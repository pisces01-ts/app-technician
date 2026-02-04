import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../chat/chat_screen.dart';

class JobDetailScreen extends StatelessWidget {
  final Map<String, dynamic> job;

  const JobDetailScreen({super.key, required this.job});

  Future<void> _openMaps() async {
    final lat = job['location_lat'];
    final lng = job['location_lng'];
    if (lat == null || lng == null) return;

    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _makeCall(String phone) async {
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerName = job['customer_name'] ?? 'ลูกค้า';
    final customerPhone = job['customer_phone'] ?? '';
    final problemType = job['problem_type'] ?? '';
    final problemDetails = job['problem_details'] ?? '';
    final locationAddress = job['location_address'] ?? 'ไม่ระบุที่อยู่';
    final status = job['status'] ?? 'pending';
    final requestId = job['request_id'] ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('รายละเอียดงาน')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                          child: const Icon(Icons.person, size: 30, color: AppTheme.primaryColor),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(customerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(customerPhone, style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: customerPhone.isNotEmpty ? () => _makeCall(customerPhone) : null,
                            icon: const Icon(Icons.phone),
                            label: const Text('โทร'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ChatScreen(requestId: requestId, customerName: customerName)),
                            ),
                            icon: const Icon(Icons.chat),
                            label: const Text('แชท'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Problem Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ปัญหา', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(problemType, style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                    ),
                    if (problemDetails.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(problemDetails, style: TextStyle(color: Colors.grey[700])),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Location
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('สถานที่', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(child: Text(locationAddress)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _openMaps,
                        icon: const Icon(Icons.navigation),
                        label: const Text('นำทางด้วย Google Maps'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text('สถานะ: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(_getStatusText(status), style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'accepted': return Colors.blue;
      case 'traveling': return Colors.purple;
      case 'arrived': return Colors.teal;
      case 'working': return Colors.indigo;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending': return 'รอดำเนินการ';
      case 'accepted': return 'รับงานแล้ว';
      case 'traveling': return 'กำลังเดินทาง';
      case 'arrived': return 'ถึงแล้ว';
      case 'working': return 'กำลังซ่อม';
      case 'completed': return 'เสร็จสิ้น';
      case 'cancelled': return 'ยกเลิก';
      default: return status;
    }
  }
}
