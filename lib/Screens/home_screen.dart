import 'package:choira_music_player/Models/track.dart';
import 'package:choira_music_player/Providers/player_Provider.dart';
import 'package:choira_music_player/Screens/now_playing_screen.dart';
import 'package:choira_music_player/Providers/track_provider.dart';
import 'package:choira_music_player/Utils/app_theme.dart';
import 'package:choira_music_player/Widgets/mini_player.dart';
import 'package:choira_music_player/Widgets/search_bar.dart';
import 'package:choira_music_player/Widgets/track_grid_view.dart';
import 'package:choira_music_player/Widgets/track_list_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrackProvider>().fetchTracks();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<TrackProvider>().fetchTracks(loadMore: true);
    }
  }

  void _openNowPlaying(Tracks track) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => NowPlayingScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;
            final horizontalPadding = constraints.maxWidth >= 700 ? 32.0 : 20.0;
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    12,
                    horizontalPadding,
                    8,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Discover', style: AppText.screenTitle),
                            SizedBox(height: 2),
                          ],
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceElevated,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: SearchBarWidget(
                        controller: _searchController,
                        onChanged: (query) {},
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(child: _buildBody(isWide)),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: Consumer<PlayerProvider>(
        builder: (context, player, child) {
          final track = player.currentTracks;
          if (track == null) return const SizedBox.shrink();
          final progress = player.duration.inMilliseconds == 0
              ? 0.0
              : player.position.inMilliseconds / player.duration.inMilliseconds;
          return MiniPlayer(
            track: track,
            isPlaying: player.isPlaying,
            progress: progress.clamp(0.0, 1.0),
            onPlayPause: player.togglePlayPause,
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => NowPlayingScreen()));
            },
          );
        },
      ),
    );
  }

  Widget _buildBody(bool isWide) {
    return isWide
        ? TrackGridView(
            scrollController: _scrollController,
            onOpenNowPlaying: _openNowPlaying,
          )
        : TrackListView(
            scrollController: _scrollController,
            onOpenNowPlaying: _openNowPlaying,
          );
  }
}
