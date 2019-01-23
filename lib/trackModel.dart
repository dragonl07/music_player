class TrackMetadata {
  static const String MediaTitleKey = "title";
  static const String MediaArtistKey = "artist";

  String title = "";
  String artist = "";

  void map(Map data) {
    data.forEach((k, v) {
      switch (k) {
        case MediaArtistKey:
          this.artist = v;
          break;
        case MediaTitleKey:
          this.title = v;
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
        default:
          print("Unknown key");
      }
    });
    return metadata;
  }
}
