import 'dart:async';
import "package:flutter/services.dart";
import 'package:music_player/audio_service.dart';
import 'package:music_player/source.dart';
import 'package:flutter/material.dart';
import 'package:music_player/trackModel.dart';
import 'package:music_player/db_services.dart';

class TrackListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TrackListViewState();
  }
}

class _TrackListViewState extends State<TrackListView> {
  List<TrackMetadata> tracklist = new List();

  _TrackListViewState() {
    DataService.dataChannel.setMethodCallHandler(_handleStateChangeMethod);
    DataService.getData().then((result) {
      if (result is List<TrackMetadata>) {
        print("Track Medatada was got");
        this.setState(() => this.tracklist = result);
      } else {
        print("Wrong data was got");
      }
    });
  }

  Future<dynamic> _handleStateChangeMethod(MethodCall call) async {
    switch (call.method) {
      case "updateData":
        return;
    }
  }

  onTrackClick(TrackMetadata track) {
    AudioService.playTrack(track);
  }

  @override
  Widget build(BuildContext context) {
    ListTile makeListTile(TrackMetadata track) => ListTile(
          onTap: () =>  onTrackClick(track),
          contentPadding: EdgeInsets.symmetric(vertical: 10.0),
          leading: Container(
            constraints: new BoxConstraints(maxHeight: 80),
            padding: EdgeInsets.only(right: 1.0, top: 1.0, bottom: 1.0)
            //child: Image.network(track.imageUrl, fit: BoxFit.fitHeight),
          ),
          title: Text(
            track.title,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(right: 1.0),
            child: Text(
              track.url,
              style: TextStyle(color: Colors.white),
            ),
          ),
        );

    Card makeCard(TrackMetadata track) => Card(
          elevation: 4.0,
          margin: new EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
          child: Container(
            decoration: BoxDecoration(
                color: track.isPlaying
                    ? Color.fromRGBO(22, 62, 70, 8)
                    : Color.fromRGBO(50, 50, 50, 7)),
            child: makeListTile(track),
          ),
        );

    final makeBody = SingleChildScrollView(
      child: Container(
        height: 450.0,
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: tracklist.length,
          itemBuilder: (BuildContext context, int index) {
            return makeCard(tracklist[index]);
          },
        ),
      ),
    );

    return makeBody;
  }
}
