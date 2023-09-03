import 'package:flutter/material.dart';
import 'package:oauth2/oauth2.dart';

abstract class BaseLogin {
  final AuthorizationCodeGrant grant;
  final Uri keycloakUri;
  BaseLogin(this.grant, this.keycloakUri);
  Widget login();
}
