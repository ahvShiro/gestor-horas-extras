import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestor_horas_extras/core/models/app_user.dart';
import 'package:gestor_horas_extras/features/authentication/data/repositories/firestore_app_user_repository.dart';
import 'package:gestor_horas_extras/features/authentication/domain/repositories/app_user_repository.dart';

import '../exceptions/login_exception.dart';
import '../exceptions/sign_up_exception.dart';

class AuthService {
  AuthService({AppUserRepository? userRepository})
    : _userRepository = userRepository ?? FirestoreAppUserRepository();

  final _auth = FirebaseAuth.instance;
  final AppUserRepository _userRepository;

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String workplaceId,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String? uid = userCredential.user?.uid;

      if (uid == null) {
        return;
      }

      final user = AppUser(
        uid: uid,
        fullName: name,
        email: email,
        workplaceId: workplaceId,
      );

      await _userRepository.save(user);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          throw SignUpException('Senha fraca');
        case 'email-already-in-use':
          throw SignUpException('Email já cadastrado');
        default:
          throw SignUpException('Erro ao criar a conta');
      }
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'INVALID_LOGIN_CREDENTIALS':
          throw LoginException('Email ou senha incorretos');
        default:
          throw LoginException('Erro ao criar a conta');
      }
    }
  }
}
