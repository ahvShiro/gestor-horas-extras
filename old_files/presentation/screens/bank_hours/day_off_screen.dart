import 'package:flutter/material.dart';
import 'package:gestor_horas_extras/core/current_user_session.dart';
import 'package:gestor_horas_extras/core/utils.dart';
import 'package:gestor_horas_extras/data/local/bank_entry_dao.dart';
import 'package:gestor_horas_extras/domain/entities/bank_entry.dart';

class DayOff extends StatefulWidget {
  const DayOff({super.key});

  @override
  State<DayOff> createState() => _DayOffState();
}

class _DayOffState extends State<DayOff> {
  final _formKey = GlobalKey<FormState>();
  final _controllerDate = TextEditingController(
    text: Utils.formatDate(DateTime.now()),
  );
  final _controllerHours = TextEditingController();
  final _controllerObservation = TextEditingController();

  int _currentBankMinutes = 0;
  bool _isLoadingBankMinutes = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentBankMinutes();
  }

  Future<void> _loadCurrentBankMinutes() async {
    final entries = await BankEntryDao.instance.findByUserId(
      CurrentUserSession.instance.currentUserId,
    );
    final totalMinutes = entries.fold<int>(0, (total, entry) {
      return total + entry.amountMinutes;
    });

    if (!mounted) {
      return;
    }

    setState(() {
      _currentBankMinutes = totalMinutes;
      _isLoadingBankMinutes = false;
    });
  }

  @override
  void dispose() {
    _controllerDate.dispose();
    _controllerHours.dispose();
    _controllerObservation.dispose();
    super.dispose();
  }

  String? _validateDate(String? value) {
    final result = Utils.validateDateBr(value);
    if (result != null) {
      return result == 'Insira a data' ? 'Insira a data da folga' : result;
    }

    return null;
  }

  String? _validateHours(String? value) {
    final hourValidation = Utils.validateHourMinute(
      value,
      requiredField: true,
      requiredMessage: 'Insira a quantidade de horas',
    );
    if (hourValidation != null) {
      return hourValidation;
    }

    final requestedMinutes = Utils.parseHourMinuteToMinutes(value ?? '');
    if (requestedMinutes <= 0) {
      return 'A quantidade deve ser maior que 00:00';
    }

    if (requestedMinutes > _currentBankMinutes) {
      return 'A quantidade de folga não pode ser maior que o banco atual';
    }

    return null;
  }

  String? _validateObservation(String? value) {
    return null;
  }

  Future<void> _saveDayOff() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final selectedDate =
        Utils.parseDateBr(_controllerDate.text) ?? DateTime.now();
    final entry = DayOffBankEntry(
      userId: CurrentUserSession.instance.currentUserId,
      dateText: _controllerDate.text,
      entryDate: selectedDate,
      createdAt: DateTime.now(),
      hoursMinutes: Utils.parseHourMinuteToMinutes(_controllerHours.text),
      observation: _controllerObservation.text.trim().isEmpty
          ? null
          : _controllerObservation.text.trim(),
    );

    await BankEntryDao.instance.insert(entry);
    if (!mounted) {
      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingBankMinutes) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Registrar folga'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_left),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final parsedMinutes = Utils.parseHourMinuteToMinutes(_controllerHours.text);
    final requestedMinutes = parsedMinutes < 0 ? 0 : parsedMinutes;
    final afterLeaveMinutes = _currentBankMinutes - requestedMinutes;

    final bankCurrentText = Utils.formatMinutes(_currentBankMinutes);
    final afterLeaveText = Utils.formatMinutes(afterLeaveMinutes);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar folga'),
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
                    'Registre a folga:',
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
                        validator: _validateDate,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Data da folga',
                          hintText: 'dd/MM/aaaa',
                        ),
                      ),
                      const SizedBox(height: 18),
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
                        validator: _validateObservation,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Observação',
                          hintText: 'Opcional',
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Banco atual: $bankCurrentText',
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
                          'Apos folga: $afterLeaveText',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveDayOff,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
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
      ),
    );
  }
}
