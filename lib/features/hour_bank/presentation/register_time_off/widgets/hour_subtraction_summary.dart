import 'package:flutter/material.dart';

import '../../../../../core/utils.dart';

class HourSubtractionSummary extends StatelessWidget {
  const HourSubtractionSummary({
    super.key,
    required this.totalTimeOff,
    required this.currentTimeInBank,
  });

  final int totalTimeOff;
  final int currentTimeInBank;

  int get afterTimeOffMinutes => currentTimeInBank - totalTimeOff;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Banco atual: ${Utils.formatMinutes(currentTimeInBank)}',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Após folga: ${Utils.formatMinutes(afterTimeOffMinutes)}',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.red.shade700,
            ),
          ),
        ),
      ],
    );
  }
}
