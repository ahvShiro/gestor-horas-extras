import 'package:flutter/material.dart';

class BankHoursHome extends StatefulWidget {
  const BankHoursHome({super.key});

  @override
  State<BankHoursHome> createState() => _BankHoursHomeState();
}

class _BankHoursHomeState extends State<BankHoursHome> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banco de Horas'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          children: [const SizedBox(height: 22), const SizedBox(height: 16)],
        ),
      ),
    );
  }
}
