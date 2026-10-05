import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gestor_horas_extras/features/authentication/data/services/auth_service.dart';

import '../../../data/models/bank_entry.dart';
import '../../../data/repositories/firestore_bank_entry_repository.dart';
import '../../../domain/repositories/bank_entry_repository.dart';

class BankHoursHomeController extends ChangeNotifier {
  BankHoursHomeController({
    BankEntryRepository? repository,
    AuthService? authService,
  }) : _repository = repository ?? FirestoreBankEntryRepository(),
       _authService = authService ?? AuthService();

  final BankEntryRepository _repository;
  final AuthService _authService;
  StreamSubscription<List<BankEntry>>? _subscription;

  List<BankEntry> entries = [];
  bool loading = true;
  String? errorMessage;

  int get balanceMinutes =>
      entries.fold(0, (total, entry) => total + entry.amountMinutes);

  void start() {
    final userId = _authService.currentUserId;
    if (userId == null) {
      loading = false;
      errorMessage = 'Usuário não autenticado';
      notifyListeners();
      return;
    }

    _subscription = _repository
        .watchAllFromUser(userId)
        .listen(
          (data) {
            entries = data;
            loading = false;
            errorMessage = null;
            notifyListeners();
          },
          onError: (Object error) {
            debugPrint('watchAllFromUser error: $error');
            loading = false;
            errorMessage = 'Não foi possível carregar o banco de horas';
            notifyListeners();
          },
        );
  }

  Future<void> deleteEntry(BankEntry entry) async {
    try {
      await _repository.delete(entry.uid);
    } catch (_) {
      errorMessage = 'Não foi possível excluir o registro';
      notifyListeners();
    }
  }

  Future<void> openEntryEdit(BankEntry entry) async {}

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
