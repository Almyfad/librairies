import 'package:flutter/services.dart';

class TimeFormatter extends TextInputFormatter {
final bool enableSeconds;

  TimeFormatter({this.enableSeconds = false});

  int get maxdigits => enableSeconds ? 6 : 8;
  String get hint => enableSeconds ? "--:--:--" : "--:--";

  String padTemplate(String value) {
    value =
        value.replaceAll("-", "").replaceAll(":", "").padRight(maxdigits, "-");
    return enableSeconds
        ? "${value.substring(0, 2)}:${value.substring(2, 4)}:${value.substring(4, 6)}"
        : "${value.substring(0, 2)}:${value.substring(2, 4)}";
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var nwvalue = newValue.text.replaceAll("-", "").replaceAll(":", "");

    if (newValue.text.length < oldValue.text.length) {
      var oldvalue = oldValue.text.replaceAll("-", "").replaceAll(":", "");

      if (oldvalue.isNotEmpty) {
        oldvalue = oldvalue.substring(0, oldvalue.length - 1);
        oldvalue = padTemplate(oldvalue);
      }

      return newValue.copyWith(
          text: oldvalue,
          selection: TextSelection(
              baseOffset: oldvalue.indexOf("-"),
              extentOffset: oldvalue.indexOf("-")));
    }

    switch (nwvalue.length) {
      case 0:
        return newValue.copyWith(
            text: padTemplate(nwvalue),
            selection: const TextSelection(baseOffset: 0, extentOffset: 0));
      case 1:
        var rex = RegExp(r'^[0-2]$');
        if (rex.hasMatch(nwvalue)) {
          return newValue.copyWith(
              text: padTemplate(nwvalue),
              selection: const TextSelection(baseOffset: 1, extentOffset: 1));
        }
        rex = RegExp(r'^[3-9]$');
        if (rex.hasMatch(nwvalue)) {
          return newValue.copyWith(
              text: padTemplate("0$nwvalue"),
              selection: const TextSelection(baseOffset: 3, extentOffset: 3));
        }
        return oldValue;
      case 2:
        var rex = RegExp(r'^[0-1][0-9]|2[0-3]$');
        if (rex.hasMatch(nwvalue)) {
          return newValue.copyWith(
              text: padTemplate(nwvalue),
              selection: const TextSelection(baseOffset: 3, extentOffset: 3));
        }
        rex = RegExp(r'^2[4-9]|[3-9][0-9]$');
        if (rex.hasMatch(nwvalue)) {
          return newValue.copyWith(
              text: padTemplate("23"),
              selection: const TextSelection(baseOffset: 3, extentOffset: 3));
        }
        return oldValue;
      case 3:
        var rex = RegExp(r'^([0-1][0-9]|2[0-3])([0-5])$');
        if (rex.hasMatch(nwvalue)) {
          return newValue.copyWith(
              text: padTemplate(nwvalue),
              selection: const TextSelection(baseOffset: 4, extentOffset: 4));
        }
        rex = RegExp(r'^([0-1][0-9]|2[0-3])[6-9]$');
        if (rex.hasMatch(nwvalue)) {
          return newValue.copyWith(
              text: padTemplate(
                  "${nwvalue.substring(0, nwvalue.length - 1)}0${nwvalue.substring(nwvalue.length - 1)}"),
              selection: const TextSelection(baseOffset: 6, extentOffset: 6));
        }
        return oldValue;
      case 4:
        var rex = RegExp(r'^([0-1][0-9]|2[0-3])([0-5][0-9])');
        if (rex.hasMatch(nwvalue)) {
          return newValue.copyWith(
              text: padTemplate(nwvalue),
              selection: const TextSelection(baseOffset: 6, extentOffset: 6));
        }

        return oldValue;
      case 5:
        if (enableSeconds == false) return oldValue;
        var rex = RegExp(r'^([0-1][0-9]|2[0-3])([0-5][0-9])([0-5])');
        if (rex.hasMatch(nwvalue)) {
          return newValue.copyWith(
              text: padTemplate(nwvalue),
              selection: const TextSelection(baseOffset: 7, extentOffset: 7));
        }

        rex = RegExp(r'^([0-1][0-9]|2[0-3])([0-5][0-9])([6-9])');
        if (rex.hasMatch(nwvalue)) {
          return newValue.copyWith(
              text: padTemplate(
                  "${nwvalue.substring(0, nwvalue.length - 1)}0${nwvalue.substring(nwvalue.length - 1)}"),
              selection: const TextSelection(baseOffset: 8, extentOffset: 8));
        }
        return oldValue;
      case 6:
        var rex = RegExp(r'^([0-1][0-9]|2[0-3])([0-5][0-9])([0-5][0-9])$');
        if (rex.hasMatch(nwvalue)) {
          return newValue.copyWith(
              text: padTemplate(nwvalue),
              selection: const TextSelection(baseOffset: 8, extentOffset: 8));
        }
        return oldValue;

      default:
        return oldValue;
    }
  }
}
