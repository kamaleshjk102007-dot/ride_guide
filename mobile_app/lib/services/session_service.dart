import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_session.dart';

class SessionService {
  static const _sessionKey = 'ride_guide_user_session';
  static const _ticketVisitorIdKey = 'ride_guide_ticket_visitor_id';

  Future<void> saveSession(UserSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
    if (session.visitorId.isNotEmpty) {
      await prefs.setString(_ticketVisitorIdKey, session.visitorId);
    }
  }

  Future<UserSession?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      return UserSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await prefs.remove(_sessionKey);
      return null;
    }
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove(_ticketVisitorIdKey);
  }

  Future<void> saveTicketVisitorId(String visitorId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ticketVisitorIdKey, visitorId);
  }

  Future<String?> loadTicketVisitorId() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_ticketVisitorIdKey);
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    return raw.trim();
  }
}
