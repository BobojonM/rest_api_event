# Solution for calling APIs
[![pub](https://img.shields.io/pub/v/rest_api_event.svg)](https://pub.dev/packages/rest_api_event)
## Get started
* Specify the path to your service:
```dart
Provider.url = "https://localhost:8080/rest/";
```

### ApiEvent
Used to get a response from a service call and control server events.
* Create a model for data with a static method that parses the response body into the data you want (this parser will be called in another ```Isolate```):<br>
```static T parser(String body)```
```dart
class Todo {
  String title;
  
  Todo.fromJson(Map<String, dynamic> json) {
    title = json["title"];
  }

  static List<Todo> parser(String body) {
    List json = convert.json.decode(body);
    List<Todo> todos = [];
    for (Map object in json) todos.add(Todo.fromJson(object));
    return todos;
  }
}
```
* Create an ```ApiEvent``` for the desired service:
```dart
ApiEvent<List<Todo>> todos = ApiEvent(
    service: "todos", 
    httpMethod: HttpMethod.GET, 
    parser: Todo.getParser,
    /// (optional)
    /// saveAuthToken: if request is successful -> save the authorization token from the cookie,
    /// auth: use saved authorization token in the header
);
```

* Just run event:
```dart
todos.run({params, body}); /// (optional) params, body
```

### Event view

* Event UI View:
```dart
EventBuilder(
    event: todos,
    completed: (data) => ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) => Text(data[index].title),
    ),
    /// (optional)
    /// initial: widget at initialization, if not specified, then loading
    /// loading: widget on call
    /// error: function with an error message that returns widget
),
```

* Full example of a widget to get a todo list from https://localhost:8080/rest/todos service:
```dart
class _AwaitWidgetState extends State<AwaitWidget> {
  final ApiEvent<List<Todo>> todos = ApiEvent(
      service: "todos", httpMethod: HttpMethod.GET, parser: Todo.getParser);

  @override
  void initState() {
    todos.run();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return EventBuilder(
      event: todos,
      completed: (data) => Center(
          child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) => Text(data[index].title))),
    );
  }
}
```

### Event
Used to control client events.

* Definition of an event reacting to changes and its view:
```dart
Event<bool> event = Event<bool>();
```
```dart
EventBuilder(event: event, builder: (context, data) => Text(data.toString()))
```
