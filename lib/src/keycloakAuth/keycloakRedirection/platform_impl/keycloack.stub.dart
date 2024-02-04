import 'package:flutter/material.dart';
import 'package:librairies/keycloack_auth.dart';
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
  Widget build(BuildContext context) {
    throw Exception("Stub implementation");
  }
}
