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

//protocol CanReceiveTransitionEvents {
//    func viewWillTransition(to size: CGSize)
//}

var vBody: SKSpriteNode!

var sprite: SKSpriteNode!   //Temporary to stop XCode errors!

//var dONTrEPEAT = false

//Track scene may be temporary. Functions below MUST be called from within a scene!
class StraightTrackScene: SKScene, SKPhysicsContactDelegate {
    
//    static var sBackground: SKSpriteNode = SKSpriteNode(color: UIColor(red: 0.19, green: 0.38, blue: 0.16, alpha: 1), size: CGSize(width: 2, height: 4))

    //property and function for handling rotation
    var sOneTime = false    //Only allows container to be created once
    var viewCreated = false
    var updateOneTime = false
    
    var sTrackCamera: SKCameraNode = SKCameraNode()
    var f8TrackCamera: SKCameraNode = SKCameraNode()

    let sContainer = SKNode()       //(Not called?)
    func set(sContainerZRotation:CGFloat) {
        sContainer.zRotation = sContainerZRotation
    }
    
    var straightScene = SceneModel()
    var f8Scene = SceneModel()
    var sBackground = Background()      //Straight Track Parent and Background
    var f8Background = Background()     //Figure 8 Track Parent and Background

    var toggleSpeed: Int = 2
    
    override func didChangeSize(_ oldSize: CGSize) {
        
        updateOneTime = false
//        print("didChangeSize triggered. Fig 8 alpha = \(f8Background.alpha). whichScene = \(whichScene)")
    }
    
    func redoCamera() {
        f8Background.alpha = ((whichScene == .figure8) ? 1.0 : 0)
        camera = ((whichScene == .figure8) ? f8TrackCamera : sTrackCamera)
        sTrackCamera.position = CGPoint(x: 0, y: 500 * straightScene.metre1)
        f8TrackCamera.position = CGPoint(x: 0, y: 500 * straightScene.metre1)
//        print("Camera Pos = \(camera!.position) : straightScene.metre1 = \(straightScene.metre1)\nf8Scene.metre1 = \(f8Scene.metre1)")
    }
    
    override func didMove(to view: SKView) {

//        let value = UIInterfaceOrientation.portrait.rawValue
//        UIDevice.current.setValue(value, forKey: "orientation")
//
        if viewCreated == false {
  
// XXX  Camera
//            camera = sTrackCamera
//            camera?.position = CGPoint(x: 0, y: 2000) //calc metre1 constant first - see below

        if sOneTime == false {
            self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            self.addChild(sContainer) //add sContainer

            sOneTime = true
        }

        //MARK: - Create background colour (width: screenwidth, height: 1km). Define sMetre1 = multiplier for metres to points
//        calcScale()

        straightScene.calcStraightScene(sSize: view.bounds.size)
//        portrait = straightScene.portrait
//        sMetre1 = straightScene.metre1
//        sSceneWidth = straightScene.width
//        sSceneHeight = straightScene.height
        
        scene?.size.width = straightScene.width //* 2         // XXXXXXXXXXXXXXXXXXXXXX !!!!!!!!!!
        scene?.size.height = 1000 * straightScene.metre1
//            camera?.position = CGPoint(x: 0, y: 500 * straightScene.metre1)
//            camera?.setScale(1/4)

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
            
            f8Scene.calcF8Scene(f8Size: view.bounds.size)

            f8Background.makeBackground(size: CGSize(width: straightScene.width, height: straightScene.height), image: "Fig 8 Track", zPos: 0)
            f8Background.position = CGPoint(x: 0, y: 500 * straightScene.metre1)
            F8YZero = f8Background.position.y
            addChild(f8Background)
            f8Background.alpha = ((whichScene == .figure8) ? 1.0 : 0)
//            f8Background.inputViewController?.prefersStatusBarHidden  //Doesn't affect status bar!
//            print("didMoveToView triggered. Fig 8 alpha = \(f8Background.alpha). whichScene = \(whichScene)")

        //MARK: - Add 2x straight roads to StraightTrackScene
        addRoads()
        
        viewCreated = true
        }
        
        redoCamera()    //Don't call until metre1 calculated!!!

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
    
//    override func preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
//        return UIInterfaceOrientation.portrait
//    }

    override func update(_ currentTime: TimeInterval) {
        
        f8Background.alpha = ((whichScene == .figure8) ? 1.0 : 0)

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
        
//        let isLandscape = (UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height)  //NOTE: Doesn't recognise UIDevice rotation here!!!
//        let rotation = UIDevice.current.orientation.isLandscape ? CGFloat.pi/2 : 0
//        camera?.zRotation = rotation
        
        let t1Vehicle = sKLAllVehicles   //Straight Track Vehicles
        let t2Vehicle = sOtherAllVehicles

        //Loop through both arrays simultaneously. Move back 1km when they've travelled 1km!
        for (vehT1, vehT2) in zip(t1Vehicle, t2Vehicle) {
            if vehT1.position.y >= (1000 * straightScene.metre1) {
                vehT1.position.y = (vehT1.position.y - (1000 * straightScene.metre1))
            }
            if vehT2.position.y < 0 {
                vehT2.position.y = (vehT2.position.y + (1000 * straightScene.metre1))
            }
//            print("X.,\(vehT1.name!):,\((vehT1.position.x).dp2),\((vehT1.position.y).dp2),,\(vehT2.name!):,\((vehT2.position.x).dp2),\((vehT2.position.y).dp2)")
        }   //End of 'for' loop
        
        let f81Vehicle = f8KLAllVehicles   //Figure 8 Track Vehicles
        let f82Vehicle = f8OtherAllVehicles
        let tempScene = f8Scene

        //Loop through both arrays simultaneously. Move into new position based on Straight Track Vehicles!
        for (vehF8KL, vehF8Other) in zip(f81Vehicle, f82Vehicle) {
            if (vehF8KL != nil) && (vehF8Other != nil) {
                
//                print("1.,\(vehF8KL.name!):,\((vehF8KL.position.x).dp2),\((vehF8KL.position.y).dp2),,\(vehF8Other.name!):,\((vehF8Other.position.x).dp2),\((vehF8Other.position.y).dp2)")
//                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//                    vehF8Other.moveF8Vehicle(f8Node: vehF8Other, meta1: tempScene.metre1, F8YZero: F8YZero)
//                    vehF8KL.moveF8Vehicle(f8Node: vehF8KL, meta1: tempScene.metre1, F8YZero: F8YZero)
//                }
//                print("2.,\(vehF8KL.name!):,\(vehF8KL.position.x.dp2),\(vehF8KL.position.y.dp2),,\(vehF8Other.name!):,\(vehF8Other.position.x.dp2),\(vehF8Other.position.y.dp2)")
            } else {
            }
        }   //End of 'for' loop
        
    }   //End of override update
    
    //        //The following code can replace the above - it's easier to follow but I suspect
    //        //creating the extra array would have a time penalty
    //        let dualArray = Array(zip(t1Vehicle, t2Vehicle))
    //        for (vehT1, vehT2) in dualArray  {
    //            if vehT1.position.y >= (1000 * sMetre1) {
    //                vehT1.position.y = (vehT1.position.y - (1000 * sMetre1))
    //            }
    //            if vehT2.position.y < 0 {
    //                vehT2.position.y = (vehT2.position.y + (1000 * sMetre1))
    //            }
    //        }
    //
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}   //Exit if not first touch!
        
        var kph: CGFloat = 110
        let multiplier: CGFloat = 1000 / 3600 * straightScene.metre1  //Value by kph gives m/sec
        
        switch toggleSpeed {
        case 0:
        for i in 1...numVehicles {
            sBackground.childNode(withName: "sKLVehicle_\(i)")?.physicsBody?.velocity.dy = 0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
            sBackground.childNode(withName: "sOtherVehicle_\(i)")?.physicsBody?.velocity.dy = -0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
        }
        case 1:
            for i in 1...numVehicles {
                sBackground.childNode(withName: "sKLVehicle_\(i)")?.physicsBody?.velocity.dy = kph * multiplier   //1000 = metres in km. 3600 = secs in hour.
//                sBackground.childNode(withName: "sOtherVehicle_\(i)")?.physicsBody?.velocity.dy = -0 * multiplier   //1000 = metres in km. 3600 = secs in hour. (NOTE: THE INSTRUCTIONS COMMENTED OUT DON'T CHANGE THE SPEED!)
            }
        case 2:
            for i in 1...numVehicles {
                sBackground.childNode(withName: "sKLVehicle_\(i)")?.physicsBody?.velocity.dy = kph * multiplier   //1000 = metres in km. 3600 = secs in hour.
                sBackground.childNode(withName: "sOtherVehicle_\(i)")?.physicsBody?.velocity.dy = -(0.6*kph) * multiplier   //1000 = metres in km. 3600 = secs in hour.
            }
        case 3:
            for i in 1...numVehicles {
                sBackground.childNode(withName: "sKLVehicle_\(i)")?.physicsBody?.velocity.dy = 0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
//                sBackground.childNode(withName: "sOtherVehicle_\(i)")?.physicsBody?.velocity.dy = -kph * multiplier   //1000 = metres in km. 3600 = secs in hour.
            }
        default:
            for i in 1...numVehicles {
//                sBackground.childNode(withName: "sKLVehicle_\(i)")?.physicsBody?.velocity.dy = 0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
                sBackground.childNode(withName: "sOtherVehicle_\(i)")?.physicsBody?.velocity.dy = -0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
            }
        }
        
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
        toggleSpeed = toggleSpeed + 1
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
    
    func createLine(xOffset: CGFloat = 0, yOffset: CGFloat = 0, lWidth: CGFloat = lineWidth, lLength: CGFloat = lineLength, colour: SKColor = .white, zPos: CGFloat = +20, parent: SKNode) -> SKNode {
//SKSpriteNode has better performance than SKShape!
        
        let line1 = SKSpriteNode(color: colour, size: CGSize(width: (lWidth * straightScene.metre1), height: (lLength * straightScene.metre1)))
//        line1.size = CGSize(width: (lWidth * straightScene.metre1), height: (lLength * straightScene.metre1))
//        line1.color = colour
        line1.anchorPoint = CGPoint(x: 0.5, y: 0) //Set anchorpoint to middle bottom
        line1.position.y = (yOffset * straightScene.metre1)
        line1.position.x = (xOffset * straightScene.metre1)
        line1.zPosition = zPos
        
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
//???        var sOtherVehicle: SKSpriteNode = SKSpriteNode(imageNamed: "\(vehImage)C1")

        for i in 1...numVehicles {
            var randomVehicle = Int.random(in: 1...maxVehicles)
//            var vWidth: CGFloat = 2.0   //Car width. Set truck & bus width = 2.5m
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
            
//            vWidth = 2  //Temporary to force all vehicles to 2m width!
            setAspectForWidth(sprite: sKLVehicle, width: vWidth, metre: straightScene.metre1)  //Sets veh width = 2m (default) & maintains aspect ratio
            let vehSize = sKLVehicle.size
            
            sKLVehicle.zPosition = +50
            sKLVehicle.name = "sKLVehicle_\(i)"  //sKLVehicle_x -> Straight Track 1, f1Vehicle_x -> Figure 8 Track 1, g1Vehicle_x -> Game Track 1.
            sKLVehicle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: sKLVehicle.size.width, height: sKLVehicle.size.height + (1 * straightScene.metre1)))   //Make rectangle same size as sprite + 0.5m front and back!
            sKLVehicle.physicsBody?.friction = 0
    //        car1.physicsBody?.affectedByGravity = false
            sKLVehicle.physicsBody?.restitution = 0
            sKLVehicle.physicsBody?.linearDamping = 0
            sKLVehicle.physicsBody?.angularDamping = 0
            sKLVehicle.physicsBody?.allowsRotation = false
            sKLVehicle.physicsBody?.isDynamic = true
//            sKLVehicle.physicsBody?.node?.zRotation = 0.0
//            print("Name = \(sKLVehicle.name!)")
//            print("sKLVehicle Dimensions = \(Int(sKLVehicle.size.width)) wide x \(Int(sKLVehicle.size.height)) long")
//            sKLVehicle.physicsBody?.isDynamic = false   //Prevents reaction to other physics bodies!
            
            sBackground.addChild(sKLVehicle)
            
            //_________________________ Fig 8 Track below __________________________________________________
            var f8KLVehicle: f8Vehicle = f8Vehicle(imageName: vehImage + String(fName))

            f8KLVehicle.size = vehSize
            f8KLVehicle.size.width = vehSize.width / 4
            f8KLVehicle.size.height = vehSize.height / 4

            f8KLVehicle.zPosition = 1
            f8KLVehicle.name = "f8KLVehicle_\(i)"  //sKLVehicle_x -> Straight Track 1, f1Vehicle_x -> Figure 8 Track 1, g1Vehicle_x -> Game Track 1.
            f8KLVehicle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: f8KLVehicle.size.width, height: f8KLVehicle.size.height + (1 * straightScene.metre1)))   //Make rectangle same size as sprite + 0.5m front and back!
            f8KLVehicle.physicsBody?.friction = 0
            f8KLVehicle.physicsBody?.restitution = 0
            f8KLVehicle.physicsBody?.linearDamping = 0
            f8KLVehicle.physicsBody?.angularDamping = 0
            f8KLVehicle.physicsBody?.allowsRotation = false
            f8KLVehicle.physicsBody?.isDynamic = false

            f8Background.addChild(f8KLVehicle)
            
//            let spinNode = SKAction.customAction(withDuration: 12, actionBlock: { (node, time) in
//                node.zRotation = .pi/3
//            })
//            f8KLVehicle.run(spinNode)

            //_________________________ Fig 8 Track above __________________________________________________

            var sOtherVehicle: Vehicle = Vehicle(imageName: vehImage + String(fName))
            setAspectForWidth(sprite: sOtherVehicle, width: vWidth, metre: straightScene.metre1)  //Sets veh width = 2m (default) & maintains aspect ratio
            let secSize = sOtherVehicle.size
            
            sOtherVehicle.zPosition = +50
            sOtherVehicle.name = "sOtherVehicle_\(i)"  //sOtherVehicle_x -> Straight Track 2, f2Vehicle_x -> Figure 8 Track 2, g2Vehicle_x -> Game Track 2.
            sOtherVehicle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: secSize.width, height: secSize.height + (1 * straightScene.metre1)))   //Make rectangle same size as sprite + 0.5m front and back!
            sOtherVehicle.physicsBody?.friction = 0
            sOtherVehicle.zRotation = CGFloat(Double.pi)  //rotate 180 degrees //XXXXXXXXXX
    //        car1.physicsBody?.affectedByGravity = false
            sOtherVehicle.physicsBody?.restitution = 0
            sOtherVehicle.physicsBody?.linearDamping = 0
            sOtherVehicle.physicsBody?.angularDamping = 0
            sOtherVehicle.physicsBody?.allowsRotation = false
            sOtherVehicle.physicsBody?.isDynamic = true
//            sKLVehicle.physicsBody?.node?.zRotation = 0.0
//            print("Name = \(sKLVehicle.name!)")
//            print("sKLVehicle Dimensions = \(Int(sKLVehicle.size.width)) wide x \(Int(sKLVehicle.size.height)) long")
//            sKLVehicle.physicsBody?.isDynamic = false   //Prevents reaction to other physics bodies!
            
            sBackground.addChild(sOtherVehicle)

//            f8KLVehicle.moveF8Vehicle(f8Node: f8KLVehicle)
            //_________________________ Fig 8 Track below __________________________________________________
            var f8OtherVehicle: f8Vehicle = f8Vehicle(imageName: vehImage + String(fName))

            f8OtherVehicle.size = secSize
            f8OtherVehicle.size.width = f8OtherVehicle.size.width / 4
            f8OtherVehicle.size.height = f8OtherVehicle.size.height / 4

            f8OtherVehicle.zPosition = 1
            f8OtherVehicle.name = "f8OtherVehicle_\(i)"  //sKLVehicle_x -> Straight Track 1, f1Vehicle_x -> Figure 8 Track 1, g1Vehicle_x -> Game Track 1.
            f8OtherVehicle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: f8OtherVehicle.size.width, height: f8OtherVehicle.size.height + (1 * straightScene.metre1)))   //Make rectangle same size as sprite + 0.5m front and back!
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
                if let speed = t1Stats["Actual Speed"]?[i] {
//                print("Name in Dictionary = \(unwrapped) : Speed = \(speed)")
                
                }
            }
        }
        
        return
//        return sKLVehicle
    }
    
//Function will randomly place vehicles onscreen.
    func placeVehicle(sKLVehicle: Vehicle, sOtherVehicle: Vehicle) -> Vehicle {
    var spriteClear = false
    var randomPos: CGFloat
    var randomLane: Int
    
    repeat {
        randomPos = CGFloat.random(in: 0..<1000)    //Sets random y position in metres (0 - 999.99999 etc)
        randomLane = Int.random(in: 0...1)          //Sets initial Lane 0 (LHS) or 1 (RHS)
        sKLVehicle.position.y = ((randomPos) * straightScene.metre1)
//        sKLVehicle.position.x = (randomLane == 0) ? ((sSceneWidth / 2.0) - (((roadWidth / 2) + (laneWidth / 2) + (lineWidth / 2) + (centreStrip/2)) * straightScene.metre1)) : ((sSceneWidth / 2.0) - (((roadWidth / 2) - (laneWidth / 2) - (lineWidth / 2) + (centreStrip/2)) * straightScene.metre1))
        sKLVehicle.position.x = (randomLane == 0) ? ( -(((roadWidth / 2) + (laneWidth / 2) + (lineWidth / 2) + (centreStrip/2)) * straightScene.metre1)) : ( -(((roadWidth / 2) - (laneWidth / 2) - (lineWidth / 2) + (centreStrip/2)) * straightScene.metre1))
        sOtherVehicle.position.y = (1000 * straightScene.metre1) - ((randomPos) * straightScene.metre1)
//        sOtherVehicle.position.x = (randomLane == 0) ? ((sSceneWidth / 2.0) + (((roadWidth / 2) + (laneWidth / 2) + (lineWidth / 2) + (centreStrip/2)) * straightScene.metre1)) : ((sSceneWidth / 2.0) + (((roadWidth / 2) - (laneWidth / 2) - (lineWidth / 2) + (centreStrip/2)) * straightScene.metre1))
        sOtherVehicle.position.x = (randomLane == 0) ? ( +(((roadWidth / 2) + (laneWidth / 2) + (lineWidth / 2) + (centreStrip/2)) * straightScene.metre1)) : ( +(((roadWidth / 2) - (laneWidth / 2) - (lineWidth / 2) + (centreStrip/2)) * straightScene.metre1))
        spriteClear = true
        
        //        veh.position = CGPoint(x: ((view?.bounds.size.width)! / 2.0) - ((5.85 + centreStrip/2) * sMetre1), y: 400.0 * sMetre1)
        //MARK: - Ensure vehicle doesn't overlap existing vehicle!
        for sprite in sKLAllVehicles {
            if (sKLVehicle.intersects(sprite)) {
                spriteClear = false
            }
        }
    } while !spriteClear
    
    sKLAllVehicles.append(sKLVehicle)
    sOtherAllVehicles.append(sOtherVehicle)

    return sKLVehicle
}

    func setAspectForWidth(sprite: Vehicle, width: CGFloat = 2, metre: CGFloat) {
        let aspectRatio: CGFloat = sprite.size.height/sprite.size.width
        sprite.size = CGSize(width: width * metre, height: width * aspectRatio * metre)
//        return sprite
    }
    
}

