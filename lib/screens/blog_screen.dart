import 'package:flutter/material.dart';

class BlogPost {
  final String title;
  final String summary;
  final String content;
  final String imageUrl;
  final String category;

  BlogPost({required this.title, required this.summary, required this.content, required this.imageUrl, required this.category});
}

class BlogScreen extends StatelessWidget {
  final List<BlogPost> posts = [
    BlogPost(
      title: "Cách huấn luyện chó đi vệ sinh đúng chỗ",
      summary: "Những mẹo đơn giản và hiệu quả nhất để chó cưng của bạn đi vệ sinh đúng chỗ.",
      content: "Bắt đầu huấn luyện ngay từ khi chó còn nhỏ. Tạo một khu vực vệ sinh riêng biệt. Khen thưởng ngay lập tức khi chó làm đúng. Hãy kiên nhẫn và duy trì thói quen hàng ngày...",
      imageUrl: "https://images.unsplash.com/photo-1544568100-847a948585b9",
      category: "Huấn luyện",
    ),
    BlogPost(
      title: "Dinh dưỡng chuẩn cho mèo con",
      summary: "Hướng dẫn chọn thức ăn và bổ sung dinh dưỡng để mèo con phát triển khỏe mạnh.",
      content: "Mèo con cần thức ăn giàu protein và chất béo. Hãy chia nhỏ bữa ăn thành 4-5 lần/ngày. Đừng quên cung cấp đủ nước sạch và tránh cho mèo uống sữa bò vì dễ gây tiêu chảy...",
      imageUrl: "https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba",
      category: "Dinh dưỡng",
    ),
    BlogPost(
      title: "Làm gì khi thú cưng bị ốm?",
      summary: "Dấu hiệu nhận biết thú cưng đang không khỏe và các bước sơ cứu cơ bản.",
      content: "Dấu hiệu phổ biến: bỏ ăn, lờ đờ, nôn mửa hoặc thay đổi thói quen vệ sinh. Đừng tự ý cho thú cưng uống thuốc của người. Hãy đo nhiệt độ và liên hệ bác sĩ thú y ngay...",
      imageUrl: "https://images.unsplash.com/photo-1583337130417-3346a1be7dee",
      category: "Sức khỏe",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("Góc chia sẻ kinh nghiệm", style: TextStyle(color: Colors.teal)),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            margin: EdgeInsets.only(bottom: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 4,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlogPostDetailScreen(post: post),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    post.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: Colors.grey.shade300,
                      child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            post.category,
                            style: TextStyle(color: Colors.teal, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          post.title,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          post.summary,
                          style: TextStyle(color: Colors.grey.shade600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
  }
}

class BlogPostDetailScreen extends StatelessWidget {
  final BlogPost post;

  const BlogPostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(post.category),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              post.imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 250,
                color: Colors.grey.shade300,
                child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal.shade900),
                  ),
                  SizedBox(height: 20),
                  Text(
                    post.content,
                    style: TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
