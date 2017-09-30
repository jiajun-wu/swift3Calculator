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
        
        //calculatorBrain.addUnaryOperation(named: String, 0){
            
       // }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private var calculatorBrain = CalculatorBrain()
    
    @IBOutlet weak var display: UILabel!
    
    // Computed propertity with get and set
    var displayValue: Double{
        get{
            return Double(display.text!)!
        }
        set{
            display.text = String(newValue)
        }
    }
    
    var isTypingDigit = false, decimaiIsTouched = false
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let displayText = display.text!
        
        var touchedDigit = String()
        
        let whatIsTouched = sender.currentTitle!
        
        // check and control the user presses the decimal point for multiple times
        if decimaiIsTouched == false && whatIsTouched == "."{
            decimaiIsTouched = true
            touchedDigit = whatIsTouched
        }else if decimaiIsTouched == true && whatIsTouched == "."{
            touchedDigit = ""
        }else{
            touchedDigit = whatIsTouched
        }
        
        if isTypingDigit{
            display.text = displayText + touchedDigit
        }else{
            display.text = touchedDigit
        }
        
        isTypingDigit = true
        
    }
    
    @IBAction func preformOperation(_ sender: UIButton) {
        decimaiIsTouched = false
        
        if isTypingDigit{
            calculatorBrain.setOperand(displayValue)
            isTypingDigit = false
        }
        
        if let mathematicalSymbol = sender.currentTitle{
            calculatorBrain.preformOperation(mathematicalSymbol)
        }
        
        displayValue = calculatorBrain.result
    }
    
    @IBOutlet weak var variable: UITextField!
    @IBOutlet weak var variableValue: UITextField!
    
    @IBAction func use(_ sender: UIButton) {
        variableValue.text! = ""
        calculatorBrain.setOperant(variable.text!)
        displayValue = calculatorBrain.variableValues[variable.text!]!
        
    }
    
    @IBAction func create(_ sender: UIButton) {
        calculatorBrain.addVariable(variableName: variable.text!, value: Double(variableValue.text!)!)
    }
    
    @IBAction func undo(_ sender: UIButton) {
        
    }
}

