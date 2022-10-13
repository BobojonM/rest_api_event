import 'dart:convert';

class Collector {
  bool isActive = false;

  List<Map<String, dynamic>> collection = [];

  void add(String requestUrl, String requestMethod, String requestBody,
      Map requestHeaders, int statusCode, String responseBody) {
    if (isActive)
      collection.add({
        "requestUrl": requestUrl,
        "requestMethod": requestMethod,
        "requestHeaders": requestHeaders,
        "requestBody": requestBody,
        "statusCode": statusCode,
        "responseBody": responseBody,
        "extra": null
      });
  }

  String get() => json.encode(collection);
}
