import 'package:flutter/material.dart';

class SportMoreInfoTab extends StatelessWidget {
  final String description;

  const SportMoreInfoTab({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Text(
        description.isNotEmpty ? description : 'لا توجد معلومات إضافية',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
