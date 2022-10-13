import 'package:rest_api_event/models/event.dart';
import 'package:rest_api_event/ui/event_builder.dart';
import 'package:flutter/material.dart';

class LocalWidget extends StatelessWidget {
  final Event<bool> event = Event<bool>();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text("Local Event"),
          EventWidget(event),
          ButtonWidget(event),
        ],
      ),
    );
  }
}

class EventWidget extends StatelessWidget {
  final Event event;

  const EventWidget(this.event, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EventBuilder(
        event: event, builder: (context, data) => Text(data.toString()));
  }
}

class ButtonWidget extends StatelessWidget {
  final Event event;

  const ButtonWidget(this.event, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () =>
            event.publish(event.value == null ? false : !event.value),
        child: Text("Change state"));
  }
}
