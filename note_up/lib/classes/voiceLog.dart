// class VoiceLog {
//   final int? id;
//   final String timestamp;
//   final String spokenInput;
//   final String command;
//   final String response;
//
//   VoiceLog({
//     this.id,
//     required this.timestamp,
//     required this.spokenInput,
//     required this.command,
//     required this.response,
//   });
//
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'timestamp': timestamp,
//       'spokenInput': spokenInput,
//       'command': command,
//       'response': response,
//     };
//   }
//
//   factory VoiceLog.fromMap(Map<String, dynamic> map) {
//     return VoiceLog(
//       id: map['id'],
//       timestamp: map['timestamp'],
//       spokenInput: map['spokenInput'],
//       command: map['command'],
//       response: map['response'],
//     );
//   }
// }



class VoiceLog {
  final int? id;
  final String timestamp;
  final String spokenInput;
  final String command;
  final String response;
  final String status;

  VoiceLog({
    this.id,
    required this.timestamp,
    required this.spokenInput,
    required this.command,
    required this.response,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp,
      'spokenInput': spokenInput,
      'command': command,
      'response': response,
      'status': status,
    };
  }

  factory VoiceLog.fromMap(Map<String, dynamic> map) {
    return VoiceLog(
      id: map['id'],
      timestamp: map['timestamp'],
      spokenInput: map['spokenInput'],
      command: map['command'],
      response: map['response'],
      status: map['status'],
    );
  }
}