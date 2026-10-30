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

    return AppScaffold(
      title: 'Perfil',
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => switch (viewModel.status) {
          ProfileStatus.loading => const StateView.loading(),
          ProfileStatus.failure => StateView.error(
            message:
                viewModel.errorMessage ?? 'Não foi possível carregar o perfil.',
            onRetry: viewModel.load,
          ),
          ProfileStatus.ready => _ProfileForm(viewModel: viewModel),
        },
      ),
    );
  }
}

/// Só existe quando o perfil já carregou: os campos nascem com os valores
/// do servidor e depois pertencem a quem está digitando.
class _ProfileForm extends StatefulWidget {
  const _ProfileForm({required this.viewModel});

  final ProfileViewModel viewModel;

  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  late final _nameController = TextEditingController(
    text: widget.viewModel.formName,
  );
  late final _photoController = TextEditingController(
    text: widget.viewModel.formAvatarUrl,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final theme = Theme.of(context);
    final semantic = context.semanticColors;

    return ListView(
      children: [
        const Gap.xl(),
        Center(
          child: AppAvatar(
            name: viewModel.displayName,
            imageUrl: viewModel.avatarUrl,
            size: 96,
          ),
        ),
        const Gap.md(),
        Text(
          viewModel.displayName,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge,
        ),
        const Gap.xs(),
        Text(
          viewModel.email,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: semantic.muted),
        ),
        const Gap.xs(),
        Text(
          viewModel.memberSince,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(color: semantic.muted),
        ),
        const SectionHeader(title: 'Dados'),
        AppTextField(
          key: const Key('profile_name'),
          controller: _nameController,
          label: 'Nome',
          prefixIcon: Icons.person_outline,
          errorText: viewModel.nameError,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onChanged: viewModel.onNameChanged,
        ),
        const Gap.md(),
        AppTextField(
          key: const Key('profile_photo'),
          controller: _photoController,
          label: 'URL da foto',
          prefixIcon: Icons.image_outlined,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.done,
          onChanged: viewModel.onAvatarUrlChanged,
          onSubmitted: (_) => viewModel.save(),
        ),
        if (viewModel.errorMessage != null) ...[
          const Gap.md(),
          Text(
            viewModel.errorMessage!,
            key: const Key('profile_error'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        if (viewModel.message != null) ...[
          const Gap.md(),
          Text(
            viewModel.message!,
            key: const Key('profile_message'),
            style: theme.textTheme.bodyMedium?.copyWith(color: semantic.income),
          ),
        ],
        const Gap.xl(),
        AppButton(
          key: const Key('profile_save'),
          label: 'Salvar',
          isLoading: viewModel.isSaving,
          onPressed: viewModel.save,
        ),
        const Gap.md(),
        AppButton.secondary(
          key: const Key('profile_logout'),
          label: 'Sair da conta',
          icon: Icons.logout,
          onPressed: viewModel.logout,
        ),
        const Gap.xl(),
      ],
    );
  }
}
