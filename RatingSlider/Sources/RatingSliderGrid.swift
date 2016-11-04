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
    
    var range: Range<Int> {
        didSet { setupLabels() }
    }
    var textColor: UIColor {
        didSet { labels.forEach { $0.textColor = textColor } }
    }
    var font: UIFont {
        didSet { labels.forEach { $0.font = font } }
    }
    
    // MARK: Init
    
    init(range: Range<Int>, textColor: UIColor, backgroundColor: UIColor, font: UIFont) {
        self.range = range
        self.textColor = textColor
        self.font = font
        
        super.init(frame: .zero)
        self.backgroundColor = backgroundColor
        self.layer.anchorPoint = .zero
        
        setupLabels()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Labels
    
    private var labels = [UILabel]()
    
    private func setupLabels() {
        labels.forEach { $0.removeFromSuperview() }
        labels = range.map {
            let label = UILabel()
            label.text = "\($0)"
            label.textColor = textColor
            label.font = font
            label.textAlignment = .Center
            addSubview(label)
            return label
        }
    }
    
    func updateLabelsSize(withMargin margin: CGFloat, elementWidth: CGFloat) {
        var frame = CGRect(x: margin, y: 0, width: elementWidth, height: bounds.height)
        labels.forEach {
            $0.frame = frame
            frame.origin.x += frame.width
        }
    }
}
