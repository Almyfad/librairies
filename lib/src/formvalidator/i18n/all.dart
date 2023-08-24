import '../locale.dart';
import 'en.dart';
import 'fr.dart';


const localeMap = <String, FormValidatorLocale>{
  'fr': LocaleFr(),
  'en': LocaleEn(),
};

final supportedLocales = localeMap.keys.toList();

FormValidatorLocale createLocale(String locale) {
  if (locale == 'default') locale = 'en';

  final result = localeMap[locale];
  if (result != null) return result;

  throw ArgumentError.value(
    locale,
    'locale',
    'Form validation locale is not yet supported.',
  );
}
