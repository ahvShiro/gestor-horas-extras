import 'package:flutter/material.dart';
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

    if (status) _redirect();
  }

  void _redirect() {
    context.go('/test');
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
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      validator: (value) => Utils.validateEmail(value),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                        hintText: 'Insira seu email',
                      ),
                    ),

                    const SizedBox(height: 18),

                    TextFormField(
                      validator: (value) => value == null || value.trim() == ''
                          ? "Insira uma senha"
                          : null,
                      obscureText: true,
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Senha',
                        hintText: 'Insira sua senha',
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _login(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                        child: const Text(
                          'Entrar',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => context.go("/forgot-password"),
                  child: const Text(
                    'Esqueci a senha',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
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
