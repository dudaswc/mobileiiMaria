import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;

import 'home_coordinator.dart';

enum HomeStatus { loading, ready, failure }

/// Estado e ações da cena de home.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required this._authRepository,
    required this._transactionRepository,
    required this._coordinator,
  });

  final AuthRepository _authRepository;
  final TransactionRepository _transactionRepository;
  final HomeCoordinator _coordinator;

  /// Mês mostrado. Fixo em setembro porque é onde estão os dados de exemplo
  /// do servidor; troque por o mês atual quando houver dados nele.
  static const _month = '2026-09';

  final _money = MoneyFormatter.forCurrency(Currency.brl);

  HomeStatus _status = HomeStatus.loading;
  Summary? _summary;
  String? _errorMessage;
  bool _disposed = false;

  HomeStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get userName => _authRepository.currentSession?.user.name ?? '';
  String get monthLabel => formatMonthKey(_month);

  String get balanceText => _money.format(_summary?.balance ?? 0);
  String get incomeText => _money.format(_summary?.income ?? 0);
  String get expenseText => _money.format(_summary?.expense ?? 0);

  Future<void> load() async {
    _status = HomeStatus.loading;
    _notify();

    final result = await _transactionRepository.summary(_month);
    result.when(
      ok: (summary) {
        _summary = summary;
        _status = HomeStatus.ready;
      },
      failure: (error) {
        _errorMessage = error.message;
        _status = HomeStatus.failure;
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
