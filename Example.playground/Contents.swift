//: Playground - noun: a place where people can play

import UIKit
import RatingSlider
import PlaygroundSupport

// Open Assistant Editor to see live view. Hit: ⌥⌘↵

let container = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
container.backgroundColor = .white

let thumb = Thumb(size: 34,
                  hole: 6,
                  cornerRadius: 17,
                  color: .white,
                  shadowColor: .black)

let frame = CGRect(x: 20, y: 100, width: 260, height: 50)

let ratingSlider = RatingSlider(frame: frame,
                                gridStyle: .dots(size: 3),
                                gridHeight: 16.0,
                                hasUpperGrid: true,
                                thumb: thumb)

ratingSlider.activeTrackColor = #colorLiteral(red: 0.9425747991, green: 0.8432862163, blue: 0.1268348098, alpha: 1)
ratingSlider.inactiveTrackColor = #colorLiteral(red: 0.8508961797, green: 0.8510394692, blue: 0.850877285, alpha: 1)
ratingSlider.activeColor = #colorLiteral(red: 0.6548359394, green: 0.6549482346, blue: 0.6548211575, alpha: 1)
ratingSlider.inactiveColor = #colorLiteral(red: 0.6548359394, green: 0.6549482346, blue: 0.6548211575, alpha: 1)
ratingSlider.range = 0...10

container.addSubview(ratingSlider)

PlaygroundPage.current.liveView = container
