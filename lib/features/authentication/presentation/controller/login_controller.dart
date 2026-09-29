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
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.login(email: email, password: password);

      return true;
    } on LoginException catch (e) {
      errorMessage = e.message;
      return false;
    } catch (_) {
      errorMessage = 'Não foi possível entrar. Tente novamente.';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
