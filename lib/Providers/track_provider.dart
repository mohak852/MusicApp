import 'dart:convert';
import 'package:choira_music_player/Models/track.dart';
import 'package:choira_music_player/Utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TrackProvider extends ChangeNotifier {
  List<Tracks> tracks = [];
  int offset = 0;
  bool isLoading = false;
  bool hasMore = true;
  bool hasError = false;
  String query = '';
  

  static const int _pageSize = 25;

  String get _clientId => dotenv.env['JAMENDO_CLIENT_ID'] ?? '';

  Future<void> fetchTracks({bool loadMore = false}) async {
    if (isLoading || (!hasMore && loadMore)) return;

    if (!loadMore) {
      offset = 0;
      tracks.clear();
      hasMore = true;
    }

    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      final response = await get(
        Uri.parse('${ApiConstants.BASE_URL}/tracks/').replace(
          queryParameters: {
            'client_id': _clientId,
            'format': 'json',
            'limit': '$_pageSize',
            'offset': '$offset',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? const [];
        final fetchedTracks = results
            .whereType<Map<String, dynamic>>()
            .map(Tracks.fromJson)
            .toList();
        tracks.addAll(fetchedTracks);
        offset += fetchedTracks.length;
        hasMore = fetchedTracks.length == _pageSize;
      } else {
        hasError = true;
      }
    } catch (error) {
      hasError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchTracks(String query) async {
    this.query = query;
    offset = 0;
    tracks.clear();
    hasMore = true;
    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      final response = await get(
        Uri.parse('${ApiConstants.BASE_URL}/tracks/').replace(
          queryParameters: {
            'client_id': _clientId,
            'format': 'json',
            'namesearch': query,
            'limit': '$_pageSize',
            'offset': '$offset',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? const [];
        final fetchedTracks = results
            .whereType<Map<String, dynamic>>()
            .map(Tracks.fromJson)
            .toList();
        tracks = fetchedTracks;
        offset = fetchedTracks.length;
        hasMore = fetchedTracks.length == _pageSize;
      } else {
        hasError = true;
      }
    } catch (error) {
      hasError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
