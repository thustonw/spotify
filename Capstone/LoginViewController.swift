//
//  LoginViewController.swift
//  Capstone
//
//  Created by Aidan Madden on 11/20/17.
//  Copyright © 2017 Aidan Madden. All rights reserved.
//
import UIKit
import SpotifyLogin
import FirebaseDatabase

var number = String()

class LogInViewController: UIViewController {
    struct GlobalVariable{
        static var myString = String()
    }
    @IBOutlet weak var anon: UISwitch!
    @IBOutlet weak var header1: UILabel!
    @IBOutlet weak var header2: UILabel!
    @IBOutlet weak var header3: UILabel!
    @IBOutlet weak var createRoom: UIButton!
    @IBOutlet weak var djName: UITextField!
    @IBOutlet weak var roomCode: UILabel!
    @IBOutlet weak var welcome: UILabel!
    
    var loginButton: UIButton?
    
    @IBAction func createRoomAction(_ sender: Any) {
        let hostVC = storyboard?.instantiateViewController(withIdentifier: "HostViewController") as! HostViewController
        var ref: DatabaseReference?
        ref = Database.database().reference()
        let num = String(number)
        let name = djName.text
        ref?.child("rooms").child(num).child("djName").setValue(djName.text)
        ref?.child("rooms").child(num).child("songNumber").setValue(0)
        roomCode.text = String(num)
        code = num
        hostVC.djName = name!
        navigationController?.pushViewController(hostVC, animated: true)
        let room = UIRoom()
        room.roomName = num
        GlobalVariable.myString = num
    }
 
    @objc func switchValueDidChange(sender:UISwitch!) {
        if sender.isOn {
            djName.text = "Anonymous"
            djName.isUserInteractionEnabled = false
        } else {
            djName.text = ""
            djName.isUserInteractionEnabled = true
        }

    }
    
   @objc func logoutAction(_ sender: Any) {
        SpotifyLogin.shared.logout()
        self.showLoginFlow()
        self.navigationItem.rightBarButtonItem = nil
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        anon.isOn = false
        createRoom.layer.cornerRadius = 10
        createRoom.layer.masksToBounds = true
        anon.addTarget(self, action: #selector(self.switchValueDidChange), for: .valueChanged)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loginSuccessful),
                                               name: .SpotifyLoginSuccessful,
                                               object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SpotifyLogin.shared.getAccessToken { [weak self] (token, error) in
            if error != nil, token == nil {
                self?.showLoginFlow()
            }
            else{
                let text = self?.randomizeAvailableLetters(tileArraySize: 4)
                let stringRepresentation = text?.joined()
                number = stringRepresentation!
                self?.roomCode.text = number
                self?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(self?.logoutAction(_:)))
            }
    
        }
    }
    
    func showLoginFlow() {
        let button = SpotifyLoginButton(viewController: self,
                                        scopes: [
                                            .playlistModifyPrivate,
                                            .playlistModifyPublic,
                                             .streaming,
                                            .userReadTop,
                                            .playlistReadPrivate,
                                            .userLibraryRead])
        
        view?.backgroundColor = UIColor(named: "black")
        welcome.isHidden = true
        header1.isHidden = true
        header2.isHidden = true
        header3.isHidden = true
        anon.isHidden = true
        djName.isHidden = true
        roomCode.isHidden = true
        createRoom.isHidden = true
        
        self.view.addSubview(button)
        self.loginButton = button
  
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        loginButton?.center = self.view.center
    }

    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    @objc func loginSuccessful() {
        view?.backgroundColor = UIColor(named: "black")
        welcome.isHidden = false
        header1.isHidden = false
        header2.isHidden = false
        header3.isHidden = false
        anon.isHidden = false
        djName.isHidden = false
        roomCode.isHidden = false
        createRoom.isHidden = false
        self.loginButton?.removeFromSuperview()
        
    }
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }

    func randomizeAvailableLetters(tileArraySize: Int) -> Array<String> {
        let alphabet: [String] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
        var availableTiles = [String]()
        for _ in 0..<tileArraySize {
            let rand = Int(arc4random_uniform(26))
            availableTiles.append(alphabet[rand])
        }
        return(availableTiles)
    }
    
    
}

