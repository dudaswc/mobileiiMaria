import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import 'transaction_detail_view_model.dart';

class TransactionDetailView extends StatefulWidget {
  const TransactionDetailView({required this.viewModel, super.key});

  final TransactionDetailViewModel viewModel;

  @override
  State<TransactionDetailView> createState() => _TransactionDetailViewState();
}

class _TransactionDetailViewState extends State<TransactionDetailView> {
  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir lançamento?'),
        content: const Text('Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            key: const Key('detail_confirm_delete'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await widget.viewModel.delete();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => AppScaffold(
        title: 'Lançamento',
        actions: [
          if (viewModel.status == TransactionDetailStatus.ready)
            IconButton(
              key: const Key('detail_delete'),
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Excluir',
              onPressed: viewModel.isDeleting ? null : _confirmDelete,
            ),
        ],
        body: switch (viewModel.status) {
          TransactionDetailStatus.loading => const StateView.loading(),
          TransactionDetailStatus.failure => StateView.error(
            message:
                viewModel.errorMessage ??
                'Não foi possível carregar o lançamento.',
            onRetry: viewModel.load,
          ),
          TransactionDetailStatus.ready => _Content(viewModel: viewModel),
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.viewModel});

  final TransactionDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = context.semanticColors.muted;
    final tone = switch (viewModel.kind) {
      TransactionKind.income => MoneyTone.income,
      TransactionKind.expense => MoneyTone.expense,
      TransactionKind.transfer => MoneyTone.neutral,
    };
    final note = viewModel.note;

    return ListView(
      children: [
        const Gap.lg(),
        TransactionTile(
          kind: viewModel.kind,
          title: viewModel.title,
          subtitle: viewModel.kindLabel,
          amount: viewModel.amountText,
        ),
        const Gap.lg(),
        MoneyText(
          viewModel.amountText,
          tone: tone,
          size: MoneySize.large,
          signed: true,
        ),
        const Gap.xl(),
        _DetailRow(label: 'Data', value: viewModel.dateText),
        _DetailRow(label: 'Conta', value: viewModel.accountText),
        _DetailRow(label: 'Categoria', value: viewModel.categoryText),
        _DetailRow(
          label: 'Observação',
          value: note ?? 'Sem observação',
          italic: note == null,
        ),
        const Gap.xl(),
        Text(
          viewModel.idText,
          style: theme.textTheme.bodySmall?.copyWith(color: muted),
        ),
        if (viewModel.errorMessage != null) ...[
          const Gap.md(),
          Text(
            viewModel.errorMessage!,
            key: const Key('detail_error'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.italic = false,
  });

  final String label;
  final String value;
  final bool italic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = context.semanticColors.muted;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontStyle: italic ? FontStyle.italic : FontStyle.normal,
                color: italic ? muted : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
