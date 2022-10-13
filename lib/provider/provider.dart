import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:rest_api_event/exceptions/bad_status_code_exception.dart';
import 'package:rest_api_event/models/rest_api_event.dart';
import 'package:rest_api_event/models/rest_api_response.dart';
import 'package:rest_api_event/utils/collector.dart';
import 'package:rest_api_event/utils/printer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class Provider {
  static Collector collector = Collector();
  static Printer printer = Printer();

  static String serviceIsUnavailableMessage = "Сервис недоступен";
  static String internalErrorMessage = "Возникла внутренняя ошибка";
  static String noInternetConnectionMessage = "Отсутствует интернет-соединение";
  static String requestTimeoutMessage = "Время ожидания запроса истекло";

  static String url;
  static Duration timeout = Duration(seconds: 30);
  static String Function(HttpClientResponse response, String body)
      onRequestDone;

  Future<dynamic> run(ApiEvent event, String params, String body,
      Map<String, String> headers, List<Cookie> cookies) async {
    event.publish(ApiResponse.loading());

    Stopwatch stopwatch;
    if (Printer.mode == PrinterMode.FULL) stopwatch = Stopwatch()..start();

    HttpClient httpClient;

    try {
      httpClient = HttpClient();
      httpClient.connectionTimeout = timeout;

      String url =
          (Provider.url ?? "") + event.service + (params != null ? params : "");
      Uri uri = Uri.parse(url);

      HttpClientRequest request;

      switch (event.httpMethod) {
        case HttpMethod.GET:
          request = await httpClient.getUrl(uri);
          break;
        case HttpMethod.POST:
          request = await httpClient.postUrl(uri);
          break;
        case HttpMethod.PUT:
          request = await httpClient.putUrl(uri);
          break;
        case HttpMethod.DELETE:
          request = await httpClient.deleteUrl(uri);
          break;
      }

      Map<String, String> headersBuilder = {};

      headersBuilder.addAll(headers ?? {});

      if (cookies != null && cookies.isNotEmpty)
        headersBuilder.addAll({
          "cookie": cookies
              .map((Cookie cookie) => '${cookie.name}=${cookie.value}')
              .join('; ')
        });

      headersBuilder.forEach((key, value) {
        request.headers.add(key, value);
      });

      if (body != null && body.isNotEmpty) {
        List<int> bodyBytes = utf8.encode(body);
        request.add(bodyBytes);
      }

      printer.info(
          _getRequestMessage(url, headersBuilder, body, event.httpMethod));

      HttpClientResponse response = await request.close();

      final Completer<String> completer = Completer();
      final StringBuffer contents = StringBuffer();
      response.transform(utf8.decoder).listen((data) {
        contents.write(data);
      }, onDone: () => completer.complete(contents.toString()));

      String responseBody = await completer.future;

      collector.add(url, event.httpMethod.asString, body, headersBuilder,
          response.statusCode, responseBody);

      if (onRequestDone != null) {
        String onRequestDoneResult = onRequestDone(response, responseBody);
        if (onRequestDoneResult != null) {
          event.publish(ApiResponse.canceled(message: onRequestDoneResult));
          return event.value;
        }
      }

      event.response = response;

      if (200 <= response.statusCode && response.statusCode <= 299) {
        if (event.parser != null) {
          final data = await compute(event.parser, responseBody);
          event.publish(ApiResponse.completed(data: data));
        } else
          event.publish(ApiResponse.completed(data: responseBody));
      } else
        throw BadStatusCodeException(
            response.statusCode, internalErrorMessage, responseBody);
    } on BadStatusCodeException catch (exception) {
      printer.exception(exception.toString());

      event.publish(ApiResponse.error(
          statusCode: exception.statusCode,
          message: exception.message,
          body: exception.body));
    } on TimeoutException catch (exception) {
      printer.exception(exception.toString());

      event.publish(ApiResponse.error(message: requestTimeoutMessage));
    } catch (exception) {
      printer.exception(exception.toString());

      ApiResponse errorApiResponse = await _onException(exception);
      event.publish(errorApiResponse);
    } finally {
      if (httpClient != null) httpClient.close();
      if (stopwatch != null) {
        printer.info("Request completed in " + stopwatch.elapsed.toString());
        stopwatch.stop();
      }
    }

    return event.value;
  }

  Future<ApiResponse> _onException(exception) async {
    bool internetStatus = await checkInternetConnection();

    return internetStatus
        ? exception.runtimeType == SocketException
            ? ApiResponse.error(message: serviceIsUnavailableMessage)
            : ApiResponse.error(message: internalErrorMessage)
        : ApiResponse.error(message: noInternetConnectionMessage);
  }

  static Future<bool> checkInternetConnection() async {
    try {
      ConnectivityResult connectivityResult =
          await Connectivity().checkConnectivity();

      return connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi;
    } catch (exception) {
      return false;
    }
  }

  String _getRequestMessage(
          String url, Map headers, String body, HttpMethod httpMethod) =>
      "Executing ${httpMethod.asString} request with timeout ${Provider.timeout.toString()}\nURL: $url\nHeaders: $headers\nBody: $body";
}
