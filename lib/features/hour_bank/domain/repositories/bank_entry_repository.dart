import '../../data/models/bank_entry.dart';

abstract interface class BankEntryRepository {
  Future<void> save(BankEntry entry);
  Future<void> delete(String id);
  Future<List<BankEntry>> getAllFromUser(String userId);
  Stream<List<BankEntry>> watchAllFromUser(String userId);
}
