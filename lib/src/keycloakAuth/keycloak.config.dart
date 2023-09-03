import 'dart:convert';

import 'package:equatable/equatable.dart';

class KeycloakConfig extends Equatable {
  final String issuer;
  final String clientid;
  const KeycloakConfig({
    required this.issuer,
    required this.clientid,
  });
  Uri get authorizationEndpoint =>
      Uri.parse("$issuer/protocol/openid-connect/auth");
  Uri get tokenEndpoint => Uri.parse("$issuer/protocol/openid-connect/token");
  Uri get logoutEndpoint => Uri.parse("$issuer/protocol/openid-connect/logout");

  @override
  String toString() => 'KeycloakConfig(issuer: $issuer, clientid: $clientid)';

  @override
  List<Object> get props => [issuer, clientid];

  KeycloakConfig copyWith({
    String? issuer,
    String? clientid,
  }) {
    return KeycloakConfig(
      issuer: issuer ?? this.issuer,
      clientid: clientid ?? this.clientid,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'issuer': issuer,
      'clientid': clientid,
    };
  }

  factory KeycloakConfig.fromMap(Map<String, dynamic> map) {
    return KeycloakConfig(
      issuer: map['issuer'] ?? '',
      clientid: map['clientid'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory KeycloakConfig.fromJson(String source) => KeycloakConfig.fromMap(json.decode(source));
}
