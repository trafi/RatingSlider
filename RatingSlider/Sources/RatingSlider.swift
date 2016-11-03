//
//  RatingSlider.swift
//  RatingSlider
//
//  Created by Domas on 03/11/2016.
//  Copyright © 2016 Trafi. All rights reserved.
//

import Foundation
import UIKit

// MARK: NPSSlider

public class RatingSlider: UIControl {
    
    // MARK: Configuration
    public var range = 0...10 {
        didSet {
            setupLabels()
            updatedSize()
        }
    }
    
    public var activeLabelsColor = UIColor.white {
        didSet { updateLabelsColor() }
    }
    public var activeTrackColor: UIColor? {
        get { return selection.backgroundColor }
        set { selection.backgroundColor = newValue }
    }
    public var inactiveLabelsColor = UIColor(white: 74/255, alpha: 1) {
        didSet { updateLabelsColor() }
    }
    public var inactiveTrackColor: UIColor {
        get { return backgroundColor ?? UIColor(white: 223/255, alpha: 1) }
        set { backgroundColor = newValue }
    }
    
    public var font = UIFont.boldSystemFont(ofSize: 12) {
        didSet { labels.forEach { $0.font = font } }
    }
    
    // MARK: Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        clipsToBounds = true
        backgroundColor = inactiveTrackColor
        
        updatedSize()
        setupSelection()
        setupLabels()
    }
    
    // MARK: Size
    
    public override var bounds: CGRect {
        didSet { updatedSize() }
    }
    
    var elementWidth: CGFloat = 0
    var margin: CGFloat = 0
    var firstElementWidth: CGFloat = 0
    
    func updatedSize() {
        // Update corner sadius
        let cornerRadius = bounds.height / 2
        layer.cornerRadius = cornerRadius
        
        // Update sizes
        let width = bounds.width
        let elements = CGFloat(range.count)
        
        elementWidth = width / elements
        if elementWidth < cornerRadius * 2 {
            elementWidth = (width - cornerRadius * 2) / (elements - 1)
        }
        margin = (width - elementWidth * elements) / 2
        firstElementWidth = margin + elementWidth + margin
        
        updateSelectionSize()
        updateLabelsSize()
    }
    
    // Selection view
    private let selection = UIView()
    
    private func setupSelection() {
        addSubview(selection)
        selection.layer.anchorPoint = .zero
        activeTrackColor = tintColor
    }
    
    private func updateSelectionSize() {
        selection.layer.cornerRadius = layer.cornerRadius
        selection.bounds.size.height = bounds.height
        
        updateSelection(to: floatingValue)
    }
    
    private func updateSelection(to value: CGFloat?) {
        guard let value = value else {
            selection.bounds.size.width = 0
            return
        }
        let newWidth = firstElementWidth + (bounds.width - firstElementWidth) * value
        if !isSliding {
            UIView.animate(withDuration: 0.2) {
                self.selection.bounds.size.width = newWidth
            }
        } else {
            selection.bounds.size.width = newWidth
        }
    }
    
    // Labels
    private var labels = [UILabel]()
    
    private func setupLabels() {
        labels.forEach { $0.removeFromSuperview() }
        labels = range.map {
            let label = UILabel()
            label.text = "\($0)"
            label.font = font
            label.textAlignment = .center
            addSubview(label)
            return label
        }
        updateLabelsSize()
        updateLabelsColor()
    }
    
    private func updateLabelsSize() {
        var frame = CGRect(x: margin, y: 0, width: elementWidth, height: bounds.height)
        labels.forEach {
            $0.frame = frame
            frame.origin.x += frame.width
        }
    }
    
    private func labelColor(atIndex index: Int) -> UIColor {
        guard let valueIndex = value.flatMap(range.index(of:)) else { return inactiveLabelsColor }
        return valueIndex >= index ? activeLabelsColor : inactiveLabelsColor
    }
    
    private func updateLabelsColor() {
        labels.enumerated().forEach { index, label in label.textColor = labelColor(atIndex: index) }
    }
    
    // MARK: Changing value
    
    private func set(value: Int?) {
        self.value = value
        sendActions(for: .valueChanged)
    }
    
    public var value: Int? {
        get {
            guard let valueFloat = floatingValue else { return nil }
            let index = Int(CGFloat(range.count - 1) * valueFloat + 0.5)
            return range[index]
        }
        set {
            guard let newValue = newValue, let index = range.index(of: newValue) else {
                floatingValue = nil
                return
            }
            floatingValue = CGFloat(index) / CGFloat(range.count - 1)
        }
    }
    
    private var floatingValue: CGFloat? {
        didSet {
            if let newValue = floatingValue, !(0...1 ~= newValue) {
                floatingValue = max(0, min(1, newValue))
            }
            updateSelection(to: floatingValue)
            updateLabelsColor()
        }
    }
    
    // MARK: Touches
    
    private var touchDownX: CGFloat?
    private var touchDownValue: CGFloat?
    private var isSliding = false
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchX = touch.location(in: touch.view).x
        touchDownX = touchX
        set(value: value(atX: touchX))
        touchDownValue = floatingValue
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard
            let touchDownX = touchDownX,
            let touchDownValue = touchDownValue,
            let touch = touches.first else { return }
        
        isSliding = true
        
        let xDiff = touch.location(in: touch.view).x - touchDownX
        let propotionalChange = xDiff / (bounds.width - firstElementWidth)
        floatingValue = touchDownValue + propotionalChange
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isSliding = false
        set(value: value)
        touchDownX = nil
        touchDownValue = nil
    }
    
    private func value(atX x: CGFloat) -> Int? {
        if (bounds.width - margin) < x {
            return range.last
        } else if x < margin {
            return range.first
        } else {
            let xWithoutMargin = x - margin
            let index = Int(xWithoutMargin / elementWidth)
            return range[index]
        }
    }
}
