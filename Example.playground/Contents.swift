//: Playground - noun: a place where people can play

import UIKit
import RatingSlider
import PlaygroundSupport

// Open Assistant Editor to see live view. Hit: ⌥⌘↵

let container = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
container.backgroundColor = .white

container.addSubview(RatingSlider(frame: CGRect(x: 20, y: 50, width: 260, height: 30)))
container.addSubview(UISlider(frame: CGRect(x: 20, y: 120, width: 260, height: 30)))

PlaygroundPage.current.liveView = container
