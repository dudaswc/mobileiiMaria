import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;

import 'profile_coordinator.dart';

/// Estado e ações da cena de perfil.
class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({
    required this._authRepository,
    required this._coordinator,
  });

  final AuthRepository _authRepository;
  final ProfileCoordinator _coordinator;

  User? get _user => _authRepository.currentSession?.user;

  String get name => _user?.name ?? '';
  String get email => _user?.email ?? '';
  String? get avatarUrl => _user?.avatarUrl;

  String get memberSince {
    final user = _user;
    if (user == null) return '';
    return 'Na Carteira desde ${formatDate(user.createdAt)}';
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _coordinator.goToLogin();
  }
}
