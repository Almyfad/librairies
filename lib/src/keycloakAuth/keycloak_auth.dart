// ignore_for_file: public_member_api_docs, sort_constructors_first

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
  const KeycloakAuth({
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
    super.initState();
    Future.microtask(() => ref.watch(oAuthClientProvider.notifier).addListener((state) {
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

//TODO log out
/*
  Future<bool?> logout(BuildContext context) async {
    if (client == null) return Future.value(null);
    try {
      var url = keycloakConfig.logoutEndpoint.toString();
      var response = await postform(context, url, body: {
        "client_id": keycloakConfig.clientid,
        "refresh_token": client!.credentials.refreshToken
      });

      debugPrint(json.encode(response));
      return true;
    } catch (e) {
      return Future.error(e);
    }
  }*/