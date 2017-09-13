//
//  CalculatorBrain.swift
//  swift3Calculator
//
//  Created by Jiajun Wu on 08/31/2017.
//  Copyright © 2017 Jiajun Wu. All rights reserved.
//

import Foundation

struct CalculatorBrain{
    private var accumulator = 0.0
    
    private var currentMemory = 0.0
    
    private var internalProgram = [AnyObject]()
    
    private var equalsButtonIsTouched = false
    
    private var history = String()
    
    private var historyDictionary = [Any]()
    
    private var C_Clear = false, AC_Clear = false
    
    // mutating the accumulator value to be whatever the value is passed in
    mutating func setOperand(_ operand: Double){
        // reset the clear (C) button
        C_Clear = false; AC_Clear = false
        
        historyDictionary.append(operand)
        accumulator = operand
        
        internalProgram.append(operand as AnyObject)
    }
    
    // create a dicitionary list of all the operations
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.Constant(Double.pi),
        "e": Operation.Constant(M_E),
        "√": Operation.UnaryOperation(.Prefix("√")){sqrt($0)},
        "sin": Operation.UnaryOperation(.Prefix("sin")){sin($0*Double.pi/180)},
        "cos": Operation.UnaryOperation(.Prefix("cos")){cos($0*Double.pi/180)},
        "tan": Operation.UnaryOperation(.Prefix("tan")){tan($0*Double.pi/180)},
        "±": Operation.UnaryOperation(.Prefix("±")){-$0},
        "%": Operation.UnaryOperation(.Postfix("%")){$0/100},
        "x²": Operation.UnaryOperation(.Postfix("²")){$0*$0},
//        "+": Operation.BinaryOperation({ (op1: Double, op2: Double)->Double in op1*op2 }),
        "+": Operation.BinaryOperation{$0+$1},
        "-": Operation.BinaryOperation{$0-$1},
        "×": Operation.BinaryOperation{$0*$1},
        "÷": Operation.BinaryOperation{$0/$1},
        "MS": Operation.preformMemory("MemoryStore"),
        "MC": Operation.preformMemory("MemoryClear"),
        "MR": Operation.preformMemory("MemoryRecall"),
        "M+": Operation.preformMemory("MemoryAdd"),
        "M-": Operation.preformMemory("MemoryMinus"),
        
        "=": Operation.Equals,
        "C": Operation.Clear
    ]
    
    private enum Operation{
        case Constant(Double)
        case UnaryOperation(printSymbol, (Double)->Double)
//        case UnaryOperation((Double)->Double)
        case BinaryOperation((Double, Double)->Double)
        case preformMemory(String)
        case Equals
        case Clear
        
        enum printSymbol {
            case Postfix(String)
            case Prefix(String)
        }
    }
    
    // preform operation functions
    mutating func preformOperation(_ symbol: String){
        internalProgram.append(symbol as AnyObject)
        
        if let operation = operations[symbol]{
            switch operation {
                case .Constant(let value):
                    accumulator = value
                    historyDictionary.append(symbol)
                    
                case .UnaryOperation(_, let function):
                    accumulator = function(accumulator)
                    historyDictionary.append(symbol)
                    
                case .BinaryOperation(let function):
                    executePendingBinaryOperation()
                    pending = PendindBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                    historyDictionary.append(symbol)
                
                case .preformMemory(let memoryOption):
                    switch memoryOption {
                    case "MemoryStore":
                        currentMemory = accumulator
                    case "MemoryRecall":
                        accumulator = currentMemory
                    case "MemoryClear":
                        currentMemory = 0.0
                    case "MemoryAdd":
                        currentMemory += accumulator
                    case "MemoryMinus":
                        currentMemory -= accumulator
                    default:
                        break
                }
                    
                case .Clear:
                    clear()
                    
                case .Equals:
                    equalsButtonIsTouched = true
                    executePendingBinaryOperation()
                    printHistory()
            }
        }
    }
    
    //  execute the result when equals button is touched
    private mutating func executePendingBinaryOperation(){
        if pending != nil{
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
            
            if equalsButtonIsTouched {
                historyDictionary.append("=\(String(accumulator))")
                equalsButtonIsTouched=false
            }
        }
    }
    
    private var pending: PendindBinaryOperationInfo?
    
    // creating a pass by value struct that gets a copy of the function and the first operand
    private struct PendindBinaryOperationInfo{
        // free initializer from struct, don't need to initial any value to it
        var binaryFunction:(Double, Double)->Double
        var firstOperand: Double
    }
    
    // typealias: let you create a type that is exacty the same as other type
    typealias PropertyList = AnyObject
    
    var program: PropertyList{
        get{
            return internalProgram as CalculatorBrain.PropertyList
        }
        set{
            clear()
            
            if let arrayOfOpreationsAndOperands = newValue as? [AnyObject]{
                for operationsAndOperands in arrayOfOpreationsAndOperands{
                    if let operand = operationsAndOperands as? Double{
                        setOperand(operand)
                    }else if let operation = operationsAndOperands as? String{
                        preformOperation(operation)
                    }
                }
            }
        }
    }
    
    // check and control click clear button once or twice
    private mutating func clear(){
        if C_Clear==false && AC_Clear==false {
            C_Clear = true
            accumulator = 0
            if !historyDictionary.isEmpty{
                historyDictionary.removeLast()
            }
        }else if C_Clear==true && AC_Clear==false{
            AC_Clear = true
            accumulator = 0
            pending = nil
            historyDictionary.removeAll()
        }else if C_Clear==true && AC_Clear==true {
            C_Clear = false; AC_Clear = false
            
        }
    }
    
    // print out calculation history in console
    private mutating func printHistory(){
        for operationsAndOperands in historyDictionary{
            if let operand = operationsAndOperands as? Double{
                history += String(operand)
            }else if let operation = operationsAndOperands as? String{
                if let symbol = operations[operation]{
                    switch symbol {
                        case .UnaryOperation(let theSymbol, _):
                            switch theSymbol {
                                case .Prefix(let printTheSymbol):
                                    history = printTheSymbol + "(" + history + ")"
                                case .Postfix(let printTheSymbol):
                                    history = "(" + history + ")" + printTheSymbol
                            }
                        case .BinaryOperation, .Constant:
                            history += operation
                        default:
                            break
                    }
                }else{
                    history += operation
                }
            }
        }
        print(history)
        history = String()
        historyDictionary.removeAll()
    }
    
    // Read-Only Computed Properties, return result to display
    var result:Double{
        return accumulator
    }
}
