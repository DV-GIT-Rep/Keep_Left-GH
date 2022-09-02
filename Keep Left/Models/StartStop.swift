//
//  StartStop.swift
//  Keep Left
//
//  Created by Bill Drayton on 19/8/2022.
//

import SpriteKit
import SwiftUI

class StartStop: SKSpriteNode {
    
    init() {
        var texture = SKTexture(imageNamed: "runIcon")
        super.init(texture: texture, color: UIColor.clear, size: texture.size())

        isUserInteractionEnabled = true
        texture = SKTexture(imageNamed: "runIcon")
//        self.xScale = -1        //Was only required when GO icon pointed left
        self.alpha = 1
        
//        position = CGPoint(x:scene!.view!.bounds.width * 0.4,y:scene!.view!.bounds.height * -0.4)  //In a UIView, 0,0 is the top left corner, so we look to bottom middle
//        position = CGPoint(x: 0, y: 0)
        zPosition = 10000000000
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}   //Exit if not first touch!

        //MARK: - Toggle Vehicle Operation
        switch runStop {
        case .stop:
            runStop = .run
            self.texture = SKTexture(imageNamed: "stopIcon")
            
            //The following will enable the runTimer after a delay
            let delayRun = SKAction.wait(forDuration: runTimerDelay)    //runTimerDelay ~ 12 secs?
            let setRun = SKAction.run {
                enableMinSpeed = true
//                print("runTimer Enabled !!!")
            }
            let delayRunSequence = SKAction.sequence([delayRun, setRun])
            run(delayRunSequence, withKey: "delayRun")

//        case .run:
        default:
            runStop = .stop
            self.texture = SKTexture(imageNamed: "runIcon")

            removeAction(forKey: "delayRun")    //Disable delay to prevent runTimerEnabled setting!
            enableMinSpeed = false          //Stop runTimer while vehicles stationary
//            print("runTimer Disabled !!!")

        }
    }

}




//var runStop: runCondition = .stop {       //Vehicles go when set to run
//    didSet {
//        if runStop == .stop {
//            enableMinSpeed = false
//        } else {
//            //The following will set display back to All Vehicles after a delay
//            let delayRun = SKAction.wait(forDuration: runTimerDelay)    //runTimerDelay ~ 12 secs?
//            let setRun = SKAction.run {
//                enableMinSpeed = true
//            }
//            let delayRunSequence = SKAction.sequence([delayRun, setRun])
//            run(delayRunSequence, withKey: "delayRun")
//        }
//    }
//}
