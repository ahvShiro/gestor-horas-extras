import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gestor_horas_extras/core/app_routes.dart';
import 'package:gestor_horas_extras/core/current_user_session.dart';
import 'package:gestor_horas_extras/core/utils.dart';
import 'package:gestor_horas_extras/data/local/bank_entry_dao.dart';
import 'package:gestor_horas_extras/domain/entities/bank_entry.dart';
import 'package:gestor_horas_extras/presentation/screens/bank_hours/edit_bank_entry_screen.dart';

class BankHoursHome extends StatefulWidget {
  const BankHoursHome({super.key});

  @override
  State<BankHoursHome> createState() => _BankHoursHomeState();
}

class _BankHoursHomeState extends State<BankHoursHome> {
  late Future<List<BankEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _entriesFuture = _loadEntries();
  }

  Future<List<BankEntry>> _loadEntries() async {
    return BankEntryDao.instance.findByUserId(
      CurrentUserSession.instance.currentUserId,
    );
  }

  int _balanceMinutes(List<BankEntry> entries) {
    return entries.fold<int>(0, (total, entry) => total + entry.amountMinutes);
  }

  String _formatSignedMinutes(int minutes) {
    final sign = minutes >= 0 ? '' : '-';
    return '$sign${Utils.formatMinutes(minutes.abs())}';
  }

  Future<void> _refresh() async {
    setState(() {
      _entriesFuture = _loadEntries();
    });
  }

  Future<void> _openAndRefresh(Future<dynamic> navigation) async {
    await navigation;
    await _refresh();
  }

  Future<void> _openUserEdit() async {
    await _openAndRefresh(Navigator.pushNamed(context, AppRoutes.editUser));
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sair da conta'),
          content: const Text(
            'Tem certeza que deseja sair da conta? Você será redirecionado para a tela de login.',
          ),
          actions: [
             TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    CurrentUserSession.instance.clear();
    if (!mounted) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  Future<void> _openEntryEdit(BankEntry entry) async {
    await _openAndRefresh(
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditBankEntryScreen(entry: entry),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteEntry(BankEntry entry) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir registro'),
          content: const Text(
            'Tem certeza que deseja excluir este registro? Esta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || entry.id == null) {
      return;
    }

    await BankEntryDao.instance.deleteById(entry.id!);
    if (!mounted) {
      return;
    }

    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banco de Horas'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit_user') {
                _openUserEdit();
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<String>(
                  value: 'edit_user',
                  child: Text('Editar usuário'),
                ),
                PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Sair da conta'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: FutureBuilder<List<BankEntry>>(
          future: _entriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Não foi possível carregar o banco de horas',
                  style: TextStyle(color: Colors.red.shade700),
                  textAlign: TextAlign.center,
                ),
              );
            }

            final entries = snapshot.data ?? const <BankEntry>[];
            final balanceMinutes = _balanceMinutes(entries);

            return Column(
              children: [
                Text(
                  _formatSignedMinutes(balanceMinutes),
                  style: const TextStyle(
                    fontSize: 54,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text(
                  'no banco de horas',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: entries.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 120),
                              Center(
                                child: Text(
                                  'Nenhum lançamento registrado ainda',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: entries.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final entry = entries[index];
                              final isDayOff = entry.amountMinutes < 0;
                              final entryColor = isDayOff
                                  ? Colors.red.shade700
                                  : Colors.green.shade700;
                              final tileBackground = isDayOff
                                  ? Colors.red.shade50
                                  : Colors.green.shade50;

                              return Slidable(
                                key: ValueKey(
                                  entry.id ?? '${entry.entryType}-$index',
                                ),
                                endActionPane: ActionPane(
                                  motion: const DrawerMotion(),
                                  extentRatio: 0.45,
                                  children: [
                                    SlidableAction(
                                      onPressed: (_) => _openEntryEdit(entry),
                                      backgroundColor: Colors.blue.shade700,
                                      foregroundColor: Colors.white,
                                      icon: Icons.edit,
                                      label: 'Editar',
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    SlidableAction(
                                      onPressed: (_) => _confirmDeleteEntry(entry),
                                      backgroundColor: Colors.red.shade700,
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete,
                                      label: 'Excluir',
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  tileColor: tileBackground,
                                  title: Text(
                                    entry.title,
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: entryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: entry.description == null
                                      ? null
                                      : Text(
                                          entry.description!,
                                          style: TextStyle(
                                            color: entryColor.withValues(
                                              alpha: 0.8,
                                            ),
                                          ),
                                        ),
                                  trailing: Text(
                                    _formatSignedMinutes(entry.amountMinutes),
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: entryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await _openAndRefresh(
                            Navigator.pushNamed(context, AppRoutes.dayOff),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Registrar folga'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await _openAndRefresh(
                            Navigator.pushNamed(context, AppRoutes.activity),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Registrar atividade'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
