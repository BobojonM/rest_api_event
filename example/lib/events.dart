import 'package:rest_api_event/rest_api_event.dart';
import './models/todo.dart';

class TodoEvents {
  static final ApiEvent<List<Todo>> todos = ApiEvent(
      service: "todos", httpMethod: HttpMethod.GET, parser: Todo.todosParser);
  static final ApiEvent<Todo> todo = ApiEvent(
      service: "todo", httpMethod: HttpMethod.GET, parser: Todo.todoParser);
}
