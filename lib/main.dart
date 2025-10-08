import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'ml_focus_page.dart';   // <-- your ML camera page
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart' as xls;

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

// ------------------- Dashboard with Split View -------------------

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? _selectedSite;

  final sites = [
    {"title": "SITE-1", "image": "assets/site1.png"},
    {"title": "SITE-2", "image": "assets/site2.png"},
    {"title": "SITE-3", "image": "assets/site3.png"},
    {"title": "SITE-4", "image": "assets/site4.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: sites.length,
              itemBuilder: (context, index) {
                final site = sites[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: Image.asset(site["image"]!, width: 80, fit: BoxFit.cover),
                    title: Text(site["title"]!),
                    trailing: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedSite = site["title"];
                        });
                      },
                      child: const Text("GO"),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 5,
            child: _selectedSite == null
                ? const Center(child: Text("Select a site from the left"))
                : SiteDetailPanel(siteName: _selectedSite!),
          ),
        ],
      ),
    );
  }
}

// ------------------- Site Detail Panel (Tabs Inside) -------------------

class SiteDetailPanel extends StatefulWidget {
  final String siteName;
  const SiteDetailPanel({super.key, required this.siteName});

  @override
  State<SiteDetailPanel> createState() => _SiteDetailPanelState();
}

class _SiteDetailPanelState extends State<SiteDetailPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _investmentList = [];
  final List<Map<String, dynamic>> _incomeList = [];

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
              Center(child: Text("${widget.siteName} Overview")),
              Center(child: Text("Farm Data for ${widget.siteName}")),
              _buildInvestmentTable(),
            ],
          ),
        ),
      ],
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

  // ------------------- Add Dialog with Date Picker -------------------

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

    // Data
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

    final dir = await getApplicationDocumentsDirectory();
    final filePath = "${dir.path}/investment_income.xlsx";
    final fileBytes = excel.encode();
    if (fileBytes != null) {
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
    }
    debugPrint("Excel saved at $filePath");
    return filePath;
  }

  Future<void> _exportExcel() async {
    final path = await _saveToExcel();
    await Share.shareXFiles([XFile(path)], text: "Investment & Income Report");
  }
}

// ------------------- Other Pages -------------------

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  @override
  Widget build(BuildContext context) => _simplePage("Notifications Page");
}

class AlarmsPage extends StatelessWidget {
  const AlarmsPage({super.key});
  @override
  Widget build(BuildContext context) => _simplePage("Alarms Page");
}

class IrrigationPage extends StatelessWidget {
  const IrrigationPage({super.key});
  @override
  Widget build(BuildContext context) => _simplePage("Irrigation Page");
}

class FinancePage extends StatelessWidget {
  const FinancePage({super.key});
  @override
  Widget build(BuildContext context) => _simplePage("Finance Page");
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => _simplePage("Home Screen");
}

Widget _simplePage(String title) {
  return Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(child: Text(title, style: const TextStyle(fontSize: 22))),
  );
}
