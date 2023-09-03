sealed class ApiException  implements Exception {
}

class UnExpectedPath extends ApiException {
  final String? message;
  UnExpectedPath({this.message});
  @override
  String toString() {
    return 'UnExpectedPath: $message';
  }
}

class NotFound extends ApiException {
  final String? message;
  NotFound({this.message});
  @override
  String toString() {
    return 'NotFoundException: $message';
  }
}
class Internal extends ApiException {
  final String? message;
  Internal({this.message});
  @override
  String toString() {
    return 'NotFoundException: $message';
  }
}
class UnAuthorise extends ApiException {
  final String? message;
  UnAuthorise({this.message});
  @override
  String toString() {
    return 'UnAuthoriseException: $message';
  }
}

class TimeOut extends ApiException {
  TimeOut();
}