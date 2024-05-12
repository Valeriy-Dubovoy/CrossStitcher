//
//  ViewController.swift
//  Cross Stitcher
//
//  Created by zappycode on 6/13/18.
//  Copyright © 2018 Nick Walter. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var myFirstLabel: UILabel!
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        count = count + 1
        myFirstLabel.text = String(count)
        
        if count >= 10 {
            view.backgroundColor = UIColor.green
        }
    }
    
}

