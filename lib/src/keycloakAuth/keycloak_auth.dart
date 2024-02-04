import 'dart:async';

import 'package:flutter/material.dart';
import 'package:librairies/src/keycloakAuth/keycloakRedirection/keycloak.provider.dart';
import 'package:provider/provider.dart';

import 'keycloak.config.dart';
import 'keycloakRedirection/platform_impl/keycloack.redirection.dart';

class KeycloakAuth extends StatefulWidget {
  final KeycloakConfig keycloakConfig;
  final Widget? indicator;
  final Widget child;
  final Widget errorWidget;
  final Function(KeycloakHttpCLient? client) onTokenUpdated;
  KeycloakAuth({
    required this.keycloakConfig,
    this.indicator,
    required this.child,
    required this.errorWidget,
    required this.onTokenUpdated,
  });

  @override
  State<KeycloakAuth> createState() => _KeycloakAuthState();
}

class _KeycloakAuthState extends State<KeycloakAuth> {
  Timer? timer;
  late final AppLifecycleListener _listener;
  OauthNotifier oauth = OauthNotifier();

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onShow: () => oauth.verifyToken(),
      onResume: () => oauth.verifyToken(),
      onRestart: () => oauth.verifyToken(),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => oauth,
        child: Consumer<OauthNotifier>(builder: (context, notifier, child) {
          return AnimatedContainer(
            duration: Durations.medium4,
            child: notifier.isLogged
                ? widget.child
                : KeycloackRedirection(
                    onLogged: (value) {
                      widget.onTokenUpdated(KeycloakHttpCLient(
                          value!.credentials,
                          oauthNotifier: notifier));
                      notifier.client = value;
                      timer = notifier.scheduleRefreshToken();
                    },
                    indicator: widget.indicator,
                    keycloakConfig: widget.keycloakConfig),
          );
        }));
  }
}
