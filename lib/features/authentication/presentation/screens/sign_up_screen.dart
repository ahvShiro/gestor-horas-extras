import 'package:flutter/material.dart';
import 'package:gestor_horas_extras/common_widgets/primary_bottom_button.dart';
import 'package:gestor_horas_extras/core/models/work_place.dart';
import 'package:gestor_horas_extras/features/authentication/presentation/controller/sign_up_controller.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils.dart';
import '../widgets/auth_screen_section.dart';
import '../widgets/auth_text_form_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _controller = SignUpController();

  final _pageController = PageController();

  final _infoFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _controllerFullName = TextEditingController();
  final _controllerEmail = TextEditingController();
  final _controllerPassword = TextEditingController();
  final _controllerRepeatPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.loadWorkspaces();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controllerFullName.dispose();
    _controllerEmail.dispose();
    _controllerPassword.dispose();
    _controllerRepeatPassword.dispose();
    super.dispose();
  }

  String? _requiredField(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }

    return null;
  }

  String? _validateRepeatPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Repita sua senha';
    }

    if (value != _controllerPassword.text) {
      return 'As senhas devem ser iguais';
    }

    return null;
  }

  Future<void> _goToPasswordStep() async {
    if (!_infoFormKey.currentState!.validate()) {
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  String? _validateEmail(String? value) {
    final requiredMessage = _requiredField(value, 'Insira seu email');

    if (requiredMessage != null) {
      return requiredMessage;
    }

    if (!value!.contains('@')) {
      return 'Insira um email válido';
    }

    return null;
  }

  Future<void> _createAccount() async {
    final success = await _controller.createAccount(
      name: _controllerFullName.text,
      email: _controllerEmail.text,
      password: _controllerPassword.text,
    );
    if (success) _redirect();
  }

  void _redirect() {
    context.go("/test");
  }

  Widget _buildInfoStep() {
    return AuthScreenSection(
      title: 'Crie sua conta:',
      child: Form(
        key: _infoFormKey,
        child: Column(
          children: <Widget>[
            AuthTextFormField(
              controller: _controllerFullName,
              validator: (value) {
                return _requiredField(value, 'Insira seu nome completo');
              },
              labelText: 'Nome completo',
              hintText: 'Insira seu nome completo',
            ),

            const SizedBox(height: 18),

            AuthTextFormField(
              controller: _controllerEmail,
              keyboardType: TextInputType.emailAddress,
              validator: (value) => (_validateEmail(value)),
              labelText: 'Email',
              hintText: 'Insira seu email',
            ),

            const SizedBox(height: 18),

            DropdownButtonFormField<Workplace>(
              decoration: InputDecoration(
                labelText: 'Select an option',
                border: OutlineInputBorder(),
              ),
              initialValue: _controller.selectedWorkplace,
              items: _controller.workplaces
                  .map(
                    (workplace) => DropdownMenuItem<Workplace>(
                      value: workplace,
                      child: Text(workplace.name),
                    ),
                  )
                  .toList(),
              onChanged: _controller.selectWorkplace,
            ),

            const SizedBox(height: 20),

            PrimaryBottomButton(
              label: 'Prosseguir',
              onPressed: _goToPasswordStep,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordStep() {
    return AuthScreenSection(
      title: 'Crie sua senha:',
      child: Form(
        key: _passwordFormKey,
        child: Column(
          children: <Widget>[
            AuthTextFormField(
              controller: _controllerPassword,
              validator: Utils.validatePassword,
              labelText: 'Senha',
              hintText: 'Insira sua senha',
              obscureText: true,
            ),

            // TODO adicionar um medidor de força de senha
            const SizedBox(height: 18),

            AuthTextFormField(
              controller: _controllerRepeatPassword,
              validator: _validateRepeatPassword,
              labelText: 'Repetir a senha',
              hintText: 'Repita sua senha',
              obscureText: true,
            ),

            const SizedBox(height: 20),

            PrimaryBottomButton(
              label: 'Criar Conta',
              onPressed: _createAccount,
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Criar conta'),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.keyboard_arrow_left),
              onPressed: () {
                if (_pageController.page == null || _pageController.page == 0) {
                  context.pop();
                  return;
                }
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [_buildInfoStep(), _buildPasswordStep()],
          ),
        );
      },
    );
  }
}
