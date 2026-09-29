import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/models/work_place.dart';
import '../../domain/repositories/workplace_repository.dart';

class FirestoreWorkplaceRepository implements WorkplaceRepository {
  final _db = FirebaseFirestore.instance
      .collection('workplaces')
      .withConverter(
        fromFirestore: (snapshot, _) =>
            Workplace.fromMap(snapshot.data()!, snapshot.id),
        toFirestore: (workplace, _) => workplace.toMap(),
      );

  @override
  Future<List<Workplace>> getAll() async {
    final snapshot = await _db.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
