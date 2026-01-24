import 'package:flutter/material.dart';

class CategoryHomeScreen extends StatelessWidget {
  final String category;

  const CategoryHomeScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: const Center(
        child: Text('Details for category: \$category'),
      ),
    );
  }
}
