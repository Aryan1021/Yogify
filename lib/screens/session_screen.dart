import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/session.dart';
import '../services/pose_service.dart';

class SessionScreen extends StatefulWidget {
  final String path; // ✅ Accepts JSON path dynamically
  const SessionScreen({super.key, required this.path});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  late Future<YogaSession> sessionFuture;

  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _tickTimer;

  int currentStepIndex = 0;
  int currentScriptIndex = 0;
  int elapsedSec = 0;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    // ✅ Load session dynamically from given path
    sessionFuture = PoseService().loadSession(widget.path);
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startStep(YogaSession session, int stepIndex) async {
    if (!mounted) return;
    if (stepIndex >= session.sequence.length) return;

    final step = session.sequence[stepIndex];
    final audioFile = session.audio[step.audioRef];

    // Reset tracking
    setState(() {
      elapsedSec = 0;
      currentScriptIndex = 0;
    });

    await _audioPlayer.stop();

    // Play audio if available
    if (audioFile != null) {
      await _audioPlayer.play(AssetSource("audio/$audioFile"));
    }

    _tickTimer?.cancel();

    // Timer to control script + step transitions
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsedSec++;

      // Update script index
      for (int i = 0; i < step.script.length; i++) {
        if (elapsedSec >= step.script[i].startSec &&
            elapsedSec < step.script[i].endSec) {
          if (i != currentScriptIndex) {
            setState(() {
              currentScriptIndex = i;
            });
          }
          break;
        }
      }

      // End step after duration
      if (elapsedSec >= step.durationSec) {
        timer.cancel();
        _audioPlayer.stop();
        if (mounted) {
          setState(() {
            currentStepIndex++;
            currentScriptIndex = 0;
          });
          _startStep(session, currentStepIndex);
        }
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
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("No session data found"));
          }

          final session = snapshot.data!;

          if (!_started) {
            _started = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _startStep(session, currentStepIndex);
            });
          }

          if (currentStepIndex >= session.sequence.length) {
            return const Center(child: Text("Session Completed ✅"));
          }

          final step = session.sequence[currentStepIndex];
          final script = step.script[currentScriptIndex];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  step.name,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Image.asset(
                  "assets/images/${session.images[script.imageRef]}",
                  height: 260,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                Text(
                  script.text,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  "Step ${currentStepIndex + 1} of ${session.sequence.length}\n"
                      "(${elapsedSec}s / ${step.durationSec}s)",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
