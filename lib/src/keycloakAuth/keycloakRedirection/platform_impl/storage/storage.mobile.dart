import 'dart:collection';

import 'package:librairies/src/keycloakAuth/keycloakRedirection/platform_impl/storage/keycloak.storage.dart';
import 'package:librairies/src/keycloakAuth/keycloakRedirection/platform_impl/storage/storage.base.dart';

class StorageImpl extends BaseStorage implements MapBase<Keys, String> {
  static Map<Keys, String> storage = {};

  @override
  String? operator [](Object? key) {
    return StorageImpl.storage[key];
  }

  @override
  void operator []=(Keys key, String value) {
    StorageImpl.storage[key] = value;
  }

  @override
  void addAll(Map<Keys, String> other) {
    StorageImpl.storage.addAll(other);
  }

  @override
  void addEntries(Iterable<MapEntry<Keys, String>> newEntries) {
    StorageImpl.storage.addEntries(newEntries);
  }

  @override
  Map<RK, RV> cast<RK, RV>() {
    throw UnimplementedError();
  }

  @override
  void clear() {
    StorageImpl.storage.clear();
  }

  @override
  bool containsKey(Object? key) {
    return StorageImpl.storage.containsKey(key);
  }

  @override
  bool containsValue(Object? value) {
    return StorageImpl.storage.containsValue(value);
  }

  @override
  Iterable<MapEntry<Keys, String>> get entries => StorageImpl.storage.entries;

  @override
  void forEach(void Function(Keys key, String value) action) {
    StorageImpl.storage.forEach((key, value) {
      action(key, value);
    });
  }

  @override
  bool get isEmpty => StorageImpl.storage.isEmpty;

  @override
  bool get isNotEmpty => StorageImpl.storage.isNotEmpty;

  @override
  Iterable<Keys> get keys => StorageImpl.storage.keys;

  @override
  int get length => StorageImpl.storage.length;

  @override
  Map<K2, V2> map<K2, V2>(
      MapEntry<K2, V2> Function(Keys key, String value) transform) {
    return StorageImpl.storage.map((key, value) => transform(key, value));
  }

  @override
  String putIfAbsent(Keys key, String Function() ifAbsent) {
    return StorageImpl.storage.putIfAbsent(key, () => ifAbsent());
  }

  @override
  String? remove(Object? key) {
    return StorageImpl.storage.remove(key);
  }

  @override
  void removeWhere(bool Function(Keys key, String value) test) {
    StorageImpl.storage.removeWhere((key, value) => test(key, value));
  }

  @override
  String update(Keys key, String Function(String value) update,
      {String Function()? ifAbsent}) {
    return StorageImpl.storage.update(key, (value) => update(value));
  }

  @override
  void updateAll(String Function(Keys key, String value) update) {
    StorageImpl.storage.updateAll((key, value) => update(key, value));
  }

  @override
  Iterable<String> get values => StorageImpl.storage.values;
}
