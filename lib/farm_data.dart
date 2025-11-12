import 'package:flutter/material.dart';
import 'package:excel/excel.dart' as xls;
import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class FarmDataWidget extends StatefulWidget {
  const FarmDataWidget({super.key});

  @override
  State<FarmDataWidget> createState() => _FarmDataWidgetState();
}

class _FarmDataWidgetState extends State<FarmDataWidget> {
  List<Map<String, dynamic>> sensorData = [];
  String selectedCycle = 'Cycle-1';
  String selectedDuration = 'Weekly';

  final List<String> cycles = [
    'Cycle-1',
    'Cycle-2',
    'Cycle-3',
    'Cycle-4',
    'Cycle-5',
    'Cycle-6'
  ];
  final List<String> durations = ['Daily', 'Weekly', 'Monthly'];

  @override
  void initState() {
    super.initState();
    loadExcelData();
  }

  Future<void> loadExcelData() async {
    try {
      final file = File('farm_sensor_data_500_samples.xlsx');
      final bytes = await file.readAsBytes();
      final excel = xls.Excel.decodeBytes(bytes);
      final sheet = excel.tables[excel.tables.keys.first]!;

      List<Map<String, dynamic>> rows = [];
      for (int i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];
        rows.add({
          "Date": row[0]?.value.toString(),
          "Sensor": row[1]?.value.toString(),
          "Moisture": double.tryParse(row[2]?.value.toString() ?? '0'),
          "pH": double.tryParse(row[3]?.value.toString() ?? '0'),
          "Nitrogen": double.tryParse(row[4]?.value.toString() ?? '0'),
          "Phosphorus": double.tryParse(row[5]?.value.toString() ?? '0'),
          "Potassium": double.tryParse(row[6]?.value.toString() ?? '0'),
        });
      }

      setState(() => sensorData = rows);
    } catch (e) {
      debugPrint("Error loading Excel: $e");
    }
  }

  List<Map<String, dynamic>> getFilteredData() {
    if (sensorData.isEmpty) return [];

    DateTime latest = DateFormat("yyyy-MM-dd").parse(sensorData.last['Date']);
    DateTime cutoff;

    switch (selectedDuration) {
      case 'Daily':
        cutoff = latest.subtract(const Duration(days: 1));
        break;
      case 'Weekly':
        cutoff = latest.subtract(const Duration(days: 7));
        break;
      case 'Monthly':
      default:
        cutoff = latest.subtract(const Duration(days: 31));
        break;
    }

    return sensorData.where((d) {
      final date = DateFormat("yyyy-MM-dd").parse(d['Date']);
      return date.isAfter(cutoff);
    }).toList();
  }

  double getAverage(List<Map<String, dynamic>> data, String field) {
    if (data.isEmpty) return 0;
    final values = data.map((e) => e[field] as double).toList();
    return values.reduce((a, b) => a + b) / values.length;
  }

  Widget buildChart(String title, String field, Color color) {
    final data = getFilteredData();

    Map<String, List<double>> grouped = {};
    for (var entry in data) {
      String sensor = entry['Sensor'];
      grouped.putIfAbsent(sensor, () => []);
      grouped[sensor]!.add(entry[field]);
    }

    List<LineChartBarData> lines = [];
    grouped.forEach((sensor, values) {
      lines.add(LineChartBarData(
        isCurved: true,
        color: color.withOpacity(0.8),
        spots: values
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), e.value))
            .toList(),
      ));
    });

    double avg = getAverage(data, field);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("$title (Avg: ${avg.toStringAsFixed(2)})",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.play_arrow, color: Colors.black),
onPressed: () {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text("$title - Separate Graphs by Sensor"),
      content: SizedBox(
        width: 450,
        height: 400,
        child: ListView(
          children: grouped.entries.map((entry) {
            final sensor = entry.key;
            final values = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sensor: $sensor",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 180,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: true),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            color: color,
                            spots: values
                                .asMap()
                                .entries
                                .map((e) =>
                                    FlSpot(e.key.toDouble(), e.value))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    ),
  );
},

                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: LineChart(LineChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: true),
                titlesData: const FlTitlesData(show: false),
                lineBarsData: lines,
              )),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: selectedCycle,
                  items: cycles
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => selectedCycle = v!),
                ),
                DropdownButton<String>(
                  value: selectedDuration,
                  items: durations
                      .map((d) => DropdownMenuItem(
                            value: d,
                            child: Text(d),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => selectedDuration = v!),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  buildChart("Soil Moisture", "Moisture", Colors.blue),
                  buildChart("pH Sensor", "pH", Colors.green),
                  const SizedBox(height: 10),
                  const Text("NPK Sensor",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  buildChart("Nitrogen", "Nitrogen", Colors.red),
                  buildChart("Phosphorus", "Phosphorus", Colors.orange),
                  buildChart("Potassium", "Potassium", Colors.purple),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
