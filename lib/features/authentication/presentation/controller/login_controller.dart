import 'package:flutter/cupertino.dart';
import 'package:gestor_horas_extras/features/authentication/data/exceptions/login_exception.dart';

import '../../data/services/auth_service.dart';

class LoginController extends ChangeNotifier {
  LoginController({AuthService? authService})
    : _authService = authService ?? AuthService();

  final AuthService _authService;

  bool loading = false;
  String? errorMessage;

  Future<bool> authenticateUser({
    required String email,
    required String password,
  }) async {
    try {
      loading = true;
      notifyListeners();

      await _authService.login(email: email, password: password);

      loading = false;
      notifyListeners();

      return true;
    } on LoginException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }
}
