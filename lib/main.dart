import 'package:carteira_core/carteira_core.dart';
import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import 'scenes/main/main_factory.dart';
import 'scenes/login/login_factory.dart';
import 'storage/shared_preferences_session_storage.dart';

/// Endereço da API (porta 8080 do Codespace do servidor).
const _baseUrl =
    'https://shady-spooky-hobgoblin-445p69x54xwcjwrx-8080.app.github.dev';

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
  // Um único ApiClient, compartilhado por todos os repositórios: é ele que
  // guarda o token depois do login.
  late final ApiClient _client = ApiClient(baseUrl: _baseUrl);

  late final AuthRepository _authRepository = RemoteAuthRepository(
    client: _client,
    storage: SharedPreferencesSessionStorage(),
  );

  late final TransactionRepository _transactionRepository =
      RemoteTransactionRepository(client: _client);

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
      _AuthState.signedIn => MainFactory.make(
        authRepository: _authRepository,
        transactionRepository: _transactionRepository,
        onLogout: () => setState(() => _state = _AuthState.signedOut),
      ),
    };
  }
}
