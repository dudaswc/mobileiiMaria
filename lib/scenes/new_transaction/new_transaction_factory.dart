import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/widgets.dart';

import 'new_transaction_coordinator.dart';
import 'new_transaction_view.dart';
import 'new_transaction_view_model.dart';

/// Monta a cena de novo lançamento, injetando as dependências no ViewModel.
abstract final class NewTransactionFactory {
  static Widget make({
    required TransactionRepository transactionRepository,
    required void Function(bool created) onClose,
  }) {
    final viewModel = NewTransactionViewModel(
      transactionRepository: transactionRepository,
      coordinator: DefaultNewTransactionCoordinator(onClose: onClose),
    );
    return NewTransactionView(viewModel: viewModel);
  }
}
