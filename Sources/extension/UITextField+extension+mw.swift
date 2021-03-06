//
//  UITextField+extension+mw.swift
//  StandardLibraryExtension
//
//  Created by 陈晓东 on 2017/4/21.
//  Copyright © 2017年 陈晓东. All rights reserved.
//

#if os(iOS)
import UIKit

private var textFieldAdditionKey: Void?

private final class TextFieldAddition: NSObject {
    var minLen: Int = 0
    var maxLen: Int = Int.max
    var maxValue: String?
    var decimalLen: Int = -1
    var regularPattern: String?
    var didChangeClosure: ((UITextField, String) -> Void)?
    var inputCategory: UITextField.InputCategory = .none
    weak var enabledButton: UIButton?
    
    @objc func textFieldDidChange(_ sender: UITextField) {
        let t: String = sender.text ?? ""
        guard t.count <= maxLen else {
            changeCallback(sender: sender, isDelete: true)
            return }
        switch inputCategory {
        case .decimal:
            guard t.isDecimal, !t.hasPrefix("."), !t.hasPrefix("00"), t.components(separatedBy: ".").count < 3 else {
                changeCallback(sender: sender, isDelete: true)
                return }
            guard t.decimalNum <= decimalLen, decimalLen != -1 else {
                changeCallback(sender: sender, isDelete: true)
                return }
        case .digit:
            guard t.isInt else {
                changeCallback(sender: sender, isDelete: true)
                return }
        case .none:
            changeCallback(sender: sender)
            return
        }
        if t.count == 2, t.hasPrefix("0"), t != "0." {
            sender.text = t.last?.description
        }
        if maxValue != nil, t.tD > maxValue!.tD {
            sender.text = maxValue
        }
        changeCallback(sender: sender)
    }
    
    private func changeCallback(sender: UITextField, isDelete: Bool = false) {
        if isDelete {
            sender.deleteBackward()
        }
        didChangeClosure?(sender, sender.text ?? "")
        enabledButton?.refreshEnabled()
    }
}

public extension UITextField {
    enum InputCategory {
        case none, decimal, digit
    }
    
    private var addition: TextFieldAddition {
        guard let addition = objc_getAssociatedObject(self, &textFieldAdditionKey) as? TextFieldAddition else {
            let addition = TextFieldAddition()
            objc_setAssociatedObject(self, &textFieldAdditionKey, addition, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            event(.editingChanged) { [weak self] in self?.addition.textFieldDidChange($0 as! UITextField) }
            return addition
        }
        return addition
    }
    
    @IBOutlet var enabledButton: UIButton? {
        set {
            addition.enabledButton = newValue
        }
        get {
            return addition.enabledButton
        }
    }
    
    @IBAction func showPwd(_ sender: UIButton) {
        isSecureTextEntry = !isSecureTextEntry
        sender.isSelected = !sender.isSelected
    }
    
    @IBInspectable var minLen: Int {
        get {
            return addition.minLen
        }
        set {
            addition.minLen = newValue
        }
    }
    
    @IBInspectable var maxLen: Int {
        get {
            return addition.maxLen
        }
        set {
            addition.maxLen = newValue
        }
    }
    
    @IBInspectable var decimal: Int {
        get {
            return addition.decimalLen
        }
        set {
            addition.decimalLen = newValue
        }
    }
    
    @IBInspectable var regularPattern: String? {
        get {
            return addition.regularPattern
        }
        set {
            addition.regularPattern = newValue
        }
    }
    
    var textLength: Int {
        return text?.count ?? 0
    }
    
    var inputValid: Bool {
        switch addition.inputCategory {
        case .none:
            if let r = regularPattern {
                return textLength > 0 && textLength >= minLen && textLength <= maxLen && text?.matchRegular(r) == true
            } else {
                return textLength > 0 && textLength >= minLen && textLength <= maxLen
            }
        default:
            return (text?.tD ?? 0) > 0
        }
    }
    
    func didChange(closure: @escaping (UITextField, String) -> Void) {
        addition.didChangeClosure = closure
    }
    
    func didBegin(closure: @escaping (String) -> Void) {
        event(.editingDidBegin) { [weak self] t in
            closure(self?.text ?? "")
        }
    }
    
    func didEnd(closure: @escaping (String) -> Void) {
        event(.editingDidEnd) { [weak self] t in
            closure(self?.text ?? "")
        }
    }
    
    @discardableResult func fillMax(value: String?) -> Self {
        addition.maxValue = value
        if (text?.tD ?? 0) > (value?.tD ?? 0) {
            text = value
        }
        return self
    }
    
    @discardableResult func min(len: Int) -> Self {
        addition.minLen = len
        return self
    }
    
    @discardableResult func max(len: Int) -> Self {
        addition.maxLen = len
        return self
    }
    
    @discardableResult func decimal(len: Int) -> Self {
        addition.decimalLen = len
        return self
    }
    
    @discardableResult func input(categary: InputCategory) -> Self {
        addition.inputCategory = categary
        switch categary {
        case .decimal:
            keyboardType = .decimalPad
        case .digit:
            keyboardType = .numberPad
        default: break
        }
        return self
    }
    
    func executeChangeClosure() {
        addition.didChangeClosure?(self, text ?? "")
    }
}
#endif
