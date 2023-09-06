// ignore: avoid_web_libraries_in_flutter
import 'dart:html' show window;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:librairies/keycloack_auth.dart';
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

  Widget loginWeb() => _KeycloackWebView(keycloakConfig: keycloakConfig);
}

enum Mode {
  redirectToKeycloak("Redirection vers Keycloak..."),
  handleAuthorizationResponse("Redirection vers..."),
  readLocalStorage("");

  const Mode(this.text);
  final String text;
}

Mode get currentMode {
  if (window.localStorage.containsKey("accesstoken") &&
      localAccesToken != null) {
    return Mode.readLocalStorage;
  }
  if (Uri.base.queryParameters.containsKey("code")) {
    return Mode.handleAuthorizationResponse;
  }
  return Mode.redirectToKeycloak;
}

String? get localRedirectAfterLogin =>
    window.localStorage["kykredirectafterlogin"];
String? get localCvPKCE => window.localStorage["cvpkce"];
String? get localAccesToken => window.localStorage["accesstoken"];
String? get localRefreshToken => window.localStorage["refreshtoken"];

DateTime? _convertDateTime(String? value) => value == null
    ? null
    : DateTime.fromMillisecondsSinceEpoch(int.parse(value));

DateTime? get localExpiration =>
    _convertDateTime(window.localStorage["expiration"]);

set localRedirectAfterLogin(value) =>
    window.localStorage["kykredirectafterlogin"] = value;
set localCvPKCE(value) => window.localStorage["cvpkce"] = value;
set localAccesToken(value) => window.localStorage["accesstoken"] = value;
set localRefreshToken(value) => window.localStorage["refreshtoken"] = value;
set localExpiration(DateTime? value) => window.localStorage["expiration"] =
    value?.millisecondsSinceEpoch.toString() ?? "NaN";

String get currentCodeVerifier => localCvPKCE ?? newcodeVerifier;

String get newcodeVerifier {
  const String charset =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
  return window.localStorage['cvpkce'] = List.generate(
    128,
    (i) => charset[Random.secure().nextInt(charset.length)],
  ).join();
}

class _KeycloackWebView extends StatefulWidget {
  final KeycloakConfig keycloakConfig;
  final Widget? indicator;

  const _KeycloackWebView({
    Key? key,
    required this.keycloakConfig,
    this.indicator,
  }) : super(key: key);

  @override
  State<_KeycloackWebView> createState() => __KeycloackWebViewState();
}

class __KeycloackWebViewState extends State<_KeycloackWebView> {
  late AuthorizationCodeGrant oauthgrant = AuthorizationCodeGrant(
      widget.keycloakConfig.clientid,
      widget.keycloakConfig.authorizationEndpoint,
      widget.keycloakConfig.tokenEndpoint,
      codeVerifier: currentCodeVerifier);

  handleMode() {
    var url = oauthgrant
        .getAuthorizationUrl(Uri.parse(widget.keycloakConfig.redirectUri));

    if (currentMode == Mode.readLocalStorage) {
      window.localStorage.remove('cvpkce');
      window.localStorage.remove('kykredirectafterlogin');

      var cred = Credentials(localAccesToken.toString(),
          refreshToken: localRefreshToken, expiration: localExpiration);

      if (cred.isExpired && cred.canRefresh == false) {
        window.localStorage.remove('accesstoken');
        window.localStorage.remove('refreshtoken');
        window.localStorage.remove('expiration');
      } else {
        Future.microtask(() {
          OAuthManager.of(context)?.onTokenUpdated?.call(localAccesToken);
          OAuthManager.of(context)?.onHttpInit(Client(
              Credentials(localAccesToken.toString(),
                  refreshToken: localRefreshToken, expiration: localExpiration),
              identifier: oauthgrant.identifier));
        });
      }
    }
    if (currentMode == Mode.redirectToKeycloak) {
      localRedirectAfterLogin = window.location.href;
      Future.microtask(() => window.location.replace(url.toString()));
    }
    if (currentMode == Mode.handleAuthorizationResponse) {
      var queryParameters = Uri.parse(window.location.href).queryParameters;

      oauthgrant.handleAuthorizationResponse(queryParameters).then((value) {
        localAccesToken = value.credentials.accessToken;

        if (value.credentials.refreshToken != null) {
          localRefreshToken = value.credentials.refreshToken!;
        }
        if (value.credentials.expiration != null) {
          localExpiration = value.credentials.expiration;
        }
        var redirect =
            localRedirectAfterLogin ?? widget.keycloakConfig.redirectUri;
        window.location.replace(redirect);
      }).onError((error, stackTrace) {});
      window.localStorage.remove('cvpkce');
    }
  }

  @override
  void initState() {
    handleMode();
    super.initState();
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
