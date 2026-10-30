import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import 'profile_view_model.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({required this.viewModel, super.key});

  final ProfileViewModel viewModel;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final theme = Theme.of(context);
    final muted = context.semanticColors.muted;

    return AppScaffold(
      title: 'Perfil',
      body: ListView(
        children: [
          const Gap.xl(),
          Center(
            child: AppAvatar(
              name: viewModel.name,
              imageUrl: viewModel.avatarUrl,
              size: 96,
            ),
          ),
          const Gap.md(),
          Text(
            viewModel.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          const Gap.xs(),
          Text(
            viewModel.email,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: muted),
          ),
          const Gap.xs(),
          Text(
            viewModel.memberSince,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
          const Gap.xxl(),
          AppButton.secondary(
            key: const Key('profile_logout'),
            label: 'Sair da conta',
            icon: Icons.logout,
            onPressed: viewModel.logout,
          ),
        ],
      ),
    );
  }
}
