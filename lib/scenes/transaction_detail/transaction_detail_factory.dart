import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/widgets.dart';

import 'transaction_detail_coordinator.dart';
import 'transaction_detail_view.dart';
import 'transaction_detail_view_model.dart';

/// Monta a cena de detalhe, injetando as dependências no ViewModel.
abstract final class TransactionDetailFactory {
  static Widget make({
    required TransactionRepository transactionRepository,
    required String transactionId,
    required void Function(bool deleted) onClose,
  }) {
    final viewModel = TransactionDetailViewModel(
      transactionRepository: transactionRepository,
      coordinator: DefaultTransactionDetailCoordinator(onClose: onClose),
      transactionId: transactionId,
    )..load();
    return TransactionDetailView(viewModel: viewModel);
  }
}
