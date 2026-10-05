import 'package:flutter/material.dart';
import 'package:gestor_horas_extras/common_widgets/app_snack_bar.dart';
import 'package:gestor_horas_extras/core/utils.dart';
import 'package:gestor_horas_extras/features/hour_bank/presentation/register_overtime/widgets/hours_summary.dart';
import 'package:go_router/go_router.dart';

import '../controllers/overtime_controller.dart';

class OvertimeScreen extends StatefulWidget {
  const OvertimeScreen({super.key});

  @override
  State<OvertimeScreen> createState() => _OvertimeScreenState();
}

class _OvertimeScreenState extends State<OvertimeScreen> {
  final _controller = OvertimeController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _updateMultiplier();
  }

  void _onDateChanged(String value) {
    _controller.setDate(value);
    _updateMultiplier();
  }

  Future<void> _updateMultiplier() async {
    final updated = await _controller.updateMarkiplier();

    if (!mounted || !updated) return;

    final message = _controller.timeMultiplier == 2.0
        ? 'Atividade em final de semana/feriado (x2)'
        : 'Atividade em dia de semana (x1,5)';

    AppSnackBar.showSuccess(context, message);
  }

  Future<void> _saveOvertime() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final saved = await _controller.saveOvertime();

    if (!mounted) return;

    if (saved) {
      context.pop(true);
      return;
    }

    final message = _controller.errorMessage;
    if (message != null) {
      AppSnackBar.showError(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar atividade'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Registre a atividade:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 16),

                Form(
                  key: _formKey,
                  child: ListenableBuilder(
                    listenable: _controller,
                    builder: (context, _) {
                      return Column(
                        children: [
                          TextFormField(
                            initialValue: _controller.date,
                            onChanged: _onDateChanged,
                            validator: (value) => Utils.validateDateBr(value),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Data da atividade',
                              hintText: 'dd/MM/aaaa',
                            ),
                          ),

                          const SizedBox(height: 18),

                          TextFormField(
                            initialValue: _controller.title,
                            onChanged: (value) => _controller.title = value,
                            validator: _controller.validateTitle,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Título da atividade',
                              hintText: 'Insira o título da atividade',
                            ),
                          ),

                          const SizedBox(height: 18),

                          CheckboxListTile(
                            value: _controller.isFullDay,
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: const Text('Dia inteiro'),
                            onChanged: (value) =>
                                _controller.setFullDay(value ?? false),
                          ),

                          const SizedBox(height: 8),

                          if (!_controller.isFullDay) ...[
                            TextFormField(
                              initialValue: _controller.firstClockIn,
                              onChanged: _controller.setFirstClockIn,
                              validator: (value) {
                                return Utils.validateHourMinute(
                                  value,
                                  requiredField: true,
                                );
                              },
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                Utils.hourMinuteInputFormatter(),
                              ],
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Entrada',
                                hintText: 'Insira o horário de entrada',
                              ),
                            ),

                            const SizedBox(height: 18),

                            TextFormField(
                              initialValue: _controller.firstClockOut,
                              onChanged: _controller.setFirstClockOut,
                              validator: (value) {
                                return Utils.validateHourMinute(
                                  value,
                                  requiredField: true,
                                );
                              },
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                Utils.hourMinuteInputFormatter(),
                              ],
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Saída',
                                hintText: 'Insira o horário de saída',
                              ),
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: _controller.firstClockIn,
                                    onChanged: _controller.setFirstClockIn,
                                    validator: (value) {
                                      return Utils.validateHourMinute(
                                        value,
                                        requiredField: true,
                                      );
                                    },
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      Utils.hourMinuteInputFormatter(),
                                    ],
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Primeira entrada',
                                      hintText: 'Insira o horário',
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: TextFormField(
                                    initialValue: _controller.secondClockIn,
                                    onChanged: _controller.setSecondClockIn,
                                    validator: (value) {
                                      return Utils.validateHourMinute(
                                        value,
                                        requiredField: true,
                                      );
                                    },
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      Utils.hourMinuteInputFormatter(),
                                    ],
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Segunda entrada',
                                      hintText: 'Insira o horário',
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: _controller.firstClockOut,
                                    onChanged: _controller.setFirstClockOut,
                                    validator: (value) {
                                      return Utils.validateHourMinute(
                                        value,
                                        requiredField: true,
                                      );
                                    },
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      Utils.hourMinuteInputFormatter(),
                                    ],
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Primeira saída',
                                      hintText: 'Insira o horário',
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: TextFormField(
                                    initialValue: _controller.secondClockOut,
                                    onChanged: _controller.setSecondClockOut,
                                    validator: (value) {
                                      return Utils.validateHourMinute(
                                        value,
                                        requiredField: true,
                                      );
                                    },
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      Utils.hourMinuteInputFormatter(),
                                    ],
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Segunda saída',
                                      hintText: 'Insira o horário',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          // Seletor oculto: o cliente atual não escolhe o
                          // multiplicador, ele vem da data
                          Visibility(
                            visible: false,
                            child: Column(
                              children: [
                                const SizedBox(height: 18),

                                DropdownButtonFormField<double>(
                                  initialValue: _controller.timeMultiplier,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Tipo de atividade',
                                  ),
                                  key: ValueKey(_controller.timeMultiplier),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 2,
                                      child: Text('Final de semana (x2)'),
                                    ),
                                    DropdownMenuItem(
                                      value: 1.5,
                                      child: Text('Dia de semana (x1,5)'),
                                    ),
                                  ],
                                  onChanged: (value) => _controller
                                      .setTimeMultiplier(value ?? 1.5),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          HoursSummary(draft: _controller.draft),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _controller.loading
                                  ? null
                                  : _saveOvertime,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                              ),
                              child: const Text('Salvar atividade'),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
