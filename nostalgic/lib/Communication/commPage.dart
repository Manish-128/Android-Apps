import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommPage extends StatefulWidget {
  String StarterID;
  String JoinerID;
  String ConnID;
  String Conn_Type;
  CommPage({required this.StarterID, required this.JoinerID, required this.ConnID , required this.Conn_Type,super.key});

  @override
  State<CommPage> createState() => _CommPageState();
}

class _CommPageState extends State<CommPage> {
  RTCPeerConnection? _peerConnection;
  RTCDataChannel? _dataChannel;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController messageController = TextEditingController();
  final List<Map<String, dynamic>> messages = [];
  final ScrollController _scrollController = ScrollController();
  String _status = 'Disconnected';
  StreamSubscription? _firestoreSubscription;
  bool _isInitiator = false;
  bool _inCall = false;
  bool _isJoiner = false;

  @override
  void initState() {
    super.initState();
    if(widget.Conn_Type == "starter"){
      _createOffer();
    }else if(widget.Conn_Type == "joiner"){
      _joinChat();
    }
  }

  Future<void> _setupWebRTC() async {
    try {
      final configuration = {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
          {'urls': 'stun:stun1.l.google.com:19302'},
          {
            'urls': 'turn:your.turn.server:3478',
            'username': 'your_username',
            'credential': 'your_password',
          },
        ],
        'sdpSemantics': 'unified-plan',
      };

      _peerConnection = await createPeerConnection(configuration);
      print('WebRTC setup initiated for ${_isInitiator
          ? "Initiator"
          : "Joiner"}');

      _peerConnection?.onIceCandidate = (candidate) async {
        if (!mounted) return;
        await _firestore
            .collection('chat rooms')
            .doc(widget.ConnID)
            .collection('candidates')
            .add({
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        }); // Extra write - Each ICE candidate adds a write; can accumulate (5-10+ per session)
      };

      _peerConnection?.onConnectionState = (state) {
        if (!mounted) return;
        setState(() {
          switch (state) {
            case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
              _status = 'Connected';
              _inCall = true;
              break;
            case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
              _status = 'Connection Failed';
              _inCall = false;
              print('Connection failed for ${_isInitiator
                  ? "Initiator"
                  : "Joiner"}');
              _reinitializeConnection();
              break;
            case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
              _status = 'Disconnected';
              _inCall = false;
              print('RTC peer connection disconnected for ${_isInitiator
                  ? "Initiator"
                  : "Joiner"}');
              _reinitializeConnection();
              break;
            case RTCPeerConnectionState.RTCPeerConnectionStateClosed:
              _status = 'Closed';
              _inCall = false;
              break;
            default:
              _status = 'Connecting...';
          }
          print('Connection state: $state for ${_isInitiator
              ? "Initiator"
              : "Joiner"}');
        });
      };

      _peerConnection?.onDataChannel = (channel) {
        if (!mounted) return;
        _dataChannel = channel;
        _setupDataChannelListeners();
      };

      _peerConnection?.onTrack = (event) {
        if (!mounted) return;
        setState(() {
          _remoteStream = event.streams[0];
          print('Received remote stream for ${_isInitiator
              ? "Initiator"
              : "Joiner"}');
        });
      };

      if (_isInitiator) {
        _dataChannel = await _peerConnection?.createDataChannel(
          'chat',
          RTCDataChannelInit()
            ..id = 1,
        );
        _setupDataChannelListeners();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'Error setting up WebRTC: $e');
      print('WebRTC setup error: $e for ${_isInitiator
          ? "Initiator"
          : "Joiner"}');
    }
  }

  Future<void> _reinitializeConnection() async {
    if (_status == 'Disconnected' || _status == 'Connection Failed') {
      print('Reinitializing connection for ${_isInitiator
          ? "Initiator"
          : "Joiner"}');
      await _setupWebRTC(); // Extra reads/writes - Triggers full setup again, including ICE candidates
      if (_isInitiator) {
        await _createOffer(); // Extra write - New offer write
      } else {
        await _joinChat(); // Extra read/write - New get/update cycle
      }
    }
  }

  void _setupDataChannelListeners() {
    _dataChannel?.onMessage = (message) {
      if (!mounted) return;
      _handleReceivedMessage(message);
    };
    _dataChannel?.onDataChannelState = (state) {
      if (!mounted) return;
      setState(() {
        _status = 'Connected (Channel: $state)';
        if (state == RTCDataChannelState.RTCDataChannelClosed) {
          _status = 'Disconnected';
          print("Data channel closed for ${_isInitiator
              ? "Initiator"
              : "Joiner"}");
          _reinitializeDataChannel();
        }
      });
    };
  }

  Future<void> _reinitializeDataChannel() async {
    if (_isInitiator && _peerConnection != null) {
      _dataChannel = await _peerConnection!.createDataChannel(
        'chat',
        RTCDataChannelInit()
          ..id = 1,
      ); // Extra write - Indirectly triggers ICE candidates again
      _setupDataChannelListeners();
      print('Data channel reinitialized for Initiator');
    }
  }

  void _handleReceivedMessage(RTCDataChannelMessage message) {
    if (message.isBinary) {
      setState(() {
        messages.add(
            {'type': 'image', 'content': message.binary, 'isMe': false, 'deletion_number': 0});
        _scrollToBottom();
      });
    } else {
      setState(() {
        messages.add({'type': 'text', 'content': message.text, 'isMe': false, 'deletion_number': 0});
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        if (!mounted) return;
        setState(() => _status = 'No image selected.');
        print('ImagePicker returned null on Phone ${_isInitiator
            ? "1 (Initiator)"
            : "2 (Joiner)"}');
        return;
      }

      final bytes = await pickedFile.readAsBytes();
      if (bytes == null || bytes.isEmpty) {
        if (!mounted) return;
        setState(() => _status = 'Failed to read image bytes.');
        print('Image bytes are null or empty on Phone ${_isInitiator
            ? "1 (Initiator)"
            : "2 (Joiner)"}');
        return;
      }

      final compressedBytes = await _compressImage(bytes);
      if (compressedBytes == null) {
        if (!mounted) return;
        setState(() => _status = 'Failed to compress image.');
        return;
      }

      if (_dataChannel == null) {
        if (!mounted) return;
        setState(() => _status = 'Data channel is null.');
        print('DataChannel is null on Phone ${_isInitiator
            ? "1 (Initiator)"
            : "2 (Joiner)"}');
        return;
      }

      if (_dataChannel!.state != RTCDataChannelState.RTCDataChannelOpen) {
        if (!mounted) return;
        setState(() =>
        _status = 'Data channel not open: ${_dataChannel!.state}');
        print('DataChannel state: ${_dataChannel!.state} on Phone ${_isInitiator
            ? "1 (Initiator)"
            : "2 (Joiner)"}');
        return;
      }

      _dataChannel!.send(RTCDataChannelMessage.fromBinary(compressedBytes));
      setState(() {
        messages.add(
            {'type': 'image', 'content': compressedBytes, 'isMe': true, 'deletion_number':0});
        _scrollToBottom();
        print('Image sent successfully from Phone ${_isInitiator
            ? "1 (Initiator)"
            : "2 (Joiner)"}');
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'Error sending image: $e');
      print('Error sending image on Phone ${_isInitiator
          ? "1 (Initiator)"
          : "2 (Joiner)"}: $e');
    }
  }

  Future<Uint8List?> _compressImage(Uint8List bytes) async {
    try {
      final image = img.decodeImage(bytes);
      if (image == null) return null;
      final resized = img.copyResize(image, width: 800);
      return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  Future<void> _startVoiceCall() async {
    if (_inCall || _peerConnection == null) return;

    try {
      _localStream = await navigator.mediaDevices.getUserMedia(
          {'audio': true, 'video': false});
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });

      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      await _firestore.collection('chat rooms').doc(widget.ConnID).set({
        'offer': offer.sdp,
        'answer': null,
      }, SetOptions(
          merge: true)); // Extra write - Voice call offer can overwrite unnecessarily

      setState(() => _inCall = true);
      _listenForSignaling();
      print('Voice call started by ${_isInitiator ? "Initiator" : "Joiner"}');
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'Error starting call: $e');
      print('Error starting call: $e for ${_isInitiator
          ? "Initiator"
          : "Joiner"}');
    }
  }

  Future<void> _endVoiceCall() async {
    if (!_inCall) return;

    try {
      _localStream?.getTracks().forEach((track) => track.stop());
      _localStream?.dispose();
      _localStream = null;
      _remoteStream?.dispose();
      _remoteStream = null;
      await _peerConnection?.close();
      _inCall = false;
      setState(() => _status = 'Call ended');
      await _setupWebRTC(); // Extra reads/writes - Reinitializes, potentially redundant
      print('Voice call ended by ${_isInitiator ? "Initiator" : "Joiner"}');
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'Error ending call: $e');
      print(
          'Error ending call: $e for ${_isInitiator ? "Initiator" : "Joiner"}');
    }
  }

  void _listenForSignaling() {
    _firestoreSubscription?.cancel();
    _firestoreSubscription = _firestore
        .collection('chat rooms')
        .doc(widget.ConnID)
        .snapshots()
        .listen((snapshot) {
      if (!mounted || !snapshot.exists || snapshot.data() == null ||
          !_isInitiator) return;

      final data = snapshot.data()! as Map<String, dynamic>;
      if (data['answer'] != null && _status != 'Connected') {
        try {
          final remoteAnswer = RTCSessionDescription(data['answer'], 'answer');
          _peerConnection?.setRemoteDescription(remoteAnswer);
          print('Set remote answer for Initiator');
        } catch (e) {
          if (!mounted) return;
          setState(() => _status = 'Error setting answer: $e');
          print('Error setting answer: $e for Initiator');
        }
      }
    }); // Extra read - Snapshot listener charges 1 read per update (e.g., answer set)

    _firestore
        .collection('chat rooms')
        .doc(widget.ConnID)
        .collection('candidates')
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;
      for (var doc in snapshot.docChanges) {
        if (doc.type == DocumentChangeType.added) {
          final data = doc.doc.data()!;
          _peerConnection?.addCandidate(RTCIceCandidate(
            data['candidate'],
            data['sdpMid'],
            data['sdpMLineIndex'],
          ));
        }
      }
    }); // Extra read - Each candidate added triggers a read; can multiply (5-10+ per session)
  }

  Future<void> _createOffer() async {
    try {
      if (!mounted) return;
      setState(() {
        _isInitiator = true;
        _isJoiner = false;
        _status = 'Waiting...';
      });
      await _setupWebRTC();
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      await _firestore.collection('chat rooms').doc(widget.ConnID).set({
        'offer': offer.sdp,
        'answer': null, //TODO: Experimental
      }, SetOptions(merge: true)); // Extra write - Initial offer write
      _listenForSignaling();
      print('Offer created by Initiator');
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'Error creating offer: $e');
      print('Error creating offer: $e for Initiator');
    }
  }

  Future<void> _joinChat() async {
    try {
      if (!mounted) return;
      setState(() {
        _isInitiator = false;
        _isJoiner = true;
        _status = 'Joining...';
      });
      await _setupWebRTC();
      final roomSnapshot = await _firestore.collection('chat rooms').doc(
          widget.ConnID).get(); // Extra read - Fetching chat room state

      if (roomSnapshot.exists && roomSnapshot.data()?['offer'] != null) {
        final remoteOffer = RTCSessionDescription(
            roomSnapshot['offer'], 'offer');
        await _peerConnection?.setRemoteDescription(remoteOffer);

        final answer = await _peerConnection!.createAnswer();
        await _peerConnection!.setLocalDescription(answer);

        await _firestore.collection('chat rooms').doc(widget.ConnID).update({
          'answer': answer.sdp,
        }); // Extra write - Answer update
        _listenForSignaling();
        print('Joined chat by Joiner');
      } else {
        if (!mounted) return;
        setState(() => _status = 'No chat found.');
        print('No chat found for Joiner');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'Error joining chat: $e');
      print('Error joining chat: $e for Joiner');
    }
  }


  void _sendMessage(String comingFrom, int deletionNo) {

    if (!mounted) return;
    // if (_dataChannel?.state == RTCDataChannelState.RTCDataChannelOpen &&
    //     messageController.text.isNotEmpty) {
    if (_dataChannel?.state == RTCDataChannelState.RTCDataChannelOpen) {
      String message = "";
      int deletion = 69;
      if(comingFrom == "send" && deletionNo == 69){
        message = messageController.text;
      }else{
        deletion = deletionNo;
      }
      try {
        _dataChannel!.send(RTCDataChannelMessage(message));
        setState(() {
          messages.add({'type': 'text', 'content': message, 'isMe': true, 'deletion_number': deletion});
          print("Sender: $comingFrom Deletion_Number: $deletion");
          _scrollToBottom();
        });
        print('Message sent by ${_isInitiator ? "Initiator" : "Joiner"}');
      } catch (e) {
        if (!mounted) return;
        setState(() => _status = 'Error sending message: $e');
        print('Error sending message: $e for ${_isInitiator
            ? "Initiator"
            : "Joiner"}');
      }
    } else {
      setState(() => _status = 'Channel not ready.');
      print('Channel not ready for ${_isInitiator ? "Initiator" : "Joiner"}');
    }
    messageController.clear();
  }

  @override
  void dispose() {
    _firestoreSubscription
        ?.cancel(); // Only cancels one listener; candidates listener persists
    _dataChannel?.close();
    _peerConnection?.close();
    _localStream?.dispose();
    _remoteStream?.dispose();
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }


  Future<void> appendToPrevConns(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    String? currentUser = prefs.getString('username');
    if (currentUser == null) {
      print("No user logged in");
      return;
    }
    String userSpecificKey = "PrevConns_$currentUser";
    List<Map<String, String>> prevConnsList = [];
    String? existingData = prefs.getString(userSpecificKey);
    if (existingData != null) {
      prevConnsList = List<Map<String, String>>.from(
          jsonDecode(existingData).map((item) =>
          Map<String, String>.from(item)));
    }
    prevConnsList.removeWhere((conn) => conn["UserName"] == userName);
    String timestamp = DateFormat("d'th' MMM, hh:mm a").format(DateTime.now());
    Map<String, String> newConn = {
      "UserName": userName,
      "Timestamp": timestamp,
    };
    prevConnsList.add(newConn);
    await prefs.setString(userSpecificKey, jsonEncode(prevConnsList));
  }

// Get UserName from UID (for sender)
  Future<String> getUserNameFromUID(String uid) async {
    final ref = FirebaseFirestore.instance.collection('users');
    DocumentSnapshot userDoc = await ref.doc(uid).get();

    if (userDoc.exists) {
      String userName = userDoc['email'] ?? '';
      print("User found! UID: $uid, UserName: $userName");
      return userName;
    } else {
      print("No user found with UID: $uid");
      return "";
    }
  }

  Future<void> _terminateConnections() async {
    await FirebaseFirestore.instance.collection("joiner connections").doc(
        widget.JoinerID).update({
      'sender_ids': FieldValue.arrayRemove([widget.ConnID]),
    }); // Extra write - Termination write 1
    await FirebaseFirestore.instance.collection("chat rooms")
        .doc(widget.ConnID)
        .delete(); // Extra write - Termination write 2
    if(_isInitiator){
      String JoinerUN = await getUserNameFromUID(widget.JoinerID);
      appendToPrevConns(JoinerUN);
    }else{
      String SenderUN = await getUserNameFromUID(widget.StarterID);
      appendToPrevConns(SenderUN);
    }
  }

  void deleteMessage(int index){
    setState(() {
      // messages.removeAt(index);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: Text(
          "Chat",
          style: GoogleFonts.orbitron(
            color: const Color(0xFF00B7FF),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00B7FF)),
          onPressed: () {
            _terminateConnections();
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 8.0, horizontal: 16.0),
            child: Text(
              _status,
              style: GoogleFonts.roboto(
                color: const Color(0xFFE0E0E0).withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ),
          TextButton(onPressed: (){
            _sendMessage("delete", 2);
          }, child: Text("Delete Previous")),
          Expanded(
            child: Container(
              color: const Color(0xFF1A1A1A),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12.0), // Reduced padding
                itemCount: messages.length,
                itemBuilder: (context, index) => _buildMessage(messages[index], index),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0), // Reduced padding
            color: const Color(0xFF252525),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image, color: Color(0xFF26A69A)),
                  onPressed: _sendImage,
                ),
                Expanded(
                  child: TextField(
                    controller: messageController,
                    style: GoogleFonts.roboto(color: const Color(0xFFE0E0E0)),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: GoogleFonts.roboto(
                          color: const Color(0xFFE0E0E0).withOpacity(0.6)),
                      filled: true,
                      fillColor: const Color(0xFF2D2D2D),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage("send", 69),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF00B7FF)),
                  onPressed: (){
                    _sendMessage("send", 69);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> message, int ind) {
    // if(message['deletion_number'] != 69){
    //   print("Deletion index ${message['deletion_number']}");  // TODO: Technical problem here
    //   deleteMessage(message['deletion_number']);
    // }
    // print("message: ${message['content']} index: $ind");
    final isMe = message['isMe'] == true;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment
            .start,
        children: [
          if (!isMe) const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery
                  .of(context)
                  .size
                  .width * 0.7),
              padding: message['type'] == 'text'
                  ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                  : const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF00B7FF) : const Color(0xFF2D2D2D),
                borderRadius: BorderRadius.circular(12).copyWith(
                  topLeft: isMe ? const Radius.circular(12) : const Radius
                      .circular(4),
                  topRight: isMe ? const Radius.circular(4) : const Radius
                      .circular(12),
                  bottomLeft: const Radius.circular(12),
                  bottomRight: const Radius.circular(12),
                ),
              ),
              child: message['type'] == 'text'
                  ? Text(
                isMe
                    ? 'You: ${message['content']}'
                    : 'Peer: ${message['content']}',
                style: GoogleFonts.roboto(
                  color: isMe ? const Color(0xFF1A1A1A) : const Color(
                      0xFFE0E0E0),
                  fontSize: 14,
                ),
              )
                  : GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) =>
                        Dialog(
                          backgroundColor: Colors.transparent,
                          child: Image.memory(
                            message['content'] as Uint8List,
                            fit: BoxFit.contain,
                          ),
                        ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color(0xFF00B7FF), width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: Image.memory(
                      message['content'] as Uint8List,
                      width: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
