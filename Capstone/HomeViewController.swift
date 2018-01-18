//
//  HomeViewController.swift
//  Capstone
//
//  Created by Aidan Madden on 11/20/17.
//  Copyright © 2017 Aidan Madden. All rights reserved.
//
import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var host: UIButton!
    @IBOutlet weak var join: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        host.layer.cornerRadius = 10
        host.layer.masksToBounds = true
        join.layer.cornerRadius = 10
        join.layer.masksToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

