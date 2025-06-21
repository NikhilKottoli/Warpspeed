import 'package:flutter/material.dart';

class Asset {
  final String name;
  final String description;
  final String imagePath;
  final double earnings;

  Asset({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.earnings,
  });
}

class AssetPage extends StatelessWidget {
  final List<Asset> assets = [
    Asset(
      name: 'Tractor',
      description: 'High power tractor suitable for all terrains.',
      imagePath: 'assets/images/tractor.jpg', // replace with asset path
      earnings: 15.0,
    ),
    Asset(
      name: 'Plough',
      description: 'Durable plough, perfect for soil preparation.',
      imagePath: 'assets/images/plough.jpg',
      earnings: 8.0,
    ),
    Asset(
      name: 'Water Pump',
      description: 'Efficient pump for irrigation systems.',
      imagePath: 'assets/images/pump.jpg',
      earnings: 6.5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Assets')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: assets.length,
          itemBuilder: (context, index) {
            final asset = assets[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        asset.imagePath,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(asset.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(asset.description,
                        style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 6),
                    Text("Earns: ${asset.earnings} FARM/day",
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        SizedBox(
                          width: 60,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "1",
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Borrow for 1 day'),
                        ),
                      ],
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
