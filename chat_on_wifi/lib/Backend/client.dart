import 'dart:convert';
import 'dart:io';

void listenForServerBroadcasts(Function(String) onServerFound) async {
  final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 8888);

  socket.listen((RawSocketEvent event) {
    if (event == RawSocketEvent.read) {
      final dg = socket.receive();
      if (dg != null) {
        final message = utf8.decode(dg.data);
        if (message.startsWith("LAN_CHAT_SERVER:")) {
          final serverIp = message.split(":")[1];
          print("Discovered server IP: $serverIp");
          onServerFound(serverIp); // Call your connect function here
        }
      }
    }
  });
}
