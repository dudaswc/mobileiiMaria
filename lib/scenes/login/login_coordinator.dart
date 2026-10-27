/// Navegação para fora da cena de login.
abstract interface class LoginCoordinator {
  void goToHome();
}

class DefaultLoginCoordinator implements LoginCoordinator {
  const DefaultLoginCoordinator({required this.onLoginSuccess});

  final void Function() onLoginSuccess;

  @override
  void goToHome() => onLoginSuccess();
}