import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import 'home_view_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({required this.viewModel, super.key});

  final HomeViewModel viewModel;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;

    return AppScaffold(
      title: 'Carteira',
      floatingActionButton: FloatingActionButton(
        key: const Key('home_add'),
        onPressed: viewModel.onAddTap,
        tooltip: 'Novo lançamento',
        child: const Icon(Icons.add),
      ),
      actions: [
        IconButton(
          key: const Key('home_theme'),
          icon: const Icon(Icons.brightness_6_outlined),
          tooltip: 'Alternar tema',
          onPressed: viewModel.toggleTheme,
        ),
      ],
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => switch (viewModel.status) {
          HomeStatus.loading => const StateView.loading(),
          HomeStatus.failure => StateView.error(
            message: viewModel.errorMessage ?? 'Não foi possível carregar.',
            onRetry: viewModel.load,
          ),
          HomeStatus.ready => ListView(
            children: [
              BalanceCard(
                balance: viewModel.balanceText,
                income: viewModel.incomeText,
                expense: viewModel.expenseText,
                monthLabel: viewModel.monthLabel,
              ),
              if (viewModel.categories.isNotEmpty) ...[
                const SectionHeader(title: 'Gastos por categoria'),
                for (final category in viewModel.categories)
                  CategoryBar(
                    label: category.label,
                    amount: category.amountText,
                    share: category.share,
                  ),
              ],
              const Gap.xl(),
              AppTextField(
                key: const Key('home_search'),
                label: 'Buscar por descrição',
                prefixIcon: Icons.search,
                textInputAction: TextInputAction.search,
                onChanged: viewModel.onQueryChanged,
              ),
              const Gap.md(),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<HomeFilter>(
                  key: const Key('home_filter'),
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment<HomeFilter>(
                      value: HomeFilter.all,
                      label: Text('Todos'),
                    ),
                    ButtonSegment<HomeFilter>(
                      value: HomeFilter.income,
                      label: Text('Receita'),
                    ),
                    ButtonSegment<HomeFilter>(
                      value: HomeFilter.expense,
                      label: Text('Despesa'),
                    ),
                    ButtonSegment<HomeFilter>(
                      value: HomeFilter.transfer,
                      label: Text('Transf.'),
                    ),
                  ],
                  selected: {viewModel.filter},
                  onSelectionChanged: (selection) =>
                      viewModel.onFilterChanged(selection.first),
                ),
              ),
              if (viewModel.days.isEmpty)
                const SizedBox(
                  height: 240,
                  child: StateView.empty(
                    message: 'Nenhum lançamento encontrado',
                  ),
                ),
              for (final day in viewModel.days) ...[
                SectionHeader(title: day.heading),
                for (final row in day.rows)
                  TransactionTile(
                    kind: row.kind,
                    title: row.title,
                    subtitle: row.subtitle,
                    amount: row.amountText,
                    onTap: () => viewModel.onTransactionTap(row.id),
                  ),
              ],
            ],
          ),
        },
      ),
    );
  }
}
