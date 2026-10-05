import 'package:flutter/material.dart';
import 'package:gestor_horas_extras/features/hour_bank/presentation/controllers/bank_hours_home_controller.dart';

import 'entry_tiles.dart';

class BankEntriesListing extends StatelessWidget {
  const BankEntriesListing({super.key, required this.controller});

  final BankHoursHomeController controller;

  @override
  Widget build(BuildContext context) {
    final entries = controller.entries;

    return Expanded(
      child: RefreshIndicator(
        onRefresh: controller.refresh,
        child: entries.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Text(
                      'Nenhum lançamento registrado ainda',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: entries.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final entry = entries[index];

                  return EntryTiles(
                    entry: entry,
                    onEdit: () => controller.openEntryEdit(entry),
                    onDelete: () => controller.confirmDeleteEntry(entry),
                  );
                },
              ),
      ),
    );
  }
}
