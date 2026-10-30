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
      actions: [
        IconButton(
          key: const Key('home_logout'),
          icon: const Icon(Icons.logout),
          tooltip: 'Sair',
          onPressed: viewModel.logout,
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
              for (final day in viewModel.days) ...[
                SectionHeader(title: day.heading),
                for (final row in day.rows)
                  TransactionTile(
                    kind: row.kind,
                    title: row.title,
                    subtitle: row.subtitle,
                    amount: row.amountText,
                  ),
              ],
            ],
          ),
        },
      ),
    );
  }
}
