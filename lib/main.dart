import 'package:flutter/material.dart';
import 'screens/home.dart';

void main() {
  runApp(const TripitakaApp());
}

class TripitakaApp extends StatelessWidget {
  const TripitakaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tripitaka Indonesia',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}
