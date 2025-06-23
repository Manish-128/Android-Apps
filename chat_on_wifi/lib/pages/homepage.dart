import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'dart:io';

import '../Backend/client.dart';
import '../Backend/server.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  final _controller = TextEditingController();
  final _ipController = TextEditingController();
  final _nameController = TextEditingController();

  String serverUser = "";
  String clientUser = "";

  String log = '';
  ServerSocket? _server;
  Socket? _clientSocket;
  Socket? _serverConnectedClient;

  bool isServer = false;
  bool isConnected = false;

  void _log(String msg) {
    setState(() {
      log += msg + '\n';
    });
  }

  Future<void> startServer() async {
    if (_nameController.text.isNotEmpty) {
      serverUser = _nameController.text.trim();
      final ip = await NetworkInfo().getWifiIP();
      _server = await ServerSocket.bind(InternetAddress.anyIPv4, 9999);
      isServer = true;
      isConnected = true;
      _log("📡 Server started on $ip:9999");

      _server!.listen((Socket client) {
        _log("🔗 Client connected: ${client.remoteAddress.address}");
        _serverConnectedClient = client;
        bool nameReceived = false;

        client.listen((data) {
          final msg = String.fromCharCodes(data);
          if (!nameReceived) {
            clientUser = msg.trim();
            nameReceived = true;
            _log("👤 Client name received: $clientUser");

            // 🟢 Send server name to client now
            client.write(serverUser);
          } else {
            _log("📥 $clientUser: $msg");
          }
        });
      });

      setState(() {});
    } else {
      _log("⚠️ Enter a name to start server!");
    }
  }

  Future<void> connectToServer(String ip) async {
    if (_nameController.text.isNotEmpty) {
      serverUser = _nameController.text.trim();
      try {
        _clientSocket = await Socket.connect(ip, 9999);
        _log("✅ Connected to $ip:9999");
        isConnected = true;

        _clientSocket!.write(_nameController.text.trim());
        bool nameReceived = false;

        _clientSocket!.listen((data) {
          final msg = String.fromCharCodes(data).trim();
          if (!nameReceived) {
            clientUser = msg; // this is the server’s name
            _log("👤 Connected to: $clientUser");
            nameReceived = true;
          } else {
            _log("📥 $clientUser: $msg");
          }
        });

        setState(() {});
      } catch (e) {
        _log("❌ Connection failed: $e");
      }
    } else {
      _log("⚠️ Enter a name to join server!");
    }
  }

  void sendMessage(String message) {
    if (_clientSocket != null) {
      _clientSocket!.write(message);
      _log("📤 You: $message");
    } else if (_serverConnectedClient != null) {
      _serverConnectedClient!.write(message);
      _log("📤 You: $message");
    } else {
      _log("⚠️ No active connection to send.");
    }
    _controller.clear();
  }

  void stopCommunication() {
    _server?.close();
    _clientSocket?.close();
    _serverConnectedClient?.close();

    _server = null;
    _clientSocket = null;
    _serverConnectedClient = null;

    isServer = false;
    isConnected = false;
    serverUser = "";
    clientUser = "";
    log = "";
    _controller.clear();
    _ipController.clear();
    _nameController.clear();

    setState(() {});
  }

  @override
  void dispose() {
    _server?.close();
    _clientSocket?.close();
    _serverConnectedClient?.close();
    super.dispose();
  }


  void startFullServer() {
    startServer(); // 🟢 Your actual TCP socket server logic
    startBroadcastingServerIP(); // 📢 Broadcast the server IP over LAN
  }

  void startClient() {
    print("Start Client being called ");
    listenForServerBroadcasts((serverIp) {
      print("Server Ip found is : $serverIp");
      connectToServer(serverIp); // 🔌 Try connecting to the announced IP
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6D4C41),
        title: const Text("LAN Messenger", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: isConnected
                  ? _buildButton("Stop Communication", stopCommunication, key: const ValueKey('stop'))
                  : Column(
                key: const ValueKey('start'),
                children: [
                  Row(
                    children: [
                      const Text("Your Name: "),
                      Expanded(
                        child: _buildTextField(
                          controller: _nameController,
                          hint: "Enter A Name",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // Expanded(
                      //   child: _buildTextField(
                      //     controller: _ipController,
                      //     hint: "Enter Server IP",
                      //   ),
                      // ),
                      // const SizedBox(width: 10),
                      _buildButton("Join", () => startClient()),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildButton("Start Server", isServer ? null : startServer),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _controller,
                    hint: "Type your message",
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF8EAC50)),
                  onPressed: () => sendMessage(_controller.text),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                width: double.maxFinite - 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5DC),
                  border: Border.all(color: const Color(0xFFBCAAA4)),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  reverse: true,
                  child: Text(
                    log,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4E342E),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF5F5DC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.brown.shade200),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildButton(String text, VoidCallback? onPressed, {Key? key}) {
    return ElevatedButton(
      key: key,
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8EAC50),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(text),
    );
  }
}
