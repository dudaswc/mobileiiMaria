/// Navegação para fora da cena de detalhe do lançamento.
abstract interface class TransactionDetailCoordinator {
  /// [deleted] avisa a tela anterior que ela precisa recarregar a lista.
  void close({required bool deleted});
}

class DefaultTransactionDetailCoordinator
    implements TransactionDetailCoordinator {
  const DefaultTransactionDetailCoordinator({required this.onClose});

  final void Function(bool deleted) onClose;

  @override
  void close({required bool deleted}) => onClose(deleted);
}
