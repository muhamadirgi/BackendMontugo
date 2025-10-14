
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const Montugo());
}

class Montugo extends StatelessWidget {
  const Montugo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Backend Montugo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
