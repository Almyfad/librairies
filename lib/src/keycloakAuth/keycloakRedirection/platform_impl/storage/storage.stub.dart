import 'dart:collection';

import 'package:librairies/src/keycloakAuth/keycloakRedirection/platform_impl/storage/keycloak.storage.dart';
import 'package:librairies/src/keycloakAuth/keycloakRedirection/platform_impl/storage/storage.base.dart';

class StorageImpl extends BaseStorage implements MapBase<String,String> {

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}