import 'package:http/http.dart' as http;
import 'package:webfeed_revised/webfeed_revised.dart';
import '../models/news_article.dart';

class RssService {
  static Future<List<NewsArticle>> fetchNews() async {
    final response = await http.get(
      Uri.parse('https://vnexpress.net/rss/tin-moi-nhat.rss'),
    );

    final feed = RssFeed.parse(response.body);
    final items = feed.items ?? [];
    List<NewsArticle> news = [];
    for (var item in items) {
      final description = item.description ?? '';
      // LẤY ẢNH
      String image = '';
      final regex = RegExp(r'<img[^>]+src="([^">]+)"', caseSensitive: false);
      final match = regex.firstMatch(description);

      if (match != null) {
        image = match.group(1) ?? '';
      }

      news.add(
        NewsArticle(
          title: item.title ?? '',

          image: image,

          link: item.link ?? '',
        ),
      );
    }
    return news;
  }
}
