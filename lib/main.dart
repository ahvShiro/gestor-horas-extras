import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gestor_horas_extras/features/authentication/presentation/screens/login_screen.dart';
import 'package:gestor_horas_extras/features/authentication/presentation/screens/sign_up_screen.dart';
import 'package:gestor_horas_extras/features/authentication/presentation/screens/test_screen.dart';
import 'package:gestor_horas_extras/features/hour_bank/presentation/dashboard/screens/dashboard_screen.dart';
import 'package:gestor_horas_extras/features/hour_bank/presentation/register_overtime/screens/overtime_screen.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => LoginScreen()),
    GoRoute(path: '/sign_up', builder: (context, state) => SignUpScreen()),
    GoRoute(path: '/test', builder: (context, state) => TestScreen()),
    GoRoute(path: '/dashboard', builder: (context, state) => DashboardScreen()),
    GoRoute(path: '/overtime', builder: (context, state) => OvertimeScreen()),
  ],
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Gestão de Horas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
