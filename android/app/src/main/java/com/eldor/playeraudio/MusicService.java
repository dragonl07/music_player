package com.eldor.playeraudio;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.media.session.MediaController;
import android.media.session.MediaSession;
import android.media.session.MediaSessionManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;

import java.util.ArrayList;

public class MusicService extends Service {

    public static final String ACTION_PLAY = "action_play";
    public static final String ACTION_PAUSE = "action_pause";
    public static final String ACTION_NEXT = "action_next";
    public static final String ACTION_STOP = "action_stop";
    public static final String ACTION_PREVIOUS = "action_previous";
    public static final String ACTION_SPECIFIC = "action_specific";

    private MediaSession mSession;
    private MediaSessionManager mManager;
    private MediaController mController;
    private MediaPlayer mMediaPlayer;
    private DBHelper db;
    Handler durationHandler = new Handler();

    double timeElapsed = 0, finalTime = 0;
    int position = 0;
    boolean isPlaying = false;
    ArrayList<String> list;


    @Override
    public void onCreate() {
        super.onCreate();
        mMediaPlayer = new MediaPlayer();
        mMediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
        mMediaPlayer.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
            public void onCompletion(MediaPlayer mp) {
                next();
            }
        });

        getAllData();
    }

    private void getAllData() {
//        db = new DBHelper(getApplicationContext());
//        list = db.getAllContacts();
        list = new ArrayList<>();
        list.add("http://www.topmusic.uz/get/track-272198.mp3");
        list.add("http://www.topmusic.uz/get/track-272202.mp3");
    }


    private void next() {
        mMediaPlayer.stop();
        position += 1;

        if(position>=list.size()){
            position = 0;
        }

        initMedia();
        mMediaPlayer.start();


    }

    private void previous() {

        mMediaPlayer.stop();
        position -= 1;

        if(position < 0) {
            position = list.size()-1;
        }
        initMedia();
        mMediaPlayer.start();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if(mManager == null){
            initMediaSession();
        }
        handleIntent(intent);
        return super.onStartCommand(intent, flags, startId);
    }

    @SuppressLint("NewApi")
    private void initMediaSession() {
        mSession = new MediaSession(getApplicationContext(), "My session");
        mController = new MediaController(getApplicationContext(), mSession.getSessionToken());
        mSession.setCallback(new MediaSession.Callback() {
            @Override
            public void onPlay() {
                super.onPlay();
                buildNotification(generateAction(android.R.drawable.ic_media_pause, "Pause", ACTION_PAUSE));
            }

            @Override
            public void onPause() {
                super.onPause();
                buildNotification(generateAction(android.R.drawable.ic_media_play, "Play", ACTION_PLAY));
            }

            @Override
            public void onSkipToNext() {
                super.onSkipToNext();
                buildNotification(generateAction(android.R.drawable.ic_media_pause, "Pause", ACTION_PAUSE));
            }

            @Override
            public void onSkipToPrevious() {
                super.onSkipToPrevious();
                buildNotification(generateAction(android.R.drawable.ic_media_pause, "Pause", ACTION_PAUSE));
            }

            @Override
            public void onStop() {
                super.onStop();
                NotificationManager notificationManager = (NotificationManager)getApplicationContext()
                        .getSystemService(Context.NOTIFICATION_SERVICE);
                notificationManager.cancel(1);
                Intent intent = new Intent(getApplicationContext(), MusicService.class);
                stopService(intent);
            }
        });
    }


    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @SuppressLint("NewApi")
    @Override
    public boolean onUnbind(Intent intent) {
        mSession.release();
        return super.onUnbind(intent);
    }

    private void initMedia(){

        Thread t = new Thread(){
            @Override
            public void run() {
                try {

                    while (!isConnected(getApplicationContext())){
                        Thread.sleep(1000);
                    }

                    mMediaPlayer = new MediaPlayer();
                    mMediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
                    mMediaPlayer.setDataSource(list.get(position));
//                    mMediaPlayer.setDataSource("http://www.topmusic.uz/get/track-272202.mp3");
                    mMediaPlayer.prepare();
                    isPlaying = true;
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        };

        t.run();

        finalTime = mMediaPlayer.getDuration();
        sendData("finaltime", finalTime, "topic", list.get(position), "duration");
        durationHandler.postDelayed(updateSeekBarTime, 100);

    }


    @SuppressLint("NewApi")
    private void handleIntent(Intent intent){
        if(intent==null || intent.getAction()==null)
            return;

        String action = intent.getAction();


        if(action.equalsIgnoreCase(ACTION_PLAY)){
            mController.getTransportControls().play();
            if(!isPlaying){
                initMedia();
            }
            mMediaPlayer.start();
        }else if(action.equalsIgnoreCase(ACTION_PAUSE)){
            mController.getTransportControls().pause();
            if(isPlaying){
                mMediaPlayer.pause();
            }
        }else if(action.equalsIgnoreCase(ACTION_NEXT)){
            mController.getTransportControls().skipToNext();
            next();
        }else if(action.equalsIgnoreCase(ACTION_PREVIOUS)){
            mController.getTransportControls().skipToPrevious();
            previous();
        }else if(action.equalsIgnoreCase(ACTION_STOP)){
            mController.getTransportControls().stop();
        }else if(action.equalsIgnoreCase(ACTION_SPECIFIC)){
            playSpecificMusic(intent.getIntExtra("music_id", 0));
        }
    }

    private void playSpecificMusic(int i) {

        mMediaPlayer.stop();

        position = i;

        initMedia();
        mMediaPlayer.start();
    }

    private Runnable updateSeekBarTime = new Runnable() {
        public void run() {

            //get current position
            timeElapsed = mMediaPlayer.getCurrentPosition();
            sendElapsedTime("timeElapsed", timeElapsed, "time");
            //repeat yourself that again in 100 miliseconds
            durationHandler.postDelayed(this, 100);
        }
    };


    private void sendElapsedTime(String key, double data, String action_title){
        Intent intent = new Intent();
        intent.setAction(action_title);
        intent.putExtra(key, data);
        sendBroadcast(intent);

    }
    private void sendData(String key, double data, String key2, String title, String action_title){
        Intent intent = new Intent();
        intent.setAction(action_title);
        intent.putExtra(key, data);
        intent.putExtra(key2, title);
        sendBroadcast(intent);
    }

    private static boolean isConnected(Context context){
        ConnectivityManager connectivityManager = (ConnectivityManager)
                context.getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo networkInfo = null;
        if(connectivityManager != null){
            networkInfo = connectivityManager.getActiveNetworkInfo();
        }
        return networkInfo != null && networkInfo.getState() == NetworkInfo.State.CONNECTED;
    }

    @TargetApi(Build.VERSION_CODES.KITKAT_WATCH)
    private Notification.Action generateAction(int icon, String title, String intentAction){
        Intent intent = new Intent(getApplicationContext(), MusicService.class);
        intent.setAction(intentAction);
        PendingIntent pendingIntent = PendingIntent.getService(getApplicationContext(), 1,intent,0);

        return new Notification.Action.Builder(icon, title, pendingIntent).build();
    }

    @SuppressLint("NewApi")
    private void buildNotification(Notification.Action action){
        Notification.MediaStyle style = new Notification.MediaStyle();
        Intent intent = new Intent(getApplicationContext(), MusicService.class);
        intent.setAction(ACTION_STOP);
        PendingIntent pendingIntent = PendingIntent.getService(getApplicationContext(),1,intent,0);
        Notification.Builder builder = new Notification.Builder(this)
                .setSmallIcon(android.R.mipmap.sym_def_app_icon)
                .setContentTitle("Audio")
                .setContentText(list.get(position))
                .setDeleteIntent(pendingIntent)
                .setStyle(style);

        builder.addAction(generateAction(android.R.drawable.ic_media_previous, "Previous", ACTION_PREVIOUS));
        builder.addAction(action);
        builder.addAction(generateAction(android.R.drawable.ic_media_next, "Next", ACTION_NEXT));
        style.setShowActionsInCompactView(0,1,2,3,4);

        NotificationManager manager = (NotificationManager)getSystemService(Context.NOTIFICATION_SERVICE);
        manager.notify(1, builder.build());
    }


}
