
import UIKit
import Firebase
var code2 = ""
var run = 0
class rows2: UITableViewCell{
    
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    @IBOutlet weak var votes: UITextField!
    @IBOutlet weak var cellURI: UILabel!
    @IBAction func upvote(_ sender: Any) {
        var votes = Int(self.votes.text!)
        votes = votes! + 1
    ref?.child("rooms").child(code2).child("songs").child(cellURI.text!).child("votes").setValue(votes!)
        self.votes.text = String(votes!)
        upButton.isEnabled = false
        downButton.isEnabled = true
        

    }
    
    @IBAction func downvote(_ sender: Any) {
        var votes = Int(self.votes.text!)
        votes = votes! - 1
    ref?.child("rooms").child(code2).child("songs").child(cellURI.text!).child("votes").setValue(votes!)
        self.votes.text = String(votes!)
        upButton.isEnabled = true
        downButton.isEnabled = false
    }
}

class PlaylistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var songData = [String]()
    @IBOutlet weak var room: UILabel!
    @IBOutlet weak var table: UITableView!
    struct song2 {
        let name: String!
        let URI: String!
        let duration: String!
        let votes: String!
    }
    var songs2 = [song2]()

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.table.reloadData()
     //   ref = Database.database().reference()
    }
    
    @objc func addSong(_ sender: Any) {
        let searchVC = storyboard?.instantiateViewController(withIdentifier: "JoinSearchViewController") as! JoinSearchViewController
        navigationController?.pushViewController(searchVC, animated: true)
        ref.removeAllObservers()
        print("runn")

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Song", style: .plain, target: self, action: #selector(self.addSong(_:)))
        ref.child("rooms").child(code2).child("songs").observeSingleEvent(of: .value){(snap) in
            print("running")
            self.songs2.removeAll()
            let arraySize = Int(snap.childrenCount)
            print(arraySize)
            
            for child in snap.children.allObjects as! [DataSnapshot]{
                self.songData.removeAll()
                for element in child.children.allObjects as! [DataSnapshot]{
                    let rawValue = "\(element.value!)"
                    self.songData.append(rawValue)
                }
                
                self.songs2.append(song2.init(name: self.songData[2] ,URI: self.songData[3] , duration: self.songData[1],votes: self.songData[4]))
                }
            }
           
        
        ref = Database.database().reference()
        room.text = "Room: \(code2)"
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs2.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! rows2
        let mainLabel = cell.viewWithTag(1) as! UILabel
        let hiddenURI = cell.viewWithTag(2) as! UILabel
        let vote = cell.viewWithTag(3) as! UITextField
        mainLabel.text = songs2[indexPath.row].name
        hiddenURI.text = songs2[indexPath.row].URI
        vote.text = songs2[indexPath.row].votes
        
        return cell
    }
    
    
}


