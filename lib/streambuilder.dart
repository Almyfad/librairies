import 'package:flutter/material.dart';
import 'package:librairies/somethingwentwrong.dart';

class EnhancedStreamBuilder<T> extends StatelessWidget {
  final Stream<T> stream;
  final Widget? progressIndicator;
  final Widget? noelement;
  final Widget? error;
  final Widget Function(BuildContext context, AsyncSnapshot<T> snapshot)
      builder;

  const EnhancedStreamBuilder(
      {Key? key,
      required this.stream,
      this.progressIndicator,
      this.noelement,
      this.error,
      required this.builder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
        stream: stream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return const Center(
                child: SizedBox(
                  height: 70,
                  child: SomethingWenWrong(
                    line1: "network issue",
                  ),
                ),
              );
            case ConnectionState.waiting:
              return progressIndicator ?? CircularProgressIndicator();
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.hasError) {
                return error ??
                    Center(
                      child: SizedBox(
                        height: 70,
                        child: SomethingWenWrong(
                          line1: snapshot.error.toString(),
                        ),
                      ),
                    );
              }
              if (!snapshot.hasData) {
                return noelement ??
                    const Center(
                      child: SizedBox(
                        height: 70,
                        child: SomethingWenWrong(
                          line1: "No Data",
                        ),
                      ),
                    );
              }
              return builder(context, snapshot);
          }
        });
  }
}
