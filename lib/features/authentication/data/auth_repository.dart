import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestor_horas_extras/core/models/work_place.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signup({
    required String email,
    required String password,
    required String name,
    required WorkPlace workplace,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print(userCredential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('Senha fraca!!!');
      } else if (e.code == 'email-already-in-use') {
        print('Email já cadastrado!!!');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> login({required String email, required String password}) async {}

  Future<void> resetPassword() async {}
}
