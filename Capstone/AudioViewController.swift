//
//  AudioViewController.swift
//  Capstone
//
//  Created by Aidan Madden on 11/22/17.
//  Copyright © 2017 Aidan Madden. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class AudioViewController: UIViewController{
    var image = UIImage()
    var mainSongTitle = String()
    var URI = String()
    var artist = String()
    var duration = Int()
    var roomCode = ""
    var ref: DatabaseReference?
    var databaseHandler1: DatabaseHandle?
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    let room = UIRoom()
    
    
    override func viewDidLoad() {
        songTitle.text = mainSongTitle
        background.image = image
        mainImageView.image = image
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Song", style: .plain, target: self, action: #selector(self.addSong(_:)))
        ref = Database.database().reference()

    }
    @objc func addSong(_ sender: Any) {
        let alert = UIAlertController(title: "Add Song to Playlist", message: "", preferredStyle: .alert)
        let firstAction = UIAlertAction(title: "Popular Queue", style: .default){ (action)
            in
            self.popularQueue(self)
        }

        alert.addAction(firstAction)
        present(alert, animated: true, completion: nil)
    }
    @objc func popularQueue(_ sender: Any){
    
        self.ref?.child("rooms").child(LogInViewController.GlobalVariable.myString).child("songs").child(self.URI).child("artist").setValue(self.artist)
        
        self.ref?.child("rooms").child(LogInViewController.GlobalVariable.myString).child("songs").child(self.URI).child("length").setValue(self.duration)
        self.ref?.child("rooms").child(LogInViewController.GlobalVariable.myString).child("songs").child(self.URI).child("title").setValue(self.mainSongTitle)
        
        self.ref?.child("rooms").child(LogInViewController.GlobalVariable.myString).child("songs").child(self.URI).child("uri").setValue(self.URI)
        self.ref?.child("rooms").child(LogInViewController.GlobalVariable.myString).child("songs").child(self.URI).child("votes").setValue(0)
        
        if let navController = self.navigationController {
            for controller in navController.viewControllers {
                if controller is HostViewController {
                    navController.popToViewController(controller, animated:true)
                    break
                }
            }
        }
    }
        
}

