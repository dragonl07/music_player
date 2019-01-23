import 'dart:async';
import 'package:flutter/services.dart';
import 'package:music_player/player_state.dart';
import 'package:music_player/trackModel.dart';
import 'dart:convert' show json;


class AudioService {
  static const MethodChannel platformChannel =
  const MethodChannel('audio_service');

  static const BasicMessageChannel<dynamic> _audio_state =
  const BasicMessageChannel('audio_service_state_channel', JSONMessageCodec());

  static final StreamController<PlaybackState> ctrl = StreamController();
  
  static Future<String> getData(dynamic message) async {
    final Map<String, dynamic> jsonMessage = json.decode(message);
    print(jsonMessage);
    if (jsonMessage.containsKey("id")) {
      ctrl.sink.add(PlaybackState.createForTrackId(jsonMessage["id"]));
    }
    if (jsonMessage.containsKey("state")) {
      ctrl.sink.add(PlaybackState.create(jsonMessage["state"]));
    }
    return message;
  }

  static Stream<PlaybackState> state () {
    _audio_state.setMessageHandler(getData);
    return ctrl.stream;
  }

  static Future<String> play(TrackMetadata track) async {
    String result = "";
    if (track == null) {
       result = await platformChannel.invokeMethod('play');
    } else {
      result = await platformChannel.invokeMethod('play', json.encode(track));
    }
    return result;
  }
  
  static Future<String> pause() async {
    String result = await platformChannel.invokeMethod('pause');
    return result;
  }

  static Future<String> next() async {
    String result = await platformChannel.invokeMethod('next');
    return result;
  }

  static Future<String> prev() async {
    String result = await platformChannel.invokeMethod('prev');
    return result;
  }
}
