import 'dart:async';

import 'package:carteira_core/carteira_core.dart';
import 'package:carteira_design_system/carteira_design_system.dart'
    show TransactionKind;
import 'package:flutter/foundation.dart' show ChangeNotifier;

import 'home_coordinator.dart';

enum HomeStatus { loading, ready, failure }

/// Filtro por tipo de lançamento, como aparece na tela.
enum HomeFilter { all, income, expense, transfer }

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

/// Um lançamento da lista, já pronto para exibir.
class TransactionRow {
  const TransactionRow({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.amountText,
  });

  final String id;
  final TransactionKind kind;
  final String title;
  final String subtitle;
  final String amountText;
}

/// Lançamentos de um mesmo dia, com o título do grupo.
class DayGroup {
  const DayGroup({required this.heading, required this.rows});

  final String heading;
  final List<TransactionRow> rows;
}

/// Estado e ações da cena de home.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required this._transactionRepository,
    required this._coordinator,
  });

  final TransactionRepository _transactionRepository;
  final HomeCoordinator _coordinator;

  /// Mês mostrado. Fixo em setembro porque é onde estão os dados de exemplo
  /// do servidor; troque por o mês atual quando houver dados nele.
  static const _month = '2026-09';

  final _money = MoneyFormatter.forCurrency(Currency.brl);

  HomeStatus _status = HomeStatus.loading;
  Summary? _summary;
  List<CategorySpending> _categories = const [];
  List<DayGroup> _days = const [];
  String? _errorMessage;
  bool _disposed = false;

  String _query = '';
  HomeFilter _filter = HomeFilter.all;
  Timer? _debounce;
  int _listRequest = 0;

  HomeStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get monthLabel => formatMonthKey(_month);
  List<CategorySpending> get categories => _categories;
  List<DayGroup> get days => _days;
  HomeFilter get filter => _filter;

  String get balanceText => _money.format(_summary?.balance ?? 0);
  String get incomeText => _money.format(_summary?.income ?? 0);
  String get expenseText => _money.format(_summary?.expense ?? 0);

  Future<void> load() async {
    _debounce?.cancel();
    _listRequest++;
    _query = '';
    _filter = HomeFilter.all;
    _status = HomeStatus.loading;
    _notify();

    final summaryResult = await _transactionRepository.summary(_month);
    final listResult = await _transactionRepository.list(
      const TransactionFilter(month: _month, pageSize: 100),
    );

    String? error;
    summaryResult.when(
      ok: (_) {},
      failure: (e) {
        error = e.message;
      },
    );
    listResult.when(
      ok: (_) {},
      failure: (e) {
        error ??= e.message;
      },
    );

    final summary = summaryResult.valueOrNull;
    final page = listResult.valueOrNull;
    if (error != null || summary == null || page == null) {
      _errorMessage = error ?? 'Não foi possível carregar.';
      _status = HomeStatus.failure;
    } else {
      _summary = summary;
      _categories = _buildCategories(page.items.whereType<Expense>());
      _days = _buildDays(page.items);
      _status = HomeStatus.ready;
    }
    _notify();
  }

  /// Chamado a cada letra digitada; só busca depois de uma pausa.
  void onQueryChanged(String value) {
    _query = value.trim();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _reloadList);
  }

  void onFilterChanged(HomeFilter filter) {
    _filter = filter;
    _notify();
    _reloadList();
  }

  void toggleTheme() => _coordinator.toggleTheme();

  /// Busca de novo só a lista, respeitando a busca e o filtro atuais.
  Future<void> _reloadList() async {
    final request = ++_listRequest;
    final result = await _transactionRepository.list(
      TransactionFilter(
        month: _month,
        type: _typeOf(_filter),
        query: _query.isEmpty ? null : _query,
        pageSize: 100,
      ),
    );
    // Uma busca mais nova já foi pedida: esta resposta ficou velha.
    if (request != _listRequest) return;

    result.when(
      ok: (page) {
        _days = _buildDays(page.items);
      },
      failure: (e) {
        _errorMessage = e.message;
        _status = HomeStatus.failure;
      },
    );
    _notify();
  }

  TransactionType? _typeOf(HomeFilter filter) => switch (filter) {
    HomeFilter.all => null,
    HomeFilter.income => TransactionType.income,
    HomeFilter.expense => TransactionType.expense,
    HomeFilter.transfer => TransactionType.transfer,
  };

  /// Soma as despesas por categoria, da maior para a menor.
  List<CategorySpending> _buildCategories(Iterable<Expense> expenses) {
    final grouped = groupBy(
      expenses,
      (Expense t) => t.category ?? 'Sem categoria',
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

  /// Agrupa os lançamentos por dia, do mais recente para o mais antigo.
  List<DayGroup> _buildDays(List<Transaction> transactions) {
    final sorted = [...transactions]..sort((a, b) => b.date.compareTo(a.date));
    final grouped = groupBy(sorted, (Transaction t) {
      final local = t.date.toLocal();
      return DateTime(local.year, local.month, local.day);
    });
    return [
      for (final entry in grouped.entries)
        DayGroup(
          heading: formatDayHeading(entry.key),
          rows: [for (final t in entry.value) _toRow(t)],
        ),
    ];
  }

  TransactionRow _toRow(Transaction t) {
    final (kind, subtitle) = switch (t) {
      Income() => (TransactionKind.income, _describe(t.category, t.account)),
      Expense() => (TransactionKind.expense, _describe(t.category, t.account)),
      Transfer(:final toAccount) => (
        TransactionKind.transfer,
        '${t.account} → $toAccount',
      ),
    };
    return TransactionRow(
      id: t.id,
      kind: kind,
      title: t.description,
      subtitle: subtitle,
      amountText: _money.format(t.amount),
    );
  }

  String _describe(String? category, String account) =>
      '${category ?? 'Sem categoria'} · $account';

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    super.dispose();
  }
}
