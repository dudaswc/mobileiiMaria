import 'package:carteira_core/carteira_core.dart';
import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import 'scenes/home/home_factory.dart';
import 'scenes/login/login_factory.dart';
import 'storage/shared_preferences_session_storage.dart';

/// Endereço da API (porta 8080 do Codespace do servidor).
const _baseUrl = 'https://animated-memory-5gvx6q6p6pvhq49-8080.app.github.dev';

void main() {
  runApp(const CarteiraApp());
}

class CarteiraApp extends StatelessWidget {
  const CarteiraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carteira Digital',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const AppRoot(),
    );
  }
}

enum _AuthState { checking, signedOut, signedIn }

/// Decide entre Login e Home conforme haja sessão salva.
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  late final AuthRepository _authRepository = RemoteAuthRepository(
    client: ApiClient(baseUrl: _baseUrl),
    storage: SharedPreferencesSessionStorage(),
  );

  _AuthState _state = _AuthState.checking;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final result = await _authRepository.restore();
    final session = result.valueOrNull;
    if (!mounted) return;
    setState(() {
      _state = session == null ? _AuthState.signedOut : _AuthState.signedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return switch (_state) {
      _AuthState.checking => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      _AuthState.signedOut => LoginFactory.make(
        authRepository: _authRepository,
        onLoginSuccess: () => setState(() => _state = _AuthState.signedIn),
      ),
      _AuthState.signedIn => HomeFactory.make(
        authRepository: _authRepository,
        onLogout: () => setState(() => _state = _AuthState.signedOut),
      ),
    };
  }
}