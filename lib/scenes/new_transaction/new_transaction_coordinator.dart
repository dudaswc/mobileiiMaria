/// Navegação para fora da cena de novo lançamento.
abstract interface class NewTransactionCoordinator {
  /// [created] avisa a tela anterior que ela precisa recarregar a lista.
  void close({required bool created});
}

class DefaultNewTransactionCoordinator implements NewTransactionCoordinator {
  const DefaultNewTransactionCoordinator({required this.onClose});

  final void Function(bool created) onClose;

  @override
  void close({required bool created}) => onClose(created);
}
