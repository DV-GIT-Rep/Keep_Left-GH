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
    /// Convert this value from Degrees to Radians
    /// - Returns: in Radians!
    /// - eg. node.zRotation = CGFloat(30).degrees(): saves 30deg in radians
    func degrees() -> CGFloat {
        return self * CGFloat.pi / 180
    }
    /// Convert this value from Radians to Degrees
    /// - Returns: in Degrees!
    /// - eg. angleDeg = atan(10 / 10).radians(): returns angle in degrees (45º)
    func radians() -> CGFloat {
        return self / (CGFloat.pi / 180)
    }
}

//extension SKNode {
//    func copi() -> SKNode {
//        var copy = SKNode()
//        copy = self
//        return copy
//    }
//}

var f8KLLabel = SKNode()    //Hierarchy: f8Background -> f8LabelParent -> f8KLLabel
var f8OtherLabel = SKNode()    //Hierarchy: f8Background -> f8LabelParent -> f8OtherLabel

//var toggleSpeed: Int = 1    //Temp for vehicle speed
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

let indicatorRadius = 0.2

//var dONTrEPEAT = false

//Track scene may be temporary. Functions below MUST be called from within a scene!
class StraightTrackScene: SKScene, SKPhysicsContactDelegate, ObservableObject {
    
//    let indic = SKShapeNode(rect: CGRectMake(<#T##CGFloat#>, <#T##CGFloat#>, <#T##CGFloat#>, <#T##CGFloat#>), cornerRadius: <#T##CGFloat#>)
//    let indic = SKShapeNode(rectOf: CGSize(width: 0.6, height: 0.4), cornerRadius: 0.15)
    let indic = SKShapeNode(circleOfRadius: indicatorRadius)
//    let indic = SKSpriteNode(color: SKColor(red: 255/255, green: 95/255, blue: 31/255, alpha: 1), size: CGSize(width: 3, height: 2))

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
    func set(sContainerZRotation: CGFloat) {
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
        scene?.size.height = sTrackLength

            sBackground.makeBackground(size: CGSize(width: straightScene.width * 2, height: sTrackLength * straightScene.metre1 * 2), zPos: -200)   //Added *2 to height 12.04.24. Better when zoomed out!
            sBackground.anchorPoint = CGPoint(x: 0.5, y: 0.05)  //was y: 0. Changed 12.04.24. Not sure why better?
//            print("1. Scene = \(scene?.size) : sBackground = \(sBackground.size)")

//            sBackground.position = CGPoint(x: 0, y: 0)    // = default
//            sBackground.color = UIColor(red: 0.89, green: 0.38, blue: 0.16, alpha: 0.3) //Is already
//            scene?.backgroundColor = UIColor(red: 0.19, green: 0.38, blue: 0.16, alpha: 1)    //Can colour scene too! Currently background is coloured.
//            sBackground.size = CGSize(width: straightScene.width * 2, height: straightScene.height)
            addChild(sBackground)
            
//            sContainer.scene?.size = CGSize(width: sTrackWidth * straightScene.metre1, height: sTrackLength * straightScene.metre1)
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
//            f8Background.xScale = -1
            f8Background.name = "f8Background"
            F8YZero = f8Background.position.y
            addChild(f8Background)
            f8Background.alpha = ((whichScene == .figure8) ? 1.0 : 0)
            f8Scale = (f8BackgroundHeight/straightScene.height)
            f8TrackCamera.setScale(f8Scale)
//            f8TrackCamera.setScale(0.2 * f8BackgroundHeight/straightScene.height) //Camera Scale - mx by 0.5 temporary !!!   XXXXXXXXXXXXXXX
            
            let f8BackShade = SKShapeNode(circleOfRadius: 10000)
            f8BackShade.fillColor = f8BackgroundColour
            f8BackShade.zPosition = -1
            f8Background.addChild(f8BackShade)
            
//            f8TrackCamera.position = CGPoint(x: 0, y: 0)
            sTrackCamera.position = CGPoint(x: 0, y: 0 + 500)
            sTrackCamera.setScale(sTrackWidth/straightScene.width)

            sTrackCamera.name = "sTrackCamera"
            f8TrackCamera.name = "f8TrackCamera"

            self.camera = ((whichScene == .figure8) ? f8TrackCamera : sTrackCamera)

            //MARK: - Create sLabelParent Node
            let sLabelParent = SKSpriteNode()                    //Labels are children of sBackground. Groups them together and puts the
            sLabelParent.position = CGPoint(x: 0, y: (sTrackLength / 2))    //  base zPos = sBackground + 100
            sLabelParent.zPosition = 1000000000
            sBackground.addChild(sLabelParent)
            
            //MARK: - Create f8LabelParent Node
            let f8LabelParent = SKSpriteNode()                    //Labels are children of f8Background. Groups them together and puts the
            f8LabelParent.position = CGPoint(x: 0, y: 0)    //  base zPos = sBackground + 100
            f8LabelParent.zPosition = 100
            f8Background.addChild(f8LabelParent)
            
            //MARK: - Create f8KLLabel Node
            let labelMask = SKShapeNode(circleOfRadius: 55) //Inside radius of blur
            labelMask.fillColor = .black
            labelMask.glowWidth = 6                         //Adds blur outside of ShapeNode
            
            let upperLabel = SKCropNode()
            upperLabel.position = CGPoint(x: 0, y: f8CircleCentre)   //Set position inside top loop of figure 8 track
            upperLabel.zPosition = 10
            upperLabel.maskNode = labelMask
            
//            let f8KLLabel = SKNode()    //Hierarchy: f8Background -> f8LabelParent -> f8KLLabel

            upperLabel.addChild(f8KLLabel)
            f8LabelParent.addChild(upperLabel)



//            let f8KLLabel = SKNode()                                //Hierarchy: f8Background -> f8LabelParent -> f8KLLabel
//            f8KLLabel.position = CGPoint(x: 0, y: f8CircleCentre)   //Set position inside top loop of figure 8 track
//            f8KLLabel.zPosition = 10
//            f8LabelParent.addChild(f8KLLabel)                       //Make child of f8LabelParent
            
            //MARK: - Create f8OtherLabel Node
            let lowerLabel = SKCropNode()
            lowerLabel.position = CGPoint(x: 0, y: -1 * f8CircleCentre)   //Set position inside top loop of figure 8 track
            lowerLabel.zPosition = 10
            lowerLabel.maskNode = labelMask
            
//            let f8OtherLabel = SKNode()    //Hierarchy: f8Background -> f8LabelParent -> f8KLLabel

            lowerLabel.addChild(f8OtherLabel)
            f8LabelParent.addChild(lowerLabel)




//            let f8OtherLabel = SKNode()                                //Hierarchy: f8Background -> f8LabelParent -> f8KLLabel
//            f8OtherLabel.position = CGPoint(x: 0, y: -1 * f8CircleCentre)   //Set position inside lower loop of figure 8 track
//            f8OtherLabel.zPosition = 1000000000000000000
//            f8LabelParent.addChild(f8OtherLabel)                       //Make child of f8LabelParent
            
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
            print("\nUIScreen:\t\t\(UIScreen.main.bounds)")
            print("UIScreenNative:\t\(UIScreen.main.nativeBounds)\n")
//            print("Camera: \(self.camera!)")

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
            bridge.zPosition = 15       //Set "altitude" of bridge (comment out to hide bridge!)
            bridge.maskNode = SKSpriteNode(color: .red, size: CGSize(width: bridgeWidth, height: bridgeWidth))
            bridge.zRotation = -CGFloat(135).degrees()        //Create cropping mask

            let bridgeCrop = SKSpriteNode(imageNamed: "Fig 8 Track")    //Set bridgeCrop equiv to f8Background
            bridgeCrop.xScale = -1
            bridgeCrop.size = f8Background.size
            bridgeCrop.position = CGPoint(x: 0, y: 0)
            bridgeCrop.name = "bridge"
            bridgeCrop.zRotation = CGFloat(45).degrees()   //Compensate for mask rotation
            
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
        
        var authorityLogo = SKSpriteNode(imageNamed: "logo-TfNSW")
        let authoScale = 0.09
        authorityLogo.setScale(authoScale)
//        authorityLogo.xScale = authoScale
    
//        authorityLogo.yScale = authoScale
        let logoXPos: CGFloat = 0.47 * (0.5 * self.size.width)
        let logoYPos: CGFloat = 0.36 * (0.5 * self.size.height)
        print("Width: \(self.size.width.dp2)\tHeight: \(self.size.height.dp2)\tName: \(String(describing: self.name))")
        authorityLogo.position = CGPoint(x: logoXPos, y: logoYPos)
        authorityLogo.zPosition = 500
        f8Background.addChild(authorityLogo)

        let ms500Timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(every500ms), userInfo: nil, repeats: true)
        
        
        
        //setVehicleSpeeds
        
//        let isLandscape = (view.bounds.size.width > view.bounds.size.height)  //NOTE: Doesn't recognise UIDevice rotation here!!!
//        let rotation = isLandscape ? CGFloat.pi/2 : 0
//        print("Rotation = \(rotation) : isLandscape = \(isLandscape)\nsContainer.frame.width = \(view.bounds.size.width)\nsContainer.frame.height = \(view.bounds.size.height)")
////        sContainer.zRotation = rotation //Normally done in StraightTrackView.swift. Required here 1st time only when starting in landscape.
//
    }       //end of 'didMove' to View
    
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
        //ideally occurs every 60Hz = 16.67ms
        
//        var whichWay: String
        
//        f8Background.alpha = ((whichScene == .figure8) ? 1.0 : 0)

        if updateOneTime == false {
        let orientation = UIDevice.current.orientation    //1: Portrait, 2: UpsideDown, 3: LandscapeLeft, 4: LandscapeRight
//        print("Orientation = \(orientation)")
        switch orientation {
        case .portrait:
            camera?.zRotation = 0
            print("Portrait - orientation = \(orientation)")
//            whichWay = ".portrait"
        case .portraitUpsideDown:
            camera?.zRotation = CGFloat.pi/3
            print("Portrait Upside Down - orientation = \(orientation)")
//            whichWay = ".portrait"
        case .landscapeLeft:
            camera?.zRotation = 2 * CGFloat.pi
            print("Landscape Left - orientation = \(orientation)")
//            whichWay = ".landscape"
        case .landscapeRight:
            camera?.zRotation = CGFloat.pi/2
            print("Landscape Right - orientation = \(orientation)")
//            whichWay = ".landscape"
        default:
            camera?.zRotation = 0
            print("Default - orientation = \(orientation)")
        }

            guard let windowScene = view?.window?.windowScene else { return }
            
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .all)) { error in
                print("requestGeometryUpdate Error!")
            }
//        let value = UIInterfaceOrientation.portrait.rawValue
//        UIDevice.current.setValue(value, forKey: "orientation")
            
            updateOneTime = true
        }
        
        //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
        //Run on Main Thread!
        if gameStage < 0x80 {           //Prevents code from running before vehicles are created.
                                        //MSB cleared when vehicles created ie. #7FH -> gameStage
            //Above changed from 0xFF to 0x80 7/1/24. Should make NO DIFFERENCE TO OPERATION!

////'noVehTest' flag (40H) set prior to 'Task' & set to 0 at end of Task.
//            if gameStage < 0x40 {
//                
//                let noVehTest: Int = 0x40   //Test Flag
////gameStage Bit 6 = noVehTest. Set during Task & clr'd when Task complete.
////                  Prevents code running again during Task.
//                
//                var testNo: Int
//                
////gameStage bit 40H set indicates below is in progress
////          bits 1 & 0 indicate stage: 10 -> 01 -> 00 -> 11
////            testNo = (gameStage & noOfCycles)   //Only interested in 2 LSBs gameStage. Set other bits = 0.
//                testNo = (gameStage & 0x03)   //Only interested in 2 LSBs gameStage. Set other bits = 0.
////Changed from 'noOfCycles' to 0x03 7/1/24
////Result = 00, 01, 10 or 11
//                if testNo != 0 {
//                    gameStage -= 1      //Decrement gameStage only when > 0
//                } else {
////                    gameStage = gameStage & 0xFC        //0 -> 2 LSBs. 2 LSBs ALREADY = 0!!!
//                    gameStage = gameStage | noOfCycles  //Set 2 LSBs = noOfCycles
////                    gameStage = gameStage | 0x03      //Set 2 LSBs (same effect as above IF noOfCycles = 03).
////Changed 7/1/24
//                }   //End else
            
            var nodeDataKL: NodeData = NodeData() //Temp storage of data - NOT SKSpriteNode!!!

            var bitTest: Int = 0x02      //~ = complement. Test for KL Track.
            var bitResult = gameStage & bitTest
            if bitResult == 0 {         //gameStage.1 = 0. Run Task for KL Track.
//                print("KLTrack\t\tStart\tgameStage: \(gameStage)\tbitResult: \(bitResult)")
                var temp1 = sKLAllVehicles      //Straight Track Vehicles.
                var t1xVehicle: [NodeData] = []

                
//                //Code measures time it takes measured code to run in seconds...
//                let clock = ContinuousClock()
//                let result = clock.measure {    //Insert code in {...}
//                }
//                print("\(result)") // "eg. 0.534663798 seconds"

//Avg time for the following loop is 168.5us in 12.9" iPad Pro on Simulator. 1st Pass has max of 709us.
                    for (index, veh1Node) in temp1.enumerated() {
                    if index != 0 {       //Skip loop for element[0] = All Vehicles
                        
                        nodeDataKL.name = veh1Node.name!      //OR = (index + 1)?
                        nodeDataKL.size = veh1Node.size
                        nodeDataKL.position = veh1Node.position
                        nodeDataKL.lane = veh1Node.lane
                        nodeDataKL.laps = veh1Node.laps
                        nodeDataKL.preferredSpeed = veh1Node.preferredSpeed
                        nodeDataKL.currentSpeed = abs(veh1Node.physicsBody!.velocity.dy * 3.6)      //  ????? x 3.6 for kph?
                        nodeDataKL.otherTrack = veh1Node.otherTrack
                        nodeDataKL.startPos = veh1Node.startPos
                        nodeDataKL.preDistance = veh1Node.preDistance
                        nodeDataKL.speedMax = veh1Node.speedMax
                        nodeDataKL.speedMin = veh1Node.speedMin
                        nodeDataKL.spdClk = veh1Node.spdClk
                        nodeDataKL.upToSpd = veh1Node.upToSpd
                        nodeDataKL.indicator = veh1Node.indicator
                        nodeDataKL.startIndicator = veh1Node.startIndicator
                        
                        nodeDataKL.mySetGap = veh1Node.mySetGap     //Always use value in KL!
                        nodeDataKL.decelMin = veh1Node.decelMin     //THESE 4 VALUES NEVER CHANGE!
                        nodeDataKL.decelMax = veh1Node.decelMax
                        nodeDataKL.myMinGap = veh1Node.myMinGap     //Gap in seconds

//                        nodeDataKL.laneProb = veh1Node.laneProb     //Always use value in KL! Never changes.
                        nodeDataKL.laneMode = -1                    //KL Track = -1. OtherTrack = 0-100

                    }   //end index zero check
                    t1xVehicle.append(nodeDataKL)
                }       //end For Loop
            
                var tKLVehicle = Array(t1xVehicle.dropFirst())       //Ignore 'All Vehicles'
                
//MARK: - KLTrack TASK
                Task {
                    gameStage = gameStage | 2               //1 -> gameStage.1. Remains set during Task!
                    //Prevents code running again during Task.
                    
                    if runStop == .run {
                        runTimer += (1/60)             //Add 16.7ms to runTimer. Used to calculate average speeds
                    }
            //        print("enableMinSpeed: \(enableMinSpeed)\t\trunTimer: \(runTimer)")
                    
                    //***************  1. findObstacles + updateSpeeds  ***************
                    //Keep Left Track (Track 1)  = gameStage bit 0 = 0
                    allAtSpeed1 = true
                    
                    await nodeDataKL.findObstacles(tVehicle: &tKLVehicle)
                    
//                    //***************  2. Restore Array  ***************
                    //NOW DONE @ END OF 'findObstacles'
//                    //NOT in Vehicle order! Arranged by Y Position!
//                    //Sort back into Vehicle No order. Note [0] is missing
//                    tKLVehicle.sort {
//                        $0.name.localizedStandardCompare($1.name) == .orderedAscending
//                    }                               //'localizedStandardCompare' ensures 21 sorted AFTER 3
//                    tKLVehicle.insert(t1xVehicle[0], at: 0)   //Copy All Vehicles into position [0].
//                    tKLVehicle[0].name = "All Vehicles"

                    //***************  2a. KL Overtake  ***************
                    //                        var re1turnV: [NodeData] = await nodeDataKL.goLeft(teeVeh: &tKLVehicle)
                    await nodeDataKL.goLeft(teeVeh: &tKLVehicle)
                    
                    await MainActor.run {
                        tKLVehicle = updateKLVehicles(rtVeh: tKLVehicle)
                    }
                    
                        //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                        if printSpd == 1 {
                            //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                            //  var WHICH = 1 (set in AppData so can be tweaked here - sets unit no.)
                            //Opt 1
                            print("Veh\tgapT\tPrSpd\tSpeed\tGSpd\tgap\t\tFNo\tFSpd\tPos\t\tFPos\toGap")
                            print(WHICH,"\t",PATH,"\t",tKLVehicle[WHICH].preferredSpeed.dp1,"\t",tKLVehicle[WHICH].currentSpeed.dp1,"\t",tKLVehicle[WHICH].goalSpeed.dp1,"\t",tKLVehicle[WHICH].gap.dp1,"\t",Int.extractNum(from: tKLVehicle[WHICH].frontUnit)!,"",tKLVehicle[WHICH].frontSpd.dp1,"\t",tKLVehicle[WHICH].position.y.dp1,"",tKLVehicle[WHICH].frontPos.y.dp1,"",tKLVehicle[WHICH].otherGap.dp1)
                            
                            //Opt 2
                            //                                print("Veh\tgapT\tPrSpd\tSpeed\tGSpd\tgap\t\tFNo\tFSpd\tCS\t\tFS\t\tGS")
                            //                                print(WHICH,"\t",PATH,"\t",tKLVehicle[WHICH].preferredSpeed.dp1,"\t",tKLVehicle[WHICH].currentSpeed.dp1,"\t",tKLVehicle[WHICH].goalSpeed.dp1,"\t",tKLVehicle[WHICH].gap.dp1,"\t",Int.extractNum(from: tKLVehicle[WHICH].frontUnit)!,"",tKLVehicle[WHICH].frontSpd.dp1,"\t",CS.dp1,"\t",FS.dp1,"\t",GS.dp1)
                        }
                        //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                        
                    //***************  3. findF8Pos + updateF8Spots  ***************
                    await nodeDataKL.findF8Pos(t1Veh: &tKLVehicle)
                        
                    await MainActor.run {
//                        let clock = ContinuousClock()     //Clock measures execution time Start to Stop
//                        let result = clock.measure {      //Start Timer
                            updateF8Vehicles(t1Vehicle: tKLVehicle, kLTrack: true)
//                        }                                 //Stop Timer
//                        print("KLResult: \(result)") // "0.534663798 seconds"
                    }
                        
                    //***************  4. updateLabel  ***************
                    //Once every 500-600ms sufficient for display calcs below
                    var rtnT1Veh = await nodeDataKL.calcAvgData(t1xVeh: &tKLVehicle)
                    //                        //Sort back into Vehicle No order. Note [0] is missing
                    //                        rtnT1Veh.sort {
                    //                            $0.name.localizedStandardCompare($1.name) == .orderedAscending
                    //                        }                               //'lacalizedStandardCompare' ensures 21 sorted AFTER 3
                    //                        rtnT1Veh.insert(rtnT1Veh[2], at: 0)   //Copy dummy into position [0] (All Vehicles).
                    //                        rtnT1Veh[0].name = "All Vehicles"
                    
                    for i in 1..<rtnT1Veh.count {
                        if i == 0 {continue}       //Skip loop for element[0] = All Vehicles
                        sKLAllVehicles[i].preDistance = rtnT1Veh[i].preDistance
                        sKLAllVehicles[i].speedMax = rtnT1Veh[i].speedMax
                        sKLAllVehicles[i].speedMin = rtnT1Veh[i].speedMin
                        sKLAllVehicles[i].startPos = rtnT1Veh[i].startPos
                        sKLAllVehicles[i].laps = rtnT1Veh[i].laps            //in case clr'd @ 10secs
                        sKLAllVehicles[i].spdClk = rtnT1Veh[i].spdClk
                        sKLAllVehicles[i].upToSpd = rtnT1Veh[i].upToSpd
                        
                        if rtnT1Veh[i].upToSpd == false { allAtSpeed1 = false } //Flag cleared if ANY vehicle NOT up to speed
                        
                        //If vehicle crosses 1km boundary then subtract tracklength from the y position.
                        if sKLAllVehicles[i].position.y >= sTrackLength {
                            //IMPORTANT!!! ??? Prevent change to pos.y in other thread during the following instruction !!!
                            sKLAllVehicles[i].position.y = (sKLAllVehicles[i].position.y - sTrackLength)
                            sKLAllVehicles[i].laps += 1
                        }
                        
                        //Code below starts lane change & indicators where required for the Keep Left track
                        //                            await MainActor.run {
                        //                                let cLResult1 = nodeDataKL.changeLanes(retnVeh: rtnT1Veh, i: i, kLTrack: true)
                        //                                rtnT1Veh = cLResult1
                        //                            }
                        

                    }               //End 'for' loop
                    //All vehicles on Track 1 (Keep Left Track) checked
                    
                    //MARK: - Calculate distances & speeds for KL 'All Vehicles'
                    //Note: Avg Speed = speed to drive Avg Distance.
                    //      Max Speed = Avg Speed of vehicle that has driven furthest
                    //      Min Speed = Avg Speed of vehicle that has driven the least distance
                    rtnT1Veh[0].distance = klDistance0
                    rtnT1Veh[0].distanceMax = klDistanceMax0
                    rtnT1Veh[0].distanceMin = klDistanceMin0
                    //                            sKLAllVehicles[0].speedAvg = (sKLAllVehicles[0].speedAvg + klSpeedAvg0) / 2
                    sKLAllVehicles[0].speedAvg = klSpeedAvg0
                    rtnT1Veh[0].speedAvg = sKLAllVehicles[0].speedAvg
                    sKLAllVehicles[0].speedMax = max(sKLAllVehicles[0].speedMax, klSpeedMax0)
                    rtnT1Veh[0].speedMax = sKLAllVehicles[0].speedMax
                    if (sKLAllVehicles[0].speedMin < 500) || enableMinSpeed == true {         //Wait for ALL vehicles up to speed
                        sKLAllVehicles[0].speedMin = min(sKLAllVehicles[0].speedMin, klSpeedMin0)
                        rtnT1Veh[0].speedMin = sKLAllVehicles[0].speedMin
                    } else {
                        rtnT1Veh[0].speedMin = klSpeedMin0
                    }
                    
                    //                    await MainActor.run {
                    topLabel.updateLabel(topLabel: true, vehicel: rtnT1Veh[f8DisplayDat])  //rtnT1Veh has no element 0!
                    //                    }
                    
                    //The following now done BEFORE Task ends as anything after can run immediately!!!
                    gameStage = gameStage & ~2      //0 -> gameStage.1. Remains set during Task!
                    //Prevents code running again during Task.
                    
                }       //End KL Task
            }                           //gameStage.1 = 1 (if above not run). End KL Track Task
//            print("KLTrack\tStop\tgameStage: \(gameStage)\tbitResult: \(bitResult)")

            //Now check OtherTrack
            bitTest = 0x01              //Bit 0 = 1 during Other Track Task!
            bitResult = gameStage & bitTest
//            bitResult = 1     //Prevents OtherTrack from running
            if bitResult == 0 {         //gameStage.0 = 0. Run Task for Other Track.
//                print("OtherTrack\tStart\tgameStage: \(gameStage)\tbitResult: \(bitResult)")
                var temp2 = sOtherAllVehicles           //Straight Track Vehicles: Ignore 'All Vehicles'
                var nodeDataO: NodeData = NodeData()
                var t2xVehicle: [NodeData] = []
                
                for (index, veh2Node) in temp2.enumerated() {
                    if index != 0 {       //Skip loop for element[0] = All Vehicles
                        
                        nodeDataO.name = veh2Node.name!      //OR = (index + 1)?
                        nodeDataO.size = veh2Node.size
                        nodeDataO.position.x = (1 - veh2Node.position.x)
                        nodeDataO.position.y = (sTrackLength - veh2Node.position.y)
                        nodeDataO.lane = veh2Node.lane
                        nodeDataO.laps = veh2Node.laps
                        nodeDataO.preferredSpeed = veh2Node.preferredSpeed
                        nodeDataO.currentSpeed = abs(veh2Node.physicsBody!.velocity.dy * 3.6)      //  ????? x 3.6 for kph?
                        nodeDataO.otherTrack = veh2Node.otherTrack
                        nodeDataO.startPos = veh2Node.startPos
                        nodeDataO.preDistance = veh2Node.preDistance
                        nodeDataO.speedMax = veh2Node.speedMax
                        nodeDataO.speedMin = veh2Node.speedMin
                        nodeDataO.spdClk = veh2Node.spdClk
                        nodeDataO.upToSpd = veh2Node.upToSpd
                        nodeDataO.indicator = veh2Node.indicator
                        nodeDataO.startIndicator = veh2Node.startIndicator
                        
                        nodeDataO.mySetGap = sKLAllVehicles[index].mySetGap     //Always use value in KL!
                        nodeDataO.decelMin = sKLAllVehicles[index].decelMin     //THESE 4 VALUES NEVER CHANGE!
                        nodeDataO.decelMax = sKLAllVehicles[index].decelMax
                        nodeDataO.myMinGap = sKLAllVehicles[index].myMinGap

//                        nodeDataO.laneProb = sKLAllVehicles[index].laneProb     //Always use KL value! Never changes.
                        nodeDataO.laneMode = sOtherAllVehicles[index].laneMode     //Always use value in KL!


//                nodeDataO.equivF8Name = not needed here!
                    }       //end index zero check
                    t2xVehicle.append(nodeDataO)
                }           //end For loop
            
            var tOtVehicle = Array(t2xVehicle.dropFirst())       //Ignore 'All Vehicles'

//MARK: - OtherTrack TASK
                Task(priority: .high) {            //Bit 0 = 1 then update Other Track
                    gameStage = gameStage | 1               //1 -> gameStage.0. Remains set during Task!
                    //Prevents code running again during Task.
                    
                    //***************  1. findObstacles + updateSpeeds  ***************
                    //Other Track (Track 2)  = gameStage bit 0 = 1
                    allAtSpeed2 = true
                    
                    await nodeDataO.findObstacles(tVehicle: &tOtVehicle)
                    
//                    //***************  2. Restore Array  ***************
//                    //NOT in Vehicle order! Arranged by Y Position!
//                    //Sort back into Vehicle No order. Note [0] is missing
//                    tOtVehicle.sort {
//                        $0.name.localizedStandardCompare($1.name) == .orderedAscending
//                    }                               //'localizedStandardCompare' ensures 21 sorted AFTER 3
//                    tOtVehicle.insert(t2xVehicle[0], at: 0)   //Copy All Vehicles into position [0].
//                    tOtVehicle[0].name = "All Vehicles"
//                    
                    //*************** 2a. Other Overtake ***************
                    //NOTE: Other Track doesn't Keep Left!
                    await nodeDataO.goLeft(teeVeh: &tOtVehicle)
//                            var tOtVehicle: [NodeData] = tOtVehicle
                    //Toggle above 2 instructions to run or disable goLeft function! (currently only KL Track)
                    
                    await MainActor.run {
                        tOtVehicle = updateOtherVehicles(rtVeh: tOtVehicle)
                    }
                    
                    //***************  3. findF8Pos + updateF8Spots  ***************
                    await nodeDataO.findF8Pos(t1Veh: &tOtVehicle)
                    
                    await MainActor.run {
//                        let clock = ContinuousClock()     //Clock measures execution time Start to Stop
//                        let result = clock.measure {      //Start Timer
                        updateF8Vehicles(t1Vehicle: tOtVehicle, kLTrack: false)
//                        }                                 //Stop Timer
//                        print("OtResult: \(result)") // "0.534663798 seconds"
                    }
                    
                    //***************  4. updateLabel  ***************
                    //Once every 500-600ms sufficient for display calcs below
                    //                            var rtnT2Veh = await nodeDataO.calcAvgData(t1Veh: &tOtVehicle)
                    var rtnT2Veh = await nodeDataO.calcAvgData(t1xVeh: &tOtVehicle)
                    
                    for i in 1..<rtnT2Veh.count {
                        sOtherAllVehicles[i].preDistance = rtnT2Veh[i].preDistance
                        sOtherAllVehicles[i].speedMax = rtnT2Veh[i].speedMax
                        sOtherAllVehicles[i].speedMin = rtnT2Veh[i].speedMin
                        sOtherAllVehicles[i].startPos = rtnT2Veh[i].startPos
                        sOtherAllVehicles[i].laps = rtnT2Veh[i].laps            //in case clr'd @ 10secs
                        sOtherAllVehicles[i].spdClk = rtnT2Veh[i].spdClk
                        sOtherAllVehicles[i].upToSpd = rtnT2Veh[i].upToSpd
                        if rtnT2Veh[i].upToSpd == false { allAtSpeed2 = false } //Flag cleared if ANY vehicle NOT up to speed
                        
                        //If vehicle crosses 1km boundary then add tracklength to the y position.
                        if sOtherAllVehicles[i].position.y < 0 {
                            //IMPORTANT!!! ??? Prevent change to pos.y in other thread during the following instruction !!!
                            sOtherAllVehicles[i].position.y = (sOtherAllVehicles[i].position.y + sTrackLength)
                            sOtherAllVehicles[i].laps += 1
                        }
                        
//                        //Code below starts lane change & indicators where required for the Keep Left track
//                        let cLResult2 = nodeDataO.changeLanes(retnVeh: rtnT2Veh, i: i, kLTrack: false)
//                        rtnT2Veh = cLResult2
                        
                    }
                    //All vehicles on Track 2 (Other Track) checked
                    
                //                            print("b4:\tMin: \(sOtherAllVehicles[0].speedMin.dp2)\tAvg: \((sOtherAllVehicles[0].speedAvg.dp2))\tMax: \(sOtherAllVehicles[0].speedMax.dp2)\tenableMinSpeed: \(enableMinSpeed)")
                                        //MARK: - Calculate distances & speeds for Other 'All Vehicles'
                                        //Note: Avg Speed = speed to drive Avg Distance.
                                        //      Max Speed = Avg Speed of vehicle that has driven furthest
                                        //      Min Speed = Avg Speed of vehicle that has driven the least distance
                                        rtnT2Veh[0].distance = oDistance0
                                        rtnT2Veh[0].distanceMax = oDistanceMax0
                                        rtnT2Veh[0].distanceMin = oDistanceMin0
                //                            sOtherAllVehicles[0].speedAvg = (sOtherAllVehicles[0].speedAvg + klSpeedAvg0) / 2
                                        sOtherAllVehicles[0].speedAvg = oSpeedAvg0
                                        rtnT2Veh[0].speedAvg = sOtherAllVehicles[0].speedAvg
                                        sOtherAllVehicles[0].speedMax = max(sOtherAllVehicles[0].speedMax, oSpeedMax0)
                                        rtnT2Veh[0].speedMax = sOtherAllVehicles[0].speedMax
                                        if (sOtherAllVehicles[0].speedMin < 500) || enableMinSpeed == true {         //Wait for ALL vehicles up to speed
                                            sOtherAllVehicles[0].speedMin = min(sOtherAllVehicles[0].speedMin, oSpeedMin0)
                                            rtnT2Veh[0].speedMin = sOtherAllVehicles[0].speedMin
                                        } else {
                                            rtnT2Veh[0].speedMin = oSpeedMin0
                                        }
                                        
                //                            print("af:\tMin: \(sOtherAllVehicles[0].speedMin.dp2)\tAvg: \((sOtherAllVehicles[0].speedAvg.dp2))\tMax: \(sOtherAllVehicles[0].speedMax.dp2)\tenableMinSpeed: \(enableMinSpeed)")
                                        
                                        bottomLabel.updateLabel(topLabel: false, vehicel: rtnT2Veh[f8DisplayDat])  //TEMP! Same data as Top Label!!!
                                        
                    //The following now done BEFORE Task ends as anything after can run immediately!!!
                    gameStage = gameStage & ~1      //0 -> gameStage.0. Remains set during Task!
                                                    //Prevents code running again during Task.
                                    }   //End OtherTrack Task!
                                    
            }                           //gameStage.0 = 1 (if above not run). End Other Track Task
//            print("OtherTrack\tStop\tgameStage: \(gameStage)\tbitResult: \(bitResult)")

                //                        print("\nallAtSpd: \(allAtSpeed)\tignoreSpd: \(ignoreSpd)")
                                    //ignoreSpd set when vehicles stopped. Reset when started plus 8 secs (runTimerDelay)
                                    //allAtSpeed1 set when ALL KL Track vehicles up to speed. allAtSpeed2 set when ALL Other Track vehicles up to speed.
                                    if allAtSpeed1 == true && allAtSpeed2 == true && ignoreSpd == false {
                                        enableMinSpeed = true       //NOTE: Now each vehicle calculates its min Spd once it's reached speed itself.
                //                            print("!!! Run Timer Enabled !!!\n")
                                    }       //End enableMinSpd check

        }           //End gameStage < 0x80

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

    }   //End of override update
    
    //        //The following code can replace the above - it's easier to follow but I suspect
    //        //creating the extra array would have a time penalty
    //        let dualArray = Array(zip(tKLVehicle, tOtVehicle))
    //        for (sKLNode, sOtherNode) in dualArray  {
    //            if sKLNode.position.y >= (sTrackLength * sMetre1) {
    //                sKLNode.position.y = (sKLNode.position.y - (sTrackLength * sMetre1))
    //            }
    //            if sOtherNode.position.y < 0 {
    //                sOtherNode.position.y = (sOtherNode.position.y + (sTrackLength * sMetre1))
    //            }
    //        }
    //
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}   //Exit if not first touch!
        
    // \\\\\\\\\\\\\\\\\\\\\\\\\\ Code below flashes selected vehicle //////////////////////////
    // FOR TESTING ONLY! Due to layering, may not see vehicle!!!
        let touchLocation = touch.location(in: self)
        var targetNode: SKSpriteNode
        targetNode = SKSpriteNode(color: SKColor(red: 0, green: 0, blue: 0, alpha: 0), size: CGSize(width: 1, height: 1))
        var ggg: String
        var targName = "No Name!"
        if let targetNode = atPoint(touchLocation) as? SKSpriteNode {
            ggg = targetNode.name ?? "dummy666"
        } else {
            ggg = "dummy666"
        }
        targName = ggg
        ggg = String(ggg.suffix(3))
        var targetNodeNum: Int = Int.extractNum(from: ggg) ?? 666 //If not a vehicle set to 666

        if targetNodeNum < 200 && ggg != "dummy666" {    //if vehicle touched flash & display vehicle data. See code on swipe too!
            print("Just selected vehicle \(targName ?? "Nothing")")
            f8DisplayDat = targetNodeNum
            let delay5 = SKAction.wait(forDuration: oneVehicleDisplayTime)
            let backToAll = SKAction.run { f8DisplayDat = 0 }
            let backToAllSequence = SKAction.sequence([delay5, backToAll])
            run(backToAllSequence, withKey: "backToAll")
        }
    // ////////////////////////// Code above flashes selected vehicle \\\\\\\\\\\\\\\\\\\\\\\\\\

        
        
        var kph: CGFloat = 130
        let multiplier: CGFloat = 1000 / 3600  //Value by kph gives m/sec
        
//        toggleSpeed += 1
//
//
//        
////            toggleSpeed = -1
////        print("Vehicle 1 Node = \(childNode(withName: "sKLVehicle_1")!)")
//
//        if toggleSpeed == 4 {
////            toggleSpeed = -1
//            toggleSpeed = 0 // WAS toggleSpeed = 0 when Fig8Scene accessed from here!!!
//            ////            var scene = Fig8Scene(fileNamed: "Fig8Scene")!
//            //            var scene = Fig8Scene()
//            ////            var transition: SKTransition = SKTransition.moveIn(with: .right, duration: 2)
//            //            var transition: SKTransition = SKTransition.fade(withDuration: 2)
//            //            self.view?.presentScene(scene, transition: transition)
//////            print("toggleSpeed = \(toggleSpeed)")
//        } else if toggleSpeed == 6 {
//            toggleSpeed = 0
////            var transition: SKTransition = SKTransition.fade(withDuration: 2)
////            var scene = StraightTrackScene()
////            self.view?.presentScene(scene)
//        }
////        toggleSpeed = toggleSpeed + 1
        
    }       //end of touchesBegan
    
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
        let lineSpacing: CGFloat = sTrackLength/83  //where 1000 = track length & 83 = no lines per km. Cld use sTrackLength here???
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
        //________________ Make Indicator 1st ___________________________
//        indic.fillColor = SKColor(red: 255/255, green: 95/255, blue: 31/255, alpha: 1)  //Orange
//        indic.position = CGPoint(x: 0, y: 510)
        indic.strokeColor = SKColor(red: 255/255, green: 95/255, blue: 31/255, alpha: 1)  //Orange
//        sBackground.addChild(indic)
        
        //________________ Indicator Complete ___________________________

        var fName: String = ""
        let maxVehicles: Int = (maxCars+maxTrucks+maxBuses)
//        var sKLVehicle: SKSpriteNode = SKSpriteNode(imageNamed: "\(vehImage)C1")
        
        var sKLAll: Vehicle = Vehicle(imageName: vehImage + "C1")       //Dummy node for 'All Vehicles' KL
//        sKLAll.name = "sKLVehicle_0"
        sKLAll.name = "stKL_0"
        sKLAll.distance = 0.0
        sKLAllVehicles.append(sKLAll)       //Place sKAll into position 0 of array
        var f8KLAll: F8Vehicle = F8Vehicle(imageName: vehImage + "C1")       //Dummy node for 'All Vehicles' KL
//        f8KLAll.name = "f8KLVehicle_0"
        f8KLAll.name = "f8KL_0"
        f8KLAll.distance = 0.0
        f8KLAllVehicles.append(f8KLAll)

        var sOtherAll: Vehicle = Vehicle(imageName: vehImage + "C1")    //Dummy node for 'All Vehicles' Other
        sOtherAll.name = "stOt_0"
        sOtherAll.distance = 0.0
        sOtherAllVehicles.append(sOtherAll) //Place sOtherAll into position 0 of array
        var f8OtherAll: F8Vehicle = F8Vehicle(imageName: vehImage + "C1")    //Dummy node for 'All Vehicles' Other
        f8OtherAll.name = "f8Ot_0"
        f8OtherAll.distance = 0.0
        f8OtherAllVehicles.append(f8OtherAll)
        
        var sL = Vehicle.VType.car              //Temp 'Speed Limited' variable
        var tempDist: CGFloat = 0
        var timeDistribution: CGFloat

        for i in 1...numVehicles {
            var randomVehicle = Int.random(in: 1...maxVehicles)
//            var vWidth: CGFloat = 2.3   //Car width. Set truck & bus width = 2.5m (allow 300mm for side mirrors?)
            var vWidth: CGFloat = 2.8   //Car width. Set truck & bus width = 2.5m (allow 300mm for side mirrors?) SET ALL = 2.5M FOR NOW!!!
//Below were for testing randomValue ONLY!
// print(randomValue(distribution: 1, min: -1, max: +1).dp2)      //Test code: I/P = 0-1
// testRun(distribution: 0, min: 500, max: 2000)      //Test code: I/P = 0-1

            if NumberedVehicles == false {  //false = normal else display numbers instead of vehicles!
                switch randomVehicle {
                case 1...maxCars:                       //Vehicle = Car. Width defined above! (2.8m for now!)
                fName = "C\(randomVehicle)"
                    sL = Vehicle.VType.car              //Cars AREN'T speed limited
                    tempDist = 1.0                      //Favour higher spdPref for cars
                case (maxCars+1)...(maxCars+maxTrucks): //Vehicle = Truck
                fName = "T\(randomVehicle-maxCars)"
                    sL = Vehicle.VType.truck            //Trucks ARE speed limited
                    tempDist = 0.45                     //Average slightly lower spdPref for trucks
                    vWidth = 2.8                        //Set Trucks = 2.8m wide
                default:                                //Vehicle = Bus
                fName = "B\(randomVehicle-maxCars-maxTrucks)"
                    sL = Vehicle.VType.bus              //Buses ARE speed limited
                    tempDist = 0.0                      //Average much lower spdPref for buses
                    vWidth = 2.8                        //Set buses = 2.8m wide
                }
                
            } else {    //NumberedVehicles = true therefore display no's for vehicles!
                switch randomVehicle {
                case 1...maxCars:                       //Vehicle = Car
                    //                fName = "C\(randomVehicle)"
                    fName = "No\(i)"
                case (maxCars+1)...(maxCars+maxTrucks): //Vehicle = Truck
                    //                fName = "T\(randomVehicle-maxCars)"
                    fName = "No\(i)"
                    vWidth = 2.8
                default:                                //Vehicle = Bus
                    //                fName = "B\(randomVehicle-maxCars-maxTrucks)"
                    fName = "No\(i)"
                    vWidth = 2.8
                }
            }       //end NumberedVehicles
            
            var sKLVehicle: Vehicle = Vehicle(imageName: vehImage + String(fName))
            
            setAspectForWidth(sprite: sKLVehicle, width: vWidth)  //Sets veh width = 2m (default) & maintains aspect ratio
             let vehSize = sKLVehicle.size
            
            sKLVehicle.zPosition = +50
            sKLVehicle.name = "stKL_\(i)"   //stKL_x -> Straight Track 1, f8KL_x -> Figure 8 Track 1, gKL_x -> Game Track 1.
            sKLVehicle.vehType = sL         //Error if .vehType not Published! vehType = car, truck or bus
                                            //Note: OtherTrack references KL Track!
//            sKLVehicle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: sKLVehicle.size.width, height: (sKLVehicle.size.height + minGap)))   //Make rectangle same size as sprite + 0.75m front and back!
            sKLVehicle.physicsBody = SKPhysicsBody(rectangleOf: sKLVehicle.size)   //Make rectangle same size as sprite + 0.75m front and back!
            sKLVehicle.physicsBody?.friction = 0
            sKLVehicle.physicsBody?.restitution = 0
            sKLVehicle.physicsBody?.linearDamping = 0
            sKLVehicle.physicsBody?.angularDamping = 0
            sKLVehicle.physicsBody?.allowsRotation = false
            sKLVehicle.physicsBody?.isDynamic = true
            sKLVehicle.physicsBody?.categoryBitMask = vehicleCategory
            sKLVehicle.physicsBody?.contactTestBitMask = vehicleCategory
            sKLVehicle.physicsBody?.collisionBitMask = 0

            sBackground.addChild(sKLVehicle)
            
            let fInd = indic.copy() as! SKShapeNode
            let rInd = indic.copy() as! SKShapeNode
            fInd.position.y = rInd.position.y + sKLVehicle.size.height - (indicatorRadius * 3)
            let leftSKLIndicators = SKShapeNode()
            leftSKLIndicators.addChild(fInd)
            leftSKLIndicators.addChild(rInd)
            leftSKLIndicators.name = "leftInd\(i)"
            leftSKLIndicators.position.x = sKLVehicle.position.x - (sKLVehicle.size.width / 2) + (indicatorRadius * 2)
            leftSKLIndicators.position.y = sKLVehicle.position.y - (sKLVehicle.size.height / 2) + (indicatorRadius * 1.5)
            leftSKLIndicators.isHidden = true
            sKLVehicle.addChild(leftSKLIndicators)
            let rightSKLIndicators = leftSKLIndicators.copy() as! SKShapeNode
            rightSKLIndicators.name = "rightInd\(i)"
            rightSKLIndicators.position.x = sKLVehicle.position.x + (sKLVehicle.size.width / 2) - (indicatorRadius * 2)
//            rightSKLIndicators.isHidden = true
            rightSKLIndicators.isHidden = true
            sKLVehicle.addChild(rightSKLIndicators)

////            let cnrInd = indic.copy() as! SKShapeNode
////            cnrInd.position = CGPoint(x: sKLVehicle.position.x - 1, y: sKLVehicle.position.y + 3)
////            cnrInd.name = "cnrInd\(i)"
//            let leftInd = twoIndicators.copy() as! SKNode
//            leftInd.yScale = sKLVehicle.size.height / 6
//            leftInd.position = CGPoint(x: sKLVehicle.position.x - (sKLVehicle.size.width / 2), y: sKLVehicle.position.y - (sKLVehicle.size.height / 2))
//            leftInd.name = "leftInd\(i)"
//            sKLVehicle.addChild(leftInd)
            
//            let cnrIndicator = SKLightNode()
//            cnrIndicator.lightColor = UIColor(red: 251/255, green: 98/255, blue: 51/255, alpha: 1)
//            cnrIndicator.falloff = 0.3
//            cnrIndicator.zPosition = 1000
//            cnrIndicator.position = CGPoint(x: 0, y: 0)
//            sKLVehicle.addChild(cnrIndicator)
            
            //_________________________ Fig 8 Track below __________________________________________________
            var f8KLVehicle: F8Vehicle = F8Vehicle(imageName: vehImage + String(fName))

            f8KLVehicle.size = vehSize

            f8KLVehicle.zPosition = 10      //Set starting "altitude" above track and below bridge
            f8KLVehicle.name = "f8KL_\(i)"  //stKL_x -> Straight Track 1, f8KL_x -> Figure 8 Track 1, gKL_x -> Game Track 1.
//            f8KLVehicle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: f8KLVehicle.size.width, height: (f8KLVehicle.size.height + minGap)))   //Make rectangle same size as sprite + 0.5m front and back!
            f8KLVehicle.physicsBody = SKPhysicsBody(rectangleOf: f8KLVehicle.size)   //Make rectangle same size as sprite + 0.5m front and back!
            f8KLVehicle.physicsBody?.friction = 0
            f8KLVehicle.physicsBody?.restitution = 0
            f8KLVehicle.physicsBody?.linearDamping = 0
            f8KLVehicle.physicsBody?.angularDamping = 0
            f8KLVehicle.physicsBody?.allowsRotation = false
            f8KLVehicle.physicsBody?.isDynamic = false
            f8KLVehicle.physicsBody?.categoryBitMask = vehicleCategory
            f8KLVehicle.physicsBody?.contactTestBitMask = vehicleCategory
            f8KLVehicle.physicsBody?.collisionBitMask = 0

            f8Background.addChild(f8KLVehicle)
            
            let f8FInd = indic.copy() as! SKShapeNode
            let f8RInd = indic.copy() as! SKShapeNode
            f8FInd.position.y = f8RInd.position.y + f8KLVehicle.size.height - (indicatorRadius * 3)
            let leftF8KLIndicators = SKShapeNode()
            leftF8KLIndicators.addChild(f8FInd)
            leftF8KLIndicators.addChild(f8RInd)
            leftF8KLIndicators.name = "leftInd\(i)"
            leftF8KLIndicators.position.x = f8KLVehicle.position.x - (f8KLVehicle.size.width / 2) + (indicatorRadius * 2)
            leftF8KLIndicators.position.y = f8KLVehicle.position.y - (f8KLVehicle.size.height / 2) + (indicatorRadius * 1.5)
            leftF8KLIndicators.isHidden = true
            f8KLVehicle.addChild(leftF8KLIndicators)
            let rightF8KLIndicators = leftF8KLIndicators.copy() as! SKShapeNode
            rightF8KLIndicators.name = "rightInd\(i)"
            rightF8KLIndicators.position.x = f8KLVehicle.position.x + (f8KLVehicle.size.width / 2) - (indicatorRadius * 2)
//            rightF8KLIndicators.isHidden = true
            rightF8KLIndicators.isHidden = true
            f8KLVehicle.addChild(rightF8KLIndicators)

            //_________________________ Fig 8 Track above __________________________________________________

            var sOtherVehicle: Vehicle = Vehicle(imageName: vehImage + String(fName))
            setAspectForWidth(sprite: sOtherVehicle, width: vWidth)  //Sets veh width = 2m (default) & maintains aspect ratio
            let secSize = sOtherVehicle.size
            
            sOtherVehicle.otherTrack = true //Flag identifies vehicle as being on the otherTrack!
            sOtherVehicle.zPosition = +50
            sOtherVehicle.name = "stOt_\(i)"  //stOt_x -> Straight Track 2, f8Ot_x -> Figure 8 Track 2, gOt_x -> Game Track 2 (if any!).
//            sOtherVehicle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: secSize.width, height: secSize.height + minGap))   //Make rectangle same size as sprite + 0.5m front and back!
            sOtherVehicle.physicsBody = SKPhysicsBody(rectangleOf: secSize)   //Make rectangle same size as sprite + 0.5m front and back!
            sOtherVehicle.physicsBody?.friction = 0
            sOtherVehicle.zRotation = CGFloat(180).degrees()  //rotate 180 degrees //XXXXXXXXXX
//            sOtherVehicle.zRotation = CGFloat(Double.pi)  //rotate 180 degrees //XXXXXXXXXX
            sOtherVehicle.physicsBody?.restitution = 0
            sOtherVehicle.physicsBody?.linearDamping = 0
            sOtherVehicle.physicsBody?.angularDamping = 0
            sOtherVehicle.physicsBody?.allowsRotation = false
            sOtherVehicle.physicsBody?.isDynamic = true
            sOtherVehicle.physicsBody?.categoryBitMask = vehicleCategory
            sOtherVehicle.physicsBody?.contactTestBitMask = vehicleCategory
            sOtherVehicle.physicsBody?.collisionBitMask = 0

            sBackground.addChild(sOtherVehicle)

            let sFOInd = indic.copy() as! SKShapeNode
            let sROInd = indic.copy() as! SKShapeNode
            sFOInd.position.y = sROInd.position.y + sOtherVehicle.size.height - (indicatorRadius * 3)
            let leftSOthIndicators = SKShapeNode()
            leftSOthIndicators.addChild(sFOInd)
            leftSOthIndicators.addChild(sROInd)
            leftSOthIndicators.name = "leftInd\(i)"
            leftSOthIndicators.position.x = sOtherVehicle.position.x - (sOtherVehicle.size.width / 2) + (indicatorRadius * 2)
            leftSOthIndicators.position.y = sOtherVehicle.position.y - (sOtherVehicle.size.height / 2) + (indicatorRadius * 1.5)
            leftSOthIndicators.isHidden = true
            sOtherVehicle.addChild(leftSOthIndicators)
            let rightSOthIndicators = leftSOthIndicators.copy() as! SKShapeNode
            rightSOthIndicators.name = "rightInd\(i)"
            rightSOthIndicators.position.x = sOtherVehicle.position.x + (sOtherVehicle.size.width / 2) - (indicatorRadius * 2)
//            rightSOthIndicators.isHidden = true
            rightSOthIndicators.isHidden = true
            sOtherVehicle.addChild(rightSOthIndicators)

            //_________________________ Fig 8 Track below __________________________________________________
            var f8OtherVehicle: F8Vehicle = F8Vehicle(imageName: vehImage + String(fName))

            f8OtherVehicle.size = secSize

            f8OtherVehicle.otherTrack = true     //Flag identifies vehicle as being on the otherTrack!
            f8OtherVehicle.zPosition = 10       //Set starting "altitude" above track and below bridge
            f8OtherVehicle.name = "f8Ot_\(i)"  //stOt_x -> Straight Track 2, f8Ot_x -> Figure 8 Track 2, gOt_x -> Game Track 2 (if any!).
//            f8OtherVehicle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: f8OtherVehicle.size.width, height: f8OtherVehicle.size.height + minGap))   //Make rectangle same size as sprite + 0.5m front and back!
            f8OtherVehicle.physicsBody = SKPhysicsBody(rectangleOf: f8OtherVehicle.size)   //Make rectangle same size as sprite + 0.5m front and back!
            f8OtherVehicle.physicsBody?.friction = 0
            f8OtherVehicle.physicsBody?.restitution = 0
            f8OtherVehicle.physicsBody?.linearDamping = 0
            f8OtherVehicle.physicsBody?.angularDamping = 0
            f8OtherVehicle.physicsBody?.allowsRotation = false
            f8OtherVehicle.physicsBody?.isDynamic = false
            f8OtherVehicle.physicsBody?.categoryBitMask = vehicleCategory
            f8OtherVehicle.physicsBody?.contactTestBitMask = vehicleCategory
            f8OtherVehicle.physicsBody?.collisionBitMask = 0

            f8Background.addChild(f8OtherVehicle)

            let f8FOInd = indic.copy() as! SKShapeNode
            let f8ROInd = indic.copy() as! SKShapeNode
            f8FOInd.position.y = f8ROInd.position.y + f8OtherVehicle.size.height - (indicatorRadius * 3)
            let leftF8OthIndicators = SKShapeNode()
            leftF8OthIndicators.addChild(f8FOInd)
            leftF8OthIndicators.addChild(f8ROInd)
            leftF8OthIndicators.name = "leftInd\(i)"
            leftF8OthIndicators.position.x = f8OtherVehicle.position.x - (f8OtherVehicle.size.width / 2) + (indicatorRadius * 2)
            leftF8OthIndicators.position.y = f8OtherVehicle.position.y - (f8OtherVehicle.size.height / 2) + (indicatorRadius * 1.5)
            leftF8OthIndicators.isHidden = true
            f8OtherVehicle.addChild(leftF8OthIndicators)
            let rightF8OthIndicators = leftF8OthIndicators.copy() as! SKShapeNode
            rightF8OthIndicators.name = "rightInd\(i)"
            rightF8OthIndicators.position.x = f8OtherVehicle.position.x + (f8OtherVehicle.size.width / 2) - (indicatorRadius * 2)
//            rightF8OthIndicators.isHidden = true
            rightF8OthIndicators.isHidden = true
            f8OtherVehicle.addChild(rightF8OthIndicators)

            //_________________________ Fig 8 Track above __________________________________________________

            f8KLAllVehicles.append(f8KLVehicle)
            f8OtherAllVehicles.append(f8OtherVehicle)
            
            //_________________________________________________________________
            //Following sets up parameters to alter vehicle preferred speed etc
            //_________________________________________________________________ start speed
            //Higher spdPref prefers > speed probability within range for next speed calculation
            // tempDist = 1.0 for Cars, 0.45 for Trucks & 0 for Buses
            sKLVehicle.spdPref = randomValue(distribution: tempDist, min: -1, max: +1)
            
//Preferred Spd will be set to 30% - topRange% of spdLimit for this type of vehicle.
            //Skewed to faster end: tempDist = 1.0 for Cars, 0.45 for Trucks & 0 for Buses
            sKLVehicle.lowRange = randomValue(distribution: tempDist, min: 0.3, max: 0.95)

//Preferred Spd will be set to 40% - 105% of spdLimit for this type of vehicle.
            //Skewed to faster end
            sKLVehicle.topRange = randomValue(distribution: tempDist, min: (0.05 + sKLVehicle.lowRange), max: 1.05)
            //Later spd calc =
            //randomValue(d: sKLVehicle.spdPref, min: (sKLAllVehicles[x].lowRange * spdLimit), max: (sKLAllVehicles[x].topRange * spdLimit)) & hold for next .varTime seconds (1-180)
            
//            timeDistribution = randomValue(distribution: sKLVehicle.spdPref, min: -1, max: +1)
            //Leave above for now & JUST use below (May tweak later!)
            //varTime sets distribution for randomly changing time between speed variances. Skewed high
            sKLVehicle.varTime = randomValue(distribution: sKLVehicle.spdPref, min: -1, max: +1)

            //varTime sets distribution for randomly changing time between speed variances. Skewed low
            sKLVehicle.holdTime = randomValue(distribution: -sKLVehicle.spdPref, min: -1, max: +1)
            //_________________________________________________________________ end speed

            //_________________________________________________________________
            //Following sets up parameters to alter set gap, min gap & decel min/max
            //Each vehicle retains these values for remainder of lifecycle
            //_________________________________________________________________ start gap
            switch sKLVehicle.vehType {
            //Gaps in seconds. Decels in m/s2. See Quick Help on each for details!
            case .car:
                sKLVehicle.mySetGap = randomValue(distribution: -0.5, min: 2.4, max: 3.4)   //gap in secs
                sKLVehicle.decelMin = randomValue(distribution: +1.0, min: 2.5, max: 4.0)   //m/s2
                sKLVehicle.decelMax = randomValue(distribution: +0.5, min: 8.0, max: 10.0)  //m/s2
                sKLVehicle.myMinGap = randomValue(distribution: -1.0, min: 0.4, max: 0.8)   //gap in secs
            case .bus:
                sKLVehicle.mySetGap = randomValue(distribution: 0.0, min: 2.8, max: 4.2)
                sKLVehicle.decelMin = randomValue(distribution: -0.2, min: 1.4, max: 3.8)
                sKLVehicle.decelMax = randomValue(distribution: 0.0, min: 7.0, max: 8.5)
                sKLVehicle.myMinGap = randomValue(distribution: 0.0, min: 0.6, max: 0.9)
            case .truck:
                sKLVehicle.mySetGap = randomValue(distribution: +0.25, min: 2.9, max: 5.8)
                sKLVehicle.decelMin = randomValue(distribution: -1.0, min: 1.0, max: 3.5)
                sKLVehicle.decelMax = randomValue(distribution: -0.5, min: 6.5, max: 8.0)
                sKLVehicle.myMinGap = randomValue(distribution: +1.0, min: 0.8, max: 1.2)
            }
            //_________________________________________________________________ end gap

            //_________________________________________________________________
            //Following sets up probabilities to alter how vehicles on the otherTrack
            // change lanes. No affect on vehicles on Keep left Track.
            //Each vehicle retains these values for remainder of lifecycle
            //_________________________________________________________________ start lane
                sKLVehicle.laneProb = randomValue(distribution: 0, min: -1, max: 1)   //Define distribution for ongoing variations

            //_________________________________________________________________ end lane

//1st line below runs randomValue & prints value. 2nd line runs randomValue 10,000 times to test distribution.
// print("Result: \(randomValue(distribution: -1, min: 0, max: 100).dp0)%")  //Prints 'numVehicles' times
// testRun(distribution: -1) //Test distribution from 10,000 attempts (* numVehicles)

            sKLVehicle = placeVehicle(sKLVehicle: sKLVehicle, sOtherVehicle: sOtherVehicle)

            //UNSURE OF RELEVANCE OF BELOW - MAY BE REDUNDANT & UNUSED!!!
            t1Stats["Name"]?.append(sKLVehicle.name!)
            t1Stats["Actual Speed"]?.append(0.0)
            if let unwrapped = t1Stats["Name"]?[i] {        //Not used???
//                if let speed = t1Stats["Actual Speed"]?[i] {
////                print("Name in Dictionary = \(unwrapped) : Speed = \(speed)")
//                }
            }           //IS THE ABOVE REDUNDANT???
            
            //Start another SKAction cycle of setting 'preferredSpeed'. Now starts @500ms
//            sKLVehicle.setVehicleSpeed()   //Randomly calculate & load preferredSpeed for each vehicle
            
        }                       //end makeVehicle 'for' loop. Loop to create the next vehicle, exit when done
        
        gameStage = gameStage & 0x70    //Clear MSB & 4 LSBs when vehicles all exist (Int = 8 bits)
                                        //  - allows processing of vehicle speeds etc.

//        let sun = SKSpriteNode(color: UIColor(red: 255/255, green: 95/255, blue: 31/255, alpha: 1), size:
//                                CGSize(width: 2, height: 2))
//        sun.position = CGPoint(x: 0, y: 500)
////            sun.zPosition = 1000000000
//        sBackground.addChild(sun)
//        sun.addGlow()

        return              //Should this return anything in particular???
//        return sKLVehicle
    }                       //end makeVehicle
    
//Function will randomly place vehicles onscreen.
    func placeVehicle(sKLVehicle: Vehicle, sOtherVehicle: Vehicle) -> Vehicle {
    var spriteClear = false
    var randomPos: CGFloat
    var randomLane: Int
        
//        scene?.enumerateChildNodes(withName: "//*") { (node, stop) in
//            print("\(node.name ?? "none")\t\(node.position.x.dp2)\t\(node.position.y.dp2)")
//                                   }
    
    repeat {
        randomPos = CGFloat.random(in: 0..<sTrackLength)    //Sets random y position in metres (0 - 999.99999 etc)
        randomLane = Int.random(in: 0...1)          //Sets initial Lane 0 (LHS) or 1 (RHS)
        sKLVehicle.position.y = randomPos
//        sKLVehicle.position.x = (randomLane == 0) ? ((sSceneWidth / 2.0) - (((roadWidth / 2) + (laneWidth / 2) + (lineWidth / 2) + (centreStrip/2)) * straightScene.metre1)) : ((sSceneWidth / 2.0) - (((roadWidth / 2) - (laneWidth / 2) - (lineWidth / 2) + (centreStrip/2)) * straightScene.metre1))
        sKLVehicle.position.x = (randomLane == 0) ? ( -((roadWidth / 2) + (laneWidth / 2) + (lineWidth / 2) + (centreStrip/2))) : ( -((roadWidth / 2) - (laneWidth / 2) - (lineWidth / 2) + (centreStrip/2)))
//        sKLVehicle.startPos = sKLVehicle.position.y
        sKLVehicle.lane = CGFloat(randomLane)
        
        sOtherVehicle.position.y = sTrackLength - randomPos
//        sOtherVehicle.position.x = (randomLane == 0) ? ((sSceneWidth / 2.0) + (((roadWidth / 2) + (laneWidth / 2) + (lineWidth / 2) + (centreStrip/2)) * straightScene.metre1)) : ((sSceneWidth / 2.0) + (((roadWidth / 2) - (laneWidth / 2) - (lineWidth / 2) + (centreStrip/2)) * straightScene.metre1))
        sOtherVehicle.position.x = (randomLane == 0) ? ( +((roadWidth / 2) + (laneWidth / 2) + (lineWidth / 2) + (centreStrip/2))) : ( +((roadWidth / 2) - (laneWidth / 2) - (lineWidth / 2) + (centreStrip/2)))
//        sOtherVehicle.startPos = sOtherVehicle.position.y
        sOtherVehicle.lane = CGFloat(randomLane)
        
        spriteClear = true
        //        veh.position = CGPoint(x: ((view?.bounds.size.width)! / 2.0) - ((5.85 + centreStrip/2) * sMetre1), y: 400.0 * sMetre1)
        //MARK: - Ensure vehicle doesn't overlap existing vehicle!
        var noRoom = 100
        sKLVehicle.size.height = (sKLVehicle.size.height + (minGap * 2))    //Temporarily increase length
        for sprite in sKLAllVehicles.dropFirst() {
//            sprite.size.height = sprite.size.height + (minGap*2)
            if (sKLVehicle.intersects(sprite)) {
                spriteClear = false
//                print ("\(Int.extractNum(from: sKLVehicle.name ?? "S")!),\(Int.extractNum(from: sprite.name ?? "D")!),Lane = ,\(Int(sKLVehicle.lane)),Pos = ,\(Int(sKLVehicle.position.y)),,Width = \(sKLVehicle.size.width.dp1),Length = ,\((sKLVehicle.size.height).dp2) *")
//                print(sKLVehicle.physicsBody!,"\n")
//                print(sKLVehicle,"\n")
//                print(sprite.physicsBody!,"\n")
//                print(sprite,"\n")
                break
            } else {                //OK - test if values approaching zero close to values approaching max
                let tempS = sprite.position.y       //Temp storage of Y position
                let tempK = sKLVehicle.position.y   //Temp storage of Y position
                if tempS < 250 {sprite.position.y = tempS + sTrackLength}      //Add 1000 to pos Y
                if tempK < 250 {sKLVehicle.position.y = tempK + sTrackLength}  //Add 1000 to pos Y
                if (sKLVehicle.intersects(sprite)) {
                    spriteClear = false
//                    print ("\(Int.extractNum(from: sKLVehicle.name ?? "S")!),\(Int.extractNum(from: sprite.name ?? "D")!),Lane = ,\(Int(sKLVehicle.lane)),Pos = ,\(Int(sKLVehicle.position.y)),,Width = \(sKLVehicle.size.width.dp1),Length = ,\((sKLVehicle.size.height).dp2) *")
//                    print(sKLVehicle.physicsBody!,"\n")
//                    print(sKLVehicle,"\n")
//                    print(sprite.physicsBody!,"\n")
//                    print(sprite,"\n")
                    break
                }                       //End 2nd 'intersects' function
                sprite.position.y = tempS           //Restore Y position
                sKLVehicle.position.y = tempK       //Restore Y position
            }                           //End 1st 'intersects' function
        }                               //End 'for sprite' loop
        sKLVehicle.size.height = (sKLVehicle.size.height - (minGap * 2))    //Restore original length

//        print ("\(Int.extractNum(from: sKLVehicle.name ?? "S")!),  ,Lane = ,\(Int(sKLVehicle.lane)),Pos = ,\(Int(sKLVehicle.position.y.rounded())),,Width = \(sKLVehicle.size.width.dp1),Length = ,\((sKLVehicle.size.height).dp2)")
//
    } while !spriteClear
    
    sKLVehicle.startPos = sKLVehicle.position.y
    sOtherVehicle.startPos = sOtherVehicle.position.y

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
        
        let duration = 0.4      //If changed, change also 'swipeRight'!

        if whichScene == .figure8 {
            let halfSwipeDelay = SKAction.wait(forDuration: duration / 2)   //Change display data @ slide halfway point
            let setNextVehicle = SKAction.run {
                if f8DisplayDat >= (numVehicles) {
                    f8DisplayDat = 0
                } else {
                    f8DisplayDat += 1
                }
            }
            //The following will set display back to All Vehicles after a delay
            let delay5 = SKAction.wait(forDuration: oneVehicleDisplayTime)
            let backToAll = SKAction.run {
                f8DisplayDat = 0
            }
            let backToAllSequence = SKAction.sequence([halfSwipeDelay, setNextVehicle, delay5, backToAll])
            run(backToAllSequence, withKey: "backToAll")
        } else {    //Scene != .figure 8. Must be displaying Straight Track
        }           //end whichScene test

        let slideLeft = SKAction.customAction(withDuration: duration, actionBlock: {
            (node, elapsedTime) in
            if (elapsedTime / duration) < 0.5 {     //Slide labels off to left
                f8KLLabel.position.x = 0 - (elapsedTime / duration) * 220
                f8OtherLabel.position.x = 0 - (elapsedTime / duration) * 220
            } else {                                //Move label off-screen to right & then slide in
                f8KLLabel.position.x = 110 - ((elapsedTime / duration) - 0.5) * 220
                f8OtherLabel.position.x = 110 - ((elapsedTime / duration) - 0.5) * 220
            }
        })
        run(slideLeft)

    }               //end Swipe Left/Right gesture

    @objc func swipeRight(sender: UISwipeGestureRecognizer) {
        
        let duration = 0.4      //If changed, change also 'swipeLeft'!

        if whichScene == .figure8 {
            let halfSwipeDelay = SKAction.wait(forDuration: duration / 2)   //Change display data @ slide halfway point
            let setNextVehicle = SKAction.run {
                if f8DisplayDat == 0 {
                    f8DisplayDat = numVehicles
                } else {
                    f8DisplayDat -= 1
                }
            }
            //The following will set display back to All Vehicles after a delay
            let delay5 = SKAction.wait(forDuration: oneVehicleDisplayTime)
            let backToAll = SKAction.run {
                f8DisplayDat = 0
            }
            let backToAllSequence = SKAction.sequence([halfSwipeDelay, setNextVehicle, delay5, backToAll])
            run(backToAllSequence, withKey: "backToAll")
        } else {
            //.straight code here
        }
        
        let slideRight = SKAction.customAction(withDuration: duration, actionBlock: {
            (node, elapsedTime) in
            if (elapsedTime / duration) < 0.5 {     //Slide labels off to right
                f8KLLabel.position.x = 0 + (elapsedTime / duration) * 220
                f8OtherLabel.position.x = 0 + (elapsedTime / duration) * 220
            } else {                                //Move label off-screen to left & then slide in
                f8KLLabel.position.x = -110 + ((elapsedTime / duration) - 0.5) * 220
                f8OtherLabel.position.x = -110 + ((elapsedTime / duration) - 0.5) * 220
            }
        })
        run(slideRight)

    }

    //MARK: - the function below runs every 500ms
    @objc func every500ms() {
        
        var newRun: Bool
        if runSwitched == .switched {   //Indicates run/stop state just changed
            newRun = true
            var currState: String
            switch runStop {
            case .run: currState = "Start"
            case .stop: currState = "Stop"
            }
            print("\(currState) just occurred!")
            runSwitched = .stable
        } else {
            newRun = false
//            print("Run State hasn't changed!\t\(newRun)")
        }
        
//        if runStop == .run {          //runTimer now increments 60 times per sec
//            runTimer += 0.5           //Add 500ms to runTimer. Used to calculate average speeds
//        }
        
//        print("enableMinSpeed: \(enableMinSpeed)\t\trunTimer: \(runTimer)")
        
    let t1Vehicle = sKLAllVehicles   //Straight Track Vehicles
    let t2Vehicle = sOtherAllVehicles
        var tempSpd: CGFloat = 0
        
        //MARK: - Set timeMx = hours of vehicle run time to now!
//        let timeMx: CGFloat = 3600 / runTimer
        
        if (Int(runTimer * 2) & 0x0F) == 0x08 {    //every 10 seconds
            randNo = CGFloat.random(in: 80...180)
            randUnitNo = Int.random(in: 1...numVehicles)
            
//            print("randNo: \(randNo.dp1)\trandUnitNo: \(randUnitNo)\tprefSpd: \(t1Vehicle[randUnitNo].preferredSpeed.dp1)\tcurrSpd: \((t1Vehicle[randUnitNo].physicsBody!.velocity.dy * 3.6).dp1)")
        }
        
        var unitNo: Int = 0
    //Loop through both arrays simultaneously. Move back 1km when they've travelled 1km!
        for (sKLNode, sOtherNode) in zip(t1Vehicle.dropFirst(), t2Vehicle.dropFirst()) {
            unitNo += 1
            
//            let randNo: CGFloat = CGFloat.random(in: 50...180)
            newNo = (randNo + (3 * newNo)) / 4
            if newNo < oldNo - 1 {
                oldNo -= 4
            } else  if newNo > oldNo + 1 {
                oldNo += 4
            }
            tempSpd = oldNo  // -> km
            let otherTempSpeed: CGFloat = tempSpd - (0.6 * (newNo - 85))
            
            //MARK: - Flash vehicle when data displayed for single vehicle only
            flashVehicle(thisVehicle: sKLNode)

//        switch runStop {   //Wait until vehicles started
//        case .stop:
//            sKLNode.preferredSpeed = 0
//            sOtherNode.preferredSpeed = 0
//
//        case .run:
//
////            sKLNode.preferredSpeed = 130
//            if randUnitNo == unitNo || sKLNode.preferredSpeed == 0 {
//                sKLNode.preferredSpeed = randNo
//                sKLAllVehicles[unitNo].preferredSpeed = randNo
////                sOtherNode.preferredSpeed = CGFloat.random(in: 82...150)
//            }
////            sKLNode.preferredSpeed = (tempSpd + CGFloat(unitNo * 4)) * 2.7
////            sKLNode.preferredSpeed = (tempSpd + CGFloat(unitNo * 4)) * 3.5
////            sOtherNode.preferredSpeed = (tempSpd + CGFloat(unitNo * 4)) * 0.6
//            
////            sOtherNode.preferredSpeed = (tempSpd + CGFloat(unitNo * 4)) * 2.2
//            sOtherNode.preferredSpeed = sKLNode.preferredSpeed
//            sOtherAllVehicles[unitNo].preferredSpeed = sKLNode.preferredSpeed
//        }

            //MARK: - Ensure vehicle speeds are constantly calculated for each vehicle
            //          setVehicleSpeed recursive. Called within 1/2s of Start/Stop
            if newRun == true {             //Call setVehicleSpeed after Start/Stop
                sKLNode.setVehicleSpeed()   //Randomly calculate & load preferredSpeed for each vehicle
                sKLNode.setLaneMode()       //Randomly calculate & load laneMode 0-100 for each vehicle
            }


            //OLD CODE BELOW!
//            if sKLNode.action(forKey: "spdAct\(unitNo)") == nil {   //SKAction hasn't begun or has ended!
//                //Start another SKAction cycle of setting 'preferredSpeed'
//                sKLNode.setVehicleSpeed()   //Randomly calculate & load preferredSpeed for each vehicle
//            } else {    //runs if action is active
//                //                print("SKAction spdAct\(unitNo) is running!")
//            }
// The above worked perfectly but now use recursion in setVehicleSpeed func instead
            
    }   //End of 'for' loop
        
//        firstThru = false       //NEVER = true again !!!
        
//        let snapShot = self.view?.texture(from: sKLAllVehicles[1], crop: CGRect(x: 0, y: 500, width: 25, height: 25))
//        var zoomBit = SKSpriteNode(texture: snapShot, size: CGSize(width: 50, height: 50))
//        zoomBit.setScale(1.5)
//        zoomBit.zPosition = 1500
//        zoomBit.zRotation = .pi/2
//        print("self: \(self)\nsnapShot: \(String(describing: snapShot))\nzoomBit: \(zoomBit)")
//        addChild(zoomBit)
        
}       //end 500ms function
    
    
    //'updateSpeeds' replaced by 'updateKLVehicles' & 'updateOtherVehicles'
    //############################################################################
    //Code below starts lane change & indicators where required
    func updateKLVehicles(rtVeh: [NodeData]) -> ([NodeData]) {
        
        var retVeh: [NodeData] = rtVeh
//        let halfFlash: CGFloat = 0.3    //Time indicators are ON or OFF
//        let numFlash = 6        //No of full indicator flashes
//        let laneChangeTime: CGFloat = CGFloat(numFlash) * halfFlash * 1.8
        let indicatorOn = SKAction.unhide() //Overtaking indicators ON
        let indicatorOff = SKAction.hide()  //Overtaking indicators OFF
        let deelay = SKAction.wait(forDuration: halfFlash)  //Delay halfFlash secs
        let pulseIndicators = SKAction.sequence([indicatorOn, deelay, indicatorOff, deelay])
        let flash = SKAction.repeat(pulseIndicators, count: numFlash)
        
        
        var speedChange: CGFloat
        var newTime: CGFloat
        var newSpeed: CGFloat
        
        let leftLaneX = ((centreStrip/2) + shoulderWidth + shoulderLineWidth + (laneWidth / 2) + (laneWidth + lineWidth))
        //leftLaneX defines X position of centre of left lane
        let lane2Lane = laneWidth + lineWidth   //distance from centre of left lane to centre of the right lane
        
        for (index, vehNode) in retVeh.enumerated() {            //index = 0 - (numVehicles - 1)
            
            if index == 0 { continue }       //Skip loop for element[0] = All Vehicles
            
            //THIS Vehicle = vehNode = retVeh[index] = (sKLAllVehicles[unitNum] OR sOtherAllVehicles[unitNum])
            //  unitNum = Int.extractNum(from: vehNode.name)!  //NOTE: Use [unitNum] for sKLAllVehicles. Use [index] for retVeh!
            //NOW THAT tVehicle RESORTED IN NUMERICAL ORDER, unitNum IS SAME AS 'index' SO NO NEED TO EXTRACT!
            
            if retVeh[index].startIndicator == true { //Code only runs to Start Flashing
                retVeh[index].startIndicator = false
                sKLAllVehicles[index].startIndicator = false
                
                let maxVehicleAngle: CGFloat = (atan(xLaneVelocity / sKLAllVehicles[index].physicsBody!.velocity.dy)).radians() //Result in radians -> degrees
                //maxVehicleAngle value fixed for duration of lane change

                if retVeh[index].indicator == .overtake { //About to Overtake
                    
                    let startMsg = SKAction.run {       //Not used - may delete startMsg later!!!
                        //                if printOvertake != 0 {
                        //                    if kLTrack {    //KL Track
                        //                    print("\t\t\t\t\t\t\(index) Start KLBack\tLane \(sKLAllVehicles[index].lane.dp0)\tInd = \(sKLAllVehicles[index].indicator)")
                        //                    } else {    //Not KL Track
                        //                        print("\t\t\t\t\t\t\(index) Start OtBack\tLane \(sOtherAllVehicles[index].lane.dp0)\tInd = \(sOtherAllVehicles[index].indicator)")
                        //                    }       //end KL Track
                        //                }           //end Optional Print
                    }               //end SKAction.run
                    
                    let goToLane1 = SKAction.customAction(withDuration: laneChangeTime, actionBlock: {
                        (node, elapsedTime) in
                        sKLAllVehicles[index].lane = (elapsedTime / laneChangeTime)
                        retVeh[index].lane = sKLAllVehicles[index].lane
                        //_____________
                        //goToLane1 needs -ve rotation angle
                        //_____________
//                        let rotFudgeFactor = 0.3 //GLOBAL variable
                        var rotAngle = sKLAllVehicles[index].lane * 2   //set initial value to 0-2
                        if rotAngle > 1 {                               //Leave 0-1 as is (1st half way)
                            rotAngle = 1 - (rotAngle - 1)               //1-2 -> 1-0 (2nd half of lane change)
                        }                                               //= 0...1...0 multiplier
                        rotAngle = -rotAngle * maxVehicleAngle          //maxVehicleAngle already in degrees
                        rotAngle = rotAngle * rotFudgeFactor            //Fudge for greater angle mid-way
                        f8KLAllVehicles[index].f8RotTweak = rotAngle    //Saved in degrees
                        sKLAllVehicles[index].zRotation = (elapsedTime / laneChangeTime) * rotAngle.degrees() //Convert back to radians
//                        if index == 1 {print("\(index)\tmaxAngle: \(maxVehicleAngle.dp2)\tAngle: \(rotAngle.dp2)\tKeepLeft Overtake")}
                        //-------------
                    })               //End goToLane0 action
                    
                    let laneChange = SKAction.group([goToLane1, flash])
                    
                    let endLane1 = SKAction.run {
                        retVeh[index].lane = 1      //Ensure lane only = 1 or 0 when here!
                        retVeh[index].indicator = .off
                        sKLAllVehicles[index].lane = 1      //Ensure lane only = 1 or 0 when here!
                        sKLAllVehicles[index].indicator = .off
                    }           //End endLane0 action
                    
                    let laneFlash1 = SKAction.sequence([startMsg, laneChange, endLane1])
                    //            let lFlash0 = SKAction.sequence([laneChange, endLane0])
                    
                    sKLAllVehicles[index].indicator = retVeh[index].indicator
                    sKLAllVehicles[index].startIndicator = retVeh[index].startIndicator
                    sKLAllVehicles[index].lane = retVeh[index].lane
                    
                    let newLanePos: Void = sKLAllVehicles[index].childNode(withName: "rightInd\(index)")!.run(laneFlash1)
                    //          let newF8LanePos: Void = f8KLAllVehicles[index].childNode(withName: "leftInd\(index)")!.run(lFlash0)
                    let newF8LanePos: Void = f8KLAllVehicles[index].childNode(withName: "rightInd\(index)")!.run(flash)
                    
                } else {        //Assume .endOvertake = About to go back to left lane
                    //            if retVeh[index].indicator == .endOvertake { }
                    
                    let startMsg = SKAction.run {       //Not used - may delete startMsg later!!!
                        //                if printOvertake != 0 {
                        //                    if kLTrack {    //KL Track
                        //                    print("\t\t\t\t\t\t\(index) Start KLBack\tLane \(sKLAllVehicles[index].lane.dp0)\tInd = \(sKLAllVehicles[index].indicator)")
                        //                    } else {    //Not KL Track
                        //                        print("\t\t\t\t\t\t\(index) Start OtBack\tLane \(sOtherAllVehicles[index].lane.dp0)\tInd = \(sOtherAllVehicles[index].indicator)")
                        //                    }       //end KL Track
                        //                }           //end Optional Print
                    }               //end SKAction.run
                    
                    let goToLane0 = SKAction.customAction(withDuration: laneChangeTime, actionBlock: {
                        (node, elapsedTime) in
                        sKLAllVehicles[index].lane = (1 - (elapsedTime / laneChangeTime))
                        retVeh[index].lane = sKLAllVehicles[index].lane
                        //_____________
                        //goToLane0 needs +ve rotation angle
                        //_____________
//                        let rotFudgeFactor = 0.3 //GLOBAL variable
                        var rotAngle = sKLAllVehicles[index].lane * 2
                        if rotAngle > 1 {
                            rotAngle = 1 - (rotAngle - 1)
                        }
//                        rotAngle = (rotAngle * maxVehicleAngle).degrees()//Convert from radians to degrees
                        rotAngle = rotAngle * maxVehicleAngle           //maxVehicleAngle already in degrees
                        rotAngle = rotAngle * rotFudgeFactor            //Fudge for greater angle mid-way
                        f8KLAllVehicles[index].f8RotTweak = rotAngle    //Saved in degrees
                        sKLAllVehicles[index].zRotation = (elapsedTime / laneChangeTime) * rotAngle.degrees() //Convert back to radians
//                        if index == 1 {print("\(index)\tmaxAngle: \(maxVehicleAngle.dp2)\tAngle: \(rotAngle.dp2)\tKeepLeft Return")}
                        //-------------
                    })               //End goToLane0 action
                    
                    let laneChange = SKAction.group([goToLane0, flash])
                    
                    let endLane0 = SKAction.run {
                        retVeh[index].lane = 0      //Ensure lane only = 1 or 0 when here!
                        retVeh[index].indicator = .off
                        sKLAllVehicles[index].lane = 0      //Ensure lane only = 1 or 0 when here!
                        sKLAllVehicles[index].indicator = .off
                    }           //End endLane0 action
                    
                    let laneFlash0 = SKAction.sequence([startMsg, laneChange, endLane0])
                    //            let lFlash0 = SKAction.sequence([laneChange, endLane0])
                    
                    sKLAllVehicles[index].indicator = retVeh[index].indicator
                    sKLAllVehicles[index].startIndicator = retVeh[index].startIndicator
                    sKLAllVehicles[index].lane = retVeh[index].lane
                    
                    let newLanePos: Void = sKLAllVehicles[index].childNode(withName: "leftInd\(index)")!.run(laneFlash0)
                    //          let newF8LanePos: Void = f8KLAllVehicles[index].childNode(withName: "leftInd\(index)")!.run(lFlash0)
                    let newF8LanePos: Void = f8KLAllVehicles[index].childNode(withName: "leftInd\(index)")!.run(flash)
                    
                }               //end of 'about to overtake OR back to left lane'
            }           //End Lane Change Routine - End of .startIndicator was true routine
            //  skips above & direct to here when .startIndicator not true
            
            
            speedChange = (vehNode.goalSpeed - vehNode.currentSpeed)
            newTime = vehNode.changeTime * 60       //changeTime in secs. Runs 60 times/sec.
//            newTime = vehNode.changeTime * (60 / (CGFloat(noOfCycles) + 1))     //newTime = no of cycles @60/30/20Hz in changeTime
            newSpeed = vehNode.currentSpeed + (speedChange / newTime)
            //        sKLAllVehicles[index].physicsBody?.velocity.dy = newSpeed / 3.6 //Polarity varies subject to track!!! see below
//            if index == 1 && vehNode.goalSpeed != 0 {print("changeTime: ,\(vehNode.changeTime.dp2),speedChange: ,\(speedChange.dp1),newSpeed: ,\(newSpeed.dp1),goal: ,\(vehNode.goalSpeed.dp1),Spd: ,\(vehNode.currentSpeed.dp1)")}
            
            //        sKLAllVehicles[1].lane = 0.8000001
            if vehNode.otherTrack == false {        //KL Track
                sKLAllVehicles[index].physicsBody?.velocity.dy = (newSpeed / 3.6)
                //            sKLAllVehicles[index].physicsBody?.velocity.dx = 0
                sKLAllVehicles[index].position.x = -leftLaneX + (vehNode.lane * (lane2Lane))  //Set vehicle position in lane - Straight Track Only! DOESN'T APPEAR TO DO ANYTHING!!! - SEE changeLanes!!!
            } else {                                //Other Track
                sKLAllVehicles[index].physicsBody?.velocity.dy = -(newSpeed / 3.6)
                //            sKLAllVehicles[index].physicsBody?.velocity.dx = 0
                sKLAllVehicles[index].position.x = +leftLaneX - (vehNode.lane * (lane2Lane))  //Set vehicle position in lane - Straight Track Only! DOESN'T APPEAR TO DO ANYTHING!!! - SEE changeLanes!!!
            }                                       //end of 'If' for both tracks
            
        }       //end 'For' loop
        
        return retVeh
        
    }           //end of 'updateKLVehicles' function
    //############################################################################

    //############################################################################
    //Code below starts lane change & indicators where required
    func updateOtherVehicles(rtVeh: [NodeData]) -> ([NodeData]) {
        
        var retVeh: [NodeData] = rtVeh
//        let halfFlash: CGFloat = 0.3    //Time indicators are ON or OFF
//        let numFlash = 6        //No of full indicator flashes
//        let laneChangeTime: CGFloat = CGFloat(numFlash) * halfFlash * 1.8
        let indicatorOn = SKAction.unhide() //Overtaking indicators ON
        let indicatorOff = SKAction.hide()  //Overtaking indicators OFF
        let deelay = SKAction.wait(forDuration: halfFlash)  //Delay halfFlash secs
        let pulseIndicators = SKAction.sequence([indicatorOn, deelay, indicatorOff, deelay])
        let flash = SKAction.repeat(pulseIndicators, count: numFlash)
        
        
        var speedChange: CGFloat
        var newTime: CGFloat
        var newSpeed: CGFloat
        
        let leftLaneX = ((centreStrip/2) + shoulderWidth + shoulderLineWidth + (laneWidth / 2) + (laneWidth + lineWidth))
        //leftLaneX defines X position of centre of left lane
        let lane2Lane = laneWidth + lineWidth   //distance from centre of left lane to centre of the right lane
        
        for (index, vehNode) in retVeh.enumerated() {            //index = 0 - (numVehicles - 1)
            
            if index == 0 { continue }       //Skip loop for element[0] = All Vehicles
            
            //THIS Vehicle = vehNode = retVeh[index] = (sOtherAllVehicles[unitNum] OR sOtherAllVehicles[unitNum])
            //  unitNum = Int.extractNum(from: vehNode.name)!  //NOTE: Use [unitNum] for sOtherAllVehicles. Use [index] for retVeh!
            //NOW THAT tVehicle RESORTED IN NUMERICAL ORDER, unitNum IS SAME AS 'index' SO NO NEED TO EXTRACT!
            
            if retVeh[index].startIndicator == true { //Code only runs to Start Flashing
                retVeh[index].startIndicator = false
                sOtherAllVehicles[index].startIndicator = false
                
                let maxVehicleAngle: CGFloat = (atan(xLaneVelocity / sOtherAllVehicles[index].physicsBody!.velocity.dy)).radians()
                //maxVehicleAngle value fixed for duration of lane change
                
                if retVeh[index].indicator == .overtake { //About to Overtake
                    
                    let startMsg = SKAction.run {       //Not used - may delete startMsg later!!!
                        //                if printOvertake != 0 {
                        //                    if kLTrack {    //KL Track
                        //                    print("\t\t\t\t\t\t\(index) Start KLBack\tLane \(sOtherAllVehicles[index].lane.dp0)\tInd = \(sOtherAllVehicles[index].indicator)")
                        //                    } else {    //Not KL Track
                        //                        print("\t\t\t\t\t\t\(index) Start OtBack\tLane \(sOtherAllVehicles[index].lane.dp0)\tInd = \(sOtherAllVehicles[index].indicator)")
                        //                    }       //end KL Track
                        //                }           //end Optional Print
                    }               //end SKAction.run
                    
                    let goToLane1 = SKAction.customAction(withDuration: laneChangeTime, actionBlock: {
                        (node, elapsedTime) in
                        sOtherAllVehicles[index].lane = (elapsedTime / laneChangeTime)
                        retVeh[index].lane = sOtherAllVehicles[index].lane
                        //_____________
                        //goToLane1 needs -ve rotation angle
                        //_____________
//                        let rotFudgeFactor = 0.3 //GLOBAL variable
                        var rotAngle = sOtherAllVehicles[index].lane * 2
                        if rotAngle > 1 {
                            rotAngle = 1 - (rotAngle - 1)
                        }
//                        rotAngle = (rotAngle * maxVehicleAngle).degrees()//Convert from radians to degrees
                        rotAngle = rotAngle * maxVehicleAngle           //maxVehicleAngle already in degrees
                        rotAngle = rotAngle * rotFudgeFactor            //Fudge for greater angle mid-way
                        f8OtherAllVehicles[index].f8RotTweak = rotAngle //Saved in degrees
                        sOtherAllVehicles[index].zRotation = ((elapsedTime / laneChangeTime) * rotAngle.degrees()) + CGFloat(180).degrees() //Convert to radians
//                        if index == 1 {print("\(index)\tmaxAngle: \(maxVehicleAngle.dp2)\tAngle: \(rotAngle.dp2)\tOtherTrack Overtake")}
                        //-------------
                    })               //End goToLane0 action
                    
                    let laneChange = SKAction.group([goToLane1, flash])
                    
                    let endLane1 = SKAction.run {
                        retVeh[index].lane = 1      //Ensure lane only = 1 or 0 when here!
                        retVeh[index].indicator = .off
                        sOtherAllVehicles[index].lane = 1      //Ensure lane only = 1 or 0 when here!
                        sOtherAllVehicles[index].indicator = .off
                    }           //End endLane0 action
                    
                    let laneFlash1 = SKAction.sequence([startMsg, laneChange, endLane1])
                    //            let lFlash0 = SKAction.sequence([laneChange, endLane0])
                    
                    sOtherAllVehicles[index].indicator = retVeh[index].indicator
                    sOtherAllVehicles[index].startIndicator = retVeh[index].startIndicator
                    sOtherAllVehicles[index].lane = retVeh[index].lane
                    
                    let newLanePos: Void = sOtherAllVehicles[index].childNode(withName: "rightInd\(index)")!.run(laneFlash1)
                    //          let newF8LanePos: Void = f8OtherAllVehicles[index].childNode(withName: "leftInd\(index)")!.run(lFlash0)
                    let newF8LanePos: Void = f8OtherAllVehicles[index].childNode(withName: "rightInd\(index)")!.run(flash)
                    
                } else {        //Assume .endOvertake = About to go back to left lane
                    //            if retVeh[index].indicator == .endOvertake { }
                    
                    let startMsg = SKAction.run {       //Not used - may delete startMsg later!!!
                        //                if printOvertake != 0 {
                        //                    if kLTrack {    //KL Track
                        //                    print("\t\t\t\t\t\t\(index) Start KLBack\tLane \(sOtherAllVehicles[index].lane.dp0)\tInd = \(sOtherAllVehicles[index].indicator)")
                        //                    } else {    //Not KL Track
                        //                        print("\t\t\t\t\t\t\(index) Start OtBack\tLane \(sOtherAllVehicles[index].lane.dp0)\tInd = \(sOtherAllVehicles[index].indicator)")
                        //                    }       //end KL Track
                        //                }           //end Optional Print
                    }               //end SKAction.run
                    
                    let goToLane0 = SKAction.customAction(withDuration: laneChangeTime, actionBlock: {
                        (node, elapsedTime) in
                        sOtherAllVehicles[index].lane = (1 - (elapsedTime / laneChangeTime))
                        retVeh[index].lane = sOtherAllVehicles[index].lane
                        //_____________
                        //goToLane0 needs +ve rotation angle
                        //_____________
//                        let rotFudgeFactor = 0.3 //GLOBAL variable
                        var rotAngle = sOtherAllVehicles[index].lane * 2
                        if rotAngle > 1 {
                            rotAngle = 1 - (rotAngle - 1)
                        }
//                        rotAngle = (rotAngle * maxVehicleAngle).degrees()//Convert from radians to degrees
                        rotAngle = -rotAngle * maxVehicleAngle          //maxVehicleAngle already in degrees
                        rotAngle = rotAngle * rotFudgeFactor            //Fudge for greater angle mid-way
                        f8OtherAllVehicles[index].f8RotTweak = rotAngle //Saved in degrees
                        sOtherAllVehicles[index].zRotation = ((elapsedTime / laneChangeTime) * rotAngle.degrees() * rotFudgeFactor) + CGFloat(180).degrees() //Convert to radians
//                        if index == 1 {print("\(index)\tmaxAngle: \(maxVehicleAngle.dp2)\tAngle: \(rotAngle.dp2)\tOtherTrack Return")}
                        //-------------
                    })               //End goToLane0 action
                    
                    let laneChange = SKAction.group([goToLane0, flash])
                    
                    let endLane0 = SKAction.run {
                        retVeh[index].lane = 0      //Ensure lane only = 1 or 0 when here!
                        retVeh[index].indicator = .off
                        sOtherAllVehicles[index].lane = 0      //Ensure lane only = 1 or 0 when here!
                        sOtherAllVehicles[index].indicator = .off
                    }           //End endLane0 action
                    
                    let laneFlash0 = SKAction.sequence([startMsg, laneChange, endLane0])
                    //            let lFlash0 = SKAction.sequence([laneChange, endLane0])
                    
                    sOtherAllVehicles[index].indicator = retVeh[index].indicator
                    sOtherAllVehicles[index].startIndicator = retVeh[index].startIndicator
                    sOtherAllVehicles[index].lane = retVeh[index].lane
                    
                    let newLanePos: Void = sOtherAllVehicles[index].childNode(withName: "leftInd\(index)")!.run(laneFlash0)
                    //          let newF8LanePos: Void = f8OtherAllVehicles[index].childNode(withName: "leftInd\(index)")!.run(lFlash0)
                    let newF8LanePos: Void = f8OtherAllVehicles[index].childNode(withName: "leftInd\(index)")!.run(flash)
                    
                }               //end of 'about to overtake OR back to left lane'
            }           //End Lane Change Routine - End of .startIndicator was true routine
            //  skips above & direct to here when .startIndicator not true
            
            
            speedChange = (vehNode.goalSpeed - vehNode.currentSpeed)
            newTime = vehNode.changeTime * 60       //changeTime in secs. Runs 60 times/sec.
//            newTime = vehNode.changeTime * (60 / (CGFloat(noOfCycles) + 1))     //newTime = no of cycles @60/30/20Hz in changeTime
            newSpeed = vehNode.currentSpeed + (speedChange / newTime)
            //        sOtherAllVehicles[index].physicsBody?.velocity.dy = newSpeed / 3.6 //Polarity varies subject to track!!! see below
            
            //        sOtherAllVehicles[1].lane = 0.8000001
            if vehNode.otherTrack == false {        //KL Track
                sOtherAllVehicles[index].physicsBody?.velocity.dy = (newSpeed / 3.6)
                //            sOtherAllVehicles[index].physicsBody?.velocity.dx = 0
                sOtherAllVehicles[index].position.x = -leftLaneX + (vehNode.lane * (lane2Lane))  //Set vehicle position in lane - Straight Track Only! DOESN'T APPEAR TO DO ANYTHING!!! - SEE changeLanes!!!
            } else {                                //Other Track
                sOtherAllVehicles[index].physicsBody?.velocity.dy = -(newSpeed / 3.6)
                //            sOtherAllVehicles[index].physicsBody?.velocity.dx = 0
                sOtherAllVehicles[index].position.x = +leftLaneX - (vehNode.lane * (lane2Lane))  //Set vehicle position in lane - Straight Track Only! DOESN'T APPEAR TO DO ANYTHING!!! - SEE changeLanes!!!
            }                                       //end of 'If' for both tracks
            
        }       //end 'For' loop
        
        return retVeh
        
    }           //end of 'updateOtherVehicles' function
    //############################################################################

//    NOTE: updateF8TSpots OBSOLETE!!! updateF8Vehicles runs 50x faster!!!
//    //MARK: - Update position of vehicles on Fig 8 Track based on Straight Track vehicles
//    func updateF8TSpots(t1Vehicle: [NodeData], kLTrack: Bool) {
//        var key: String = ""            //Create Unique key for each Fig 8 vehicle
//        let actionTimeF8: CGFloat = 0.5 //SKAction time in seconds
//        for (index, veh1Node) in t1Vehicle.enumerated() {            //index = 0 - (numVehicles - 1)
//            if index == 0 {continue}        //Skip loop for element[0] = All Vehicles
//            guard let f8Node = f8Background.childNode(withName: veh1Node.equivF8Name) else {
//                print("f8Node NOT found!!! (see 'func updateF8TSpots')\t\(childNode(withName: veh1Node.equivF8Name))\t\(veh1Node.equivF8Name)")
//                return
//            }
//            f8Node.position = veh1Node.f8Pos
//            f8Node.zRotation = veh1Node.f8Rot
//            f8Node.zPosition = veh1Node.f8zPos
//        }   //end 'for' loop
//    }       //end updateF8TSpots

    //MARK: - Update position of vehicles on Fig 8 Track based on Straight Track vehicles
    func updateF8Vehicles(t1Vehicle: [NodeData], kLTrack: Bool) {
        
        var key: String = ""            //Create Unique key for each Fig 8 vehicle
        let actionTimeF8: CGFloat = 0.5 //SKAction time in seconds

        for (index, veh1Node) in t1Vehicle.enumerated() {            //index = 0 - (numVehicles - 1)
            if index == 0 {continue}        //Skip loop for element[0] = All Vehicles

            if kLTrack {
                f8KLAllVehicles[index].position = veh1Node.f8Pos
                f8KLAllVehicles[index].zRotation = veh1Node.f8Rot + (f8KLAllVehicles[index].f8RotTweak.degrees()) //Convert to radians
                f8KLAllVehicles[index].zPosition = veh1Node.f8zPos
//                if index == 2 { //Print for single unit ONLY (#2)
//                    if abs(f8KLAllVehicles[index].f8RotTweak) > 0.000009 {  //Don't print when zero!
//                        print("\(index)\tRotTweak: \(f8KLAllVehicles[index].f8RotTweak.dp3)º")
//                    }
//                }
            } else {
                f8OtherAllVehicles[index].position = veh1Node.f8Pos
                f8OtherAllVehicles[index].zRotation = veh1Node.f8Rot + f8OtherAllVehicles[index].f8RotTweak.degrees() //Convert to radians
                f8OtherAllVehicles[index].zPosition = veh1Node.f8zPos
            }
            
        }   //end 'for' loop
    }       //end updateF8Vehicles

}           //end Class 'StraightTrackScene'

func redoCamera() {
    f8Background.alpha = ((whichScene == .figure8) ? 1.0 : 0)

    kamera?.camera = ((whichScene == .figure8) ? f8TrackCamera : sTrackCamera)
    sTrackCamera.position = CGPoint(x: 0, y: 0 + 500)
//        sTrackCamera.scene?.size.width = straightScene.width/sTrackWidth
    f8TrackCamera.position = CGPoint(x: 0, y: 0)
//    sTrackCamera.setScale(sTrackWidth/straightScene.width)
////        camera?.setScale(1/4)
////        f8TrackCamera.setScale(f8Scene.height/f8ImageHeight)
}           //end of redoCamera func

//MARK: - Function flashes vehicle when display shows only that data
func flashVehicle(thisVehicle: Vehicle) {           //Called every 500ms. 'thisVehicle' = sKL...
    
    //The code below extracts the vehicle number from its name. Ignores track etc.
    if let vehNum = Int.extractNum(from: thisVehicle.name!) {
        // Do something with this number
        
        switch f8DisplayDat {
        case 1...999999:                //Display shows 1 vehicle only
            
            //Note: 'thisVehicle' = sKLAllVehicles[vehNum]
            if f8DisplayDat == vehNum {     //Flash currently addressed Vehicle
                if thisVehicle.alpha == 0 { //alpha = 0. Flash Vehicle ON
                    thisVehicle.alpha = 1
                    flashOffFlag = false
                    sOtherAllVehicles[vehNum].alpha = 1
                    f8KLAllVehicles[vehNum].alpha = 1
                    f8OtherAllVehicles[vehNum].alpha = 1
                } else {                    //alpha = 1. Flash Vehicle OFF
                    thisVehicle.alpha = 0
                    flashOffFlag = true
                    sOtherAllVehicles[vehNum].alpha = 0
                    f8KLAllVehicles[vehNum].alpha = 0
                    f8OtherAllVehicles[vehNum].alpha = 0
                }                           //end alpha check
            } else {                        //DON'T flash currently addressed Vehicle
                thisVehicle.alpha = 1
                sOtherAllVehicles[vehNum].alpha = 1
                f8KLAllVehicles[vehNum].alpha = 1
                f8OtherAllVehicles[vehNum].alpha = 1
            }                               //end Flash Test
        default:                            //Display shows 'All Vehicles' (f8DisplayData = 0). Don't flash
            thisVehicle.alpha = 1
            sOtherAllVehicles[vehNum].alpha = 1
            f8KLAllVehicles[vehNum].alpha = 1
            f8OtherAllVehicles[vehNum].alpha = 1
        }
    }
}               //end of flashVehicle func
