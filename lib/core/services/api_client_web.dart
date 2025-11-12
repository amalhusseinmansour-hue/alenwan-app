import 'package:dio/dio.dart';
import 'package:dio/browser.dart';

Dio createDio() {
  final dio = Dio();
  dio.httpClientAdapter = BrowserHttpClientAdapter();
  return dio;
}
