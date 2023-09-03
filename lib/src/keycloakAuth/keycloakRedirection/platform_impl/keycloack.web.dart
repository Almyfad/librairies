// ignore: avoid_web_libraries_in_flutter
import 'dart:html' show window;
import 'package:flutter/material.dart';
import 'package:oauth2/oauth2.dart';
import 'package:librairies/src/keycloakAuth/keycloakRedirection/platform_impl/keycloack.base.dart';

class KeycloackImpl extends BaseLogin {
  final Widget? indicator;
  KeycloackImpl(AuthorizationCodeGrant grant, Uri redirectUri,{this.indicator})
      : super(grant, redirectUri);

  @override
  Widget login() {
    var url = grant.getAuthorizationUrl(keycloakUri);
    Future.microtask(() => window.location.replace(url.toString()));

    return  Scaffold(
      body: Column(
        children: [
          indicator ?? CircularProgressIndicator(),
          Text("Redirection vers keycloack"),
        ],
      ),
    );
  }
}
