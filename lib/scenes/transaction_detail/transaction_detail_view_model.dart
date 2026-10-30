import 'package:carteira_core/carteira_core.dart';
import 'package:carteira_design_system/carteira_design_system.dart'
    show TransactionKind;
import 'package:flutter/foundation.dart' show ChangeNotifier;

import 'transaction_detail_coordinator.dart';

enum TransactionDetailStatus { loading, ready, failure }

/// Estado e ações da cena de detalhe do lançamento.
class TransactionDetailViewModel extends ChangeNotifier {
  TransactionDetailViewModel({
    required this._transactionRepository,
    required this._coordinator,
    required this.transactionId,
  });

  final TransactionRepository _transactionRepository;
  final TransactionDetailCoordinator _coordinator;
  final String transactionId;

  final _money = MoneyFormatter.forCurrency(Currency.brl);

  TransactionDetailStatus _status = TransactionDetailStatus.loading;
  Transaction? _transaction;
  bool _isDeleting = false;
  String? _errorMessage;
  bool _disposed = false;

  TransactionDetailStatus get status => _status;
  bool get isDeleting => _isDeleting;
  String? get errorMessage => _errorMessage;

  TransactionKind get kind => switch (_transaction) {
    Income() => TransactionKind.income,
    Transfer() => TransactionKind.transfer,
    Expense() || null => TransactionKind.expense,
  };

  String get kindLabel => switch (kind) {
    TransactionKind.income => 'Receita',
    TransactionKind.expense => 'Despesa',
    TransactionKind.transfer => 'Transferência',
  };

  String get title => _transaction?.description ?? '';
  String get amountText => _money.format(_transaction?.amount ?? 0);

  String get dateText {
    final transaction = _transaction;
    return transaction == null ? '' : formatDateTime(transaction.date);
  }

  String get accountText {
    final transaction = _transaction;
    if (transaction == null) return '';
    if (transaction is Transfer) {
      return '${transaction.account} → ${transaction.toAccount}';
    }
    return transaction.account;
  }

  String get categoryText => _transaction?.category ?? 'Sem categoria';

  /// Null quando não há observação.
  String? get note {
    final value = _transaction?.note;
    if (value == null || value.trim().isEmpty) return null;
    return value;
  }

  String get idText => 'ID ${_transaction?.id ?? transactionId}';

  Future<void> load() async {
    _status = TransactionDetailStatus.loading;
    _errorMessage = null;
    _notify();

    final result = await _transactionRepository.getById(transactionId);
    result.when(
      ok: (transaction) {
        _transaction = transaction;
        _status = TransactionDetailStatus.ready;
      },
      failure: (error) {
        _errorMessage = error.message;
        _status = TransactionDetailStatus.failure;
      },
    );
    _notify();
  }

  Future<void> delete() async {
    if (_isDeleting) return;
    _isDeleting = true;
    _errorMessage = null;
    _notify();

    final result = await _transactionRepository.delete(transactionId);

    _isDeleting = false;
    var deleted = false;
    result.when(
      ok: (_) {
        deleted = true;
      },
      failure: (error) {
        _errorMessage = error.message;
      },
    );
    if (deleted) {
      _coordinator.close(deleted: true);
      return;
    }
    _notify();
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
