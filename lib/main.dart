import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_player/audio_service.dart';
import 'package:music_player/player_state.dart';
import 'package:music_player/song_list.dart';
import 'package:music_player/source.dart';
import 'package:music_player/songs.dart';
import 'package:music_player/theme.dart';
import 'package:music_player/trackModel.dart';
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

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Music Player'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final TrackMetadata metadata = new TrackMetadata();

  @override
  _MyHomePageState createState() => _MyHomePageState();

  MyHomePage({Key key, this.title}) : super(key: key);
}

class _MyHomePageState extends State<MyHomePage> {
  IconData _playIcon = Icons.play_arrow;
  PlayerState _state = PlayerState.unknown;
  List<Track> _tracks = tracksList;
  TrackMetadata _metadata = new TrackMetadata();

  @override
  void initState() {
    super.initState();
    // init();

    AudioService.platformChannel.setMethodCallHandler(_handleStateChangeMethod);
    AudioService.state().listen((data) {
      if (data.playerState != null) {
        updatePlayIcon(data.playerState);
      }
      if (data.trackId != null) {
        updateCurrentTrack(data.trackId);
      }
    });
  }

  void updateCurrentTrack(String newTrackId) {
    setState(() {
      _tracks.forEach((f) => f.isPlayning = (f.id == newTrackId));
    });
  }

  void updatePlayIcon(PlayerState state) {
    setState(() {
      _state = state;
      // ignore: missing_enum_constant_in_switch
      switch (_state) {
        case PlayerState.onPlay:
          _playIcon = Icons.pause;
          break;
        case PlayerState.onPause:
          _playIcon = Icons.play_arrow;
          break;
      }
    });
  }

  Future<dynamic> _handleStateChangeMethod(MethodCall call) async {
    switch (call.method) {
      case "updateNowPlayingInfo":
        print("Now playing");
        print(call.arguments);
        setState(() {
          this._metadata.map(call.arguments);
        });
        return;
    }
  }


  Future<String> playPause() async {
    String result;
    if (_state == PlayerState.onPlay) {
      result = await AudioService.pause();
    } else {
      result = await AudioService.play();
    }

    if (result == "onPlay") {
      _state = PlayerState.onPlay;
    } else {
      _state = PlayerState.onPause;
    }
    updatePlayIcon(_state);
    return result;
  }

  Future<String> next() async {
    String result = await AudioService.next();
    return result;
  }

  Future<String> prev() async {
    String result = await AudioService.prev();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back_ios),
          color: const Color(0xFFDDDDDD),
          onPressed: () {},
        ),
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.menu),
            color: const Color(0xFFDDDDDD),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: new Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom:0.0),
                child: new Container(
                height: 300.0,
                child: new TrackListView(),

                ),
              ),
            ),
          ),
          //seek bar
          
          //visuilazer
          new Container(
            width: double.infinity,
            height: 5.0,
            color: Colors.red,
            child: LinearProgressIndicator(
              backgroundColor: Colors.white,
              value: 50.0,
            ),
          ),

          new Column(
            children: <Widget>[
              new IconButton(
                color: Colors.grey,
                icon: new Icon(Icons.menu),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SongList()),
                  );
                },
              ),
            ],
          ),
          //control buttons song details
          new Container(
            width: double.infinity,
            child: Material(
              color: accentColor,
              child: Padding(
                padding: const EdgeInsets.only(top: 70.0, bottom: 120.0),
                child: new Column(
                  children: <Widget>[
                    new RichText(
                      text: TextSpan(text: "", children: [
                        new TextSpan(
                            text: this._metadata.title + "\n",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 4.0,
                                height: 1.5)),
                        new TextSpan(
                            text: this._metadata.artist,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 12.0,
                                letterSpacing: 3.0,
                                height: 1.5)),
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Row(
                        children: <Widget>[
                          new Expanded(child: new Container()),
                          new IconButton(
                            splashColor: lightAccentColor,
                            highlightColor: Colors.transparent,
                            icon: new Icon(
                              Icons.skip_previous,
                              color: Colors.white,
                              size: 40.0,
                            ),
                            onPressed: () {
                              prev();
                            },
                          ),
                          new Expanded(child: new Container()),
                          new RawMaterialButton(
                            shape: CircleBorder(),
                            fillColor: Colors.white,
                            splashColor: accentColor,
                            highlightColor: lightAccentColor,
                            elevation: 10.0,
                            onPressed: () {
                              playPause();
                            },
                            child: new Padding(
                              padding: EdgeInsets.all(8.0),
                              child: new Icon(
                                _playIcon,
                                size: 35.0,
                                color: darkAccentColor,
                              ),
                            ),
                          ),
                          new Expanded(child: new Container()),
                          new IconButton(
                            splashColor: lightAccentColor,
                            highlightColor: Colors.transparent,
                            icon: new Icon(
                              Icons.skip_next,
                              color: Colors.white,
                              size: 40.0,
                            ),
                            onPressed: () {
                              next();
                            },
                          ),
                          new Expanded(child: new Container()),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


