import 'dart:convert';

import 'package:gestor_horas_extras/core/utils.dart';

abstract class BankEntry {
  const BankEntry({
    this.id,
    required this.userId,
    required this.dateText,
    required this.entryDate,
    required this.createdAt,
    this.sortOrder = 0,
  });

  final int? id;
  final int userId;
  final String dateText;
  final DateTime entryDate;
  final DateTime createdAt;
  final int sortOrder;

  String get entryType;
  String get title;
  String? get description;
  int get amountMinutes;

  Map<String, Object?> toFormData();

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'entry_type': entryType,
      'title': title,
      'description': description,
      'amount_minutes': amountMinutes,
      'entry_date': entryDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'sort_order': sortOrder,
      'form_data': jsonEncode(toFormData()),
    };
  }

  static Map<String, dynamic> _decodeFormData(Map<String, Object?> map) {
    final raw = map['form_data'];
    if (raw is String && raw.trim().isNotEmpty) {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    }

    return <String, dynamic>{};
  }

  static BankEntry fromMap(Map<String, Object?> map) {
    switch (map['entry_type'] as String?) {
      case 'activity':
        return ActivityBankEntry.fromMap(map);
      case 'day_off':
        return DayOffBankEntry.fromMap(map);
      default:
        throw StateError('Unsupported bank entry type: ${map['entry_type']}');
    }
  }
}

class ActivityBankEntry extends BankEntry {
  const ActivityBankEntry({
    super.id,
    required super.userId,
    required super.dateText,
    required super.entryDate,
    required super.createdAt,
    this.activityDescription = '',
    this.isFullDay = false,
    this.eventMultiplier = 1.5,
    required this.entry1,
    required this.exit1,
    this.entry2,
    this.exit2,
    super.sortOrder,
  });

  final String activityDescription;
  final bool isFullDay;
  final double eventMultiplier;
  final DateTime entry1;
  final DateTime exit1;
  final DateTime? entry2;
  final DateTime? exit2;

  int get workedMinutes {
    var total = _workedMinutesFromRange(entry1, exit1);
    if (isFullDay) {
      total += _workedMinutesFromRange(entry2, exit2);
    }

    return total;
  }

  int _workedMinutesFromRange(DateTime? entry, DateTime? exit) {
    if (entry == null || exit == null) return 0;
    if (!exit.isAfter(entry)) return 0;
    return exit.difference(entry).inMinutes;
  }

  @override
  String get entryType => 'activity';

  @override
  String get title => activityDescription;

  @override
  String? get description =>
      isFullDay ? 'Atividade em dia inteiro' : 'Atividade';

  @override
  int get amountMinutes => (workedMinutes * eventMultiplier).round();

  @override
  Map<String, Object?> toFormData() {
    return {
      'date': dateText,
      'description': activityDescription,
      'isFullDay': isFullDay,
      'eventMultiplier': eventMultiplier,
      'entry': entry1.toIso8601String(),
      'exit': exit1.toIso8601String(),
      'entry2': entry2?.toIso8601String(),
      'exit2': exit2?.toIso8601String(),
    };
  }

  factory ActivityBankEntry.fromMap(Map<String, Object?> map) {
    final formData = BankEntry._decodeFormData(map);
    final entryDate = DateTime.parse(
      (map['entry_date'] as String?) ?? (map['created_at'] as String),
    );
    return ActivityBankEntry(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      dateText: (formData['date'] as String?) ?? Utils.formatDate(entryDate),
      entryDate: entryDate,
      createdAt: DateTime.parse(map['created_at'] as String),
      sortOrder: (map['sort_order'] as int?) ?? 0,
      activityDescription:
          (formData['description'] as String?) ??
          (map['title'] as String? ?? ''),
      isFullDay:
          (formData['isFullDay'] as bool?) ??
          (map['description'] as String?) == 'Atividade em dia inteiro',
      eventMultiplier: (formData['eventMultiplier'] as num?)?.toDouble() ?? 1.5,
      entry1: _parseEntryTime(formData['entry'] as String?, entryDate),
      exit1: _parseEntryTime(formData['exit'] as String?, entryDate),
      entry2: _parseEntryTime(formData['entry2'] as String?, entryDate),
      exit2: _parseEntryTime(formData['exit2'] as String?, entryDate),
    );
  }

  static DateTime _parseEntryTime(String? raw, DateTime entryDate) {
    if (raw == null || raw.trim().isEmpty) {
      return DateTime(entryDate.year, entryDate.month, entryDate.day);
    }

    try {
      // Try ISO8601 first
      return DateTime.parse(raw);
    } catch (_) {
      // Fallback to HH:MM anchored on entryDate
      final parsed = Utils.parseHourMinuteToDateTime(raw, entryDate);
      return parsed ?? DateTime(entryDate.year, entryDate.month, entryDate.day);
    }
  }
}

class DayOffBankEntry extends BankEntry {
  const DayOffBankEntry({
    super.id,
    required super.userId,
    required super.dateText,
    required super.entryDate,
    required super.createdAt,
    required this.hoursMinutes,
    this.observation,
    super.sortOrder,
  });

  final int hoursMinutes;
  final String? observation;

  int get requestedMinutes => hoursMinutes;

  @override
  String get entryType => 'day_off';

  @override
  String get title => observation?.trim() ?? '';

  @override
  String? get description => 'Folga';

  @override
  int get amountMinutes => -requestedMinutes;

  @override
  Map<String, Object?> toFormData() {
    return {'date': dateText, 'hoursMinutes': hoursMinutes, 'observation': observation};
  }

  factory DayOffBankEntry.fromMap(Map<String, Object?> map) {
    final formData = BankEntry._decodeFormData(map);
    final entryDate = DateTime.parse(
      (map['entry_date'] as String?) ?? (map['created_at'] as String),
    );
    return DayOffBankEntry(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      dateText: (formData['date'] as String?) ?? Utils.formatDate(entryDate),
      entryDate: entryDate,
      createdAt: DateTime.parse(map['created_at'] as String),
      sortOrder: (map['sort_order'] as int?) ?? 0,
      hoursMinutes: (formData['hoursMinutes'] as int?) ??
          ((formData['hours'] as String?) != null
              ? Utils.parseHourMinuteToMinutes(formData['hours'] as String)
              : (map['amount_minutes'] as int? ?? 0).abs()),
      observation:
          (formData['observation'] as String?) ??
          (map['description'] as String?),
    );
  }

}
