class YogaSession {
  final Map<String, dynamic> metadata;
  final Map<String, String> images;
  final Map<String, String> audio;
  final List<SequenceStep> sequence;

  YogaSession({
    required this.metadata,
    required this.images,
    required this.audio,
    required this.sequence,
  });

  factory YogaSession.fromJson(Map<String, dynamic> json) {
    final assets = json['assets'] as Map<String, dynamic>;
    return YogaSession(
      metadata: json['metadata'] as Map<String, dynamic>,
      images: Map<String, String>.from(assets['images']),
      audio: Map<String, String>.from(assets['audio']),
      sequence: (json['sequence'] as List<dynamic>)
          .map((e) => SequenceStep.fromJson(e))
          .toList(),
    );
  }
}

class SequenceStep {
  final String type;
  final String name;
  final String audioRef;
  final int durationSec;
  final List<ScriptLine> script;

  SequenceStep({
    required this.type,
    required this.name,
    required this.audioRef,
    required this.durationSec,
    required this.script,
  });

  factory SequenceStep.fromJson(Map<String, dynamic> json) {
    return SequenceStep(
      type: json['type'],
      name: json['name'],
      audioRef: json['audioRef'],
      durationSec: json['durationSec'],
      script: (json['script'] as List<dynamic>)
          .map((e) => ScriptLine.fromJson(e))
          .toList(),
    );
  }
}

class ScriptLine {
  final String text;
  final int startSec;
  final int endSec;
  final String imageRef;

  ScriptLine({
    required this.text,
    required this.startSec,
    required this.endSec,
    required this.imageRef,
  });

  factory ScriptLine.fromJson(Map<String, dynamic> json) {
    return ScriptLine(
      text: json['text'],
      startSec: json['startSec'],
      endSec: json['endSec'],
      imageRef: json['imageRef'],
    );
  }
}
