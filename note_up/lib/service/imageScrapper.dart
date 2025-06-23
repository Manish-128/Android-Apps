import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';

class ImageScraper {
  Future<List<String>> scrapeImages(String url) async {
    final uri = Uri.parse(url);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      final List<Element> imgTags = document.getElementsByTagName('img');

      List<String> imageUrls = [];

      for (var img in imgTags) {
        final src = img.attributes['src'];
        if (src != null && (src.startsWith('http') || src.startsWith('//'))) {
          final fullUrl = src.startsWith('//') ? 'https:$src' : src;
          imageUrls.add(fullUrl);
        }
      }

      return imageUrls;
    } else {
      throw Exception('Failed to load page');
    }
  }
}
