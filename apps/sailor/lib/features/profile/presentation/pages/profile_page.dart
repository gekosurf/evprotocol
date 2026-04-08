import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sailor/core/at/at_providers.dart';
import 'package:sailor/core/sync/sync_provider.dart';
import 'package:sailor/core/theme/app_colors.dart';
import 'package:sailor/core/theme/app_text_styles.dart';
import 'package:sailor/features/auth/presentation/providers/auth_providers.dart';
import 'package:sailor/shared/widgets/ev_overlays.dart';

/// Profile page — view identity details, copy pubkey, logout.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (identity) {
          if (identity == null) {
            return const Center(child: Text('No identity'));
          }

          final pubkeyShort = identity.pubkey.toString();
          final displayKey = pubkeyShort.length > 16
              ? '${pubkeyShort.substring(0, 8)}...${pubkeyShort.substring(pubkeyShort.length - 8)}'
              : pubkeyShort;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 32),

                // Avatar
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.highlight,
                    borderRadius: BorderRadius.circular(48),
                  ),
                  child: Center(
                    child: Text(
                      identity.displayName.isNotEmpty
                          ? identity.displayName[0].toUpperCase()
                          : '?',
                      style: AppTextStyles.h1.copyWith(
                        fontSize: 40,
                        color: AppColors.textOnHighlight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Name
                Text(
                  identity.displayName,
                  style: AppTextStyles.h2,
                ),

                // Bio
                if (identity.bio != null && identity.bio!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    identity.bio!,
                    style: AppTextStyles.bodySecondary,
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 32),

                // Identity card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PUBLIC KEY', style: AppTextStyles.label),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: pubkeyShort),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Public key copied'),
                              backgroundColor: AppColors.success,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                displayKey,
                                style: AppTextStyles.body.copyWith(
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.copy,
                              size: 16,
                              color: AppColors.textTertiary,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Divider(color: AppColors.divider),
                      const SizedBox(height: 16),

                      const Text('PROTOCOL', style: AppTextStyles.label),
                      const SizedBox(height: 8),
                      _buildAtProtocolStatus(ref),

                      const SizedBox(height: 16),

                      const Text('SYNC STATUS', style: AppTextStyles.label),
                      const SizedBox(height: 8),
                      _buildSyncStatus(ref),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Backup key button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.vpn_key_outlined, size: 18),
                    label: const Text('View Backup Key'),
                    onPressed: () async {
                      final backupKey =
                          await ref.read(getBackupKeyUseCaseProvider).call();
                      if (context.mounted) {
                        showEvDialog(
                          context: context,
                          builder: (ctx) => Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Backup Key', style: AppTextStyles.h3),
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: SelectableText(
                                  backupKey,
                                  style: AppTextStyles.body.copyWith(
                                    fontFamily: 'monospace',
                                    height: 1.6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(text: backupKey),
                                    );
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Key copied'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  },
                                  child: const Text('Copy & Close'),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Delete identity
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      showEvDialog(
                        context: context,
                        builder: (ctx) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              size: 48,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Delete Identity?',
                              style: AppTextStyles.h3,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'This will remove your identity from this device. Make sure you have your backup key.',
                              style: AppTextStyles.bodySecondary,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancel'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.error,
                                    ),
                                    onPressed: () async {
                                      Navigator.pop(ctx);
                                      await ref
                                          .read(authRepositoryProvider)
                                          .deleteIdentity();
                                      ref.invalidate(authStateProvider);
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text(
                      'Delete Identity',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAtProtocolStatus(WidgetRef ref) {
    final isAtAuth = ref.watch(atAuthStateProvider);
    final auth = ref.watch(atAuthServiceProvider);

    if (isAtAuth && auth.did != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('AT Protocol — Connected', style: AppTextStyles.body),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: auth.did!));
              ScaffoldMessenger.of(ref.context).showSnackBar(
                const SnackBar(
                  content: Text('DID copied'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Row(
              children: [
                const SizedBox(width: 16),
                const Icon(Icons.fingerprint, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    auth.did!,
                    style: AppTextStyles.bodySmall.copyWith(fontFamily: 'monospace'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.copy, size: 12, color: AppColors.textTertiary),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.warning,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text('Offline only — sign in for sync', style: AppTextStyles.body),
        ),
      ],
    );
  }

  Widget _buildSyncStatus(WidgetRef ref) {
    final pendingAsync = ref.watch(pendingSyncCountProvider);

    return pendingAsync.when(
      loading: () => Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.textTertiary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text('Checking...', style: AppTextStyles.body),
        ],
      ),
      error: (_, _) => Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text('Sync unavailable', style: AppTextStyles.body),
        ],
      ),
      data: (pendingCount) {
        final synced = pendingCount == 0;
        return Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: synced ? AppColors.success : AppColors.warning,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              synced ? 'All synced ✓' : '$pendingCount pending',
              style: AppTextStyles.body,
            ),
          ],
        );
      },
    );
  }
}
