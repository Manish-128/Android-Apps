// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:note_up/classes/watchlist_class.dart';
//
// class WatchHistory extends StatefulWidget {
//   bool isDark;
//   WatchListClass contWatch;
//   WatchHistory({required this.isDark, required this.contWatch, super.key});
//
//   @override
//   State<WatchHistory> createState() => _WatchHistoryState();
// }
//
// class _WatchHistoryState extends State<WatchHistory> {
//   final _movieController = TextEditingController();
//   final _yearController = TextEditingController();
//
//   String? _posterUrl;
//   String? _error;
//   bool _loading = false;
//
//   // 🔑 Replace with your own key from https://www.omdbapi.com/apikey.aspx
//   final String apiKey = 'd72d505b';
//
//   Future<void> _fetchPoster(String title, String year) async {
//     setState(() {
//       _posterUrl = null;
//       _error = null;
//       _loading = true;
//     });
//
//     final query = Uri.parse(
//         'https://www.omdbapi.com/?t=${Uri.encodeComponent(title)}&y=$year&apikey=$apiKey');
//
//     try {
//       final response = await http.get(query);
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//
//         if (data['Response'] == 'True') {
//           setState(() => _posterUrl = data['Poster']);
//         } else {
//           setState(() => _error = data['Error'] ?? 'Movie not found.');
//         }
//       } else {
//         setState(() => _error = 'HTTP error ${response.statusCode}');
//       }
//     } catch (e) {
//       setState(() => _error = 'Failed: $e');
//     }
//
//     setState(() => _loading = false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Movie Poster Finder (OMDb API)")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(children: [
//           TextField(
//             controller: _movieController,
//             decoration: InputDecoration(labelText: "Movie Name"),
//           ),
//           TextField(
//             controller: _yearController,
//             decoration: InputDecoration(labelText: "Release Year"),
//             keyboardType: TextInputType.number,
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () {
//               final title = _movieController.text.trim();
//               final year = _yearController.text.trim();
//               if (title.isNotEmpty && year.isNotEmpty) {
//                 _fetchPoster(title, year);
//               }
//             },
//             child: Text("Get Poster"),
//           ),
//           const SizedBox(height: 20),
//           if (_loading) CircularProgressIndicator(),
//           if (_error != null)
//             Text(_error!, style: TextStyle(color: Colors.red)),
//           if (_posterUrl != null)
//             Image.network(_posterUrl!, height: 400),
//         ]),
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:note_up/classes/watchlist_class.dart';
import 'package:path_provider/path_provider.dart';

import '../dbs/watchlist_db_helper.dart';

class WatchHistory extends StatefulWidget {
  final bool isDark;
  final WatchListClass contWatch;

  const WatchHistory({required this.isDark, required this.contWatch, super.key});

  @override
  State<WatchHistory> createState() => _WatchHistoryState();
}

class _WatchHistoryState extends State<WatchHistory> {
  final _movieController = TextEditingController();
  final _yearController = TextEditingController();

  String? _posterUrl;
  String? _error;
  bool _loading = false;
  bool _saved = false;

  final String apiKey = 'd72d505b';

  Future<void> _fetchPoster(String title, String year) async {
    setState(() {
      _posterUrl = null;
      _error = null;
      _loading = true;
      _saved = false;
    });

    final query = Uri.parse(
        'https://www.omdbapi.com/?t=${Uri.encodeComponent(title)}&y=$year&apikey=$apiKey');

    try {
      final response = await http.get(query);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['Response'] == 'True') {
          setState(() => _posterUrl = data['Poster']);
        } else {
          setState(() => _error = data['Error'] ?? 'Movie not found.');
        }
      } else {
        setState(() => _error = 'HTTP error ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _error = 'Failed: $e');
    }

    setState(() => _loading = false);
  }

  Future<String> _saveImageLocally(String url, String filename) async {
    final response = await http.get(Uri.parse(url));
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename.jpg');
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }

  Future<void> _saveToWatchlist() async {
    if (_posterUrl == null) return;

    final title = _movieController.text.trim();
    final year = int.tryParse(_yearController.text.trim());

    if (title.isEmpty || year == null) return;

    try {
      final localPath = await _saveImageLocally(_posterUrl!, title.replaceAll(' ', '_'));
      final newItem = WatchListClass(id: widget.contWatch.id, title: title, year: year, image: localPath);

      await WatchListDbHelper.instance.updateWatchlist(newItem);

      setState(() {
        _saved = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to watchlist!')),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error = 'Error saving movie: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Movie Poster Finder")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(children: [
            TextField(
              controller: _movieController,
              decoration: const InputDecoration(labelText: "Movie Name"),
            ),
            TextField(
              controller: _yearController,
              decoration: const InputDecoration(labelText: "Release Year"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final title = _movieController.text.trim();
                final year = _yearController.text.trim();
                if (title.isNotEmpty && year.isNotEmpty) {
                  _fetchPoster(title, year);
                }
              },
              child: const Text("Get Poster"),
            ),
            const SizedBox(height: 20),
            if (_loading) const CircularProgressIndicator(),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_posterUrl != null) ...[
              Image.network(_posterUrl!, height: 400),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _saveToWatchlist,
                icon: const Icon(Icons.save),
                label: const Text("Save to Watchlist"),
              ),
              if (_saved)
                const Text("Saved!", style: TextStyle(color: Colors.green)),
            ],
          ]),
        ),
      ),
    );
  }
}
