import 'package:choira_music_player/Models/track.dart';
import 'package:choira_music_player/Utils/app_theme.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';

class TrackListItem extends StatelessWidget {
  final Tracks track;
  final bool isActive;
  final VoidCallback onTap;

  const TrackListItem({
    super.key,
    required this.track,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.surfaceElevated : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final showDuration = constraints.maxWidth >= 300;

            return Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  child: FastCachedImage(
                    url: track.albumImage,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, _) {
                      return Container(
                        width: 52,
                        height: 52,
                        color: AppColors.surfaceElevated,
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 52,
                      height: 52,
                      color: AppColors.surfaceElevated,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        track.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.trackTitle.copyWith(
                          color: isActive
                              ? AppColors.accent
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        track.artistName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.trackArtist,
                      ),
                    ],
                  ),
                ),
                if (showDuration) ...[
                  const SizedBox(width: 10),
                  Text(
                    track.formattedDuration,
                    style: const TextStyle(
                      color: AppColors.textFaint,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Icon(
                  isActive ? Icons.equalizer : Icons.more_vert,
                  color: isActive ? AppColors.accent : AppColors.textFaint,
                  size: 18,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
