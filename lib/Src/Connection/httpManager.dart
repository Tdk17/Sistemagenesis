import 'package:dio/dio.dart';
import 'package:sistema_genesis/Src/Config/appConfig.dart';

class HttpManager {
  HttpManager(this._dio);

  final Dio _dio;

  Map<String, String> get _parseHeaders => {
    if (AppConfig.parseApplicationId.isNotEmpty)
      'X-Parse-Application-Id': AppConfig.parseApplicationId,
    if (AppConfig.parseJavaScriptKey.isNotEmpty)
      'X-Parse-JavaScript-Key': AppConfig.parseJavaScriptKey,
    'Content-Type': 'application/json',
  };

  Future<Map<String, dynamic>> post(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String> headers = const {},
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: body,
      options: Options(headers: {..._parseHeaders, ...headers}),
    );
    return response.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
    Map<String, String> headers = const {},
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: query,
      options: Options(headers: {..._parseHeaders, ...headers}),
    );
    return response.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> put(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String> headers = const {},
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      path,
      data: body,
      options: Options(headers: {..._parseHeaders, ...headers}),
    );
    return response.data ?? <String, dynamic>{};
  }

  Future<void> delete(
    String path, {
    Map<String, String> headers = const {},
  }) async {
    await _dio.delete<void>(
      path,
      options: Options(headers: {..._parseHeaders, ...headers}),
    );
  }
}
