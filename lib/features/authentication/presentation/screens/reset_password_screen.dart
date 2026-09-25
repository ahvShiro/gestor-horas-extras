import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gestor_horas_extras/common_widgets/secondary_bottom_button.dart';
import 'package:gestor_horas_extras/core/app_routes.dart';
import 'package:gestor_horas_extras/core/utils.dart';

import '../../../../common_widgets/primary_bottom_button.dart';
import '../widgets/auth_screen_section.dart';
import '../widgets/auth_text_form_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controllerCode = TextEditingController();
  final _controllerNewPassword = TextEditingController();
  final _controllerRepeatNewPassword = TextEditingController();

  @override
  void dispose() {
    _controllerCode.dispose();
    _controllerNewPassword.dispose();
    _controllerRepeatNewPassword.dispose();
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
                  'Um email com o código de redefinição foi enviado para você. Caso o email nao chegue, cheque a caixa de spam ou envie novamente.',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AuthTextFormField(
                        controller: _controllerCode,
                        keyboardType: const TextInputType.numberWithOptions(),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Insira o código';
                          }
                          if (value.length != 6) {
                            return 'Código incorreto. Verifique e digite novamente';
                          }
                          return null;
                        },
                        labelText: 'Código',
                        hintText: 'Insira o código',
                      ),
                      const SizedBox(height: 18),
                      AuthTextFormField(
                        controller: _controllerNewPassword,
                        validator: Utils.validatePassword,
                        labelText: 'Senha nova',
                        hintText: 'Insira a senha nova',
                        obscureText: true,
                      ),
                      const SizedBox(height: 18),
                      AuthTextFormField(
                        controller: _controllerRepeatNewPassword,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Repita a senha nova';
                          }
                          if (value != _controllerNewPassword.text) {
                            return 'As senhas devem ser iguais';
                          }
                          return null;
                        },
                        labelText: 'Repita a senha nova',
                        hintText: 'Repita a senha nova',
                      ),
                      const SizedBox(height: 20),
                      SecondaryBottomButton(
                        label: 'Reenviar código',
                        onPressed: () {},
                      ),
                      const SizedBox(height: 12),
                      PrimaryBottomButton(
                        label: 'Alterar Senha',
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.bankHoursHome,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Senha alterada com sucesso'),
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
