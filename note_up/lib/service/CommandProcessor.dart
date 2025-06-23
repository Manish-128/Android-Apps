// import 'dart:collection';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:note_up/classes/voiceLog.dart';
// import 'package:note_up/dbs/VoiceDbHelper.dart';
// import 'package:path/path.dart';
//
// import '../screens/note_screens.dart';
//
// class CommandProcessor {
//   final Queue<VoiceLog> _inBuffer = Queue();
//   final Queue<VoiceLog> _outBuffer = Queue();
//   final VoiceLogDb _logDb = VoiceLogDb();
//
//   // Regex patterns for command classification
//   final Map<String, RegExp> _commandPatterns = {
//     'open_note': RegExp(r'\b(open|enter)\s+note\b', caseSensitive: false),
//     'create_note': RegExp(r'\b(create|new)\s+note\b', caseSensitive: false),
//     'set_title': RegExp(r'\b(set|change)\s+title\b', caseSensitive: false),
//     'add_description': RegExp(r'\b(add|update)\s+description\b', caseSensitive: false),
//   };
//
//   // Start processing commands from the IN buffer
//   void startProcessing() async {
//     while (_inBuffer.isNotEmpty) {
//       final log = _inBuffer.removeFirst();
//       final processedLog = await _processCommand(log);
//       _outBuffer.add(processedLog);
//       await _logDb.insertLog(processedLog);
//     }
//   }
//
//   // Add a command to the IN buffer
//   void addToInBuffer(VoiceLog log) {
//     _inBuffer.add(log);
//     startProcessing();
//   }
//
//   // Classify and execute the command
//   Future<VoiceLog> _processCommand(VoiceLog log) async {
//     final String detectedCommand = _classifyCommand(log.spokenInput);
//     final String response = _executeCommand(detectedCommand, log.spokenInput);
//
//     return VoiceLog(
//       id: log.id,
//       timestamp: log.timestamp,
//       spokenInput: log.spokenInput,
//       command: detectedCommand,
//       response: response,
//       status: 'executed',
//     );
//   }
//
//   // Classify command using regex
//   String _classifyCommand(String spokenInput) {
//     for (var entry in _commandPatterns.entries) {
//       if (entry.value.hasMatch(spokenInput)) {
//         return entry.key;
//       }
//     }
//     return 'unknown_command';
//   }
//
//
//   //TODO: ADd logic to the commands here
//   // Execute the command and return a response
//   String _executeCommand(String command, String spokenInput) {
//     switch (command) {
//       case 'open_note':
//         return 'Note opened';
//       case 'create_note':
//         return 'Note created';
//       case 'set_title':
//         final title = spokenInput.replaceAll(_commandPatterns['set_title']!, '').trim();
//         return 'Title set to: $title';
//       case 'add_description':
//         final description = spokenInput.replaceAll(_commandPatterns['add_description']!, '').trim();
//         return 'Description added: $description';
//       default:
//         return 'Command not recognized';
//     }
//   }
// }


import 'dart:async';
import 'dart:collection';
import 'package:note_up/classes/voiceLog.dart';
import 'package:note_up/dbs/VoiceDbHelper.dart';

class CommandProcessor {
  final Queue<VoiceLog> _inBuffer = Queue();
  final Queue<VoiceLog> _outBuffer = Queue();
  final VoiceLogDb _logDb = VoiceLogDb();
  final StreamController<Map<String, dynamic>> _commandStreamController =
  StreamController.broadcast();

  // Stream to listen for processed commands
  Stream<Map<String, dynamic>> get commandStream => _commandStreamController.stream;

  // Regex patterns for command classification
  final Map<String, RegExp> _commandPatterns = {
    'open_note': RegExp(r'\b(open|show)\s+note\b', caseSensitive: false),
    'create_note': RegExp(r'\b(create|new)\s+note\b', caseSensitive: false),
    'set_title': RegExp(r'\b(set|change)\s+title\b', caseSensitive: false),
    'add_description': RegExp(r'\b(add|update)\s+description\b', caseSensitive: false),
  };

  // Start processing commands from the IN buffer
  void startProcessing() async {
    while (_inBuffer.isNotEmpty) {
      final log = _inBuffer.removeFirst();
      final processedLog = await _processCommand(log);
      _outBuffer.add(processedLog);
      await _logDb.insertLog(processedLog);
    }
  }

  // Add a command to the IN buffer
  void addToInBuffer(VoiceLog log) {
    _inBuffer.add(log);
    startProcessing();
  }

  // Classify and execute the command
  Future<VoiceLog> _processCommand(VoiceLog log) async {
    final String detectedCommand = _classifyCommand(log.spokenInput);
    final Map<String, dynamic> result = _executeCommand(detectedCommand, log.spokenInput);

    // Emit the result to the stream
    _commandStreamController.add(result);

    return VoiceLog(
      id: log.id,
      timestamp: log.timestamp,
      spokenInput: log.spokenInput,
      command: detectedCommand,
      response: result['response'],
      status: 'executed',
    );
  }

  // Classify command using regex
  String _classifyCommand(String spokenInput) {
    for (var entry in _commandPatterns.entries) {
      if (entry.value.hasMatch(spokenInput)) {
        return entry.key;
      }
    }
    return 'unknown_command';
  }

  // Execute the command and return a result map
  Map<String, dynamic> _executeCommand(String command, String spokenInput) {
    switch (command) {
      case 'open_note':
        return {
          'action': 'navigate',
          'command': 'open_note',
          'response': 'Note opened',
        };
      case 'create_note':
        return {
          'action': 'creation',
          'command': 'create_note',
          'response': 'Note created',
        };
      case 'set_title':
        final title = spokenInput.replaceAll(_commandPatterns['set_title']!, '').trim();
        return {
          'action': 'none',
          'command': 'set_title',
          'response': 'Title set to: $title',
        };
      case 'add_description':
        final description = spokenInput.replaceAll(_commandPatterns['add_description']!, '').trim();
        return {
          'action': 'none',
          'command': 'add_description',
          'response': 'Description added: $description',
        };
      default:
        return {
          'action': 'none',
          'command': 'unknown_command',
          'response': 'Command not recognized',
        };
    }
  }

  // Dispose of the stream controller
  void dispose() {
    _commandStreamController.close();
  }
}