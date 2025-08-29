import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/session.dart';
import '../services/pose_service.dart';

class SessionScreen extends StatefulWidget {
  final String path;
  const SessionScreen({super.key, required this.path});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen>
    with TickerProviderStateMixin {
  late Future<YogaSession> sessionFuture;
  late AnimationController _pulseController;
  late AnimationController _breatheController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _breatheAnimation;

  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _tickTimer;

  int currentStepIndex = 0;
  int currentScriptIndex = 0;
  int elapsedSec = 0;
  bool _started = false;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    sessionFuture = PoseService().loadSession(widget.path);

    // Initialize animations
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _breatheController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _breatheAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _breatheController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
    _breatheController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _audioPlayer.dispose();
    _pulseController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  void _startStep(YogaSession session, int stepIndex) async {
    if (!mounted) return;
    if (stepIndex >= session.sequence.length) return;

    final step = session.sequence[stepIndex];
    final audioFile = session.audio[step.audioRef];

    setState(() {
      elapsedSec = 0;
      currentScriptIndex = 0;
    });

    await _audioPlayer.stop();

    if (audioFile != null) {
      await _audioPlayer.play(AssetSource("audio/$audioFile"));
    }

    _tickTimer?.cancel();

    _tickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_paused) return;

      elapsedSec++;

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

  void _pauseSession() {
    setState(() {
      _paused = true;
    });
    _audioPlayer.pause();
  }

  void _resumeSession(YogaSession session) {
    setState(() {
      _paused = false;
    });
    _audioPlayer.resume();
  }

  void _stopSession() {
    _tickTimer?.cancel();
    _audioPlayer.stop();
    setState(() {
      currentStepIndex = 0;
      currentScriptIndex = 0;
      elapsedSec = 0;
      _started = false;
      _paused = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.black87),
              onPressed: () {
                // Settings functionality can be added here
              },
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: FutureBuilder<YogaSession>(
        future: sessionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.teal, Colors.cyan],
                            ),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: const Icon(
                            Icons.spa,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Preparing your session...",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      "Oops! Something went wrong",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Error: ${snapshot.error}",
                      style: TextStyle(color: Colors.red[600]),
                    ),
                  ],
                ),
              ),
            );
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
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF8FFFE), Color(0xFFE8F5F3)],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.teal, Colors.cyan],
                              ),
                              borderRadius: BorderRadius.circular(60),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.teal.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 60,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      "Session Completed! ✨",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Great job! Take a moment to breathe and relax.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Return to Sessions",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final step = session.sequence[currentStepIndex];
          final script = step.script[currentScriptIndex];
          final progress = elapsedSec / (step.durationSec > 0 ? step.durationSec : 1);

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF8FFFE), Color(0xFFE8F5F3)],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Progress Indicator
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Step ${currentStepIndex + 1}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                "of ${session.sequence.length}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: progress),
                              duration: const Duration(milliseconds: 300),
                              builder: (context, value, _) => LinearProgressIndicator(
                                value: value,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.teal,
                                ),
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${elapsedSec}s / ${step.durationSec}s",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Pose Name
                    Text(
                      step.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // Pose Image with breathing animation
                    Expanded(
                      flex: 3,
                      child: AnimatedBuilder(
                        animation: _breatheAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _breatheAnimation.value,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: Container(
                                key: ValueKey(script.imageRef),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.teal.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    "assets/images/${session.images[script.imageRef]}",
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Script Text with enhanced styling
                    Expanded(
                      flex: 2,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: Text(
                              script.text,
                              key: ValueKey(script.text),
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.4,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Enhanced Control Panel
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildControlButton(
                            Icons.play_arrow,
                            Colors.green,
                                () => _resumeSession(session),
                            !_paused,
                          ),
                          _buildControlButton(
                            Icons.pause,
                            Colors.orange,
                            _pauseSession,
                            _paused,
                          ),
                          _buildControlButton(
                            Icons.stop,
                            Colors.red,
                            _stopSession,
                            false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildControlButton(
      IconData icon,
      Color color,
      VoidCallback onPressed,
      bool isDisabled,
      ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isDisabled ? null : onPressed,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDisabled
                  ? Colors.grey[300]
                  : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDisabled
                    ? Colors.grey[400]!
                    : color.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              size: 28,
              color: isDisabled
                  ? Colors.grey[500]
                  : color,
            ),
          ),
        ),
      ),
    );
  }
}