
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_up/classes/image_class.dart';
import 'package:note_up/dbs/image_db_helper.dart';
import 'package:note_up/screens/sideBar.dart';
import 'package:note_up/tools/noteTools.dart';
import 'package:provider/provider.dart';

import '../Providers/notesProvider.dart';
import '../Providers/themeProvider.dart';
import '../classes/note_class.dart';
import '../screens/HomeScreen.dart';

class Notes extends StatefulWidget {
  Note contNote;
  bool isDark;
  Notes({required this.isDark, required this.contNote, super.key});

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> with WidgetsBindingObserver {
  String selectedColor = "White";
  String hintTextTitle = "Title";
  bool hintTitleColor = false;
  TextEditingController noteText = TextEditingController();
  TextEditingController titleText = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<String> _images = [];
  bool toggleVal = false;
  double _keyboardHeight = 0;

  @override
  void initState() {
    noteText.text = widget.contNote.content;
    titleText.text = widget.contNote.title;
    toggleVal = widget.isDark;
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if(widget.contNote.imgKey != null){
     loadImagesFromDb(widget.contNote.imgKey!);
    }
    noteText.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      });
    });
  }


  void loadImagesFromDb(int id) async {
    ImageClass? imageData = await ImageDbHelper.instance.readImage(id);

    if (imageData != null) {
      List<String> images = [];

      if (imageData.imageOne != null && imageData.imageOne!.isNotEmpty) {
        images.add(imageData.imageOne!);
      }
      if (imageData.imageTwo != null && imageData.imageTwo!.isNotEmpty) {
        images.add(imageData.imageTwo!);
      }
      if (imageData.imageThree != null && imageData.imageThree!.isNotEmpty) {
        images.add(imageData.imageThree!);
      }

      setState(() {
        _images = images;
      });
    }
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    noteText.dispose();
    _scrollController.dispose();
    titleText.dispose();
    super.dispose();
  }

  void updateNote() async {
    if(titleText.text.isEmpty || noteText.text.isEmpty){
      if(titleText.text.isEmpty && noteText.text.isNotEmpty){
        final note = Note(
          id: widget.contNote.id,
          title: "Default Title",
          content: noteText.text.trim(),
        );
        context.read<NotesProvider>().updateNote(note: note);
      }else if(titleText.text.isEmpty && noteText.text.isEmpty){
        context.read<NotesProvider>().deleteNote(noteId: widget.contNote.id ?? 10000);
      }
    }else{
      final note = Note(
        id: widget.contNote.id,
        title: titleText.text.trim(),
        content: noteText.text.trim(),
      );
      context.read<NotesProvider>().updateNote(note: note);
    }
  }

  Future<bool> _onWillPop() async {
    updateNote();
    return true;
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    setState(() {
      _keyboardHeight = bottomInset;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = toggleVal;
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: themeProvider.backg,
        appBar: AppBar(
          backgroundColor: themeProvider.backg,
          title: Text(
            "Notes",
            style: GoogleFonts.montserrat(
              color: themeProvider.textCol,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: Icon(Icons.list),
              color: themeProvider.buttonCol,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() => toggleVal = !toggleVal);
                ThemeUtils.changeTheme(context, toggleVal);
              },
              icon: Icon(
                toggleVal ? Icons.dark_mode : Icons.light_mode,
                size: 28,
              ),
              color: themeProvider.buttonCol,
            ),
          ],
        ),
        drawer: Sidebar(isDark: widget.isDark),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              // Tool Buttons Bar
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    makeToolButton(Icons.copy, () => NoteTools().copyFunction(context, controller: noteText)),
                    makeToolButton(Icons.paste, () => NoteTools().pasteFunction(context, controller: noteText)),
                    makeToolButton(Icons.picture_as_pdf, () {}),
                    makeToolButton(Icons.highlight, () {}),
                    makeToolButton(Icons.format_list_bulleted, () {}),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // Title Field
              TextField(
                controller: titleText,
                style: GoogleFonts.openSans(
                  color: themeProvider.inputTextCol,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: "Title",
                  hintStyle: TextStyle(color: themeProvider.inputTextCol.withOpacity(0.6)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: themeProvider.backg,
                ),
              ),
              SizedBox(height: 12),
              // Notes Field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: themeProvider.backg,
                    border: Border.all(color: themeProvider.buttonCol.withOpacity(0.4)),
                  ),
                  child: TextField(
                    controller: noteText,
                    scrollController: _scrollController,
                    style: GoogleFonts.roboto(
                      color: themeProvider.inputTextCol,
                      fontSize: 16,
                    ),
                    expands: true,
                    maxLines: null,
                    minLines: null,
                    keyboardType: TextInputType.multiline,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText: "Start typing your notes...",
                      hintStyle: TextStyle(
                        color: themeProvider.inputTextCol.withOpacity(0.5),
                      ),
                      contentPadding: EdgeInsets.all(12),
                      border: InputBorder.none,
                    ),
                  ),
                ),

              ),
              Expanded(child: ListView(
                children: [
                  if (_images.isNotEmpty) ...[
                    _buildImageGallery(theme),
                  ],
                ],
              )),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Related Images',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: _images.length,
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: _images[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: theme.colorScheme.surfaceVariant,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: theme.colorScheme.errorContainer,
                  child: const Icon(Icons.error),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget makeToolButton(IconData icon, VoidCallback func) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.watch<ThemeProvider>().buttonCol.withOpacity(0.1),
      ),
      child: IconButton(
        onPressed: func,
        icon: Icon(icon, size: 22),
        color: context.watch<ThemeProvider>().buttonCol,
        tooltip: icon.toString(),
      ),
    );
  }
}