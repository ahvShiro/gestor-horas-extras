import 'package:flutter/material.dart';
import 'package:gestor_horas_extras/core/utils.dart';

import '../controllers/overtime_controller.dart';

class HoursSummary extends StatelessWidget {
  const HoursSummary({
    super.key,
    required this.controller,
    required this.firstClockIn,
    required this.firstClockOut,
    required this.secondClockIn,
    required this.secondClockOut,
  });

  final OvertimeController controller;
  final TextEditingController firstClockIn;
  final TextEditingController firstClockOut;
  final TextEditingController secondClockIn;
  final TextEditingController secondClockOut;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        firstClockIn,
        firstClockOut,
        secondClockIn,
        secondClockOut,
      ]),
      builder: (context, _) {
        final isFullDay = controller.isFullDay;
        final workedMinutes = controller.workedMinutes(
          entry: firstClockIn.text,
          exit: firstClockOut.text,
          entry2: isFullDay ? secondClockIn.text : null,
          exit2: isFullDay ? secondClockOut.text : null,
        );
        final generatedMinutes = controller.generatedMinutes(workedMinutes);

        return Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Horas trabalhadas: ${Utils.formatMinutes(workedMinutes)}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
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
      },
    );
  }
}
