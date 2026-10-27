import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/widgets.dart';

import 'login_coordinator.dart';
import 'login_view.dart';
import 'login_view_model.dart';

/// Monta a cena de login, injetando as dependências no ViewModel.
abstract final class LoginFactory {
  static Widget make({
    required AuthRepository authRepository,
    required void Function() onLoginSuccess,
  }) {
    final viewModel = LoginViewModel(
      authRepository: authRepository,
      coordinator: DefaultLoginCoordinator(onLoginSuccess: onLoginSuccess),
    );
    return LoginView(viewModel: viewModel);
  }
}