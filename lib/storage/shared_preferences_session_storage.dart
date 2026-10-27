import 'dart:convert';

import 'package:carteira_core/carteira_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda a sessão no aparelho. O Core só define a interface
/// [SessionStorage]; esta é a implementação do app.
class SharedPreferencesSessionStorage implements SessionStorage {
  static const _key = 'carteira_session';

  @override
  Future<Session?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    return Session.fromJson(jsonDecode(raw) as Map<String, Object?>);
  }

  @override
  Future<void> write(Session session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(session.toJson()));
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}