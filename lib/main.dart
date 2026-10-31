import 'package:carteira_core/carteira_core.dart';
import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import 'scenes/login/login_factory.dart';
import 'scenes/main/main_factory.dart';
import 'scenes/new_transaction/new_transaction_factory.dart';
import 'scenes/transaction_detail/transaction_detail_factory.dart';
import 'storage/shared_preferences_session_storage.dart';

/// Endereço da API (porta 8080 do Codespace do servidor).
const _baseUrl =
    'https://shady-spooky-hobgoblin-445p69x54xwcjwrx-8080.app.github.dev';

void main() {
  runApp(const CarteiraApp());
}

class CarteiraApp extends StatefulWidget {
  const CarteiraApp({super.key});

  @override
  State<CarteiraApp> createState() => _CarteiraAppState();
}

class _CarteiraAppState extends State<CarteiraApp> {
  ThemeMode _themeMode = ThemeMode.system;

  /// Alterna entre claro e escuro, partindo do que está aparecendo agora.
  void _toggleTheme() {
    final systemIsDark =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
    final isDark =
        _themeMode == ThemeMode.dark ||
        (_themeMode == ThemeMode.system && systemIsDark);
    setState(() => _themeMode = isDark ? ThemeMode.light : ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carteira Digital',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode,
      home: AppRoot(onToggleTheme: _toggleTheme),
    );
  }
}

enum _AuthState { checking, signedOut, signedIn }

/// Decide entre Login e Home conforme haja sessão salva.
class AppRoot extends StatefulWidget {
  const AppRoot({required this.onToggleTheme, super.key});

  final void Function() onToggleTheme;

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

  late final UserRepository _userRepository = RemoteUserRepository(
    client: _client,
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

  /// Abre o detalhe por cima da Home. Devolve true se o lançamento foi
  /// excluído, para a Home recarregar a lista.
  Future<bool> _openTransaction(String id) async {
    final deleted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TransactionDetailFactory.make(
          transactionRepository: _transactionRepository,
          transactionId: id,
          onClose: (deleted) => Navigator.of(context).pop(deleted),
        ),
      ),
    );
    return deleted ?? false;
  }

  /// Abre o formulário por cima da Home. Devolve true se criou um lançamento,
  /// para a Home recarregar a lista.
  Future<bool> _openNewTransaction() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => NewTransactionFactory.make(
          transactionRepository: _transactionRepository,
          onClose: (created) => Navigator.of(context).pop(created),
        ),
      ),
    );
    return created ?? false;
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
        userRepository: _userRepository,
        onLogout: () => setState(() => _state = _AuthState.signedOut),
        onToggleTheme: widget.onToggleTheme,
        onOpenTransaction: _openTransaction,
        onOpenNewTransaction: _openNewTransaction,
      ),
    };
  }
}
