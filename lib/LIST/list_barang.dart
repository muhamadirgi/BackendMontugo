import 'package:flutter/material.dart';

class ListBarang extends StatelessWidget {
  const ListBarang({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("List Barang"),),
      body: IsiBarang(),
    );
  }
}

class IsiBarang extends StatefulWidget {
  const IsiBarang({super.key});

  @override
  State<IsiBarang> createState() => _IsiBarangState();
}

class _IsiBarangState extends State<IsiBarang> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}