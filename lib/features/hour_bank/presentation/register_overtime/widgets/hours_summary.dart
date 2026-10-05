import 'package:flutter/material.dart';
import 'package:gestor_horas_extras/core/utils.dart';
import 'package:gestor_horas_extras/features/hour_bank/data/models/bank_entry.dart';

class HoursSummary extends StatelessWidget {
  const HoursSummary({super.key, required this.draft});

  final BankEntry? draft;

  @override
  Widget build(BuildContext context) {
    final workedMinutes = draft?.workedMinutes ?? 0;
    final generatedMinutes = draft?.amountMinutes ?? 0;

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Horas trabalhadas: ${Utils.formatMinutes(workedMinutes)}',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ),

        const SizedBox(height: 8),

        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Horas geradas: ${Utils.formatMinutes(generatedMinutes)}',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.green.shade700,
            ),
          ),
        ),
      ],
    );
  }
}
