import 'package:flutter/material.dart';
import 'package:gestor_horas_extras/core/current_user_session.dart';
import 'package:gestor_horas_extras/core/utils.dart';
import 'package:gestor_horas_extras/data/local/bank_entry_dao.dart';
import 'package:gestor_horas_extras/domain/entities/bank_entry.dart';

class Activity extends StatefulWidget {
  const Activity({super.key});

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  final _formKey = GlobalKey<FormState>();
  final _controllerDate = TextEditingController(
    text: Utils.formatDate(DateTime.now()),
  );
  final _controllerDescription = TextEditingController();
  final _controllerEntry = TextEditingController();
  final _controllerExit = TextEditingController();
  final _controllerEntry2 = TextEditingController();
  final _controllerExit2 = TextEditingController();

  bool _isFullDay = false;
  double _eventMultiplier = 1.5;

  @override
  void dispose() {
    _controllerDate.dispose();
    _controllerDescription.dispose();
    _controllerEntry.dispose();
    _controllerExit.dispose();
    _controllerEntry2.dispose();
    _controllerExit2.dispose();
    super.dispose();
  }

  String? _validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Insira a descrição da atividade';
    }

    return null;
  }

  int _workedMinutesFromRange(String entry, String exit) {
    final entryMinutes = Utils.parseHourMinuteToMinutes(entry);
    final exitMinutes = Utils.parseHourMinuteToMinutes(exit);
    if (entryMinutes < 0 || exitMinutes < 0) {
      return 0;
    }
    if (exitMinutes <= entryMinutes) {
      return 0;
    }
    return exitMinutes - entryMinutes;
  }

  int get _workedMinutes {
    var total = _workedMinutesFromRange(
      _controllerEntry.text,
      _controllerExit.text,
    );

    if (_isFullDay) {
      total += _workedMinutesFromRange(
        _controllerEntry2.text,
        _controllerExit2.text,
      );
    }

    return total;
  }

  Future<void> _saveActivity() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final selectedDate =
        Utils.parseDateBr(_controllerDate.text) ?? DateTime.now();
    final entry1Dt = Utils.parseHourMinuteToDateTime(_controllerEntry.text, selectedDate)!;
    final exit1Dt = Utils.parseHourMinuteToDateTime(_controllerExit.text, selectedDate)!;
    final entry2Dt = _isFullDay
        ? Utils.parseHourMinuteToDateTime(_controllerEntry2.text, selectedDate)
        : null;
    final exit2Dt = _isFullDay
        ? Utils.parseHourMinuteToDateTime(_controllerExit2.text, selectedDate)
        : null;

    final entry = ActivityBankEntry(
      userId: CurrentUserSession.instance.currentUserId,
      dateText: _controllerDate.text,
      entryDate: selectedDate,
      createdAt: DateTime.now(),
      activityDescription: _controllerDescription.text.trim(),
      isFullDay: _isFullDay,
      eventMultiplier: _eventMultiplier,
      entry1: entry1Dt,
      exit1: exit1Dt,
      entry2: entry2Dt,
      exit2: exit2Dt,
    );

    await BankEntryDao.instance.insert(entry);
    if (!mounted) {
      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final workedHoursText = Utils.formatMinutes(_workedMinutes);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar atividade'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_left),
          onPressed: () => Navigator.pop(context),
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
                  child: Column(
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
                        validator: _validateDescription,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Descrição da atividade',
                          hintText: 'Ex.: Mutirão de vacinação',
                        ),
                      ),
                      const SizedBox(height: 18),
                      CheckboxListTile(
                        value: _isFullDay,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text('Dia inteiro'),
                        onChanged: (value) {
                          setState(() {
                            _isFullDay = value ?? false;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      if (!_isFullDay) ...[
                        TextFormField(
                          controller: _controllerEntry,
                          onChanged: (_) => setState(() {}),
                          validator: (value) {
                            return Utils.validateHourMinute(
                              value,
                              requiredField: true,
                            );
                          },
                          keyboardType: TextInputType.number,
                          inputFormatters: [Utils.hourMinuteInputFormatter()],
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Entrada',
                            hintText: '08:00',
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _controllerExit,
                          onChanged: (_) => setState(() {}),
                          validator: (value) {
                            return Utils.validateHourMinute(
                              value,
                              requiredField: true,
                            );
                          },
                          keyboardType: TextInputType.number,
                          inputFormatters: [Utils.hourMinuteInputFormatter()],
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Saída',
                            hintText: '12:00',
                          ),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _controllerEntry,
                                onChanged: (_) => setState(() {}),
                                validator: (value) {
                                  return Utils.validateHourMinute(
                                    value,
                                    requiredField: true,
                                  );
                                },
                                keyboardType: TextInputType.number,
                                inputFormatters: [Utils.hourMinuteInputFormatter()],
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Entrada 1',
                                  hintText: '08:00',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _controllerEntry2,
                                onChanged: (_) => setState(() {}),
                                validator: (value) {
                                  return Utils.validateHourMinute(
                                    value,
                                    requiredField: true,
                                  );
                                },
                                keyboardType: TextInputType.number,
                                inputFormatters: [Utils.hourMinuteInputFormatter()],
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Entrada 2',
                                  hintText: '13:00',
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
                                onChanged: (_) => setState(() {}),
                                validator: (value) {
                                  return Utils.validateHourMinute(
                                    value,
                                    requiredField: true,
                                  );
                                },
                                keyboardType: TextInputType.number,
                                inputFormatters: [Utils.hourMinuteInputFormatter()],
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Saída 1',
                                  hintText: '12:00',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _controllerExit2,
                                onChanged: (_) => setState(() {}),
                                validator: (value) {
                                  return Utils.validateHourMinute(
                                    value,
                                    requiredField: true,
                                  );
                                },
                                keyboardType: TextInputType.number,
                                inputFormatters: [Utils.hourMinuteInputFormatter()],
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Saída 2',
                                  hintText: '18:00',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 18),
                      DropdownButtonFormField<double>(
                        initialValue: _eventMultiplier,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Tipo de evento',
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
                        onChanged: (value) {
                          setState(() {
                            _eventMultiplier = value ?? 1.5;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Horas trabalhadas: $workedHoursText',
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
                          'Horas geradas: ${Utils.formatMinutes((_workedMinutes * _eventMultiplier).round())}',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveActivity,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                          child: const Text('Salvar atividade'),
                        ),
                      ),
                    ],
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
