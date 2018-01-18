//
//  HostViewController.swift
//  Capstone
//
//  Created by Aidan Madden on 11/20/17.
//  Copyright © 2017 Aidan Madden. All rights reserved.
//

import UIKit
import SpotifyLogin
import Firebase
import Alamofire
import AVFoundation
var ref: DatabaseReference!
var code = ""
class rows: UITableViewCell{
    
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    @IBOutlet weak var votes: UITextField!
    @IBOutlet weak var cellURI: UILabel!
    
    @IBAction func upvote(_ sender: Any) {
        ref = Database.database().reference()
        var votes = Int(self.votes.text!)
        votes = votes! + 1
    ref?.child("rooms").child(code).child("songs").child(cellURI.text!).child("votes").setValue(votes!)
        self.votes.text = String(votes!)
    }
    
    @IBAction func downvote(_ sender: Any) {
        var votes = Int(self.votes.text!)
        votes = votes! - 1
    ref?.child("rooms").child(code).child("songs").child(cellURI.text!).child("votes").setValue(votes!)
        self.votes.text = String(votes!)
    }
}

struct song {
    let name: String!
    let URI: String!
    let duration: String!
    let votes: String!
}
var songs = [song]()

class HostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var data = String()
    var image = UIImage()
    var mainSongTitle = String()
    var songCount = 0
    var roomCode = ""
    var djName = ""
    var songData = [String]()
    fileprivate var track: SPTTrack!
    @IBOutlet weak var welcome: UILabel!
    @IBOutlet weak var hostedBy: UILabel!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var playerButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    
    
    @IBAction func play(_ sender: Any) {
        if playerButton.currentImage == #imageLiteral(resourceName: "play.png") {
            playerButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        } else{
            playerButton.setImage(#imageLiteral(resourceName: "play.png"), for: .normal)
        }
        MediaPlayer.shared.loadTrack(url: "spotify:track:451GvHwY99NKV4zdKPRWmv") {[weak self] (track, error) in
            guard let `self` = self else {return}
            print(`self`)
            guard let track = track, error == nil else {
                print("track not loading")
                return
            }
            self.track = track
            self.infoLabel.text = track.name
            self.playerView.reloadInputViews()
            print(track)
            MediaPlayer.shared.play(track: track)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ref = Database.database().reference()
        self.table.reloadData()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Song", style: .plain, target: self, action: #selector(self.addSong(_:)))
    }
    override func viewDidLoad() {
        let user = SpotifyLogin.shared.username
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let someDateTime = formatter.date(from: "2017/12/10 14:41")
        let session = SPTSession.init(userName: user, accessToken: token, expirationDate: someDateTime)
        MediaPlayer.shared.configurePlayer(authSession: session!, id: "58c49f01f0c2403abac1de918f4223c0")
        MediaPlayer.shared.delegate = self
        
        
        
        ref = Database.database().reference()
        super.viewDidLoad()
        ref.child("rooms").child(code).child("songs").observe(.childAdded) { (snapshot) in
            let change = snapshot.key
            self.songData.removeAll()
            ref.child("rooms").child(code).child("songs").child(change).observe(.value){ (songAdded) in
                let enumerator = songAdded.children
                while let rest = enumerator.nextObject() as? DataSnapshot {
                    let rawValue = "\(rest.value!)"
                    self.songData.append(rawValue)
                }
                songs.append(song.init(name: self.songData[2] ,URI: self.songData[3] , duration: self.songData[1],votes: self.songData[4]))
                
                for elements in songs{
                    print(elements)
                }
            }
            
            ref.child("rooms").child(code).child("songs").child(change).observe(.childChanged){ (voteChange) in
                
                let new = voteChange.key
                print("we got a new vote!: \(new)")
            }
            
        }
        welcome.text = "Room \(code)"
        hostedBy.text = "Hosted by DJ \(djName)"

    }
    @objc func addSong(_ sender: Any) {
        let searchVC = storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! rows
        let mainLabel = cell.viewWithTag(1) as! UILabel
        let hiddenURI = cell.viewWithTag(2) as! UILabel
        mainLabel.text = songs[indexPath.row].name
        hiddenURI.text = songs[indexPath.row].URI
        
        return cell
    }
}

extension HostViewController: MediaPlayerDelegate {
    
    func mediaPlayerDidStartPlaying(track: SPTTrack) {
        print("here")
    }
    
    func mediaPlayerDidChange(trackProgress: Double) {
        progressSlider.setValue(Float(trackProgress), animated: true)
    }
    
    func mediaPlayerDidPause() {
        
    }
    
    func mediaPlayerDidResume() {
        
    }
    
    func mediaPlayerDidFail(error: Error) {
        showDefaultError()
        MediaPlayer.shared.pause()
//        updatePlayButton(playing: false)
    }
    
    func mediaPlayerDidFinishTrack() {
//        updatePlayButton(playing: false)
        progressSlider.setValue(0, animated: false)
    }
    
    fileprivate func showDefaultError() {
        let alert = UIAlertController(title: "Oops", message: "Something went wrong. Please try again.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("run")
        ref.removeAllObservers()
    }
    
}



