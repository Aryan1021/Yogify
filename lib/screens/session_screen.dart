import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/session.dart';
import '../services/pose_service.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  late Future<YogaSession> sessionFuture;
  int currentStepIndex = 0;
  AudioPlayer audioPlayer = AudioPlayer();
  Timer? stepTimer;

  @override
  void initState() {
    super.initState();
    sessionFuture = PoseService().loadSession();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    stepTimer?.cancel();
    super.dispose();
  }

  void _playStep(YogaSession session, int index) async {
    if (index >= session.sequence.length) return;

    final step = session.sequence[index];
    final audioFile = session.audio[step.audioRef];

    // Cancel any previous timers
    stepTimer?.cancel();

    // Play audio
    if (audioFile != null) {
      await audioPlayer.stop();
      await audioPlayer.play(AssetSource("audio/$audioFile"));
    }

    // Move to next step after duration
    stepTimer = Timer(Duration(seconds: step.durationSec), () {
      if (mounted) {
        setState(() {
          currentStepIndex++;
        });
        _playStep(session, currentStepIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yogify - Session")),
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

          // Start first step automatically
          if (currentStepIndex < session.sequence.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _playStep(session, currentStepIndex);
            });
          }

          if (currentStepIndex >= session.sequence.length) {
            return const Center(child: Text("Session Completed ✅"));
          }

          final currentStep = session.sequence[currentStepIndex];

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                currentStep.name,
                style:
                const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Show first script image + text for this step
              if (currentStep.script.isNotEmpty) ...[
                Image.asset(
                  "assets/images/${session.images[currentStep.script[0].imageRef]}",
                  height: 250,
                  fit: BoxFit.contain,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    currentStep.script[0].text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],

              const SizedBox(height: 20),
              Text("Step ${currentStepIndex + 1} of ${session.sequence.length}"),
            ],
          );
        },
      ),
    );
  }
}
