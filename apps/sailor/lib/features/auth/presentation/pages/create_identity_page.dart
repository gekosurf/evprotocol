import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sailor/core/router/app_router.dart';
import 'package:sailor/core/theme/app_colors.dart';
import 'package:sailor/core/theme/app_text_styles.dart';
import 'package:sailor/features/auth/presentation/providers/auth_providers.dart';

/// Create Identity page — step 2 of onboarding.
class CreateIdentityPage extends ConsumerStatefulWidget {
  const CreateIdentityPage({super.key});

  @override
  ConsumerState<CreateIdentityPage> createState() =>
      _CreateIdentityPageState();
}

class _CreateIdentityPageState extends ConsumerState<CreateIdentityPage> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _createIdentity() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref.read(createIdentityProvider.notifier).create(
            displayName: _nameController.text,
            bio: _bioController.text.isEmpty ? null : _bioController.text,
          );

      // Get backup key and navigate
      final backupKey =
          await ref.read(getBackupKeyUseCaseProvider).call();

      if (mounted) {
        context.go(AppRoutes.backupKey, extra: backupKey);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createIdentityProvider);
    final isLoading = createState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Identity'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Avatar placeholder
                Center(
                  child: GestureDetector(
                    onTap: () {
                      // TODO: Avatar picker
                    },
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBg,
                        borderRadius: BorderRadius.circular(44),
                        border: Border.all(
                          color: AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_add,
                        size: 36,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Tap to add photo',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Display name
                const Text('DISPLAY NAME', style: AppTextStyles.label),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  style: AppTextStyles.body,
                  decoration: const InputDecoration(
                    hintText: 'How others will see you',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    if (value.trim().length > 64) {
                      return '64 characters max';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Bio (optional)
                const Text('BIO (OPTIONAL)', style: AppTextStyles.label),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bioController,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.sentences,
                  style: AppTextStyles.body,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Tell the fleet about yourself',
                  ),
                ),

                const Spacer(),

                // Info text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.highlightMuted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.vpn_key_outlined,
                        color: AppColors.highlight,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'A unique cryptographic key will be generated for your identity. No email or password needed.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.highlight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Create button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _createIdentity,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textOnHighlight,
                            ),
                          )
                        : const Text('Generate Identity'),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
