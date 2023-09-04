import 'package:flutter/material.dart';
import 'package:librairies/keycloack_auth.dart';
import 'package:librairies/src/keycloakAuth/keycloakRedirection/platform_impl/keycloack.base.dart';

class KeycloackImpl extends BaseLogin {
  final Widget? indicator;

  KeycloackImpl(KeycloakConfig keycloakConfig,{this.indicator})
      : super(keycloakConfig);
  @override
  Widget login(BuildContext context) {
    throw Exception("Stub implementation");
  }
}
