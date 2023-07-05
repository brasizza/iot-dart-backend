import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final Map<String, WebSocketSink> webSockets = {};

void main(List<String> args) async {
  var app = Router();

  // var wsHandle = webSocketHandler((WebSocketChannel channel, Request request) {
  //   final headers = request.headers;

  //   print(headers);

  //   webSockets[channel.hashCode.toString()] = channel.sink;

  //   channel.stream.listen((message) {
  //     print(message);
  //   });

  //   channel.sink.done.then((_) {
  //     webSockets.remove(channel.hashCode.toString());
  //   });
  // });

  app.get('/', (Request r) {
    return Response.ok('hello-world');
  });

  app.get('/ws', (Request request) {
    return webSocketHandler((WebSocketChannel channel) {
      // Access the headers from the original request
      final headers = request.headers;
      print(headers);

      webSockets[headers['serialno'] ?? '123'] = channel.sink;

      channel.stream.listen((message) {
        print(message);
      });
    })(request);
  });

  app.post('/send-message', triggerWebSocketMessage); // Map the endpoint to trigger WebSocket messages
  var server = await io.serve(app, '0.0.0.0', 80);
  print("Server is on at ${server.address.host} ${server.port}");
}

Future<Response> triggerWebSocketMessage(Request request) async {
  final channelId = request.headers['channel-id'];
  final sink = webSockets[channelId];
  final value = await request.readAsString();
  sink?.add(value);
  return Response.ok('WebSocket message sent');
}
