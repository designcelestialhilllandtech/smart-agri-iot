import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'ml_focus_page.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart' as xls;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html; 


void main() {
  runApp(const SmartIoTApp());
}

class SmartIoTApp extends StatelessWidget {
  const SmartIoTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart IoT App',
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset("assets/logo.png", height: 50),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("CELESTIAL",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            Text("HILLAND TECH",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person,
                              size: 30, color: Colors.blueAccent),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const HomeScreen()));
                          },
                          icon: const Icon(Icons.home,
                              color: Colors.white, size: 30),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSideButton(
                          context, "NOTIFICATIONS", const NotificationsPage()),
                      const SizedBox(height: 12),
                      _buildSideButton(context, "ALARMS", const AlarmsPage()),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMenuButton(context, "assets/dashboard.png",
                        "DASHBOARD", const DashboardPage()),
                    _buildMenuButton(context, "assets/ml.png", "ML FOCUS",
                        const MLFocusPage()),
                    _buildMenuButton(context, "assets/irrigation.jpg",
                        "IRRIGATION", const IrrigationPage()),
                    _buildMenuButton(context, "assets/finance.png", "FINANCE",
                        const FinancePage()),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSideButton(BuildContext context, String label, Widget page) {
    return InkWell(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        width: 180,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          border: Border.all(color: Colors.black),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildMenuButton(
      BuildContext context, String iconPath, String label, Widget page) {
    return InkWell(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.blue[800],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconPath, height: 40),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ---------------- DASHBOARD PAGE ----------------

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Map<String, dynamic>> sites = [];
  Map<String, dynamic>? _selectedSite;

  Future<void> _browseImages() async {
    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
        withData: true,
      );
      if (result != null) {
        setState(() {
          sites = List.generate(result.files.length, (i) {
            final file = result.files[i];
            return {
              "title": "SITE-${i + 1}",
              "bytes": file.bytes,
              "name": file.name,
            };
          });
        });
      }
    } else {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      );
      if (result != null) {
        setState(() {
          sites = List.generate(result.paths.length, (i) {
            return {
              "title": "SITE-${i + 1}",
              "path": result.paths[i],
            };
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            onPressed: _browseImages,
            icon: const Icon(Icons.folder_open),
            tooltip: "Browse Images",
          ),
        ],
      ),
      body: Row(
        children: [
          // ---------- LEFT SIDE: Site List ----------
          Expanded(
            flex: 2,
            child: sites.isEmpty
                ? const Center(
                    child: Text(
                      "No site images found.\nClick 📂 to browse images.",
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: sites.length,
                    itemBuilder: (context, index) {
                      final site = sites[index];
                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          leading: kIsWeb
                              ? Image.memory(
                                  site["bytes"],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(site["path"]!),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                          title: Text(site["title"]),
                          trailing: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedSite = site;
                              });
                            },
                            child: const Text("GO"),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // ---------- RIGHT SIDE: Tabs Only ----------
          Expanded(
            flex: 5,
            child: _selectedSite == null
                ? const Center(
                    child: Text(
                      "Select a site from the left",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                : SiteDetailPanel(site: _selectedSite!),
          ),
        ],
      ),
    );
  }
}
// ===================== AXIS PAINTER =====================
class _AxesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black45
      ..strokeWidth = 1;

    // X and Y axes
    canvas.drawLine(
      Offset(40, size.height - 30),
      Offset(size.width - 10, size.height - 30),
      paint,
    );
    canvas.drawLine(
      Offset(40, 10),
      Offset(40, size.height - 30),
      paint,
    );

    // Horizontal gridlines
    for (double y = 30; y < size.height - 30; y += 40) {
      canvas.drawLine(
        Offset(40, y),
        Offset(size.width - 10, y),
        paint..color = Colors.black12,
      );
    }

    // Vertical gridlines
    for (double x = 80; x < size.width - 10; x += 60) {
      canvas.drawLine(
        Offset(x, 10),
        Offset(x, size.height - 30),
        paint..color = Colors.black12,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ------------------- Site Detail Panel -------------------

class SiteDetailPanel extends StatefulWidget {
  final Map<String, dynamic> site;
  const SiteDetailPanel({super.key, required this.site});

  @override
  State<SiteDetailPanel> createState() => _SiteDetailPanelState();
  
}


class _SiteDetailPanelState extends State<SiteDetailPanel>
    with SingleTickerProviderStateMixin {
      
  late TabController _tabController;

  final List<Map<String, dynamic>> _investmentList = [];
  final List<Map<String, dynamic>> _incomeList = [];

  String? selectedCrop;
  double? plotSize;
  DateTime? harvestDate;

  final List<String> crops = ["Wheat", "Rice", "Corn", "Ginger", "Garlic"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.blue,
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            tabs: const [
              Tab(text: "Site"),
              Tab(text: "Farm Data"),
              Tab(text: "Investment"),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSiteOverviewTab(),
              _buildFarmDataTab(),
              _buildInvestmentTable(),
            ],
          ),
        ),
      ],
    );
  }

Widget _buildFarmDataTab() {
  String selectedCycle = 'Cycle-1';
  String selectedPeriod = 'Weekly';
  List<String> cycles = ['Cycle-1', 'Cycle-2', 'Cycle-3', 'Cycle-4', 'Cycle-5'];
  List<String> periods = ['Weekly', 'Monthly'];

  return StatefulBuilder(
    builder: (context, setState) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔹 Dropdown Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<String>(
                    value: selectedCycle,
                    items: cycles
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedCycle = val!),
                  ),
                  const SizedBox(width: 20),
                  DropdownButton<String>(
                    value: selectedPeriod,
                    items: periods
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedPeriod = val!),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 🔹 Graphs (5 total)
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  _buildGraphBox("Soil Moisture"),
                  _buildGraphBox("Ph Sensor"),
                  _buildGraphBox("Nitrogen"),
                  _buildGraphBox("Phosphorus"),
                  _buildGraphBox("Potassium"),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

// 🔹 Graph Box (Title + Axis)
Widget _buildGraphBox(String title) {
  return Container(
    width: 350,
    height: 250,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 3)),
      ],
    ),
    padding: const EdgeInsets.all(12),
    child: Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: CustomPaint(
            size: const Size(double.infinity, double.infinity),
            painter: _AxesPainter(),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildSiteOverviewTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: kIsWeb
                  ? Image.memory(widget.site["bytes"], fit: BoxFit.contain)
                  : Image.file(File(widget.site["path"]), fit: BoxFit.contain),
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                const Text("Plot Size (cent): ",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 10),
                DropdownButton<double>(
                  hint: const Text("Select"),
                  value: plotSize,
                  items: List.generate(100, (i) => (i + 1) * 1.0)
                      .map((val) =>
                          DropdownMenuItem(value: val, child: Text("$val")))
                      .toList(),
                  onChanged: (val) => setState(() => plotSize = val),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                const Text("Crop: ",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  hint: const Text("Select Crop"),
                  value: selectedCrop,
                  items: crops
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedCrop = val),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                const Text("Harvest Date: ",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) {
                      setState(() => harvestDate = picked);
                    }
                  },
                  child: Text(harvestDate == null
                      ? "Select Date"
                      : DateFormat('dd-MM-yyyy').format(harvestDate!)),
                ),
              ],
            ),
            const SizedBox(height: 20),

// 🔹 WEATHER BOX
WeatherBox(
  latitude: 8.385,  // 🔹 Replace with your actual site’s latitude
  longitude: 77.05, // 🔹 Replace with your actual site’s longitude
),

const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }

  // ------------------- Investment / Income Table -------------------

  Widget _buildInvestmentTable() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text("Investment / Income",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildTable("Investment", _investmentList)),
                const SizedBox(width: 12),
                Expanded(child: _buildTable("Income", _incomeList)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _exportExcel,
            icon: const Icon(Icons.download),
            label: const Text("Export to Excel"),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(String title, List<Map<String, dynamic>> dataList) {
    final total = dataList.fold<double>(
        0, (sum, item) => sum + (item["amount"] as double));

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.yellow,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.add_box, color: Colors.black),
                onPressed: () => _showAddDialog(title, dataList),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: dataList.length,
            itemBuilder: (context, i) {
              final item = dataList[i];
              return ListTile(
                leading: Text("${i + 1}"),
                title: Text(item["name"]),
                subtitle: Text(item["date"]),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("₹${item["amount"].toStringAsFixed(2)}"),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          dataList.removeAt(i);
                          _saveToExcel();
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Total : ₹${total.toStringAsFixed(2)}",
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  void _showAddDialog(String title, List<Map<String, dynamic>> dataList) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add $title"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: "Amount"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text("Date: "),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Text(
                    "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  amountController.text.isNotEmpty) {
                setState(() {
                  dataList.add({
                    "name": nameController.text,
                    "amount": double.tryParse(amountController.text) ?? 0,
                    "date":
                        "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}",
                  });
                  _saveToExcel();
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // ------------------- Excel Export -------------------

  Future<String> _saveToExcel() async {
    final excel = xls.Excel.createExcel();
    final xls.Sheet investmentSheet = excel['Investment'];
    final xls.Sheet incomeSheet = excel['Income'];

    // Headers
    investmentSheet.appendRow([
      xls.TextCellValue("Name"),
      xls.TextCellValue("Amount"),
      xls.TextCellValue("Date"),
    ]);
    incomeSheet.appendRow([
      xls.TextCellValue("Name"),
      xls.TextCellValue("Amount"),
      xls.TextCellValue("Date"),
    ]);

    for (var item in _investmentList) {
      investmentSheet.appendRow([
        xls.TextCellValue(item["name"]),
        xls.DoubleCellValue(item["amount"]),
        xls.TextCellValue(item["date"]),
      ]);
    }
    for (var item in _incomeList) {
      incomeSheet.appendRow([
        xls.TextCellValue(item["name"]),
        xls.DoubleCellValue(item["amount"]),
        xls.TextCellValue(item["date"]),
      ]);
    }

     // Save file
String filePath;
List<int>? fileBytes = excel.encode();

if (kIsWeb) {
  // Web: create a downloadable file
  final content = base64Encode(fileBytes!);
  final anchor = html.AnchorElement(
    href: "data:application/octet-stream;charset=utf-16le;base64,$content",
  )
    ..setAttribute("download",
        "Farm_Investment_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx")
    ..click();
  return "web";
} else {
  // Mobile/Desktop
  final dir = await getApplicationDocumentsDirectory();
  filePath =
      '${dir.path}/Farm_Investment_${DateFormat("yyyyMMdd_HHmmss").format(DateTime.now())}.xlsx';
  final file = File(filePath);
  await file.writeAsBytes(fileBytes!, flush: true);
}



  final file = File(filePath);
  await file.writeAsBytes(fileBytes, flush: true);

  return filePath;
}

Future<void> _exportExcel() async {
  try {
    final filePath = await _saveToExcel();
    await Share.shareXFiles([XFile(filePath)], text: "Farm Data Excel Export");
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Export failed: $e")),
    );
  }
}
  }


// ------------- PLACEHOLDER PAGES -------------

class MLFocusPage extends StatelessWidget {
  const MLFocusPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(child: Text("ML Focus Page Placeholder")));
  }
}

class IrrigationPage extends StatelessWidget {
  const IrrigationPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(child: Text("Irrigation Page Placeholder")));
  }
}

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // For calculator
  String _expression = "";
  String _result = "";

  // For ROI calculator
  final TextEditingController investmentCtrl = TextEditingController();
  final TextEditingController incomeCtrl = TextEditingController();
  String roiResult = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _onButtonPressed(String value) {
    setState(() {
      if (value == "C") {
        _expression = "";
        _result = "";
      } else if (value == "=") {
        try {
          final exp = _expression
              .replaceAll("×", "*")
              .replaceAll("÷", "/")
              .replaceAll("–", "-");
          final res = _evalExpression(exp);
          _result = res.toStringAsFixed(2);
        } catch (e) {
          _result = "Error";
        }
      } else {
        _expression += value;
      }
    });
  }

  double _evalExpression(String exp) {
    exp = exp.replaceAll(" ", "");
    List<String> tokens = exp.split(RegExp(r"([+\-*/])"));
    List<String> ops = RegExp(r"([+\-*/])")
        .allMatches(exp)
        .map((m) => m.group(0)!)
        .toList();

    double result = double.parse(tokens[0]);
    for (int i = 0; i < ops.length; i++) {
      double nextNum = double.parse(tokens[i + 1]);
      switch (ops[i]) {
        case "+":
          result += nextNum;
          break;
        case "-":
          result -= nextNum;
          break;
        case "*":
          result *= nextNum;
          break;
        case "/":
          result /= nextNum;
          break;
      }
    }
    return result;
  }

  void _calculateROI() {
    final investment = double.tryParse(investmentCtrl.text) ?? 0;
    final income = double.tryParse(incomeCtrl.text) ?? 0;

    if (investment <= 0) {
      setState(() {
        roiResult = "Invalid investment amount";
      });
      return;
    }

    final roi = ((income - investment) / investment) * 100;
    setState(() {
      roiResult = "ROI: ${roi.toStringAsFixed(2)}%";
    });
  }

  @override
  Widget build(BuildContext context) {
    final buttons = [
      ["7", "8", "9", "÷"],
      ["4", "5", "6", "×"],
      ["1", "2", "3", "–"],
      ["0", ".", "C", "="],
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Finance"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Calculator"),
            Tab(text: "ROI Calculator"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ---------------- Calculator Tab ----------------
          Column(
            children: [
              const SizedBox(height: 20),
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _expression,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20, top: 10),
                child: Text(
                  _result,
                  style: const TextStyle(
                    fontSize: 36,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1,
                  ),
                  itemCount: buttons.length * 4,
                  itemBuilder: (context, index) {
                    final row = index ~/ 4;
                    final col = index % 4;
                    final label = buttons[row][col];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (label == "=")
                              ? Colors.orange
                              : (["÷", "×", "–"].contains(label))
                                  ? Colors.blueGrey
                                  : Colors.white,
                          foregroundColor: (label == "=")
                              ? Colors.white
                              : (["÷", "×", "–"].contains(label))
                                  ? Colors.white
                                  : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(18),
                        ),
                        onPressed: () => _onButtonPressed(label),
                        child: Text(label,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // ---------------- ROI Calculator Tab ----------------
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  "Return on Investment (ROI)",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: investmentCtrl,
                  decoration: const InputDecoration(
                    labelText: "Total Investment (₹)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: incomeCtrl,
                  decoration: const InputDecoration(
                    labelText: "Total Income (₹)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _calculateROI,
                  icon: const Icon(Icons.calculate),
                  label: const Text("Calculate ROI"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    backgroundColor: Colors.green,
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  roiResult,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(child: Text("Home Screen Placeholder")));
  }
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(child: Text("Notifications Page Placeholder")));
  }
}

class AlarmsPage extends StatelessWidget {
  const AlarmsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(child: Text("Alarms Page Placeholder")));
  }
}
class WeatherBox extends StatefulWidget {
  final double latitude;
  final double longitude;

  const WeatherBox({super.key, required this.latitude, required this.longitude});

  @override
  State<WeatherBox> createState() => _WeatherBoxState();
}

class _WeatherBoxState extends State<WeatherBox> {
  Map<String, dynamic>? weatherData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    const apiKey = "YOUR_API_KEY"; // 🔹 replace with your actual key
    final url =
        "https://api.openweathermap.org/data/2.5/weather?lat=${widget.latitude}&lon=${widget.longitude}&units=metric&appid=$apiKey";

    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        setState(() {
          weatherData = json.decode(res.body);
          isLoading = false;
        });
      } else {
        print("Failed to fetch weather: ${res.statusCode}");
      }
    } catch (e) {
      print("Error fetching weather: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final temp = weatherData?['main']?['temp']?.toStringAsFixed(1) ?? "--";
    final condition = weatherData?['weather']?[0]?['main'] ?? "N/A";
    final humidity = weatherData?['main']?['humidity'] ?? "--";
    final wind = weatherData?['wind']?['speed'] ?? "--";

    return Card(
      color: Colors.lightBlue.shade50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "🌦️ Current Weather",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("$temp°C",
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Condition: $condition"),
                    Text("Humidity: $humidity%"),
                    Text("Wind: $wind m/s"),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
