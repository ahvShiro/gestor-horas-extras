import 'package:flutter/material.dart';
import 'package:gestor_horas_extras/features/authentication/data/exceptions/signup_exception.dart';
import 'package:gestor_horas_extras/features/authentication/data/services/auth_service.dart';
import 'package:gestor_horas_extras/features/authentication/domain/repositories/workplace_repository.dart';

import '../../../../core/models/work_place.dart';
import '../../data/repositories/firestore_workplace_repository.dart';

class SignUpController extends ChangeNotifier {
  SignUpController({
    WorkplaceRepository? workplaceRepository,
    AuthService? authService,
  }) : _workplaceRepository =
           workplaceRepository ?? FirestoreWorkplaceRepository(),
       _authService = authService ?? AuthService();

  final WorkplaceRepository _workplaceRepository;
  final AuthService _authService;

  List<Workplace> workplaces = [];
  Workplace? selectedWorkplace;

  bool isLoading = false;
  String? errorMessage;

  Future<void> loadWorkspaces() async {
    isLoading = true;
    notifyListeners();

    workplaces = await _workplaceRepository.getAll();

    isLoading = false;
    notifyListeners();
  }

  void selectWorkplace(Workplace? workplace) {
    selectedWorkplace = workplace;
    notifyListeners();
  }

  Future<bool> createAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    if (selectedWorkplace == null) return false;

    try {
      await _authService.signup(
        email: email,
        password: password,
        name: name,
        workplaceId: selectedWorkplace!.uid,
      );
      return true;
    } on SignupException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }
}
