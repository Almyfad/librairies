typedef ValidatorPredicate = bool Function(String value);

class ValidatorOptions {
  ValidatorOptions({
    RegExp? emailRegExp,
    RegExp? phoneRegExp,
    RegExp? ipv4RegExp,
    RegExp? ipv6RegExp,
    RegExp? urlRegExp,
    RegExp? numRegExp,
    RegExp? addressMACRegExp,
  })  : emailRegExp = emailRegExp ?? _defaultEmailRegExp,
        phoneRegExp = phoneRegExp ?? _defaultPhoneRegExp,
        ipv4RegExp = ipv4RegExp ?? _defaultIpv4RegExp,
        ipv6RegExp = ipv6RegExp ?? _defaultIpv6RegExp,
        urlRegExp = urlRegExp ?? _defaultUrlRegExp,
        numRegExp = numRegExp ?? _defaultnumRegExp,
        addressMACRegExp = addressMACRegExp ?? _defaultaddressMACRegExp;

  RegExp emailRegExp;
  RegExp phoneRegExp;
  RegExp ipv4RegExp;
  RegExp ipv6RegExp;
  RegExp urlRegExp;
  RegExp numRegExp;
  RegExp addressMACRegExp;

  static final RegExp _defaultEmailRegExp = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9\-\_]+(\.[a-zA-Z]+)*$");

  static final RegExp _defaultPhoneRegExp = RegExp(r'^\d{7,15}$');

  static final RegExp _defaultIpv4RegExp = RegExp(
      r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$');

  static final RegExp _defaultIpv6RegExp = RegExp(
      r'^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$');

  static final RegExp _defaultUrlRegExp = RegExp(
      r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)');

  static final RegExp _defaultnumRegExp = RegExp(r'^[0-9]*$');

  static final RegExp _defaultaddressMACRegExp =RegExp(r'^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$');




}
