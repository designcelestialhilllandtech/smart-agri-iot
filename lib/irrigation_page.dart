import 'package:flutter/material.dart';

class IrrigationPage extends StatefulWidget {
  const IrrigationPage({super.key});

  @override
  State<IrrigationPage> createState() => _IrrigationPageState();
}

class _IrrigationPageState extends State<IrrigationPage> {
  bool isTankOn = true;
  bool isDripOn = false;
  bool isAutoOn = false;
  String selectedSite = "SITE-1";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Center(
                      child: Text(
                        "DRIP IRRIGATION",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.green.shade300,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedSite,
                        dropdownColor: Colors.white,
                        items: ["SITE-1", "SITE-2", "SITE-3", "SITE-4"]
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => selectedSite = v!),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // --- MAIN CONTENT ---
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Tank Filling ---
                    _buildControlCard(
                      title: "TANK FILLING",
                      imagePath: "assets/tank.png",
                      statusText: "75%",
                      switchValue: isTankOn,
                      onChanged: (val) => setState(() => isTankOn = val),
                    ),

                    // --- Drip Irrigation ---
                    _buildControlCard(
                      title: "DRIP IRRIGATION",
                      imagePath: "assets/drip_irrigation.png",
                      switchValue: isDripOn,
                      onChanged: (val) => setState(() => isDripOn = val),
                    ),

                    // --- Automation Mode ---
                    _buildControlCard(
                      title: "AUTOMATION MODE",
                      imagePath: "assets/automation.png",
                      switchValue: isAutoOn,
                      onChanged: (val) => setState(() => isAutoOn = val),
                    ),
                  ],
                ),
              ),
            ),

            // --- IRRIGATION HISTORY SECTION ---
            Container(
              width: double.infinity,
              color: const Color(0xFF0D3A5C),
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              child: const Text(
                "IRRIGATION HISTORY",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                color: const Color(0xFF0D3A5C),
              ),
            ),

            // --- HOME BUTTON ---
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 55,
                    width: 55,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      image: DecorationImage(
                        image: AssetImage("assets/home.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlCard({
    required String title,
    required String imagePath,
    bool? switchValue,
    required Function(bool) onChanged,
    String? statusText,
  }) {
    return Expanded(
      child: Column(
        children: [
          // --- Title ---
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // --- Image / Gauge ---
          if (statusText != null)
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(imagePath, height: 120, fit: BoxFit.contain),
                Positioned(
                  right: 10,
                  child: Container(
                    width: 40,
                    height: 100,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            )
          else
            Image.asset(imagePath, height: 120, fit: BoxFit.cover),

          const SizedBox(height: 10),

          // --- Switch ---
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _customSwitch(switchValue!, onChanged),
              const SizedBox(width: 6),
              Text(
                switchValue ? "ON" : "OFF",
                style: TextStyle(
                  color: switchValue ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),
          const Text(
            "MANUAL MODE",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _customSwitch(bool value, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? Colors.green : Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 25,
          height: 25,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
