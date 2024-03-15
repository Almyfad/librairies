// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:librairies/keycloack_auth.dart';

import 'package:librairies/src/keycloakAuth/keycloakRedirection/platform_impl/keycloack.stub.dart'
    if (dart.library.io) 'package:librairies/src/keycloakAuth/keycloakRedirection/platform_impl/keycloack.mobile.dart'
    if (dart.library.html) 'package:librairies/src/keycloakAuth/keycloakRedirection/platform_impl/keycloack.web.dart';
import 'package:oauth2/oauth2.dart';

class KeycloackRedirection extends StatelessWidget {
  final Widget? indicator;
  final KeycloakConfig keycloakConfig;
  final Function(Client? client) onLogged;

  KeycloackRedirection(
      {super.key,
      required this.keycloakConfig,
      required this.onLogged,
      this.indicator});

  @override
  Widget build(BuildContext context) => KeycloackImpl(
        keycloakConfig: keycloakConfig,
        indicator: indicator,
        onLogged: onLogged,
      );
}
