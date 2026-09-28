import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestor_horas_extras/core/models/app_user.dart';
import 'package:gestor_horas_extras/features/authentication/data/repositories/app_user_repository.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = AppUserRepository();

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

      await _db.save(user);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          throw Exception('Senha fraca');
        case 'email-already-in-use':
          throw Exception('Email já cadastrado');
        default:
          throw Exception('Erro ao criar a conta');
      }
    }
  }
}
