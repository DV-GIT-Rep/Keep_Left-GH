//
//  Line.swift
//  Keep Left
//
//  Created by Bill Drayton on 6/4/2022.
//

import SpriteKit

class Line: SKSpriteNode {
    
//    var colour: UIColor = .white
    var length: CGFloat = 3    //Length of line in metres
    var width: CGFloat = 0.2   //Width of line in metres
//    var metreMultiplier: CGFloat = sMetre1
//    var xOffset: CGFloat = 0
//    var yOffset: CGFloat = 0
//    var zPos:CGFloat = -53
    
    init() {
        
//        super.init(texture: nil, color: colour, size: CGSize(width: (width * sMetre1), height: (length * metreMultiplier)))
        super.init(texture: nil, color: .white, size: CGSize(width: (width * sMetre1), height: (length * sMetre1)))
        
//        let line = SKSpriteNode(color: colour, size: CGSize(width: (lWidth * metreMultiplier), height: (lLength * metreMultiplier)))
        
//        var line1 = SKSpriteNode(color: colour, size: CGSize(width: (lWidth * sMetre1), height: (lLength * sMetre1)))

//        self.anchorPoint = CGPoint(x: 0.5, y: 0) //Set anchorpoint to middle bottom
////        line1.position = CGPoint(x: size.width/2, y: size.height/2)
//        self.position.y = (yOffset * metreMultiplier)
//        self.position.x = (size.width / 2) - (xOffset * metreMultiplier)
//        self.zPosition = zPos
//        self.addChild(line1)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
