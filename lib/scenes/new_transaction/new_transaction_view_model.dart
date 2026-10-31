import 'package:carteira_core/carteira_core.dart';
import 'package:carteira_design_system/carteira_design_system.dart'
    show TransactionKind;
import 'package:flutter/foundation.dart' show ChangeNotifier;

import 'new_transaction_coordinator.dart';

/// Estado e ações da cena de novo lançamento.
class NewTransactionViewModel extends ChangeNotifier {
  NewTransactionViewModel({
    required this._transactionRepository,
    required this._coordinator,
  });

  /// Contas e categorias do servidor (ver docs/api-contract.md).
  static const accounts = ['Nubank', 'Itaú', 'Carteira'];
  static const categories = [
    'Alimentação',
    'Transporte',
    'Moradia',
    'Lazer',
    'Saúde',
    'Educação',
    'Salário',
    'Outros',
  ];

  final TransactionRepository _transactionRepository;
  final NewTransactionCoordinator _coordinator;

  TransactionKind _kind = TransactionKind.expense;
  String _description = '';
  String _amount = '';
  String _account = accounts.first;
  String? _toAccount;
  String? _category;
  DateTime _date = DateTime.now();
  String _note = '';

  bool _isSaving = false;
  String? _descriptionError;
  String? _amountError;
  String? _toAccountError;
  String? _errorMessage;
  bool _disposed = false;

  TransactionKind get kind => _kind;
  String get account => _account;
  String? get toAccount => _toAccount;
  String? get category => _category;
  DateTime get date => _date;
  String get dateText => formatDate(_date);
  bool get isSaving => _isSaving;
  String? get descriptionError => _descriptionError;
  String? get amountError => _amountError;
  String? get toAccountError => _toAccountError;
  String? get errorMessage => _errorMessage;

  /// Contas possíveis como destino: qualquer uma, menos a de origem.
  List<String> get destinationAccounts =>
      [for (final name in accounts) if (name != _account) name];

  void onKindChanged(TransactionKind kind) {
    _kind = kind;
    _toAccountError = null;
    if (kind == TransactionKind.transfer) _category = null;
    _notify();
  }

  void onDescriptionChanged(String value) {
    _description = value;
    if (_descriptionError != null) {
      _descriptionError = null;
      _notify();
    }
  }

  void onAmountChanged(String value) {
    _amount = value;
    if (_amountError != null) {
      _amountError = null;
      _notify();
    }
  }

  void onAccountChanged(String value) {
    _account = value;
    if (_toAccount == value) _toAccount = null;
    _notify();
  }

  void onToAccountChanged(String? value) {
    _toAccount = value;
    _toAccountError = null;
    _notify();
  }

  void onCategoryChanged(String? value) {
    _category = value;
    _notify();
  }

  void onDateChanged(DateTime picked) {
    // Mantém a hora atual; o usuário só escolhe o dia.
    _date = DateTime(
      picked.year,
      picked.month,
      picked.day,
      _date.hour,
      _date.minute,
    );
    _notify();
  }

  void onNoteChanged(String value) {
    _note = value;
  }

  Future<void> save() async {
    if (_isSaving) return;

    _descriptionError = validateRequired(_description, field: 'A descrição');
    _amountError = validateAmount(_amount);
    _toAccountError = _kind == TransactionKind.transfer && _toAccount == null
        ? 'Escolha a conta de destino.'
        : null;
    if (_descriptionError != null ||
        _amountError != null ||
        _toAccountError != null) {
      _notify();
      return;
    }

    _isSaving = true;
    _errorMessage = null;
    _notify();

    final description = _description.trim();
    final note = _note.trim().isEmpty ? null : _note.trim();
    final amount = parseAmount(_amount)!;
    final Transaction transaction = switch (_kind) {
      TransactionKind.income => Income(
        id: '',
        amount: amount,
        description: description,
        date: _date,
        account: _account,
        category: _category,
        note: note,
      ),
      TransactionKind.expense => Expense(
        id: '',
        amount: amount,
        description: description,
        date: _date,
        account: _account,
        category: _category,
        note: note,
      ),
      TransactionKind.transfer => Transfer(
        id: '',
        amount: amount,
        description: description,
        date: _date,
        account: _account,
        toAccount: _toAccount!,
        note: note,
      ),
    };

    final result = await _transactionRepository.create(transaction);

    _isSaving = false;
    var created = false;
    result.when(
      ok: (_) {
        created = true;
      },
      failure: (error) {
        _errorMessage = error.message;
      },
    );
    if (created) {
      _coordinator.close(created: true);
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
