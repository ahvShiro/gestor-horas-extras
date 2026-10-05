import 'package:flutter/material.dart';
import 'package:gestor_horas_extras/features/hour_bank/data/models/bank_entry.dart';

class BankHoursHomeController extends ChangeNotifier {
  List<BankEntry> get entries => const [];

  int get balanceMinutes => 0;

  Future<void> refresh() async {}

  Future<void> openEntryEdit(BankEntry entry) async {}

  Future<void> confirmDeleteEntry(BankEntry entry) async {}
}
