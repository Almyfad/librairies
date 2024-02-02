
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairies/src/keycloakAuth/keycloakRedirection/keycloak.provider.dart';
import 'package:oauth2/oauth2.dart';

import 'keycloak.config.dart';
import 'keycloakRedirection/platform_impl/keycloack.redirection.dart';

class KeycloakAuth extends ConsumerStatefulWidget {
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
  ConsumerState<ConsumerStatefulWidget> createState() => _KeycloakAuthState();
}

class _KeycloakAuthState extends ConsumerState<KeycloakAuth> {
  @override
  void initState() {
    KeycloackController.config = widget.keycloakConfig;
    super.initState();
    Future.microtask(
        () => ref.watch(oAuthClientProvider.notifier).addListener((state) {
              widget.onTokenUpdated(state?.client);
            }));
  }

  @override
  Widget build(BuildContext context) {
    final wrpClient = ref.watch(oAuthClientProvider);
    if (wrpClient?.isLogged ?? false) return widget.child;
    return KeycloackRedirection(
        indicator: widget.indicator, keycloakConfig: widget.keycloakConfig);
  }
}

class KeycloackController {
  static KeycloakConfig? config;
  KeycloackController();

  Future<bool> logout(WidgetRef ref) async {
    if (config == null) return false;
     return ref.read(logoutProvider(config!).future);
  }
}
