// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' show window;

import 'package:flutter/material.dart';
import 'package:librairies/keycloack_auth.dart';
import 'package:librairies/src/keycloakAuth/keycloakRedirection/platform_impl/storage/keycloak.storage.dart';
import 'package:oauth2/oauth2.dart';

class KeycloackImpl extends StatelessWidget {
  final Widget? indicator;
  final Function(Client? client) onLogged;
  final KeycloakConfig keycloakConfig;
  KeycloackImpl({
    required this.keycloakConfig,
    required this.onLogged,
    this.indicator,
  });

  @override
  Widget build(BuildContext context) => KeycloackWebView(
        keycloakConfig: keycloakConfig,
        onLogged: onLogged,
        indicator: indicator,
      );
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

class KeycloackWebView extends StatefulWidget {
  final KeycloakConfig keycloakConfig;
  final Widget? indicator;
  final Function(Client? client) onLogged;

  const KeycloackWebView({
    Key? key,
    required this.keycloakConfig,
    required this.onLogged,
    this.indicator,
  }) : super(key: key);

  @override
  State<KeycloackWebView> createState() => _KeycloackWebViewState();
}

class _KeycloackWebViewState extends State<KeycloackWebView> {
  bool isTokenRedreshenable = false;
  late AuthorizationCodeGrant oauthgrant = AuthorizationCodeGrant(
      widget.keycloakConfig.clientid,
      widget.keycloakConfig.authorizationEndpoint,
      widget.keycloakConfig.tokenEndpoint,
      codeVerifier: KeyclockLocalStorage.currentCodeVerifier);

  handleMode() {
    debugPrint("🔒 Starting Auth with ${window.location.href}...");
    if (Keys.redirectUri.value?.isEmpty ?? true) {
      Keys.redirectUri.value = window.location.href;
    }
    var url = oauthgrant.getAuthorizationUrl(
        Uri.parse(Keys.redirectUri.value ?? widget.keycloakConfig.redirectUri));

    if (currentMode == Mode.readLocalStorage) {
      debugPrint("⚙️ Current mode is ${Mode.readLocalStorage}");

      var cred = Credentials(Keys.accesstoken.value!,
          refreshToken: Keys.refreshtoken.value,
          tokenEndpoint: widget.keycloakConfig.tokenEndpoint,
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
        widget.onLogged(Client(cred, identifier: oauthgrant.identifier));
        isTokenRedreshenable = true;
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
        var uri = Uri.parse(
            Keys.redirectUri.value ?? widget.keycloakConfig.redirectUri);
        var resultUrl = Uri(
            scheme: uri.scheme,
            host: uri.host,
            port: uri.port,
            path: uri.path,
            fragment: uri.fragment);
        window.history.pushState({}, "document.title", resultUrl.toString());
        Keys.redirectUri.reset;
        widget.onLogged(value);
        isTokenRedreshenable = true;

        Keys.codePKCEVerifier.reset;
      }).onError((error, stackTrace) {
        debugPrint(error.toString());
        isTokenRedreshenable = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      handleMode();
    });
  }

  @override
  Widget build(BuildContext context) {
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
