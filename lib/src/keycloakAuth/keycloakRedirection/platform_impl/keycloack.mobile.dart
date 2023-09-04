import 'package:flutter/material.dart';
import 'package:librairies/keycloack_auth.dart';
import 'package:oauth2/oauth2.dart';
import 'package:librairies/src/keycloakAuth/keycloakRedirection/platform_impl/keycloack.base.dart';
import 'package:librairies/somethingwentwrong.dart';
import 'package:webview_flutter/webview_flutter.dart';

class KeycloackImpl extends BaseLogin {
  final Widget? indicator;
  KeycloackImpl(KeycloakConfig keycloakConfig, {this.indicator})
      : super(keycloakConfig);

  @override
  Widget login(BuildContext context) =>
      KeycloackMobile(keycloakConfig).loginMobile();
}

class KeycloackMobile {
  final KeycloakConfig keycloakConfig;
  KeycloackMobile(this.keycloakConfig);

  Widget loginMobile() => _KeycloackWebView(
        keycloakConfig: keycloakConfig,
      );
}

class _KeycloackWebView extends StatefulWidget {
  final KeycloakConfig keycloakConfig;
  const _KeycloackWebView({Key? key, required this.keycloakConfig})
      : super(key: key);

  @override
  State<_KeycloackWebView> createState() => _KeycloackWebViewState();
}

class _KeycloackWebViewState extends State<_KeycloackWebView> {
  late final WebViewController controller;
  late NavigationDelegate _navigationDelegate;
  late AuthorizationCodeGrant oauthgrant = AuthorizationCodeGrant(
      widget.keycloakConfig.clientid,
      widget.keycloakConfig.authorizationEndpoint,
      widget.keycloakConfig.tokenEndpoint);
  String? logmessage = "";
  WebResourceError? networkError;
  bool isNetworkError = false;
  bool reloading = false;
  @override
  void initState() {
    _navigationDelegate = NavigationDelegate(
      onWebResourceError: (error) {
        networkError = error;
      },
      onPageStarted: (url) {
        networkError = null;
      },
      onPageFinished: (url) async {
        await Future.delayed(const Duration(milliseconds: 500));
        setState(() {
          isNetworkError = networkError != null;
          reloading = false;
        });
      },
      onNavigationRequest: (NavigationRequest request) async {
        log("verify code...");
        var responseUrl = Uri.parse(request.url);
        log("verify code : ${responseUrl.toString()}");
        debugPrint("NavigationRequest =>$responseUrl");

        if (responseUrl.queryParameters['code']?.isEmpty ?? true) {
          log(null);
          return NavigationDecision.navigate;
        }
        if (OAuthManager.of(context) == null) {
          log("OAuthManager is null");
        } else {
          log("setting client http...");
        }
        OAuthManager.of(context)?.onHttpInit(await oauthgrant
            .handleAuthorizationResponse(responseUrl.queryParameters));

        log("authentification done");

        return NavigationDecision.prevent;
      },
    );

    super.initState();
    controller = WebViewController()
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(_navigationDelegate)
      ..loadRequest(oauthgrant.getAuthorizationUrl(Uri.parse(widget.keycloakConfig.redirectUri)));
    // on intercept le redirect, on le kill et on recup le authCode ( on ne navigue pas vers le redirect URi)
  }

  void log(String? msg) => setState(() {
        logmessage = msg;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Builder(builder: (context) {
      if (isNetworkError) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SomethingWenWrong(
                iconsize: 70,
                line1: "Erreur de réseaux",
                line2: "Verifiez votre connection internet",
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: reloading
                    ? const CircularProgressIndicator()
                    : TextButton(
                        onPressed: () {
                          controller.reload();
                          setState(() {
                            reloading = true;
                          });
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh),
                            Text("Réessayer"),
                          ],
                        )),
              )
            ],
          ),
        );
      }
      return Stack(
        children: [
          WebViewWidget(controller: controller),
          Align(
              alignment: Alignment.bottomCenter, child: Text(logmessage ?? ""))
        ],
      );
    }));
  }
}
