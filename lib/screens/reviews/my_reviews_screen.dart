import 'package:flutter/material.dart';
import '../../config/theme.dart';

class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reviews = [
      {
        'customer': 'คุณสมศรี',
        'rating': 5,
        'comment': 'ช่างมาเร็วมาก ซ่อมเสร็จไว ราคาเป็นธรรม ประทับใจครับ',
        'date': '2 ชั่วโมงที่แล้ว',
        'jobType': 'เปลี่ยนยาง',
      },
      {
        'customer': 'คุณสมชาย',
        'rating': 4,
        'comment': 'บริการดี แต่มาช้านิดหน่อย',
        'date': 'เมื่อวาน',
        'jobType': 'แบตหมด',
      },
      {
        'customer': 'คุณมานี',
        'rating': 5,
        'comment': 'ช่างใจดีมาก ช่วยอธิบายปัญหาให้ฟังด้วย',
        'date': '3 วันที่แล้ว',
        'jobType': 'เครื่องร้อน',
      },
    ];

    // Calculate stats
    final totalReviews = reviews.length;
    final avgRating = reviews.fold<double>(0, (sum, r) => sum + (r['rating'] as int)) / totalReviews;
    final fiveStarCount = reviews.where((r) => r['rating'] == 5).length;

    return Scaffold(
      appBar: AppBar(title: const Text('รีวิวของฉัน')),
      body: Column(
        children: [
          // Stats Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        avgRating.toStringAsFixed(1),
                        style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (i) => Icon(
                          i < avgRating.round() ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        )),
                      ),
                      const SizedBox(height: 4),
                      Text('$totalReviews รีวิว', style: TextStyle(color: Colors.white.withOpacity(0.8))),
                    ],
                  ),
                ),
                Container(width: 1, height: 80, color: Colors.white.withOpacity(0.3)),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text('5 ดาว', style: TextStyle(color: Colors.white.withOpacity(0.8))),
                        ],
                      ),
                      Text(
                        '$fiveStarCount',
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      Text('รีวิว', style: TextStyle(color: Colors.white.withOpacity(0.8))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Reviews List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: reviews.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                child: Text(
                                  (review['customer'] as String).substring(3, 4),
                                  style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(review['customer'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  Text(review['jobType'] as String, style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                          Text(review['date'] as String, style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(5, (i) => Icon(
                          i < (review['rating'] as int) ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 18,
                        )),
                      ),
                      const SizedBox(height: 8),
                      Text(review['comment'] as String, style: TextStyle(color: AppTheme.textSecondary)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
