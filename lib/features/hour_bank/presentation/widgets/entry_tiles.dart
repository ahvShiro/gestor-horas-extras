import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gestor_horas_extras/core/utils.dart';

import '../../data/models/bank_entry.dart';

class EntryTiles extends StatelessWidget {
  const EntryTiles({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final BankEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isTimeOff = entry.entryType == EntryType.timeOff;
    final entryColor = isTimeOff ? Colors.red.shade700 : Colors.green.shade700;
    final tileBackground = isTimeOff
        ? Colors.red.shade50
        : Colors.green.shade50;

    return Slidable(
      key: ValueKey(entry.uid),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.45,
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(),
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Editar',
            borderRadius: BorderRadius.circular(10),
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Excluir',
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: tileBackground,
        title: Text(
          entry.title,
          style: TextStyle(
            fontSize: 17,
            color: entryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: entry.description != null
            ? Text(
                entry.description!,
                style: TextStyle(color: entryColor.withValues(alpha: 0.8)),
              )
            : Text(''),
        trailing: Text(
          Utils.formatSignedMinutes(entry.amountMinutes),
          style: TextStyle(
            fontSize: 22,
            color: entryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
