import 'dart:io';
import 'package:flutter/services.dart'; // Penting buat akses assets
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _coreDb;

  DatabaseHelper._init();

  // 1. Akses Core Database
  Future<Database> get database async {
    if (_coreDb != null) return _coreDb!;
    _coreDb = await _initCoreDB();
    return _coreDb!;
  }

  // 2. Logic Copy dari Assets (Hanya jalan sekali seumur hidup install)
  Future<Database> _initCoreDB() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'core.db');

    // Cek: Apakah file DB udah ada di HP user?
    if (!await File(path).exists()) {
      print("Core DB belum ada. Meng-copy dari assets...");

      try {
        // Ambil file dari folder assets project
        ByteData data = await rootBundle.load("assets/database/core.db");
        List<int> bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );

        // Tulis ke memori HP
        await File(path).writeAsBytes(bytes);
        print("Sukses copy Core DB!");
      } catch (e) {
        print("Error copy database: $e");
      }
    } else {
      print("Core DB sudah ada. Membuka...");
    }

    return await openDatabase(path, version: 1);
  }

  // 3. Logic Attach Module (Sama kayak sebelumnya)
  Future<void> attachNikayaModule() async {
    final db = await database; // Pastikan core db kebuka dulu
    final dir = await getApplicationDocumentsDirectory();
    final modulePath = join(dir.path, 'module', '4nikaya.db');

    if (await File(modulePath).exists()) {
      try {
        // Cek dulu apakah udah ter-attach biar gak error
        final check = await db.rawQuery("PRAGMA database_list;");
        final isAttached = check.any((row) => row['name'] == 'nikaya_db');

        if (!isAttached) {
          await db.rawQuery("ATTACH DATABASE ? AS nikaya_db", [modulePath]);
          print("Berhasil attach 4nikaya.db!");
        }
      } catch (e) {
        print("Gagal attach: $e");
      }
    }
  }

  // 4. Contoh Query Gabungan (Cross-Database)
  // Misal: Cari Sutta di Core, ambil isi text di Module
  Future<List<Map<String, dynamic>>> testGabungan() async {
    final db = await database;
    await attachNikayaModule();

    // Pastikan nama tabel kamu bener.
    // Contoh: Tabel 'suttas' ada di core.db, Tabel 'pages' ada di 4nikaya.db
    // Query ini cuma contoh, sesuaikan dengan nama tabel aslimu
    try {
      return await db.rawQuery('''
        SELECT * FROM nikaya_db.pages LIMIT 3
      ''');
    } catch (e) {
      print("Error query gabungan: $e");
      return [];
    }
  }
}
