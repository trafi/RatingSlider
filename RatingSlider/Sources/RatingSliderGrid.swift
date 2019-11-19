//
//  RatingSliderGrid.swift
//  RatingSlider
//
//  Created by Domas on 04/11/2016.
//  Copyright © 2016 Trafi. All rights reserved.
//

import UIKit

public enum GridStyle {
    case labels(font: UIFont)
    case dots(size: CGFloat)
}

class RatingSliderGrid: UIView {
    
    // MARK: Configuration
    
    var range: CountableClosedRange<Int> {
        didSet { setupLabels() }
    }
    
    var style: GridStyle {
        didSet { updateItems(by: style) }
    }
    
    var itemColor: UIColor = .white {
        didSet { updateItems(by: style) }
    }
    
    var thumb: Thumb? = nil
    
    // MARK: Init
    
    init(range: CountableClosedRange<Int>, style: GridStyle, thumb: Thumb? = nil, backgroundColor: UIColor) {
        self.range = range
        self.style = style
        self.thumb = thumb
        
        super.init(frame: .zero)
        self.backgroundColor = backgroundColor
        self.layer.anchorPoint = .zero
        
        setupItems()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Items
    
    private func setupItems() {
        switch style {
        case .labels:
            setupLabels()
        case .dots:
            setupDots()
        }
    }
    
    private func updateItems(by style: GridStyle) {
        switch style {
        case .labels(let font):
            updateLabels(with: font)
        case .dots(let size):
            updateDots(size: size)
        }
    }
    
    // MARK: - Dots
    
    private var dots = [UIView]()
    
    private func setupDots() {
        guard case let .dots(size) = style else { return }
        
        dots.forEach { $0.removeFromSuperview() }
        dots = range.map { [unowned self] _ in
            let dotContainerView = UIView()
            dotContainerView.backgroundColor = .clear
            
            let dot = UIView(frame: .init(x: 0, y: 0, width: size, height: size))
            dot.backgroundColor = self.itemColor
            dot.layer.cornerRadius = size / 2
            
            dotContainerView.addSubview(dot)
            addSubview(dotContainerView)
            
            return dotContainerView
        }
    }
    
    private func updateDots(size: CGFloat) {
        dots.forEach {
            guard let dot = $0.subviews.first else { return }
            dot.backgroundColor = itemColor
            dot.frame.size = .init(width: size, height: size)
        }
    }
    
    // MARK: Labels
    
    private var labels = [UILabel]()
    
    private func setupLabels() {
        guard case let .labels(font) = style else { return }
        
        labels.forEach { $0.removeFromSuperview() }
        labels = range.map { [unowned self] in
            let label = UILabel()
            label.text = "\($0)"
            label.textColor = self.itemColor
            label.font = font
            label.textAlignment = .center
            addSubview(label)
            return label
        }
    }
    
    func updateLabels(with font: UIFont) {
        labels.forEach { [unowned self] in
            $0.font = font
            $0.textColor = self.itemColor
        }
    }
    
    func updateLabel(at value: Int?) {
        labels.enumerated().forEach { index, label in
            let fontWeight: UIFont.Weight = value == nil ? .regular : index == value ? .bold : .regular
            label.font = .systemFont(ofSize: 12, weight: fontWeight)
        }
    }
    
    // MARK: - Update
    
    func updateItemSize(withMargin margin: CGFloat, elementWidth: CGFloat) {
        switch style {
        case .labels:
            labelSize(margin: margin, elementWidth: elementWidth)
        case .dots(let size):
            dotSize(margin: margin, elementWidth: elementWidth, dotSize: size)
        }
    }
    
    private func dotSize(margin: CGFloat, elementWidth: CGFloat, dotSize: CGFloat) {
        var frame = CGRect(x: margin, y: 0, width: elementWidth, height: bounds.height)
        
        dots.forEach {
            $0.frame = frame
            $0.subviews.first!.center.y = $0.frame.height / 2
            $0.subviews.first!.center.x = $0.frame.width / 2
            frame.origin.x += frame.width
        }
    }
    
    private func labelSize(margin: CGFloat, elementWidth: CGFloat) {
        var frame = CGRect(x: margin, y: 0, width: elementWidth, height: bounds.height)
        labels.forEach {
            $0.frame = frame
            frame.origin.x += frame.width
        }
    }
    
}
