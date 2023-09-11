// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' show window;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairies/keycloack_auth.dart';
import 'package:librairies/src/keycloakAuth/keycloakRedirection/keycloak.localstorage.dart';
import 'package:librairies/src/keycloakAuth/keycloakRedirection/keycloak.provider.dart';
import 'package:librairies/src/keycloakAuth/keycloakRedirection/platform_impl/keycloack.base.dart';
import 'package:oauth2/oauth2.dart';

class KeycloackImpl extends BaseLogin {
  final Widget? indicator;
  KeycloackImpl(KeycloakConfig keycloakConfig, {this.indicator})
      : super(keycloakConfig);

  @override
  Widget login(BuildContext context) =>
      KeycloackWeb(keycloakConfig, indicator: indicator).loginWeb();
}

class KeycloackWeb {
  final KeycloakConfig keycloakConfig;
  final Widget? indicator;

  KeycloackWeb(this.keycloakConfig, {this.indicator});

  Widget loginWeb() => KeycloackWebView(keycloakConfig: keycloakConfig);
}

enum Mode {
  redirectToKeycloak("Redirection vers Keycloak..."),
  handleAuthorizationResponse("Redirection vers..."),
  readLocalStorage("");

  const Mode(this.text);
  final String text;
}

Mode get currentMode {
  if (KeyclockLocalStorage.isAcessTokenReady &&
      Uri.base.queryParameters.containsKey("code") == false) {
    return Mode.readLocalStorage;
  }
  if (Uri.base.queryParameters.containsKey("code")) {
    return Mode.handleAuthorizationResponse;
  }
  return Mode.redirectToKeycloak;
}

class KeycloackWebView extends ConsumerStatefulWidget {
  final KeycloakConfig keycloakConfig;
  final Widget? indicator;

  const KeycloackWebView({
    Key? key,
    required this.keycloakConfig,
    this.indicator,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      __KeycloackWebViewState();
}

class __KeycloackWebViewState extends ConsumerState<KeycloackWebView> {
  bool isTokenRedreshenable = false;
  late AuthorizationCodeGrant oauthgrant = AuthorizationCodeGrant(
      widget.keycloakConfig.clientid,
      widget.keycloakConfig.authorizationEndpoint,
      widget.keycloakConfig.tokenEndpoint,
      codeVerifier: KeyclockLocalStorage.currentCodeVerifier);

  handleMode() {
    debugPrint("🔒 Starting Auth...");
    var url = oauthgrant
        .getAuthorizationUrl(Uri.parse(widget.keycloakConfig.redirectUri));

    if (currentMode == Mode.readLocalStorage) {
      debugPrint("⚙️ Current mode is ${Mode.readLocalStorage}");

      var cred = Credentials(Keys.accesstoken.value!,
          refreshToken: Keys.refreshtoken.value,
          expiration: Keys.expiration.getDate);

      debugPrint("🗝️ Token Expiring at ${cred.expiration?.toIso8601String()}");
      if (cred.isExpired && cred.canRefresh == false) {
        debugPrint("❌⏱️❌ Token Expired");

        Keys.accesstoken.reset;
        Keys.refreshtoken.reset;
        Keys.expiration.reset;
      } else {
        debugPrint("👌⏱️👌 Token Still valid");
        Keys.codePKCEVerifier.reset;
        Future.microtask(() {
          ref.read(oAuthClientProvider.notifier).client =
              Client(cred, identifier: oauthgrant.identifier);
          isTokenRedreshenable = true;
        });
      }
    }
    if (currentMode == Mode.redirectToKeycloak) {
      debugPrint("⚙️ Current mode is ${Mode.redirectToKeycloak}");

      Keys.accesstoken.reset;
      Keys.refreshtoken.reset;
      Keys.expiration.reset;
      Future.microtask(() => window.location.replace(url.toString()));
    }
    if (currentMode == Mode.handleAuthorizationResponse) {
      debugPrint("⚙️ Current mode is ${Mode.handleAuthorizationResponse}");
      var queryParameters = Uri.parse(window.location.href).queryParameters;

      oauthgrant.handleAuthorizationResponse(queryParameters).then((value) {
        debugPrint(
            "✔️🗝️ new Token generated expired at ${value.credentials.expiration?.toIso8601String()}");

        Keys.accesstoken.value = value.credentials.accessToken;
        if (value.credentials.refreshToken != null) {
          Keys.refreshtoken.value = value.credentials.refreshToken!;
        }
        if (value.credentials.expiration != null) {
          Keys.expiration.setDate = value.credentials.expiration;
        }
        var uri = Uri.parse(window.location.href);
        var resultUrl = Uri(
            scheme: uri.scheme, host: uri.host, port: uri.port, path: uri.path);
        window.history.pushState({}, "document.title", resultUrl.toString());
        ref.read(oAuthClientProvider.notifier).client = value;
        isTokenRedreshenable = true;

        Keys.codePKCEVerifier.reset;
      }).onError((error, stackTrace) {
        isTokenRedreshenable = false;
      });
    }
  }



  @override
  void dispose() {
   // ref.read(timerProvider(widget.keycloakConfig)).cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(timerProvider(widget.keycloakConfig));
    handleMode();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget.indicator ?? CircularProgressIndicator(),
            Text(currentMode.text),
          ],
        ),
      ),
    );
  }
}
