// import 'package:flutter/material.dart';
// import '../classes/voiceLog.dart';
// import '../dbs/VoiceDbHelper.dart';
//
// class VoiceLogViewerPage extends StatefulWidget {
//   const VoiceLogViewerPage({super.key});
//
//   @override
//   State<VoiceLogViewerPage> createState() => _VoiceLogViewerPageState();
// }
//
// class _VoiceLogViewerPageState extends State<VoiceLogViewerPage> {
//   List<VoiceLog> _logs = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadLogs();
//   }
//
//   Future<void> _loadLogs() async {
//     final logs = await VoiceLogDb().getLogs();
//     if (mounted) {
//       setState(() {
//         _logs = logs;
//       });
//     }
//   }
//
//   Future<void> _clearLogs() async {
//     await VoiceLogDb().clearLogs();
//     await _loadLogs();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5), // Soft beige
//       appBar: AppBar(
//         title: const Text(
//           'Voice Log History',
//           style: TextStyle(
//             fontFamily: 'Roboto',
//             fontSize: 18,
//             fontWeight: FontWeight.w500,
//             color: Color(0xFF4A4A4A), // Warm gray
//           ),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(
//               Icons.delete_forever,
//               color: Color(0xFFF28C38), // Coral
//             ),
//             onPressed: () async {
//               final confirm = await showDialog<bool>(
//                 context: context,
//                 builder:
//                     (_) => AlertDialog(
//                       backgroundColor: Colors.white,
//                       title: const Text(
//                         'Clear History?',
//                         style: TextStyle(
//                           fontFamily: 'Roboto',
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                           color: Color(0xFF4A4A4A),
//                         ),
//                       ),
//                       content: const Text(
//                         'This will permanently delete all voice logs.',
//                         style: TextStyle(
//                           fontFamily: 'Roboto',
//                           fontSize: 14,
//                           color: Color(0xFF4A4A4A),
//                         ),
//                       ),
//                       actions: [
//                         TextButton(
//                           onPressed: () => Navigator.pop(context, false),
//                           child: const Text(
//                             'Cancel',
//                             style: TextStyle(
//                               fontFamily: 'Roboto',
//                               fontSize: 14,
//                               color: Color(0xFF4A4A4A),
//                             ),
//                           ),
//                         ),
//                         TextButton(
//                           onPressed: () => Navigator.pop(context, true),
//                           child: const Text(
//                             'Delete',
//                             style: TextStyle(
//                               fontFamily: 'Roboto',
//                               fontSize: 14,
//                               color: Color(0xFFF28C38), // Coral
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//               );
//               if (confirm == true) _clearLogs();
//             },
//           ),
//         ],
//       ),
//       body:
//           _logs.isEmpty
//               ? const Center(
//                 child: Text(
//                   'No logs recorded',
//                   style: TextStyle(
//                     fontFamily: 'Roboto',
//                     fontSize: 16,
//                     color: Color(0xFF4A4A4A),
//                   ),
//                 ),
//               )
//               : ListView.builder(
//                 key: ValueKey(_logs.length), // Reload when logs change
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//                 itemCount: _logs.length,
//                 itemBuilder: (context, index) {
//                   final log = _logs[index];
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 4),
//                     child: Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(
//                           color: const Color(0xFFE0E0E0),
//                           width: 1,
//                         ), // Light gray border
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 4,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             log.spokenInput,
//                             style: const TextStyle(
//                               fontFamily: 'Roboto',
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               color: Color(0xFF4A4A4A),
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             'Time: ${log.timestamp.split('T').first} ${log.timestamp.split('T').last.split('.').first}',
//                             style: const TextStyle(
//                               fontFamily: 'Roboto',
//                               fontSize: 12,
//                               color: Color(0xFF6B7280), // Slightly lighter gray
//                             ),
//                           ),
//                           Text(
//                             'Command: ${log.command}',
//                             style: const TextStyle(
//                               fontFamily: 'Roboto',
//                               fontSize: 12,
//                               color: Color(0xFF6B7280),
//                             ),
//                           ),
//                           Text(
//                             'Response: ${log.response}',
//                             style: const TextStyle(
//                               fontFamily: 'Roboto',
//                               fontSize: 12,
//                               color: Color(0xFF6B7280),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import '../classes/voiceLog.dart';
import '../dbs/VoiceDbHelper.dart';

class VoiceLogViewerPage extends StatefulWidget {
  const VoiceLogViewerPage({super.key});

  @override
  State<VoiceLogViewerPage> createState() => _VoiceLogViewerPageState();
}

class _VoiceLogViewerPageState extends State<VoiceLogViewerPage> {
  List<VoiceLog> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final logs = await VoiceLogDb().getLogs();
    if (mounted) {
      setState(() {
        _logs = logs;
      });
    }
  }

  Future<void> _clearLogs() async {
    await VoiceLogDb().clearLogs();
    await _loadLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Voice Log History',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4A4A4A),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_forever,
              color: Color(0xFFF28C38),
            ),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: Colors.white,
                  title: const Text(
                    'Clear History?',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4A4A4A),
                    ),
                  ),
                  content: const Text(
                    'This will permanently delete all voice logs.',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      color: Color(0xFF4A4A4A),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          color: Color(0xFFF28C38),
                        ),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) _clearLogs();
            },
          ),
        ],
      ),
      body: _logs.isEmpty
          ? const Center(
        child: Text(
          'No logs recorded',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16,
            color: Color(0xFF4A4A4A),
          ),
        ),
      )
          : ListView.builder(
        key: ValueKey(_logs.length),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _logs.length,
        itemBuilder: (context, index) {
          final log = _logs[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFE0E0E0),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.spokenInput,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4A4A4A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Time: ${log.timestamp.split('T').first} ${log.timestamp.split('T').last.split('.').first}',
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  Text(
                    'Command: ${log.command}',
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  Text(
                    'Response: ${log.response}',
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  Text(
                    'Status: ${log.status}',
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
