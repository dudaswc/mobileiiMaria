/// Navegação para fora da cena de perfil.
abstract interface class ProfileCoordinator {
  void goToLogin();
}

class DefaultProfileCoordinator implements ProfileCoordinator {
  const DefaultProfileCoordinator({required this.onLogout});

  final void Function() onLogout;

  @override
  void goToLogin() => onLogout();
}
