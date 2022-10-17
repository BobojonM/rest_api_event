import 'dart:io';

import 'package:rest_api_event/models/rest_api_response.dart';
import 'package:rest_api_event/models/event.dart';
import 'package:rest_api_event/provider/provider.dart';
import 'package:flutter/widgets.dart';

class ApiEvent<T> extends Event<ApiResponse<T>> {
  final Provider provider = Provider();

  final String service;
  final HttpMethod httpMethod;
  final T Function(String body) parser;

  HttpClientResponse response;

  ApiEvent({@required this.service, @required this.httpMethod, this.parser})
      : assert(service != null && service.isNotEmpty && httpMethod != null);

  bool get isCompleted => this.value != null ? this.value.status == Status.COMPLETED : Status.LOADING == Status.ERROR;
  bool get isError => this.value != null ? this.value.status == Status.ERROR : Status.LOADING == Status.ERROR;

  @override
  void publish(ApiResponse<dynamic> event) {
    ApiResponse<T> response = ApiResponse<T>(event);
    subject.sink.add(response);
  }

  Future<ApiResponse<T>> run(
          {String params,
          String body,
          Map<String, String> headers,
          List<Cookie> cookies}) async =>
      await provider.run(this, params, body, headers, cookies);
}

enum HttpMethod { GET, POST, PUT, DELETE }

extension ParseToString on HttpMethod {
  String get asString => this.toString().split('.').last;
}
