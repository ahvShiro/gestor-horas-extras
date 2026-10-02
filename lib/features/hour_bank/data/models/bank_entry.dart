enum EntryType { overtime, timeOff }

class BankEntry {
  final String uid;
  final String userId;
  final String description;
  final double timeMultiplier;
  final DateTime firstClockIn;
  final DateTime? secondClockIn;
  final DateTime firstClockOut;
  final DateTime? secondClockOut;
  final DateTime registeredDate;

  BankEntry({
    required this.uid,
    required this.userId,
    required this.description,
    required this.timeMultiplier,
    required this.firstClockIn,
    this.secondClockIn,
    required this.firstClockOut,
    this.secondClockOut,
    required this.registeredDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'description': description,
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
      description: map['description'] as String,
      timeMultiplier: map['timeMultiplier'] as double,
      firstClockIn: map['firstClockIn'] as DateTime,
      secondClockIn: map['secondClockIn'] as DateTime,
      firstClockOut: map['firstClockOut'] as DateTime,
      secondClockOut: map['secondClockOut'] as DateTime,
      registeredDate: map['registeredDate'] as DateTime,
      userId: map['userId'] as String,
    );
  }
}
