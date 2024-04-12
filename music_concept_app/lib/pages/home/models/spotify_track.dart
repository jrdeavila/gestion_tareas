class SpotifyTrack {
  final String name;
  final String? imageURL;
  final String trackURL;
  final String artist;

  SpotifyTrack({
    required this.name,
    required this.imageURL,
    required this.trackURL,
    required this.artist,
  });

  factory SpotifyTrack.fromJson(Map<String, dynamic> json) {
    final track = json['track'];
    final artists = track['artists'] as List;
    final trackURL = track["album"]["external_urls"]["spotify"];
    final images = track["album"]["images"] as List;
    final imageURL = images.isNotEmpty ? images[0]["url"] : null;
    return SpotifyTrack(
      name: track['name'],
      imageURL: imageURL,
      trackURL: trackURL,
      artist: artists.first['name'],
    );
  }

  Map<String, dynamic> toFirebase() {
    return {
      "name": name,
      "imageURL": imageURL,
      "trackURL": trackURL,
      "artist": artist,
    };
  }

  factory SpotifyTrack.fromFirebase(Map<String, dynamic> data) {
    return SpotifyTrack(
      name: data['name'],
      imageURL: data['imageURL'],
      trackURL: data['trackURL'],
      artist: data['artist'],
    );
  }
}
