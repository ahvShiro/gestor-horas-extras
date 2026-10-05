import 'package:flutter/material.dart';
import 'package:gestor_horas_extras/core/utils.dart';

import '../../../../authentication/data/services/auth_service.dart';
import '../../../data/models/bank_entry.dart';
import '../../../data/repositories/firestore_bank_entry_repository.dart';
import '../../../domain/repositories/bank_entry_repository.dart';

class TimeOffController extends ChangeNotifier {
  TimeOffController({BankEntryRepository? repository, AuthService? authService})
    : _repository = repository ?? FirestoreBankEntryRepository(),
      _authService = authService ?? AuthService();

  final BankEntryRepository _repository;
  final AuthService _authService;

  int currentBankMinutes = 0;
  bool loadingBalance = true;
  bool loading = false;
  String? errorMessage;

  Future<void> loadCurrentBankMinutes() async {
    loadingBalance = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentBankMinutes = await getTotalFromBank();
    } catch (e) {
      errorMessage = 'Não foi possível carregar o banco de horas';
    } finally {
      loadingBalance = false;
      notifyListeners();
    }
  }

  String? validateDate(String? value) {
    final result = Utils.validateDateBr(value);
    if (result != null) {
      return result == 'Insira a data' ? 'Insira a data da folga' : result;
    }

    final day = Utils.parseDateBr(value!);
    if (day == null || Utils.formatDate(day) != value.trim()) {
      return 'Insira uma data válida';
    }

    return null;
  }

  Future<int> getTotalFromBank() async {
    final userId = _authService.currentUserId;
    if (userId == null) return 0;

    final entryList = await _repository.getAllFromUser(userId);

    int total = 0;

    for (var entry in entryList) {
      total += entry.amountMinutes;
    }

    return total;
  }

  String? validateHours(String? value) {
    final hourValidation = Utils.validateHourMinute(
      value,
      requiredField: true,
      requiredMessage: 'Insira a quantidade de horas',
    );
    if (hourValidation != null) {
      return hourValidation;
    }

    final requestedMinutes = Utils.parseHourMinuteToMinutes(value ?? '');
    if (requestedMinutes <= 0) {
      return 'A quantidade deve ser maior que 00:00';
    }

    if (requestedMinutes > currentBankMinutes) {
      return 'Folga não pode ser maior que o banco atual';
    }

    return null;
  }

  Future<bool> saveTimeOff({
    required String date,
    required String hours,
    String? observation,
  }) async {
    errorMessage = null;

    final userId = _authService.currentUserId;
    if (userId == null) {
      errorMessage = 'Usuário não autenticado';
      notifyListeners();
      return false;
    }

    final day = Utils.parseDateBr(date);
    final requestedMinutes = Utils.parseHourMinuteToMinutes(hours);
    if (day == null || requestedMinutes <= 0) {
      errorMessage = 'Verifique a data e a quantidade de horas';
      notifyListeners();
      return false;
    }

    final entry = BankEntry(
      uid: '',
      userId: userId,
      title: 'Folga',
      observation: observation,
      entryType: EntryType.timeOff,
      timeMultiplier: 1.0,
      firstClockIn: day,
      firstClockOut: day.add(Duration(minutes: requestedMinutes)),
      registeredDate: DateTime.now(),
    );

    loading = true;
    notifyListeners();

    try {
      await _repository.save(entry);
      return true;
    } catch (_) {
      errorMessage = 'Não foi possível salvar a folga';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
