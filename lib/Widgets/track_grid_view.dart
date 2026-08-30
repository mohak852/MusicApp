import 'package:choira_music_player/Models/track.dart';
import 'package:choira_music_player/Providers/player_Provider.dart';
import 'package:choira_music_player/Providers/track_provider.dart';
import 'package:choira_music_player/Widgets/track_list_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TrackGridView extends StatelessWidget {
  final ScrollController scrollController;
  final void Function(Tracks track) onOpenNowPlaying;

  const TrackGridView({
    super.key,
    required this.scrollController,
    required this.onOpenNowPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<TrackProvider, PlayerProvider>(
      builder: (context, trackProvider, playerProvider, _) {
        final activeId = playerProvider.currentTracks?.id;

        return GridView.builder(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 420,
            mainAxisExtent: 72,
            crossAxisSpacing: 8,
            mainAxisSpacing: 4,
          ),
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
