// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:librairies/keycloack_auth.dart';

import 'package:librairies/src/keycloakAuth/keycloakRedirection/platform_impl/keycloack.stub.dart'
    if (dart.library.io) 'package:librairies/src/keycloakAuth/keycloakRedirection/platform_impl/keycloack.mobile.dart'
    if (dart.library.html) 'package:librairies/src/keycloakAuth/keycloakRedirection/platform_impl/keycloack.web.dart';

class KeycloackRedirection extends StatelessWidget {
  final Widget? indicator;
  final KeycloakConfig keycloakConfig;
  final KeycloackImpl _login;

  KeycloackRedirection({
    super.key,
    required this.keycloakConfig,
    this.indicator
  }) : _login = KeycloackImpl(keycloakConfig,indicator: indicator);

  @override
  Widget build(BuildContext context) => _login.login(context);
}
