//
//  MediaPlayer.swift
//  Capstone
//
//  Created by Aidan Madden on 12/10/17.
//  Copyright © 2017 Aidan Madden. All rights reserved.
//

import Foundation

protocol MediaPlayerDelegate: class {
    func mediaPlayerDidFinishTrack()
    func mediaPlayerDidFail(error: Error)
    func mediaPlayerDidStartPlaying(track: SPTTrack)
    func mediaPlayerDidPause()
    func mediaPlayerDidChange(trackProgress: Double)
    func mediaPlayerDidResume()
}

class MediaPlayer: NSObject {
    
    static let shared = MediaPlayer()
    private override init() {}
    weak var delegate: MediaPlayerDelegate?
    private var player: SPTAudioStreamingController?
    private (set) var currentTrack: SPTPartialTrack?
    var isPlaying: Bool {
        if let player = player,
            let state = player.playbackState {
            return state.isPlaying
        }
        return false
    }
    
    func loadTrack(url: String, completion: @escaping (_ track: SPTTrack?, _ error: Error?) -> Void) {
        SPTTrack.track(withURI: URL(string:url), accessToken: token, market: nil) { (error,response) in
            completion(response as? SPTTrack, error)
        }
    }
    
    func play(track: SPTTrack) {
    
        
        player?.playSpotifyURI("spotify:track:27eO3EGKIUU7yug1eOxUZu", startingWith: 0, startingWithPosition: 0, callback: { (error) in
            if let error = error {
                self.delegate?.mediaPlayerDidFail(error: error)
                print("yeah not working")
            } else {
                self.currentTrack = track
                self.delegate?.mediaPlayerDidStartPlaying(track: track)
                print("yeah working")

            }
        })
    }
    
    func seek(to progress: Float) {
        guard let current = currentTrack else {return}
        player?.seek(to: Double(progress) * current.duration, callback: { (error) in
            if let error = error {
                self.delegate?.mediaPlayerDidFail(error: error)
            }
        })
    }
    
    func resume() {
        player?.setIsPlaying(true, callback: { (error) in
            if let error = error {
                self.delegate?.mediaPlayerDidFail(error: error)
            } else {
                self.delegate?.mediaPlayerDidResume()
            }
        })
    }
    
    func pause() {
        player?.setIsPlaying(false, callback: { (error) in
            if let error = error {
                self.delegate?.mediaPlayerDidFail(error: error)
            } else {
                self.delegate?.mediaPlayerDidPause()
            }
        })
    }
    
    func configurePlayer(authSession: SPTSession, id: String) {
        if self.player == nil {
            self.player = SPTAudioStreamingController.sharedInstance()
            self.player!.playbackDelegate = self
            self.player!.delegate = self
            try! player?.start(withClientId: id)
            self.player!.login(withAccessToken: token)
            let test = self.player?.loggedIn
            let test2 = self.player?.playbackState
            print(test!)
            print(test2.debugDescription)
       //     let log = self.player?.loggedIn
          //  let test = self.player?.playbackState
        //    let w = test?.isActiveDevice
        //    print(w!)
        //    print(log!)
        }
    }
    
}

extension MediaPlayer: SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePosition position: TimeInterval) {
        delegate?.mediaPlayerDidChange(trackProgress: position/currentTrack!.duration)
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        print("logged in")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: String!) {
        delegate?.mediaPlayerDidFinishTrack()
    }
    
}
