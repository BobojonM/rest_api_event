import 'package:rest_api_event/rest_api_event.dart';
import 'package:rest_api_event/utils/printer.dart';
import 'package:flutter/material.dart';

import 'ui/await.dart';
import 'ui/event.dart';

void main() {
  Provider.url = "https://jsonplaceholder.typicode.com/";
  Printer.mode = PrinterMode.FULL;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Expanded(child: AwaitWidget()),
            Expanded(child: LocalWidget()),
          ],
        ),
      ),
    );
  }
}
