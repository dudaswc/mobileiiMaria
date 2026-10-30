import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/widgets.dart';

import 'home_coordinator.dart';
import 'home_view.dart';
import 'home_view_model.dart';

/// Monta a cena de home, injetando as dependências no ViewModel.
abstract final class HomeFactory {
  static Widget make({
    required AuthRepository authRepository,
    required TransactionRepository transactionRepository,
    required void Function() onLogout,
  }) {
    final viewModel = HomeViewModel(
      authRepository: authRepository,
      transactionRepository: transactionRepository,
      coordinator: DefaultHomeCoordinator(onLogout: onLogout),
    )..load();
    return HomeView(viewModel: viewModel);
  }
}
