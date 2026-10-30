import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/widgets.dart';

import 'profile_coordinator.dart';
import 'profile_view.dart';
import 'profile_view_model.dart';

/// Monta a cena de perfil, injetando as dependências no ViewModel.
abstract final class ProfileFactory {
  static Widget make({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required void Function() onLogout,
  }) {
    final viewModel = ProfileViewModel(
      authRepository: authRepository,
      userRepository: userRepository,
      coordinator: DefaultProfileCoordinator(onLogout: onLogout),
    )..load();
    return ProfileView(viewModel: viewModel);
  }
}
