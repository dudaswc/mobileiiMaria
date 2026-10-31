import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/widgets.dart';

import '../home/home_factory.dart';
import '../profile/profile_factory.dart';
import 'main_view.dart';

/// Monta a estrutura principal do app, com as cenas de cada aba.
abstract final class MainFactory {
  static Widget make({
    required AuthRepository authRepository,
    required TransactionRepository transactionRepository,
    required UserRepository userRepository,
    required void Function() onLogout,
    required void Function() onToggleTheme,
    required Future<bool> Function(String id) onOpenTransaction,
    required Future<bool> Function() onOpenNewTransaction,
  }) {
    return MainView(
      home: HomeFactory.make(
        transactionRepository: transactionRepository,
        onToggleTheme: onToggleTheme,
        onOpenTransaction: onOpenTransaction,
        onOpenNewTransaction: onOpenNewTransaction,
      ),
      profile: ProfileFactory.make(
        authRepository: authRepository,
        userRepository: userRepository,
        onLogout: onLogout,
      ),
    );
  }
}
