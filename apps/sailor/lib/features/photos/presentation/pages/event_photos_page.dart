import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sailor/core/theme/app_colors.dart';
import 'package:sailor/core/theme/app_text_styles.dart';
import 'package:sailor/features/photos/data/photo_service.dart';
import 'package:sailor/features/photos/presentation/providers/photo_providers.dart';

/// Event photos page — grid gallery of photos from all participants.
class EventPhotosPage extends ConsumerWidget {
  final String eventAtUri;
  final String eventName;
  final List<String> participantDids;

  const EventPhotosPage({
    super.key,
    required this.eventAtUri,
    required this.eventName,
    required this.participantDids,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(eventPhotosProvider((
      eventAtUri: eventAtUri,
      participantDids: participantDids,
    )));

    return Scaffold(
      appBar: AppBar(
        title: Text(eventName),
        actions: [
          // Pending upload badge
          Builder(builder: (context) {
            final pending = ref.watch(pendingPhotoUploadsProvider);
            if (pending == 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                label: Text('$pending uploading'),
                backgroundColor: AppColors.warning.withValues(alpha: 0.2),
                labelStyle: AppTextStyles.label.copyWith(
                  color: AppColors.warning,
                  fontSize: 11,
                ),
              ),
            );
          }),
        ],
      ),
      body: photosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              const Text('Failed to load photos', style: AppTextStyles.body),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(eventPhotosProvider((
                  eventAtUri: eventAtUri,
                  participantDids: participantDids,
                ))),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (photos) {
          if (photos.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.photo_library_outlined,
                      size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  Text(
                    'No photos yet',
                    style: AppTextStyles.h3
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap + to share the first photo',
                    style: AppTextStyles.bodySecondary,
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
              return _PhotoTile(photo: photo);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.highlight,
        foregroundColor: AppColors.textOnHighlight,
        onPressed: () {
          // Phase 4: open image picker
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo picker — coming in Phase 4'),
              backgroundColor: AppColors.info,
            ),
          );
        },
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final EventPhoto photo;
  const _PhotoTile({required this.photo});

  @override
  Widget build(BuildContext context) {
    final url = photo.blobUrl;
    final truncDid = photo.authorDid.length > 16
        ? '${photo.authorDid.substring(0, 10)}…'
        : photo.authorDid;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Photo or placeholder
          if (photo.isLocal && photo.localPath != null)
            Image.asset(
              photo.localPath!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _placeholder(),
            )
          else if (url != null)
            Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _placeholder(),
              loadingBuilder: (_, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _placeholder();
              },
            )
          else
            _placeholder(),

          // Caption overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Text(
                photo.caption ?? truncDid,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Upload pending indicator
          if (photo.isLocal)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.cloud_upload,
                    size: 12, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.surfaceBg,
      child: const Center(
        child: Icon(Icons.photo, size: 32, color: AppColors.textTertiary),
      ),
    );
  }
}
