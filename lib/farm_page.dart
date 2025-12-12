// lib/farm_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sensor_graph_page.dart';
import 'graph_widget.dart';

class FarmPage extends StatefulWidget {
  
  final String siteId;
  final String siteName;

  const FarmPage({
    super.key,
    required this.siteId,
    required this.siteName,
  });

  @override
  State<FarmPage> createState() => _FarmPageState();
}

class _FarmPageState extends State<FarmPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final List<Color> sensorColors = [
  Colors.blue,
  Colors.red,
  Colors.green,
  Colors.orange,
  Colors.purple,
  Colors.brown,
  Colors.teal,
];

  int moisture = 0;
  int ph = 0;
  int npk = 0;
  bool loading = true;

  final TextEditingController moistureCtrl = TextEditingController();
  final TextEditingController phCtrl = TextEditingController();
  final TextEditingController npkCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final doc = await _firestore.collection("farm_config").doc(widget.siteId).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        // robustly parse ints even if Firestore stored strings
        moisture = int.tryParse("${data['moistureSensors'] ?? 0}") ?? 0;
        ph = int.tryParse("${data['phSensors'] ?? 0}") ?? 0;
        npk = int.tryParse("${data['npkSensors'] ?? 0}") ?? 0;

        moistureCtrl.text = moisture.toString();
        phCtrl.text = ph.toString();
        npkCtrl.text = npk.toString();
      } else {
        // defaults remain 0
      }
    } catch (e) {
      debugPrint("🔥 Error loading config: $e");
    }

    if (mounted) setState(() => loading = false);
  }

  Future<void> saveConfig() async {
    try {
      await _firestore.collection("farm_config").doc(widget.siteId).set({
        "moistureSensors": moisture,
        "phSensors": ph,
        "npkSensors": npk,
        "updatedAt": DateTime.now(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Saved successfully")),
        );
      }
    } catch (e) {
      debugPrint("🔥 Save error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.siteName)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.siteName)),
body: Padding(
  padding: const EdgeInsets.all(16),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // ---------------- LEFT PANEL (GRAPHS) ----------------
      Expanded(
        flex: 3,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                "Sensor Graphs",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              sensorCard("Moisture Sensors", moisture, "moisture"),
              sensorCard("pH Sensors", ph, "ph"),
              sensorCard("NPK Sensors", npk, "npk"),
            ],
          ),
        ),
      ),

      const SizedBox(width: 20),

      // ---------------- RIGHT PANEL (SETTINGS) ----------------
      Container(
        width: 260,    // small fixed box
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Sensor Configuration",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            numberField("Moisture Sensors", moistureCtrl),
            numberField("pH Sensors", phCtrl),
            numberField("NPK Sensors", npkCtrl),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    moisture = int.tryParse(moistureCtrl.text) ?? 0;
                    ph = int.tryParse(phCtrl.text) ?? 0;
                    npk = int.tryParse(npkCtrl.text) ?? 0;
                  });
                  saveConfig();
                },
                child: const Text("Save"),
              ),
            )
          ],
        ),
      ),
    ],
  ),
),

    );
  }

  Widget numberField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

Widget sensorCard(String title, int count, String type) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- TITLE ROW ----------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SensorGraphPage(
                        siteId: widget.siteId,
                        sensorType: type,
                        sensorCount: count,   // full combined graph
                      ),
                    ),
                  );
                },
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                "$count sensors",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ---------- COMBINED GRAPH ----------
          if (count > 0)
            GraphWidget(
              siteId: widget.siteId,
              sensorType: type,
              sensorId: 0,            // COMBINED graph
              totalSensors: count,    // required for combined
            )
          else
            const Text("No sensors configured"),

          const SizedBox(height: 12),

          // ---------- SENSOR BUTTONS ----------
          if (count > 0)
            Wrap(
              spacing: 10,
              children: [
                for (int i = 1; i <= count; i++)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SensorGraphPage(
                            siteId: widget.siteId,
                            sensorType: type,
                            sensorCount: i,    // FIXED HERE
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.show_chart, size: 16),
                    label: Text("Sensor $i"),
                  ),
              ],
            ),
        ],
      ),
    ),
  );
}

}



