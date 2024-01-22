import 'dart:math';

import 'package:librairies/src/keycloakAuth/keycloakRedirection/platform_impl/storage/storage.stub.dart'
    if (dart.library.io) 'package:librairies/src/keycloakAuth/keycloakRedirection/platform_impl/storage/storage.mobile.dart'
    if (dart.library.html) 'package:librairies/src/keycloakAuth/keycloakRedirection/platform_impl/storage/storage.web.dart';



class KeyclockLocalStorage {
  static KeyclockLocalStorage? _instance;

  final StorageImpl? storage;

  KeyclockLocalStorage({this.storage});

  static StorageImpl get instance {
     _instance ??= KeyclockLocalStorage(storage: StorageImpl());
     return _instance!.storage!;
  }

  static bool get isAcessTokenReady =>
      Keys.accesstoken.exist &&
      Keys.accesstoken.value != null &&
      (Keys.accesstoken.value?.isNotEmpty ?? false);
  static String get currentCodeVerifier =>
      Keys.codePKCEVerifier.value ?? newcodeVerifier;

  static String get newcodeVerifier {
    const String charset =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    return Keys.codePKCEVerifier.value = List.generate(
      128,
      (i) => charset[Random.secure().nextInt(charset.length)],
    ).join();
  }
}

enum Keys {
  accesstoken("acess_token"),
  refreshtoken("refresh_token"),
  codePKCEVerifier("cvpkce"),
  expiration("expiration");

  const Keys(this.key);
  final String key;

  bool get exist => KeyclockLocalStorage.instance.containsKey(key);
  String? get value => KeyclockLocalStorage.instance[key];
  void get reset => KeyclockLocalStorage.instance.remove(key);
  DateTime? get getDate => _convertDateTime(KeyclockLocalStorage.instance[key]);

  DateTime? _convertDateTime(String? value) => value == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(int.parse(value));

  set value(String? value) => KeyclockLocalStorage.instance[this] = value ?? "";
  set setDate(DateTime? value) =>
      KeyclockLocalStorage.instance[this] = value?.millisecondsSinceEpoch.toString() ?? "NaN";
}
