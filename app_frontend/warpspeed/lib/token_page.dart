import 'package:flutter/material.dart';

class TokenShopPage extends StatelessWidget {
  final List<Map<String, dynamic>> products = [
    {
      "name": "Organic Compost",
      "price": 50.0,
      "stock": 100,
    },
    {
      "name": "NPK Fertilizer",
      "price": 75.0,
      "stock": 50,
    },
    {
      "name": "Bio Fertilizer",
      "price": 100.0,
      "stock": 25,
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "🛒 Token Shop",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Use your FARM tokens to purchase fertilizers!",
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    itemCount: products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemBuilder: (context, index) {
                      final item = products[index];
                      final price = item["price"] as double;

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item["name"],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text("💰 Price: $price FARM", style: const TextStyle(color: Colors.white70)),
                            Text("📦 Stock: ${item["stock"]}", style: const TextStyle(color: Colors.white70)),
                            const SizedBox(height: 8),
                            TextField(
                              decoration: InputDecoration(
                                hintText: "Qty",
                                hintStyle: const TextStyle(color: Colors.white54),
                                filled: true,
                                fillColor: Colors.white10,
                                contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.number,
                            ),
                            const Spacer(),
                            Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.greenAccent,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                ),
                                onPressed: () {
                                  // Handle purchase
                                },
                                child: const Text("Purchase"),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
