/// Navegação e ações para fora da cena de home.
abstract interface class HomeCoordinator {
  void toggleTheme();

  /// Abre o detalhe do lançamento [id]. Devolve true se ele foi excluído.
  Future<bool> openTransaction(String id);
}

class DefaultHomeCoordinator implements HomeCoordinator {
  const DefaultHomeCoordinator({
    required this.onToggleTheme,
    required this.onOpenTransaction,
  });

  final void Function() onToggleTheme;
  final Future<bool> Function(String id) onOpenTransaction;

  @override
  void toggleTheme() => onToggleTheme();

  @override
  Future<bool> openTransaction(String id) => onOpenTransaction(id);
}
