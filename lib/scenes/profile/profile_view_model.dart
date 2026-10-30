import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;

import 'profile_coordinator.dart';

enum ProfileStatus { loading, ready, failure }

/// Estado e ações da cena de perfil.
class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({
    required this._authRepository,
    required this._userRepository,
    required this._coordinator,
  });

  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final ProfileCoordinator _coordinator;

  ProfileStatus _status = ProfileStatus.loading;
  User? _user;
  String _name = '';
  String _avatarUrl = '';
  bool _isSaving = false;
  String? _nameError;
  String? _message;
  String? _errorMessage;
  bool _disposed = false;

  ProfileStatus get status => _status;
  bool get isSaving => _isSaving;
  String? get nameError => _nameError;

  /// Confirmação depois de salvar.
  String? get message => _message;

  /// Falha ao carregar ou ao salvar.
  String? get errorMessage => _errorMessage;

  // Cabeçalho: sempre o último usuário confirmado pelo servidor.
  String get displayName => _user?.name ?? '';
  String get email => _user?.email ?? '';
  String? get avatarUrl => _user?.avatarUrl;

  String get memberSince {
    final user = _user;
    if (user == null) return '';
    return 'Na Carteira desde ${formatDate(user.createdAt)}';
  }

  // Valores iniciais dos campos do formulário.
  String get formName => _user?.name ?? '';
  String get formAvatarUrl => _user?.avatarUrl ?? '';

  Future<void> load() async {
    _status = ProfileStatus.loading;
    _errorMessage = null;
    _notify();

    final result = await _userRepository.getProfile();
    result.when(
      ok: (user) {
        _user = user;
        _name = user.name;
        _avatarUrl = user.avatarUrl ?? '';
        _status = ProfileStatus.ready;
      },
      failure: (error) {
        _errorMessage = error.message;
        _status = ProfileStatus.failure;
      },
    );
    _notify();
  }

  void onNameChanged(String value) {
    _name = value;
    _nameError = null;
    _message = null;
    _notify();
  }

  void onAvatarUrlChanged(String value) {
    _avatarUrl = value;
    _message = null;
    _notify();
  }

  Future<void> save() async {
    if (_isSaving) return;

    final error = validateRequired(_name, field: 'O nome');
    if (error != null) {
      _nameError = error;
      _notify();
      return;
    }

    _isSaving = true;
    _message = null;
    _errorMessage = null;
    _notify();

    final url = _avatarUrl.trim();
    final result = await _userRepository.updateProfile(
      name: _name,
      avatarUrl: url.isEmpty ? null : url,
    );

    _isSaving = false;
    result.when(
      ok: (user) {
        _user = user;
        _name = user.name;
        _message = 'Perfil atualizado.';
      },
      failure: (error) {
        _errorMessage = error.message;
      },
    );
    _notify();
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _coordinator.goToLogin();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
