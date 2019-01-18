import 'dart:math';

import 'package:flutter/material.dart';
import 'package:music_player/theme.dart';


class ButtomControls extends StatelessWidget {
  const ButtomControls({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: double.infinity,
      child: Material(
        color: accentColor,
         child: Padding(
          padding: const EdgeInsets.only(top: 70.0, bottom: 120.0),
          child: new Column(
            children: <Widget>[

              new RichText(
                text: TextSpan(
                  text: "",
                  children: [
                    new TextSpan(
                      text: 'song title\n',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4.0,
                        height: 1.5
                      )
                    ),
                    new TextSpan(
                      text: 'artist name',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 12.0,
                        letterSpacing: 3.0,
                        height: 1.5

                      )
                    ),
                  ]
                ),
 
              ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Row(
                          children: <Widget>[
                            new Expanded(child: new Container()),
                            new PreviousButton(),


                            new Expanded(child: new Container()),
                            new PauseButton(),
                             

                            new Expanded(child: new Container()),
                            new NextButton(),
                            
                            new Expanded(child: new Container()),
                            ],
                        ),
                  )
            ],
          ),
        ),
      ),
    );
  }
}

class PreviousButton extends StatelessWidget {
  const PreviousButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new IconButton(
      splashColor: lightAccentColor,
        highlightColor: Colors.transparent,
      icon: new Icon(
        Icons.skip_previous,
        color: Colors.white,
        size: 40.0,
      ),
      onPressed: () {
        //TODO:
      },
    );
  }
}

class PauseButton extends StatelessWidget {
  const PauseButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new RawMaterialButton(
      shape: CircleBorder(),
      fillColor: Colors.white,
      splashColor: accentColor,
      highlightColor: lightAccentColor,
      elevation: 10.0,
      onPressed: () {
        //pause action
      },
      child: new Padding(
        padding: EdgeInsets.all(8.0),
        child: new Icon(
          Icons.play_arrow,
          size: 35.0,
          color: darkAccentColor,
         ),
      ),
     );
  }
}

class NextButton extends StatelessWidget {
  const NextButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new IconButton(
      splashColor: lightAccentColor,
        highlightColor: Colors.transparent,
      icon: new Icon(
        Icons.skip_next,
        color: Colors.white,
        size: 40.0,
      ),
      onPressed: () {
        //TODO:
      },
    );
  }
}

class CircleClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return new Rect.fromCircle(
      center: new Offset(size.width / 2, size.height / 2),
      radius: min(size.width, size.height) / 2,
    );
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }

}