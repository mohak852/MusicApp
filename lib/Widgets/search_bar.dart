import 'package:choira_music_player/Providers/track_provider.dart';
import 'package:choira_music_player/Utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClear,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search, color: AppColors.textFaint, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: widget.controller,
              onChanged: widget.onChanged,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
              ),
              decoration: const InputDecoration(
                hintText: 'Search songs, artists...',
                hintStyle: TextStyle(color: AppColors.textFaint, fontSize: 15),
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          if (widget.controller.text.isNotEmpty)
            Consumer<TrackProvider>(
              builder: (context, trackProvider, child) {
                return IconButton(
                  icon: const Icon(Icons.search, color: AppColors.textFaint),
                  onPressed: () {
                    print('Clearing search results');
                    print(widget.controller.text);
                    trackProvider.searchTracks(widget.controller.text);
                  },
                );
              },
            )
          else
            const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.clear, color: AppColors.textFaint),
            onPressed: () {
              setState(() {
                widget.controller.clear();
                context.read<TrackProvider>().fetchTracks();
              });
            },
          ),
        ],
      ),
    );
  }
}
