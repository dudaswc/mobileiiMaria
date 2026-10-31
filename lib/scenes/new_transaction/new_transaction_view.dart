import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import 'new_transaction_view_model.dart';

class NewTransactionView extends StatefulWidget {
  const NewTransactionView({required this.viewModel, super.key});

  final NewTransactionViewModel viewModel;

  @override
  State<NewTransactionView> createState() => _NewTransactionViewState();
}

class _NewTransactionViewState extends State<NewTransactionView> {
  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.viewModel.date,
      firstDate: DateTime(2024),
      lastDate: DateTime(2027, 12, 31),
    );
    if (picked != null) widget.viewModel.onDateChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final theme = Theme.of(context);
    final semantic = context.semanticColors;
    final isTransfer = viewModel.kind == TransactionKind.transfer;

    return AppScaffold(
      title: 'Novo lançamento',
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => ListView(
          children: [
            const Gap.lg(),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<TransactionKind>(
                key: const Key('new_kind'),
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment<TransactionKind>(
                    value: TransactionKind.expense,
                    label: Text('Despesa'),
                  ),
                  ButtonSegment<TransactionKind>(
                    value: TransactionKind.income,
                    label: Text('Receita'),
                  ),
                  ButtonSegment<TransactionKind>(
                    value: TransactionKind.transfer,
                    label: Text('Transf.'),
                  ),
                ],
                selected: {viewModel.kind},
                onSelectionChanged: (selection) =>
                    viewModel.onKindChanged(selection.first),
              ),
            ),
            const Gap.lg(),
            AppTextField(
              key: const Key('new_description'),
              label: 'Descrição',
              prefixIcon: Icons.edit_outlined,
              errorText: viewModel.descriptionError,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              onChanged: viewModel.onDescriptionChanged,
            ),
            const Gap.md(),
            AppTextField(
              key: const Key('new_amount'),
              label: 'Valor',
              hint: '0,00',
              prefixIcon: Icons.attach_money,
              errorText: viewModel.amountError,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              onChanged: viewModel.onAmountChanged,
            ),
            const Gap.md(),
            DropdownButtonFormField<String>(
              key: ValueKey('new_account_${viewModel.account}'),
              initialValue: viewModel.account,
              decoration: InputDecoration(
                labelText: isTransfer ? 'Conta de origem' : 'Conta',
                prefixIcon: const Icon(Icons.account_balance_outlined),
              ),
              items: [
                for (final name in NewTransactionViewModel.accounts)
                  DropdownMenuItem(value: name, child: Text(name)),
              ],
              onChanged: (value) {
                if (value != null) viewModel.onAccountChanged(value);
              },
            ),
            const Gap.md(),
            if (isTransfer)
              DropdownButtonFormField<String>(
                key: ValueKey(
                  'new_to_${viewModel.account}_${viewModel.toAccount}',
                ),
                initialValue: viewModel.toAccount,
                decoration: InputDecoration(
                  labelText: 'Conta de destino',
                  prefixIcon: const Icon(Icons.swap_horiz),
                  errorText: viewModel.toAccountError,
                ),
                items: [
                  for (final name in viewModel.destinationAccounts)
                    DropdownMenuItem(value: name, child: Text(name)),
                ],
                onChanged: viewModel.onToAccountChanged,
              )
            else
              DropdownButtonFormField<String?>(
                key: ValueKey('new_category_${viewModel.category}'),
                initialValue: viewModel.category,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  prefixIcon: Icon(Icons.label_outline),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    child: Text('Sem categoria'),
                  ),
                  for (final name in NewTransactionViewModel.categories)
                    DropdownMenuItem<String?>(value: name, child: Text(name)),
                ],
                onChanged: viewModel.onCategoryChanged,
              ),
            const Gap.md(),
            ListTile(
              key: const Key('new_date'),
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(viewModel.dateText),
              subtitle: Text(
                'Data',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: semantic.muted,
                ),
              ),
              onTap: _pickDate,
            ),
            const Gap.md(),
            AppTextField(
              key: const Key('new_note'),
              label: 'Observação (opcional)',
              prefixIcon: Icons.notes_outlined,
              textCapitalization: TextCapitalization.sentences,
              onChanged: viewModel.onNoteChanged,
            ),
            if (viewModel.errorMessage != null) ...[
              const Gap.md(),
              Text(
                viewModel.errorMessage!,
                key: const Key('new_error'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const Gap.xl(),
            AppButton(
              key: const Key('new_save'),
              label: 'Salvar',
              isLoading: viewModel.isSaving,
              onPressed: viewModel.save,
            ),
            const Gap.xl(),
          ],
        ),
      ),
    );
  }
}
