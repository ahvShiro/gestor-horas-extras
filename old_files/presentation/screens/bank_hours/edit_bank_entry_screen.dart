import 'package:flutter/material.dart';
import 'package:gestor_horas_extras/core/current_user_session.dart';
import 'package:gestor_horas_extras/core/utils.dart';
import 'package:gestor_horas_extras/data/local/bank_entry_dao.dart';
import 'package:gestor_horas_extras/domain/entities/bank_entry.dart';

class EditBankEntryScreen extends StatefulWidget {
  const EditBankEntryScreen({super.key, required this.entry});

  final BankEntry entry;

  @override
  State<EditBankEntryScreen> createState() => _EditBankEntryScreenState();
}

class _EditBankEntryScreenState extends State<EditBankEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controllerDate = TextEditingController();
  final _controllerDescription = TextEditingController();
  final _controllerEntry = TextEditingController();
  final _controllerExit = TextEditingController();
  final _controllerEntry2 = TextEditingController();
  final _controllerExit2 = TextEditingController();
  final _controllerHours = TextEditingController();
  final _controllerObservation = TextEditingController();

  bool _isFullDay = false;
  double _eventMultiplier = 1.5;
  bool _isLoading = true;

  bool get _isActivity => widget.entry is ActivityBankEntry;

  @override
  void initState() {
    super.initState();
    _loadInitialValues();
  }

  @override
  void dispose() {
    _controllerDate.dispose();
    _controllerDescription.dispose();
    _controllerEntry.dispose();
    _controllerExit.dispose();
    _controllerEntry2.dispose();
    _controllerExit2.dispose();
    _controllerHours.dispose();
    _controllerObservation.dispose();
    super.dispose();
  }

  void _loadInitialValues() {
    if (_isActivity) {
      final entry = widget.entry as ActivityBankEntry;
      _controllerDate.text = entry.dateText;
      _controllerDescription.text = entry.activityDescription;
      _isFullDay = entry.isFullDay;
      _eventMultiplier = entry.eventMultiplier;
      _controllerEntry.text = Utils.formatTime(entry.entry1);
      _controllerExit.text = Utils.formatTime(entry.exit1);
      _controllerEntry2.text = Utils.formatTime(entry.entry2);
      _controllerExit2.text = Utils.formatTime(entry.exit2);
    } else {
      final entry = widget.entry as DayOffBankEntry;
      _controllerDate.text = entry.dateText;
      final hm = entry.hoursMinutes;
      final h = (hm ~/ 60).toString().padLeft(2, '0');
      final m = (hm % 60).toString().padLeft(2, '0');
      _controllerHours.text = '$h:$m';
      _controllerObservation.text = entry.observation ?? '';
    }

    setState(() {
      _isLoading = false;
    });
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

  String? _validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Insira a descrição da atividade';
    }

    return null;
  }

  String? _validateDate(String? value) => Utils.validateDateBr(value);

  String? _validateHourMinute(String? value) {
    return Utils.validateHourMinute(value, requiredField: true);
  }

  String? _validateHours(String? value) {
    final validation = Utils.validateHourMinute(
      value,
      requiredField: true,
      requiredMessage: 'Insira a quantidade de horas',
    );
    if (validation != null) {
      return validation;
    }

    final minutes = Utils.parseHourMinuteToMinutes(value ?? '');
    if (minutes <= 0) {
      return 'A quantidade deve ser maior que 00:00';
    }

    return null;
  }

  Future<void> _saveChanges() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final selectedDate =
        Utils.parseDateBr(_controllerDate.text) ?? widget.entry.entryDate;

    final updatedEntry = _isActivity
        ? ActivityBankEntry(
            id: widget.entry.id,
            userId: CurrentUserSession.instance.currentUserId,
            dateText: _controllerDate.text,
            entryDate: selectedDate,
            createdAt: widget.entry.createdAt,
            sortOrder: widget.entry.sortOrder,
            activityDescription: _controllerDescription.text.trim(),
            isFullDay: _isFullDay,
            eventMultiplier: _eventMultiplier,
        entry1: Utils.parseHourMinuteToDateTime(_controllerEntry.text, selectedDate)!,
        exit1: Utils.parseHourMinuteToDateTime(_controllerExit.text, selectedDate)!,
        entry2: _isFullDay ? Utils.parseHourMinuteToDateTime(_controllerEntry2.text, selectedDate) : null,
        exit2: _isFullDay ? Utils.parseHourMinuteToDateTime(_controllerExit2.text, selectedDate) : null,
          )
        : DayOffBankEntry(
            id: widget.entry.id,
            userId: CurrentUserSession.instance.currentUserId,
            dateText: _controllerDate.text,
            entryDate: selectedDate,
            createdAt: widget.entry.createdAt,
            sortOrder: widget.entry.sortOrder,
        hoursMinutes: Utils.parseHourMinuteToMinutes(_controllerHours.text),
            observation: _controllerObservation.text.trim().isEmpty
                ? null
                : _controllerObservation.text.trim(),
          );

    try {
      await BankEntryDao.instance.update(updatedEntry);
      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar as alterações')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_isActivity ? 'Editar atividade' : 'Editar folga'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_left),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isActivity ? 'Editar atividade' : 'Editar folga'),
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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _isActivity ? 'Edite a atividade:' : 'Edite a folga:',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _controllerDate,
                    validator: _validateDate,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: _isActivity
                          ? 'Data da atividade'
                          : 'Data da folga',
                      hintText: 'dd/MM/aaaa',
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (_isActivity) ...[
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
                        validator: _validateHourMinute,
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
                        validator: _validateHourMinute,
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
                              validator: _validateHourMinute,
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
                              validator: _validateHourMinute,
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
                              validator: _validateHourMinute,
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
                              validator: _validateHourMinute,
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
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Horas trabalhadas: ${Utils.formatMinutes(_workedMinutes)}',
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
                  ] else ...[
                    TextFormField(
                      controller: _controllerHours,
                      onChanged: (_) => setState(() {}),
                      validator: _validateHours,
                      keyboardType: TextInputType.number,
                      inputFormatters: [Utils.hourMinuteInputFormatter()],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Quantidade de horas',
                        hintText: 'Ex.: 01:30',
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _controllerObservation,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Observação',
                        hintText: 'Opcional',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Horas registradas: ${_controllerHours.text}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isActivity
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                      child: const Text('Salvar alterações'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
