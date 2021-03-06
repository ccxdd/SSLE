//
//  UIStackView+extension+mw.swift
//  SSLE
//
//  Created by 陈晓东 on 2018/11/27.
//  Copyright © 2018 陈晓东. All rights reserved.
//

#if os(iOS)
import UIKit

private var AdditionKey: Void?

public extension UIStackView {
    struct Row {
        var rowView: UIView?
        var contentView: UIView?
    }
    
    private var addition: StackViewAddition {
        if let addition = objc_getAssociatedObject(self, &AdditionKey) as? StackViewAddition {
            return addition
        } else {
            let addition = StackViewAddition()
            objc_setAssociatedObject(self, &AdditionKey, addition, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return addition
        }
    }
    
    @discardableResult
    func addRow(view: UIView?) -> Self {
        guard let v = view else { return self }
        var row = Row()
        row.rowView = UIView()
        row.contentView = v
        row.rowView?.addSubview(row.contentView!)
        row.contentView?.mwl.edge()
        addArrangedSubview(row.rowView!)
        addition.rows.append(row)
        addition.index = addition.rows.count - 1
        return self
    }
    
    @discardableResult
    func inset(t: CGFloat = 0, l: CGFloat = 0, b: CGFloat = 0, r: CGFloat = 0) -> Self {
        addition.rows.at(addition.index)?.contentView?.mwl.edge(t: t, l: l, b: b, r: r)
        return self
    }
    
    @discardableResult
    func content(bg: UIColor) -> Self {
        addition.rows.at(addition.index)?.contentView?.backgroundColor = bg
        return self
    }
    
    @discardableResult
    func row(bg: UIColor) -> Self {
        addition.rows.at(addition.index)?.rowView?.backgroundColor = bg
        return self
    }
    
    @discardableResult
    func row(height: CGFloat) -> Self {
        addition.rows.at(addition.index)?.rowView?.mwl.h(height)
        return self
    }
    
    @discardableResult
    func content(height: CGFloat) -> Self {
        addition.rows.at(addition.index)?.contentView?.mwl.h(height)
        return self
    }
    
    @discardableResult
    func set(row: Int) -> Self {
        if arrangedSubviews.count > row {
            addition.index = row
        }
        return self
    }
    
    @discardableResult
    func remove(row: Int) -> Self {
        guard let v = arrangedSubviews.at(row) else { return self }
        removeArrangedSubview(v)
        addition.rows.remove(at: row)
        return self
    }
    
    @discardableResult
    func hide(_ flag: Bool) -> Self {
        arrangedSubviews.at(addition.index)?.isHidden = flag
        return self
    }
    
    func viewIn(row: Int) -> UIView? {
        return arrangedSubviews.at(row)
    }
    
    func labelIn(row: Int) -> UILabel? {
        return arrangedSubviews.at(row)?.asTo(UILabel.self)
    }
    
    func fieldIn(row: Int) -> UITextField? {
        return arrangedSubviews.at(row)?.asTo(UITextField.self)
    }
    
    @discardableResult
    func section(view: @autoclosure () -> UIView?, h: @autoclosure () -> CGFloat, data: [Any]?) -> Self {
        guard let d = data else { return self }
        for (idx, i) in d.enumerated() {
            let v = view()
            addRow(view: v).row(height: h())
            (v as? RowItemProtocol)?.setCellItem(item: i, indexPath: [0, idx])
        }
        return self
    }
}

private final class StackViewAddition {
    var index: Int = 0
    var rows: [UIStackView.Row] = []
}
#endif
