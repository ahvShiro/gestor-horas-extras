import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/bank_entry_repository.dart';
import '../models/bank_entry.dart';

class FirestoreBankEntryRepository implements BankEntryRepository {
  final _db = FirebaseFirestore.instance
      .collection('bank_entries')
      .withConverter(
        fromFirestore: (snapshot, _) =>
            BankEntry.fromMap(snapshot.data()!, snapshot.id),
        toFirestore: (bankEntry, _) => bankEntry.toMap(),
      );

  Query<BankEntry> _fromUser(String userId) => _db
      .where('userId', isEqualTo: userId)
      .orderBy('registeredDate', descending: true);

  @override
  Future<void> save(BankEntry entry) async {
    await _db.doc(entry.uid.isEmpty ? null : entry.uid).set(entry);
  }

  @override
  Future<void> delete(String id) async {
    await _db.doc(id).delete();
  }

  @override
  Future<List<BankEntry>> getAllFromUser(String userId) async {
    final snapshot = await _fromUser(userId).get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Stream<List<BankEntry>> watchAllFromUser(String userId) {
    return _fromUser(userId).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
    );
  }
}
