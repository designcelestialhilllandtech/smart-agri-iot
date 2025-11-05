import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'farm_data.dart';
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _sites = [];
  int? _selectedIndex;

  final List<Map<String, dynamic>> investmentData = [];
  final List<Map<String, dynamic>> incomeData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );

    if (result != null) {
      for (var file in result.files) {
        _sites.add({
          'name': 'SITE-${_sites.length + 1}',
          'imageBytes': file.bytes,
          'crop': null,
          'plot': null,
          'harvestDate': null,
        });
      }
      setState(() {
        _selectedIndex = _sites.isNotEmpty ? 0 : null;
      });
    }
  }

  Future<void> _pickHarvestDate(int index) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _sites[index]['harvestDate'] ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _sites[index]['harvestDate'] = picked);
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
      setState(() {
        _sites.removeAt(index);
        if (_sites.isEmpty) {
          _selectedIndex = null;
        } else {
          _selectedIndex = 0;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: const Color(0xFF0D3A5C),
        bottom: TabBar(
          controller: _tabController,
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
          _buildFarmData(),
          _buildInvestment(),
        ],
      ),
    );
  }

  // ---------------- SITE INFO TAB ----------------
// ---------------- SITE INFO TAB ----------------
Widget _buildSiteInfo() {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // LEFT SIDE: SCROLLABLE SITE LIST + BROWSE BUTTON
      Container(
        width: 250,
        color: Colors.grey.shade200,
        child: Column(
          children: [
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Browse Sites"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D3A5C),
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(_sites.length, (index) {
                    final site = _sites[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 8),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: _selectedIndex == index
                                ? Colors.green
                                : Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 3,
                              offset: Offset(0, 2))
                        ],
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
                                fit: BoxFit.cover,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(site['name'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(10),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                            child: const Text(
                              "GO",
                              style:
                                  TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),

      // RIGHT SIDE: SELECTED SITE DETAIL
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          child: _selectedIndex == null
              ? const Center(child: Text("Select a site from the left list"))
              : _buildSiteDetail(_selectedIndex!),
        ),
      ),
    ],
  );
}

Widget _buildSiteDetail(int index) {
  final site = _sites[index];
  final harvestDate = site['harvestDate'] != null
      ? DateFormat('dd/MM/yyyy').format(site['harvestDate'])
      : "Select Date";

  int year = (site['harvestDate'] ?? DateTime.now()).year % 100;
  List<String> dateBoxes =
      List.generate(12, (i) => '${i + 1}/1/$year');

  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // SITE IMAGE HEADER
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade400),
          ),
          clipBehavior: Clip.antiAlias,
          child: site['imageBytes'] != null
              ? Image.memory(site['imageBytes'],
                  height: 250, width: double.infinity, fit: BoxFit.cover)
              : Container(
                  height: 250,
                  alignment: Alignment.center,
                  color: Colors.grey[300],
                  child: const Text("No Image Selected"),
                ),
        ),

        const SizedBox(height: 8),

        // CROP, PLOT, HARVEST INFO
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _infoBox("PLOT SIZE",
                site['plot'] ?? "Select", onTap: () {
              _showPlotDialog(site);
            }),
            _infoBox("CROP", site['crop'] ?? "Select", onTap: () {
              _showCropDialog(site);
            }),
            _infoBox("~HARVEST", harvestDate, onTap: () {
              _pickHarvestDate(index);
            }),
          ],
        ),

        const SizedBox(height: 16),

        // SCALE + WEATHER + ANALYSIS SCALE
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Image.asset('assets/weather.jpg',
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover),
                  const SizedBox(height: 8),

                ],
              ),
            ),
            const SizedBox(width: 10),

            // 🔍 ANALYSIS SCALE BUILT IN FLUTTER
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Analysis Scale for Hybrid",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          decoration: TextDecoration.underline),
                    ),
                    const SizedBox(height: 8),
                    _legendBox(Colors.green, "Good Crop Health & Irrigation"),
                    _legendBox(Colors.orange,
                        "Requires Crop Health attention"),
                    _legendBox(Colors.purple,
                        "Requires Irrigation attention"),
                    _legendBox(Colors.red,
                        "Critical Crop Health & Irrigation"),
                    _legendBox(Colors.grey,
                        "No crop/clouds over the farm"),
                    const SizedBox(height: 8),
                    const Text(
                      "00.0% 🟩 Good Crop Health & Irrigation\n"
                      "24.7% 🟧 Requires Crop Health Attention\n"
                      "00.0% 🟪 Requires Irrigation Attention\n"
                      "75.3% 🟥 Critical Crop Health & Irrigation\n"
                      "00.0% ⚪ Cloud Cover / No Crop",
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // DATE BOXES
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: dateBoxes
                .map((d) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Text(
                        d,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ))
                .toList(),
          ),
        ),

        const SizedBox(height: 10),

        // PROGRESS COLOR BAR
        Row(
          children: [
            Expanded(flex: 3, child: Container(height: 25, color: Colors.green)),
            Expanded(flex: 2, child: Container(height: 25, color: Colors.blue)),
          ],
        ),
        const SizedBox(height: 10),
      ],
    ),
  );
}

// 🔹 Helper Widget for Legend Rows
Widget _legendBox(Color color, String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Container(width: 20, height: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 12)),
        ),
      ],
    ),
  );
}


// Helper: Info Box
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

// Simple popups for crop/plot selection
void _showCropDialog(Map<String, dynamic> site) {
  showDialog(
    context: context,
    builder: (context) {
      return SimpleDialog(
        title: const Text("Select Crop"),
        children: ["Ginger", "Tomato", "Paddy", "Banana"].map((crop) {
          return SimpleDialogOption(
            onPressed: () {
              setState(() => site['crop'] = crop);
              Navigator.pop(context);
            },
            child: Text(crop),
          );
        }).toList(),
      );
    },
  );
}

void _showPlotDialog(Map<String, dynamic> site) {
  showDialog(
    context: context,
    builder: (context) {
      return SimpleDialog(
        title: const Text("Select Plot Size"),
        children: ["5 Cent", "10 Cent", "20 Cent"].map((plot) {
          return SimpleDialogOption(
            onPressed: () {
              setState(() => site['plot'] = plot);
              Navigator.pop(context);
            },
            child: Text(plot),
          );
        }).toList(),
      );
    },
  );
}


  // ---------------- FARM DATA TAB ----------------
Widget _buildFarmData() {
  return const FarmDataWidget();
}

  // ---------------- INVESTMENT TAB ----------------
  Widget _buildInvestment() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(child: _buildTable("Investment", investmentData)),
          const SizedBox(width: 10),
          Expanded(child: _buildTable("Income", incomeData)),
        ],
      ),
    );
  }

  Widget _buildTable(String title, List<Map<String, dynamic>> data) {
    double total = data.fold(0, (sum, row) => sum + (row['amount'] ?? 0));

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                color: Colors.yellow,
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                child: Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  setState(() {
                    data.add({
                      'item': '',
                      'vendor': '',
                      'date': DateTime.now(),
                      'amount': 0.0,
                    });
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 600),
              child: Table(
                border: TableBorder.all(color: Colors.grey.shade400),
                columnWidths: const {
                  0: FixedColumnWidth(40),
                  1: FlexColumnWidth(),
                  2: FlexColumnWidth(),
                  3: FlexColumnWidth(),
                  4: FlexColumnWidth(),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xFF0D3A5C)),
                    children: [
                      _tableHeader('#'),
                      _tableHeader('Item'),
                      _tableHeader('Vendor'),
                      _tableHeader('Date'),
                      _tableHeader('Amount (₹)'),
                    ],
                  ),
                  ...data.asMap().entries.map((entry) {
                    int i = entry.key + 1;
                    Map<String, dynamic> row = entry.value;
                    return TableRow(children: [
                      _tableCell(Text('$i', textAlign: TextAlign.center)),
                      _tableInput(row, 'item'),
                      _tableInput(row, 'vendor'),
                      _tableDate(row),
                      _tableAmount(row),
                    ]);
                  }),
                  TableRow(children: [
                    const SizedBox(),
                    const Padding(
                        padding: EdgeInsets.all(6),
                        child: Text('Total',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    const SizedBox(),
                    const SizedBox(),
                    Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text('₹${total.toStringAsFixed(2)}',
                            textAlign: TextAlign.center)),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
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

  Widget _tableInput(Map<String, dynamic> row, String key) => Padding(
        padding: const EdgeInsets.all(4),
        child: TextFormField(
          initialValue: row[key],
          onChanged: (v) => row[key] = v,
          decoration: const InputDecoration(border: InputBorder.none),
        ),
      );

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
          initialValue: row['amount'].toString(),
          keyboardType: TextInputType.number,
          onChanged: (v) => setState(() {
            row['amount'] = double.tryParse(v) ?? 0.0;
          }),
          decoration: const InputDecoration(border: InputBorder.none),
        ),
      );
}
