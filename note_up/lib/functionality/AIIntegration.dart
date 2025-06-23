import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:note_up/classes/image_class.dart';
import 'package:note_up/classes/note_class.dart';
import 'package:note_up/dbs/image_db_helper.dart';
import 'package:note_up/dbs/note_db_helper.dart';
import 'package:note_up/service/gemini.dart';
import '../Providers/notesProvider.dart';
import '../service/imageScrapper.dart';

class AIPlan extends StatefulWidget {
  const AIPlan({super.key});

  @override
  State<AIPlan> createState() => _AIPlanState();
}

class _AIPlanState extends State<AIPlan> {
  final GeminiService _gemini = GeminiService();
  final ImageScraper _scraper = ImageScraper();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _response = '';
  List<String> _images = [];
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void updateDetails() async{
    ImageClass img = ImageClass();
    int? ImgId;

    if(_images.length >= 3){
      img = ImageClass(imageOne: _images[0], imageTwo: _images[1], imageThree: _images[2]);
      ImgId = await ImageDbHelper.instance.createImage(img);
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to Save Images'),
          duration: Duration(seconds: 2), // Optional
        ),
      );
    }

    if(_response != "" && _controller.text.isNotEmpty && ImgId != null){
      Note note = Note(title: _controller.text.trim(), content: _response, imgKey: ImgId);
      context.read<NotesProvider>().addNote(note: note);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note Saved with Images'),
          duration: Duration(seconds: 2), // Optional
        ),
      );
    }
    else if(_response != "" && _controller.text.isNotEmpty){
      Note note = Note(title: _controller.text.trim(), content: _response);
      context.read<NotesProvider>().addNote(note: note);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note Saved'),
          duration: Duration(seconds: 2), // Optional
        ),
      );
    }else{
      print(_response);
      print(_controller.text.trim());
      print(_images.length);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save Note'),
          duration: Duration(seconds: 2), // Optional
        ),
      );
    }

  }
  Future<bool> _WillPop() async {
    updateDetails();
    return true;
  }

  void _scrape() async {
    try {
      final query = _controller.text.trim();
      final urls = await _scraper.scrapeImages("https://www.bing.com/images/search?q=$query");
      setState(() => _images = urls);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load images'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _scrape,
          ),
        ),
      );
    }
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _loading = true;
      _response = '';
      _images = [];
    });

    try {
      final result = await _gemini.sendMessage(_controller.text);
      setState(() => _response = result);
      _scrape();
      // _controller.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _sendMessage,
          ),
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: _WillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AI Assistant'),
          elevation: 0,
          backgroundColor: theme.scaffoldBackgroundColor,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  if (_response.isNotEmpty) ...[
                    _buildResponseCard(theme),
                    const SizedBox(height: 16),
                  ],
                  if (_loading) ...[
                    _buildSkeletonLoader(),
                  ],
                  if (_images.isNotEmpty) ...[
                    _buildImageGallery(theme),
                  ],
                ],
              ),
            ),
            _buildInputArea(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Response',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _response,
              style: theme.textTheme.bodyMedium,
            ),
          ],
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

  Widget _buildInputArea(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Ask anything...',
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                // // suffixIcon: _controller.text.isNotEmpty
                // //     ? IconButton(
                // //   icon: const Icon(Icons.clear),
                // //   onPressed: () => _controller.clear(),
                // // )
                //     : null,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _loading ? null : _sendMessage,
            mini: true,
            child: _loading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 20,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 16,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              height: 16,
              color: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }
}