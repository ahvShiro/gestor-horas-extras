import 'package:gestor_horas_extras/core/models/work_place.dart';

abstract interface class WorkplaceRepository {
  Future<List<Workplace>> getAll();
}
