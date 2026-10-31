/// Navegação e ações para fora da cena de home.
abstract interface class HomeCoordinator {
  void toggleTheme();

  /// Abre o detalhe do lançamento [id]. Devolve true se ele foi excluído.
  Future<bool> openTransaction(String id);

  /// Abre o formulário de novo lançamento. Devolve true se criou um.
  Future<bool> openNewTransaction();
}

class DefaultHomeCoordinator implements HomeCoordinator {
  const DefaultHomeCoordinator({
    required this.onToggleTheme,
    required this.onOpenTransaction,
    required this.onOpenNewTransaction,
  });

  final void Function() onToggleTheme;
  final Future<bool> Function(String id) onOpenTransaction;
  final Future<bool> Function() onOpenNewTransaction;

  @override
  void toggleTheme() => onToggleTheme();

  @override
  Future<bool> openTransaction(String id) => onOpenTransaction(id);

  @override
  Future<bool> openNewTransaction() => onOpenNewTransaction();
}
