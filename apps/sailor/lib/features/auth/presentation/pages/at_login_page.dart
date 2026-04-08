import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sailor/core/at/at_providers.dart';
import 'package:sailor/core/router/app_router.dart';
import 'package:sailor/core/theme/app_colors.dart';
import 'package:sailor/core/theme/app_text_styles.dart';

/// AT Protocol login page — handle + app password.
///
/// Phase 2: Simple form. Phase 4: OAuth + biometrics.
class AtLoginPage extends ConsumerStatefulWidget {
  const AtLoginPage({super.key});

  @override
  ConsumerState<AtLoginPage> createState() => _AtLoginPageState();
}

class _AtLoginPageState extends ConsumerState<AtLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _handleController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _handleController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final auth = ref.read(atAuthServiceProvider);
      await auth.login(
        handle: _handleController.text.trim(),
        appPassword: _passwordController.text.trim(),
      );

      // Start background sync
      ref.read(atSyncServiceProvider).start();
      ref.read(atAuthStateProvider.notifier).setAuthenticated(true);

      if (mounted) {
        context.go(AppRoutes.home);
      }
    } catch (e) {
      setState(() {
        _error = 'Login failed. Check your handle and app password.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 80),

                // Logo
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.highlight,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.sailing,
                      size: 40,
                      color: AppColors.textOnHighlight,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Center(
                  child: Text('Sign in', style: AppTextStyles.h1),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Connect with your Bluesky account',
                    style: AppTextStyles.bodySecondary,
                  ),
                ),
                const SizedBox(height: 40),

                // Handle field
                TextFormField(
                  controller: _handleController,
                  decoration: InputDecoration(
                    labelText: 'Handle',
                    hintText: 'yourname.bsky.social',
                    prefixIcon: const Icon(Icons.alternate_email),
                    filled: true,
                    fillColor: AppColors.surfaceBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.highlight, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter your Bluesky handle';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // App Password field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'App Password',
                    hintText: 'xxxx-xxxx-xxxx-xxxx',
                    prefixIcon: const Icon(Icons.key),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.highlight, width: 2),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  autocorrect: false,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _login(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter your app password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Help text
                Text(
                  'Create an app password at bsky.app/settings/app-passwords',
                  style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 24),

                // Error message
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Login button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textOnHighlight,
                            ),
                          )
                        : const Text('Connect'),
                  ),
                ),
                const SizedBox(height: 16),

                // Skip for now
                Center(
                  child: TextButton(
                    onPressed: () => context.go(AppRoutes.createIdentity),
                    child: Text(
                      'Skip — use offline only',
                      style: AppTextStyles.bodySecondary.copyWith(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
