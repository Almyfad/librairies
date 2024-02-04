import 'dart:async';

import 'package:flutter/material.dart';
import 'package:librairies/src/keycloakAuth/keycloakRedirection/platform_impl/storage/keycloak.storage.dart';
import 'package:oauth2/oauth2.dart';

class OauthNotifier extends ChangeNotifier {
  Client? _client;

  String? get accessToken => _client?.credentials.accessToken;
  String? get refreshToken => _client?.credentials.refreshToken;
  DateTime? get expiration => _client?.credentials.expiration;

  bool get _isExpired => _client?.credentials.isExpired ?? true;
  bool get _canRefresh => _client?.credentials.canRefresh ?? false;
  bool get isLogged => _isExpired == false || _canRefresh;

  set client(Client? value) {
    _client = value;
    notifyListeners();
  }

  reset() {
    _client = null;
    notifyListeners();
  }

  Future<bool> refresh() async {
    debugPrint("💥💥 Token refreshor");
    _client = await _client?.refreshCredentials();
    if (_client != null) {
      Keys.expiration.setDate = _client!.credentials.expiration;
      Keys.accesstoken.value = _client!.credentials.accessToken;
      Keys.refreshtoken.value = _client!.credentials.refreshToken;
    }
    debugPrint(
        "✔️🗝️ new Token generated expired at ${Keys.expiration.getDate?.toIso8601String()}");
    notifyListeners();
    return true;
  }

  scheduleRefreshToken() async{
    if (_client == null) return;
    if (_client!.credentials.expiration == null) return;
    var time = Duration(
        seconds: DateTime.now()
                .difference(_client!.credentials.expiration!)
                .abs()
                .inSeconds -
            30);

    debugPrint(
        "📅 Token refresh setup to ${DateTime.now().add(time).toIso8601String()}");

    await Future.delayed(time, () => debugPrint("Time elapsed ! Try Refreshing Token"));
    await refresh();
    scheduleRefreshToken();
  }

  set credidentials(Credentials creds) {
    _client = Client(creds);
    notifyListeners();
  }

  Future<bool> logout(config) async {
    if (Keys.accesstoken.value == null) return Future.value(false);

    debugPrint("💥💥 LOGIN OUT !!!!");

    try {
      await Client(Credentials(Keys.accesstoken.value!))
          .post(config.logoutEndpoint, headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      }, body: {
        "client_id": config.clientid,
        "refresh_token": Keys.refreshtoken.value,
      });

      Keys.accesstoken.value = null;
      Keys.refreshtoken.value = null;
      Keys.expiration.setDate = null;

      try {
        client = null;
        notifyListeners();
      } catch (e) {
        debugPrint(e.toString());
      }

      return true;
    } catch (e) {
      return Future.error(e);
    }
  }
}
