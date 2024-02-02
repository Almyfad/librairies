import 'dart:collection';
import 'dart:html';

import 'package:librairies/src/keycloakAuth/keycloakRedirection/platform_impl/storage/storage.base.dart';

class StorageImpl extends BaseStorage implements MapBase<String, String> {
  @override
  String? operator [](Object? key) {
    return window.localStorage[key];
  }

  @override
  void operator []=(String key, String value) {
    window.localStorage[key] = value;
  }

  @override
  void addAll(Map<String, String> other) {}

  @override
  void addEntries(Iterable<MapEntry<String, String>> newEntries) {}

  @override
  Map<RK, RV> cast<RK, RV>() {
    throw UnimplementedError();
  }

  @override
  void clear() {
    window.localStorage.clear();
  }

  @override
  bool containsKey(Object? key) {
    return window.localStorage.containsKey(key);
  }

  @override
  bool containsValue(Object? value) {
    return window.localStorage.containsValue(value);
  }

  @override
  Iterable<MapEntry<String, String>> get entries => throw UnimplementedError();

  @override
  void forEach(void Function(String key, String value) action) {}

  @override
  bool get isEmpty => window.localStorage.isEmpty;

  @override
  bool get isNotEmpty => window.localStorage.isNotEmpty;

  @override
  Iterable<String> get keys => throw UnimplementedError();

  @override
  int get length => throw UnimplementedError();

  @override
  Map<K2, V2> map<K2, V2>(
      MapEntry<K2, V2> Function(String key, String value) transform) {
    throw UnimplementedError();
  }

  @override
  String putIfAbsent(String key, String Function() ifAbsent) {
    throw UnimplementedError();
  }

  @override
  String? remove(Object? key) {
    return window.localStorage.remove(key);
  }

  @override
  void removeWhere(bool Function(String key, String value) test) {
    throw UnimplementedError();
  }

  @override
  String update(String key, String Function(String value) update,
      {String Function()? ifAbsent}) {
    throw UnimplementedError();
  }

  @override
  void updateAll(String Function(String key, String value) update) {}

  @override
  Iterable<String> get values => window.localStorage.values;
}
