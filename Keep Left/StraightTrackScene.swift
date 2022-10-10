//
//  StraightTrackScene.swift
//  Keep Left
//
//  Created by Bill Drayton on 3/2/2022.
//

import Foundation
import SpriteKit
import SwiftUI
import UIKit

//Convert Degrees to Radians
//Usage eg. spriteNode.zRotation = CGFloat(30).degrees()
public extension CGFloat {
    func degrees() -> CGFloat {
        return self * CGFloat.pi / 180
    }
}

var toggleSpeed: Int = 1    //Temp for vehicle speed
var firstThru = true        //Set to false after all vehicle speeds evaluated once

var f8SwitchView: SwitchView = SwitchView()   //Move between Straight Track and Figure 8 Track views.
var f8StartStop: StartStop = StartStop()      //Start and stop vehicle movement.
var sSwitchView: SwitchView = SwitchView()   //Move between Straight Track and Figure 8 Track views.
var sStartStop: StartStop = StartStop()      //Start and stop vehicle movement.

var f8Scale: CGFloat = 0        //Ratio of screen display to physical display
var sScale: CGFloat = 0

var straightScene = SceneModel()    //Includes .metre1 scale factor
var f8Scene = SceneModel()          //Includes .metre1 scale factor
var sBackground = Background()      //Straight Track Parent and Background
var f8Background = Background()     //Figure 8 Track Parent and Background
var commonLabelBackground = SKSpriteNode()

var sTrackCamera: SKCameraNode = SKCameraNode()     //Create SKCameraNode instance
var f8TrackCamera: SKCameraNode = SKCameraNode()    //Create SKCameraNode instance
var kamera: SKScene?

//protocol CanReceiveTransitionEvents {
//    func viewWillTransition(to size: CGSize)
//}
var tempNo: CGFloat = 0.0

var vBody: SKSpriteNode!

var sprite: SKSpriteNode!   //Temporary to stop XCode errors!

var newNo: CGFloat = 120    // !!!! TEMP to randomise & dampen vehicle speed !!!!
var oldNo: CGFloat = 120

//var dONTrEPEAT = false

//Track scene may be temporary. Functions below MUST be called from within a scene!
class StraightTrackScene: SKScene, SKPhysicsContactDelegate, ObservableObject {
    
    @StateObject var vehicle = Vehicle()
    @StateObject var f8Vehicle = F8Vehicle()
    
//    //Reference the top and bottom figure 8 labels
//    var topLabel: LabelData?
//    var bottomLabel: LabelData?
    @StateObject var dummy: LabelData = LabelData()
    //Reference the top and bottom figure 8 labels
    @State var topLabel: LabelData = LabelData()
    @State var bottomLabel: LabelData = LabelData()


//    @StateObject var topLabel = LabelData()
//    @StateObject var bottomLabel = LabelData()
////    @EnvironmentObject var topLabel: LabelData
////    @EnvironmentObject var bottomLabel: LabelData

//    @StateObject var kLLabel = F8DataLabelModel()
//    @StateObject var otherLabel = F8DataLabelModel()

//    static var sBackground: SKSpriteNode = SKSpriteNode(color: UIColor(red: 0.19, green: 0.38, blue: 0.16, alpha: 1), size: CGSize(width: 2, height: 4))

    //property and function for handling rotation
    var sOneTime = false    //Only allows container to be created once
    var viewCreated = false
    var updateOneTime = false
    
//    var f8KLLabelTitle: Label = Label() //Create Label instance


    let sContainer = SKNode()       //(Not called?)
    func set(sContainerZRotation:CGFloat) {
        sContainer.zRotation = sContainerZRotation
    }
    
    var bridge = Background()           //Create bridge at higher zPos

//    var toggleSpeed: Int = 2
//
    override func didChangeSize(_ oldSize: CGSize) {
        
        updateOneTime = false
//        print("didChangeSize triggered. Fig 8 alpha = \(f8Background.alpha). whichScene = \(whichScene)")
    }
    
    override func didMove(to view: SKView) {
        
        //MARK: - Create swipe gesture recognisers
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(StraightTrackScene.swipeLeft(sender:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(StraightTrackScene.swipeRight(sender:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)

        //        let value = UIInterfaceOrientation.portrait.rawValue
//        UIDevice.current.setValue(value, forKey: "orientation")
//
        if viewCreated == false {
  
        if sOneTime == false {
            self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            self.addChild(sContainer) //add sContainer

            sOneTime = true
        }

        //MARK: - Create background colour (width: screenwidth, height: 1km). Define sMetre1 = multiplier for metres to points
//        calcScale()

        straightScene.calcStraightScene(sSize: view.bounds.size)    //Define straightScene parameters
//        portrait = straightScene.portrait
//        sMetre1 = straightScene.metre1
//        sSceneWidth = straightScene.width
//        sSceneHeight = straightScene.height
        
        scene?.size.width = straightScene.width //* 2         // XXXXXXXXXXXXXXXXXXXXXX !!!!!!!!!!
        scene?.size.height = 1000

            sBackground.makeBackground(size: CGSize(width: straightScene.width * 2, height: 1000 * straightScene.metre1), zPos: -200)
            sBackground.anchorPoint = CGPoint(x: 0.5, y: 0)
//            print("1. Scene = \(scene?.size) : sBackground = \(sBackground.size)")

//            sBackground.position = CGPoint(x: 0, y: 0)    // = default
//            sBackground.color = UIColor(red: 0.89, green: 0.38, blue: 0.16, alpha: 0.3) //Is already
//            scene?.backgroundColor = UIColor(red: 0.19, green: 0.38, blue: 0.16, alpha: 1)    //Can colour scene too! Currently background is coloured.
//            sBackground.size = CGSize(width: straightScene.width * 2, height: straightScene.height)
            addChild(sBackground)
            
//            sContainer.scene?.size = CGSize(width: sTrackWidth * straightScene.metre1, height: 1000 * straightScene.metre1)
//            sContainer.scene?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
//            print("2. Scene = \(scene?.size) : sBackground = \(sBackground.size)")
//        scene?.backgroundColor = UIColor(red: 0.19, green: 0.38, blue: 0.16, alpha: 1)
//        scene?.zPosition = -55
//        scene?.scaleMode = .aspectFill
        physicsWorld.gravity = .zero
        
        scene?.scaleMode = .resizeFill
            
            let hGTWx2: Bool = f8Scene.calcF8Scene(f8Size: view.bounds.size)       //Define f8Scene parameters
            
            //MARK: - Create f8Background Node
            let f8BackgroundHeight = f8ScreenHeight                     //= 400m
            let f8BackgroundWidth = f8BackgroundHeight/f8ImageAspect    //Assumes track image height = 400m !!!
            f8Background.makeBackground(size: CGSize(width: f8BackgroundWidth, height: f8BackgroundHeight), image: "Fig 8 Track", zPos: 0)
            f8Background.position = CGPoint(x: 0, y: 500 * straightScene.metre1)
            f8Background.name = "f8Background"
            F8YZero = f8Background.position.y
            addChild(f8Background)
            f8Background.alpha = ((whichScene == .figure8) ? 1.0 : 0)
            f8Scale = (f8BackgroundHeight/straightScene.height)
            f8TrackCamera.setScale(f8Scale)
//            f8TrackCamera.setScale(0.2 * f8BackgroundHeight/straightScene.height) //Camera Scale - mx by 0.5 temporary !!!   XXXXXXXXXXXXXXX
            
//            f8TrackCamera.position = CGPoint(x: 0, y: 0)
            sTrackCamera.position = CGPoint(x: 0, y: 0 + 500)
            sTrackCamera.setScale(sTrackWidth/straightScene.width)

            sTrackCamera.name = "sTrackCamera"
            f8TrackCamera.name = "f8TrackCamera"

            self.camera = ((whichScene == .figure8) ? f8TrackCamera : sTrackCamera)

            //MARK: - Create sLabelParent Node
            let sLabelParent = SKSpriteNode()                    //Labels are children of f8Background. Groups them together and puts the
            sLabelParent.position = CGPoint(x: 0, y: (sTrackLength / 2))    //  base zPos = sBackground + 100
            sLabelParent.zPosition = 1000000000
            sBackground.addChild(sLabelParent)
            
            //MARK: - Create f8LabelParent Node
            let f8LabelParent = SKSpriteNode()                    //Labels are children of f8Background. Groups them together and puts the
            f8LabelParent.position = CGPoint(x: 0, y: 0)    //  base zPos = sBackground + 100
            f8LabelParent.zPosition = 100
            f8Background.addChild(f8LabelParent)
            
            //MARK: - Create f8KLLabel Node
            let f8KLLabel = SKNode()                                //Hierarchy: f8Background -> f8LabelParent -> f8KLLabel
            f8KLLabel.position = CGPoint(x: 0, y: f8CircleCentre)   //Set position inside top loop of figure 8 track
            f8KLLabel.zPosition = 10
            f8LabelParent.addChild(f8KLLabel)                       //Make child of f8LabelParent
            
            //MARK: - Create f8OtherLabel Node
            let f8OtherLabel = SKNode()                                //Hierarchy: f8Background -> f8LabelParent -> f8KLLabel
            f8OtherLabel.position = CGPoint(x: 0, y: -1 * f8CircleCentre)   //Set position inside lower loop of figure 8 track
            f8OtherLabel.zPosition = 1000000000000000000
            f8LabelParent.addChild(f8OtherLabel)                       //Make child of f8LabelParent
            
            //MARK: - Create commonViewBackground Node
            commonLabelBackground.zPosition = 1
            commonLabelBackground.name = "commonLabelBackground"
            f8Background.addChild(commonLabelBackground)
            commonLabelBackground.size = f8Background.size
            
            var cornerIconX: CGFloat = 94          //X offset from centre in f8 metres
            var cornerIconY: CGFloat = 182          //Y offset from centre in f8 metres
            //MARK: - Create Start/Stop Button
            //Figure 8 Track
            f8LabelParent.addChild(f8StartStop)
            f8StartStop.position = CGPoint(x: cornerIconX, y: -cornerIconY)
//            f8StartStop.position = CGPoint(x: f8BackgroundWidth * 0.42, y: f8BackgroundHeight * -0.46)
            f8StartStop.zPosition = 10000
            
            //Straight Track
            sLabelParent.addChild(sStartStop)
            sStartStop.position = CGPoint(x: cornerIconX * (f8Scene.metre1 / straightScene.metre1), y: -cornerIconY * (f8Scene.metre1 / straightScene.metre1))
            sStartStop.size = CGSize(width: f8StartStop.size.width * (f8Scene.metre1 / straightScene.metre1), height: f8StartStop.size.height * (f8Scene.metre1 / straightScene.metre1))
            sStartStop.zPosition = 10000000000
            print("UIScreen: \(UIScreen.main.bounds)")
            print("UIScreenNative: \(UIScreen.main.nativeBounds)")
            print("Camera: \(self.camera)!")

            //MARK: - Create Change View Button
            //Figure 8 Track
            f8LabelParent.addChild(f8SwitchView)
            f8SwitchView.position = CGPoint(x: -cornerIconX, y: -cornerIconY)
//            f8SwitchView.position = CGPoint(x: f8BackgroundWidth * -0.42, y: f8BackgroundHeight * -0.46)
            f8SwitchView.zPosition = 10

            //Straight Track
            sLabelParent.addChild(sSwitchView)
//            sSwitchView.position = CGPoint(x: -50, y: -95)
            sSwitchView.position = CGPoint(x: -cornerIconX * (f8Scene.metre1 / straightScene.metre1), y: -cornerIconY * (f8Scene.metre1 / straightScene.metre1))
            sSwitchView.texture = SKTexture(imageNamed: "fig8Icon")
            sSwitchView.size = CGSize(width: f8StartStop.size.width * (f8Scene.metre1 / straightScene.metre1), height: f8StartStop.size.height * (f8Scene.metre1 / straightScene.metre1))
//            sSwitchView.position = CGPoint(x: sBackground.size.width * 0.42, y: sBackground.size.height * -0.46)
            sSwitchView.zPosition = 100000000

            //MARK: - Create mask for overhead bridge
            let bridge = SKCropNode()
            bridge.position = CGPoint(x: 0, y: 0)
            bridge.zPosition = 15       //Set "altitude" of bridge
            bridge.maskNode = SKSpriteNode(color: .red, size: CGSize(width: bridgeWidth, height: bridgeWidth))
            bridge.zRotation = CGFloat(45).degrees()        //Create cropping mask

            let bridgeCrop = SKSpriteNode(imageNamed: "Fig 8 Track")    //Set bridgeCrop equiv to f8Background
            bridgeCrop.size = f8Background.size
            bridgeCrop.position = CGPoint(x: 0, y: 0)
            bridgeCrop.name = "bridge"
            bridgeCrop.zRotation = -CGFloat(45).degrees()   //Compensate for mask rotation
            
            bridge.addChild(bridgeCrop)
            f8Background.addChild(bridge)
            
            kamera = self       //'self' here = sBackground

        //MARK: - Add 2x straight roads to StraightTrackScene
        addRoads()
        
            sBackground.addChild(sTrackCamera)
            f8Background.addChild(f8TrackCamera)
            
            //MARK: - Add Keep Left Track labelNode
            topLabel.createTrackLabels(labelParent: f8KLLabel, topLabel: true)
            
            //MARK: - Add Other Track labelNode
            bottomLabel.createTrackLabels(labelParent: f8OtherLabel, topLabel: false)
            
//
//            //MARK: - Add magnifier: TEMP CODE FOR TESTING!!!
//            var magView = f8Background.texture
//
//            var f8MagnifierRadius: CGFloat = 10.0
//            var f8Magnifier = SKShapeNode(circleOfRadius: f8MagnifierRadius)
//            f8Magnifier.fillTexture = f8Background.texture
//            f8Magnifier.strokeColor = .black
//            f8Magnifier.zPosition = 50
////            f8Magnifier.fillTexture?.size().width = f8Background.texture?.size().width * 2
//
//            f8Magnifier.physicsBody = SKPhysicsBody(circleOfRadius: f8MagnifierRadius)
//            f8Magnifier.physicsBody?.node?.zPosition = 50
//            f8Magnifier.physicsBody?.node?.setScale(2)
//
//            f8Background.addChild(f8Magnifier)
//
            
            //__________________________ TEMP 16m dia red circles spaced 50m apart
            let showMarkers = false
            if showMarkers == true {
                
                //CIRCLES
            for x in stride(from: -150, through: 150, by: 50) {
                let aa = SKShapeNode(circleOfRadius: 8)
                aa.fillColor = SKColor(red: 0, green: 1, blue: 1, alpha: 0.5)
                aa.zPosition = 1
                aa.position = CGPoint(x: x, y: 0)
                f8Background.addChild(aa)
            }
            for y in stride(from: -250, through: 250, by: 50) {
                let aa = SKShapeNode(circleOfRadius: 8)
                aa.fillColor = SKColor(displayP3Red: 0, green: 0, blue: 1, alpha: 1)
                aa.zPosition = 1
                aa.position = CGPoint(x: 0, y: y)
                f8Background.addChild(aa)
            }

                //TOP LINES
            let aa = SKSpriteNode(color: .red, size: CGSize(width: 300, height: 1))
            let bb = SKSpriteNode(color: .red, size: CGSize(width: 1, height: 10))
            bb.zPosition = 100
            aa.addChild(bb)

//            aa.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            aa.zRotation = CGFloat(45).degrees()
            aa.zPosition = 100
//            aa.strokeColor = SKColor(red: 1, green: 0, blue: 0, alpha: 1)
            aa.position = CGPoint(x: -(sin(CGFloat(45).degrees()) * 75), y: (sin(CGFloat(45).degrees()) * 75))
            print("Line Pos: \(aa.position)")
            f8Background.addChild(aa)

            let gg = SKSpriteNode(color: .red, size: CGSize(width: 300, height: 1)) //Long red line
            let hh = SKSpriteNode(color: .red, size: CGSize(width: 1, height: 10))  //Short red line
            hh.zPosition = 100
            gg.addChild(hh)

            gg.zRotation = -CGFloat(45).degrees()
            gg.zPosition = 100
            gg.position = CGPoint(x: (sin(CGFloat(45).degrees()) * 75), y: (sin(CGFloat(45).degrees()) * 75))
            print("Line Pos: \(gg.position)")
            f8Background.addChild(gg)

                //BOTTOM LINES
                let nn = SKSpriteNode(color: .red, size: CGSize(width: 300, height: 1))
                let oo = SKSpriteNode(color: .red, size: CGSize(width: 1, height: 10))
                oo.zPosition = 100
                nn.addChild(oo)

                nn.zRotation = CGFloat(45).degrees()
                nn.zPosition = 100
                nn.position = CGPoint(x: -(sin(CGFloat(45).degrees()) * 75), y: -3 * (sin(CGFloat(45).degrees()) * 75))
                print("Line Pos: \(nn.position)")
                f8Background.addChild(nn)

                let pp = SKSpriteNode(color: .red, size: CGSize(width: 300, height: 1)) //Long red line
                let qq = SKSpriteNode(color: .red, size: CGSize(width: 1, height: 10))  //Short red line
                qq.zPosition = 100
                pp.addChild(qq)

                pp.zRotation = -CGFloat(45).degrees()
                pp.zPosition = 100
                pp.position = CGPoint(x: (sin(CGFloat(45).degrees()) * 75), y: -3 * (sin(CGFloat(45).degrees()) * 75))
                print("Line Pos: \(pp.position)")
                f8Background.addChild(pp)
            }
            //_________________ above is TEMP 16m dia red circles spaced 50m apart

        viewCreated = true
        }
        
        redoCamera()    //Don't call until metre1 calculated!!!

        let ms500Timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(every500ms), userInfo: nil, repeats: true)
        
//        let isLandscape = (view.bounds.size.width > view.bounds.size.height)  //NOTE: Doesn't recognise UIDevice rotation here!!!
//        let rotation = isLandscape ? CGFloat.pi/2 : 0
//        print("Rotation = \(rotation) : isLandscape = \(isLandscape)\nsContainer.frame.width = \(view.bounds.size.width)\nsContainer.frame.height = \(view.bounds.size.height)")
////        sContainer.zRotation = rotation //Normally done in StraightTrackView.swift. Required here 1st time only when starting in landscape.
//
    }
    
    ///////////////////////////////////////////
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        let value = UIInterfaceOrientation.landscapeLeft.rawValue
//        UIDevice.current.setValue(value, forKey: "orientation")
//    }

//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        UIInterfaceOrientationMask.
//        return .portrait
//    }
//
//    override var shouldAutorotate: Bool {
//        return false
//    }
//    ///////////////////////////////////////////
    
//    override func preferredInterfaceOrientationForPr  esentation: UIInterfaceOrientation {
//        return UIInterfaceOrientation.portrait
//    }
    
    override func update(_ currentTime: TimeInterval) {
        //ideally occurs every 60ms
        
//        f8Background.alpha = ((whichScene == .figure8) ? 1.0 : 0)

        if updateOneTime == false {
        let orientation = UIDevice.current.orientation    //1: Portrait, 2: UpsideDown, 3: LandscapeLeft, 4: LandscapeRight
        print("Orientation = \(orientation)")
        switch orientation {
        case .portrait:
            camera?.zRotation = 0
            print("Portrait - orientation = \(orientation)")
        case .portraitUpsideDown:
            camera?.zRotation = CGFloat.pi/3
            print("Portrait Upside Down - orientation = \(orientation)")
        case .landscapeLeft:
            camera?.zRotation = 2 * CGFloat.pi
            print("Landscape Left - orientation = \(orientation)")
        case .landscapeRight:
            camera?.zRotation = CGFloat.pi/2
            print("Landscape Right - orientation = \(orientation)")
        default:
            camera?.zRotation = 0
            print("Default - orientation = \(orientation)")
        }

        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
            
            updateOneTime = true
        }
        
        //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
        //Run on Main Thread!
        
        if gameStage <= 0xFF {                          //Prevents code from running before vehicles are created
            var temp1 = sKLAllVehicles.dropFirst()      //Straight Track Vehicles: Ignore 'All Vehicles'
            var nodeData: NodeData = NodeData()
            var t1Vehicle: [NodeData] = []
            
            for (index, veh1Node) in temp1.enumerated() {
                nodeData.name = veh1Node.name!      //OR = (index + 1)?
                nodeData.size = veh1Node.size
                nodeData.position = veh1Node.position
                nodeData.lane = veh1Node.lane
                nodeData.laps = veh1Node.laps
                nodeData.currentSpeed = veh1Node.physicsBody!.velocity.dy * 3.6      //  ????? x 3.6 for kph?
                t1Vehicle.append(nodeData)
            }
            
            var temp2 = sOtherAllVehicles.dropFirst()      //Straight Track Vehicles: Ignore 'All Vehicles'
            //var nodeData: NodeData = NodeData()
            var t2Vehicle: [NodeData] = []
            
            for (index, veh2Node) in temp2.enumerated() {
                nodeData.name = veh2Node.name!      //OR = (index + 1)?
                nodeData.size = veh2Node.size
                nodeData.position = veh2Node.position
                nodeData.lane = veh2Node.lane
                nodeData.laps = veh2Node.laps
                nodeData.currentSpeed = veh2Node.physicsBody!.velocity.dy * 3.6      //  ????? x 3.6 for kph?
                t2Vehicle.append(nodeData)
            }
            
            Task {
                var result = await nodeData.findObstacles(t1Vehicle: &t1Vehicle, t2Vehicle: &t2Vehicle)
                let t1Vehicle = result.t1Vehicle
                let t2Vehicle = result.t2Vehicle
            }
            
        }
        
        //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
        

    }   //End of override update
    
    //        //The following code can replace the above - it's easier to follow but I suspect
    //        //creating the extra array would have a time penalty
    //        let dualArray = Array(zip(t1Vehicle, t2Vehicle))
    //        for (sKLNode, sOtherNode) in dualArray  {
    //            if sKLNode.position.y >= (1000 * sMetre1) {
    //                sKLNode.position.y = (sKLNode.position.y - (1000 * sMetre1))
    //            }
    //            if sOtherNode.position.y < 0 {
    //                sOtherNode.position.y = (sOtherNode.position.y + (1000 * sMetre1))
    //            }
    //        }
    //
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}   //Exit if not first touch!
        
        var kph: CGFloat = 130
        let multiplier: CGFloat = 1000 / 3600  //Value by kph gives m/sec
        
        toggleSpeed += 1
//        switch toggleSpeed {
//        case 0:
//        for i in 1...numVehicles {
//            sBackground.childNode(withName: "sKLVehicle_\(i)")?.physicsBody?.velocity.dy = 0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
//            sBackground.childNode(withName: "sOtherVehicle_\(i)")?.physicsBody?.velocity.dy = -0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
//        }
//        case 1:
//            for i in 1...numVehicles {
//                sBackground.childNode(withName: "sKLVehicle_\(i)")?.physicsBody?.velocity.dy = kph * multiplier   //1000 = metres in km. 3600 = secs in hour.
////                sBackground.childNode(withName: "sOtherVehicle_\(i)")?.physicsBody?.velocity.dy = -0 * multiplier   //1000 = metres in km. 3600 = secs in hour. (NOTE: THE INSTRUCTIONS COMMENTED OUT DON'T CHANGE THE SPEED!)
//            }
//        case 2:
//            for i in 1...numVehicles {
//                sBackground.childNode(withName: "sKLVehicle_\(i)")?.physicsBody?.velocity.dy = kph * multiplier   //1000 = metres in km. 3600 = secs in hour.
//                sBackground.childNode(withName: "sOtherVehicle_\(i)")?.physicsBody?.velocity.dy = -(0.9 * kph) * multiplier   //1000 = metres in km. 3600 = secs in hour.
//            }   //$$$$$$$$$$$$$$$     !!! Other lane slowed above to create difference !!!     $$$$$$$$$$$$$$$$$$$$$$$$$$$$
//        case 3:
//            for i in 1...numVehicles {
//                sBackground.childNode(withName: "sKLVehicle_\(i)")?.physicsBody?.velocity.dy = 0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
////                sBackground.childNode(withName: "sOtherVehicle_\(i)")?.physicsBody?.velocity.dy = -kph * multiplier   //1000 = metres in km. 3600 = secs in hour.
//            }
//        default:
//            for i in 1...numVehicles {
////                sBackground.childNode(withName: "sKLVehicle_\(i)")?.physicsBody?.velocity.dy = 0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
//                sBackground.childNode(withName: "sOtherVehicle_\(i)")?.physicsBody?.velocity.dy = -0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
//            }
//        }
//
/*        switch toggleSpeed {
        case 0:
        for i in 1...numVehicles {
            sBackground.childNode(withName: "sKLVehicle_\(i)")?.physicsBody?.velocity.dx = 0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
            sBackground.childNode(withName: "sOtherVehicle_\(i)")?.physicsBody?.velocity.dx = -0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
        }
        case 1:
            for i in 1...numVehicles {
                sBackground.childNode(withName: "sKLVehicle_\(i)")?.physicsBody?.velocity.dx = kph * multiplier   //1000 = metres in km. 3600 = secs in hour.
//                sBackground.childNode(withName: "sOtherVehicle_\(i)")?.physicsBody?.velocity.dx = -0 * multiplier   //1000 = metres in km. 3600 = secs in hour. (NOTE: THE INSTRUCTIONS COMMENTED OUT DON'T CHANGE THE SPEED!)
            }
        case 2:
            for i in 1...numVehicles {
                sBackground.childNode(withName: "sKLVehicle_\(i)")?.physicsBody?.velocity.dx = kph * multiplier   //1000 = metres in km. 3600 = secs in hour.
                sBackground.childNode(withName: "sOtherVehicle_\(i)")?.physicsBody?.velocity.dx = -kph * multiplier   //1000 = metres in km. 3600 = secs in hour.
            }
        case 3:
            for i in 1...numVehicles {
                sBackground.childNode(withName: "sKLVehicle_\(i)")?.physicsBody?.velocity.dx = 0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
//                sBackground.childNode(withName: "sOtherVehicle_\(i)")?.physicsBody?.velocity.dx = -kph * multiplier   //1000 = metres in km. 3600 = secs in hour.
            }
        default:
            for i in 1...numVehicles {
//                sBackground.childNode(withName: "sKLVehicle_\(i)")?.physicsBody?.velocity.dx = 0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
                sBackground.childNode(withName: "sOtherVehicle_\(i)")?.physicsBody?.velocity.dx = -0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
            }
        }   */
        
//            toggleSpeed = -1
//        print("Vehicle 1 Node = \(childNode(withName: "sKLVehicle_1")!)")

        if toggleSpeed == 4 {
//            toggleSpeed = -1
            toggleSpeed = 0 // WAS toggleSpeed = 0 when Fig8Scene accessed from here!!!
            ////            var scene = Fig8Scene(fileNamed: "Fig8Scene")!
            //            var scene = Fig8Scene()
            ////            var transition: SKTransition = SKTransition.moveIn(with: .right, duration: 2)
            //            var transition: SKTransition = SKTransition.fade(withDuration: 2)
            //            self.view?.presentScene(scene, transition: transition)
////            print("toggleSpeed = \(toggleSpeed)")
        } else if toggleSpeed == 6 {
            toggleSpeed = 0
//            var transition: SKTransition = SKTransition.fade(withDuration: 2)
//            var scene = StraightTrackScene()
//            self.view?.presentScene(scene)
        }
//        toggleSpeed = toggleSpeed + 1
    } // //ZZZ
    
    func addRoads() {
        createKLSRoad()
        createOtherSRoad()
        
//        if dONTrEPEAT == false {
        let veh = makeVehicle()
//            dONTrEPEAT = true
//        }
    }   //End addRoads
    
    func createKLSRoad() {
    let sKLRoad = createRoadSurface(xOffset: -((roadWidth + centreStrip) / 2), parent: sBackground)
    createCentreLines(xOffset: -((roadWidth + centreStrip) / 2), parent: sBackground)    //NOTE: Changing parent also changes origin!!!
    createInsideLines(xOffset: -(shoulderWidth + (shoulderLineWidth / 2) + (centreStrip / 2)), parent: sBackground)
    createOutsideLines(xOffset: -(roadWidth + (centreStrip / 2) - (shoulderWidth + (shoulderLineWidth / 2))), parent: sBackground)
    }   //End
    
    func createOtherSRoad() {
    let sOtherRoad = createRoadSurface(xOffset: ((roadWidth + centreStrip) / 2), parent: sBackground)
    createCentreLines(xOffset: ((roadWidth + centreStrip) / 2), parent: sBackground)    //NOTE: Changing parent also changes origin!!!
    createInsideLines(xOffset: (shoulderWidth + (shoulderLineWidth / 2) + (centreStrip / 2)), parent: sBackground)
    createOutsideLines(xOffset: (roadWidth + (centreStrip / 2) - (shoulderWidth + (shoulderLineWidth / 2))), parent: sBackground)
    }   //End
    
    func createRoadSurface(xOffset: CGFloat = 0, parent: SKNode) -> SKNode {
//    var roadLength: CGFloat = 1000.0
//    var roadWidth: CGFloat = 8.0
//    var yOffset: CGFloat = -500.0  //default = -500
    var zPos: CGFloat = +10
        
    let line = createLine(xOffset: xOffset, lWidth: roadWidth, lLength: roadLength, colour: asphalt, zPos: zPos, parent: parent)   //Lay down bitumen

        return line
    }

    func createCentreLines(xOffset: CGFloat = 0, parent: SKNode) {
        var yOffset = 0.0    //Starting point for first line = -500m
//        let xOffset = (roadWidth / 2) + (centreStrip / 2)     //metres (no change from road surfaces)
//        let numLines: CGFloat = trunc(roadLength / linePeriod)
        let lineSpacing: CGFloat = 1000/83  //where 1000 = track length & 83 = no lines per km
        for i in 0..<83 {   //83 = no times centre line is drawn per 1km
            yOffset = (CGFloat(i) * lineSpacing)  //metres
            createLine(xOffset: xOffset, yOffset: yOffset, lLength: lineLength, parent: parent)
//            print("Line Spacing = \(yOffset) metres : sMetre1 = \(sMetre1)")
        }   //end for loop
    }

    func createInsideLines(xOffset: CGFloat = 0, parent: SKNode) {
        let yOffset = 0.0
//        let xOffset = (shoulderLineWidth / 2) + (shoulderWidth) + (centreStrip / 2)     //metres (no change from road surfaces)
//        let roadLength = 1000.0
//        let lWidth = lineWidth    //Default = lineWidth
//        zPos = -53                 //Default = -53
        createLine(xOffset: xOffset, yOffset: yOffset, lWidth: shoulderLineWidth, lLength: roadLength, parent: parent)
    }

    func createOutsideLines(xOffset: CGFloat = 0, parent: SKNode) {
        let yOffset = 0.0
//        let xOffset = (roadWidth - ((shoulderLineWidth / 2) + (shoulderWidth))) + (centreStrip / 2)
//        let roadLength = 1000.0
//        let lWidth = lineWidth  //Default = lineWidth
//        zPos = -53    //createLine defaults to -53 & colour defaults to white
        createLine(xOffset: xOffset, yOffset: yOffset, lWidth: shoulderLineWidth, lLength: roadLength, parent: parent)
//        Line().createLine(xOffset: xOffset, yOffset: yOffset, lWidth: shoulderLineWidth, lLength: roadLength, lineParent: self)
//        print("size.width = \(size.width)")
    }
    //KKK TEMPORARY TEXT ADDED B4 NEXT CHANGES !!! DELETE ONCE WORKING !!!
    func createLine(xOffset: CGFloat = 0, yOffset: CGFloat = 0, lWidth: CGFloat = lineWidth, lLength: CGFloat = lineLength, colour: SKColor = .white, zPos: CGFloat = +20, parent: SKNode) -> SKNode {
//SKSpriteNode has better performance than SKShape!
        
        let line1 = SKSpriteNode(color: colour, size: CGSize(width: (lWidth), height: (lLength)))
//        line1.size = CGSize(width: (lWidth * straightScene.metre1), height: (lLength * straightScene.metre1))
//        line1.color = colour
        line1.anchorPoint = CGPoint(x: 0.5, y: 0) //Set anchorpoint to middle bottom
        line1.position.y = (yOffset)
        line1.position.x = (xOffset)
        line1.zPosition = zPos
//        line1.physicsBody?.isDynamic = false
//        line1.physicsBody?.collisionBitMask = 0
        
        parent.addChild(line1)
        
        return line1
        }

    
//    func putVehicle() -> SKSpriteNode {
////        let veh = SKSpriteNode(imageNamed: "VehicleImage/T1")
//        let veh = Vehicle(imageName: "VehicleImage/T1")
//
//        setAspectForWidth(sprite: veh)  //Sets veh width = 2m (default) & keeps aspect ratio
//        let vehSize = veh.size
////        veh.position = CGPoint(x: ((view?.bounds.size.width)! / 2.0) - ((5.85 + centreStrip/2) * sMetre1), y: 400.0 * sMetre1)
//        veh.zPosition = -49
//        veh.physicsBody = SKPhysicsBody(rectangleOf: vehSize)
//        veh.physicsBody?.friction = 0
//        veh.physicsBody?.restitution = 0
//        veh.physicsBody?.linearDamping = 0
//        veh.physicsBody?.angularDamping = 0
//        veh.physicsBody?.allowsRotation = false
////        sBackground.addChild(veh)
//        
//        return veh
//    }

//    func makeVehicle() -> Vehicle {
    func makeVehicle() {
        var fName: String = ""
        let maxVehicles: Int = (maxCars+maxTrucks+maxBuses)
//        var sKLVehicle: SKSpriteNode = SKSpriteNode(imageNamed: "\(vehImage)C1")
        
        var sKLAll: Vehicle = Vehicle(imageName: vehImage + "C1")       //Dummy node for 'All Vehicles' KL
        sKLAll.name = "sKLVehicle_0"
        sKLAll.distance = 0.0
//        sBackground.addChild(sKLAll)          //May not need to add to scene ???
        sKLAllVehicles.append(sKLAll)       //Place sKAll into position 0 of array
        var f8KLAll: F8Vehicle = F8Vehicle(imageName: vehImage + "C1")       //Dummy node for 'All Vehicles' KL
        f8KLAll.name = "sKLVehicle_0"
        f8KLAll.distance = 0.0
        f8KLAllVehicles.append(f8KLAll)

        var sOtherAll: Vehicle = Vehicle(imageName: vehImage + "C1")    //Dummy node for 'All Vehicles' Other
        sOtherAll.name = "sOtherVehicle_0"
        sOtherAll.distance = 0.0
//        sBackground.addChild(sOtherAll)       //May not need to add to scene ???
        sOtherAllVehicles.append(sOtherAll) //Place sOtherAll into position 0 of array
        var f8OtherAll: F8Vehicle = F8Vehicle(imageName: vehImage + "C1")    //Dummy node for 'All Vehicles' Other
        f8OtherAll.name = "f8OtherVehicle_0"
        f8OtherAll.distance = 0.0
        f8OtherAllVehicles.append(f8OtherAll)

        for i in 1...numVehicles {
            var randomVehicle = Int.random(in: 1...maxVehicles)
            var vWidth: CGFloat = 2.3   //Car width. Set truck & bus width = 2.5m (allow 300mm for side mirrors?)
            switch randomVehicle {
            case 1...maxCars:                       //Vehicle = Car
                fName = "C\(randomVehicle)"
            case (maxCars+1)...(maxCars+maxTrucks): //Vehicle = Truck
                fName = "T\(randomVehicle-maxCars)"
                vWidth = 2.5
            default:                                //Vehicle = Bus
                fName = "B\(randomVehicle-maxCars-maxTrucks)"
                vWidth = 2.5
            }
            
            var sKLVehicle: Vehicle = Vehicle(imageName: vehImage + String(fName))
            
            setAspectForWidth(sprite: sKLVehicle, width: vWidth)  //Sets veh width = 2m (default) & maintains aspect ratio
            let vehSize = sKLVehicle.size
            
            sKLVehicle.zPosition = +50
            sKLVehicle.name = "sKLVehicle_\(i)"  //sKLVehicle_x -> Straight Track 1, f1Vehicle_x -> Figure 8 Track 1, g1Vehicle_x -> Game Track 1.
            sKLVehicle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: sKLVehicle.size.width, height: sKLVehicle.size.height + 1))   //Make rectangle same size as sprite + 0.5m front and back!
            sKLVehicle.physicsBody?.friction = 0
            sKLVehicle.physicsBody?.restitution = 0
            sKLVehicle.physicsBody?.linearDamping = 0
            sKLVehicle.physicsBody?.angularDamping = 0
            sKLVehicle.physicsBody?.allowsRotation = false
            sKLVehicle.physicsBody?.isDynamic = true
            
            sBackground.addChild(sKLVehicle)
            
            //_________________________ Fig 8 Track below __________________________________________________
            var f8KLVehicle: F8Vehicle = F8Vehicle(imageName: vehImage + String(fName))

            f8KLVehicle.size = vehSize

            f8KLVehicle.zPosition = 10      //Set starting "altitude" above track and below bridge
            f8KLVehicle.name = "f8KLVehicle_\(i)"  //sKLVehicle_x -> Straight Track 1, f1Vehicle_x -> Figure 8 Track 1, g1Vehicle_x -> Game Track 1.
            f8KLVehicle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: f8KLVehicle.size.width, height: f8KLVehicle.size.height + 1))   //Make rectangle same size as sprite + 0.5m front and back!
            f8KLVehicle.physicsBody?.friction = 0
            f8KLVehicle.physicsBody?.restitution = 0
            f8KLVehicle.physicsBody?.linearDamping = 0
            f8KLVehicle.physicsBody?.angularDamping = 0
            f8KLVehicle.physicsBody?.allowsRotation = false
            f8KLVehicle.physicsBody?.isDynamic = false

            f8Background.addChild(f8KLVehicle)
            
            //_________________________ Fig 8 Track above __________________________________________________

            var sOtherVehicle: Vehicle = Vehicle(imageName: vehImage + String(fName))
            setAspectForWidth(sprite: sOtherVehicle, width: vWidth)  //Sets veh width = 2m (default) & maintains aspect ratio
            let secSize = sOtherVehicle.size
            
            sOtherVehicle.otherTrack = true //Flag identifies vehicle as being on the otherTrack!
            sOtherVehicle.zPosition = +50
            sOtherVehicle.name = "sOtherVehicle_\(i)"  //sOtherVehicle_x -> Straight Track 2, f2Vehicle_x -> Figure 8 Track 2, g2Vehicle_x -> Game Track 2.
            sOtherVehicle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: secSize.width, height: secSize.height + 1))   //Make rectangle same size as sprite + 0.5m front and back!
            sOtherVehicle.physicsBody?.friction = 0
            sOtherVehicle.zRotation = CGFloat(Double.pi)  //rotate 180 degrees //XXXXXXXXXX
            sOtherVehicle.physicsBody?.restitution = 0
            sOtherVehicle.physicsBody?.linearDamping = 0
            sOtherVehicle.physicsBody?.angularDamping = 0
            sOtherVehicle.physicsBody?.allowsRotation = false
            sOtherVehicle.physicsBody?.isDynamic = true
            
            sBackground.addChild(sOtherVehicle)

            //_________________________ Fig 8 Track below __________________________________________________
            var f8OtherVehicle: F8Vehicle = F8Vehicle(imageName: vehImage + String(fName))

            f8OtherVehicle.size = secSize

            f8OtherVehicle.otherTrack = true     //Flag identifies vehicle as being on the otherTrack!
            f8OtherVehicle.zPosition = 10       //Set starting "altitude" above track and below bridge
            f8OtherVehicle.name = "f8OtherVehicle_\(i)"  //sKLVehicle_x -> Straight Track 1, f1Vehicle_x -> Figure 8 Track 1, g1Vehicle_x -> Game Track 1.
            f8OtherVehicle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: f8OtherVehicle.size.width, height: f8OtherVehicle.size.height + 1))   //Make rectangle same size as sprite + 0.5m front and back!
            f8OtherVehicle.physicsBody?.friction = 0
            f8OtherVehicle.physicsBody?.restitution = 0
            f8OtherVehicle.physicsBody?.linearDamping = 0
            f8OtherVehicle.physicsBody?.angularDamping = 0
            f8OtherVehicle.physicsBody?.allowsRotation = false
            f8OtherVehicle.physicsBody?.isDynamic = false

            f8Background.addChild(f8OtherVehicle)

            //_________________________ Fig 8 Track above __________________________________________________

            f8KLAllVehicles.append(f8KLVehicle)
            f8OtherAllVehicles.append(f8OtherVehicle)

            sKLVehicle = placeVehicle(sKLVehicle: sKLVehicle, sOtherVehicle: sOtherVehicle)

            t1Stats["Name"]?.append(sKLVehicle.name!)
            t1Stats["Actual Speed"]?.append(0.0)
            if let unwrapped = t1Stats["Name"]?[i] {
//                if let speed = t1Stats["Actual Speed"]?[i] {
////                print("Name in Dictionary = \(unwrapped) : Speed = \(speed)")
//                }
            }
        }
        
        gameStage = gameStage & 0xFF    //Clear all but 8 LSBs when vehicles all exist
                                        //  - allows processing of vehicle speeds etc.

        return
//        return sKLVehicle
    }
    
//Function will randomly place vehicles onscreen.
    func placeVehicle(sKLVehicle: Vehicle, sOtherVehicle: Vehicle) -> Vehicle {
    var spriteClear = false
    var randomPos: CGFloat
    var randomLane: Int
        
//        scene?.enumerateChildNodes(withName: "//*") { (node, stop) in
//            print("\(node.name ?? "none")\t\(node.position.x.dp2)\t\(node.position.y.dp2)")
//                                   }
    
    repeat {
        randomPos = CGFloat.random(in: 0..<1000)    //Sets random y position in metres (0 - 999.99999 etc)
        randomLane = Int.random(in: 0...1)          //Sets initial Lane 0 (LHS) or 1 (RHS)
        sKLVehicle.position.y = randomPos
//        sKLVehicle.position.x = (randomLane == 0) ? ((sSceneWidth / 2.0) - (((roadWidth / 2) + (laneWidth / 2) + (lineWidth / 2) + (centreStrip/2)) * straightScene.metre1)) : ((sSceneWidth / 2.0) - (((roadWidth / 2) - (laneWidth / 2) - (lineWidth / 2) + (centreStrip/2)) * straightScene.metre1))
        sKLVehicle.position.x = (randomLane == 0) ? ( -((roadWidth / 2) + (laneWidth / 2) + (lineWidth / 2) + (centreStrip/2))) : ( -((roadWidth / 2) - (laneWidth / 2) - (lineWidth / 2) + (centreStrip/2)))
        sKLVehicle.startPos = sKLVehicle.position.y
        sKLVehicle.lane = CGFloat(randomLane)
        
        sOtherVehicle.position.y = 1000 - randomPos
//        sOtherVehicle.position.x = (randomLane == 0) ? ((sSceneWidth / 2.0) + (((roadWidth / 2) + (laneWidth / 2) + (lineWidth / 2) + (centreStrip/2)) * straightScene.metre1)) : ((sSceneWidth / 2.0) + (((roadWidth / 2) - (laneWidth / 2) - (lineWidth / 2) + (centreStrip/2)) * straightScene.metre1))
        sOtherVehicle.position.x = (randomLane == 0) ? ( +((roadWidth / 2) + (laneWidth / 2) + (lineWidth / 2) + (centreStrip/2))) : ( +((roadWidth / 2) - (laneWidth / 2) - (lineWidth / 2) + (centreStrip/2)))
        sOtherVehicle.startPos = sOtherVehicle.position.y
        sOtherVehicle.lane = CGFloat(randomLane)
        
        spriteClear = true
        //        veh.position = CGPoint(x: ((view?.bounds.size.width)! / 2.0) - ((5.85 + centreStrip/2) * sMetre1), y: 400.0 * sMetre1)
        //MARK: - Ensure vehicle doesn't overlap existing vehicle!
        for sprite in sKLAllVehicles.dropFirst() {
            if (sKLVehicle.intersects(sprite)) {
                spriteClear = false
//                print("\(sKLVehicle.name!)\t\(sKLVehicle.position.x.dp2)\t\(sKLVehicle.position.y.dp2)\t\(sprite.name ?? "none")\t\(sprite.position.x.dp2)\t\(sprite.position.y.dp2)")
                break
//            } else {
//                print("\(sKLVehicle.name!)\t\(sKLVehicle.position.x.dp2)\t\(sKLVehicle.position.y.dp2)")
            }
        }
//        print("\(sKLVehicle.name!)\t\(sKLVehicle.position.y.dp2)\tspriteClear: \(spriteClear)")
    } while !spriteClear
    
    sKLAllVehicles.append(sKLVehicle)
    sOtherAllVehicles.append(sOtherVehicle)

    return sKLVehicle
}

    func setAspectForWidth(sprite: Vehicle, width: CGFloat = 2) {
        let aspectRatio: CGFloat = sprite.size.height/sprite.size.width
        sprite.size = CGSize(width: width, height: width * aspectRatio)
    }
    
    func setAspectForHeight(sprite: Vehicle, height: CGFloat = 400) {
        let aspectRatio: CGFloat = sprite.size.height/sprite.size.width
        sprite.size = CGSize(width: height / aspectRatio, height: height)
    }
    
    //MARK: - Swipe left/right on figure 8 screen
    @objc func swipeLeft(sender: UISwipeGestureRecognizer) {
        
        if whichScene == .figure8 {
            if f8DisplayDat >= (numVehicles) {
                f8DisplayDat = 0
            } else {
                f8DisplayDat += 1
            }
            let delay5 = SKAction.wait(forDuration: oneVehicleDisplayTime)
            let backToAll = SKAction.run {
                f8DisplayDat = 0
            }
            let backToAllSequence = SKAction.sequence([delay5, backToAll])
            run(backToAllSequence, withKey: "backToAll")
        } else {
        }

    }

    @objc func swipeRight(sender: UISwipeGestureRecognizer) {
        
        if whichScene == .figure8 {
            if f8DisplayDat == 0 {
                f8DisplayDat = numVehicles
            } else {
                f8DisplayDat -= 1
            }
            //The following will set display back to All Vehicles after a delay
            let delay5 = SKAction.wait(forDuration: oneVehicleDisplayTime)
            let backToAll = SKAction.run {
                f8DisplayDat = 0
            }
            let backToAllSequence = SKAction.sequence([delay5, backToAll])
            run(backToAllSequence, withKey: "backToAll")
        } else {
            //.straight code here
        }
        
    }

    //MARK: - the function below runs every 500ms
    @objc func every500ms() {
        
        if runStop == .run {
            runTimer += 0.5             //Add 500ms to runTimer
        }
//        print("enableMinSpeed: \(enableMinSpeed)\t\trunTimer: \(runTimer)")
        

//    t1Vehicle = sKLAllVehicles   //Straight Track Vehicles
//    t2Vehicle = sOtherAllVehicles
    let t1Vehicle = sKLAllVehicles   //Straight Track Vehicles
    let t2Vehicle = sOtherAllVehicles
    var sumKL: CGFloat = 0
        var maxSumKL: CGFloat = 0
        var minSumKL: CGFloat = 99999999
    var sumOther: CGFloat = 0
        var maxSumOther: CGFloat = 0
        var minSumOther: CGFloat = 99999999
        
        // !!!! TEMPORARY !!!!
        let randNo: CGFloat = CGFloat.random(in: 75...145)
        newNo = (randNo + (3 * newNo)) / 4
        if newNo < oldNo - 1 {
            oldNo -= 1
        } else  if newNo > oldNo + 1 {
            oldNo += 1
        }
        let tempSpd: CGFloat = oldNo / 3.6  // -> km
        let otherTempSpeed: CGFloat = tempSpd - ((0.6 * (newNo - 85)) / 3.6)
        
        //MARK: - Set timeMx = hours of vehicle run time to now!
        let timeMx: CGFloat = 3600 / runTimer
        
    //Loop through both arrays simultaneously. Move back 1km when they've travelled 1km!
        for (sKLNode, sOtherNode) in zip(t1Vehicle.dropFirst(), t2Vehicle.dropFirst()) {
        if sKLNode.position.y >= 1000 {
            //IMPORTANT!!! ??? Prevent change to pos.y in other thread during the following instruction !!!
            sKLNode.position.y = (sKLNode.position.y - 1000)
            sKLNode.laps += 1
        }
            
            //MARK: - Flash vehicle when data displayed for single vehicle only
            flashVehicle(thisVehicle: sKLNode)

        switch runStop {   //Wait until vehicles started
        case .stop:
//            sKLNode.physicsBody?.velocity.dy = 0  // !!!! TEMPORARY !!!!
            sOtherNode.physicsBody?.velocity.dy = 0  // !!!! TEMPORARY !!!!

        case .run:
//            sKLAllVehicles[1].preferredSpeed = tempSpd
//            sKLNode.physicsBody?.velocity.dy = tempSpd  // !!!! TEMPORARY !!!!
            sOtherNode.physicsBody?.velocity.dy = -otherTempSpeed  // !!!! TEMPORARY !!!!
        }

        sKLNode.distance = (sKLNode.position.y - sKLNode.startPos) / sTrackLength + sKLNode.laps                //Distance travelled in km
//            print("sKLNodePos: \(sKLNode.position)")
        sKLNode.moveF8Vehicle(sNode: sKLNode, sNodePos: sKLNode.position, meta1: 0, F8YZero: 0) //Reposition figure 8 KL vehicles
//        print("Velocity: \(sKLNode.physicsBody!.velocity.dy.dp2)")
        
            if firstThru == true {                  //Ensures initial reading > max possible speed
                sKLNode.speedMin = 900
                sOtherNode.speedMin = 900
            }
            sKLNode.speedAvg = sKLNode.distance * timeMx                //Average speed for vehicle
            sKLNode.speedMax = max(sKLNode.speedMax, sKLNode.speedAvg)  //Max avg speed for vehicle
            if enableMinSpeed == true {
                sKLNode.speedMin = min(sKLNode.speedMin, sKLNode.speedAvg)
            }           //Min avg speed for vehicle. Ignores acceleration period.

            sumKL += sKLNode.distance                   //All veh's: Total distance for all summed
            maxSumKL = max(maxSumKL, sKLNode.distance)  //Max distance by a single vehicle NOW
            minSumKL = min(minSumKL, sKLNode.distance)  //Min distance for a single vehicle NOW
            
        if sOtherNode.position.y < 0 {
            //IMPORTANT!!! ??? Prevent change to pos.y in other thread during the following instruction !!!
            sOtherNode.position.y = (sOtherNode.position.y + 1000)
            sOtherNode.laps += 1
        }
            
        sOtherNode.distance = (sOtherNode.startPos - sOtherNode.position.y) / sTrackLength + sOtherNode.laps    //Distance travelled in km
        sOtherNode.moveF8Vehicle(sNode: sOtherNode, sNodePos: sOtherNode.position, meta1: 0, F8YZero: 0)    //Reposition figure 8 Other vehicles
        
            sOtherNode.speedAvg = sOtherNode.distance * timeMx                  //Average speed for vehicle
            sOtherNode.speedMax = max(sOtherNode.speedMax, sOtherNode.speedAvg) //Max avg speed for vehicle
            if enableMinSpeed == true {
                sOtherNode.speedMin = min(sOtherNode.speedMin, sOtherNode.speedAvg)
            }           //Min avg speed for vehicle. Ignores acceleration period.

            sumOther += sOtherNode.distance   //Total distance
            maxSumOther = max(maxSumOther, sOtherNode.distance)
            minSumOther = min(minSumOther, sOtherNode.distance)

//        updateF8Labels()
        
    }   //End of 'for' loop
        firstThru = false       //NEVER = true again !!!
        
        //MARK: - Calculate distances & speeds for 'All Vehicles'
        //Note: Avg Speed = speed to drive Avg Distance.
        //      Max Speed = Avg Speed of vehicle that has driven furthest
        //      Min Speed = Avg Speed of vehicle that has driven the least distance
        //(Note: @ present (24/8/22) avg, max & min the same as all vehicles driven at same speed over same distance.
        sKLAllVehicles[0].distance = sumKL / CGFloat(numVehicles)
        sKLAllVehicles[0].distanceMax = maxSumKL
        sKLAllVehicles[0].distanceMin = minSumKL

        sKLAllVehicles[0].speedAvg = sKLAllVehicles[0].distance * timeMx
        sKLAllVehicles[0].speedMax = maxSumKL * timeMx
        sKLAllVehicles[0].speedMin = minSumKL * timeMx

        sOtherAllVehicles[0].distance = sumOther / CGFloat(numVehicles)
        sOtherAllVehicles[0].distanceMax = maxSumOther
        sOtherAllVehicles[0].distanceMin = minSumOther

        sOtherAllVehicles[0].speedAvg = sOtherAllVehicles[0].distance * timeMx
        sOtherAllVehicles[0].speedMax = maxSumOther * timeMx
        sOtherAllVehicles[0].speedMin = minSumOther * timeMx
        
        topLabel.updateLabel(topLabel: true, vehicel: sKLAllVehicles[f8DisplayDat])
        bottomLabel.updateLabel(topLabel: false, vehicel: sOtherAllVehicles[f8DisplayDat])

}
    
//    //Function below called once / sec (or 500ms?)
//    func updateF8Labels() {
//
    
//        vehicle.f8KLLabelDescription.text = (f8DisplayDat == 0) ? "All Vehicles" : "Vehicle \(f8DisplayDat)"    //Display "All Vehicles" or "Vehicle x"
//
//        //Figure 8 Vehicles 1st !!!
//        vehicle.avgSpeed.text = "\(round("vehicle.sKLVehicle_\(f8DisplayDat)."speedAvg) \(kph))"         //
//
//    }

}

func redoCamera() {
    f8Background.alpha = ((whichScene == .figure8) ? 1.0 : 0)

    kamera?.camera = ((whichScene == .figure8) ? f8TrackCamera : sTrackCamera)
    sTrackCamera.position = CGPoint(x: 0, y: 0 + 500)
//        sTrackCamera.scene?.size.width = straightScene.width/sTrackWidth
    f8TrackCamera.position = CGPoint(x: 0, y: 0)
//    sTrackCamera.setScale(sTrackWidth/straightScene.width)
////        camera?.setScale(1/4)
////        f8TrackCamera.setScale(f8Scene.height/f8ImageHeight)
}

//MARK: - Function flashes vehicle when display shows only that data
func flashVehicle(thisVehicle: Vehicle) {           //Called every 500ms. 'thisVehicle' = sKL...
    
    //The code below extracts the vehicle number from its name. Ignores track etc.
    if let vehNum = Int.parse(from: thisVehicle.name!) {
        // Do something with this number
        
        switch f8DisplayDat {
        case 1...999999:                //Display shows 1 vehicle only
            
            if f8DisplayDat == vehNum {
                if thisVehicle.alpha == 0 {
                    thisVehicle.alpha = 1
                    sOtherAllVehicles[vehNum].alpha = 1
                    f8KLAllVehicles[vehNum].alpha = 1
                    f8OtherAllVehicles[vehNum].alpha = 1
                } else {
                    thisVehicle.alpha = 0
                    sOtherAllVehicles[vehNum].alpha = 0
                    f8KLAllVehicles[vehNum].alpha = 0
                    f8OtherAllVehicles[vehNum].alpha = 0
                }
            } else {
                thisVehicle.alpha = 1
                sOtherAllVehicles[vehNum].alpha = 1
                f8KLAllVehicles[vehNum].alpha = 1
                f8OtherAllVehicles[vehNum].alpha = 1
            }
        default:                        //Display shows 'All Vehicles' (f8DisplayData = 0)
            thisVehicle.alpha = 1
            sOtherAllVehicles[vehNum].alpha = 1
            f8KLAllVehicles[vehNum].alpha = 1
            f8OtherAllVehicles[vehNum].alpha = 1
        }
    }
}
