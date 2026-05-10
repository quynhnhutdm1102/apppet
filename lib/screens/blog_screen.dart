import 'package:flutter/material.dart';

import '../models/news_article.dart';
import '../services/rss_service.dart';
import 'article_webview_screen.dart';

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  late Future<List<NewsArticle>> futureNews;

  @override
  void initState() {
    super.initState();

    futureNews = RssService.fetchNews();
  }

  Future<void> refreshNews() async {
    setState(() {
      futureNews = RssService.fetchNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,

        title: const Text(
          "Tin tức thú cưng",
          style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
        ),
      ),

      body: FutureBuilder<List<NewsArticle>>(
        future: futureNews,

        builder: (context, snapshot) {
          // LOADING

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ERROR

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 70,
                      color: Colors.grey.shade400,
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "Không thể tải dữ liệu",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,

                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            );
          }

          final articles = snapshot.data ?? [];

          // EMPTY

          if (articles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Icon(Icons.newspaper, size: 70, color: Colors.grey.shade400),

                  const SizedBox(height: 14),

                  const Text(
                    "Không có tin tức",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          // LIST

          return RefreshIndicator(
            color: Colors.teal,

            onRefresh: refreshNews,

            child: ListView.builder(
              padding: const EdgeInsets.all(16),

              itemCount: articles.length,

              itemBuilder: (context, index) {
                final article = articles[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ArticleWebViewScreen(
                          url: article.link,
                          title: article.title,
                        ),
                      ),
                    );
                  },

                  child: Container(
                    margin: const EdgeInsets.only(bottom: 18),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(24),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        // IMAGE
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),

                          child: article.image.isNotEmpty
                              ? Image.network(
                                  article.image,

                                  width: double.infinity,
                                  height: 210,

                                  fit: BoxFit.cover,

                                  errorBuilder: (_, __, ___) {
                                    return Container(
                                      height: 210,
                                      color: Colors.grey.shade300,

                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  height: 210,
                                  color: Colors.grey.shade300,

                                  child: const Center(
                                    child: Icon(Icons.image, size: 50),
                                  ),
                                ),
                        ),

                        // CONTENT
                        Padding(
                          padding: const EdgeInsets.all(18),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),

                                decoration: BoxDecoration(
                                  color: Colors.teal.withOpacity(0.1),

                                  borderRadius: BorderRadius.circular(20),
                                ),

                                child: const Text(
                                  "TIN TỨC",
                                  style: TextStyle(
                                    color: Colors.teal,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              Text(
                                article.title,

                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,

                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: 14),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.menu_book_rounded,
                                    color: Colors.teal,
                                    size: 20,
                                  ),

                                  const SizedBox(width: 8),

                                  Text(
                                    "Nhấn để đọc bài báo",
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
