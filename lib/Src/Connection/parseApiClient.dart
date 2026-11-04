import 'package:sistema_genesis/Src/Connection/httpManager.dart';

class ParseApiClient {
  const ParseApiClient(this._http);

  final HttpManager _http;

  Map<String, String> _sessionHeaders(String token) =>
      token.isEmpty ? const {} : {'X-Parse-Session-Token': token};

  Future<Map<String, dynamic>> logIn({
    required String username,
    required String password,
  }) {
    return _http.get(
      '/login',
      query: {'username': username.trim().toLowerCase(), 'password': password},
    );
  }

  Future<void> logOut(String sessionToken) async {
    await _http.post(
      '/logout',
      body: const {},
      headers: _sessionHeaders(sessionToken),
    );
  }

  Future<List<Map<String, dynamic>>> listObjects(
    String className,
    String sessionToken,
  ) async {
    final data = await _http.get(
      '/classes/$className',
      query: {'limit': 1000, 'order': '-updatedAt'},
      headers: _sessionHeaders(sessionToken),
    );
    final results = data['results'];
    if (results is! List) return const [];
    return results
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<String> createObject(
    String className,
    Map<String, dynamic> body,
    String sessionToken,
  ) async {
    final data = await _http.post(
      '/classes/$className',
      body: body,
      headers: _sessionHeaders(sessionToken),
    );
    return data['objectId']?.toString() ?? '';
  }

  Future<void> updateObject(
    String className,
    String objectId,
    Map<String, dynamic> body,
    String sessionToken,
  ) async {
    await _http.put(
      '/classes/$className/$objectId',
      body: body,
      headers: _sessionHeaders(sessionToken),
    );
  }

  Future<void> deleteObject(
    String className,
    String objectId,
    String sessionToken,
  ) {
    return _http.delete(
      '/classes/$className/$objectId',
      headers: _sessionHeaders(sessionToken),
    );
  }
}
