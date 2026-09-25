import 'package:cloud_firestore/cloud_firestore.dart';

class WorkPlace {
  const WorkPlace({
    required this.name,
    required this.description,
    required this.uid,
  });

  final String uid;
  final String name;
  final String description;

  Map<String, dynamic> toMap() {
    return {'uid': uid, 'name': name, 'description': description};
  }

  factory WorkPlace.fromMap(Map<String, dynamic> map) => WorkPlace(
    uid: map['uid'] as String,
    name: map['name'] as String,
    description: map['description'] as String,
  );

  factory WorkPlace.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) =>
      WorkPlace.fromMap(doc.data()!);
}
