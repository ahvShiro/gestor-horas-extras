import 'package:flutter/material.dart';
import 'package:gestor_horas_extras/common_widgets/app_snack_bar.dart';
import 'package:gestor_horas_extras/common_widgets/primary_bottom_button.dart';
import 'package:gestor_horas_extras/core/utils.dart';
import 'package:gestor_horas_extras/features/authentication/presentation/controller/login_controller.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _controller = LoginController();

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final status = await _controller.authenticateUser(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (status) {
      _redirect();
      return;
    }

    final message = _controller.errorMessage;

    if (message != null) {
      AppSnackBar.showError(context, message);
    }
  }

  void _redirect() {
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Entre na sua conta:',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 4),

              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => context.go("/sign_up"),
                  child: const Text(
                    'Não tem uma conta? Cadastre-se aqui',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Form(
                key: _formKey,
                child: ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) {
                    return Column(
                      children: <Widget>[
                        TextFormField(
                          validator: (value) => Utils.validateEmail(value),
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !_controller.loading,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Email',
                            hintText: 'Insira seu email',
                          ),
                        ),

                        const SizedBox(height: 18),

                        TextFormField(
                          validator: (value) =>
                              value == null || value.trim() == ''
                              ? "Insira uma senha"
                              : null,
                          obscureText: true,
                          controller: _passwordController,
                          enabled: !_controller.loading,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Senha',
                            hintText: 'Insira sua senha',
                          ),
                        ),

                        const SizedBox(height: 20),

                        PrimaryBottomButton(
                          label: 'Entrar',
                          onPressed: _login,
                          isLoading: _controller.loading,
                        ),
                      ],
                    );
                  },
                ),
              ),

              // const SizedBox(height: 16),
              //
              // Align(
              //   alignment: Alignment.centerLeft,
              //   child: GestureDetector(
              //     onTap: () => context.go("/forgot-password"),
              //     child: const Text(
              //       'Esqueci a senha',
              //       style: TextStyle(fontSize: 16, color: Colors.blue),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
