import 'package:flutter/material.dart';

class HistoryList extends StatelessWidget {
  final List<String> history;
  final Function(String) onItemTap;

  const HistoryList({
    super.key,
    required this.history,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Text('No history yet.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: history.map((item) {
        return ListTile(
          title: Text(item),
          onTap: () => onItemTap(item),
        );
      }).toList(),
    );
  }
}
