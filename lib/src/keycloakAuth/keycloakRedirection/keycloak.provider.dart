import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:librairies/src/keycloakAuth/keycloakRedirection/platform_impl/storage/keycloak.storage.dart';
import 'package:oauth2/oauth2.dart';

class OauthNotifier extends ChangeNotifier {
  Client? _client;
  Timer? timer;

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
    if (_client == null) return Future.value(false);
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

  verifyToken() {
    debugPrint("🗝️ Check Token ");
    if (isLogged) return;
    _client = null;
    notifyListeners();
  }

  scheduleRefreshToken() {
    timer?.cancel();
    if (_client == null) return null;
    if (_client!.credentials.expiration == null) return null;
    var time = Duration(
        seconds: DateTime.now()
                .difference(_client!.credentials.expiration!)
                .abs()
                .inSeconds -
            30);

    debugPrint(
        "📅 Token refresh setup to ${DateTime.now().add(time).toIso8601String()}");

    timer = Timer.periodic(time, (timer) async {
      await refresh();
      debugPrint(
          "📅 Token refresh setup to ${DateTime.now().add(time).toIso8601String()}");
    });
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
      timer?.cancel();
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

class KeycloakHttpCLient extends Client {
  final OauthNotifier oauthNotifier;
  KeycloakHttpCLient(super.credentials, {required this.oauthNotifier});
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    try {
      var send = await super.send(request);
      return send;
    } on ExpirationException catch (_) {
      oauthNotifier.reset();
      rethrow;
    }
  }
}
