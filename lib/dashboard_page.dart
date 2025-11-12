// dashboard_page.dart
import 'dart:typed_data';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'farm_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const String OPENWEATHER_API_KEY = '9fe0fffc423415be0b52229540367576'; // <-- PUT YOUR KEY

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}
Map<String, List<Map<String, dynamic>>> siteInvestments = {};
Map<String, List<Map<String, dynamic>>> siteIncomes = {};

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  // ---------- ADDED CONTROLLERS ----------
  TextEditingController investmentController = TextEditingController();
  TextEditingController incomeController = TextEditingController();

  Future<void> fetchSiteData(String siteName) async {
    try {
      DocumentSnapshot siteSnapshot = await FirebaseFirestore.instance
          .collection('farm_data')
          .doc(siteName)
          .get();

      if (siteSnapshot.exists) {
        Map<String, dynamic>? data =
            siteSnapshot.data() as Map<String, dynamic>?;

        if (data != null) {
          setState(() {
            investmentController.text = data['investment']?.toString() ?? '';
            incomeController.text = data['income']?.toString() ?? '';
            // Add other fields if needed
          });
        }
      } else {
        setState(() {
          investmentController.clear();
          incomeController.clear();
        });
      }
    } catch (e) {
      print("Error fetching site data: $e");
    }
  }

Future<void> _loadDataFromFirestore(String siteName) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('sites')
        .doc(siteName)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        siteInvestments[siteName] =
            List<Map<String, dynamic>>.from(data['investments'] ?? []);
        siteIncomes[siteName] =
            List<Map<String, dynamic>>.from(data['incomes'] ?? []);
      });
    }
  } catch (e) {
    debugPrint('❌ Error loading data from Firestore: $e');
  }
}

Future<void> _saveDataToFirestore(String siteName) async {
  try {
    final docRef =
        FirebaseFirestore.instance.collection('sites').doc(siteName);

    await docRef.set({
      'investments': siteInvestments[siteName] ?? [],
      'incomes': siteIncomes[siteName] ?? [],
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    debugPrint('✅ Data saved to Firestore for $siteName');
  } catch (e) {
    debugPrint('❌ Error saving to Firestore: $e');
  }
}

  
  Future<Map<String, dynamic>?> _showAddEntryDialog(String title) async {
    String item = '';
    String vendorOrRemarks = '';
    DateTime? date = DateTime.now();
    String amountStr = '';

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add $title Entry"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Item Name'),
                onChanged: (v) => item = v,
              ),
              TextField(
                decoration: InputDecoration(
                    labelText:
                        title == "Investment" ? "Vendor" : "Remarks"),
                onChanged: (v) => vendorOrRemarks = v,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Amount (₹)'),
                keyboardType: TextInputType.number,
                onChanged: (v) => amountStr = v,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text("Date: "),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: date ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) date = picked;
                    },
                    child: Text(DateFormat('dd/MM/yyyy').format(date!)),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (item.isNotEmpty && vendorOrRemarks.isNotEmpty && amountStr.isNotEmpty) {
                  Navigator.pop(context, {
                    'item': item,
                    title == "Investment"
                        ? 'vendor'
                        : 'remarks': vendorOrRemarks,
                    'date': date,
                    'amount': double.tryParse(amountStr) ?? 0.0,
                  });
                }
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }


  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Map<String, dynamic>> _sites = [];
  int? _selectedIndex;

  // weather + location state
  Map<String, dynamic>? _weather; // holds weather JSON
  Position? _position;
  bool _loadingWeather = false;
  String? _weatherError;

  final List<Map<String, dynamic>> investmentData = [];
  final List<Map<String, dynamic>> incomeData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSitesFromFirebase();
  }

  // ---------------- Firestore load/save (unchanged)
Future<void> _loadSitesFromFirebase() async {
  try {
    final snapshot = await _firestore.collection('sites').get();

    // Remove duplicates by site name
    final uniqueNames = <String>{};
    final sites = <Map<String, dynamic>>[];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final name = data['name'] ?? 'Unnamed Site';
      if (uniqueNames.contains(name)) continue; // skip duplicate names
      uniqueNames.add(name);

      Uint8List? imageBytes;
      if (data['imageBytes'] != null) {
        try {
          imageBytes = base64Decode(data['imageBytes']); // ✅ decode base64
        } catch (e) {
          debugPrint("⚠️ Error decoding image for site $name: $e");
        }
      }

      sites.add({
        'id': doc.id,
        'name': name,
        'crop': data['crop'],
        'plot': data['plot'],
        'cycle': data['cycle'],
        'harvestDate': data['harvestDate'] != null
            ? (data['harvestDate'] as Timestamp).toDate()
            : null,
        'plantedDate': data['plantedDate'] != null
            ? (data['plantedDate'] as Timestamp).toDate()
            : null,
        'imageBytes': imageBytes, // ✅ store decoded bytes
      });
    }

    // 🔹 Update state once after loop finishes
    setState(() {
      _sites
        ..clear()
        ..addAll(sites);
      _selectedIndex = _sites.isNotEmpty ? 0 : null;
    });

    if (_selectedIndex != null) {
      _updateWeatherForSelectedSite();
    }
  } catch (e) {
    debugPrint("❌ Error loading sites from Firestore: $e");
  }
}




Future<void> _saveSiteToFirebase(Map<String, dynamic> site) async {
  try {
    final imageString = site['imageBytes'] != null
        ? base64Encode(site['imageBytes'])
        : null;

    if (site['id'] != null) {
      // 🔹 Update existing document
      await _firestore.collection('sites').doc(site['id']).update({
        'name': site['name'],
        'crop': site['crop'],
        'plot': site['plot'],
        'cycle': site['cycle'],
        'plantedDate': site['plantedDate'],
        'harvestDate': site['harvestDate'],
        'imageBytes': imageString, // ✅ save image as Base64
      });
    } else {
      // 🔹 Add new document
      final doc = await _firestore.collection('sites').add({
        'name': site['name'],
        'crop': site['crop'],
        'plot': site['plot'],
        'cycle': site['cycle'],
        'plantedDate': site['plantedDate'],
        'harvestDate': site['harvestDate'],
        'imageBytes': imageString, // ✅ save image as Base64
      });
      site['id'] = doc.id;
    }
  } catch (e) {
    debugPrint("❌ Error saving site to Firestore: $e");
  }
}

  // ---------------- Pick image (unchanged)
  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
      withData: true,
    );

    if (result != null) {
      for (var file in result.files) {
        final newName = 'SITE-${_sites.length + 1}';

        // 🚫 Skip if a site with this name already exists
        bool exists = _sites.any((s) => s['name'] == newName);
        if (exists) continue;

        final newSite = {
          'name': newName,
          'imageBytes': file.bytes,
          'crop': null,
          'plot': null,
          'plantedDate': null,
          'harvestDate': null,
        };
        await _saveSiteToFirebase(newSite);
        _sites.add(newSite);
      }

      setState(() {
        _selectedIndex = _sites.isNotEmpty ? 0 : null;
      });
    }
  }


  // ---------------- date pickers (generalized)
  Future<void> _pickDate(int index, String type) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _sites[index][type] ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _sites[index][type] = picked);
      await _saveSiteToFirebase(_sites[index]);
    }
  }

  Future<void> _confirmDeleteSite(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Site"),
        content: Text(
            "Are you sure you want to delete ${_sites[index]['name']}? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (_sites[index]['id'] != null) {
        await _firestore.collection('sites').doc(_sites[index]['id']).delete();
      }
      setState(() {
        _sites.removeAt(index);
        _selectedIndex = _sites.isEmpty ? null : 0;
      });
    }
  }

  // ---------------- WEATHER & GEO functions ----------------

  Future<void> _updateWeatherForSelectedSite() async {
    // If we already have a site with lat/lon stored later, use it.
    // For now we request device location and fetch weather for that lat/lon.
    if (_selectedIndex == null) return;
    await _determinePosition();
    if (_position != null) {
      await _fetchWeather(_position!.latitude, _position!.longitude);
    }
  }

  Future<void> _determinePosition() async {
    setState(() {
      _loadingWeather = true;
      _weatherError = null;
    });

    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _weatherError = 'Location services are disabled.';
          _loadingWeather = false;
        });
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _weatherError = 'Location permissions are denied';
            _loadingWeather = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _weatherError =
              'Location permissions are permanently denied. Please enable them in settings.';
          _loadingWeather = false;
        });
        return;
      }

      _position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);
    } catch (e) {
      _weatherError = 'Failed to get location: $e';
    } finally {
      // don't set _loadingWeather false yet — weather fetch follows
      if (_position == null) _loadingWeather = false;
    }
  }

  Future<void> _fetchWeather(double lat, double lon) async {
    setState(() {
      _loadingWeather = true;
      _weatherError = null;
    });

    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$OPENWEATHER_API_KEY';

    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        _weather = json.decode(res.body) as Map<String, dynamic>;
      } else {
        _weatherError =
            'Weather API error: ${res.statusCode} ${res.reasonPhrase}';
      }
    } catch (e) {
      _weatherError = 'Failed to fetch weather: $e';
    } finally {
      setState(() {
        _loadingWeather = false;
      });
    }
  }

  // ---------------- UI build ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: const Color(0xFF0D3A5C),
bottom: TabBar(
  controller: _tabController,
  labelColor: Colors.white, // active tab text color
  unselectedLabelColor: Colors.white70, // inactive tab text color
  indicatorColor: Colors.white, // underline color
  labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
  unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
  tabs: const [
    Tab(text: "SITE INFO"),
    Tab(text: "FARM DATA"),
    Tab(text: "INVESTMENT"),
  ],
),

      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSiteInfo(),
          const FarmDataWidget(),
          _buildInvestment(),
        ],
      ),
    );
  }

  Widget _buildSiteInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // left column
        Container(
          width: 250,
          color: Colors.grey.shade200,
          child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const SizedBox(height: 10),

    // 🔽 Always visible site dropdown
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          const Text(
            "Select Site:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<int>(
              value: _selectedIndex,
              isExpanded: true,
              hint: const Text("Choose a site"),
              items: List.generate(_sites.length, (index) {
                final site = _sites[index];
                return DropdownMenuItem<int>(
                  value: index,
                  child: Text(site['name']),
                );
              }),
onChanged: (newIndex) async {
  if (newIndex != null) {
    final selectedSite = _sites[newIndex];

    // Fetch latest data from Firestore
    final docRef = _firestore.collection('sites').doc(selectedSite['id']);
    final docSnap = await docRef.get();

if (docSnap.exists) {
  final data = docSnap.data()!;

  setState(() {
    Uint8List? imageBytes;
    if (data['imageBytes'] != null) {
      try {
        imageBytes = base64Decode(data['imageBytes']);
      } catch (e) {
        debugPrint("⚠️ Error decoding image: $e");
      }
    }

    _sites[newIndex] = {
      ..._sites[newIndex],
      'name': data['name'],
      'plot': data['plot'],
      'crop': data['crop'],
      'cycle': data['cycle'],
      'plantedDate': data['plantedDate'] != null
          ? (data['plantedDate'] as Timestamp).toDate()
          : null,
      'harvestDate': data['harvestDate'] != null
          ? (data['harvestDate'] as Timestamp).toDate()
          : null,
      'imageBytes': imageBytes, // ✅ FIX: fetched from Firestore
    };
    _selectedIndex = newIndex;
  });
}


    // ✅ Update weather
    await _updateWeatherForSelectedSite();
  }
},

            ),
          ),
        ],
      ),
    ),

    const SizedBox(height: 10),

    // 🖼️ Browse Sites button (always visible)
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton.icon(
        onPressed: _pickImage,
        icon: const Icon(Icons.image),
        label: const Text("Browse Sites"),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D3A5C),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
    ),

    const SizedBox(height: 10),

    // 📜 Scrollable site list below fixed controls
    Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(_sites.length, (index) {
            final site = _sites[index];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: _selectedIndex == index
                      ? Colors.green
                      : Colors.grey.shade400,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  if (site['imageBytes'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.memory(
                        site['imageBytes'],
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    site['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedIndex == index
                              ? Colors.green
                              : Colors.grey.shade500,
                          shape: const CircleBorder(),
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                          Future.delayed(
                            const Duration(milliseconds: 50),
                            _updateWeatherForSelectedSite,
                          );
                        },
                        child: const Text(
                          "GO",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeleteSite(index),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    ),
  ],
)

        ),

        // right details
// right details
Expanded(
  child: Container(
    padding: const EdgeInsets.all(12),
    child: _sites.isEmpty
        ? const Center(child: Text("No sites available"))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔽 Dropdown selector for sites
 
              const SizedBox(height: 12),

              Expanded(
                child: _selectedIndex == null
                    ? const Center(
                        child: Text("Select a site from dropdown"))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildSiteDetail(_selectedIndex!)),
                          const SizedBox(height: 8),
                          _buildWeatherSection(),
                          const SizedBox(height: 8),
                          _buildGeoSection(),
                        ],
                      ),
              ),
            ],
          ),
  ),
),

      ],
    );
  }
Widget _buildSiteDetail(int index) {
  final site = _sites[index];

  String plantedDateText = site['plantedDate'] != null
      ? DateFormat('dd/MM/yyyy').format(site['plantedDate'])
      : "Select";
  String harvestDateText = site['harvestDate'] != null
      ? DateFormat('dd/MM/yyyy').format(site['harvestDate'])
      : "Select";

  // timeline range
  DateTime? start = site['plantedDate'];
  DateTime? end = site['harvestDate'];
  if (start == null && end != null) {
    start = DateTime(end.year - (end.month <= 12 ? 1 : 0), end.month, end.day);
  }

  // 🔹 List of cycles
  final List<String> cycles = ["Cycle 1", "Cycle 2", "Cycle 3", "Cycle 4"];

  return SingleChildScrollView(
    child: Column(
      children: [
        Row(
          children: [
            // site image
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                clipBehavior: Clip.antiAlias,
                child: site['imageBytes'] != null
                    ? Image.memory(
                        site['imageBytes'],
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      )
                    : Container(
                        height: 250,
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: const Text("No Image Selected"),
                      ),
              ),
            ),

            const SizedBox(width: 10),

            // analysis scale image
            Expanded(
              flex: 2,
              child: Image.asset(
                'assets/scale.png',
                height: 250,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Info row: plot, crop, planted, harvest, cycle
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _plotSizeField(site),
              _infoBox("CROP", site['crop'] ?? "Select", onTap: () {
                _showCropDialog(site);
              }),
              _infoBox("PLANTED", plantedDateText,
                  onTap: () => _pickDate(index, 'plantedDate')),
              _infoBox("HARVEST", harvestDateText,
                  onTap: () => _pickDate(index, 'harvestDate')),

              // 🔹 NEW CYCLE DROPDOWN
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  border: Border.all(color: Colors.grey.shade500),
                ),
                child: Row(
                  children: [
                    const Text(
                      "Cycle: ",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(width: 6),
                    DropdownButton<String>(
                      value: site['cycle'],
                      underline: const SizedBox(),
                      hint: const Text("Select"),
                      items: cycles
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c),
                              ))
                          .toList(),
                      onChanged: (value) async {
                        setState(() => site['cycle'] = value);
                        await _saveSiteToFirebase(site);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // timeline (if planted date available)
        if (start != null)
          _buildTimelineWidget(start, end ?? (start.add(Duration(days: 365)))),
      ],
    ),
  );
}


  Widget _plotSizeField(Map<String, dynamic> site) {
    final controller = TextEditingController(text: site['plot'] ?? "");
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        border: Border.all(color: Colors.grey.shade500),
      ),
      width: 140,
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: "Plot Size",
          border: InputBorder.none,
        ),
        onChanged: (v) {
          site['plot'] = v;
        },
        onEditingComplete: () async {
          await _saveSiteToFirebase(site);
        },
      ),
    );
  }


  Widget _infoBox(String title, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          border: Border.all(color: Colors.grey.shade500),
        ),
        child: Column(
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black)),
          ],
        ),
      ),
    );
  }

  void _showCropDialog(Map<String, dynamic> site) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text("Select Crop"),
        children: ["Ginger", "Tomato", "Paddy", "Banana"].map((crop) {
          return SimpleDialogOption(
            onPressed: () async {
              setState(() => site['crop'] = crop);
              await _saveSiteToFirebase(site);
              Navigator.pop(context);
            },
            child: Text(crop),
          );
        }).toList(),
      ),
    );
  }

  // ---------------- WEATHER & GEO UI ----------------

  Widget _buildWeatherSection() {
    if (_loadingWeather) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_weatherError != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(child: Text(_weatherError!)),
            ElevatedButton(
              onPressed: _updateWeatherForSelectedSite,
              child: const Text('Retry'),
            )
          ],
        ),
      );
    }

    if (_weather == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.cloud_queue),
            const SizedBox(width: 8),
            const Expanded(child: Text('Weather: not loaded')),
            ElevatedButton(
                onPressed: _updateWeatherForSelectedSite,
                child: const Text('Load Weather'))
          ],
        ),
      );
    }

    // parse weather fields
    final main = _weather!['main'] ?? {};
    final wind = _weather!['wind'] ?? {};
    final weatherList = _weather!['weather'] as List<dynamic>?;

    final temp = main['temp']?.toString() ?? '-';
    final humidity = main['humidity']?.toString() ?? '-';
    final windSpeed = wind['speed']?.toString() ?? '-';
    final desc = weatherList != null && weatherList.isNotEmpty
        ? weatherList[0]['description']
        : '-';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          // Weather summary
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Weather: ${desc.toString().capitalizeFirst()}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _smallStat('Temp', '$temp °C'),
                    _smallStat('Humidity', '$humidity %'),
                    _smallStat('Wind', '$windSpeed m/s'),
                  ],
                )
              ],
            ),
          ),

          // Refresh & more actions
          Column(
            children: [
              ElevatedButton.icon(
                onPressed: _updateWeatherForSelectedSite,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallStat(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGeoSection() {
    final pos = _position;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: Colors.white, border: Border.all(color: Colors.grey.shade300)),
      child: Row(
        children: [
          const Icon(Icons.location_on),
          const SizedBox(width: 8),
          Expanded(
            child: Text(pos != null
                ? 'Latitude: ${pos.latitude.toStringAsFixed(5)}, Longitude: ${pos.longitude.toStringAsFixed(5)}'
                : 'Location not available'),
          ),
          ElevatedButton(
            onPressed: _updateWeatherForSelectedSite,
            child: const Text('Get Location'),
          )
        ],
      ),
    );
  }

  // ---------------- TIMELINE WIDGET ----------------
  Widget _buildTimelineWidget(DateTime start, DateTime end) {
    // clamp end >= start
    if (end.isBefore(start)) end = start.add(const Duration(days: 30));

    // produce a sensible number of boxes: months between start and end, max 24
    final months = _monthsBetween(start, end);
    final displayCount = min(months.length, 24); // cap boxes
    final displayMonths = months.take(displayCount).toList();

    // progress split: we'll color first 60% green and remaining 40% blue (example)
    final total = displayMonths.length;
    final greenCount = (total * 0.6).round();
    final blueCount = total - greenCount;

    return Column(
      children: [
        // date boxes row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // seed icon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Image.asset('assets/seed.png', width: 36, height: 36),
              ),
              ...displayMonths.map((d) {
                final label = DateFormat('M/d/yy').format(d);
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                );
              }).toList(),
              // harvest icon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Image.asset('assets/harvest.png', width: 36, height: 36),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // color progress bar (two segments) — proportionate to greenCount and blueCount
        Row(
          children: [
            Expanded(
              flex: max(1, greenCount),
              child: Container(height: 28, color: Colors.lightGreen),
            ),
            Expanded(
              flex: max(1, blueCount),
              child: Container(height: 28, color: Colors.blue.shade900),
            ),
          ],
        ),
      ],
    );
  }

  // helper to produce list of month starts between start and end inclusive
  List<DateTime> _monthsBetween(DateTime start, DateTime end) {
    final list = <DateTime>[];
    DateTime current = DateTime(start.year, start.month, 1);
    final last = DateTime(end.year, end.month, 1);
    while (!current.isAfter(last) && list.length < 120) {
      list.add(current);
      current = DateTime(current.year, current.month + 1, 1);
    }
    return list;
  }

  // ---------------- INVESTMENT TAB placeholder ----------------
  Widget _buildInvestment() {
    
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
  Expanded(
    child: _buildTable(
      "Investment",
      _selectedIndex != null ? _sites[_selectedIndex!]['name'] : "NoSite",
    ),
  ),
  const SizedBox(width: 10),
  Expanded(
    child: _buildTable(
      "Income",
      _selectedIndex != null ? _sites[_selectedIndex!]['name'] : "NoSite",
    ),
  ),

        ],
      ),
    );
  }

  Widget _buildTable(String title, String siteName) {
    final isInvestment = title == "Investment";
    final data = isInvestment
        ? (siteInvestments[siteName] ?? [])
        : (siteIncomes[siteName] ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
onPressed: () async {
  final newEntry = await _showAddEntryDialog(title);
  if (newEntry != null) {
    setState(() {
      if (isInvestment) {
        siteInvestments[siteName] = [...data, newEntry];
      } else {
        siteIncomes[siteName] = [...data, newEntry];
      }
    });

    // ✅ Save immediately to Firestore
    await _saveDataToFirestore(siteName);
  }
},

            ),
          ],
        ),
        const SizedBox(height: 8),
        data.isEmpty
            ? Text("No $title data added yet.")
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text("Item")),
                    DataColumn(label: Text("Vendor / Remarks")),
                    DataColumn(label: Text("Date")),
                    DataColumn(label: Text("Amount (₹)")),
                  ],
                  rows: data.map((entry) {
                    return DataRow(cells: [
                      DataCell(Text(entry['item'])),
                      DataCell(Text(
                          entry['vendor'] ?? entry['remarks'] ?? '')),
                      DataCell(Text(
                          DateFormat('dd/MM/yyyy').format(entry['date']))),
                      DataCell(Text(entry['amount'].toString())),
                    ]);
                  }).toList(),
                ),
              ),
        const SizedBox(height: 20),
      ],
    );
  }


  static Widget _tableHeader(String text) => Padding(
        padding: const EdgeInsets.all(6),
        child: Text(text,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center),
      );

  Widget _tableCell(Widget child) =>
      Padding(padding: const EdgeInsets.all(4), child: child);
  Widget _tableInput(Map<String, dynamic> row, String key) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: TextFormField(
        initialValue: row[key]?.toString() ?? '',
        onChanged: (v) => setState(() => row[key] = v),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        ),
      ),
    );
  }

  Widget _tableDate(Map<String, dynamic> row) => Padding(
        padding: const EdgeInsets.all(4),
        child: InkWell(
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: row['date'] ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) setState(() => row['date'] = picked);
          },
          child: Text(
            row['date'] != null
                ? DateFormat('dd/MM/yyyy').format(row['date'])
                : "Select",
            textAlign: TextAlign.center,
          ),
        ),
      );

  Widget _tableAmount(Map<String, dynamic> row) => Padding(
        padding: const EdgeInsets.all(4),
        child: TextFormField(
          initialValue: row['amount']?.toString() ?? '0',
          keyboardType: TextInputType.number,
          onChanged: (v) => setState(() {
            row['amount'] = double.tryParse(v) ?? 0.0;
          }),
          decoration: const InputDecoration(border: InputBorder.none),
        ),
      );
} // end of _DashboardPageState

// helpful extension
extension StringCasingExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
