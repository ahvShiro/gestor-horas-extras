import 'package:flutter/material.dart';
import 'package:gestor_horas_extras/core/app_routes.dart';

import '../../../../common_widgets/primary_bottom_button.dart';
import '../widgets/auth_screen_section.dart';
import '../widgets/auth_text_form_field.dart';

class PasswordRecoverScreen extends StatefulWidget {
  const PasswordRecoverScreen({super.key});

  @override
  State<PasswordRecoverScreen> createState() => _PasswordRecoverScreenState();
}

class _PasswordRecoverScreenState extends State<PasswordRecoverScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controllerUsername = TextEditingController();

  @override
  void dispose() {
    _controllerUsername.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Senha'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_left),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AuthScreenSection(
                title: 'Recuperar Senha',
                subtitle: const Text(
                  'Para redefinição da senha, insira seu nome de usuário:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AuthTextFormField(
                        controller: _controllerUsername,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Insira seu nome de usuário';
                          }
                          return null;
                        },
                        labelText: 'Usuário',
                        hintText: 'Insira seu nome de usuário',
                      ),
                      const SizedBox(height: 20),
                      PrimaryBottomButton(
                        label: 'Prosseguir',
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Seu email está correto?'),
                                content: Text.rich(
                                  TextSpan(
                                    text: 'Seu email é ',
                                    children: [
                                      TextSpan(
                                        text: '"usua******@gm***.com"',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: '? (ocultado para privacidade)',
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.login,
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Contate o suporte para alterar seu email',
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text('Não'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.passwordRecoveryNew,
                                      );
                                    },
                                    child: const Text('Sim'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
