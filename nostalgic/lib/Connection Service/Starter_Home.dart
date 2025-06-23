// import 'dart:convert';
// import 'package:intl/intl.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:nostalgic/Communication/commPage.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class StarterHome extends StatefulWidget {
//   const StarterHome({super.key});
//
//   @override
//   State<StarterHome> createState() => _StarterHomeState();
// }
//
// class _StarterHomeState extends State<StarterHome> {
//   TextEditingController searchCont = TextEditingController();
//   String StarterUID = "";
//   String JoinerUID = "";
//   List<dynamic> UserPair = [];
//
//   String connectionPacketId = "";
//
//   Future<void> SetUpConnection() async{
//
//     // Add _searchUser()
//     //   If present, display a dialogue box to join the conversation
//     //   If not, deliver a snackbar that user is not present
//     String StarterUN = await getUserNameFromSharedPref();
//     String JoinerUN = searchCont.text;
//     List<dynamic> UP = await _searchUser(StarterUN, JoinerUN);
//     print("The returned UerPair has size ${UP.length}");
//     setState(() {
//       UserPair = UP;
//       //   Now map userIDs of both users in a global vaiable
//       _mapUsers(UserPair);
//     });
//     if(UP.length == 2){
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text("Do you want to Join, Now?"),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop(); // Closes the dialog
//                   // Add your "No" logic here
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text("Connection Terminated", style: TextStyle(color: Colors.black),),
//                       backgroundColor: Colors.red, // Soft Red for errors
//                     ), // make sure to use it after the user pressed yes in dialogue box
//                   );
//                 },
//                 child: const Text("No"),
//               ),
//               TextButton(
//                 onPressed: () async{
//                   Navigator.of(context).pop(); // Closes the dialog
//
//                   // Add your "Yes" logic here
//                   String connID = await createDocumentWithId('chat rooms', {
//                     'starter': StarterUID,
//                     'joiner':JoinerUID,
//                     'has_joiner_accepted': false,
//                     'offer': "",
//                     'answer': "",
//                   });
//
//                   setState(() {
//                     connectionPacketId = connID;
//                     print("New COnnection Packet ID is $connectionPacketId");
//                   });
//
//                   addSIDstoJoinerConnections('joiner connections', [connectionPacketId], JoinerUID
//                   );
//
//                   //   Add the userName and thier ID to shared pref
//
//                   appendToPrevConns(searchCont.text);
//
//                   //   Sending to the Communication page
//                   _sendMetoTheComm();
//                 },
//                 child: const Text("Yes"),
//               ),
//             ],
//           );
//         },
//       );
//
//     }else{
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("User not found", style: TextStyle(color: Colors.black),),
//           backgroundColor: Colors.red, // Soft Red for errors
//         ),
//       );
//     }
//   }
// //   Future<void> appendToPrevConns(String userName) async {
// //     final prefs = await SharedPreferences.getInstance();
// //
// //     // Get existing list or initialize new one
// //     List<Map<String, String>> prevConnsList = [];
// //     String? existingData = prefs.getString("PrevConns");
// //     if (existingData != null) {
// //       prevConnsList = List<Map<String, String>>.from(
// //           jsonDecode(existingData).map((item) => Map<String, String>.from(item))
// //       );
// //     }
// //
// //     // Remove any existing entry with the same UserName
// //     prevConnsList.removeWhere((conn) => conn["UserName"] == userName);
// //
// //     // Format current timestamp (e.g., "7th Dec, 8:01 AM")
// //     String timestamp = DateFormat("d'th' MMM, hh:mm a").format(DateTime.now());
// //
// //     // Create new connection map with timestamp
// //     Map<String, String> newConn = {
// //       "UserName": userName,
// //       "Timestamp": timestamp,
// //     };
// //
// //     // Add new connection to the end
// //     prevConnsList.add(newConn);
// //
// //     // Save updated list back to SharedPreferences
// //     await prefs.setString("PrevConns", jsonEncode(prevConnsList));
// //   }
// //
// // // Retrieve the list of connections
// //   Future<List<Map<String, String>>> retrievePrevConnsList() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     String? jsonString = prefs.getString("PrevConns");
// //
// //     if (jsonString != null) {
// //       return List<Map<String, String>>.from(
// //           jsonDecode(jsonString).map((item) => Map<String, String>.from(item))
// //       );
// //     }
// //
// //     return [];
// //   }
//
//   Future<void> appendToPrevConns(String userName) async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Get the current logged-in user's username
//     String? currentUser = prefs.getString('username');
//     if (currentUser == null) {
//       print("No user logged in");
//       return;
//     }
//
//     // Use a user-specific key
//     String userSpecificKey = "PrevConns_$currentUser";
//
//     // Get existing list or initialize new one for this user
//     List<Map<String, String>> prevConnsList = [];
//     String? existingData = prefs.getString(userSpecificKey);
//     if (existingData != null) {
//       prevConnsList = List<Map<String, String>>.from(
//           jsonDecode(existingData).map((item) => Map<String, String>.from(item))
//       );
//     }
//
//     // Remove any existing entry with the same UserName
//     prevConnsList.removeWhere((conn) => conn["UserName"] == userName);
//
//     // Format current timestamp (e.g., "7th Dec, 8:01 AM")
//     String timestamp = DateFormat("d'th' MMM, hh:mm a").format(DateTime.now());
//
//     // Create new connection map with timestamp
//     Map<String, String> newConn = {
//       "UserName": userName,
//       "Timestamp": timestamp,
//     };
//
//     // Add new connection to the end
//     prevConnsList.add(newConn);
//
//     // Save updated list back to SharedPreferences under user-specific key
//     await prefs.setString(userSpecificKey, jsonEncode(prevConnsList));
//   }
//
// // Retrieve the list of connections for the current user
//   Future<List<Map<String, String>>> retrievePrevConnsList() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Get the current logged-in user's username
//     String? currentUser = prefs.getString('username');
//     if (currentUser == null) {
//       print("No user logged in");
//       return [];
//     }
//
//     // Use a user-specific key
//     String userSpecificKey = "PrevConns_$currentUser";
//
//     String? jsonString = prefs.getString(userSpecificKey);
//
//     if (jsonString != null) {
//       return List<Map<String, String>>.from(
//           jsonDecode(jsonString).map((item) => Map<String, String>.from(item))
//       );
//     }
//
//     return [];
//   }
//
//   void _sendMetoTheComm(){
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => CommPage(
//         StarterID: StarterUID,
//         JoinerID: JoinerUID,
//         ConnID: connectionPacketId,
//       )),
//     );
//   }
//   Future<String> createDocumentWithId(String collectionName, Map<String, dynamic> data) async {
//     var docRef = await FirebaseFirestore.instance.collection(collectionName).add(data);
//     await docRef.update({'connection_id': docRef.id});
//     print("The connection packet ID is ${docRef.id}");
//     return docRef.id;
//
//   }
//
//   Future<void> addSIDstoJoinerConnections(String collectionName, List<dynamic> SID, String manualID) async {
//     await FirebaseFirestore.instance.collection(collectionName).doc(manualID).update({
//       'sender_ids': FieldValue.arrayUnion(SID),
//     });
//   }
//
//   void _mapUsers(List<dynamic> UserPairs) {
//     if(UserPairs.length != 0){
//       setState(() {
//         StarterUID = UserPairs[0];
//         JoinerUID = UserPairs[1];
//       });
//       print("Starter UID: ${UserPairs[0]}");
//       print("Joiner UID: ${UserPairs[1]}");
//     }
//     else{
//       print("The UserPairs is empty");
//     }
//   }
//
//   // Get the user's username from shared preference
//   Future<String> getUserNameFromSharedPref() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String em = prefs.getString('username') ?? "";
//     print("------username is $em------");
//     return em;
//   }
//
//   // And then search for the UID in firebase and return Starter UID
//   Future<String> getUID(String UserName) async {
//     final ref = FirebaseFirestore.instance.collection('users');
//
//     final querySnapshot =
//         await ref.where("email", isEqualTo: UserName).get();
//
//     if (querySnapshot.docs.isNotEmpty) {
//       var userDoc = querySnapshot.docs.first;
//       // setState(() {
//       //   StarterID = userDoc.id;
//       // });
//       print("User found! whose username is : $UserName");
//       return userDoc.id;
//     } else {
//       print("No user found with username: $UserName");
//       return "";
//     }
//   }
//
//   Future<List<dynamic>> _searchUser(String StarterUN, String JoinerUN) async {
//     String StarterUID = await getUID(StarterUN);
//     String JoinerUID = await getUID(JoinerUN);
//
//     if (StarterUID != "" && JoinerUID != "") {
//       return [StarterUID, JoinerUID];
//     } else {
//       return [];
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: EdgeInsets.only(top: 60, left: 5, right: 5),
//         child: Column(
//           children: [
//             // Creating a Text Field to get Joiner's UserName
//
//             SizedBox(
//               width: 330,
//               height: 60,
//               child: TextField(
//                 controller: searchCont,
//                 decoration: InputDecoration(
//                   labelText: "Enter User's Name",
//                   labelStyle: TextStyle(color: Colors.grey.shade600),
//                   filled: true,
//                   fillColor: Colors.grey.shade100,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                   prefixIcon: Icon(Icons.person, color: Colors.black),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: Colors.black, width: 2),
//                   ),
//                 ),
//                 style: TextStyle(color: Colors.black),
//                 cursorColor: Colors.black,
//               ),
//             ),
//
//             //   Creating a Search Button to search the userName in users collection
//             Align(
//               alignment: Alignment.centerRight,
//               child: TextButton(
//                 onPressed: () async {
//                   SetUpConnection();
//                 },
//                 child: Text("Search"),
//               ),
//             ),
//
//             SizedBox(height: 50,),
//
//             TextButton(onPressed: (){
//               Navigator.pushNamed(context, '/joinH');
//             },
//                 child: Text("See Requests")),
//
//             SizedBox(height: 20,),
//             Text("Previous Connections, Tap to join"),
//             // SizedBox(height: 20,),
//
//
//             Container(
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   width: 1.0,
//
//                 )
//               ),
//               child: SizedBox(
//                 height: 500,
//                 width: double.maxFinite,
//                 child: FutureBuilder<List<Map<String, String>>>(future: retrievePrevConnsList(), // Call the retrieve method
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Center(child: CircularProgressIndicator());
//                     }
//                     if (snapshot.hasError) {
//                       return Center(child: Text('Error: ${snapshot.error}'));
//                     }
//                     if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                       return Center(child: Text('No previous connections found'));
//                     }
//
//                     final prevConnsList = snapshot.data!;
//                     return ListView.builder(
//                       // reverse: true, // Optional: Show newest first
//                       itemCount: prevConnsList.length,
//                       itemBuilder: (context, index) {
//                         final conn = prevConnsList[index];
//                         return GestureDetector(
//                           onTap: () {
//                             // Handle tap event here
//                             SetUpConnection(); // Ensure this is defined elsewhere
//                           },
//                           child: Card(
//                             margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                             elevation: 4,
//                             child: Padding(
//                               padding: EdgeInsets.all(16),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     '${conn["UserName"] ?? "N/A"}',
//                                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                                   ),
//                                   SizedBox(height: 8),
//                                   Text(
//                                     'Last joined: ${conn["Timestamp"] ?? "N/A"}',
//                                     style: TextStyle(fontSize: 14),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nostalgic/Communication/commPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StarterHome extends StatefulWidget {
  const StarterHome({super.key});

  @override
  State<StarterHome> createState() => _StarterHomeState();
}

class _StarterHomeState extends State<StarterHome> {
  late Future<List<Map<String, String>>> _prevConnsFuture;
  TextEditingController searchCont = TextEditingController();
  String StarterUID = "";
  String JoinerUID = "";
  List<dynamic> UserPair = [];
  String connectionPacketId = "";
  String OrigUser ="";

  void getInitialFutureBuilder() async{
    String tp = await getUserNameFromSharedPref();
    setState(() {
      OrigUser = tp;
    });
  }

  @override
  void initState(){
    super.initState();
    _prevConnsFuture = retrievePrevConnsList();
    getInitialFutureBuilder();
  }

  Future<void> SetUpConnection(String setter, String? Join_user) async {
    String StarterUN = await getUserNameFromSharedPref();
    String JoinerUN = "";
    if(setter == "card"){
      JoinerUN = Join_user ?? "";
    }
    else if(setter == "search"){
      JoinerUN = searchCont.text;
    }
    searchCont.clear();
    List<dynamic> UP = await _searchUser(StarterUN, JoinerUN);
    print("The returned UserPair has size ${UP.length}");
    setState(() {
      UserPair = UP;
      _mapUsers(UserPair);
    });
    if (UP.length == 2) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: Text(
              "Do you want to Join, Now?",
              style: GoogleFonts.roboto(color: const Color(0xFFE0E0E0)),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Connection Terminated", style: GoogleFonts.roboto(color: Colors.black)),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                child: Text("No", style: GoogleFonts.roboto(color: const Color(0xFF00B7FF))),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  String connID = await createDocumentWithId('chat rooms', {
                    'starter': StarterUID,
                    'joiner': JoinerUID,
                    'has_joiner_accepted': false,
                    'offer': "",
                    'answer': "",
                  });

                  setState(() {
                    connectionPacketId = connID;
                    print("New Connection Packet ID is $connectionPacketId");
                  });

                  addSIDstoJoinerConnections('joiner connections', [connectionPacketId], JoinerUID);
                  // appendToPrevConns(searchCont.text);
                  _sendMetoTheComm();
                },
                child: Text("Yes", style: GoogleFonts.roboto(color: const Color(0xFF00B7FF))),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("User not found", style: GoogleFonts.roboto(color: Colors.black)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Future<void> appendToPrevConns(String userName) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   String? currentUser = prefs.getString('username');
  //   if (currentUser == null) {
  //     print("No user logged in");
  //     return;
  //   }
  //   String userSpecificKey = "PrevConns_$currentUser";
  //   List<Map<String, String>> prevConnsList = [];
  //   String? existingData = prefs.getString(userSpecificKey);
  //   if (existingData != null) {
  //     prevConnsList = List<Map<String, String>>.from(
  //         jsonDecode(existingData).map((item) => Map<String, String>.from(item)));
  //   }
  //   prevConnsList.removeWhere((conn) => conn["UserName"] == userName);
  //   String timestamp = DateFormat("d'th' MMM, hh:mm a").format(DateTime.now());
  //   Map<String, String> newConn = {
  //     "UserName": userName,
  //     "Timestamp": timestamp,
  //   };
  //   prevConnsList.add(newConn);
  //   await prefs.setString(userSpecificKey, jsonEncode(prevConnsList));
  // }
  //
  Future<List<Map<String, String>>> retrievePrevConnsList() async {
    final prefs = await SharedPreferences.getInstance();
    String? currentUser = prefs.getString('username');
    if (currentUser == null) {
      print("No user logged in");
      return Future.value([]);
    }
    String userSpecificKey = "PrevConns_$currentUser";
    String? jsonString = prefs.getString(userSpecificKey);
    if (jsonString != null) {
      return List<Map<String, String>>.from(
          jsonDecode(jsonString).map((item) => Map<String, String>.from(item)));
    }
    return Future.value([]);
  }

  Future<void> deleteFromPrevConns(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    String? currentUser = prefs.getString('username');

    if (currentUser == null) {
      print("No user logged in");
      return;
    }

    String userSpecificKey = "PrevConns_$currentUser";
    String? existingData = prefs.getString(userSpecificKey);

    if (existingData != null) {
      List<Map<String, String>> prevConnsList = List<Map<String, String>>.from(
          jsonDecode(existingData).map((item) => Map<String, String>.from(item)));

      // Remove the entry with the given userName
      prevConnsList.removeWhere((conn) => conn["UserName"] == userName);

      // Save the updated list back to SharedPreferences
      await prefs.setString(userSpecificKey, jsonEncode(prevConnsList));
    }

    setState(() {
      _prevConnsFuture = retrievePrevConnsList();
    });
  }


  void _sendMetoTheComm() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CommPage(
            StarterID: StarterUID,
            JoinerID: JoinerUID,
            ConnID: connectionPacketId,
            Conn_Type: "starter",
          )),
    );
  }

  Future<String> createDocumentWithId(String collectionName, Map<String, dynamic> data) async {
    var docRef = await FirebaseFirestore.instance.collection(collectionName).add(data);
    await docRef.update({'connection_id': docRef.id});
    print("The connection packet ID is ${docRef.id}");
    return docRef.id;
  }

  Future<void> addSIDstoJoinerConnections(String collectionName, List<dynamic> SID, String manualID) async {
    await FirebaseFirestore.instance.collection(collectionName).doc(manualID).update({
      'sender_ids': FieldValue.arrayUnion(SID),
    });
  }

  void _mapUsers(List<dynamic> UserPairs) {
    if (UserPairs.isNotEmpty) {
      setState(() {
        StarterUID = UserPairs[0];
        JoinerUID = UserPairs[1];
      });
      print("Starter UID: ${UserPairs[0]}");
      print("Joiner UID: ${UserPairs[1]}");
    } else {
      print("The UserPairs is empty");
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

  Future<List<dynamic>> _searchUser(String StarterUN, String JoinerUN) async {
    String StarterUID = await getUID(StarterUN);
    String JoinerUID = await getUID(JoinerUN);
    if (StarterUID != "" && JoinerUID != "") {
      return [StarterUID, JoinerUID];
    } else {
      return [];
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: const Color(0xFF1A1A1A),
  //     body: SafeArea(
  //       child: Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               'Start a Chat',
  //               style: GoogleFonts.orbitron(
  //                 fontSize: 28,
  //                 fontWeight: FontWeight.bold,
  //                 color: const Color(0xFF00B7FF),
  //               ),
  //             ),
  //             const SizedBox(height: 8),
  //             Text(
  //               'Find someone to connect with',
  //               style: GoogleFonts.roboto(
  //                 fontSize: 14,
  //                 color: const Color(0xFFE0E0E0).withOpacity(0.6),
  //               ),
  //             ),
  //             const SizedBox(height: 24),
  //             TextField(
  //               controller: searchCont,
  //               style: GoogleFonts.roboto(color: const Color(0xFFE0E0E0)),
  //               decoration: InputDecoration(
  //                 labelText: "Enter Username",
  //                 labelStyle: GoogleFonts.roboto(color: const Color(0xFF26A69A)),
  //                 prefixIcon: const Icon(Icons.person, color: Color(0xFF26A69A)),
  //                 border: OutlineInputBorder(
  //                   borderSide: const BorderSide(color: Color(0xFF00B7FF), width: 1),
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //                 enabledBorder: OutlineInputBorder(
  //                   borderSide: const BorderSide(color: Color(0xFF00B7FF), width: 1),
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //                 focusedBorder: OutlineInputBorder(
  //                   borderSide: const BorderSide(color: Color(0xFF00B7FF), width: 2),
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //                 contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
  //               ),
  //             ),
  //             const SizedBox(height: 16),
  //             Align(
  //               alignment: Alignment.centerRight,
  //               child: TextButton(
  //                 onPressed: () async {
  //                   SetUpConnection("search", null);
  //                 },
  //                 child: Text(
  //                   "Search",
  //                   style: GoogleFonts.roboto(
  //                     fontSize: 16,
  //                     color: const Color(0xFF00B7FF),
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(height: 24),
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.pushNamed(context, '/joinH');
  //               },
  //               child: Text(
  //                 "See Requests",
  //                 style: GoogleFonts.roboto(
  //                   fontSize: 16,
  //                   color: const Color(0xFF00B7FF),
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(height: 24),
  //             Text(
  //               "Previous Connections",
  //               style: GoogleFonts.orbitron(
  //                 fontSize: 20,
  //                 fontWeight: FontWeight.bold,
  //                 color: const Color(0xFF00B7FF),
  //               ),
  //             ),
  //             const SizedBox(height: 8),
  //             Expanded(
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                   border: Border.all(color: const Color(0xFF00B7FF), width: 1),
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //                 child: FutureBuilder<List<Map<String, String>>>(
  //                   future: retrievePrevConnsList(),
  //                   builder: (context, snapshot) {
  //                     if (snapshot.connectionState == ConnectionState.waiting) {
  //                       return const Center(
  //                           child: CircularProgressIndicator(
  //                             valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B7FF)),
  //                           ));
  //                     }
  //                     if (snapshot.hasError) {
  //                       return Center(
  //                           child: Text('Error: ${snapshot.error}',
  //                               style: GoogleFonts.roboto(color: const Color(0xFFE0E0E0))));
  //                     }
  //                     if (!snapshot.hasData || snapshot.data!.isEmpty) {
  //                       return Center(
  //                           child: Text('No previous connections',
  //                               style: GoogleFonts.roboto(
  //                                   color: const Color(0xFFE0E0E0).withOpacity(0.6))));
  //                     }
  //                     final prevConnsList = snapshot.data!;
  //                     return ListView.builder(
  //                       // reverse: true,
  //                       itemCount: prevConnsList.length,
  //                       itemBuilder: (context, index) {
  //                         final conn = prevConnsList[index];
  //                         return GestureDetector(
  //                           onTap: () {
  //                             SetUpConnection("card", conn["UserName"] ?? "N/A");
  //                           },
  //                           child: Card(
  //                             color: const Color(0xFF252525),
  //                             margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
  //                             elevation: 0,
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(8),
  //                             ),
  //                             child: Padding(
  //                               padding: const EdgeInsets.all(12),
  //                               child: Column(
  //                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                 children: [
  //                                   Row(
  //                                     children: [
  //                                       Text(
  //                                         '${conn["UserName"] ?? "N/A"}',
  //                                         style: GoogleFonts.roboto(
  //                                           fontSize: 16,
  //                                           fontWeight: FontWeight.bold,
  //                                           color: const Color(0xFFE0E0E0),
  //                                         ),
  //                                       ),
  //                                       IconButton(onPressed: (){
  //                                         deleteFromPrevConns('${conn["UserName"]}');
  //                                       }, icon: Icon(Icons.delete))
  //                                     ],
  //                                   ),
  //                                   const SizedBox(height: 4),
  //                                   Text(
  //                                     'Last joined: ${conn["Timestamp"] ?? "N/A"}',
  //                                     style: GoogleFonts.roboto(
  //                                       fontSize: 12,
  //                                       color: const Color(0xFFE0E0E0).withOpacity(0.6),
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           ),
  //                         );
  //                       },
  //                     );
  //                   },
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Start a Chat',
                    style: GoogleFonts.orbitron(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00B7FF),
                    ),
                  ),
                  IconButton(onPressed: (){
                    Navigator.pushReplacementNamed(context, '/log');
                  },
                    color: Colors.redAccent,
                    icon: Icon(Icons.exit_to_app_sharp),
                    iconSize: 30,

                  )
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '#$OrigUser',
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  color: Colors.green     ,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: searchCont,
                style: GoogleFonts.roboto(color: const Color(0xFFE0E0E0)),
                decoration: InputDecoration(
                  labelText: "Enter Username",
                  labelStyle: GoogleFonts.roboto(color: const Color(0xFF26A69A)),
                  prefixIcon: const Icon(Icons.person, color: Color(0xFF26A69A)),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF00B7FF), width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF00B7FF), width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF00B7FF), width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    SetUpConnection("search", null);
                  },
                  child: Text(
                    "Search",
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: const Color(0xFF00B7FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/joinH');
                    },
                    child: Text(
                      "See Requests",
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: const Color(0xFF00B7FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF00B7FF)),
                    onPressed: () async{
                      String tp = await getUserNameFromSharedPref();
                      setState(() {
                        _prevConnsFuture = retrievePrevConnsList();
                        OrigUser = tp;

                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                "Previous Connections",
                style: GoogleFonts.orbitron(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00B7FF),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF00B7FF), width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FutureBuilder<List<Map<String, String>>>(
                    future: _prevConnsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B7FF)),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: GoogleFonts.roboto(color: const Color(0xFFE0E0E0)),
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            'No previous connections',
                            style: GoogleFonts.roboto(
                              color: const Color(0xFFE0E0E0).withOpacity(0.6),
                            ),
                          ),
                        );
                      }
                      final prevConnsList = snapshot.data!;
                      return ListView.builder(
                        itemCount: prevConnsList.length,
                        itemBuilder: (context, index) {
                          final conn = prevConnsList[index];
                          print('UserName is ${conn['UserName'] ?? 'N/A'}---------------------------------------------------');
                          if(conn['UserName'] != null){
                            return GestureDetector(
                              onTap: () {
                                SetUpConnection("card", conn["UserName"] ?? "N/A");
                              },
                              child: Card(
                                color: const Color(0xFF252525),
                                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${conn["UserName"] ?? "N/A"}',
                                            style: GoogleFonts.roboto(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFFE0E0E0),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              deleteFromPrevConns('${conn["UserName"]}');
                                            },
                                            icon: const Icon(Icons.delete),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Last joined: ${conn["Timestamp"] ?? "N/A"}',
                                        style: GoogleFonts.roboto(
                                          fontSize: 12,
                                          color: const Color(0xFFE0E0E0).withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}