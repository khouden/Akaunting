import 'package:flutter/material.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Akaunting Dashboard')),
      body: const Center(
        child: Text('Main Authenticated Area - Ready for components!'),
      ),
    );
  }
}
