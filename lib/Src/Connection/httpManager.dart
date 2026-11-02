import 'package:dio/dio.dart';

class HttpManager {
  HttpManager(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> post(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String> headers = const {},
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: body,
      options: Options(headers: headers),
    );
    return response.data ?? <String, dynamic>{};
  }
}
