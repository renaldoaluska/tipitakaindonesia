import 'package:dio/dio.dart';

class Api {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://suttacentral.net/api/",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  /// GET request, return JSON
  static Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final response = await _dio.get(path, queryParameters: query);
      return response.data;
    } catch (e) {
      throw Exception("API error: $e");
    }
  }
}
