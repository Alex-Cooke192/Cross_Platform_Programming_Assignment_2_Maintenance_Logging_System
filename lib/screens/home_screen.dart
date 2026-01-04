import 'package:flutter/material.dart';
import 'inspection_list_screen.dart';
import '../mocks/mock_models.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RampCheck'),
        actions: const [
          Icon(Icons.sync), // later: sync status indicator
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today’s Work',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _DashboardCard(
              title: 'Assigned Inspections',
              value: '3',
              icon: Icons.assignment,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InspectionListScreen(
                      inspections: MockData.inspections,
                      tasks: MockData.tasks,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            _DashboardCard(
              title: 'In Progress',
              value: '1',
              icon: Icons.build,
              onTap: () {
                // later: navigate to filtered list
              },
            ),
            const SizedBox(height: 12),

            _DashboardCard(
              title: 'Completed • Awaiting Sync',
              value: '2',
              icon: Icons.cloud_upload,
              onTap: () {
                // later: navigate to completed+dirty list
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 32),
              const SizedBox(width: 16),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
              Text(
                value,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
