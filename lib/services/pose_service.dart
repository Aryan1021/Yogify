import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/session.dart';

class PoseService {
  Future<YogaSession> loadSession() async {
    final String response = await rootBundle.loadString('assets/poses.json');
    final Map<String, dynamic> data = json.decode(response);

    return YogaSession.fromJson(data);
  }
}
