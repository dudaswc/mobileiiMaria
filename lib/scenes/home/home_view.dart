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
      body: Center(
        child: Text(
          'Olá, ${viewModel.userName}!',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}