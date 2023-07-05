import 'dart:async';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// Create a map to store the WebSocket channels
final Map<String, WebSocketSink> webSockets = {};

// Define the WebSocket endpoint
void webSocketHandler(WebSocketChannel channel) {
  print(channel);
  // Add the channel to the map when a new WebSocket connection is established
  webSockets[channel.hashCode.toString()] = channel.sink;

  channel.stream.listen((message) {
    // Process the incoming WebSocket message here
    // You can emit events and perform other actions

    // Send a response back
    channel.sink.add('Received: $message');
  });

  // Remove the channel from the map when the WebSocket connection is closed
  channel.sink.done.then((_) {
    webSockets.remove(channel.hashCode.toString());
  });
}

// Define the endpoint that triggers WebSocket messages
Response triggerWebSocketMessage(Request request) {
  // Get the WebSocket channel's ID from the request parameters or headers
  final channelId = request.headers['channel-id'];

  // Get the WebSocket sink associated with the channel ID
  final sink = webSockets[channelId];

  // Send a message through the WebSocket
  sink?.add('Hello, WebSocket!');

  // Return a response
  return Response.ok('WebSocket message sent');
}

// Create the Shelf application
var app = Router()
  ..get('/ws', webSocketHandler) // Map the WebSocket endpoint
  ..get('/send-message', triggerWebSocketMessage); // Map the endpoint to trigger WebSocket messages

// Create the server
Future<void> main() async {
  var server = await serve(app, '0.0.0.0', 8089);
  print('Server started on port ${server.port}');
}
