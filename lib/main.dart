import 'package:flutter/material.dart';
import 'services/pose_service.dart';
import 'models/session.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yogify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PoseTestScreen(),
    );
  }
}

class PoseTestScreen extends StatefulWidget {
  const PoseTestScreen({super.key});

  @override
  State<PoseTestScreen> createState() => _PoseTestScreenState();
}

class _PoseTestScreenState extends State<PoseTestScreen> {
  // ✅ Initialize directly, no 'late' needed
  final Future<YogaSession> sessionFuture = PoseService().loadSession();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yogify - Session Test")),
      body: FutureBuilder<YogaSession>(
        future: sessionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No session data found"));
          }

          final session = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text("Title: ${session.metadata['title']}",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              Text("Category: ${session.metadata['category']}"),
              const Divider(),
              ...session.sequence.map((step) => ListTile(
                title: Text("${step.name} (${step.type})"),
                subtitle: Text("Duration: ${step.durationSec} sec"),
              )),
            ],
          );
        },
      ),
    );
  }
}
