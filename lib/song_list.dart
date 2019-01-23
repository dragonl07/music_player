import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_player/source.dart';
import 'package:music_player/tracts_listview.dart';
var tracksList = [
  Track(
      "0",
      "SomaFM: Deep Space",
      "http://somafm.com/img3/deepspaceone-400.jpg",
      "http://ice1.somafm.com/deepspaceone-128-mp3"),
  Track("1", "SomaFM: Drone Zone", "http://somafm.com/img3/dronezone-400.jpg",
      "http://ice3.somafm.com/dronezone-256-mp3"),
       Track("1", "SomaFM: Drone Zone", "http://somafm.com/img3/dronezone-400.jpg",
      "http://ice3.somafm.com/dronezone-256-mp3"),
      
  Track("1", "SomaFM: Drone Zone", "http://somafm.com/img3/dronezone-400.jpg",
      "http://ice3.somafm.com/dronezone-256-mp3"),
       Track("1", "SomaFM: Drone Zone", "http://somafm.com/img3/dronezone-400.jpg",
      "http://ice3.somafm.com/dronezone-256-mp3"),
  Track(
      "2",
      "Space Station Soma",
      "http://somafm.com/img3/spacestation-400.jpg",
      "http://ice1.somafm.com/spacestation-128-mp3")
      
];

class SongList extends StatefulWidget {
  @override
  SongListState createState() {
    return new SongListState();
  }
}

class SongListState extends State<SongList> {
  List<Track> _tracks = tracksList;

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xfffddddd),
        elevation: 0.0,
       actions: <Widget>[
          new IconButton(
          icon: new Icon(
            Icons.add,
          ),
          color: Colors.black,
          iconSize: 40.0,
          onPressed: (){
            
            
          },
        ),
       ],
        
      ),
      body: Container(
        child: new Column(
          children: <Widget>[
            new TextField(
              autofocus: true,
              decoration: new InputDecoration(
                border: new OutlineInputBorder(
                  borderSide: new BorderSide(color: Colors.black, width: 5.0)
                  
                ) ,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top:15.0),
              child: new TrackListView(_tracks),
            ),
          ],
        ),
      ),
    );
  } 
}


