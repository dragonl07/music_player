import UIKit
import Flutter
import RealmSwift
import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate
{
    var audioService: AudioService!
    
    override func application(_ application: UIApplication,didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        GeneratedPluginRegistrant.register(with: self)
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch{
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
            print(error.localizedDescription)
        }
        let realm = try! Realm()
        if realm.isEmpty
        {
            try! realm.write {
                realm.add(StreamObject("http://www.topmusic.uz/get/track-272203.mp3", "Remedy"))
                realm.add(StreamObject("http://www.topmusic.uz/get/track-272202.mp3", "Walk On Water"))
                realm.add(StreamObject("http://www.topmusic.uz/get/track-272198.mp3", "Rescue Me"))
            }
        }
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let methodChannel = FlutterMethodChannel(name: "audio_service", binaryMessenger: controller)
        let dataChannel = FlutterMethodChannel(name: "data_service", binaryMessenger: controller)
        
        self.audioService = AudioService(methodChannel)
        
        methodChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            switch call.method
            {
            case "play":
                self?.audioService.play(StreamObject.mapJson(call.arguments as? String))
                result("onPlay")
            case "pause":
                self?.audioService.pause()
                result("onPause")
            case "next":
                print("Flutter next")
                self?.audioService.nextSong()
                result("onPlay")
            case "prev":
                self?.audioService.previousSong()
                result("onPlay")
            default: result(FlutterMethodNotImplemented)
            }
        })
        
        dataChannel.setMethodCallHandler {
            [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            switch call.method
            {
            case "getData":
                let streams = self!.audioService.urlTableController.streams
                let data = StreamObject.generateFlutterData(streams)
                result(data)
            default: result(FlutterMethodNotImplemented)
            }
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
