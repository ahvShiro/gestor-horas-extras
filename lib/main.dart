import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gestor_horas_extras/core/app_routes.dart';

import 'features/authentication/presentation/screens/login_screen.dart';
import 'features/authentication/presentation/screens/password_recover_screen.dart';
import 'features/authentication/presentation/screens/reset_password_screen.dart';
import 'features/authentication/presentation/screens/sign_up_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestão de Horas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.passwordRecovery: (context) => const PasswordRecoverScreen(),
        AppRoutes.passwordRecoveryNew: (context) => const ResetPasswordScreen(),
        AppRoutes.signUp: (context) => const SignUpScreen(),
      },
      home: const LoginScreen(),
    );
  }
}
