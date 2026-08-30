import 'package:choira_music_player/Models/track.dart';
import 'package:choira_music_player/Providers/player_Provider.dart';
import 'package:choira_music_player/Providers/track_provider.dart';
import 'package:choira_music_player/Utils/app_theme.dart';
import 'package:choira_music_player/Utils/message.dart';
import 'package:choira_music_player/Widgets/track_list_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TrackListView extends StatelessWidget {
  final ScrollController scrollController;
  final void Function(Tracks track) onOpenNowPlaying;

  const TrackListView({
    super.key,
    required this.scrollController,
    required this.onOpenNowPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<TrackProvider, PlayerProvider>(
      builder: (context, trackProvider, playerProvider, _) {
        if (trackProvider.isLoading && trackProvider.tracks.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          );
        }

        if (trackProvider.hasError) {
          return MessageState(
            icon: Icons.wifi_off_rounded,
            title: 'Couldn\'t load tracks',
            subtitle: 'Check your connection and try again.',
            actionLabel: 'Retry',
            onAction: () => context.read<TrackProvider>().fetchTracks(),
          );
        }

        if (trackProvider.tracks.isEmpty) {
          return const MessageState(
            icon: Icons.search_off_rounded,
            title: 'No results',
            subtitle: 'Try a different search term.',
          );
        }

        final activeId = playerProvider.currentTracks?.id;
        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          itemCount: trackProvider.tracks.length,
          itemBuilder: (context, index) {
            final track = trackProvider.tracks[index];
            return TrackListItem(
              track: track,
              isActive: track.id == activeId,
              onTap: () {
                context.read<PlayerProvider>().playTracks(
                  trackProvider.tracks,
                  index,
                );
                onOpenNowPlaying(track);
              },
            );
          },
        );
      },
    );
  }
}
