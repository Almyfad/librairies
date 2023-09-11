import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairies/src/keycloakAuth/keycloak.config.dart';
import 'package:librairies/src/keycloakAuth/keycloakRedirection/keycloak.localstorage.dart';
import 'package:oauth2/oauth2.dart';

final oAuthClientProvider =
    StateNotifierProvider<OauthNotifier, WrappedClient?>((ref) {
  return OauthNotifier();
});

class OauthNotifier extends StateNotifier<WrappedClient?> {
  OauthNotifier() : super(null);

  set client(Client? value) {
    state = WrappedClient(client: value);
  }

  set credidentials(Credentials creds) {
    state = WrappedClient(client: Client(creds));
  }
}

class WrappedClient {
  final Client? client;
  WrappedClient({
    this.client,
  });

  bool get _isExpired => client?.credentials.isExpired ?? true;
  bool get _canRefresh => client?.credentials.canRefresh ?? false;
  bool get isLogged => _isExpired == false || _canRefresh;
}

final timerProvider = StateProvider.family<Timer,KeycloakConfig>((ref,config) {
  var time = Duration(minutes: 5);
  debugPrint(
      "📅 Token refresh setup to ${DateTime.now().add(time).toIso8601String()}");
  debugPrint("📅 Token refresh setup in ${time.inMinutes} minutes");
  return Timer.periodic(time, (timer) {
    ref.read(refreshTokenProvider(config));
  });
});

final refreshTokenProvider =
    FutureProvider.family<bool, KeycloakConfig>((ref, config) async {
  var client = ref.watch(oAuthClientProvider)?.client;
  debugPrint("💥💥 Token refreshing");
  if (client == null) return Future.value(false);
  try {
    var res = await client.post(config.tokenEndpoint, headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    }, body: {
      "client_id": config.clientid,
      "refresh_token": Keys.refreshtoken.value,
      "grant_type": "refresh_token"
    });
    var data = jsonDecode(res.body);

    Keys.accesstoken.value = data["access_token"];
    Keys.refreshtoken.value = data["refresh_token"];
    Keys.expiration.setDate =
        DateTime.now().add(Duration(seconds: data["expires_in"] as int));
    debugPrint(
        "✔️🗝️ new Token generated expired at ${Keys.expiration.getDate?.toIso8601String()}");

    try {
      ref.read(oAuthClientProvider.notifier).credidentials = Credentials(
          Keys.accesstoken.value!,
          refreshToken: Keys.refreshtoken.value,
          expiration: Keys.expiration.getDate);
    } catch (e) {
      debugPrint(e.toString());
    }

    return true;
  } catch (e) {
    return Future.error(e);
  }
});
