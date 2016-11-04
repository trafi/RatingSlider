//
//  RatingSlider.swift
//  RatingSlider
//
//  Created by Domas on 03/11/2016.
//  Copyright © 2016 Trafi. All rights reserved.
//

import UIKit

// MARK: NPSSlider

public class RatingSlider: UIControl {
    
    // MARK: - Configuration
    
    public var range = 0...10 {
        didSet {
            guard range != oldValue else { return }
            set(value: nil)
            grids { $0.range = range }
            updatedSize()
        }
    }
    @IBInspectable public var font: UIFont {
        get { return activeGrid.font }
        set { grids { $0.font = newValue } }
    }
    
    // MARK: Active grid
    
    @IBInspectable public var activeLabelsColor: UIColor {
        get { return activeGrid.textColor }
        set { activeGrid.textColor = newValue }
    }
    @IBInspectable public var activeTrackColor: UIColor? {
        get { return activeGrid.backgroundColor }
        set { activeGrid.backgroundColor = newValue }
    }
    public override var tintColor: UIColor! {
        didSet { activeTrackColor = tintColor }
    }
    
    // MARK: Inactive grid
    
    @IBInspectable public var inactiveLabelsColor: UIColor {
        get { return inactiveGrid.textColor }
        set { inactiveGrid.textColor = newValue }
    }
    @IBInspectable public var inactiveTrackColor: UIColor? {
        get { return backgroundColor }
        set { backgroundColor = newValue }
    }
    
    // MARK: - Init
    
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
        
        if backgroundColor == nil {
            backgroundColor = UIColor(white: 0.9, alpha: 1)
        }
        
        addSubview(inactiveGrid)
        addSubview(activeGrid)
        activeGrid.maskView = selection
        
        updatedSize()
    }
    
    // MARK: - Size
    
    public override var frame: CGRect {
        didSet {
            guard frame.size != oldValue.size else { return }
            updatedSize()
        }
    }
    public override var bounds: CGRect {
        didSet {
            guard bounds.size != oldValue.size else { return }
            updatedSize()
        }
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
        updateGridsSize()
    }
    
    // MARK: - Grids
    
    private func grids(@noescape action: (RatingSliderGrid) -> ()) {
        [activeGrid, inactiveGrid].forEach(action)
    }
    
    private lazy var activeGrid: RatingSliderGrid = RatingSliderGrid(
        range: 0...10,
        textColor:   .whiteColor(),
        backgroundColor: self.tintColor,
        font: .systemFontOfSize(12)
    )
    
    private lazy var inactiveGrid: RatingSliderGrid = RatingSliderGrid(
        range: 0...10,
        textColor: .grayColor(),
        backgroundColor: .clearColor(),
        font: .systemFontOfSize(12)
    )
    
    private func updateGridsSize() {
        grids {
            $0.bounds = bounds
            $0.updateLabelsSize(withMargin: margin, elementWidth: elementWidth)
        }
    }
    
    // MARK: - Selection
    
    private lazy var selection: UIView = {
        let selection = UIView()
        selection.layer.anchorPoint = .zero
        selection.backgroundColor = .blackColor()
        return selection
    }()
    
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
            UIView.animateWithDuration(0.2) {
                self.selection.bounds.size.width = newWidth
            }
        } else {
            selection.bounds.size.width = newWidth
        }
    }
    
    // MARK: - Changing value
    
    private func set(value value: Int?) {
        self.value = value
        sendActionsForControlEvents(.ValueChanged)
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
            if let newValue = floatingValue where !(0...1 ~= newValue) {
                floatingValue = max(0, min(1, newValue))
            }
            updateSelection(to: floatingValue)
        }
    }
    
    // MARK: - Touches
    
    private var touchDownX: CGFloat?
    private var touchDownValue: CGFloat?
    private var isSliding = false
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchX = touch.locationInView(touch.view).x
        touchDownX = touchX
        set(value: value(atX: touchX))
        touchDownValue = floatingValue
    }
    
    public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard
            let touchDownX = touchDownX,
            let touchDownValue = touchDownValue,
            let touch = touches.first else { return }
        
        isSliding = true
        
        let xDiff = touch.locationInView(touch.view).x - touchDownX
        let propotionalChange = xDiff / (bounds.width - firstElementWidth)
        floatingValue = touchDownValue + propotionalChange
    }
    
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
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
