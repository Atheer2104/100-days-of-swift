//
//  ViewController.swift
//  ProjectTwo
//
//  Created by Atheer on 2019-05-09.
//  Copyright © 2019 Atheer. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    
    var countries = [String]()
    var score = 0
    var correctAnswer = 0
    var asked = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countries += ["estonia", "france", "germany", "ireland", "italy",
        "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
        
        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1
        
        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor
        
        askQuestion()
    }
    
    // we give action type of uialertaction and has a default value of nil 
    func askQuestion(action: UIAlertAction! = nil) {
        countries.shuffle()
        // create random int from 0 to 2
        correctAnswer = Int.random(in: 0...2)
        
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        
        title = countries[correctAnswer].uppercased() + " Current score: \(score)"
    }
    
    @IBAction func ButtonTapped(_ sender: UIButton) {
        var title: String
        var message: String
        asked += 1
        
        if asked == 2 {
            title = "Game Ended"
            message = "Your final score is \(score)"
            
            let final = UIAlertController(title: title, message: message, preferredStyle: .alert)
            final.addAction(UIAlertAction(title: "Continue", style: .default, handler: nil))
            present(final, animated: true)
            
            score = 0
        }
        
        if sender.tag == correctAnswer {
            score += 1
            title = "Correct"
            message = "Your score is \(score)"
        }else {
            score -= 1
            title = "Wrong"
            message = "Wrong! That’s the flag of \(countries[sender.tag])"
            let wrong = UIAlertController(title: title, message: message, preferredStyle: .alert)
            wrong.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
            present(wrong, animated: true)
            
            message = "Your score is \(score)"
        }

        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
        
        present(ac, animated: true)
        
        
        
    }
    

}

