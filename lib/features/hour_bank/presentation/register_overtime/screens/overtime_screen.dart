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
  final _controllerDate = TextEditingController(
    text: Utils.formatDate(DateTime.now()),
  );
  final _controllerDescription = TextEditingController();
  final _controllerEntry = TextEditingController();
  final _controllerExit = TextEditingController();
  final _controllerEntry2 = TextEditingController();
  final _controllerExit2 = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _controllerDate.dispose();
    _controllerDescription.dispose();
    _controllerEntry.dispose();
    _controllerExit.dispose();
    _controllerEntry2.dispose();
    _controllerExit2.dispose();
    super.dispose();
  }

  Future<void> _saveOvertime() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final isFullDay = _controller.isFullDay;
    final saved = await _controller.saveOvertime(
      date: _controllerDate.text,
      description: _controllerDescription.text,
      firstClockIn: _controllerEntry.text,
      firstClockOut: _controllerExit.text,
      secondClockIn: isFullDay ? _controllerEntry2.text : null,
      secondClockOut: isFullDay ? _controllerExit2.text : null,
    );

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
                            controller: _controllerDate,
                            validator: (value) => Utils.validateDateBr(value),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Data da atividade',
                              hintText: 'dd/MM/aaaa',
                            ),
                          ),

                          const SizedBox(height: 18),

                          TextFormField(
                            controller: _controllerDescription,
                            validator: _controller.validateDescription,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Descrição da atividade',
                              hintText: 'Ex.: Mutirão de vacinação',
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
                              controller: _controllerEntry,
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
                                hintText: '08:00',
                              ),
                            ),

                            const SizedBox(height: 18),

                            TextFormField(
                              controller: _controllerExit,
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
                                hintText: 'Insira horário de saída',
                              ),
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _controllerEntry,
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
                                      labelText: 'Primaira entrada',
                                      hintText: 'Insira horário de entrada',
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: TextFormField(
                                    controller: _controllerEntry2,
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
                                      hintText: 'Insira horário de entrada',
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
                                    controller: _controllerExit,
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
                                      hintText: 'Insira horário de saída',
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: TextFormField(
                                    controller: _controllerExit2,
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
                                      hintText: 'Insira horário de saída',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 18),

                          DropdownButtonFormField<double>(
                            initialValue: _controller.timeMultiplier,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Tipo de atividade',
                            ),
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
                            onChanged: (value) =>
                                _controller.setTimeMultiplier(value ?? 1.5),
                          ),

                          const SizedBox(height: 20),

                          HoursSummary(
                            controller: _controller,
                            firstClockIn: _controllerEntry,
                            firstClockOut: _controllerExit,
                            secondClockIn: _controllerEntry2,
                            secondClockOut: _controllerExit2,
                          ),

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
