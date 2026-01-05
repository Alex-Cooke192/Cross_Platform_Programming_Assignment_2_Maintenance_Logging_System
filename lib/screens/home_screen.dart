import 'package:flutter/material.dart';
import 'outstanding_inspection_list_screen.dart';
import 'current_inspection_list_screen.dart'; 
import '../mocks/mock_models.dart';
import '../widgets/signed_in_as_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('RampCheck'),

        leadingWidth: 180,
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: SignedInAs(userLabel: 'user.name'),
        ),

        actions: const [
          Icon(Icons.sync), // later: sync status indicator
          SizedBox(width: 12),
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
              title: 'Assigned Inspections: Ready to begin',
              value: '3',
              icon: Icons.assignment,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OutstandingInspectionListScreen(
                      inspections: MockData.inspections,
                      tasks: MockData.tasks,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            _DashboardCard(
              title: 'Assigned Inspections: In Progress',
              value: '1',
              icon: Icons.build,
              onTap: () {
                // 1) filter inspections to only "in progress"
                final inProgress = MockData.inspections
                    .where((i) => i.statusLabel == "In Progress") // <-- adjust to your model
                    .toList();

                // 2) navigate
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CurrentInspectionListScreen(
                      inProgressInspections: inProgress,
                      onOpenInspection: (inspection) {
                        // navigate to your inspection details/resume screen
                        // Example:
                        // Navigator.push(context, MaterialPageRoute(builder: (_) => InspectionDetailsScreen(inspection: inspection)));

                        // If you want to use your existing task screen, you can look up tasks by inspection id here.
                      },
                      onStartNewInspection: () {
                        // start flow (optional)
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),


            _DashboardCard(
              title: 'Assigned Inspections: Completed • Awaiting Sync',
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
