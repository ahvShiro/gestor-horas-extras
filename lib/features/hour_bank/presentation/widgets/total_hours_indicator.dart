import 'package:flutter/material.dart';
import 'package:gestor_horas_extras/core/utils.dart';
import 'package:gestor_horas_extras/features/hour_bank/presentation/controllers/bank_hours_home_controller.dart';

class TotalHoursIndicator extends StatelessWidget {
  const TotalHoursIndicator({super.key, required this.controller});

  final BankHoursHomeController controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          Utils.formatSignedMinutes(controller.balanceMinutes),
          style: const TextStyle(fontSize: 54, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 6),
        const Text(
          'no banco de horas',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }
}
