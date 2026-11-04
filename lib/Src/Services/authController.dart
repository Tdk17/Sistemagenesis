import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sistema_genesis/Src/Config/appConfig.dart';
import 'package:sistema_genesis/Src/Connection/parseApiClient.dart';
import 'package:sistema_genesis/Src/Services/localDatabase.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._api, this._database);

  final ParseApiClient _api;
  final LocalDatabase _database;

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String _sessionToken = '';
  String _userId = '';
  String? _error;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String get sessionToken => _sessionToken;
  String get userId => _userId;
  String? get error => _error;

  Future<void> initialize() async {
    if (AppConfig.isBack4AppConfigured) {
      _sessionToken = await _database.readString(LocalDatabase.sessionTokenKey);
      _userId = await _database.readString(LocalDatabase.userIdKey);
      _isAuthenticated = _sessionToken.isNotEmpty;
    } else {
      _isAuthenticated = await _database.readBool(
        LocalDatabase.localSessionKey,
      );
    }
    notifyListeners();
  }

  Future<bool> logIn({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (AppConfig.isBack4AppConfigured) {
        final response = await _api.logIn(username: email, password: password);
        final token = response['sessionToken']?.toString() ?? '';
        final userId = response['objectId']?.toString() ?? '';
        if (token.isEmpty) {
          throw const FormatException(
            'Sessão inválida retornada pelo servidor.',
          );
        }
        _sessionToken = token;
        _userId = userId;
        await _database.writeString(LocalDatabase.sessionTokenKey, token);
        await _database.writeString(LocalDatabase.userIdKey, userId);
      } else {
        final validEmail =
            email.trim().toLowerCase() ==
            AppConfig.localAdminEmail.toLowerCase();
        final validPassword = password == AppConfig.localAdminPassword;
        if (!validEmail || !validPassword) {
          _error = 'E-mail ou senha incorretos.';
          return false;
        }
        await _database.writeBool(LocalDatabase.localSessionKey, true);
      }

      _isAuthenticated = true;
      return true;
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['error'] != null) {
        _error = data['error'].toString();
      } else {
        _error = 'Não foi possível conectar ao Back4App.';
      }
      return false;
    } catch (error) {
      _error = error is FormatException
          ? error.message
          : 'Não foi possível entrar. Tente novamente.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logOut() async {
    final token = _sessionToken;
    _isAuthenticated = false;
    _sessionToken = '';
    _userId = '';
    await _database.remove(LocalDatabase.localSessionKey);
    await _database.remove(LocalDatabase.sessionTokenKey);
    await _database.remove(LocalDatabase.userIdKey);
    notifyListeners();

    if (AppConfig.isBack4AppConfigured && token.isNotEmpty) {
      try {
        await _api.logOut(token);
      } catch (_) {
        // A sessão local já foi encerrada. Falha remota não bloqueia a saída.
      }
    }
  }
}
