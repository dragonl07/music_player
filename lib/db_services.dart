import 'dart:async';
import 'package:flutter/services.dart';
import 'package:music_player/trackModel.dart';

class DataService {

  static const dataChannel = const MethodChannel('data_service');

  static Future<dynamic> getData() async {
    try {
      final result = await dataChannel.invokeMethod('getData');
      if (result is List) {
        List<TrackMetadata> tracks = new List();
        print("Right Data");
        for (Map track in result) {
          tracks.add(TrackMetadata.metadataFactory(track));
        }
        return tracks;
      } else {
        print("Not right object");
      }
    } on PlatformException catch (error) {
      // handle error
      print('Error: $error'); // here
    }
  }
}
