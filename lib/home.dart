import 'package:flutter/material.dart';
import 'package:myapp/LIST/list_gunung.dart';
import 'package:myapp/LIST/list_barang.dart';
import 'package:myapp/LIST/list_berita.dart';
import 'package:myapp/LIST/list_katalog.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backend Service MONTUGO')),
      body: GridView.count(
        crossAxisCount: 2,
        children: <Widget>[
          _buildCard(context, 'Berita', Icons.article, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ListBerita()),
            );
          }),
          _buildCard(context, 'Gunung', Icons.landscape, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ListGunung()),
            );
          }),
          _buildCard(context, 'Barang', Icons.bookmark_add_rounded, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ListBarang()),
            );
          }),
          _buildCard(context, 'Katalog', Icons.shopping_bag_rounded, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ListKatalog()), 
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 70.0),
              Text(title, style: const TextStyle(fontSize: 17.0)),
            ],
          ),
        ),
      ),
    );
  }
}
