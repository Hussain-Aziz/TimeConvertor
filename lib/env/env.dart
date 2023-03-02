import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'MAP_API', obfuscate: true)
  static final mapAPI = _Env.mapAPI;
  @EnviedField(varName: 'TIMEZONEDB_API', obfuscate: true)
  static final timeZoneDBAPI = _Env.timeZoneDBAPI;
}
