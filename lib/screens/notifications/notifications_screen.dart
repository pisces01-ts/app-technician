import 'package:flutter/material.dart';
import '../../config/theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 1,
      'title': 'งานใหม่เข้ามา!',
      'message': 'มีลูกค้าแจ้งซ่อมใกล้คุณ 2.5 กม.',
      'time': '2 นาทีที่แล้ว',
      'type': 'new_job',
      'read': false,
    },
    {
      'id': 2,
      'title': 'ได้รับรีวิว 5 ดาว',
      'message': 'คุณได้รับรีวิว 5 ดาวจากลูกค้า "สมศรี"',
      'time': '30 นาทีที่แล้ว',
      'type': 'review',
      'read': false,
    },
    {
      'id': 3,
      'title': 'ยอดเงินเข้า',
      'message': 'คุณได้รับเงิน ฿850 จากงาน #00123',
      'time': '2 ชั่วโมงที่แล้ว',
      'type': 'payment',
      'read': true,
    },
  ];

  IconData _getIcon(String type) {
    switch (type) {
      case 'new_job': return Icons.work;
      case 'review': return Icons.star;
      case 'payment': return Icons.account_balance_wallet;
      default: return Icons.notifications;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'new_job': return AppTheme.primaryColor;
      case 'review': return AppTheme.warningColor;
      case 'payment': return AppTheme.statusCompleted;
      default: return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('การแจ้งเตือน'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (var n in _notifications) {
                  n['read'] = true;
                }
              });
            },
            child: const Text('อ่านทั้งหมด'),
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 80, color: AppTheme.textMuted),
                  const SizedBox(height: 16),
                  Text('ไม่มีการแจ้งเตือน', style: TextStyle(color: AppTheme.textMuted, fontSize: 16)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final notif = _notifications[index];
                return Container(
                  decoration: BoxDecoration(
                    color: notif['read'] ? Colors.white : AppTheme.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: notif['read'] ? AppTheme.dividerColor : AppTheme.primaryColor.withOpacity(0.2),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getIconColor(notif['type']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_getIcon(notif['type']), color: _getIconColor(notif['type'])),
                    ),
                    title: Text(
                      notif['title'],
                      style: TextStyle(
                        fontWeight: notif['read'] ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(notif['message'], style: TextStyle(color: AppTheme.textSecondary)),
                        const SizedBox(height: 4),
                        Text(notif['time'], style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                      ],
                    ),
                    trailing: !notif['read']
                        ? Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        notif['read'] = true;
                      });
                    },
                  ),
                );
              },
            ),
    );
  }
}
