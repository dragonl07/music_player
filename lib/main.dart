import 'package:flutter/material.dart';
import 'package:music_player/buttom_controls.dart';
import 'package:music_player/song_list.dart';
import 'package:music_player/songs.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Music Player MediaBy'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: new IconButton(
          icon: new Icon(
            Icons.arrow_back_ios
          ),
          color: const Color(0xFFDDDDDD),
          onPressed: () {},
        ),
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: <Widget>[
          new IconButton(
          icon: new Icon(
            Icons.menu
          ),
          color: const Color(0xFFDDDDDD),
          onPressed: () {},
        ),
        ],
      ),
      body: Column(
        children: <Widget>[
          new Expanded(
            child: new Container(),
          ),
          //seek bar
           new Expanded(
            child: new Center(
               child: new Container(
                 height: 125.0,
                 width: 125.0,
                 child: ClipOval(
                   clipper: new CircleClipper(),
                     child: new Image.network(
                     demoPlaylist.songs[0].albumArtUrl,
                     fit: BoxFit.cover,
                    ),
                 ),
               ),
            ),
           ),
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
             icon: new Icon(
               Icons.menu
              ),
                  onPressed: (){
                    Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => SongList()),
                  );
              },
           ),
         ],
       ),
          //control buttons song details
          new ButtomControls()
        ],
        
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

