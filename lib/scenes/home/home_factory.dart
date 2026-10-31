import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/widgets.dart';

import 'home_coordinator.dart';
import 'home_view.dart';
import 'home_view_model.dart';

/// Monta a cena de home, injetando as dependências no ViewModel.
abstract final class HomeFactory {
  static Widget make({
    required TransactionRepository transactionRepository,
    required void Function() onToggleTheme,
    required Future<bool> Function(String id) onOpenTransaction,
    required Future<bool> Function() onOpenNewTransaction,
  }) {
    final viewModel = HomeViewModel(
      transactionRepository: transactionRepository,
      coordinator: DefaultHomeCoordinator(
        onToggleTheme: onToggleTheme,
        onOpenTransaction: onOpenTransaction,
        onOpenNewTransaction: onOpenNewTransaction,
      ),
    )..load();
    return HomeView(viewModel: viewModel);
  }
}
