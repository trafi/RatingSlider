//
//  RatingSliderGrid.swift
//  RatingSlider
//
//  Created by Domas on 04/11/2016.
//  Copyright © 2016 Trafi. All rights reserved.
//

import UIKit

class RatingSliderGrid: UIView {
    
    // MARK: Configuration
    
    var range: CountableClosedRange<Int> {
        didSet { setupLabels() }
    }
    
    var style: GridStyle {
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
        case .labeled:
            setupLabels()
        case .dotted:
            setupDots()
        }
    }
    
    private func updateItems(by style: GridStyle) {
        switch style {
        case .labeled(let appearance):
            updateLabels(with: appearance)
        case .dotted(let appearance):
            updateDots(with: appearance)
        }
    }
    
    // MARK: - Dots
    
    private var dots = [UIView]()
    
    private func setupDots() {
        guard case .dotted(let appearance) = style else { return }
        
        dots.forEach { $0.removeFromSuperview() }
        dots = range.map { _ in
            let dotContainerView = UIView()
            dotContainerView.backgroundColor = .clear
            
            let dot = UIView(frame: .init(x: 0, y: 0, width: appearance.inactiveSize, height: appearance.inactiveSize))
            dot.backgroundColor = appearance.inactiveColor
            dot.layer.cornerRadius = appearance.inactiveSize / 2
            
            dotContainerView.addSubview(dot)
            addSubview(dotContainerView)
            
            return dotContainerView
        }
    }
    
    private func updateDots(with appearance: DotAppearance) {
        dots.forEach {
            guard let dot = $0.subviews.first else { return }
            dot.frame.size = .init(width: appearance.inactiveSize, height: appearance.inactiveSize)
            dot.layer.cornerRadius = appearance.inactiveSize / 2
            dot.backgroundColor = appearance.inactiveColor
        }
    }

    func updateDot(at value: Int?) {
        guard case .dotted(let appearance) = style else { return }

        dots.enumerated().forEach { index, container in
            let isActive = value == nil ? false : index == value

            let dot = container.subviews.first!
            let style = appearance.sizeAndColor(isActive: isActive)

            dot.backgroundColor = style.color
            dot.frame = .init(
                x: container.frame.width / 2 - style.size / 2,
                y: container.frame.height / 2 - style.size / 2,
                width: style.size,
                height: style.size
            )
            dot.layer.cornerRadius = style.size / 2
        }
    }
    
    // MARK: Labels
    
    private var labels = [UILabel]()
    
    private func setupLabels() {
        guard case .labeled(let appearance) = style else { return }
        
        labels.forEach { $0.removeFromSuperview() }
        labels = range.map {
            let label = UILabel()
            label.text = "\($0)"
            label.textColor = appearance.inactiveColor
            label.font = appearance.inactiveFont
            label.textAlignment = .center
            addSubview(label)
            return label
        }
    }
    
    func updateLabels(with appearance: LabelAppearance) {
        labels.forEach {
            $0.font = appearance.inactiveFont
            $0.textColor = appearance.inactiveColor
        }
    }
    
    func updateLabel(at value: Int?) {
        guard case .labeled(let appearance) = style else { return }

        labels.enumerated().forEach { index, label in
            let isActive = value == nil ? false : index == value
            let style = appearance.fontAndColor(isActive: isActive)

            label.font = style.font
            label.textColor = style.color
        }
    }
    
    // MARK: - Update
    
    func updateItemSize(withMargin margin: CGFloat, elementWidth: CGFloat) {
        switch style {
        case .labeled:
            labelSize(margin: margin, elementWidth: elementWidth)
        case .dotted(let appearance):
            dotSize(margin: margin, elementWidth: elementWidth, dotSize: appearance.activeSize)
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
