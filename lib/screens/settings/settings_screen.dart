import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../reviews/my_reviews_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isOnline = true;
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ตั้งค่า')),
      body: ListView(
        children: [
          // Online Status
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isOnline 
                    ? [AppTheme.primaryColor, AppTheme.primaryDark]
                    : [Colors.grey, Colors.grey.shade700],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _isOnline ? Icons.wifi : Icons.wifi_off,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isOnline ? 'กำลังออนไลน์' : 'ออฟไลน์',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _isOnline ? 'พร้อมรับงานใหม่' : 'ไม่รับงานชั่วคราว',
                        style: TextStyle(color: Colors.white.withOpacity(0.8)),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isOnline,
                  onChanged: (v) => setState(() => _isOnline = v),
                  activeColor: Colors.white,
                  activeTrackColor: Colors.white.withOpacity(0.5),
                ),
              ],
            ),
          ),

          // Account Section
          _buildSectionHeader('บัญชี'),
          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'แก้ไขโปรไฟล์',
            subtitle: 'ชื่อ, เบอร์โทร, ข้อมูลรถ',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.lock_outline,
            title: 'เปลี่ยนรหัสผ่าน',
            onTap: () => _showChangePasswordDialog(),
          ),
          _buildMenuItem(
            icon: Icons.star_outline,
            title: 'รีวิวของฉัน',
            subtitle: 'ดูรีวิวจากลูกค้า',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyReviewsScreen())),
          ),

          // Notifications Section
          _buildSectionHeader('การแจ้งเตือน'),
          SwitchListTile(
            secondary: _buildIcon(Icons.notifications_outlined, AppTheme.primaryColor),
            title: const Text('การแจ้งเตือน'),
            subtitle: const Text('รับแจ้งเตือนงานใหม่'),
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
          ),
          SwitchListTile(
            secondary: _buildIcon(Icons.volume_up_outlined, AppTheme.secondaryColor),
            title: const Text('เสียงแจ้งเตือน'),
            value: _soundEnabled,
            onChanged: (v) => setState(() => _soundEnabled = v),
          ),

          // About Section
          _buildSectionHeader('เกี่ยวกับ'),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'เกี่ยวกับแอป',
            onTap: () => _showAboutDialog(),
          ),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'ช่วยเหลือ',
            onTap: () {},
          ),

          const SizedBox(height: 20),

          // Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => _confirmLogout(),
              icon: const Icon(Icons.logout, color: AppTheme.errorColor),
              label: const Text('ออกจากระบบ', style: TextStyle(color: AppTheme.errorColor)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.errorColor),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Center(child: Text('เวอร์ชัน 1.0.0', style: TextStyle(color: AppTheme.textMuted))),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(title, style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, String? subtitle, required VoidCallback onTap}) {
    return ListTile(
      leading: _buildIcon(icon, AppTheme.primaryColor),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: AppTheme.textMuted)) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เปลี่ยนรหัสผ่าน'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(obscureText: true, decoration: const InputDecoration(labelText: 'รหัสผ่านปัจจุบัน')),
            const SizedBox(height: 12),
            TextField(obscureText: true, decoration: const InputDecoration(labelText: 'รหัสผ่านใหม่')),
            const SizedBox(height: 12),
            TextField(obscureText: true, decoration: const InputDecoration(labelText: 'ยืนยันรหัสผ่านใหม่')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ยกเลิก')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('บันทึก')),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(children: [
          Icon(Icons.build_circle, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          const Text('CarHelp Tech'),
        ]),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('แอปสำหรับช่างบริการรถยนต์'),
            SizedBox(height: 8),
            Text('เวอร์ชัน: 1.0.0'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('ปิด'))],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ออกจากระบบ'),
        content: const Text('คุณต้องการออกจากระบบใช่หรือไม่?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ยกเลิก')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('ออกจากระบบ'),
          ),
        ],
      ),
    );
  }
}
