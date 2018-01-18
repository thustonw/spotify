//
//  JoinViewController.swift
//  Capstone
//
//  Created by Aidan Madden on 11/20/17.
//  Copyright © 2017 Aidan Madden. All rights reserved.
//

import UIKit
import Firebase
var roomCode2 = ""

class JoinViewController: UIViewController {
    
    @IBOutlet weak var error: UILabel!
    @IBOutlet weak var roomCode: UITextField!
    @IBAction func joinRoom(_ sender: Any) {
        ref.child("rooms").observeSingleEvent(of: .value, with: { (snapshot) in
            if(snapshot.exists()) {
                if(snapshot.hasChild(self.roomCode.text!)){
                    print(self.roomCode.text!)
                    let text = self.roomCode.text!
                    code2 = text
                    self.performSegue(withIdentifier: "join_to_playlist", sender: self)
                }
                else{
                    self.error.text = "No room with that code exists."
                }
        
            } else {
                print("does not exits")
            }
        })
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roomCode2 = self.roomCode.text!
        ref = Database.database().reference()

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

