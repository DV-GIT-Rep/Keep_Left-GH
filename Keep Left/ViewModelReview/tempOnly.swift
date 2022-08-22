//
//  tempOnly.swift
//  Keep Left
//
//  Created by Bill Drayton on 21/8/2022.
//

import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        let camera = SKCameraNode()
        self.camera = camera  // Maybe you missed this?
        addChild(camera)
        camera.position = CGPoint(x: 0, y: 0)
     
        let myLabel = SKLabelNode(fontNamed:"SF Mono")
        myLabel.text = "Touch me. I'll stay."
        camera.addChild(myLabel)
        myLabel.fontSize = 22
        myLabel.position = CGPoint(x:0, y:-0)
        myLabel.fontColor = .red
        myLabel.zPosition = 100
        myLabel.setScale(0.005)
        
        print(camera.frame)

        camera.setScale(100)

        let sprite = SKSpriteNode(imageNamed:"Car 1")
//        sprite.setScale(8)
        self.addChild(sprite)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a mouse click occurs */
     
        guard let camera = camera else { return }
     
        let rotateAction = SKAction.rotate(byAngle: CGFloat(M_PI), duration:1)
        let scaleOutAction = SKAction.scale(by: 2, duration: 1)
        let actionGroup = SKAction.group([rotateAction, scaleOutAction])
     
        camera.run(actionGroup)
    }

    override func update(_ currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
