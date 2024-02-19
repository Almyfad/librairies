import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:librairies/keycloack_auth.dart';
import 'package:librairies/src/keycloakAuth/keycloakRedirection/platform_impl/storage/keycloak.storage.dart';
import 'package:oauth2/oauth2.dart';

class OauthNotifier extends ChangeNotifier {
  final Function(Client? client)? onRefresh;

  Client? _client;
  Timer? timer;

  OauthNotifier({this.onRefresh});

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
    // return Future.value(false);
    try {
      client = await _client?.refreshCredentials();
    } catch (e) {
      debugPrint("❌❌  Token refreshor FAILED ❌❌");
      return Future.value(false);
    }
    if (_client == null) return false;

    Keys.expiration.setDate = _client!.credentials.expiration;
    Keys.accesstoken.value = _client!.credentials.accessToken;
    Keys.refreshtoken.value = _client!.credentials.refreshToken;
    onRefresh?.call(_client);
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
    client = Client(creds);
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

class KeycloakHttpClient extends Client {
  final OauthNotifier oauthNotifier;
  KeycloakHttpClient(super.credentials,
      {required this.oauthNotifier, super.identifier});
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    try {
      debugPrint(
          "⏱️⏱️$identifier Token Expired ${DateTime.now().difference(Keys.expiration.getDate!).abs().inSeconds} seconds");
      var res = await super.send(request);
      if (res.statusCode == 403 || res.statusCode == 401) {
        throw Exception(
          "Droits Insufisants",
        );
      }
      return res;
    } on ExpirationException catch (_) {
      oauthNotifier.reset();
      rethrow;
    } on AuthorizationException catch (e) {
      oauthNotifier.reset();
      rethrow;
    }
  }
}
