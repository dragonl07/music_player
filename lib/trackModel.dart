

class TrackMetadata extends Object {
  static const String MediaTitleKey = "title";
  static const String MediaArtistKey = "artist";
  static const String MediaUrlKey = "url";
  static const String MediaIdKey = "id";

  String title = "";
  String artist = "";
  String url = "";
  String id = "";
  bool isPlaying = false;

  Map<String, dynamic> toJson() => {
    MediaIdKey: id,
    MediaArtistKey: artist,
    MediaTitleKey: title,
    MediaUrlKey: url
  };

  void map(Map data) {
    data.forEach((k, v) {
      switch (k) {
        case MediaArtistKey:
          this.artist = v;
          break;
        case MediaTitleKey:
          this.title = v;
          break;
        case MediaUrlKey:
          this.url = v;
          break;
        default:
          print("Unknown key");
      }
    });
  }

  static TrackMetadata metadataFactory(Map rawData) {
    TrackMetadata metadata = new TrackMetadata();

    rawData.forEach((k, v) {
      switch (k) {
        case MediaArtistKey:
          metadata.artist = v;
          break;
        case MediaTitleKey:
          metadata.title = v;
          break;
        case MediaIdKey:
          metadata.id = v;
          break;
        case MediaUrlKey:
          metadata.url = v;
          break;
        default:
          print("Unknown key");
      }
    });
    return metadata;
  }
}
