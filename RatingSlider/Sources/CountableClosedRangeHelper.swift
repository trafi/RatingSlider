//
//  CountableClosedRangeHelper.swift
//  RatingSlider
//
//  Created by Domas on 03/11/2016.
//  Copyright © 2016 Trafi. All rights reserved.
//

import Foundation

extension Range {
    subscript(index: Int) -> Element? {
        return dropFirst(index).first
    }
}
extension Range where Element: IntegerArithmeticType {
    func index(of element: Element) -> Element? {
        guard self ~= element else { return nil }
        return element - first!
    }
}
