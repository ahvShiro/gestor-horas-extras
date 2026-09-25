import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestor_horas_extras/core/models/work_place.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.workPlace,
  });

  final String uid;
  final String fullName;
  final String email;
  final WorkPlace workPlace;

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'workPlace': workPlace.toMap(),
    };
  }

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> map) {
    final data = map.data()!;

    return AppUser(
      uid: map.id,
      fullName: data['fullName'] as String,
      email: data['email'] as String,
      workPlace: WorkPlace.fromMap(data['workPlace'] as Map<String, dynamic>),
    );
  }
}
