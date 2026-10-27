import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/foundation.dart';

import 'login_coordinator.dart';

/// Estado e ações da cena de login.
class LoginViewModel extends ChangeNotifier {
  LoginViewModel({
    required this._authRepository,
    required this._coordinator,
  });

  final AuthRepository _authRepository;
  final LoginCoordinator _coordinator;

  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String? _errorMessage;

  String get email => _email;
  String get password => _password;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void onEmailChanged(String value) {
    _email = value;
  }

  void onPasswordChanged(String value) {
    _password = value;
  }

  Future<void> submit() async {
    if (_isLoading) return;

    if (_email.trim().isEmpty || _password.isEmpty) {
      _errorMessage = 'Informe e-mail e senha.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.login(
      email: _email,
      password: _password,
    );

    _isLoading = false;
    result.when(
      ok: (_) {
        notifyListeners();
        _coordinator.goToHome();
      },
      failure: (error) {
        _errorMessage = error.message;
        notifyListeners();
      },
    );
  }
}