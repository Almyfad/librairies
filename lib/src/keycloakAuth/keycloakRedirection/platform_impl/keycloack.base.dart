import 'package:flutter/material.dart';
import 'package:librairies/keycloack_auth.dart';


abstract class BaseLogin {
  final KeycloakConfig keycloakConfig;
  BaseLogin(this.keycloakConfig);
  Widget login(BuildContext context);
}