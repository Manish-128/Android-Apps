import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';

void startBroadcastingServerIP() async {
  final info = NetworkInfo();
  final serverIp = await info.getWifiIP();

  if (serverIp == null) {
    print("Not connected to Wi-Fi.");
    return;
  }

  final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 8888);
  socket.broadcastEnabled = true;

  Timer.periodic(Duration(seconds: 2), (_) {
    final message = utf8.encode("LAN_CHAT_SERVER:$serverIp");
    socket.send(message, InternetAddress("224.0.0.1"), 8888);
    print("Broadcasted IP: $serverIp");
  });
}
