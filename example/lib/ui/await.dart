import 'package:flutter/material.dart';
import 'package:rest_api_event/rest_api_event.dart';

import '../events.dart';

class AwaitWidget extends StatefulWidget {
  @override
  _AwaitWidgetState createState() => _AwaitWidgetState();
}

class _AwaitWidgetState extends State<AwaitWidget> {
  @override
  void initState() {
    TodoEvents.todos.run();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(50),
      child: EventBuilder(
        event: TodoEvents.todos,
        completed: (data) => Center(
            child: ListView.separated(
                separatorBuilder: (context, index) => Divider(),
                itemCount: data.length,
                itemBuilder: (context, index) => Text(data[index].title))),
      ),
    );
  }
}
