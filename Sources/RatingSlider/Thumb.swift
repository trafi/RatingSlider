//
//  RatingSliderGrid.swift
//  RatingSlider
//
//  Created by Domas on 04/11/2016.
//  Copyright © 2016 Trafi. All rights reserved.
//

import UIKit

public struct Thumb {
    public var size = CGFloat()
    public var hole = CGFloat()
    public var cornerRadius = CGFloat()
    public var color = UIColor()
    public var shadowColor = UIColor()
    
    public init(size: CGFloat = 34.0,
                hole: CGFloat = 6.0,
                cornerRadius: CGFloat = 17.0,
                color: UIColor = .white,
                shadowColor: UIColor = .black) {
        
        self.size = size
        self.hole = hole
        self.cornerRadius = cornerRadius
        self.color = color
        self.shadowColor = shadowColor
    }
}
