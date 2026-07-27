import 'package:flutter/material.dart';

/// One status-count tile in Screen 6's summary-cards row (FR11).
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    required this.label,
    required this.value,
    super.key,
    this.color,
  });

  final String label;
  final int value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$value',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
