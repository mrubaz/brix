// brix_network against a public test API.
//
// Run: dart run example/main.dart
import 'package:brix_network/brix_network.dart';

class Todo {
  Todo({required this.id, required this.title, required this.done});

  factory Todo.fromJson(Json json) => Todo(
    id: json.integer('id'),
    title: json.string('title'),
    done: json.boolean('completed'),
  );

  final int id;
  final String title;
  final bool done;
}

Future<void> main() async {
  // This API answers with the data itself, no {data: ...} envelope.
  final api = BrixApi(
    baseUrl: 'https://jsonplaceholder.typicode.com/',
    reader: ResponseReader.custom((response) => ApiReply(data: response.body)),
    logger: PrettyNetworkLogger(maxLines: 8),
  );

  final todos = await api.get(
    'todos',
    query: {'_limit': 3},
    parse: (data) => data.items(Todo.fromJson),
  );

  switch (todos) {
    case Success(:final data):
      for (final todo in data) {
        print('${todo.done ? '✓' : '·'} ${todo.title}');
      }
    case Failed(:final failure):
      print('Could not load: ${failure.displayMessage}');
  }

  api.close();
}
