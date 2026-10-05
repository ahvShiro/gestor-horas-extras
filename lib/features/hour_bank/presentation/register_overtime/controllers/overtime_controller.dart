import 'package:flutter/material.dart';
import 'package:gestor_horas_extras/core/utils.dart';
import 'package:gestor_horas_extras/features/authentication/data/services/auth_service.dart';
import 'package:gestor_horas_extras/features/hour_bank/data/models/bank_entry.dart';
import 'package:gestor_horas_extras/features/hour_bank/data/repositories/firestore_bank_entry_repository.dart';
import 'package:gestor_horas_extras/features/hour_bank/domain/repositories/bank_entry_repository.dart';

class OvertimeController extends ChangeNotifier {
  OvertimeController({
    BankEntryRepository? repository,
    AuthService? authService,
  }) : _repository = repository ?? FirestoreBankEntryRepository(),
       _authService = authService ?? AuthService();

  final BankEntryRepository _repository;
  final AuthService _authService;

  String date = Utils.formatDate(DateTime.now());
  String title = '';
  String firstClockIn = '';
  String firstClockOut = '';
  String secondClockIn = '';
  String secondClockOut = '';
  bool isFullDay = false;
  double timeMultiplier = 1.5;
  bool loading = false;
  String? errorMessage;

  void setDate(String value) {
    date = value;
    notifyListeners();
  }

  void setFirstClockIn(String value) {
    firstClockIn = value;
    notifyListeners();
  }

  void setFirstClockOut(String value) {
    firstClockOut = value;
    notifyListeners();
  }

  void setSecondClockIn(String value) {
    secondClockIn = value;
    notifyListeners();
  }

  void setSecondClockOut(String value) {
    secondClockOut = value;
    notifyListeners();
  }

  void setFullDay(bool value) {
    isFullDay = value;
    notifyListeners();
  }

  void setTimeMultiplier(double value) {
    timeMultiplier = value;
    notifyListeners();
  }

  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Insira a descrição da atividade';
    }

    return null;
  }

  BankEntry? get draft {
    final day = Utils.parseDateBr(date);
    if (day == null) return null;

    final firstIn = Utils.parseHourMinuteToDateTime(firstClockIn, day);
    final firstOut = Utils.parseHourMinuteToDateTime(firstClockOut, day);
    if (firstIn == null || firstOut == null) return null;
    if (!firstOut.isAfter(firstIn)) return null;

    DateTime? secondIn;
    DateTime? secondOut;
    if (isFullDay) {
      secondIn = Utils.parseHourMinuteToDateTime(secondClockIn, day);
      secondOut = Utils.parseHourMinuteToDateTime(secondClockOut, day);
      if (secondIn == null || secondOut == null) return null;
      if (!secondOut.isAfter(secondIn)) return null;
    }

    return BankEntry(
      uid: '',
      userId: _authService.currentUserId ?? '',
      title: title.trim(),
      description: isFullDay ? 'Atividade em dia inteiro' : 'Atividade',
      entryType: EntryType.overtime,
      timeMultiplier: timeMultiplier,
      firstClockIn: firstIn,
      firstClockOut: firstOut,
      secondClockIn: secondIn,
      secondClockOut: secondOut,
      registeredDate: DateTime.now(),
    );
  }

  Future<bool> saveOvertime() async {
    errorMessage = null;

    if (_authService.currentUserId == null) {
      errorMessage = 'Usuário não autenticado';
      notifyListeners();
      return false;
    }

    final entry = draft;
    if (entry == null) {
      errorMessage =
          'Verifique os horários: a saída deve ser depois da entrada';
      notifyListeners();
      return false;
    }

    loading = true;
    notifyListeners();

    try {
      await _repository.save(entry);
      return true;
    } catch (_) {
      errorMessage = 'Não foi possível salvar a atividade';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
