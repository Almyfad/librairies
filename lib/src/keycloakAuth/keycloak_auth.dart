import 'package:flutter/material.dart';
import 'package:librairies/src/keycloakAuth/keycloakRedirection/keycloak.provider.dart';
import 'package:oauth2/oauth2.dart';
import 'package:provider/provider.dart';

import 'keycloak.config.dart';
import 'keycloakRedirection/platform_impl/keycloack.redirection.dart';

class KeycloakAuth extends StatefulWidget {
  final KeycloakConfig keycloakConfig;
  final Widget? indicator;
  final Widget child;
  final Widget errorWidget;
  final Function(Client? client) onTokenUpdated;
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => OauthNotifier(),
        child: Consumer<OauthNotifier>(builder: (context, notifier, child) {
          return AnimatedContainer(
            duration: Durations.medium4,
            child: notifier.isLogged
                ? widget.child
                : KeycloackRedirection(
                    onLogged: (value) {
                      widget.onTokenUpdated(value);
                      notifier.client = value;
                      notifier.scheduleRefreshToken();
                    },
                    indicator: widget.indicator,
                    keycloakConfig: widget.keycloakConfig),
          );
        }));
  }
}
