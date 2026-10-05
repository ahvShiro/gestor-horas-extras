import 'package:cloud_firestore/cloud_firestore.dart';

enum EntryType { overtime, timeOff }

class BankEntry {
  final String uid;
  final String userId;
  final String title;
  final String? description;
  final EntryType entryType;
  final double timeMultiplier;
  final DateTime firstClockIn;
  final DateTime? secondClockIn;
  final DateTime firstClockOut;
  final DateTime? secondClockOut;
  final DateTime registeredDate;

  BankEntry({
    required this.uid,
    required this.userId,
    required this.title,
    this.description,
    required this.entryType,
    required this.timeMultiplier,
    required this.firstClockIn,
    this.secondClockIn,
    required this.firstClockOut,
    this.secondClockOut,
    required this.registeredDate,
  });

  int get amountMinutes {
    final amount = (workedMinutes * timeMultiplier).round();
    return entryType == EntryType.timeOff ? -amount : amount;
  }

  int get workedMinutes {
    var worked = firstClockOut.difference(firstClockIn).inMinutes;

    if (secondClockIn == null || secondClockOut == null) return worked;

    return worked + secondClockOut!.difference(secondClockIn!).inMinutes;
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'entryType': entryType.name,
      'timeMultiplier': timeMultiplier,
      'firstClockIn': firstClockIn,
      'secondClockIn': secondClockIn,
      'firstClockOut': firstClockOut,
      'secondClockOut': secondClockOut,
      'registeredDate': registeredDate,
      'userId': userId,
    };
  }

  factory BankEntry.fromMap(Map<String, dynamic> map, String id) {
    return BankEntry(
      uid: id,
      title: map['title'] as String,
      description: map['description'] as String?,
      entryType: EntryType.values.byName(map['entryType'] as String),
      timeMultiplier: (map['timeMultiplier'] as num).toDouble(),
      firstClockIn: (map['firstClockIn'] as Timestamp).toDate(),
      secondClockIn: (map['secondClockIn'] as Timestamp?)?.toDate(),
      firstClockOut: (map['firstClockOut'] as Timestamp).toDate(),
      secondClockOut: (map['secondClockOut'] as Timestamp?)?.toDate(),
      registeredDate: (map['registeredDate'] as Timestamp).toDate(),
      userId: map['userId'] as String,
    );
  }
}
