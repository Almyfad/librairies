import 'dart:html';
import 'dart:math';


enum Keys {
  accesstoken("acess_token"),
  refreshtoken("refresh_token"),
  codePKCEVerifier("cvpkce"),
  expiration("expiration");

  const Keys(this.key);
  final String key;

  bool get exist => _storage.containsKey(key);
  Storage get _storage => window.localStorage;
  String? get value => _storage[key];
  void get reset => _storage.remove(key);
  DateTime? get getDate => _convertDateTime(_storage[key]);

  DateTime? _convertDateTime(String? value) => value == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(int.parse(value));

  set value(String? value) => _storage[key] = value ?? "";
  set setDate(DateTime? value) =>
      _storage[key] = value?.millisecondsSinceEpoch.toString() ?? "NaN";
}

class KeyclockLocalStorage {
  static bool get isAcessTokenReady =>
      Keys.accesstoken.exist && Keys.accesstoken.value != null;
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
