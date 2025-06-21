import 'package:flutter/material.dart';
import 'browse_page.dart';
import 'token_page.dart';
import 'list_page.dart';
import 'my_assets.dart';

class HomeTabView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // ⬅️ Increase tab count
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "🌾 Krishi Assets",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Farm: 100000',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            )
          ],
          elevation: 0,
          backgroundColor: Colors.transparent,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.agriculture), text: "Browse"),
              Tab(icon: Icon(Icons.store), text: "Shop"),
              Tab(icon: Icon(Icons.add_box), text: "List Asset"),
              Tab(icon: Icon(Icons.inventory), text: "My Assets"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BrowseAssetsPage(),
            TokenShopPage(),
            ListAssetPage(),
            MyAssetsPage(),
          ],
        ),
      ),
    );
  }
}
