import 'package:flutter/material.dart';
import 'package:oauth2/oauth2.dart';
import 'package:librairies/src/keycloakAuth/keycloakRedirection/platform_impl/keycloack.base.dart';

class KeycloackImpl extends BaseLogin {
  final Widget? indicator;

  KeycloackImpl(AuthorizationCodeGrant grant, Uri keycloakUri,{this.indicator})
      : super(grant, keycloakUri);
  @override
  Widget login() {
    throw Exception("Stub implementation");
  }
}
