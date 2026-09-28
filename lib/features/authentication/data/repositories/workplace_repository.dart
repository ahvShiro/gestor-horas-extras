import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/models/work_place.dart';

class WorkplaceRepository {
  final _db = FirebaseFirestore.instance
      .collection('workplaces')
      .withConverter(
        fromFirestore: (snapshot, _) =>
            Workplace.fromMap(snapshot.data()!, snapshot.id),
        toFirestore: (workplace, _) => workplace.toMap(),
      );

  Future<List<Workplace>> getAll() async {
    final snapshot = await _db.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
