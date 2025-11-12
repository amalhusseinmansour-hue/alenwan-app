import 'package:dio/dio.dart';
import 'api_client.dart';
import 'package:alenwan/models/section_model.dart';

class HomeSectionsService {
  final Dio _dio = ApiClient().dio;

  Future<List<SectionModel>> fetchAll({int limit = 12}) async {
    final res =
        await _dio.get('/home-sections', queryParameters: {'limit': limit});
    final List sections = (res.data['sections'] ?? []) as List;
    return sections
        .map((e) => SectionModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
