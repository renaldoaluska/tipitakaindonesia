import 'dart:io';
import 'package:dio/dio.dart';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class DownloaderService {
  final Dio _dio = Dio();

  // Fungsi sakti buat download modul
  Future<bool> downloadModule({
    required String url,
    required String fileName, // misal: '4nikaya.db'
    required Function(double) onProgress,
  }) async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();

      // 1. Tentukan Path Folder 'module'
      final moduleDir = Directory(p.join(docsDir.path, 'module'));

      // 2. WAJIB: Cek & Bikin Folder kalau belum ada
      if (!await moduleDir.exists()) {
        await moduleDir.create(recursive: true);
        print("Folder 'module' berhasil dibuat.");
      }

      final zipPath = p.join(moduleDir.path, "temp_download.zip");
      final targetDbPath = p.join(moduleDir.path, fileName);

      print("Mulai download dari $url ke $zipPath");

      // 3. Download File ZIP
      await _dio.download(
        url,
        zipPath,
        onReceiveProgress: (rec, total) {
          if (total != -1) {
            onProgress(rec / total);
          }
        },
      );

      // 4. Extract ZIP (Versi Universal - Kompatibel Semua Versi)
      print("Sedang mengekstrak...");
      // Kita baca file zip langsung sebagai bytes (aman untuk file 50MB)
      final bytes = await File(zipPath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      for (var file in archive) {
        // Kita cuma ambil file .db nya aja
        if (file.name.endsWith('.db')) {
          // Kalau file db ketemu, tulis ke folder tujuan
          final data = file.content as List<int>;
          await File(targetDbPath).writeAsBytes(data);
        }
      }

      // 5. Bersih-bersih sampah ZIP
      await File(zipPath).delete();
      print("Selesai! File tersimpan di: $targetDbPath");
      return true;
    } catch (e) {
      print("Error Download: $e");
      return false;
    }
  }
}
