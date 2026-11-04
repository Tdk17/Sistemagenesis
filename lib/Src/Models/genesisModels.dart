enum ProjectStage {
  analysis,
  awaitingApproval,
  planned,
  inProgress,
  validation,
  published,
}

extension ProjectStageX on ProjectStage {
  String get label => switch (this) {
    ProjectStage.analysis => 'Em análise',
    ProjectStage.awaitingApproval => 'Aguardando cliente',
    ProjectStage.planned => 'Planejado',
    ProjectStage.inProgress => 'Em andamento',
    ProjectStage.validation => 'Em validação',
    ProjectStage.published => 'Publicado',
  };

  String get compactLabel => switch (this) {
    ProjectStage.awaitingApproval => 'Aguardando',
    _ => label,
  };
}

enum AgendaKind { meeting, presentation, deadline, task }

extension AgendaKindX on AgendaKind {
  String get label => switch (this) {
    AgendaKind.meeting => 'Reunião',
    AgendaKind.presentation => 'Apresentação',
    AgendaKind.deadline => 'Prazo',
    AgendaKind.task => 'Tarefa',
  };
}

enum FinanceType { income, expense }

extension FinanceTypeX on FinanceType {
  String get label => this == FinanceType.income ? 'Receita' : 'Despesa';
}

enum PaymentStatus { pending, paid }

extension PaymentStatusX on PaymentStatus {
  String get label => this == PaymentStatus.paid ? 'Pago' : 'Pendente';
}

class Client {
  const Client({
    required this.id,
    required this.name,
    required this.company,
    required this.email,
    required this.phone,
    required this.city,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.remoteId,
    this.pendingSync = true,
  });

  final String id;
  final String name;
  final String company;
  final String email;
  final String phone;
  final String city;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? remoteId;
  final bool pendingSync;

  Client copyWith({
    String? name,
    String? company,
    String? email,
    String? phone,
    String? city,
    String? notes,
    DateTime? updatedAt,
    String? remoteId,
    bool? pendingSync,
  }) {
    return Client(
      id: id,
      name: name ?? this.name,
      company: company ?? this.company,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remoteId: remoteId ?? this.remoteId,
      pendingSync: pendingSync ?? this.pendingSync,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'company': company,
    'email': email,
    'phone': phone,
    'city': city,
    'notes': notes,
    'createdAtLocal': createdAt.toIso8601String(),
    'updatedAtLocal': updatedAt.toIso8601String(),
    'remoteId': remoteId,
    'pendingSync': pendingSync,
  };

  Map<String, dynamic> toRemote() => {
    'localId': id,
    'name': name,
    'company': company,
    'email': email,
    'phone': phone,
    'city': city,
    'notes': notes,
    'createdAtLocal': createdAt.toIso8601String(),
    'updatedAtLocal': updatedAt.toIso8601String(),
  };

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: (json['localId'] ?? json['id'] ?? json['objectId']).toString(),
      name: json['name']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      createdAt: _parseDate(json['createdAtLocal'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updatedAtLocal'] ?? json['updatedAt']),
      remoteId: (json['objectId'] ?? json['remoteId'])?.toString(),
      pendingSync: json['pendingSync'] == true,
    );
  }
}

class Project {
  const Project({
    required this.id,
    required this.name,
    required this.clientId,
    required this.value,
    required this.stage,
    required this.dueDate,
    required this.domain,
    required this.domainExpiration,
    required this.siteUrl,
    required this.repositoryUrl,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.remoteId,
    this.pendingSync = true,
  });

  final String id;
  final String name;
  final String clientId;
  final double value;
  final ProjectStage stage;
  final DateTime? dueDate;
  final String domain;
  final DateTime? domainExpiration;
  final String siteUrl;
  final String repositoryUrl;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? remoteId;
  final bool pendingSync;

  Project copyWith({
    String? name,
    String? clientId,
    double? value,
    ProjectStage? stage,
    DateTime? dueDate,
    String? domain,
    DateTime? domainExpiration,
    String? siteUrl,
    String? repositoryUrl,
    String? notes,
    DateTime? updatedAt,
    String? remoteId,
    bool? pendingSync,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      clientId: clientId ?? this.clientId,
      value: value ?? this.value,
      stage: stage ?? this.stage,
      dueDate: dueDate ?? this.dueDate,
      domain: domain ?? this.domain,
      domainExpiration: domainExpiration ?? this.domainExpiration,
      siteUrl: siteUrl ?? this.siteUrl,
      repositoryUrl: repositoryUrl ?? this.repositoryUrl,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remoteId: remoteId ?? this.remoteId,
      pendingSync: pendingSync ?? this.pendingSync,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'clientId': clientId,
    'value': value,
    'stage': stage.name,
    'dueDate': dueDate?.toIso8601String(),
    'domain': domain,
    'domainExpiration': domainExpiration?.toIso8601String(),
    'siteUrl': siteUrl,
    'repositoryUrl': repositoryUrl,
    'notes': notes,
    'createdAtLocal': createdAt.toIso8601String(),
    'updatedAtLocal': updatedAt.toIso8601String(),
    'remoteId': remoteId,
    'pendingSync': pendingSync,
  };

  Map<String, dynamic> toRemote() => {
    'localId': id,
    'name': name,
    'clientId': clientId,
    'value': value,
    'stage': stage.name,
    'dueDate': dueDate?.toIso8601String(),
    'domain': domain,
    'domainExpiration': domainExpiration?.toIso8601String(),
    'siteUrl': siteUrl,
    'repositoryUrl': repositoryUrl,
    'notes': notes,
    'createdAtLocal': createdAt.toIso8601String(),
    'updatedAtLocal': updatedAt.toIso8601String(),
  };

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: (json['localId'] ?? json['id'] ?? json['objectId']).toString(),
      name: json['name']?.toString() ?? '',
      clientId: json['clientId']?.toString() ?? '',
      value: _parseDouble(json['value']),
      stage: ProjectStage.values.firstWhere(
        (stage) => stage.name == json['stage'],
        orElse: () => ProjectStage.analysis,
      ),
      dueDate: _parseNullableDate(json['dueDate']),
      domain: json['domain']?.toString() ?? '',
      domainExpiration: _parseNullableDate(json['domainExpiration']),
      siteUrl: json['siteUrl']?.toString() ?? '',
      repositoryUrl: json['repositoryUrl']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      createdAt: _parseDate(json['createdAtLocal'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updatedAtLocal'] ?? json['updatedAt']),
      remoteId: (json['objectId'] ?? json['remoteId'])?.toString(),
      pendingSync: json['pendingSync'] == true,
    );
  }
}

class AgendaEntry {
  const AgendaEntry({
    required this.id,
    required this.title,
    required this.kind,
    required this.dateTime,
    required this.clientId,
    required this.projectId,
    required this.notes,
    required this.done,
    required this.createdAt,
    required this.updatedAt,
    this.remoteId,
    this.pendingSync = true,
  });

  final String id;
  final String title;
  final AgendaKind kind;
  final DateTime dateTime;
  final String clientId;
  final String projectId;
  final String notes;
  final bool done;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? remoteId;
  final bool pendingSync;

  AgendaEntry copyWith({
    String? title,
    AgendaKind? kind,
    DateTime? dateTime,
    String? clientId,
    String? projectId,
    String? notes,
    bool? done,
    DateTime? updatedAt,
    String? remoteId,
    bool? pendingSync,
  }) {
    return AgendaEntry(
      id: id,
      title: title ?? this.title,
      kind: kind ?? this.kind,
      dateTime: dateTime ?? this.dateTime,
      clientId: clientId ?? this.clientId,
      projectId: projectId ?? this.projectId,
      notes: notes ?? this.notes,
      done: done ?? this.done,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remoteId: remoteId ?? this.remoteId,
      pendingSync: pendingSync ?? this.pendingSync,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'kind': kind.name,
    'dateTime': dateTime.toIso8601String(),
    'clientId': clientId,
    'projectId': projectId,
    'notes': notes,
    'done': done,
    'createdAtLocal': createdAt.toIso8601String(),
    'updatedAtLocal': updatedAt.toIso8601String(),
    'remoteId': remoteId,
    'pendingSync': pendingSync,
  };

  Map<String, dynamic> toRemote() => {
    'localId': id,
    'title': title,
    'kind': kind.name,
    'dateTime': dateTime.toIso8601String(),
    'clientId': clientId,
    'projectId': projectId,
    'notes': notes,
    'done': done,
    'createdAtLocal': createdAt.toIso8601String(),
    'updatedAtLocal': updatedAt.toIso8601String(),
  };

  factory AgendaEntry.fromJson(Map<String, dynamic> json) {
    return AgendaEntry(
      id: (json['localId'] ?? json['id'] ?? json['objectId']).toString(),
      title: json['title']?.toString() ?? '',
      kind: AgendaKind.values.firstWhere(
        (kind) => kind.name == json['kind'],
        orElse: () => AgendaKind.meeting,
      ),
      dateTime: _parseDate(json['dateTime']),
      clientId: json['clientId']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      done: json['done'] == true,
      createdAt: _parseDate(json['createdAtLocal'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updatedAtLocal'] ?? json['updatedAt']),
      remoteId: (json['objectId'] ?? json['remoteId'])?.toString(),
      pendingSync: json['pendingSync'] == true,
    );
  }
}

class FinanceEntry {
  const FinanceEntry({
    required this.id,
    required this.description,
    required this.type,
    required this.status,
    required this.amount,
    required this.category,
    required this.dueDate,
    required this.projectId,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.remoteId,
    this.pendingSync = true,
  });

  final String id;
  final String description;
  final FinanceType type;
  final PaymentStatus status;
  final double amount;
  final String category;
  final DateTime dueDate;
  final String projectId;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? remoteId;
  final bool pendingSync;

  FinanceEntry copyWith({
    String? description,
    FinanceType? type,
    PaymentStatus? status,
    double? amount,
    String? category,
    DateTime? dueDate,
    String? projectId,
    String? notes,
    DateTime? updatedAt,
    String? remoteId,
    bool? pendingSync,
  }) {
    return FinanceEntry(
      id: id,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      projectId: projectId ?? this.projectId,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remoteId: remoteId ?? this.remoteId,
      pendingSync: pendingSync ?? this.pendingSync,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'type': type.name,
    'status': status.name,
    'amount': amount,
    'category': category,
    'dueDate': dueDate.toIso8601String(),
    'projectId': projectId,
    'notes': notes,
    'createdAtLocal': createdAt.toIso8601String(),
    'updatedAtLocal': updatedAt.toIso8601String(),
    'remoteId': remoteId,
    'pendingSync': pendingSync,
  };

  Map<String, dynamic> toRemote() => {
    'localId': id,
    'description': description,
    'type': type.name,
    'status': status.name,
    'amount': amount,
    'category': category,
    'dueDate': dueDate.toIso8601String(),
    'projectId': projectId,
    'notes': notes,
    'createdAtLocal': createdAt.toIso8601String(),
    'updatedAtLocal': updatedAt.toIso8601String(),
  };

  factory FinanceEntry.fromJson(Map<String, dynamic> json) {
    return FinanceEntry(
      id: (json['localId'] ?? json['id'] ?? json['objectId']).toString(),
      description: json['description']?.toString() ?? '',
      type: FinanceType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => FinanceType.income,
      ),
      status: PaymentStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      amount: _parseDouble(json['amount']),
      category: json['category']?.toString() ?? '',
      dueDate: _parseDate(json['dueDate']),
      projectId: json['projectId']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      createdAt: _parseDate(json['createdAtLocal'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updatedAtLocal'] ?? json['updatedAt']),
      remoteId: (json['objectId'] ?? json['remoteId'])?.toString(),
      pendingSync: json['pendingSync'] == true,
    );
  }
}

DateTime _parseDate(dynamic value) {
  return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
}

DateTime? _parseNullableDate(dynamic value) {
  if (value == null || value.toString().isEmpty) return null;
  return DateTime.tryParse(value.toString());
}

double _parseDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
