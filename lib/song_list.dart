import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_player/tracts_listview.dart';


class SongList extends StatefulWidget {
  @override
  SongListState createState() {
    return new SongListState();
  }
}

class SongListState extends State<SongList> {
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
              child: new TrackListView(),
            ),
          ],
        ),
      ),
    );
  } 
}


