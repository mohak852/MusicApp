import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:choira_music_player/Models/track.dart';
import 'package:choira_music_player/Utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class TrackProvider extends ChangeNotifier {
  List<Tracks> tracks = [];
  int offset = 0;
  bool isLoading = false;
  bool hasMore = true;
  bool hasError = false;
  String query = '';
  bool isShowingCachedData = false;

  static const int _pageSize = 25;

  String get _clientId => const String.fromEnvironment('JAMENDO_CLIENT_ID');

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
        isShowingCachedData = false;

        if (!loadMore) {
          await _cacheTracks();
        }
      } else {
        hasError = true;
        debugPrint('Failed to load tracks: ${response.statusCode}');
        if (tracks.isEmpty) {
          await _loadCachedTracks();
        }
      }
    } catch (error) {
      hasError = true;
      debugPrint('Error fetching tracks: $error');
      if (tracks.isEmpty) {
        await _loadCachedTracks(); // offline fallback
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _cacheTracks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = tracks.map((t) => t.toJson()).toList();
      await prefs.setString('cached_tracks', jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Cache save error: $e');
    }
  }

  Future<void> _loadCachedTracks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cached_tracks');
      if (cached != null) {
        final jsonList = jsonDecode(cached) as List<dynamic>;
        tracks = jsonList
            .whereType<Map<String, dynamic>>()
            .map(Tracks.fromJson)
            .toList();
        hasMore = false;
        isShowingCachedData = true;
      }
    } catch (e) {
      debugPrint('Cache load error: $e');
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
        debugPrint('Failed to search tracks: ${response.statusCode}');
      }
    } catch (error) {
      hasError = true;
      debugPrint('Error searching tracks: $error');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
