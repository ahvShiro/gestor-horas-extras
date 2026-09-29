import 'package:gestor_horas_extras/core/models/app_user.dart';

abstract interface class AppUserRepository {
  Future<void> save(AppUser user);
}
