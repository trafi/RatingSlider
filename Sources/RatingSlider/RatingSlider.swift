//
//  RatingSlider.swift
//  RatingSlider
//
//  Created by Domas on 03/11/2016.
//  Copyright © 2016 Trafi. All rights reserved.
//

import UIKit

// MARK: NPSSlider

open class RatingSlider: UIControl {
    
    private var gridStyle: GridStyle = .labeled(.default)
    private var thumb: Thumb? = nil
    
    // MARK: - Configuration
    
    public var range = 0...10 {
        didSet {
            guard range != oldValue else { return }
            set(value: nil)
            grids { $0.range = range }
            updatedSize()
        }
    }
    
    // MARK: Active grid

    @IBInspectable public var activeTrackColor: UIColor? {
        get { activeGrid.backgroundColor }
        set { activeGrid.backgroundColor = newValue }
    }
    
    open override var tintColor: UIColor! {
        didSet { activeTrackColor = tintColor }
    }
    
    // MARK: Inactive grid

    @IBInspectable public var inactiveTrackColor: UIColor? {
        get { inactiveGrid.backgroundColor }
        set { inactiveGrid.backgroundColor = newValue }
    }
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public init(frame: CGRect, gridStyle: GridStyle = .labeled(.default), thumb: Thumb? = nil) {
        super.init(frame: frame)
        
        self.gridStyle = gridStyle
        self.thumb = thumb
        
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        setupContainerView()
        setupContainerViewSubviews()
        setupSelectionMask()
        setupTopGripViewIfNeeded()
        setupThumbViewIfNeeded()
        
        updatedSize()
    }
    
    private func setupContainerView() {
        addSubview(containerView)

        var additionalSpacing: CGFloat {
            guard
                let labeledGridHeight = gridStyle.labeledGridHeight,
                let thumbHeight = thumb?.size,
                thumbHeight > labeledGridHeight
            else { return 0.0 }

            return (thumbHeight - labeledGridHeight) / 2
        }
        
        let topConstraint: CGFloat = gridStyle.hasUpperLabeledGrid ? gridStyle.labeledGridHeight! : 0
        let height = (gridStyle.labeledGridHeight ?? thumb?.size) ?? bounds.height - topConstraint
        
        containerView.topAnchor.constraint(equalTo: self.topAnchor, constant: topConstraint + additionalSpacing).isActive = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.heightAnchor.constraint(equalToConstant: height).isActive = true
        containerView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        self.layoutIfNeeded()
    }
    
    private func setupContainerViewSubviews() {
        containerView.addSubview(inactiveGrid)
        containerView.addSubview(activeGrid)
    }
    
    private func setupSelectionMask() {
        activeGrid.mask = selection
    }
    
    private func setupThumbViewIfNeeded() {
        guard let thumb = thumb, let thumbView = thumbView else { return }
        addSubview(thumbView)
        
        thumbView.frame.size = CGSize(width: thumb.size, height: thumb.size)
        thumbView.center = containerView.center
    }
    
    private func setupTopGripViewIfNeeded() {
        guard
            gridStyle.hasUpperLabeledGrid,
            let height = gridStyle.labeledGridHeight,
            let upperGrid = upperGrid
        else { return }

        upperGrid.bounds = CGRect(x: 0, y: 0, width: bounds.width, height: height)
        addSubview(upperGrid)
        upperGrid.layoutIfNeeded()
    }

    // MARK: - Size
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .clear
        return view
    }()
    
    open override var frame: CGRect {
        didSet {
            guard frame.size != oldValue.size else { return }
            updatedSize()
        }
    }
    open override var bounds: CGRect {
        didSet {
            guard bounds.size != oldValue.size else { return }
            updatedSize()
        }
    }
    
    var elementWidth: CGFloat = 0
    var margin: CGFloat = 0
    var firstElementWidth: CGFloat = 0
    
    func updatedSize() {
        // Update corner radius
        let cornerRadius = containerView.bounds.height / 2
        containerView.layer.cornerRadius = cornerRadius
        
        // Update sizes
        let width = containerView.bounds.width
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
    
    private func grids(action: (RatingSliderGrid) -> ()) {
        [activeGrid, inactiveGrid, upperGrid]
            .compactMap { $0 }
            .forEach(action)
    }
    
    private lazy var upperGrid: RatingSliderGrid? = {
        guard case .dotted(let appearance) = gridStyle, let style = appearance.labels else { return nil }
        return .init(range: range, style: .labeled(style), backgroundColor: .clear)
    }()
    
    private lazy var activeGrid: RatingSliderGrid = RatingSliderGrid(
        range: range,
        style: gridStyle,
        thumb: thumb,
        backgroundColor: tintColor
    )
    
    private lazy var inactiveGrid: RatingSliderGrid = RatingSliderGrid(
        range: range,
        style: gridStyle,
        thumb: thumb,
        backgroundColor: UIColor(white: 0.9, alpha: 1)
    )
    
    private func updateGridsSize() {
        grids {
            if $0 != upperGrid { $0.bounds = containerView.bounds }
            $0.updateItemSize(withMargin: margin, elementWidth: elementWidth)
        }
    }
    
    // MARK: - Thumb
    
    private lazy var thumbView: UIView? = {
        guard let thumb = thumb else { return nil }
        
        let thumbView = UIView()
        thumbView.isUserInteractionEnabled = false
        thumbView.layer.cornerRadius = thumb.cornerRadius
        
        /* Color, hole */
        thumbView.layer.borderColor = thumb.color.cgColor
        thumbView.layer.borderWidth = CGFloat((thumb.size) / 2) - thumb.hole
        
        /* shadow */
        thumbView.layer.shadowOffset = .zero
        thumbView.layer.shadowColor = thumb.shadowColor.cgColor
        thumbView.layer.shadowOpacity = 0.16
        thumbView.layer.shadowRadius = 6
        
        return thumbView
    }()
    
    // MARK: - Selection
    
    private lazy var selection: UIView = {
        let selection = UIView()
        selection.layer.anchorPoint = .zero
        selection.backgroundColor = .black
        return selection
    }()
    
    private func updateSelectionSize() {
        selection.layer.cornerRadius = containerView.layer.cornerRadius
        selection.bounds.size.height = containerView.bounds.height
        
        updateSelection(to: floatingValue)
    }
    
    private func updateSelection(to value: CGFloat?) {
        
        updateGridsSelection()
        
        guard let value = value else {
            UIView.animate(withDuration: 0.2) { [unowned self] in
                self.selection.bounds.size.width = 0
                self.thumbView?.center = self.containerView.center
            }
            return
        }
        
        let newWidth = firstElementWidth + (bounds.width - firstElementWidth) * value
        if !isSliding {
            UIView.animate(withDuration: 0.2) { [unowned self] in
                self.selection.bounds.size.width = newWidth
                self.thumbView?.center.x = (self.selection.bounds.maxX - (self.firstElementWidth / 2))
            }
        } else {
            selection.bounds.size.width = newWidth
            thumbView?.center.x = (selection.bounds.maxX - (firstElementWidth / 2))
        }
    }
    
    private func updateGridsSelection() {
        [activeGrid, inactiveGrid, upperGrid]
            .compactMap { $0 }
            .forEach { $0.updateSelection(at: value) }
    }
    
    // MARK: - Changing value
    
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
        }
    }
    
    // MARK: - Touches
    
    private var touchDownX: CGFloat?
    private var touchDownValue: CGFloat?
    private var isSliding = false
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchX = touch.location(in: containerView).x
        touchDownX = touchX
        set(value: value(atX: touchX))
        touchDownValue = floatingValue
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard
            let touchDownX = touchDownX,
            let touchDownValue = touchDownValue,
            let touch = touches.first else { return }
        
        isSliding = true
        
        let xDiff = touch.location(in: containerView).x - touchDownX
        let propotionalChange = xDiff / (containerView.bounds.width - firstElementWidth)
        floatingValue = touchDownValue + propotionalChange
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isSliding = false
        set(value: value)
        touchDownX = nil
        touchDownValue = nil
    }
    
    private func value(atX x: CGFloat) -> Int? {
        if (containerView.bounds.width - margin) < x {
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
