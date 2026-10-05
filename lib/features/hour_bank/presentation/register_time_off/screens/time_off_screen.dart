import 'package:flutter/material.dart';
import 'package:gestor_horas_extras/common_widgets/app_snack_bar.dart';
import 'package:gestor_horas_extras/core/utils.dart';
import 'package:gestor_horas_extras/features/hour_bank/presentation/register_time_off/widgets/hour_subtraction_summary.dart';
import 'package:go_router/go_router.dart';

import '../controllers/time_off_controller.dart';

class TimeOffScreen extends StatefulWidget {
  const TimeOffScreen({super.key});

  @override
  State<TimeOffScreen> createState() => _TimeOffScreenState();
}

class _TimeOffScreenState extends State<TimeOffScreen> {
  final _controller = TimeOffController();

  final _formKey = GlobalKey<FormState>();
  final _controllerDate = TextEditingController(
    text: Utils.formatDate(DateTime.now()),
  );
  final _controllerHours = TextEditingController();
  final _controllerObservation = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentBankMinutes();
  }

  Future<void> _loadCurrentBankMinutes() async {
    await _controller.loadCurrentBankMinutes();

    if (!mounted) return;

    final message = _controller.errorMessage;
    if (message != null) {
      AppSnackBar.showError(context, message);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _controllerDate.dispose();
    _controllerHours.dispose();
    _controllerObservation.dispose();
    super.dispose();
  }

  Future<void> _saveTimeOff() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final observation = _controllerObservation.text.trim();
    final saved = await _controller.saveTimeOff(
      date: _controllerDate.text,
      hours: _controllerHours.text,
      observation: observation.isEmpty ? null : observation,
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
        title: const Text('Registrar folga'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.loadingBalance) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Registre a folga:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _controllerDate,
                            validator: _controller.validateDate,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Data da folga',
                              hintText: 'dd/MM/aaaa',
                            ),
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _controllerHours,
                            validator: _controller.validateHours,
                            keyboardType: TextInputType.number,
                            inputFormatters: [Utils.hourMinuteInputFormatter()],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Quantidade de horas',
                              hintText: 'hh:mm',
                            ),
                          ),

                          const SizedBox(height: 18),

                          TextFormField(
                            controller: _controllerObservation,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Observação (Opcional)',
                              hintText:
                                  'Insira observação sobre o registro de folga',
                            ),
                          ),

                          const SizedBox(height: 20),

                          ValueListenableBuilder(
                            valueListenable: _controllerHours,
                            builder: (context, value, _) {
                              final requested = Utils.parseHourMinuteToMinutes(
                                value.text,
                              );

                              return HourSubtractionSummary(
                                totalTimeOff: requested < 0 ? 0 : requested,
                                currentTimeInBank:
                                    _controller.currentBankMinutes,
                              );
                            },
                          ),

                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _controller.loading
                                  ? null
                                  : _saveTimeOff,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                              ),
                              child: const Text('Salvar folga'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
