import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/job_model.dart';
import '../../providers/job_provider.dart';
import '../../config/theme.dart';
import '../home/home_screen.dart';

class ActiveJobScreen extends StatefulWidget {
  final JobModel job;

  const ActiveJobScreen({super.key, required this.job});

  @override
  State<ActiveJobScreen> createState() => _ActiveJobScreenState();
}

class _ActiveJobScreenState extends State<ActiveJobScreen> {
  late JobModel _job;
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _job = widget.job;
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(String status) async {
    final provider = Provider.of<JobProvider>(context, listen: false);
    final success = await provider.updateJobStatus(_job.requestId, status);
    
    if (success && mounted) {
      setState(() {
        _job = JobModel(
          requestId: _job.requestId,
          customerId: _job.customerId,
          technicianId: _job.technicianId,
          problemType: _job.problemType,
          problemDetails: _job.problemDetails,
          locationLat: _job.locationLat,
          locationLng: _job.locationLng,
          status: status,
          price: _job.price,
          customerName: _job.customerName,
          customerPhone: _job.customerPhone,
        );
      });
    }
  }

  Future<void> _finishJob() async {
    final price = double.tryParse(_priceController.text) ?? 0;
    if (price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกราคา'), backgroundColor: AppTheme.warningColor),
      );
      return;
    }

    final provider = Provider.of<JobProvider>(context, listen: false);
    final success = await provider.finishJob(_job.requestId, price);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ปิดงานสำเร็จ!'), backgroundColor: AppTheme.primaryColor),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _callCustomer() async {
    if (_job.customerPhone != null) {
      final uri = Uri.parse('tel:${_job.customerPhone}');
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    }
  }

  Future<void> _openNavigation() async {
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${_job.locationLat},${_job.locationLng}');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('งานปัจจุบัน'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.getStatusColor(_job.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(_getStatusIcon(_job.status), size: 48, color: AppTheme.getStatusColor(_job.status)),
                  const SizedBox(height: 12),
                  Text(AppTheme.getStatusText(_job.status), style: Theme.of(context).textTheme.headlineMedium),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Customer info
            _InfoCard(
              title: 'ข้อมูลลูกค้า',
              icon: Icons.person,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_job.customerName ?? 'ลูกค้า', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _callCustomer,
                          icon: const Icon(Icons.phone),
                          label: const Text('โทร'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _openNavigation,
                          icon: const Icon(Icons.navigation),
                          label: const Text('นำทาง'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Problem info
            _InfoCard(
              title: 'ปัญหาที่แจ้ง',
              icon: Icons.build,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_job.problemType, style: Theme.of(context).textTheme.titleMedium),
                  if (_job.problemDetails.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(_job.problemDetails, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons based on status
            if (_job.isAccepted) ...[
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () => _updateStatus('traveling'),
                  icon: const Icon(Icons.directions_car),
                  label: const Text('เริ่มเดินทาง'),
                ),
              ),
            ] else if (_job.isTraveling) ...[
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () => _updateStatus('working'),
                  icon: const Icon(Icons.build),
                  label: const Text('ถึงแล้ว - เริ่มซ่อม'),
                ),
              ),
            ] else if (_job.isWorking) ...[
              Text('ราคาค่าบริการ', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'กรอกราคา',
                  prefixIcon: Icon(Icons.attach_money),
                  suffixText: 'บาท',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _finishJob,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('ปิดงาน'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'accepted': return Icons.check_circle;
      case 'traveling': return Icons.directions_car;
      case 'working': return Icons.build;
      default: return Icons.info;
    }
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _InfoCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.textMuted),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
