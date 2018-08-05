//
//  PoolScene.swift
//  SpriteKitShaders
//
//  Created by Matthew Reagan on 8/3/18.
//  Copyright © 2018 Matt Reagan. All rights reserved.
//
//  More info: http://sound-of-silence.com
//
//  For LICENSE information please see AppDelegate.swift.

import SpriteKit

class PoolScene: SKScene {
    
    // MARK: - Properties
    
    let waterNode = SKSpriteNode(imageNamed: "water")
    let emitterNode = SKEmitterNode(fileNamed: "LightSparkle")!
    var waterWarpPositions: [float2] = []
    let waterWarpGridSize = 12
    
    // MARK: - Init
    
    override init(size: CGSize) {
        super.init(size: size)
        configureNodes()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Node Configuration
    
    func configureNodes() {
        waterNode.position = CGPoint(x: 0.0, y: 12.0);
        waterNode.shader = SKShader(fileNamed: "poolWaterShader")
        addChild(waterNode)
        
        emitterNode.position = waterNode.position
        addChild(emitterNode)
        
        let backgroundNode = SKSpriteNode(imageNamed: "poolBackground")
        backgroundNode.size = size
        backgroundNode.zPosition = -10.0
        addChild(backgroundNode)
        
        let spriteKitTextNode = SKSpriteNode(imageNamed: "spritekitText")
        spriteKitTextNode.zPosition = 50.0
        spriteKitTextNode.position = CGPoint(x: 0.0, y: 250.0)
        spriteKitTextNode.shader = SKShader(fileNamed: "simpleLiquidShader")
        addChild(spriteKitTextNode)
        
        waterWarpPositions = geometryGridPositions(byWarping: false)
        waterNode.warpGeometry = SKWarpGeometryGrid(columns: waterWarpGridSize, rows: waterWarpGridSize)
        randomizeWaterGeometry()
    }
    
    // MARK: - Animation Functions
    
    func geometryGridPositions(byWarping: Bool) -> [float2] {
        var points = [float2]()
        for y in 0...waterWarpGridSize {
            for x in 0...waterWarpGridSize {
                let shouldWarp = byWarping && x > 0 && y > 0 && x < waterWarpGridSize && y < waterWarpGridSize
                let warpAmount: Float = 1.0 / Float(waterWarpGridSize + 1) / 4.0
                func randomizedWarpAmount() -> Float { return (shouldWarp ? warpAmount * Random.between0And1() - (warpAmount / 2.0) : 0.0) }
                let nx = Float(x) * (1.0 / Float(waterWarpGridSize)) + randomizedWarpAmount()
                let ny = Float(y) * (1.0 / Float(waterWarpGridSize)) + randomizedWarpAmount()
                points.append(float2(nx,ny))
            }
        }
        return points
    }
    
    func randomizeWaterGeometry() {
        let sourcePositions = waterWarpPositions
        waterWarpPositions = geometryGridPositions(byWarping: true)
        let warpGeometryGrid = SKWarpGeometryGrid.init(columns: waterWarpGridSize, rows: waterWarpGridSize, sourcePositions: sourcePositions, destinationPositions: waterWarpPositions)
        let warpDuration = TimeInterval(0.36)
        if let warpAction =  SKAction.warp(to: warpGeometryGrid, duration: warpDuration) {
            waterNode.run(.sequence([
                warpAction.byEasingInOut(),
                .run({[weak self] in self?.randomizeWaterGeometry()})
                ]))
        }
    }
    
    // MARK: - Event Handlers
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        let pointInPool = event.location(in: waterNode)
        
        if pointInPool.distance(to: .zero) < 160.0 {
            dropLeaf(at: pointInPool)
        }
    }
    
    // MARK: - Leaf Animation Utilities
    
    func dropLeaf(at pointInPool: CGPoint) {
        let leaf = SKSpriteNode(imageNamed: "leaf")
        leaf.zPosition = 5.0
        leaf.position = pointInPool
        leaf.alpha = 0.4
        leaf.zRotation = CGFloat(Random.between0And1() * (Float.pi * 2.0))
        waterNode.addChild(leaf)
        
        let blueFadeColor = SKColor.init(red: 0.0, green: 0.0, blue: 0.7, alpha: 1.0)
        
        let randomRotationAngle = CGFloat(Random.between0And1() * (Float.pi * 2.0) - Float.pi)
        let randomDriftAngle = CGFloat(Random.between0And1() * (Float.pi * 2.0) - Float.pi)
        let randomDriftDistance = CGFloat(Random.between0And1() * 30.0) + 20.0
        let driftDestination = CGPoint(x: randomDriftDistance * cos(randomDriftAngle) * CGFloat(Random.between0And1()) + pointInPool.x,
                                       y: randomDriftDistance * sin(randomDriftAngle) * CGFloat(Random.between0And1()) + pointInPool.y)
        
        let totalAnimationDuration = TimeInterval(2.2)
        let leafFallDuration = TimeInterval(0.82)
        let leafDieDuration = TimeInterval(0.85)
        leaf.run(.sequence([
            .group([
                SKAction.scale(to: 0.5, duration: leafFallDuration).byEasingIn(),
                .fadeIn(withDuration: leafFallDuration)]),
            .run({ [weak self] in self?.createRipple(at: pointInPool) }),
            .group([
                .rotate(byAngle: randomRotationAngle, duration: totalAnimationDuration),
                .move(to: driftDestination, duration: totalAnimationDuration),
                .colorize(with: blueFadeColor, colorBlendFactor: 0.4, duration: totalAnimationDuration)]),
            .group([
                .scale(to: 0.25, duration: leafDieDuration),
                .colorize(with: blueFadeColor, colorBlendFactor: 0.6, duration: leafDieDuration),
                .fadeAlpha(to: 0.14, duration: leafDieDuration)]),
            .fadeOut(withDuration: 5.0),
            .removeFromParent(),
            ]))
    }
    
    func createRipple(at pointInPool: CGPoint) {
        let numRipples = 4
        for i in 0..<numRipples {
            
            let rippleSize = 16.0 + (CGFloat(i + 4) * 8.0)
            let rippleDuration = TimeInterval(0.80 + 0.28 * CGFloat(i))
            
            let ripple = SKShapeNode.init(ellipseOf: CGSize(width:rippleSize, height:rippleSize))
            ripple.xScale = 0.6 + (0.1 * CGFloat(Random.between0And1()) - 0.05)
            ripple.yScale = 0.6 + (0.1 * CGFloat(Random.between0And1()) - 0.05)
            ripple.alpha = 0.02
            ripple.lineWidth = 4.0
            ripple.fillColor = SKColor.clear
            ripple.strokeColor = SKColor.white
            ripple.blendMode = .add
            
            waterNode.addChild(ripple)
            let endScale = 0.35 * CGFloat(i + 2)
            let destXScale = endScale + (0.2 * CGFloat(Random.between0And1()) - 0.1)
            let destYScale = endScale + (0.2 * CGFloat(Random.between0And1()) - 0.1)
            
            ripple.run(.sequence([
                .group([
                    .fadeAlpha(to: 0.2, duration: 0.1),
                    SKAction.scaleX(to: destXScale, y: destYScale, duration: rippleDuration).byEasingInOut(),
                    .sequence([.wait(forDuration: 0.1),
                               SKAction.fadeOut(withDuration: rippleDuration - 0.1).byEasingInOut()])
                    ]),
                .removeFromParent()]))
            ripple.position = pointInPool
        }
    }
}


