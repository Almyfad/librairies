// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class SomethingWenWrong extends StatelessWidget {
  const SomethingWenWrong({
    Key? key,
    this.line1,
    this.line2,
    this.iconsize,
  }) : super(key: key);

  final String? line1;
  final String? line2;
  final double? iconsize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.warning,
          color: Colors.yellow,
          size: iconsize,
        ),
        SelectableText(
          line1 ?? 'Une Erreure est survenue...',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.redAccent),
        ),
        SelectableText(line2 ?? "",
            style: const TextStyle(
                color: Colors.redAccent,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w300)),
      ],
    );
  }
}
