import 'dart:convert' as convert;

class Todo {
  String title;

  Todo(this.title);

  Todo.fromJson(Map<String, dynamic> json) {
    title = json["title"];
  }

  static Todo todoParser(String body) {
    Map json = convert.json.decode(body);
    return Todo.fromJson(json);
  }

  static List<Todo> todosParser(String body) {
    List json = convert.json.decode(body);
    List<Todo> todos = [];

    for (Map object in json) todos.add(Todo.fromJson(object));

    return todos;
  }
}
