package com.eldor.playeraudio;

import android.content.Intent;
import android.os.Bundle;
import android.widget.Toast;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.JSONMessageCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StringCodec;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

  private static final String CHANNEL = "com.eldor.playeraudio";
  private static final String MESSAGE_CHANNEL = "audio_service_state_channel";
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    initControlChannel();
  }

  private void initControlChannel() {
    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(new MethodChannel.MethodCallHandler() {
      @Override
      public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {

        switch (methodCall.method){
          case "play":
            init(MusicService.ACTION_PLAY);
            result.success("onPlay");
            break;
          case "pause":
            init(MusicService.ACTION_PAUSE);
            result.success("onPause");
            break;
          case "next":
            init(MusicService.ACTION_NEXT);
            break;
          case "prev":
            init(MusicService.ACTION_PREVIOUS);
            break;

        }
      }
    });
  }

  public void init(String action){
    Intent intent = new Intent(MainActivity.this, MusicService.class);
    intent.setAction(action);
    startService(intent);
  }
}
