import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/foundation.dart';

import 'home_coordinator.dart';

/// Estado e ações da cena de home (provisória, será expandida).
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required this._authRepository,
    required this._coordinator,
  });

  final AuthRepository _authRepository;
  final HomeCoordinator _coordinator;

  String get userName => _authRepository.currentSession?.user.name ?? '';

  Future<void> logout() async {
    await _authRepository.logout();
    _coordinator.goToLogin();
  }
}
