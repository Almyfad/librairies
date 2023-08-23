import 'package:librairies/form_validator.dart';
import 'package:test/test.dart';

void checkValidation(
  StringValidationCallback validate, {
  List<String?> validValues = const [],
  List<String?> invalidValues = const [],
}) {
  if (validValues.isNotEmpty) {
    for (var value in validValues) {
      expect(validate(value), isNull, reason: '"$value" is valid value');
    }
  }

  if (invalidValues.isNotEmpty) {
    for (var value in invalidValues) {
      expect(validate(value), isNotNull, reason: '"$value" is invalid value');
    }
  }
}
