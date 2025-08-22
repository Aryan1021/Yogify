import 'package:flutter/material.dart';
import '../models/session.dart';
import 'session_screen.dart';

class PreviewScreen extends StatelessWidget {
  final YogaSession session;
  final String path;

  const PreviewScreen({super.key, required this.session, required this.path});

  @override
  Widget build(BuildContext context) {
    // Use first image as header preview
    final firstImageRef = session.sequence.first.script.first.imageRef;
    final headerImage = "assets/images/${session.images[firstImageRef]}";

    return Scaffold(
      appBar: AppBar(title: Text("Preview: ${session.metadata['title']}")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero Image + Session Header
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: "sessionThumb-$path", // ✅ Hero tag matches ListScreen
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.asset(
                      headerImage,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.metadata['title'] ?? "Yoga Session",
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("Category: ${session.metadata['category']}",
                          style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sequence Steps
          const Text(
            "Session Flow",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...session.sequence.expand((step) => step.script).map(
                (script) => Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    "assets/images/${session.images[script.imageRef]}",
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  script.text,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Start Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.play_arrow, size: 28),
              label: const Text("Start Session", style: TextStyle(fontSize: 18)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SessionScreen(path: path),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
