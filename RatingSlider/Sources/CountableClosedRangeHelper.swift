//
//  CountableClosedRangeHelper.swift
//  RatingSlider
//
//  Created by Domas on 03/11/2016.
//  Copyright © 2016 Trafi. All rights reserved.
//

import Foundation

extension CountableClosedRange {
    subscript(index: Int) -> Bound? {
        return dropFirst(index).first
    }
}

extension CountableClosedRange where Bound: Numeric {
    func index(of element: Bound) -> Bound? {
        guard self ~= element else { return nil }
        return element - first!
    }
}
