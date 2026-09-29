import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestor_horas_extras/core/models/app_user.dart';
import 'package:gestor_horas_extras/features/authentication/data/repositories/firestore_app_user_repository.dart';
import 'package:gestor_horas_extras/features/authentication/domain/repositories/app_user_repository.dart';

import '../exceptions/signup_exception.dart';

class AuthService {
  AuthService({AppUserRepository? userRepository})
    : _userRepository = userRepository ?? FirestoreAppUserRepository();

  final _auth = FirebaseAuth.instance;
  final AppUserRepository _userRepository;

  Future<void> signup({
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
          throw SignupException('Senha fraca');
        case 'email-already-in-use':
          throw SignupException('Email já cadastrado');
        default:
          throw SignupException('Erro ao criar a conta');
      }
    }
  }
}
