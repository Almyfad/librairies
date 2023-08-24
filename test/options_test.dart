import 'package:librairies/form_validator.dart';
import 'package:librairies/src/formvalidator/validator_options.dart';
import 'package:test/test.dart';

void main() {
  final cursedOptions = ValidatorOptions(
    emailRegExp: RegExp('abc'), // only accepts email containing 'abc'
    phoneRegExp: RegExp('123'), // only accepts phone number containing '123'
    ipv4RegExp: RegExp('not.ip'),
    ipv6RegExp: RegExp('not::ip'),
  );

  group('global options', () {
    setUp(() {
      ValidationBuilder.globalOptions = cursedOptions;
    });

    builder() => ValidationBuilder();

    test('email', () {
      expect(builder().email().test('user@example.org'), isNotNull);
    });

    test('phone', () {
      expect(builder().phone().test('+994000000000'), isNotNull);
    });

    test('ipv4', () {
      expect(builder().ip().test('127.0.0.1'), isNotNull);
    });

    test('ipv6', () {
      expect(builder().ip().test('1fca:2345::0'), isNotNull);
    });
  });

  group('local options', () {
    setUp(() {
      // reset global options to default state
      ValidationBuilder.globalOptions = ValidatorOptions();
    });

    builder() => ValidationBuilder(options: cursedOptions);

    test('email', () {
      expect(builder().email().test('user@example.org'), isNotNull);
    });

    test('phone', () {
      expect(builder().phone().test('+994000000000'), isNotNull);
    });

    test('ipv4', () {
      expect(builder().ip().test('127.0.0.1'), isNotNull);
    });

    test('ipv6', () {
      expect(builder().ip().test('1fca:2345::0'), isNotNull);
    });

    test('number', () {
      expect(builder().number().test('1fca:2345::0'), isNotNull);
      expect(builder().number().test('cvxvcxvxv'), isNotNull);
      expect(builder().number().test('1231.1321'), isNotNull);
      expect(builder().number().test('1424242'), isNull);
    });

    test('addresseMac', () {
      expect(builder().addresseMac().test('1fca:2345::0'), isNotNull);
      expect(builder().addresseMac().test('cvxvcxvxv'), isNotNull);
      expect(builder().addresseMac().test('1231.1321'), isNotNull);
      expect(builder().addresseMac().test('1424242zer'), isNotNull);
      expect(builder().addresseMac().test('00:B3:45:12:12:12:00'), isNotNull);
      expect(builder().addresseMac().test('00:B3:45:12:12:12:AA'), isNotNull);
      expect(builder().addresseMac().test('00:X0:D0:63:C2:26'), isNotNull);
      expect(builder().addresseMac().test('00:G0:D0:63:C2:26'), isNotNull);


      expect(builder().addresseMac().test('00:B0:D0:63:C2:26'), isNull);
      expect(builder().addresseMac().test('12:23:45:12:12:12'), isNull);
      expect(builder().addresseMac().test('00:B3:45:12:12:12'), isNull);
    });
  });
}
