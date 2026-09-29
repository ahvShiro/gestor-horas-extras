import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestor_horas_extras/features/authentication/domain/repositories/app_user_repository.dart';

import '../../../../core/models/app_user.dart';

class FirestoreAppUserRepository implements AppUserRepository {
  final _db = FirebaseFirestore.instance
      .collection('users')
      .withConverter(
        fromFirestore: (snapshot, _) =>
            AppUser.fromMap(snapshot.data()!, snapshot.id),
        toFirestore: (appUser, _) => appUser.toMap(),
      );

  @override
  Future<void> save(AppUser user) async {
    await _db.add(user);
  }
}
