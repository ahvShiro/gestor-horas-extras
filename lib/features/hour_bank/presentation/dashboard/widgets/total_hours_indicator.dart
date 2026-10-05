import 'package:flutter/material.dart';
import 'package:gestor_horas_extras/core/utils.dart';

import '../controllers/dashboard_controller.dart';

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

        const SizedBox(height: 4),
        const Text(
          'no banco de horas',
          style: TextStyle(fontSize: 20, color: Colors.black54),
        ),
      ],
    );
  }
}
