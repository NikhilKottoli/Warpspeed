import 'package:flutter/material.dart';

class MyAssetsPage extends StatelessWidget {
  final List<Map<String, dynamic>> myAssets = [
    {
      "name": "Seeder Machine",
      "description": "Precision seeder for crop planting.",
      "earnings": 8.0,
      "image": "assets/images/seeder.jpg",
      "status": "Currently Borrowed",
    },
    {
      "name": "Sprayer",
      "description": "Pesticide sprayer with automated coverage.",
      "earnings": 6.0,
      "image": "assets/images/sprayer.jpg",
      "status": "Available",
    },
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
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
          itemCount: myAssets.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  "📦 My Assets",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              );
            }

            final asset = myAssets[index - 1];
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(bottom: 20),
              color: Colors.white.withOpacity(0.1),
              elevation: 4,
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
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      asset["description"],
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Earnings: ${asset['earnings']} FARM/day",
                      style: const TextStyle(color: Colors.greenAccent),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Status: ${asset['status']}",
                      style: TextStyle(
                        color: asset['status'] == "Available" ? Colors.lightGreenAccent : Colors.orangeAccent,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
