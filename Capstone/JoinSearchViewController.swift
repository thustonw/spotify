//
//  JoinSearchViewController.swift
//  Capstone
//
//  Created by Aidan Madden on 12/10/17.
//  Copyright © 2017 Aidan Madden. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SpotifyLogin

struct post2 {
    let mainImage: UIImage!
    let name: String!
    let URI: String!
    let artist: String!
    let duration: Int!
}

class JoinSearchViewController: UITableViewController, UISearchBarDelegate{
    
   
    @IBOutlet weak var searchBar: UISearchBar!
    var posts2 = [post2]()
    var searchURL = String()
    var artist = String()
    var int = Int()
    
    typealias JSONStandard = [String: AnyObject]
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let keywords = searchBar.text
        let finalKeywords = keywords?.replacingOccurrences(of: " ", with: "+")
        searchURL = "https://api.spotify.com/v1/search?q=\(finalKeywords!))&type=track"
        callAlamo(url: searchURL)
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callAlamo(url: searchURL)
    }
    
    func callAlamo(url: String){
        SpotifyLogin.shared.getAccessToken { (accessToken, error) in
            token = accessToken!
        }
        Alamofire.request(url, method: .get, parameters: ["q":"", "type":"track"], encoding: URLEncoding.default, headers: ["Authorization": "Bearer \(token)"]).responseJSON(completionHandler: {
            response in
            self.parseData(JSONData: response.data!)
        })
    }
    
    func parseData(JSONData: Data){
        do {
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
            if let tracks = readableJSON["tracks"] as? JSONStandard{
                if let items = tracks["items"] as? [JSONStandard]{
                    for i in 0..<items.count {
                        let item = items[i]
                        print(item)
                        let name = item["name"] as! String
                        let URI = item["uri"] as! String
                        let duration = item["duration_ms"] as! Int
                        if let artists = item["artists"] as? NSArray{
                            var text = artists.description
                            if text.contains("name"){
                                let startIndex = text.range(of: "name = ",range: nil, locale: nil)!.upperBound
                                let endIndex = text.range(of: "type",range: nil, locale: nil)!.lowerBound
                                let newStr = text[startIndex..<endIndex]
                                text = newStr.description
                                text = text.replacingOccurrences(of: ";", with: "")
                                text = text.replacingOccurrences(of: "\n", with: "")
                                artist = text
                            }
                        }
                        if let album = item["album"] as? JSONStandard{
                            if let images = album["images"] as? [JSONStandard]{
                                let imageData = images[0]
                                let mainImageURL = URL(string: imageData["url"] as! String)
                                let mainImageData = NSData(contentsOf: mainImageURL!)
                                let mainImage = UIImage(data: mainImageData! as Data)
                                posts2.append(post2.init(mainImage: mainImage, name: name, URI: URI,artist: artist, duration: duration))
                                self.tableView.reloadData()
                                
                            }
                        }
                        
                    }
                }
            }
        }
        catch{
            print(error)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts2.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        let mainImageView = cell?.viewWithTag(2) as! UIImageView
        mainImageView.image = posts2[indexPath.row].mainImage
        let mainLabel = cell?.viewWithTag(1) as! UILabel
        mainLabel.text = posts2[indexPath.row].name
        let queueVC = storyboard?.instantiateViewController(withIdentifier: "HostViewController") as! HostViewController
        queueVC.image = posts2[indexPath.row].mainImage
        queueVC.mainSongTitle = posts2[indexPath.row].name
        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = self.tableView.indexPathForSelectedRow?.row
        let vc = segue.destination as! JoinAudioViewController
        vc.image = posts2[indexPath!].mainImage
        vc.mainSongTitle = posts2[indexPath!].name
        vc.URI = posts2[indexPath!].URI
        vc.artist = posts2[indexPath!].artist
        vc.duration = posts2[indexPath!].duration
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
