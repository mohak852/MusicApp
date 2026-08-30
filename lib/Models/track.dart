class Tracks {
  final String id;
  final String name;
  final String artistName;
  final String albumImage;
  final String audioUrl;
  final int duration;

  Tracks({
    required this.id,
    required this.name,
    required this.artistName,
    required this.albumImage,
    required this.audioUrl,
    required this.duration,
  });

  factory Tracks.fromJson(Map<String, dynamic> json) {
    return Tracks(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown Title',
      artistName: json['artist_name'] ?? 'Unknown Artist',
      albumImage: json['album_image'] ?? json['image'] ?? '',
      audioUrl: json['audio'] ?? '',
      duration: (json['duration'] is int)
          ? json['duration']
          : int.tryParse(json['duration']?.toString() ?? '0') ?? 0,
    );
  }

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'artist_name': artistName,
      'album_image': albumImage,
      'audio': audioUrl,
      'duration': duration,
    };
  }
}
