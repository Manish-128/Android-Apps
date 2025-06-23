// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';
//
// import '../classes/Code.dart';
//
// class GeminiCodePage extends StatefulWidget {
//   final Code? initialCode;
//   final Function(String, String?)? onSave;
//
//   const GeminiCodePage({super.key, this.initialCode, this.onSave});
//
//   @override
//   State<GeminiCodePage> createState() => _GeminiCodePageState();
// }
//
// class _GeminiCodePageState extends State<GeminiCodePage> with SingleTickerProviderStateMixin {
//   final TextEditingController _codeController = TextEditingController();
//   final FocusNode _focusNode = FocusNode();
//   late final GenerativeModel _model;
//   String _response = '';
//   bool _isLoading = false;
//   int _selectedTab = 0;
//   bool _isFullScreen = false;
//
//   final String _apiKey = 'AIzaSyCQCJR1iPYDGxlWvlCA4S9bywbFgXo4P8w'; // Replace with your Gemini API key
//
//   @override
//   void initState() {
//     super.initState();
//     _model = GenerativeModel(
//       model: 'gemini-1.5-flash',
//       apiKey: _apiKey,
//     );
//     if (widget.initialCode != null) {
//       _codeController.text = widget.initialCode!.content;
//       _response = widget.initialCode!.analysis ?? '';
//     }
//   }
//
//   Future<void> _analyzeCode() async {
//     final inputCode = _codeController.text.trim();
//     if (inputCode.isEmpty) return;
//
//     setState(() {
//       _isLoading = true;
//       _response = '';
//       _selectedTab = 0;
//     });
//
//     try {
//       final prompt = '''
// Analyze the following code and provide the following information in **numbered sections**:
// 1. Title or Problem Type (in a short line — e.g., "Two Pointers", "String Manipulation").
// 2. Time and Space Complexity (in Big O notation and explain briefly).
// 3. Step-by-Step Summary (clear, logical steps in bullet points).
//
// Here is the code:
// $inputCode
// ''';
//
//       final content = [Content.text(prompt)];
//       final result = await _model.generateContent(content);
//
//       setState(() {
//         _response = result.text?.trim() ?? 'No response received.';
//       });
//
//       if (widget.onSave != null) {
//         widget.onSave!(inputCode, _response);
//       }
//     } catch (e) {
//       setState(() {
//         _response = 'Error: $e';
//       });
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   void _copyCode() {
//     Clipboard.setData(ClipboardData(text: _codeController.text));
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Code copied to clipboard!')),
//     );
//   }
//
//   void _toggleFullScreen() {
//     setState(() {
//       _isFullScreen = !_isFullScreen;
//     });
//     if (_isFullScreen) {
//       _focusNode.requestFocus();
//     } else {
//       _focusNode.unfocus();
//     }
//   }
//
//   Widget _buildCodeInputField() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Container(
//         height: _isFullScreen ? MediaQuery.of(context).size.height * 0.8 : 250,
//         decoration: BoxDecoration(
//           color: Colors.grey[50],
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.indigo[200]!),
//         ),
//         child: Stack(
//           children: [
//             TextField(
//               controller: _codeController,
//               focusNode: _focusNode,
//               maxLines: null,
//               expands: true,
//               textAlignVertical: TextAlignVertical.top,
//               style: const TextStyle(
//                 fontFamily: 'monospace',
//                 color: Colors.black87,
//                 fontSize: 14,
//               ),
//               decoration: InputDecoration(
//                 contentPadding: const EdgeInsets.all(16),
//                 hintText: 'Paste your code here...',
//                 hintStyle: TextStyle(color: Colors.grey[400]),
//                 border: InputBorder.none,
//               ),
//             ),
//             Positioned(
//               top: 8,
//               right: 8,
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.copy, size: 20, color: Colors.amber),
//                     onPressed: _codeController.text.isEmpty ? null : _copyCode,
//                     tooltip: 'Copy Code',
//                   ),
//                   IconButton(
//                     icon: Icon(
//                       _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
//                       size: 20,
//                       color: Colors.amber,
//                     ),
//                     onPressed: _toggleFullScreen,
//                     tooltip: _isFullScreen ? 'Exit Full Screen' : 'Full Screen',
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAnalyzeButton() {
//     final isDisabled = _codeController.text.trim().isEmpty || _isLoading;
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: isDisabled
//               ? [Colors.grey[400]!, Colors.grey[400]!]
//               : [Colors.indigo, Colors.indigoAccent],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.indigo.withOpacity(0.3),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: ElevatedButton(
//         onPressed: isDisabled ? null : _analyzeCode,
//         style: ElevatedButton.styleFrom(
//           padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
//           backgroundColor: Colors.transparent,
//           shadowColor: Colors.transparent,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//         child: _isLoading
//             ? const SizedBox(
//           width: 24,
//           height: 24,
//           child: CircularProgressIndicator(
//             strokeWidth: 2,
//             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//           ),
//         )
//             : const Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.analytics, color: Colors.white),
//             SizedBox(width: 8),
//             Text(
//               'Analyze Code',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildResponseSection() {
//     if (_response.isEmpty) return const SizedBox.shrink();
//
//     // Remove ** markers and prepare for bold styling
//     final cleanedResponse = _response.replaceAll(RegExp(r'\*\*'), '');
//
//     final regex = RegExp(
//       r'1\.\s*(.*?)\s*2\.\s*(.*?)\s*3\.\s*(.*)',
//       dotAll: true,
//     );
//
//     final match = regex.firstMatch(cleanedResponse);
//
//     if (match == null || match.groupCount < 3) {
//       return Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.red[50],
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: SelectableText(
//             cleanedResponse,
//             style: const TextStyle(fontSize: 14, color: Colors.red),
//           ),
//         ),
//       );
//     }
//
//     final title = match.group(1)!.trim();
//     final complexity = match.group(2)!.trim();
//     final summary = match.group(3)!.trim();
//
//     final tabs = [
//       {'title': 'Problem Type', 'content': title, 'icon': Icons.bolt},
//       {'title': 'Complexity', 'content': complexity, 'icon': Icons.speed},
//       {'title': 'Summary', 'content': summary, 'icon': Icons.list_alt},
//     ];
//
//     // Build RichText with bold headers for each section
//     Widget buildRichText(String content, String sectionTitle) {
//       final lines = content.split('\n');
//       final children = <TextSpan>[];
//
//       for (var line in lines) {
//         if (line.startsWith(RegExp(r'\d+\.\s+')) || line.trim().isEmpty) {
//           // Bold for numbered headers (e.g., "1. Title or Problem Type")
//           children.add(TextSpan(
//             text: '$line\n',
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 14,
//               color: Colors.black87,
//             ),
//           ));
//         } else {
//           // Regular text for other lines
//           children.add(TextSpan(
//             text: '$line\n',
//             style: const TextStyle(
//               fontSize: 14,
//               color: Colors.black87,
//             ),
//           ));
//         }
//       }
//
//       return SelectableText.rich(
//         TextSpan(children: children),
//       );
//     }
//
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Column(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.grey[100],
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//             ),
//             child: Row(
//               children: List.generate(tabs.length, (index) {
//                 return Expanded(
//                   child: GestureDetector(
//                     onTap: () => setState(() => _selectedTab = index),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       decoration: BoxDecoration(
//                         color: _selectedTab == index
//                             ? Colors.indigo.withOpacity(0.1)
//                             : Colors.transparent,
//                         border: Border(
//                           bottom: BorderSide(
//                             color: _selectedTab == index
//                                 ? Colors.indigo
//                                 : Colors.transparent,
//                             width: 2,
//                           ),
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(tabs[index]['icon'] as IconData,
//                               color: _selectedTab == index
//                                   ? Colors.indigo
//                                   : Colors.grey),
//                           const SizedBox(width: 4),
//                           Text(
//                             tabs[index]['title'] as String,
//                             style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: _selectedTab == index
//                                   ? FontWeight.bold
//                                   : FontWeight.normal,
//                               color: _selectedTab == index
//                                   ? Colors.indigo
//                                   : Colors.grey,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               }),
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(16),
//             child: buildRichText(tabs[_selectedTab]['content'] as String, tabs[_selectedTab]['title'] as String),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => _focusNode.unfocus(),
//       child: Scaffold(
//         backgroundColor: Colors.grey[100],
//         appBar: AppBar(
//           title: const Text(
//             'Code Analyzer',
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//           flexibleSpace: Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.indigo, Colors.indigoAccent],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//           elevation: 0,
//         ),
//         body: _isFullScreen
//             ? Padding(
//           padding: const EdgeInsets.all(16),
//           child: _buildCodeInputField(),
//         )
//             : Padding(
//           padding: const EdgeInsets.all(16),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const Text(
//                   'Paste your code to analyze',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.indigo,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 _buildCodeInputField(),
//                 const SizedBox(height: 16),
//                 _buildAnalyzeButton(),
//                 const SizedBox(height: 20),
//                 AnimatedOpacity(
//                   opacity: _response.isEmpty ? 0 : 1,
//                   duration: const Duration(milliseconds: 300),
//                   child: _buildResponseSection(),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _codeController.dispose();
//     _focusNode.dispose();
//     super.dispose();
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:note_up/classes/Code.dart';

class GeminiCodePage extends StatefulWidget {
  final Code? initialCode;
  final Function(String, String?, String?)? onSave; // Updated to include title

  const GeminiCodePage({super.key, this.initialCode, this.onSave});

  @override
  State<GeminiCodePage> createState() => _GeminiCodePageState();
}

class _GeminiCodePageState extends State<GeminiCodePage> with SingleTickerProviderStateMixin {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late final GenerativeModel _model;
  String _response = '';
  bool _isLoading = false;
  int _selectedTab = 0;
  bool _isFullScreen = false;

  final String _apiKey = 'AIzaSyCQCJR1iPYDGxlWvlCA4S9bywbFgXo4P8w'; // Replace with your Gemini API key

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey!,
    );
    if (widget.initialCode != null) {
      _codeController.text = widget.initialCode!.content;
      _response = widget.initialCode!.analysis ?? '';
    }
  }

  Future<void> _analyzeCode() async {
    final inputCode = _codeController.text.trim();
    if (inputCode.isEmpty) return;

    setState(() {
      _isLoading = true;
      _response = '';
      _selectedTab = 0;
    });

    try {
      final prompt = '''
Analyze the following code and provide the following information in **numbered sections**:
1. Title or Problem Type (in a short line — e.g., "Two Pointers", "String Manipulation").
2. Time and Space Complexity (in Big O notation and explain briefly).
3. Step-by-Step Summary (in bullet points).

Here is the code:
```dart
$inputCode
```
''';

      final content = [Content.text(prompt)];
      final result = await _model.generateContent(content);

      setState(() {
        _response = result.text?.trim() ?? 'No response received.';
      });

      // Extract title from the response
      String? extractedTitle;
      final cleanedResponse = _response.replaceAll(RegExp(r'\*\*'), '');
      final regex = RegExp(r'1\.\s*(.*?)\s*2\.\s*(.*?)\s*3\.\s*(.*)', dotAll: true);
      final match = regex.firstMatch(cleanedResponse);
      if (match != null && match.groupCount >= 1) {
        extractedTitle = match.group(1)?.trim();
      }

      if (widget.onSave != null) {
        widget.onSave!(inputCode, _response, extractedTitle);
      }
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: _codeController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code copied to clipboard!')),
    );
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
    if (_isFullScreen) {
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
    }
  }

  Widget _buildCodeInputField() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: _isFullScreen ? MediaQuery.of(context).size.height * 0.8 : 250,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.indigo[200]!),
        ),
        child: Stack(
          children: [
            TextField(
              controller: _codeController,
              focusNode: _focusNode,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: Colors.black87,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(16),
                hintText: 'Paste your code here...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20, color: Colors.amber),
                    onPressed: _codeController.text.isEmpty ? null : _copyCode,
                    tooltip: 'Copy Code',
                  ),
                  IconButton(
                    icon: Icon(
                      _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                      size: 20,
                      color: Colors.amber,
                    ),
                    onPressed: _toggleFullScreen,
                    tooltip: _isFullScreen ? 'Exit Full Screen' : 'Full Screen',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    final isDisabled = _codeController.text.trim().isEmpty || _isLoading;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDisabled
              ? [Colors.grey[400]!, Colors.grey[400]!]
              : [Colors.indigo, Colors.indigoAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isDisabled ? null : _analyzeCode,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.analytics, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Analyze Code',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseSection() {
    if (_response.isEmpty) return const SizedBox.shrink();

    // Remove ** markers and prepare for bold styling
    final cleanedResponse = _response.replaceAll(RegExp(r'\*\*'), '');

    final regex = RegExp(
      r'1\.\s*(.*?)\s*2\.\s*(.*?)\s*3\.\s*(.*)',
      dotAll: true,
    );

    final match = regex.firstMatch(cleanedResponse);

    if (match == null || match.groupCount < 3) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: SelectableText(
            cleanedResponse,
            style: const TextStyle(fontSize: 14, color: Colors.red),
          ),
        ),
      );
    }

    final title = match.group(1)!.trim();
    final complexity = match.group(2)!.trim();
    final summary = match.group(3)!.trim();

    final tabs = [
      {'title': 'Problem Type', 'content': title, 'icon': Icons.bolt},
      {'title': 'Complexity', 'content': complexity, 'icon': Icons.speed},
      {'title': 'Summary', 'content': summary, 'icon': Icons.list_alt},
    ];

    // Build RichText with bold headers for each section
    Widget buildRichText(String content, String sectionTitle) {
      final lines = content.split('\n');
      final children = <TextSpan>[];

      for (var line in lines) {
        if (line.startsWith(RegExp(r'\d+\.\s+')) || line.trim().isEmpty) {
          // Bold for numbered headers (e.g., "1. Title or Problem Type")
          children.add(TextSpan(
            text: '$line\n',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ));
        } else {
          // Regular text for other lines
          children.add(TextSpan(
            text: '$line\n',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ));
        }
      }

      return SelectableText.rich(
        TextSpan(children: children),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: List.generate(tabs.length, (index) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTab == index
                            ? Colors.indigo.withOpacity(0.1)
                            : Colors.transparent,
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTab == index
                                ? Colors.indigo
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(tabs[index]['icon'] as IconData,
                              color: _selectedTab == index
                                  ? Colors.indigo
                                  : Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            tabs[index]['title'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _selectedTab == index
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: _selectedTab == index
                                  ? Colors.indigo
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: buildRichText(tabs[_selectedTab]['content'] as String, tabs[_selectedTab]['title'] as String),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _focusNode.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            'Code Analyzer',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo, Colors.indigoAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 0,
        ),
        body: _isFullScreen
            ? Padding(
          padding: const EdgeInsets.all(16),
          child: _buildCodeInputField(),
        )
            : Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Paste your code to analyze',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 12),
                _buildCodeInputField(),
                const SizedBox(height: 16),
                _buildAnalyzeButton(),
                const SizedBox(height: 20),
                AnimatedOpacity(
                  opacity: _response.isEmpty ? 0 : 1,
                  duration: const Duration(milliseconds: 300),
                  child: _buildResponseSection(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}