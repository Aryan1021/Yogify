import 'package:flutter/material.dart';
import '../models/session.dart';
import 'session_screen.dart';

class PreviewScreen extends StatelessWidget {
  final YogaSession session;
  final String path;

  const PreviewScreen({super.key, required this.session, required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Preview: ${session.metadata['title']}")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("Category: ${session.metadata['category']}",
              style: const TextStyle(fontSize: 18)),
          const Divider(),
          ...session.sequence.expand((step) => step.script).map(
                (script) => ListTile(
              leading: Image.asset(
                "assets/images/${session.images[script.imageRef]}",
                width: 50,
              ),
              title: Text(script.text),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text("Start Session"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SessionScreen(path: path),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
