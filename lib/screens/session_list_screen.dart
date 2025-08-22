import 'package:flutter/material.dart';
import '../models/session.dart';
import '../services/pose_service.dart';
import 'preview_screen.dart';

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
        padding: const EdgeInsets.all(16),
        itemCount: sessionFiles.length,
        itemBuilder: (context, index) {
          final path = sessionFiles[index];
          return FutureBuilder<YogaSession>(
            future: _loadSession(path),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final session = snapshot.data!;

              // Use the first script's image as thumbnail
              final firstImageRef = session.sequence.first.script.first.imageRef;
              final thumbnailPath = "assets/images/${session.images[firstImageRef]}";

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      thumbnailPath,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    session.metadata["title"] ?? "Unknown",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    session.metadata["category"] ?? "",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PreviewScreen(session: session, path: path),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
