// import 'package:flutter/material.dart';
// import 'package:flutter_speed_dial/flutter_speed_dial.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:note_up/Providers/notesProvider.dart';
// import 'package:note_up/classes/note_class.dart';
// import 'package:note_up/functionality/notes.dart';
// import 'package:note_up/screens/sideBar.dart';
// import 'package:provider/provider.dart';
// import 'package:note_up/screens/HomeScreen.dart';
// import '../Providers/themeProvider.dart';
// import '../functionality/AIIntegration.dart';
//
// class NoteScreens extends StatefulWidget {
//   bool isDark;
//   NoteScreens({required this.isDark, super.key});
//
//   @override
//   State<NoteScreens> createState() => _NoteScreensState();
// }
//
// class _NoteScreensState extends State<NoteScreens> {
//   bool toggleVal = false;
//   final TextEditingController _searchCont = TextEditingController();
//   late Future<bool> _loadFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     toggleVal = widget.isDark;
//     _loadFuture = loadNotes();
//   }
//
//
//
//   Future<bool> loadNotes() async {
//     context.read<NotesProvider>().loadNotes();
//     return true;
//   }
//
//   void addNote() async {
//     final note = Note(title: '', content: '');
//     final savedNote = await context.read<NotesProvider>().addNote(note: note);
//     if (mounted) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) =>
//               Notes(isDark: widget.isDark, contNote: savedNote),
//         ),
//       );
//     }
//   }
//
//   void addAiNote() async {
//     if (mounted) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => AIPlan()),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = context.watch<ThemeProvider>();
//     return WillPopScope(
//       onWillPop: () => loadNotes(),
//       child: Scaffold(
//         backgroundColor: theme.backg,
//         appBar: AppBar(
//           backgroundColor: theme.backg,
//           title: Text(
//             "Notes",
//             style: GoogleFonts.montserrat(
//               color: theme.textCol,
//               fontSize: 24,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           centerTitle: true,
//           elevation: 0.5,
//           actions: [
//             IconButton(
//               onPressed: () {
//                 setState(() {
//                   _loadFuture = loadNotes();
//                 });
//               },
//               icon: Icon(Icons.refresh_sharp),
//               color: theme.buttonCol,
//             ),
//             IconButton(
//               onPressed: () {
//                 setState(() {
//                   toggleVal = !toggleVal;
//                 });
//                 ThemeUtils.changeTheme(context, toggleVal);
//               },
//               icon: Icon(toggleVal
//                   ? Icons.toggle_on_outlined
//                   : Icons.toggle_off_outlined),
//               iconSize: 36,
//               color: theme.buttonCol,
//             ),
//           ],
//           leading: Builder(
//             builder: (context) => IconButton(
//               onPressed: () {
//                 Scaffold.of(context).openDrawer();
//               },
//               icon: Icon(Icons.list),
//               color: theme.buttonCol,
//             ),
//           ),
//         ),
//         drawer: Sidebar(isDark: widget.isDark),
//         floatingActionButton: SpeedDial(
//           animatedIcon: AnimatedIcons.menu_close,
//           backgroundColor: Colors.tealAccent.shade100,
//           spacing: 10,
//           spaceBetweenChildren: 8,
//           childrenButtonSize: Size(56.0, 56.0),
//           overlayColor: Colors.black,
//           overlayOpacity: 0.4,
//           children: [
//             SpeedDialChild(
//               child: Icon(Icons.note_add),
//               label: 'Note',
//               onTap: () {
//                 // Call your addNote function or navigation
//                 addNote();
//               },
//             ),
//             SpeedDialChild(
//               child: Icon(Icons.smart_toy),
//               label: 'AI Note',
//               onTap: () {
//                 // Handle AI note action
//                 addAiNote();
//               },
//             ),
//           ],
//         ),
//         body: Padding(
//           padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
//           child: Column(
//             children: [
//               // Optional Search Bar
//               TextField(
//                 controller: _searchCont,
//                 style: GoogleFonts.roboto(
//                   color: theme.inputTextCol,
//                   fontSize: 16,
//                 ),
//                 decoration: InputDecoration(
//
//                   hintText: "Search Notes",
//                   hintStyle: TextStyle(color: theme.buttonCol),
//                   prefixIcon: Icon(Icons.search, color: theme.buttonCol,),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//
//                 ),
//                 onChanged: (value) {
//                   setState(() {});
//                 },
//               ),
//               SizedBox(height: 10),
//               Expanded(
//                 child: FutureBuilder<bool>(
//                   future: _loadFuture,
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Center(child: CircularProgressIndicator());
//                     }
//
//                     List<Note> notes =
//                     context.watch<NotesProvider>().syncNotesFromScreen();
//
//                     // Apply search filter
//                     final filteredNotes = notes
//                         .where((note) => note.title
//                         .toLowerCase()
//                         .contains(_searchCont.text.toLowerCase()))
//                         .toList();
//
//                     if (filteredNotes.isEmpty) {
//                       return Center(
//                         child: Text(
//                           "No notes found",
//                           style: TextStyle(fontSize: 18, color: theme.buttonCol),
//                         ),
//                       );
//                     }
//
//                     return GridView.builder(
//                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         mainAxisExtent: 250,
//                         mainAxisSpacing: 10,
//                         crossAxisSpacing: 10,
//                       ),
//                       itemCount: filteredNotes.length,
//                       itemBuilder: (context, index) {
//                         final note = filteredNotes[index];
//                         return Column(
//                           children: [
//                             Container(
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(12),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black12,
//                                     blurRadius: 4,
//                                     offset: Offset(2, 2),
//                                   ),
//                                 ],
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Container(
//                                     decoration: BoxDecoration(
//                                       color: Colors.teal.shade800,
//                                       borderRadius: BorderRadius.only(
//                                         topLeft: Radius.circular(12),
//                                         topRight: Radius.circular(12),
//                                       ),
//                                     ),
//                                     padding: EdgeInsets.symmetric(vertical: 8),
//                                     child: Row(
//                                       children: [
//                                         Center(
//                                           child: Text(
//                                             note.title,
//                                             style: GoogleFonts.openSans(
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 18,
//                                               color: Colors.white,
//                                             ),
//                                           ),
//                                         ),
//                                         IconButton(onPressed: (){}, icon: Icon(Icons.delete))
//                                       ],
//                                     ),
//                                   ),
//                                   GestureDetector(
//                                     onTap: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) => Notes(
//                                             isDark: widget.isDark,
//                                             contNote: note,
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                     child: Expanded(
//                                       child: Container(
//                                         width: double.infinity,
//                                         padding: EdgeInsets.all(8),
//                                         decoration: BoxDecoration(
//                                           color: Colors.teal.shade400,
//                                           borderRadius: BorderRadius.only(
//                                             bottomLeft: Radius.circular(12),
//                                             bottomRight: Radius.circular(12),
//                                           ),
//                                         ),
//                                         child: Text(
//                                           note.content,
//                                           style: GoogleFonts.openSans(
//                                             fontWeight: FontWeight.w600,
//                                             fontSize: 14,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   )
//                                 ],
//                               ),
//                             ),
//                           ],
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:note_up/Providers/notesProvider.dart';
import 'package:note_up/Providers/themeProvider.dart';
import 'package:note_up/classes/note_class.dart';
import 'package:note_up/functionality/notes.dart';
import 'package:note_up/screens/sideBar.dart';
import 'package:note_up/functionality/AIIntegration.dart';

import 'HomeScreen.dart';

class NoteScreens extends StatefulWidget {
  final bool isDark;
  const NoteScreens({required this.isDark, super.key});

  @override
  State<NoteScreens> createState() => _NoteScreensState();
}

class _NoteScreensState extends State<NoteScreens> {
  final TextEditingController _searchCont = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late Future<bool> _loadFuture;
  bool _isLoading = false;
  bool toggleVal = false;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadNotes();
    _searchCont.addListener(() => setState(() {}));
    toggleVal = widget.isDark;
  }

  @override
  void dispose() {
    _searchCont.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<bool> _loadNotes() async {
    try {
      context.read<NotesProvider>().loadNotes();
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading notes: $e')),
        );
      }
      return false;
    }
  }

  void addNote() async {
    setState(() => _isLoading = true);
    try {
      final note = Note(title: '', content: '');
      final savedNote = await context.read<NotesProvider>().addNote(note: note);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Notes(isDark: widget.isDark, contNote: savedNote),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addAiNote() {
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AIPlan()),
      );
    }
  }

  void _deleteNote(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<NotesProvider>().deleteNote( noteId: note.id ?? 0);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note deleted')),
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
          "Notes",
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
                _loadFuture = _loadNotes();
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
        backgroundColor: Colors.teal.shade400,
        overlayColor: Colors.black,
        overlayOpacity: 0.4,
        spacing: 12,
        spaceBetweenChildren: 12,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.note_add),
            label: 'New Note',
            backgroundColor: Colors.teal.shade300,
            onTap: _isLoading ? null : addNote,
          ),
          SpeedDialChild(
            child: const Icon(Icons.smart_toy),
            label: 'AI Note',
            backgroundColor: Colors.teal.shade300,
            onTap: _isLoading ? null : _addAiNote,
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
                hintText: "Search Notes",
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
                            "Error loading notes",
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              color: theme.buttonCol,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final notes = context.watch<NotesProvider>().syncNotesFromScreen();
                  final filteredNotes = notes
                      .where((note) => note.title
                      .toLowerCase()
                      .contains(_searchCont.text.toLowerCase()))
                      .toList();

                  if (filteredNotes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.note_add_outlined,
                            size: 48,
                            color: theme.buttonCol.withOpacity(0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "No notes found",
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
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
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
                                builder: (context) => Notes(
                                  isDark: widget.isDark,
                                  contNote: note,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade700,
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
                                        note.title.isEmpty ? 'Untitled' : note.title,
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
                                      onPressed: () => _deleteNote(note),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade100,
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    note.content.isEmpty ? 'No content' : note.content,
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
}