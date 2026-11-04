import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:sistema_genesis/Src/Config/appConfig.dart';
import 'package:sistema_genesis/Src/Connection/parseApiClient.dart';
import 'package:sistema_genesis/Src/Models/genesisModels.dart';
import 'package:sistema_genesis/Src/Services/authController.dart';
import 'package:sistema_genesis/Src/Services/localDatabase.dart';

class GenesisController extends ChangeNotifier {
  GenesisController(this._database, this._api, this._auth);

  static const clientsClass = 'GenesisClient';
  static const projectsClass = 'GenesisProject';
  static const agendaClass = 'GenesisAgenda';
  static const financeClass = 'GenesisFinance';

  final LocalDatabase _database;
  final ParseApiClient _api;
  final AuthController _auth;

  final List<Client> _clients = [];
  final List<Project> _projects = [];
  final List<AgendaEntry> _agenda = [];
  final List<FinanceEntry> _finance = [];
  final List<Map<String, dynamic>> _pendingDeletes = [];

  bool _isLoading = true;
  bool _isSyncing = false;
  DateTime? _lastSync;
  String _syncMessage = 'Dados salvos neste dispositivo';

  List<Client> get clients => List.unmodifiable(_clients);
  List<Project> get projects => List.unmodifiable(_projects);
  List<AgendaEntry> get agenda => List.unmodifiable(_agenda);
  List<FinanceEntry> get finance => List.unmodifiable(_finance);
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSync => _lastSync;
  String get syncMessage => _syncMessage;

  int get pendingSyncCount =>
      _clients.where((item) => item.pendingSync).length +
      _projects.where((item) => item.pendingSync).length +
      _agenda.where((item) => item.pendingSync).length +
      _finance.where((item) => item.pendingSync).length +
      _pendingDeletes.length;

  double get totalIncome => _finance
      .where(
        (entry) =>
            entry.type == FinanceType.income &&
            entry.status == PaymentStatus.paid,
      )
      .fold(0, (total, entry) => total + entry.amount);

  double get totalExpenses => _finance
      .where(
        (entry) =>
            entry.type == FinanceType.expense &&
            entry.status == PaymentStatus.paid,
      )
      .fold(0, (total, entry) => total + entry.amount);

  double get receivable => _finance
      .where(
        (entry) =>
            entry.type == FinanceType.income &&
            entry.status == PaymentStatus.pending,
      )
      .fold(0, (total, entry) => total + entry.amount);

  Future<void> initialize() async {
    _clients
      ..clear()
      ..addAll(
        (await _database.readList(LocalDatabase.clientsKey))
            .map(Client.fromJson),
      );
    _projects
      ..clear()
      ..addAll(
        (await _database.readList(LocalDatabase.projectsKey))
            .map(Project.fromJson),
      );
    _agenda
      ..clear()
      ..addAll(
        (await _database.readList(LocalDatabase.agendaKey))
            .map(AgendaEntry.fromJson),
      );
    _finance
      ..clear()
      ..addAll(
        (await _database.readList(LocalDatabase.financeKey))
            .map(FinanceEntry.fromJson),
      );
    _pendingDeletes
      ..clear()
      ..addAll(await _database.readList(LocalDatabase.pendingDeletesKey));
    _sortAll();
    _isLoading = false;
    notifyListeners();
  }

  String createId(String prefix) {
    final random = Random().nextInt(999999).toString().padLeft(6, '0');
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}-$random';
  }

  Client? clientById(String id) {
    for (final client in _clients) {
      if (client.id == id) return client;
    }
    return null;
  }

  Project? projectById(String id) {
    for (final project in _projects) {
      if (project.id == id) return project;
    }
    return null;
  }

  void saveClient(Client client) {
    final index = _clients.indexWhere((item) => item.id == client.id);
    final value = client.copyWith(updatedAt: DateTime.now(), pendingSync: true);
    if (index < 0) {
      _clients.add(value);
    } else {
      _clients[index] = value;
    }
    _sortAll();
    _changed();
  }

  void deleteClient(Client client) {
    _clients.removeWhere((item) => item.id == client.id);
    if (client.remoteId != null) {
      _queueDelete(clientsClass, client.remoteId!);
    }
    _changed();
  }

  void saveProject(Project project) {
    final index = _projects.indexWhere((item) => item.id == project.id);
    final value = project.copyWith(
      updatedAt: DateTime.now(),
      pendingSync: true,
    );
    if (index < 0) {
      _projects.add(value);
    } else {
      _projects[index] = value;
    }
    _sortAll();
    _changed();
  }

  void moveProject(String projectId, ProjectStage stage) {
    final index = _projects.indexWhere((item) => item.id == projectId);
    if (index < 0 || _projects[index].stage == stage) return;
    _projects[index] = _projects[index].copyWith(
      stage: stage,
      updatedAt: DateTime.now(),
      pendingSync: true,
    );
    _changed();
  }

  void deleteProject(Project project) {
    _projects.removeWhere((item) => item.id == project.id);
    if (project.remoteId != null) {
      _queueDelete(projectsClass, project.remoteId!);
    }
    _changed();
  }

  void saveAgendaEntry(AgendaEntry entry) {
    final index = _agenda.indexWhere((item) => item.id == entry.id);
    final value = entry.copyWith(updatedAt: DateTime.now(), pendingSync: true);
    if (index < 0) {
      _agenda.add(value);
    } else {
      _agenda[index] = value;
    }
    _sortAll();
    _changed();
  }

  void toggleAgendaEntry(AgendaEntry entry) {
    saveAgendaEntry(entry.copyWith(done: !entry.done));
  }

  void deleteAgendaEntry(AgendaEntry entry) {
    _agenda.removeWhere((item) => item.id == entry.id);
    if (entry.remoteId != null) {
      _queueDelete(agendaClass, entry.remoteId!);
    }
    _changed();
  }

  void saveFinanceEntry(FinanceEntry entry) {
    final index = _finance.indexWhere((item) => item.id == entry.id);
    final value = entry.copyWith(updatedAt: DateTime.now(), pendingSync: true);
    if (index < 0) {
      _finance.add(value);
    } else {
      _finance[index] = value;
    }
    _sortAll();
    _changed();
  }

  void deleteFinanceEntry(FinanceEntry entry) {
    _finance.removeWhere((item) => item.id == entry.id);
    if (entry.remoteId != null) {
      _queueDelete(financeClass, entry.remoteId!);
    }
    _changed();
  }

  Future<bool> syncAll() async {
    if (!AppConfig.isBack4AppConfigured) {
      _syncMessage = 'Modo local — Back4App ainda não configurado';
      notifyListeners();
      return false;
    }
    if (!_auth.isAuthenticated || _auth.sessionToken.isEmpty) {
      _syncMessage = 'Entre novamente para sincronizar';
      notifyListeners();
      return false;
    }

    _isSyncing = true;
    _syncMessage = 'Sincronizando…';
    notifyListeners();

    try {
      await _syncDeletes();
      await _pushClients();
      await _pushProjects();
      await _pushAgenda();
      await _pushFinance();
      await _pullRemote();
      await _persist();
      _lastSync = DateTime.now();
      _syncMessage = 'Tudo sincronizado';
      return true;
    } catch (_) {
      _syncMessage = 'Falha na sincronização — dados locais preservados';
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  void _queueDelete(String className, String objectId) {
    _pendingDeletes.add({'className': className, 'objectId': objectId});
  }

  void _changed() {
    _syncMessage = AppConfig.isBack4AppConfigured
        ? '$pendingSyncCount alterações aguardando sincronização'
        : 'Dados salvos neste dispositivo';
    notifyListeners();
    unawaited(_persist());
  }

  Future<void> _persist() async {
    await Future.wait([
      _database.writeList(
        LocalDatabase.clientsKey,
        _clients.map((item) => item.toJson()).toList(),
      ),
      _database.writeList(
        LocalDatabase.projectsKey,
        _projects.map((item) => item.toJson()).toList(),
      ),
      _database.writeList(
        LocalDatabase.agendaKey,
        _agenda.map((item) => item.toJson()).toList(),
      ),
      _database.writeList(
        LocalDatabase.financeKey,
        _finance.map((item) => item.toJson()).toList(),
      ),
      _database.writeList(LocalDatabase.pendingDeletesKey, _pendingDeletes),
    ]);
  }

  Future<void> _syncDeletes() async {
    final completed = <Map<String, dynamic>>[];
    for (final item in _pendingDeletes) {
      final className = item['className']?.toString() ?? '';
      final objectId = item['objectId']?.toString() ?? '';
      if (className.isEmpty || objectId.isEmpty) continue;
      await _api.deleteObject(className, objectId, _auth.sessionToken);
      completed.add(item);
    }
    _pendingDeletes.removeWhere(completed.contains);
  }

  Map<String, dynamic> _secured(Map<String, dynamic> data) {
    if (_auth.userId.isEmpty) return data;
    return {
      ...data,
      'ACL': {
        _auth.userId: {'read': true, 'write': true},
      },
    };
  }

  Future<void> _pushClients() async {
    for (var index = 0; index < _clients.length; index++) {
      final item = _clients[index];
      if (!item.pendingSync) continue;
      if (item.remoteId == null) {
        final id = await _api.createObject(
          clientsClass,
          _secured(item.toRemote()),
          _auth.sessionToken,
        );
        _clients[index] = item.copyWith(remoteId: id, pendingSync: false);
      } else {
        await _api.updateObject(
          clientsClass,
          item.remoteId!,
          item.toRemote(),
          _auth.sessionToken,
        );
        _clients[index] = item.copyWith(pendingSync: false);
      }
    }
  }

  Future<void> _pushProjects() async {
    for (var index = 0; index < _projects.length; index++) {
      final item = _projects[index];
      if (!item.pendingSync) continue;
      if (item.remoteId == null) {
        final id = await _api.createObject(
          projectsClass,
          _secured(item.toRemote()),
          _auth.sessionToken,
        );
        _projects[index] = item.copyWith(remoteId: id, pendingSync: false);
      } else {
        await _api.updateObject(
          projectsClass,
          item.remoteId!,
          item.toRemote(),
          _auth.sessionToken,
        );
        _projects[index] = item.copyWith(pendingSync: false);
      }
    }
  }

  Future<void> _pushAgenda() async {
    for (var index = 0; index < _agenda.length; index++) {
      final item = _agenda[index];
      if (!item.pendingSync) continue;
      if (item.remoteId == null) {
        final id = await _api.createObject(
          agendaClass,
          _secured(item.toRemote()),
          _auth.sessionToken,
        );
        _agenda[index] = item.copyWith(remoteId: id, pendingSync: false);
      } else {
        await _api.updateObject(
          agendaClass,
          item.remoteId!,
          item.toRemote(),
          _auth.sessionToken,
        );
        _agenda[index] = item.copyWith(pendingSync: false);
      }
    }
  }

  Future<void> _pushFinance() async {
    for (var index = 0; index < _finance.length; index++) {
      final item = _finance[index];
      if (!item.pendingSync) continue;
      if (item.remoteId == null) {
        final id = await _api.createObject(
          financeClass,
          _secured(item.toRemote()),
          _auth.sessionToken,
        );
        _finance[index] = item.copyWith(remoteId: id, pendingSync: false);
      } else {
        await _api.updateObject(
          financeClass,
          item.remoteId!,
          item.toRemote(),
          _auth.sessionToken,
        );
        _finance[index] = item.copyWith(pendingSync: false);
      }
    }
  }

  Future<void> _pullRemote() async {
    final results = await Future.wait([
      _api.listObjects(clientsClass, _auth.sessionToken),
      _api.listObjects(projectsClass, _auth.sessionToken),
      _api.listObjects(agendaClass, _auth.sessionToken),
      _api.listObjects(financeClass, _auth.sessionToken),
    ]);

    final remoteClients = results[0].map(Client.fromJson).toList();
    final remoteProjects = results[1].map(Project.fromJson).toList();
    final remoteAgenda = results[2].map(AgendaEntry.fromJson).toList();
    final remoteFinance = results[3].map(FinanceEntry.fromJson).toList();

    final localClients = List<Client>.of(_clients);
    final localProjects = List<Project>.of(_projects);
    final localAgenda = List<AgendaEntry>.of(_agenda);
    final localFinance = List<FinanceEntry>.of(_finance);

    _clients
      ..clear()
      ..addAll(
        _merge(
          localClients,
          remoteClients,
          (item) => item.id,
          (item) => item.pendingSync,
        ),
      );
    _projects
      ..clear()
      ..addAll(
        _merge(
          localProjects,
          remoteProjects,
          (item) => item.id,
          (item) => item.pendingSync,
        ),
      );
    _agenda
      ..clear()
      ..addAll(
        _merge(
          localAgenda,
          remoteAgenda,
          (item) => item.id,
          (item) => item.pendingSync,
        ),
      );
    _finance
      ..clear()
      ..addAll(
        _merge(
          localFinance,
          remoteFinance,
          (item) => item.id,
          (item) => item.pendingSync,
        ),
      );
    _sortAll();
  }

  List<T> _merge<T>(
    List<T> local,
    List<T> remote,
    String Function(T) id,
    bool Function(T) pending,
  ) {
    final merged = <String, T>{for (final item in local) id(item): item};
    for (final remoteItem in remote) {
      final current = merged[id(remoteItem)];
      if (current == null || !pending(current)) {
        merged[id(remoteItem)] = remoteItem;
      }
    }
    return merged.values.toList();
  }

  void _sortAll() {
    _clients.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    _projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _agenda.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    _finance.sort((a, b) => b.dueDate.compareTo(a.dueDate));
  }
}
