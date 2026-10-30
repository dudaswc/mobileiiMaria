import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

/// Estrutura com a barra de abas: Lançamentos e Perfil.
///
/// As duas abas ficam vivas ao mesmo tempo (IndexedStack), então trocar de
/// aba não perde a busca nem a posição da lista.
class MainView extends StatefulWidget {
  const MainView({required this.home, required this.profile, super.key});

  final Widget home;
  final Widget profile;

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: false,
      padded: false,
      bottom: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Lançamentos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: [widget.home, widget.profile],
      ),
    );
  }
}
