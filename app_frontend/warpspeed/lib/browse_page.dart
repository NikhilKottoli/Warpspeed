import 'package:flutter/material.dart';

class BrowseAssetsPage extends StatelessWidget {
  final List<Map<String, dynamic>> assets = [
    {
      "name": "Tractor",
      "description": "Powerful tractor with advanced torque system.",
      "earnings": 10.0,
      "image": "assets/images/tractor.jpg"
    },
    {
      "name": "Plough",
      "description": "Heavy-duty plough for field preparation.",
      "earnings": 7.5,
      "image": "assets/images/plough.jpg"
    },
    {
      "name": "Water Pump",
      "description": "High-pressure irrigation pump.",
      "earnings": 5.0,
      "image": "assets/images/pump.jpg"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              children: [
                const SizedBox(height: 20),
                const Text(
                  "🔍 Browse Assets",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                ...assets.map((asset) => _buildAssetCard(asset)).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssetCard(Map<String, dynamic> asset) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 20),
      color: Colors.white.withOpacity(0.1),
      elevation: 6,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                asset["image"],
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              asset["name"],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              asset["description"],
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              "Earns: ${asset['earnings']} FARM/day",
              style: const TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 60,
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white12,
                      hintText: "1",
                      hintStyle: const TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onPressed: () {
                    // Borrow logic
                  },
                  child: const Text("Borrow for 1 day"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
