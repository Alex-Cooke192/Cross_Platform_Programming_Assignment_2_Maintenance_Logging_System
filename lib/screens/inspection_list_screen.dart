import 'package:flutter/material.dart';
import 'task_detail_screen.dart';


class InspectionListScreen extends StatelessWidget {
  const InspectionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspections'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 5, // placeholder
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          return _InspectionTile(
            aircraft: 'G-ABCD',
            status: index == 0 ? 'In Progress' : 'Open',
            location: 'Hangar A',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TaskDetailScreen(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _InspectionTile extends StatelessWidget {
  final String aircraft;
  final String status;
  final String location;
  final VoidCallback onTap;

  const _InspectionTile({
    required this.aircraft,
    required this.status,
    required this.location,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(
          aircraft,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(location),
        trailing: Text(
          status,
          style: TextStyle(
            color: status == 'In Progress' ? Colors.orange : Colors.green,
          ),
        ),
      ),
    );
  }
}
