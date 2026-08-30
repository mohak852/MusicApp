import 'package:choira_music_player/Models/track.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';


class PlayerProvider extends ChangeNotifier {
  
  final AudioPlayer _player = AudioPlayer();

  List<Tracks> _queue = [];
  int _currentIndex = -1;

  Tracks? get currentTracks => _currentIndex >= 0 && _currentIndex < _queue.length
      ? _queue[_currentIndex]
      : null;

  bool get isPlaying => _player.playing;
  Duration get position => _player.position;
  Duration get duration => _player.duration ?? Duration.zero;
  bool get hasNext => _currentIndex < _queue.length - 1;
  bool get hasPrevious => _currentIndex > 0;

  PlayerProvider() {
    _player.positionStream.listen((_) => notifyListeners());
    _player.durationStream.listen((_) => notifyListeners());
    _player.playerStateStream.listen((state) {
      notifyListeners();
      if (state.processingState == ProcessingState.completed) {
        next(); 
      }
    });
  }

  Future<void> playTracks(List<Tracks> queue, int index) async {
    _queue = queue;
    _currentIndex = index;
    // ignore: non_constant_identifier_names
    final tracks = _queue[index];

    try {
      await _player.setUrl(tracks.audioUrl);
      await _player.play();
    } catch (e) {
    }
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> next() async {
    if (hasNext) {
      await playTracks(_queue, _currentIndex + 1);
    }
  }

  Future<void> previous() async {
    if (hasPrevious) {
      await playTracks(_queue, _currentIndex - 1);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
