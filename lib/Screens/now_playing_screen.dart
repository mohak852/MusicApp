import 'package:choira_music_player/Providers/player_Provider.dart';
import 'package:flutter/material.dart';
import 'package:choira_music_player/Utils/app_theme.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:provider/provider.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Consumer<PlayerProvider>(
            builder: (context, player, child) {
              final track = player.currentTracks;

              if (track == null) {
                return const Center(
                  child: Text(
                    'Nothing playing',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                );
              }

              final duration = player.duration;
              final position = player.position;
              final progress = duration.inMilliseconds == 0
                  ? 0.0
                  : position.inMilliseconds / duration.inMilliseconds;

              return Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textPrimary,
                          size: 30,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      Text('NOW PLAYING', style: AppText.sectionLabel),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: (MediaQuery.sizeOf(context).width - 48).clamp(
                      180.0,
                      520.0,
                    ),
                    height: (MediaQuery.sizeOf(context).width - 48).clamp(
                      180.0,
                      520.0,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      child: FastCachedImage(
                        key: ValueKey(track.albumImage),
                        url: track.albumImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color.fromARGB(255, 12, 12, 13),
                          child: const Icon(
                            Icons.music_note,
                            color: AppColors.textFaint,
                            size: 64,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              track.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(track.artistName, style: AppText.trackArtist),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      activeTrackColor: AppColors.accent,
                      inactiveTrackColor: AppColors.divider,
                      thumbColor: AppColors.accent,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 14,
                      ),
                    ),
                    child: Slider(
                      value: progress.clamp(0.0, 1.0),
                      onChanged: (v) {
                        final newPosition = duration * v;
                        player.seek(newPosition);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(position),
                          style: const TextStyle(
                            color: AppColors.textFaint,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _formatDuration(duration),
                          style: const TextStyle(
                            color: AppColors.textFaint,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.skip_previous_rounded,
                          color: AppColors.textPrimary,
                          size: 34,
                        ),
                        onPressed: player.hasPrevious ? player.previous : null,
                      ),
                      Container(
                        width: 68,
                        height: 68,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            player.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: AppColors.bg,
                            size: 34,
                          ),
                          onPressed: player.togglePlayPause,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.skip_next_rounded,
                          color: AppColors.textPrimary,
                          size: 34,
                        ),
                        onPressed: player.hasNext ? player.next : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
