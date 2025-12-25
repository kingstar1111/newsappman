import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

void main() async {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://newsapi.org/v2',
      responseType: ResponseType.json,
    ),
  );

  final apiKey = '14dc2aa002c84293bcadd6667f53e970';

  debugPrint('--- Testing Saudi Arabia (ar) ---');
  try {
    final responseSA = await dio.get(
      '/top-headlines',
      queryParameters: {
        'category': 'general',
        'country': 'sa',
        'apiKey': apiKey,
      },
    );
    debugPrint('SA Status: ${responseSA.statusCode}');
    debugPrint('SA Articles: ${(responseSA.data['articles'] as List).length}');
  } catch (e) {
    debugPrint('SA Error: $e');
  }

  debugPrint('\n--- Testing Turkey (tr) ---');
  try {
    final responseTR = await dio.get(
      '/top-headlines',
      queryParameters: {
        'category': 'general',
        'country': 'tr',
        'apiKey': apiKey,
      },
    );
    debugPrint('TR Status: ${responseTR.statusCode}');
    debugPrint('TR Articles: ${(responseTR.data['articles'] as List).length}');
  } catch (e) {
    debugPrint('TR Error: $e');
  }
}
