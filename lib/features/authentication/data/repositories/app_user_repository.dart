import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestor_horas_extras/core/models/app_user.dart';

class AppUserRepository {
  final _db = FirebaseFirestore.instance
      .collection('users')
      .withConverter(
        fromFirestore: (snapshot, _) =>
            AppUser.fromMap(snapshot.data()!, snapshot.id),
        toFirestore: (appUser, _) => appUser.toMap(),
      );

  Future<DocumentReference<AppUser>> save(AppUser user) async {
    return await _db.add(user);
  }
}
