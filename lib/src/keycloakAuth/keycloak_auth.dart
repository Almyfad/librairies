import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart';

import 'exceptions.dart';
import 'keycloak.config.dart';
import 'keycloakRedirection/platform_impl/keycloack.redirection.dart';

class KeycloakAuth extends StatefulWidget {
  final KeycloakConfig keycloakConfig;
  final Widget? indicator;
  const KeycloakAuth({
    Key? key,
    required this.keycloakConfig,
    required this.child,
    required this.errorWidget,
    this.indicator,
    this.authenticateHttpClient,
  }) : super(key: key);
  final Widget child;
  final Widget errorWidget;
  final AuthenticateHttpClient? authenticateHttpClient;
  @override
  State<KeycloakAuth> createState() => _KeycloakAuthState();
}

class _KeycloakAuthState extends State<KeycloakAuth> {
  late AuthenticateHttpClient authenticateHttp =
      widget.authenticateHttpClient ?? AuthenticateHttpClient();

  @override
  Widget build(BuildContext context) {
    return OAuthManager(
        indicator: widget.indicator,
        keycloakConfig: widget.keycloakConfig,
        authenticateHttp: authenticateHttp,
        onHttpInit: (value) => setState(() {
              authenticateHttp.client = value;
            }),
        child: _AuthHandler(
          indicator: widget.indicator,
          keycloackConfig: widget.keycloakConfig,
          errorWidget: widget.errorWidget,
          child: widget.child,
        ));
  }
}

class OAuthManager extends InheritedWidget {
  final KeycloakConfig keycloakConfig;
  final Widget? indicator;
  const OAuthManager({
    super.key,
    required super.child,
    required this.authenticateHttp,
    required this.indicator,
    required this.keycloakConfig,
    required this.onHttpInit,
  });

  final AuthenticateHttpClient authenticateHttp;
  final ValueChanged<Client?> onHttpInit;

  static OAuthManager? of(BuildContext context) {
    var oauth = context.getInheritedWidgetOfExactType<OAuthManager>();
    assert(oauth != null, "OAuthManager not found in widgetTree");
    return oauth;
  }

  @override
  bool updateShouldNotify(OAuthManager oldWidget) =>
      oldWidget.onHttpInit != onHttpInit;

  Future<dynamic> get(BuildContext context, String url,
      {Map<String, String>? params}) {
    var parsedUrl = Uri.parse(url).replace(queryParameters: params);
    debugPrint("[🌎Url]=$parsedUrl");
    return _sendQuery(context, () => client!.get(parsedUrl));
  }

  Future<dynamic> post(BuildContext context, String url,
      {Object? body, Map<String, String>? params}) {
    var parsedUrl = Uri.parse(url).replace(queryParameters: params);
    debugPrint("[🌎Url]=$parsedUrl");
    debugPrint("[💪body]=${json.encode(body)}");
    return _sendQuery(
        context,
        () => client!.post(parsedUrl,
            body: json.encode(body),
            headers: {"Content-Type": "application/json"}));
  }

  Future<dynamic> postform(BuildContext context, String url,
      {Object? body, Map<String, String>? params}) {
    var parsedUrl = Uri.parse(url).replace(queryParameters: params);
    debugPrint("[🌎Url]=$parsedUrl");
    debugPrint("[💪body]=${json.encode(body)}");
    return _sendQuery(
        context,
        () => client!.post(parsedUrl,
            body: body,
            headers: {"Content-Type": "application/x-www-form-urlencoded"}));
  }

  Future<dynamic> _sendQuery(
      BuildContext context, Future<http.Response> Function() method) async {
    assert(client != null, "authenticateHttp.client cannot be null");

    debugPrint("🔑 Token :${client?.credentials.accessToken}");
    debugPrint("[⏱️expiration]=${client?.credentials.expiration}");
    debugPrint("[⏱️canRefresh]=${client?.credentials.canRefresh}");
    debugPrint("[⏱️isExpired]=${client?.credentials.isExpired}");

    if (isLogged == false) {
      OAuthManager.of(context)?.onHttpInit(null); //Redirige vers la page login
    }
    try {
      var response = await method().timeout(const Duration(seconds: 30));
      if (response.statusCode == 403) {
        return Future.error(UnAuthorise(message: response.body));
      }
      if (response.statusCode == 404) {
        return Future.error(NotFound());
      }
      if (response.statusCode == 204) {
        return Future.value(true);
      }
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return response.body;
      }
    } on AuthorizationException catch (e) {
      client!.close();
      Future.microtask(() => OAuthManager.of(context)
          ?.onHttpInit(null)); //Redirige vers la page login
      return Future.error(
          UnAuthorise(message: "${e.error} : ${e.description}"));
    } on TimeoutException catch (_) {
      return Future.error(TimeOut());
    } catch (e) {
      return Future.error(Internal());
    }
  }

  Future<bool?> logout(BuildContext context) async {
    if (client == null) return Future.value(null);

    var url = keycloakConfig.logoutEndpoint.toString();
    var response = await postform(context, url, body: {
      "client_id": keycloakConfig.clientid,
      "refresh_token": client!.credentials.refreshToken
    });

    debugPrint(json.encode(response));
    return response;
  }

  Client? get client => authenticateHttp.client;
  bool get _isExpired => client?.credentials.isExpired ?? true;
  bool get _canRefresh => client?.credentials.canRefresh ?? false;
  bool get isLogged => _isExpired == false || _canRefresh;

  navigatePush(BuildContext context, Widget child) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => KeycloakAuth(
                indicator: indicator,
                keycloakConfig: keycloakConfig,
                authenticateHttpClient: authenticateHttp,
                errorWidget: Container(),
                child: child)));
  }

  navigatePushReplacement(BuildContext context, Widget child) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => KeycloakAuth(
                keycloakConfig: keycloakConfig,
                authenticateHttpClient: authenticateHttp,
                errorWidget: Container(),
                child: child)));
  }
}

class _AuthHandler extends StatefulWidget {
  final Widget child;
  final Widget? indicator;
  final Widget errorWidget;
  final KeycloakConfig keycloackConfig;
  const _AuthHandler({
    Key? key,
    required this.child,
    required this.errorWidget,
    required this.keycloackConfig,
    this.indicator,
  }) : super(key: key);

  @override
  State<_AuthHandler> createState() => _AuthHandlerState();
}

class _AuthHandlerState extends State<_AuthHandler> {
  late Uri uri = Uri.parse(widget.keycloackConfig.issuer);

  @override
  Widget build(BuildContext context) {
    if (OAuthManager.of(context)?.isLogged ?? false) return widget.child;

    return KeycloackRedirection(
        indicator: widget.indicator,
        keycloackUri: uri,
        grant: AuthorizationCodeGrant(
          widget.keycloackConfig.clientid,
          widget.keycloackConfig.authorizationEndpoint,
          widget.keycloackConfig.tokenEndpoint,
        ));
  }
}

class AuthenticateHttpClient {
  Client? client;
  AuthenticateHttpClient({this.client});
}
