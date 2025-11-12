import 'package:dio/dio.dart';
import 'package:dio/io.dart';

Dio createDio() {
  final dio = Dio();
  dio.httpClientAdapter = IOHttpClientAdapter();
  return dio;
}
