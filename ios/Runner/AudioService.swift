//
//  ViewController.swift
//  Audio Streaming
//
//  Created by Sherzod on 1/13/19.
//  Copyright © 2019 Humanz. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class AudioService: NSObject
{
    var player: AVPlayer!
    var playerItems = [String: AVPlayerItem]()
    var timeObserverToken: Any?
    var currentMetadata: [AVMetadataItem]?
    var startedPlaying: Bool = false
    var currentIndex: Int = 0
    var urlTableController: URLTableViewController!
    var interruptionTime: Double = 0
    var wasplaying: Bool = false
    var methodChannel: FlutterMethodChannel!
    
    override init()
    {
        super.init()
        self.urlTableController = URLTableViewController()
    }
    
    convenience init(_ methodChannel: FlutterMethodChannel)
    {
        self.init()
        self.methodChannel = methodChannel
    }
    
    @IBAction func playPauseAction()
    {
        if self.player == nil {
            self.prepareToPlay(self.urlTableController.streams.first?.urlString ?? "")
        } else if self.player.rate == 0.0 {
            print("Started to play")
            self.play()
        } else if self.player.rate == 1.0 {
            print("Paused")
            self.pause()
        }
    }
    
    func play()
    {
        if self.player != nil
        {
            self.player.play()
            self.wasplaying = true
        }
        else
        {
            self.prepareToPlay(self.urlTableController.streams.first?.urlString ?? "")
        }
    }
    
    func pause()
    {
        if self.player != nil
        {
            self.player.pause()
            self.wasplaying = false
        }
        else
        {
            self.prepareToPlay(self.urlTableController.streams.first?.urlString ?? "")
        }
    }
    
    @IBAction func addURL()
    {
        
    }
    
    @IBAction func nextSong()
    {
        guard self.urlTableController.streams.count != 0 else {
            return
        }
        
        print("Next Song")
        if self.currentIndex == self.urlTableController.streams.count - 1 {
            self.currentIndex = 0
        } else {
            self.currentIndex += 1
        }
        
        self.prepareToPlay(self.urlTableController.streams[self.currentIndex].urlString)
    }
    
    @IBAction func previousSong()
    {
        guard self.urlTableController.streams.count != 0 else {
            return
        }
        print("Previous Song")
        if self.currentIndex == 0 {
            self.currentIndex = self.urlTableController.streams.count - 1
        } else {
            self.currentIndex -= 1
        }
        
        self.prepareToPlay(self.urlTableController.streams[self.currentIndex].urlString)
    }
    
    
    func prepareToPlay(_ urlString: String)
    {
        guard let url = URL(string: urlString) else {
            print("Failed to make URL")
            return
        }
        if self.playerItems[urlString] == nil {
            let asset = AVAsset(url: url)
            let assetKeys = [
                "playable",
                "hasProtectedContent",
                "duration",
                "commonMetadata"
            ]
            // Create a new AVPlayerItem with the asset and an
            // array of asset keys to be automatically loaded
            self.playerItems[urlString] = AVPlayerItem(asset: asset,
                                                       automaticallyLoadedAssetKeys: assetKeys)
        }
        
        // Register as an observer of the player item's status property
        self.playerItems[urlString]!.addObserver(self,
                                                 forKeyPath: #keyPath(AVPlayerItem.status),
                                                 options: [.old, .new],
                                                 context: nil)
        
        // Associate the player item with the player
        if self.player == nil {
            print("Player init")
            self.player = AVPlayer(playerItem: self.playerItems[urlString])
            self.player.addObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), options: [.old, .new], context: nil)
            self.addPeriodicTimeObserver()
            self.setupRemoteTransportControls()
            self.setupNotifications()
        } else {
            
            self.play()
            
            self.player.replaceCurrentItem(with: self.playerItems[urlString])
            
            print("Replace item: \(urlString)")
            if self.player.currentItem!.status == .readyToPlay
            {
                print("Ready to play: \(urlString)")
                if MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] != nil
                {
                    MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0
                }
                self.startPlaying()
            }
        }
    }
    
    func addPeriodicTimeObserver() {
        //        // Invoke callback every half second
        //        let interval = CMTime(seconds: 1,
        //                              preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        //        // Queue on which to invoke the callback
        //        let mainQueue = DispatchQueue.main
        //        // Add time observer
        //        timeObserverToken =
        //            player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue) {
        //                [weak self] time in
        //                self?.currentTime.text = self?.formatTime(from: Int(self?.player.currentItem?.currentTime().seconds ?? 0))
        //                if self?.player.currentItem?.duration.isNumeric ?? false {
        //                    self?.timeline.progress = Float(time.seconds / (self?.player.currentItem?.duration.seconds ?? 1.0))
        //                }
        //        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        //super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        if keyPath == #keyPath(AVPlayerItem.status)
        {
            let status: AVPlayerItem.Status
            
            // Get the status change from the change dictionary
            if let statusNumber = change?[.newKey] as? Int
            {
                status = AVPlayerItem.Status(rawValue: statusNumber) ?? .failed
            }
            else
            {
                status = .unknown
            }
            
            // Switch over the status
            switch status
            {
            case .readyToPlay:
                print("Ready to play: \(self.currentIndex)")
                self.startPlaying()
            case .failed:
                print(self.player.currentItem?.error ?? "Not AVPlayerItem.Status.failed")
            case .unknown:
                print("State is unkown")
            }
        }
        
        if keyPath == #keyPath(AVPlayer.timeControlStatus)
        {
            if let player = object as? AVPlayer,
                let playerItem = player.currentItem
            {
                if #available(iOS 10.0, *) {
                    print("Rate: \(player.timeControlStatus.rawValue)")
                    if playerItem.status == .readyToPlay && player.timeControlStatus == .playing
                    {
                        self.setupNowPlaying(playerItem.asset.commonMetadata)
                    }
                } else {
                    if playerItem.status == .readyToPlay
                    {
                        self.setupNowPlaying(playerItem.asset.commonMetadata)
                    }
                }
            }
            else
            {
                print("Not Player Object")
            }
        }
    }
    
    func setupNotifications()
    {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleInterruption(notification:)), name: AVAudioSession.interruptionNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleAudioSessionReset(notifiaction:)), name: AVAudioSession.mediaServicesWereResetNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleNetworkInterruption(notification:)), name: .AVPlayerItemPlaybackStalled, object: nil)
    }
    
    @objc func handleAudioSessionReset(notifiaction: Notification)
    {
        print("Audio session was reseted")
    }
    
    @objc func handleNetworkInterruption(notification: Notification)
    {
        print("Network error")
    }
    
    @objc func handleInterruption(notification: Notification)
    {
        guard let typeValue = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                print("No type")
                return
        }
        
        if type == .began && self.player != nil
        {
            print("Begin")
            self.interruptionTime = self.player.currentTime().seconds
            //self.wasplaying = self.player.rate == 1.0
        }
        else if type == .ended
        {
            print("Ended")
            if let optionValue = notification.userInfo?[AVAudioSessionInterruptionOptionKey] as? UInt
            {
                print("Options")
                let option = AVAudioSession.InterruptionOptions(rawValue: optionValue)
                if option.contains(.shouldResume) && self.wasplaying
                {
                    print("Started to play")
                    self.startPlaying(CMTime(seconds: self.interruptionTime, preferredTimescale: 1))
                    print(self.interruptionTime)
                }
            }
        }
        else
        {
            print("Unkown type")
        }
    }
    
    func startPlaying(_ from: CMTime = .zero)
    {
        guard let playerItem = self.player.currentItem else {
            print("Player does not have any PlayerItem")
            return
        }
        print("Started to play")
        var error: NSError? = nil
        self.player.seek(to: from)
        
        //        if playerItem.duration.isNumeric {
        //            self.endTime.text = formatTime(from: Int(playerItem.duration.seconds))
        //            self.timeline.progress = 0
        //        } else {
        //            self.endTime.text = "Live"
        //            self.timeline.progress = 1
        //        }
        
        if playerItem.asset.statusOfValue(forKey: "commonMetadata", error: &error) != .loaded
        {
            playerItem.asset.loadValuesAsynchronously(forKeys: ["commonMetadata"]) {
                let status = playerItem.asset.statusOfValue(forKey: "commonMetadata", error: &error)
                switch status
                {
                case .loaded:
                    print("Loaded")
                    self.setupNowPlaying(playerItem.asset.commonMetadata, true)
                case .failed:
                    print("Failed")
                case .cancelled:
                    print("Canceled")
                default:
                    print("Something")
                }
            }
        }
        else
        {
            self.setupNowPlaying(playerItem.asset.commonMetadata)
        }
        
        self.play()
    }
    
    func formatTime(from seconds: Int) -> String
    {
        let sec: Int = seconds % 60
        let min: Int = seconds / 60
        return "\(min):\(sec)"
    }
    
    func setupNowPlaying(_ metadata: [AVMetadataItem], _ isInitial: Bool = false) {
        guard let playerItem = self.player.currentItem else {
            print("Player does not have any PlayerItem")
            return
        }
        //var error: NSError? = nil
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()

        for item in metadata {
            if item.commonKey == AVMetadataKey.commonKeyTitle {
                nowPlayingInfo[MPMediaItemPropertyTitle] = item.stringValue
            }
            if item.commonKey == AVMetadataKey.commonKeyArtist {
                nowPlayingInfo[MPMediaItemPropertyArtist] = item.stringValue
            }
        }

        print("Control elapsed: \(player.currentTime().seconds)")
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime().seconds

        if playerItem.asset.duration.isNumeric {
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = playerItem.asset.duration.seconds
        } else {
            if #available(iOS 10.0, *) {
                nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = true
            } else {
                nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = 0
            }
        }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.timeControlStatus == .playing

        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        
        
        self.methodChannel.invokeMethod("updateNowPlayingInfo", arguments: nowPlayingInfo)
    }
    
    func setupRemoteTransportControls() {
        guard self.player != nil else {
            print("No Player")
            return
        }
        UIApplication.shared.beginReceivingRemoteControlEvents()
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.player.rate == 0.0 {
                print("Command Play")
                self.play()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.player.rate == 1.0 {
                print("Command Pause")
                self.play()
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            self.nextSong()
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            self.previousSong()
            return .success
        }
    }
}

