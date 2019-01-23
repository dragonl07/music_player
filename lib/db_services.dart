import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
   

class DB_chanel{
   String id;
   String title;
   String imageUrl;
   String streamUrl;

static const PLATFORM_CHANNEL = const MethodChannel('<APP_BUNDLE_NAME>/platform_channel');
// you can use whatever you like. but make sure you use the same channel string in native code also
// platform channel method calling
Future<Null> getData(BuildContext context) async {
  try {
    final String result = await PLATFORM_CHANNEL.invokeMethod(
      'getData', // call the native function
      <String, dynamic> { // data to be passed to the function
        'id' : id,
        'title': title,
        'imageUrl': imageUrl,
        'streamUrl': streamUrl

      }
    );
    // result hold the response from plaform calls
  } on PlatformException catch (error) { // handle error
    print('Error: $error'); // here
  }
}
}

