import 'package:flutter/material.dart';
import 'screens/home.dart'; // Ini penting biar dia kenal file home_screen.dart

void main() async {
  // Memastikan binding flutter siap sebelum jalanin app
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tripitaka Indonesia',
      //ilangin banner 'Debug' di pojok kanan atas biar bersih
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Kita pake warna tema Oranye (khas jubah bhikkhu/Tipitaka)
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      // Langsung buka halaman Home (tempat kita bikin tombol download tadi)
      home: const HomeScreen(),
    );
  }
}
