import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/job_provider.dart';
import '../../config/theme.dart';
import 'active_job_screen.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<JobProvider>(context, listen: false).loadAvailableJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('งานที่รอรับ')),
      body: Consumer<JobProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final pendingJobs = provider.availableJobs.where((j) => j.canAccept).toList();

          if (pendingJobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: AppTheme.textMuted.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text('ไม่มีงานที่รอรับในขณะนี้', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textMuted)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadAvailableJobs(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingJobs.length,
              itemBuilder: (context, index) {
                final job = pendingJobs[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.warningColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.build, color: AppTheme.warningColor),
                        ),
                        title: Text(job.problemType, style: Theme.of(context).textTheme.titleMedium),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (job.customerName != null) ...[
                              const SizedBox(height: 4),
                              Text('ลูกค้า: ${job.customerName}', style: Theme.of(context).textTheme.bodySmall),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              job.requestTime != null
                                  ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(job.requestTime!))
                                  : '-',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final success = await provider.acceptJob(job.requestId);
                              if (success && context.mounted) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (_) => ActiveJobScreen(job: provider.currentJob!)),
                                );
                              } else if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(provider.errorMessage), backgroundColor: AppTheme.errorColor),
                                );
                              }
                            },
                            child: const Text('รับงาน'),
                          ),
                        ),
                      ),
                    ],
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
