class BadStatusCodeException implements Exception {
  int statusCode;
  String message;
  String body;

  BadStatusCodeException(this.statusCode, this.message, this.body);

  @override
  String toString() =>
      "BadStatusCodeException\nCode:$statusCode\nMessage:$message\nBody:$body";
}
