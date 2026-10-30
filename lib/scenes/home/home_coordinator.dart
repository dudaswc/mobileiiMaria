/// Navegação e ações para fora da cena de home.
abstract interface class HomeCoordinator {
  void toggleTheme();
}

class DefaultHomeCoordinator implements HomeCoordinator {
  const DefaultHomeCoordinator({required this.onToggleTheme});

  final void Function() onToggleTheme;

  @override
  void toggleTheme() => onToggleTheme();
}
