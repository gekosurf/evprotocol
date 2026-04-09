import 'package:ev_protocol_at/ev_protocol_at.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sailor/core/at/at_providers.dart';
import 'package:sailor/core/theme/app_colors.dart';
import 'package:sailor/core/theme/app_text_styles.dart';

/// Connections page — manage known Bluesky users whose events you discover.
class ConnectionsPage extends ConsumerStatefulWidget {
  const ConnectionsPage({super.key});

  @override
  ConsumerState<ConnectionsPage> createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends ConsumerState<ConnectionsPage> {
  final _handleController = TextEditingController();
  bool _isAdding = false;
  bool _isImporting = false;
  String? _error;

  @override
  void dispose() {
    _handleController.dispose();
    super.dispose();
  }

  Future<void> _addConnection() async {
    final handle = _handleController.text.trim();
    if (handle.isEmpty) return;

    setState(() {
      _isAdding = true;
      _error = null;
    });

    try {
      final auth = ref.read(atAuthServiceProvider);
      final client = auth.client;
      if (client == null) throw Exception('Not authenticated');

      debugPrint('[Connections] Resolving handle: $handle');
      final result = await client.atproto.identity.resolveHandle(
        handle: handle,
      ).timeout(const Duration(seconds: 10));
      final did = result.data.did;
      debugPrint('[Connections] Resolved $handle → $did');

      final store = await ref.read(connectionsStoreProvider.future);
      await store.add(Connection(
        handle: handle,
        did: did,
        addedAt: DateTime.now(),
      ));

      ref.invalidate(connectionsProvider);
      _handleController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connected to $handle ✓'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      debugPrint('[Connections] Add failed: $e');
      setState(() {
        _error = 'Failed: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  Future<void> _removeConnection(String did, String handle) async {
    final store = await ref.read(connectionsStoreProvider.future);
    await store.remove(did);
    ref.invalidate(connectionsProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed $handle'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _importFollows() async {
    setState(() => _isImporting = true);
    debugPrint('[Connections] Import follows started');
    try {
      final auth = ref.read(atAuthServiceProvider);
      final client = auth.client;
      if (client == null) throw Exception('Not authenticated');

      final store = await ref.read(connectionsStoreProvider.future);
      final existingDids = (await store.loadAll()).map((c) => c.did).toSet();
      final selfDid = auth.did!;
      debugPrint('[Connections] Self DID: $selfDid, existing: ${existingDids.length}');

      int added = 0;
      String? cursor;

      do {
        debugPrint('[Connections] Fetching follows page (cursor: $cursor)');
        final result = await client.graph.getFollows(
          actor: selfDid,
          cursor: cursor,
        ).timeout(const Duration(seconds: 15));

        debugPrint('[Connections] Got ${result.data.follows.length} follows');

        for (final follow in result.data.follows) {
          if (follow.did == selfDid || existingDids.contains(follow.did)) continue;

          await store.add(Connection(
            handle: follow.handle,
            did: follow.did,
            addedAt: DateTime.now(),
          ));
          existingDids.add(follow.did);
          added++;
        }

        cursor = result.data.cursor;
      } while (cursor != null);

      ref.invalidate(connectionsProvider);
      debugPrint('[Connections] Imported $added follows');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imported $added follows from Bluesky ✓'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      debugPrint('[Connections] Import failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectionsAsync = ref.watch(connectionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connections'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share my handle',
            onPressed: () {
              final auth = ref.read(atAuthServiceProvider);
              final handle = auth.handle ?? auth.did ?? 'unknown';
              final shareText = 'Add me on Sailor: $handle';
              Clipboard.setData(ClipboardData(text: shareText));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Handle copied — share it with your crew!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Add connection input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add a Bluesky user to discover their events',
                    style: AppTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _handleController,
                          style: AppTextStyles.body,
                          decoration: InputDecoration(
                            hintText: 'alice.bsky.social',
                            prefixIcon: const Icon(Icons.alternate_email,
                                size: 20, color: AppColors.highlight),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onSubmitted: (_) => _addConnection(),
                          textInputAction: TextInputAction.go,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isAdding ? null : _addConnection,
                          child: _isAdding
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.textOnHighlight,
                                  ),
                                )
                              : const Text('Add'),
                        ),
                      ),
                    ],
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!,
                        style: AppTextStyles.label
                            .copyWith(color: AppColors.error)),
                  ],
                  const SizedBox(height: 12),
                  // Import follows button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: _isImporting ? null : _importFollows,
                      icon: _isImporting
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.download_rounded, size: 18),
                      label: Text(_isImporting
                          ? 'Importing...'
                          : 'Import from Bluesky Follows'),
                    ),
                  ),
                ],
              ),
            ),

            // Connections list
            Expanded(
              child: connectionsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text('Error: $e', style: AppTextStyles.body)),
                data: (connections) {
                  if (connections.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_outline,
                              size: 64,
                              color: AppColors.textTertiary
                                  .withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'No connections yet',
                            style: AppTextStyles.h3
                                .copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 48),
                            child: Text(
                              'Tap "Import from Bluesky Follows" above to automatically add everyone you follow.',
                              style: AppTextStyles.bodySecondary,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: connections.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: AppColors.border.withValues(alpha: 0.2),
                    ),
                    itemBuilder: (context, index) {
                      final conn = connections[index];
                      return Dismissible(
                        key: ValueKey(conn.did),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: AppColors.error,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete_outline,
                              color: Colors.white),
                        ),
                        onDismissed: (_) =>
                            _removeConnection(conn.did, conn.handle),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                AppColors.highlight.withValues(alpha: 0.15),
                            child: Text(
                              conn.handle[0].toUpperCase(),
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.highlight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          title: Text(conn.handle, style: AppTextStyles.body),
                          subtitle: Text(
                            conn.did.length > 24
                                ? '${conn.did.substring(0, 24)}…'
                                : conn.did,
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.close,
                                size: 18, color: AppColors.textTertiary),
                            onPressed: () =>
                                _removeConnection(conn.did, conn.handle),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
