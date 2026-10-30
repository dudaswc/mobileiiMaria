import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;

import 'home_coordinator.dart';

enum HomeStatus { loading, ready, failure }

/// Uma linha da lista "Gastos por categoria", já pronta para exibir.
class CategorySpending {
  const CategorySpending({
    required this.label,
    required this.amountText,
    required this.share,
  });

  final String label;
  final String amountText;

  /// Fração do total de despesas, de 0 a 1.
  final double share;
}

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
  List<CategorySpending> _categories = const [];
  String? _errorMessage;
  bool _disposed = false;

  HomeStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get userName => _authRepository.currentSession?.user.name ?? '';
  String get monthLabel => formatMonthKey(_month);
  List<CategorySpending> get categories => _categories;

  String get balanceText => _money.format(_summary?.balance ?? 0);
  String get incomeText => _money.format(_summary?.income ?? 0);
  String get expenseText => _money.format(_summary?.expense ?? 0);

  Future<void> load() async {
    _status = HomeStatus.loading;
    _notify();

    final summaryResult = await _transactionRepository.summary(_month);
    final expensesResult = await _transactionRepository.list(
      const TransactionFilter(
        month: _month,
        type: TransactionType.expense,
        pageSize: 100,
      ),
    );

    String? error;
    summaryResult.when(
      ok: (_) {},
      failure: (e) {
        error = e.message;
      },
    );
    expensesResult.when(
      ok: (_) {},
      failure: (e) {
        error ??= e.message;
      },
    );

    final summary = summaryResult.valueOrNull;
    final expenses = expensesResult.valueOrNull;
    if (error != null || summary == null || expenses == null) {
      _errorMessage = error ?? 'Não foi possível carregar.';
      _status = HomeStatus.failure;
    } else {
      _summary = summary;
      _categories = _buildCategories(expenses.items);
      _status = HomeStatus.ready;
    }
    _notify();
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _coordinator.goToLogin();
  }

  /// Soma as despesas por categoria, da maior para a menor.
  List<CategorySpending> _buildCategories(List<Transaction> expenses) {
    final grouped = groupBy(
      expenses,
      (Transaction t) => t.category ?? 'Sem categoria',
    );
    final totals = {
      for (final entry in grouped.entries)
        entry.key: entry.value.fold<double>(0, (sum, t) => sum + t.amount),
    };
    final total = totals.values.fold<double>(0, (sum, value) => sum + value);
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [
      for (final entry in sorted)
        CategorySpending(
          label: entry.key,
          amountText: _money.format(entry.value),
          share: total == 0 ? 0 : entry.value / total,
        ),
    ];
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
