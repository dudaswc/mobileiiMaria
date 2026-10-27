/// Navegação para fora da cena de home.
abstract interface class HomeCoordinator {
  void goToLogin();
}

class DefaultHomeCoordinator implements HomeCoordinator {
  const DefaultHomeCoordinator({required this.onLogout});

  final void Function() onLogout;

  @override
  void goToLogin() => onLogout();
}