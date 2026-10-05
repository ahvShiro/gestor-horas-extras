import 'package:flutter/material.dart';

class OvertimeController extends ChangeNotifier {
  bool isFullDay = false;
  double timeMultiplier = 1.5;
  bool loading = false;
  String? errorMessage;

  void setFullDay(bool value) {
    isFullDay = value;
    notifyListeners();
  }

  void setTimeMultiplier(double value) {
    timeMultiplier = value;
    notifyListeners();
  }

  String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Insira a descrição da atividade';
    }

    return null;
  }

  int workedMinutes({
    required String entry,
    required String exit,
    String? entry2,
    String? exit2,
  }) => 0;

  int generatedMinutes(int workedMinutes) => 0;

  Future<bool> saveOvertime({
    required String date,
    required String description,
    required String firstClockIn,
    required String firstClockOut,
    String? secondClockIn,
    String? secondClockOut,
  }) async => false;
}
