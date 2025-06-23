//
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'commPage.dart'; // Assuming your previous CommPage is in this file
//
// class ConnectionRequestsPage extends StatefulWidget {
//   @override
//   _ConnectionRequestsPageState createState() => _ConnectionRequestsPageState();
// }
//
// class _ConnectionRequestsPageState extends State<ConnectionRequestsPage> {
//   String _joinerUID = '';
//   List<Map<String, dynamic>> _requests = [];
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchJoinerUIDAndRequests();
//   }
//
//   // Fetch Joiner UID and connection requests
//   Future<void> _fetchJoinerUIDAndRequests() async {
//     try {
//       // Get email from SharedPreferences
//       String email = await getUserNameFromSharedPref();
//       if (email.isEmpty) {
//         setState(() => _isLoading = false);
//         return;
//       }
//
//       // Get UID from Firestore (for joiner)
//       String uid = await getUID(email);
//       if (uid.isEmpty) {
//         setState(() => _isLoading = false);
//         return;
//       }
//
//       setState(() => _joinerUID = uid);
//
//       // Fetch joiner connections
//       DocumentSnapshot joinerDoc = await FirebaseFirestore.instance
//           .collection('joiner connections')
//           .doc(_joinerUID)
//           .get();
//
//       if (!joinerDoc.exists || joinerDoc['sender_ids'] == null) {
//         setState(() {
//           _requests = [];
//           _isLoading = false;
//         });
//         return;
//       }
//
//       List<String> senderIds = List<String>.from(joinerDoc['sender_ids']);
//
//       // Fetch each connection request from chat rooms
//       List<Map<String, dynamic>> requests = [];
//       for (String connId in senderIds) {
//         DocumentSnapshot chatRoomDoc = await FirebaseFirestore.instance
//             .collection('chat rooms')
//             .doc(connId)
//             .get();
//         if (chatRoomDoc.exists) {
//           // Fetch sender UserName from UID
//           String senderUserName = await getUserNameFromUID(chatRoomDoc['starter']);
//           requests.add({
//             'connection_id': connId,
//             'starter': chatRoomDoc['starter'], // Keep for CommPage
//             'starterUserName': senderUserName, // Add UserName for display
//             'joiner': chatRoomDoc['joiner'],
//             'has_joiner_accepted': chatRoomDoc['has_joiner_accepted'],
//           });
//         }
//       }
//
//       setState(() {
//         _requests = requests;
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error fetching requests: $e');
//       setState(() => _isLoading = false);
//     }
//   }
//
//   // Accept a connection request
//   Future<void> _acceptRequest(String connId) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('chat rooms')
//           .doc(connId)
//           .update({'has_joiner_accepted': true});
//       setState(() {
//         _requests.firstWhere((req) => req['connection_id'] == connId)['has_joiner_accepted'] = true;
//       });
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => CommPage(
//             StarterID: _requests.firstWhere((req) => req['connection_id'] == connId)['starter'],
//             JoinerID: _joinerUID,
//             ConnID: connId,
//           ),
//         ),
//       );
//     } catch (e) {
//       print('Error accepting request: $e');
//     }
//   }
//
//   // Reject a connection request
//   Future<void> _rejectRequest(String connId) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('joiner connections')
//           .doc(_joinerUID)
//           .update({
//         'sender_ids': FieldValue.arrayRemove([connId]),
//       });
//       await FirebaseFirestore.instance
//           .collection('chat rooms')
//           .doc(connId)
//           .delete();
//       setState(() {
//         _requests.removeWhere((req) => req['connection_id'] == connId);
//       });
//     } catch (e) {
//       print('Error rejecting request: $e');
//     }
//   }
//
//   // Get username from SharedPreferences
//   Future<String> getUserNameFromSharedPref() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String em = prefs.getString('username') ?? "";
//     print("------username is $em------");
//     return em;
//   }
//
//   // Get UID from Firestore using email (for joiner)
//   Future<String> getUID(String UserName) async {
//     final ref = FirebaseFirestore.instance.collection('users');
//     final querySnapshot = await ref.where("email", isEqualTo: UserName).get();
//
//     if (querySnapshot.docs.isNotEmpty) {
//       var userDoc = querySnapshot.docs.first;
//       print("User found! whose username is : $UserName");
//       return userDoc.id;
//     } else {
//       print("No user found with username: $UserName");
//       return "";
//     }
//   }
//
//   // Get UserName from UID (for sender)
//   Future<String> getUserNameFromUID(String uid) async {
//     final ref = FirebaseFirestore.instance.collection('users');
//     DocumentSnapshot userDoc = await ref.doc(uid).get();
//
//     if (userDoc.exists) {
//       String userName = userDoc['email'] ?? '';
//       print("User found! UID: $uid, UserName: $userName");
//       return userName;
//     } else {
//       print("No user found with UID: $uid");
//       return "";
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 1,
//         title: Text(
//           "Connection Requests Page",
//           style: GoogleFonts.poppins(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w500),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black54),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : _requests.isEmpty
//           ? Center(
//         child: Text(
//           "No pending requests",
//           style: GoogleFonts.poppins(
//             color: Colors.grey,
//             fontSize: 16,
//           ),
//         ),
//       )
//           : ListView.builder(
//         padding: EdgeInsets.all(16),
//         itemCount: _requests.length,
//         itemBuilder: (context, index) {
//           final request = _requests[index];
//           return Card(
//             color: Colors.grey[900],
//             margin: EdgeInsets.symmetric(vertical: 8),
//             child: ListTile(
//               title: Text(
//                 "From: ${request['starterUserName']}", // Display UserName instead of UID
//                 style: GoogleFonts.poppins(
//                   color: Colors.white,
//                   fontSize: 16,
//                 ),
//               ),
//               subtitle: Text(
//                 request['has_joiner_accepted'] ? "Accepted" : "Pending",
//                 style: GoogleFonts.poppins(
//                   color: request['has_joiner_accepted'] ? Colors.green : Colors.orange,
//                   fontSize: 14,
//                 ),
//               ),
//               trailing: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   if (!request['has_joiner_accepted']) ...[
//                     IconButton(
//                       icon: Icon(Icons.check, color: Colors.green),
//                       onPressed: () => _acceptRequest(request['connection_id']),
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.close, color: Colors.red),
//                       onPressed: () => _rejectRequest(request['connection_id']),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'commPage.dart'; // Assuming your previous CommPage is in this file

class ConnectionRequestsPage extends StatefulWidget {
  @override
  _ConnectionRequestsPageState createState() => _ConnectionRequestsPageState();
}

class _ConnectionRequestsPageState extends State<ConnectionRequestsPage> {
  String _joinerUID = '';
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchJoinerUIDAndRequests();
  }

  Future<void> _fetchJoinerUIDAndRequests() async {
    try {
      String email = await getUserNameFromSharedPref();
      if (email.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }
      String uid = await getUID(email);
      if (uid.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }
      setState(() => _joinerUID = uid);
      DocumentSnapshot joinerDoc = await FirebaseFirestore.instance
          .collection('joiner connections')
          .doc(_joinerUID)
          .get();

      if (!joinerDoc.exists || joinerDoc['sender_ids'] == null) {
        setState(() {
          _requests = [];
          _isLoading = false;
        });
        return;
      }

      List<String> senderIds = List<String>.from(joinerDoc['sender_ids']);
      List<Map<String, dynamic>> requests = [];
      for (String connId in senderIds) {
        DocumentSnapshot chatRoomDoc = await FirebaseFirestore.instance
            .collection('chat rooms')
            .doc(connId)
            .get();
        if (chatRoomDoc.exists) {
          String senderUserName = await getUserNameFromUID(chatRoomDoc['starter']);
          requests.add({
            'connection_id': connId,
            'starter': chatRoomDoc['starter'],
            'starterUserName': senderUserName,
            'joiner': chatRoomDoc['joiner'],
            'has_joiner_accepted': chatRoomDoc['has_joiner_accepted'],
          });
        }
      }

      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching requests: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptRequest(String connId) async {
    try {
      await FirebaseFirestore.instance
          .collection('chat rooms')
          .doc(connId)
          .update({'has_joiner_accepted': true});
      setState(() {
        _requests.firstWhere((req) => req['connection_id'] == connId)['has_joiner_accepted'] = true;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CommPage(
            StarterID: _requests.firstWhere((req) => req['connection_id'] == connId)['starter'],
            JoinerID: _joinerUID,
            ConnID: connId,
            Conn_Type: "joiner",
          ),
        ),
      );
    } catch (e) {
      print('Error accepting request: $e');
    }
  }

  Future<void> _rejectRequest(String connId) async {
    try {
      await FirebaseFirestore.instance
          .collection('joiner connections')
          .doc(_joinerUID)
          .update({
        'sender_ids': FieldValue.arrayRemove([connId]),
      });
      await FirebaseFirestore.instance.collection('chat rooms').doc(connId).delete();
      setState(() {
        _requests.removeWhere((req) => req['connection_id'] == connId);
      });
    } catch (e) {
      print('Error rejecting request: $e');
    }
  }

  Future<String> getUserNameFromSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String em = prefs.getString('username') ?? "";
    print("------username is $em------");
    return em;
  }

  Future<String> getUID(String UserName) async {
    final ref = FirebaseFirestore.instance.collection('users');
    final querySnapshot = await ref.where("email", isEqualTo: UserName).get();
    if (querySnapshot.docs.isNotEmpty) {
      var userDoc = querySnapshot.docs.first;
      print("User found! whose username is : $UserName");
      return userDoc.id;
    } else {
      print("No user found with username: $UserName");
      return "";
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: Text(
          "Requests",
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
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B7FF)),
        ),
      )
          : _requests.isEmpty
          ? Center(
        child: Text(
          "No pending requests",
          style: GoogleFonts.roboto(
            color: const Color(0xFFE0E0E0).withOpacity(0.6),
            fontSize: 16,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final request = _requests[index];
          return Card(
            color: const Color(0xFF252525),
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              title: Text(
                "From: ${request['starterUserName']}",
                style: GoogleFonts.roboto(
                  color: const Color(0xFFE0E0E0),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                request['has_joiner_accepted'] ? "Accepted" : "Pending",
                style: GoogleFonts.roboto(
                  color: request['has_joiner_accepted']
                      ? Colors.green
                      : Colors.orange,
                  fontSize: 12,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!request['has_joiner_accepted']) ...[
                    IconButton(
                      icon: const Icon(Icons.check, color: Color(0xFF26A69A)),
                      onPressed: () => _acceptRequest(request['connection_id']),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFFFF4D4D)),
                      onPressed: () => _rejectRequest(request['connection_id']),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}