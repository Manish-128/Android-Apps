// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:permission_handler/permission_handler.dart';
// import '../classes/voiceLog.dart';
// import '../dbs/VoiceDbHelper.dart';
// import 'package:note_up/service/CommandProcessor.dart';
//
// class SpeechToTextPage extends StatefulWidget {
//   const SpeechToTextPage({super.key});
//
//   @override
//   State<SpeechToTextPage> createState() => _SpeechToTextPageState();
// }
//
// class _SpeechToTextPageState extends State<SpeechToTextPage> {
//   late stt.SpeechToText _speech;
//   bool _isListening = false;
//   bool _speechEnabled = false;
//   String _spokenText = 'Tap to speak';
//   final CommandProcessor _commandProcessor = CommandProcessor();
//
//   @override
//   void initState() {
//     super.initState();
//     _speech = stt.SpeechToText();
//     _checkPermissionsAndInit();
//   }
//
//   Future<void> _checkPermissionsAndInit() async {
//     var status = await Permission.microphone.request();
//     if (status.isGranted) {
//       bool available = await _speech.initialize(
//         onError: (error) => debugPrint('Error: $error'),
//       );
//
//       if (mounted) {
//         setState(() {
//           _speechEnabled = available;
//           if (!available) {
//             _spokenText = 'Speech recognition unavailable';
//           }
//         });
//       }
//     } else {
//       if (mounted) {
//         setState(() {
//           _spokenText = 'Microphone permission denied';
//         });
//       }
//     }
//   }
//
//   void _startListening() async {
//     if (!_speechEnabled) return;
//
//     await _speech.listen(
//       onResult: (result) async {
//         final String spoken = result.recognizedWords;
//
//         if (mounted) {
//           setState(() {
//             _spokenText = spoken.isEmpty ? 'Tap to speak' : spoken;
//           });
//         }
//
//         if (result.finalResult && spoken.isNotEmpty) {
//           final log = VoiceLog(
//             timestamp: DateTime.now().toIso8601String(),
//             spokenInput: spoken,
//             command: 'pending',
//             response: 'Processing...',
//             status: 'pending',
//           );
//           _commandProcessor.addToInBuffer(log);
//         }
//       },
//       localeId: 'en_US',
//     );
//
//     if (mounted) {
//       setState(() => _isListening = true);
//     }
//   }
//
//   void _stopListening() async {
//     await _speech.stop();
//     if (mounted) {
//       setState(() => _isListening = false);
//     }
//   }
//
//   void _toggleListening() {
//     if (_isListening) {
//       _stopListening();
//     } else {
//       _startListening();
//     }
//   }
//
//   @override
//   void dispose() {
//     _speech.stop();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//       appBar: AppBar(
//         title: const Text(
//           'Voice Notes',
//           style: TextStyle(
//             fontFamily: 'Roboto',
//             fontSize: 18,
//             fontWeight: FontWeight.w500,
//             color: Color(0xFF4A4A4A),
//           ),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 300,
//               height: 200,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Center(
//                 child: Text(
//                   _spokenText,
//                   key: ValueKey(_spokenText),
//                   style: const TextStyle(
//                     fontFamily: 'Roboto',
//                     fontSize: 16,
//                     color: Color(0xFF4A4A4A),
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             GestureDetector(
//               onTap: _speechEnabled ? _toggleListening : null,
//               child: Container(
//                 width: 56,
//                 height: 56,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: _isListening ? const Color(0xFFF28C38) : const Color(0xFFE0E0E0),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 4,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Icon(
//                   _isListening ? Icons.stop : Icons.mic,
//                   color: _isListening ? Colors.white : const Color(0xFF4A4A4A),
//                   size: 28,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               _isListening
//                   ? 'Listening...'
//                   : _speechEnabled
//                   ? 'Tap to start'
//                   : 'Unavailable',
//               style: const TextStyle(
//                 fontFamily: 'Roboto',
//                 fontSize: 14,
//                 color: Color(0xFF4A4A4A),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:note_up/classes/note_class.dart';
import 'package:note_up/functionality/notes.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../Providers/notesProvider.dart';
import '../classes/voiceLog.dart';
import '../screens/note_screens.dart';
import '../service/CommandProcessor.dart'; // Import your NoteScreens widget

class SpeechToTextPage extends StatefulWidget {
  const SpeechToTextPage({super.key});

  @override
  State<SpeechToTextPage> createState() => _SpeechToTextPageState();
}

class _SpeechToTextPageState extends State<SpeechToTextPage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechEnabled = false;
  String _spokenText = 'Tap to speak';
  late CommandProcessor _commandProcessor;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _commandProcessor = CommandProcessor();
    _checkPermissionsAndInit();
    // Listen to command processor stream for navigation
    _commandProcessor.commandStream.listen((result) async {
      if (result['action'] == 'navigate' && result['command'] == 'open_note') {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NoteScreens(isDark: false)),
          );
        }
      }
      else if (result['action'] == 'creation' && result['command'] == 'create_note') {
        final note = Note(title: '', content: '');
        final savedNote = await context.read<NotesProvider>().addNote(note: note);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Notes(isDark: false, contNote: savedNote),
            ),
          );
        }
      }
    });
  }

  Future<void> _checkPermissionsAndInit() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      bool available = await _speech.initialize(
        onError: (error) => debugPrint('Error: $error'),
      );

      if (mounted) {
        setState(() {
          _speechEnabled = available;
          if (!available) {
            _spokenText = 'Speech recognition unavailable';
          }
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _spokenText = 'Microphone permission denied';
        });
      }
    }
  }

  void _startListening() async {
    if (!_speechEnabled) return;

    await _speech.listen(
      onResult: (result) async {
        final String spoken = result.recognizedWords;

        if (mounted) {
          setState(() {
            _spokenText = spoken.isEmpty ? 'Tap to speak' : spoken;
          });
        }

        if (result.finalResult && spoken.isNotEmpty) {
          final log = VoiceLog(
            timestamp: DateTime.now().toIso8601String(),
            spokenInput: spoken,
            command: 'pending',
            response: 'Processing...',
            status: 'pending',
          );
          _commandProcessor.addToInBuffer(log);
        }
      },
      localeId: 'en_US',
    );

    if (mounted) {
      setState(() => _isListening = true);
    }
  }

  void _stopListening() async {
    await _speech.stop();
    if (mounted) {
      setState(() => _isListening = false);
    }
  }

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _commandProcessor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Voice Notes',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4A4A4A),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  _spokenText,
                  key: ValueKey(_spokenText),
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    color: Color(0xFF4A4A4A),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _speechEnabled ? _toggleListening : null,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening ? const Color(0xFFF28C38) : const Color(0xFFE0E0E0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.stop : Icons.mic,
                  color: _isListening ? Colors.white : const Color(0xFF4A4A4A),
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isListening
                  ? 'Listening...'
                  : _speechEnabled
                  ? 'Tap to start'
                  : 'Unavailable',
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                color: Color(0xFF4A4A4A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}