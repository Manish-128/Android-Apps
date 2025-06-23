// import 'package:flutter/material.dart';
// import 'package:flutter_speed_dial/flutter_speed_dial.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:note_up/Providers/themeProvider.dart';
// import 'package:note_up/screens/sideBar.dart';
//
// import '../Providers/code_provider.dart';
// import '../classes/Code.dart';
// import '../functionality/DSAHelper.dart';
// import 'HomeScreen.dart';
//
// class CodeScreen extends StatefulWidget {
//   final bool isDark;
//   const CodeScreen({required this.isDark, super.key});
//
//   @override
//   State<CodeScreen> createState() => _CodeScreenState();
// }
//
// class _CodeScreenState extends State<CodeScreen> {
//   final TextEditingController _searchCont = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   late Future<bool> _loadFuture;
//   bool _isLoading = false;
//   bool toggleVal = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadFuture = _loadCodes();
//     _searchCont.addListener(() => setState(() {}));
//     toggleVal = widget.isDark;
//   }
//
//   @override
//   void dispose() {
//     _searchCont.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   Future<bool> _loadCodes() async {
//     try {
//       await context.read<CodeProvider>().loadCodes();
//       return true;
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error loading codes: $e')),
//         );
//       }
//       return false;
//     }
//   }
//
//   void _addCode() async {
//     setState(() => _isLoading = true);
//     try {
//       final code = Code(content: '');
//       final savedCode = await context.read<CodeProvider>().addCode(code: code);
//       if (mounted) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => GeminiCodePage(
//               initialCode: savedCode,
//               onSave: (content, analysis) async {
//                 await context.read<CodeProvider>().updateCode(
//                   code: Code(
//                     id: savedCode.id,
//                     content: content,
//                     analysis: analysis,
//                   ),
//                 );
//               },
//             ),
//           ),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   void _deleteCode(Code code) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Code'),
//         content: const Text('Are you sure you want to delete this code snippet?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               context.read<CodeProvider>().deleteCode(codeId: code.id ?? 0);
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Code deleted')),
//               );
//             },
//             child: Text(
//               'Delete',
//               style: TextStyle(color: Theme.of(context).colorScheme.error),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = context.watch<ThemeProvider>();
//     return Scaffold(
//       backgroundColor: theme.backg,
//       appBar: AppBar(
//         backgroundColor: theme.backg,
//         title: Text(
//           "Code Snippets",
//           style: GoogleFonts.montserrat(
//             color: theme.textCol,
//             fontSize: 24,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//         elevation: 0,
//         actions: [
//           IconButton(
//             onPressed: () {
//               setState(() {
//                 _isLoading = true;
//                 _loadFuture = _loadCodes();
//               });
//             },
//             icon: const Icon(Icons.refresh),
//             color: theme.buttonCol,
//           ),
//           IconButton(
//             onPressed: () {
//               setState(() {
//                 toggleVal = !toggleVal;
//               });
//               ThemeUtils.changeTheme(context, toggleVal);
//             },
//             icon: Icon(
//               widget.isDark ? Icons.dark_mode : Icons.light_mode,
//               size: 28,
//             ),
//             color: theme.buttonCol,
//           ),
//         ],
//         leading: Builder(
//           builder: (context) => IconButton(
//             onPressed: () => Scaffold.of(context).openDrawer(),
//             icon: const Icon(Icons.menu),
//             color: theme.buttonCol,
//           ),
//         ),
//       ),
//       drawer: Sidebar(isDark: widget.isDark),
//       floatingActionButton: SpeedDial(
//         animatedIcon: AnimatedIcons.menu_close,
//         backgroundColor: Colors.indigo.shade400,
//         overlayColor: Colors.black,
//         overlayOpacity: 0.4,
//         spacing: 12,
//         spaceBetweenChildren: 12,
//         children: [
//           SpeedDialChild(
//             child: const Icon(Icons.code),
//             label: 'New Code',
//             backgroundColor: Colors.indigo.shade300,
//             onTap: _isLoading ? null : _addCode,
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: _searchCont,
//               style: GoogleFonts.roboto(
//                 color: theme.inputTextCol,
//                 fontSize: 16,
//               ),
//               decoration: InputDecoration(
//                 hintText: "Search Code Snippets",
//                 hintStyle: TextStyle(color: theme.buttonCol.withOpacity(0.6)),
//                 prefixIcon: Icon(Icons.search, color: theme.buttonCol),
//                 suffixIcon: _searchCont.text.isNotEmpty
//                     ? IconButton(
//                   icon: const Icon(Icons.clear),
//                   color: theme.buttonCol,
//                   onPressed: () => setState(() => _searchCont.clear()),
//                 )
//                     : null,
//                 filled: true,
//                 fillColor: theme.backg?.withOpacity(0.1),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Expanded(
//               child: FutureBuilder<bool>(
//                 future: _loadFuture,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return _buildSkeletonLoader(theme);
//                   }
//
//                   if (snapshot.hasError) {
//                     return Center(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(Icons.error_outline, size: 48, color: theme.buttonCol),
//                           const SizedBox(height: 8),
//                           Text(
//                             "Error loading code snippets",
//                             style: GoogleFonts.roboto(
//                               fontSize: 18,
//                               color: theme.buttonCol,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }
//
//                   final codes = context.watch<CodeProvider>().syncCodesFromScreen();
//                   final filteredCodes = codes
//                       .where((code) =>
//                       code.content.toLowerCase().contains(_searchCont.text.toLowerCase()))
//                       .toList();
//
//                   if (filteredCodes.isEmpty) {
//                     return Center(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             Icons.code_off_outlined,
//                             size: 48,
//                             color: theme.buttonCol.withOpacity(0.5),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             "No code snippets found",
//                             style: GoogleFonts.roboto(
//                               fontSize: 18,
//                               color: theme.buttonCol,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }
//
//                   return GridView.builder(
//                     controller: _scrollController,
//                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       mainAxisExtent: 200,
//                       mainAxisSpacing: 16,
//                       crossAxisSpacing: 16,
//                     ),
//                     itemCount: filteredCodes.length,
//                     itemBuilder: (context, index) {
//                       final code = filteredCodes[index];
//                       return Card(
//                         elevation: 3,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: InkWell(
//                           borderRadius: BorderRadius.circular(12),
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => GeminiCodePage(
//                                   initialCode: code,
//                                   onSave: (content, analysis) async {
//                                     await context.read<CodeProvider>().updateCode(
//                                       code: Code(
//                                         id: code.id,
//                                         content: content,
//                                         analysis: analysis,
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ),
//                             );
//                           },
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Container(
//                                 decoration: BoxDecoration(
//                                   color: Colors.indigo.shade700,
//                                   borderRadius: const BorderRadius.only(
//                                     topLeft: Radius.circular(12),
//                                     topRight: Radius.circular(12),
//                                   ),
//                                 ),
//                                 padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
//                                 child: Row(
//                                   children: [
//                                     Expanded(
//                                       child: Text(
//                                         code.content.isEmpty ? 'Untitled' : code.content.substring(0, code.content.length > 20 ? 20 : code.content.length) + '...',
//                                         style: GoogleFonts.openSans(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 16,
//                                           color: Colors.white,
//                                         ),
//                                         maxLines: 1,
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     ),
//                                     IconButton(
//                                       icon: const Icon(Icons.delete_outline, color: Colors.white),
//                                       onPressed: () => _deleteCode(code),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Container(
//                                   padding: const EdgeInsets.all(12),
//                                   decoration: BoxDecoration(
//                                     color: Colors.indigo.shade100,
//                                     borderRadius: const BorderRadius.only(
//                                       bottomLeft: Radius.circular(12),
//                                       bottomRight: Radius.circular(12),
//                                     ),
//                                   ),
//                                   child: Text(
//                                     code.analysis?.isEmpty ?? true ? 'No analysis yet' : code.analysis!,
//                                     style: GoogleFonts.openSans(
//                                       fontWeight: FontWeight.w500,
//                                       fontSize: 14,
//                                       color: theme.textCol,
//                                     ),
//                                     maxLines: 6,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSkeletonLoader(ThemeProvider theme) {
//     return GridView.builder(
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         mainAxisExtent: 200,
//         mainAxisSpacing: 16,
//         crossAxisSpacing: 16,
//       ),
//       itemCount: 4,
//       itemBuilder: (context, index) => Card(
//         elevation: 3,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               height: 48,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(12),
//                   topRight: Radius.circular(12),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: const BorderRadius.only(
//                     bottomLeft: Radius.circular(12),
//                     bottomRight: Radius.circular(12),
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(height: 16, width: 100, color: Colors.grey[300]),
//                     const SizedBox(height: 8),
//                     Container(height: 14, width: double.infinity, color: Colors.grey[300]),
//                     const SizedBox(height: 4),
//                     Container(height: 14, width: double.infinity, color: Colors.grey[300]),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:note_up/Providers/code_provider.dart';
import 'package:note_up/Providers/themeProvider.dart';
import 'package:note_up/classes/Code.dart';
import 'package:note_up/functionality/DSAHelper.dart';
import 'package:note_up/screens/sideBar.dart';

import 'HomeScreen.dart';

class CodeScreen extends StatefulWidget {
  final bool isDark;
  const CodeScreen({required this.isDark, super.key});

  @override
  State<CodeScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends State<CodeScreen> {
  final TextEditingController _searchCont = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late Future<bool> _loadFuture;
  bool _isLoading = false;
  bool toggleVal = false;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadCodes();
    _searchCont.addListener(() => setState(() {}));
    toggleVal = widget.isDark;
  }

  @override
  void dispose() {
    _searchCont.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<bool> _loadCodes() async {
    try {
      await context.read<CodeProvider>().loadCodes();
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading codes: $e')),
        );
      }
      return false;
    }
  }

  void _addCode() async {
    setState(() => _isLoading = true);
    try {
      final code = Code(content: '');
      final savedCode = await context.read<CodeProvider>().addCode(code: code);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GeminiCodePage(
              initialCode: savedCode,
              onSave: (content, analysis, title) async {
                await context.read<CodeProvider>().updateCode(
                  code: Code(
                    id: savedCode.id,
                    title: title,
                    content: content,
                    analysis: analysis,
                  ),
                );
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _deleteCode(Code code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Code'),
        content: const Text('Are you sure you want to delete this code snippet?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<CodeProvider>().deleteCode(codeId: code.id ?? 0);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Code deleted')),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Scaffold(
      backgroundColor: theme.backg,
      appBar: AppBar(
        backgroundColor: theme.backg,
        title: Text(
          "Code Snippets",
          style: GoogleFonts.montserrat(
            color: theme.textCol,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _loadFuture = _loadCodes();
              });
            },
            icon: const Icon(Icons.refresh),
            color: theme.buttonCol,
          ),
          IconButton(
            onPressed: () {
              setState(() {
                toggleVal = !toggleVal;
              });
              ThemeUtils.changeTheme(context, toggleVal);
            },
            icon: Icon(
              widget.isDark ? Icons.dark_mode : Icons.light_mode,
              size: 28,
            ),
            color: theme.buttonCol,
          ),
        ],
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu),
            color: theme.buttonCol,
          ),
        ),
      ),
      drawer: Sidebar(isDark: widget.isDark),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: Colors.indigo.shade400,
        overlayColor: Colors.black,
        overlayOpacity: 0.4,
        spacing: 12,
        spaceBetweenChildren: 12,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.code),
            label: 'New Code',
            backgroundColor: Colors.indigo.shade300,
            onTap: _isLoading ? null : _addCode,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchCont,
              style: GoogleFonts.roboto(
                color: theme.inputTextCol,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: "Search Code Snippets",
                hintStyle: TextStyle(color: theme.buttonCol.withOpacity(0.6)),
                prefixIcon: Icon(Icons.search, color: theme.buttonCol),
                suffixIcon: _searchCont.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  color: theme.buttonCol,
                  onPressed: () => setState(() => _searchCont.clear()),
                )
                    : null,
                filled: true,
                fillColor: theme.backg?.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<bool>(
                future: _loadFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildSkeletonLoader(theme);
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: theme.buttonCol),
                          const SizedBox(height: 8),
                          Text(
                            "Error loading code snippets",
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              color: theme.buttonCol,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final codes = context.watch<CodeProvider>().syncCodesFromScreen();
                  final filteredCodes = codes
                      .where((code) =>
                  (code.title?.toLowerCase().contains(_searchCont.text.toLowerCase()) ?? false) ||
                      code.content.toLowerCase().contains(_searchCont.text.toLowerCase()))
                      .toList();

                  if (filteredCodes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.code_off_outlined,
                            size: 48,
                            color: theme.buttonCol.withOpacity(0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "No code snippets found",
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              color: theme.buttonCol,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    controller: _scrollController,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisExtent: 200,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemCount: filteredCodes.length,
                    itemBuilder: (context, index) {
                      final code = filteredCodes[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GeminiCodePage(
                                  initialCode: code,
                                  onSave: (content, analysis, title) async {
                                    await context.read<CodeProvider>().updateCode(
                                      code: Code(
                                        id: code.id,
                                        title: title,
                                        content: content,
                                        analysis: analysis,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.indigo.shade700,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                ),
                                padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        code.title?.isNotEmpty ?? false
                                            ? code.title!
                                            : 'Untitled',
                                        style: GoogleFonts.openSans(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.white),
                                      onPressed: () => _deleteCode(code),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo.shade100,
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    code.analysis?.isEmpty ?? true
                                        ? 'No analysis yet'
                                        : code.analysis!,
                                    style: GoogleFonts.openSans(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: theme.textCol,
                                    ),
                                    maxLines: 6,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader(ThemeProvider theme) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 200,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: 4,
      itemBuilder: (context, index) => Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 16, width: 100, color: Colors.grey[300]),
                    const SizedBox(height: 8),
                    Container(height: 14, width: double.infinity, color: Colors.grey[300]),
                    const SizedBox(height: 4),
                    Container(height: 14, width: double.infinity, color: Colors.grey[300]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // void _deleteCode(Code code) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Delete Code'),
  //       content: const Text('Are you sure you want to delete this code snippet?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             context.read<CodeProvider>().deleteCode(codeId: code.id ?? 0);
  //             Navigator.pop(context);
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               const SnackBar(content: Text('Code deleted')),
  //             );
  //           },
  //           child: Text(
  //             'Delete',
  //             style: TextStyle(color: Theme.of(context).colorScheme.error),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}