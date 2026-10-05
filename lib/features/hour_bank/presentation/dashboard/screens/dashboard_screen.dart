import 'package:flutter/material.dart';

import '../controllers/dashboard_controller.dart';
import '../widgets/bank_entries_listing.dart';
import '../widgets/total_hours_indicator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _controller = BankHoursHomeController();

  @override
  void initState() {
    super.initState();
    _controller.start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            if (_controller.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            final errorMessage = _controller.errorMessage;
            if (errorMessage != null && _controller.entries.isEmpty) {
              return Center(
                child: Text(
                  '$errorMessage\nEntre em contato com o suporte',
                  style: TextStyle(color: Colors.red.shade700, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return Column(
              children: [
                TotalHoursIndicator(controller: _controller),
                const SizedBox(height: 22),
                BankEntriesListing(controller: _controller),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }
}
