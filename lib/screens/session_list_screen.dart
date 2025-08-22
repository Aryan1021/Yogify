import 'package:flutter/material.dart';
import '../models/session.dart';
import '../services/pose_service.dart';
import 'preview_screen.dart'; // ✅ new screen

class SessionListScreen extends StatelessWidget {
  const SessionListScreen({super.key});

  final List<String> sessionFiles = const [
    "assets/sessions/cat_cow.json",
    "assets/sessions/sun_salutation.json",
  ];

  Future<YogaSession> _loadSession(String path) {
    return PoseService().loadSession(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yogify - Sessions")),
      body: ListView.builder(
        itemCount: sessionFiles.length,
        itemBuilder: (context, index) {
          final path = sessionFiles[index];
          return FutureBuilder<YogaSession>(
            future: _loadSession(path),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const ListTile(title: Text("Loading..."));
              }
              final session = snapshot.data!;
              return ListTile(
                title: Text(session.metadata["title"] ?? "Unknown"),
                subtitle: Text(session.metadata["category"] ?? ""),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PreviewScreen(session: session, path: path), // ✅ open preview first
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
