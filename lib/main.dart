import 'package:flutter/material.dart';

void main() {
  runApp(const HelpHubApp());
}

class HelpHubApp extends StatelessWidget {
  const HelpHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HelpHub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HelpHubHomePage(),
    );
  }
}

class HelpHubHomePage extends StatelessWidget {
  const HelpHubHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HelpHub'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'HelpHub project is ready.\n\nNext steps:\n'
            '1. Connect Firebase (flutterfire configure)\n'
            '2. Build authentication module\n'
            '3. Implement concern reporting and SOS',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
