//
//  AppDelegate.swift
//  SpriteKitShaders
//
//  Created by Matthew Reagan on 8/1/18.
//  Copyright © 2018 Matt Reagan. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
// documentation files (the "Software"), to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
// and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
// IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Cocoa
import SpriteKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    var skView: SKView!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Random.seed()
        DispatchQueue.main.async {
            self.setUpView()
        }
    }

    func setUpView() {
        guard let contentView = window.contentView else { return }
        
        let scene = PoolScene.init(size: contentView.bounds.size)
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scene.backgroundColor = SKColor.black
        scene.scaleMode = .aspectFit
        
        skView = SKView.init(frame: contentView.bounds)
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.autoresizingMask = [.width, .height]
        
        contentView.addSubview(skView)
        skView.presentScene(scene)
    }
}

