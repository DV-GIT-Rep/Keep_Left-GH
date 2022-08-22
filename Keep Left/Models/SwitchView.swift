//
//  SwitchView.swift
//  Keep Left
//
//  Created by Bill Drayton on 19/8/2022.
//

import SpriteKit

class SwitchView: SKSpriteNode {
    

    init() {
        var texture = SKTexture(imageNamed: "straightIcon")
        super.init(texture: texture, color: UIColor.clear, size: texture.size())

        isUserInteractionEnabled = true
        self.alpha = 1
        
        position = CGPoint(x: 0, y: 0)
        zPosition = 10000000000
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}   //Exit if not first touch!

        //MARK: - Toggle between Straight and Figure 8 Views
        switch whichScene {
        case .figure8:
            whichScene = .straight
            texture = SKTexture(imageNamed: "straightIcon")
//            commonLabelBackground.move(toParent: sTrackCamera)
//            commonLabelBackground.size = sBackground.size
//            switchView.position = CGPoint(x: scene!.view!.bounds.width * -0.42, y: scene!.view!.bounds.height * -0.46)
//            commonLabelBackground.setScale(0.05)
//            commonLabelBackground.setScale(1.8)
//            sSwitchView.position = CGPoint(x: sTrackCamera.frame.width * 0.42, y: sTrackCamera.frame.height * -0.46)
//            sStartStop.position = CGPoint(x: UIScreen.main.bounds.width * -0.42, y: (UIScreen.main.bounds.height * -0.46))
            print("s cLBack: \(commonLabelBackground.parent!)")
            print("kamera: \(kamera!)\nkamera.camera: \(kamera!.camera ?? sTrackCamera)")
            print("sMetre1: \(straightScene.metre1),   f8Metre1: \(f8Scene.metre1)")
//        case .straight:   //gameScene = third option
        default:
            whichScene = .figure8
            texture = SKTexture(imageNamed: "fig8Icon")
//            commonLabelBackground.move(toParent: f8TrackCamera)
//            commonLabelBackground.size = f8Background.size
//            switchView.position = CGPoint(x: scene!.view!.bounds.width * -0.42, y: scene!.view!.bounds.height * -0.46)
//            commonLabelBackground.setScale(5)
//            commonLabelBackground.setScale(0.6)
            print("f8 cLBack: \(commonLabelBackground.parent!)")
            print("kamera: \(kamera!)\nkamera.camera: \(kamera!.camera ?? sTrackCamera)")
//            position = CGPoint(x: f8TrackCamera.frame.width * -0.42, y: f8TrackCamera.frame.height * -0.46)
        }
//        setScale(2)
//        print("sTrackWidth/straightScene.width: \(sTrackWidth/straightScene.width)")
//        position = CGPoint(x: -320.8, y: -480.8)
        
        //MARK: - Ensure the correct Go/Stop icon is displayed!
        if runStop == .stop {
            f8StartStop.texture = SKTexture(imageNamed: "runIcon")
            sStartStop.texture = SKTexture(imageNamed: "runIcon")
        } else {
            f8StartStop.texture = SKTexture(imageNamed: "stopIcon")
            sStartStop.texture = SKTexture(imageNamed: "stopIcon")
        }

        redoCamera()
        alpha = 1.0
//        position = CGPoint(x: f8TrackCamera.frame.width * -0.42, y: f8TrackCamera.frame.height * -0.46)
//        print("sTrackCamera: \(straightScene.size),    f8TrackCamera: \(f8TrackCamera.frame.size)")
//        switchView.position = CGPoint(x:scene!.view!.bounds.width * -0.42,y:scene!.view!.bounds.height * -0.46)
    }

}
