//
//  UtilityExtensions.swift
//  SpriteKitShaders
//
//  Created by Matthew Reagan on 8/3/18.
//  Copyright © 2018 Matt Reagan. All rights reserved.
//

import SpriteKit

extension CGPoint {
    func distance(to otherPoint: CGPoint) -> CGFloat {
        let xDelta = x - otherPoint.x
        let yDelta = y - otherPoint.y
        return ((xDelta * xDelta) + (yDelta * yDelta)).squareRoot()
    }
}

extension SKAction {
    func byEasingIn() -> SKAction {
        self.timingMode = .easeIn
        return self
    }
    func byEasingInOut() -> SKAction {
        self.timingMode = .easeInEaseOut
        return self
    }
    func byEasingOut() -> SKAction {
        self.timingMode = .easeOut
        return self
    }
}

struct Random {
    static func seed() {
        srand48(Int(time(nil)))
    }
    static func between0And1() -> Float {
        return Float(drand48())
    }
}
