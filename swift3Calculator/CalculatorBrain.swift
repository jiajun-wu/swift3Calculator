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
    
    private var equalsIsTouched = false
    
    private var history = String()
    
    private var historyDictionary = [Any]()
    
    private var C_Clear = false, AC_Clear = false
    
    mutating func setOperand(_ operand: Double){
        C_Clear = false; AC_Clear = false
        historyDictionary.append(operand)
        accumulator = operand
        
        internalProgram.append(operand as AnyObject)
    }
    
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
        "MC": Operation.MemoryClear,
        "MR": Operation.MemoryRecall,
        "M+": Operation.MemoryAdd,
        "M-": Operation.MemoryMinus,
        "MS": Operation.MemoryStore,
        
        "=": Operation.Equals,
        "C": Operation.Clear
    ]
    
    private enum Operation{
        case Constant(Double)
        case UnaryOperation(printSymbol, (Double)->Double)
//        case UnaryOperation((Double)->Double)
        case BinaryOperation((Double, Double)->Double)
        case MemoryStore
        case MemoryRecall
        case MemoryClear
        case MemoryAdd
        case MemoryMinus
        case Equals
        case Clear
        
        enum printSymbol {
            case Postfix(String)
            case Prefix(String)
        }
    }
    
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
                    
                case .MemoryStore:
                    currentMemory = accumulator
                    
                case .MemoryRecall:
                    accumulator = currentMemory
                    
                case .MemoryClear:
                    currentMemory = 0.0
                    
                case .MemoryAdd:
                    currentMemory+=accumulator
                    
                case .MemoryMinus:
                    currentMemory-=accumulator
                    
                case .Clear:
                    clear()
                    
                case .Equals:
                    equalsIsTouched = true
                    executePendingBinaryOperation()
                    printHistory()
            }
        }
    }
    
    private mutating func executePendingBinaryOperation(){
        if pending != nil{
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
            
            if equalsIsTouched {
                historyDictionary.append("=\(String(accumulator))")
                equalsIsTouched=false
            }
        }
    }
    
    private var pending: PendindBinaryOperationInfo?
    
    private struct PendindBinaryOperationInfo{
        var binaryFunction:(Double, Double)->Double
        var firstOperand: Double
    }
    
    private mutating func preformMemory(functionName: String, numberOnDisplay: Double) -> Double{
        switch functionName {
            case "MemoryClear":
                currentMemory = 0
            case "MemoryRecall":
                break
            case "MemoryAdd":
                currentMemory += numberOnDisplay
            case "MemoryMinus":
                currentMemory -= numberOnDisplay
            case "MemoryStore":
                currentMemory = numberOnDisplay
            default: break
        }
        return currentMemory
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
    
    var numberFormatter : NumberFormatter?
    
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
    
    var result:Double{
        get{
            return accumulator
        }
    }
}
