//
//  ViewController.swift
//  swift3Calculator
//
//  Created by Jiajun Wu on 08/30/2017.
//  Copyright © 2017 Jiajun Wu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private var calculatorBrain = CalculatorBrain()
    
    @IBOutlet weak var display: UILabel!
    
    var displayValue: Double{
        get{
            return Double(display.text!)!
        }
        set{
            display.text = String(newValue)
        }
    }
    
    var isTypingDigit = false
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let displayText = display.text!
        
        let touchedDigit = sender.currentTitle!
        
        if isTypingDigit{
            display.text = displayText + touchedDigit
        }else{
            display.text = touchedDigit
        }
        
        isTypingDigit = true
    }
    
    @IBAction func preformOperation(_ sender: UIButton) {
        isTypingDigit = false
        
        let touchedOperation = sender.currentTitle!
        
        switch touchedOperation {
        case "C":
            display.text = "0"
        default:
            break
        }
    }
}

