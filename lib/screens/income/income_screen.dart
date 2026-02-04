import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../../config/theme.dart';
import 'package:intl/intl.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final ApiService _api = ApiService();
  final _currencyFormat = NumberFormat.currency(locale: 'th_TH', symbol: '฿', decimalDigits: 0);
  
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String _period = 'month';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final response = await _api.get('${ApiConfig.incomeDashboard}?period=$_period');

    setState(() {
      _isLoading = false;
      if (response.success && response.data != null) {
        _data = response.data;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายได้'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _period = value);
              _loadData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'day', child: Text('วันนี้')),
              const PopupMenuItem(value: 'week', child: Text('สัปดาห์นี้')),
              const PopupMenuItem(value: 'month', child: Text('เดือนนี้')),
              const PopupMenuItem(value: 'year', child: Text('ปีนี้')),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
              ? const Center(child: Text('ไม่สามารถโหลดข้อมูลได้'))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCards(),
                        const SizedBox(height: 24),
                        _buildRecentJobs(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSummaryCards() {
    final summary = _data?['summary'] ?? {};
    final totalIncome = summary['total_income'] ?? 0.0;
    final totalJobs = summary['total_jobs'] ?? 0;
    final allTimeIncome = summary['all_time_income'] ?? 0.0;
    final avgRating = summary['avg_rating'] ?? 0.0;

    return Column(
      children: [
        // Main income card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                _getPeriodText(),
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                _currencyFormat.format(totalIncome),
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '$totalJobs งาน',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Stats row
        Row(
          children: [
            Expanded(
              child: _buildStatCard('รายได้ทั้งหมด', _currencyFormat.format(allTimeIncome), Icons.account_balance_wallet, Colors.green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard('คะแนนเฉลี่ย', avgRating.toStringAsFixed(1), Icons.star, Colors.amber),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRecentJobs() {
    final recentJobs = List<Map<String, dynamic>>.from(_data?['recent_jobs'] ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('งานล่าสุด', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (recentJobs.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text('ยังไม่มีงานที่เสร็จสิ้น', style: TextStyle(color: Colors.grey[500])),
            ),
          )
        else
          ...recentJobs.map((job) => _buildJobItem(job)),
      ],
    );
  }

  Widget _buildJobItem(Map<String, dynamic> job) {
    final price = double.tryParse(job['price']?.toString() ?? '0') ?? 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withOpacity(0.1),
          child: const Icon(Icons.check_circle, color: Colors.green),
        ),
        title: Text(job['problem_type'] ?? 'งานซ่อม'),
        subtitle: Text(job['customer_name'] ?? 'ลูกค้า'),
        trailing: Text(
          _currencyFormat.format(price),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
        ),
      ),
    );
  }

  String _getPeriodText() {
    switch (_period) {
      case 'day': return 'รายได้วันนี้';
      case 'week': return 'รายได้สัปดาห์นี้';
      case 'year': return 'รายได้ปีนี้';
      default: return 'รายได้เดือนนี้';
    }
  }
}
