import 'package:flutter/material.dart';
import 'package:gestor_horas_extras/common_widgets/app_snack_bar.dart';
import 'package:gestor_horas_extras/core/exceptions/business_exception.dart';

import '../../../data/models/bank_entry.dart';
import '../controllers/dashboard_controller.dart';
import 'entry_tiles.dart';

class BankEntriesListing extends StatelessWidget {
  const BankEntriesListing({super.key, required this.controller});

  final BankHoursHomeController controller;

  Future<void> _confirmDelete(BuildContext context, BankEntry entry) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir registro'),
          content: const Text(
            'Tem certeza que deseja excluir este registro? Esta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        await controller.deleteEntry(entry);
      } on BusinessException catch (e) {
        if (context.mounted) {
          AppSnackBar.showError(context, e.message);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = controller.entries;

    return Expanded(
      child: entries.isEmpty
          ? ListView(
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
              itemCount: entries.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final entry = entries[index];

                return EntryTiles(
                  entry: entry,
                  onEdit: () => controller.openEntryEdit(entry),
                  onDelete: () => _confirmDelete(context, entry),
                );
              },
            ),
    );
  }
}
