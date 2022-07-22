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

//protocol CanReceiveTransitionEvents {
//    func viewWillTransition(to size: CGSize)
//}

var vBody: SKSpriteNode!

var sprite: SKSpriteNode!   //Temporary to stop XCode errors!

var dONTrEPEAT = false

//Track scene may be temporary. Functions below MUST be called from within a scene!
class StraightTrackScene: SKScene, SKPhysicsContactDelegate {
    
    //property and function for handling rotation
    var sOneTime = false    //Only allows container to be created once
    var viewCreated = false
    var updateOneTime = false
    
    var sSceneCamera: SKCameraNode = SKCameraNode()
    
    let sContainer = SKNode()
    func set(sContainerZRotation:CGFloat) {
        sContainer.zRotation = sContainerZRotation
    }
    
    var straightScene = SceneModel()
    var toggleSpeed: Int = 2
    
    override func didChangeSize(_ oldSize: CGSize) {
        updateOneTime = false
//        print("didChangeSize triggered")
    }
    
    override func didMove(to view: SKView) {

//        let value = UIInterfaceOrientation.portrait.rawValue
//        UIDevice.current.setValue(value, forKey: "orientation")
//

        if viewCreated == false {
  
// XXX  Camera
            camera = sSceneCamera
            camera?.position = CGPoint(x: 0, y: 0)

        if sOneTime == false {
            self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            self.addChild(sContainer) //add sContainer

            sOneTime = true
        }

        //MARK: - Create background colour (width: screenwidth, height: 1km). Define sMetre1 = multiplier for metres to points
//        calcScale()

        straightScene.calcStraightScene(sSize: view.bounds.size)
        portrait = straightScene.portrait
        sMetre1 = straightScene.metre1
        sSceneWidth = straightScene.width
        sSceneHeight = straightScene.height
        
        scene?.size.width = straightScene.width
        scene?.size.height = straightScene.height
        
        scene?.backgroundColor = UIColor(red: 0.19, green: 0.38, blue: 0.16, alpha: 1)
//        scene?.zPosition = -55
//        scene?.scaleMode = .aspectFill
        physicsWorld.gravity = .zero
        
        scene?.scaleMode = .resizeFill
            
        //MARK: - Add 2x straight roads to StraightTrackScene
        addRoads()
        
        viewCreated = true
        }
        
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
        
        let t1Vehicle = t1allVehicles
        let t2Vehicle = t2allVehicles

        //Loop through both arrays simultaneously. Move back 1km when they've travelled 1km!
        for (vehT1, vehT2) in zip(t1Vehicle, t2Vehicle) {
            if vehT1.position.y >= (500 * straightScene.metre1) {
                vehT1.position.y = (vehT1.position.y - (1000 * straightScene.metre1))
            }
            if vehT2.position.y < -500 {
                vehT2.position.y = (vehT2.position.y + (1000 * straightScene.metre1))
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
            sContainer.childNode(withName: "sKLVehicle_\(i)")?.physicsBody?.velocity.dy = 0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
            sContainer.childNode(withName: "sOtherVehicle_\(i)")?.physicsBody?.velocity.dy = -0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
        }
        case 1:
            for i in 1...numVehicles {
                sContainer.childNode(withName: "sKLVehicle_\(i)")?.physicsBody?.velocity.dy = kph * multiplier   //1000 = metres in km. 3600 = secs in hour.
//                sContainer.childNode(withName: "sOtherVehicle_\(i)")?.physicsBody?.velocity.dy = -0 * multiplier   //1000 = metres in km. 3600 = secs in hour. (NOTE: THE INSTRUCTIONS COMMENTED OUT DON'T CHANGE THE SPEED!)
            }
        case 2:
            for i in 1...numVehicles {
                sContainer.childNode(withName: "sKLVehicle_\(i)")?.physicsBody?.velocity.dy = kph * multiplier   //1000 = metres in km. 3600 = secs in hour.
                sContainer.childNode(withName: "sOtherVehicle_\(i)")?.physicsBody?.velocity.dy = -(0.6*kph) * multiplier   //1000 = metres in km. 3600 = secs in hour.
            }
        case 3:
            for i in 1...numVehicles {
                sContainer.childNode(withName: "sKLVehicle_\(i)")?.physicsBody?.velocity.dy = 0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
//                sContainer.childNode(withName: "sOtherVehicle_\(i)")?.physicsBody?.velocity.dy = -kph * multiplier   //1000 = metres in km. 3600 = secs in hour.
            }
        default:
            for i in 1...numVehicles {
//                sContainer.childNode(withName: "sKLVehicle_\(i)")?.physicsBody?.velocity.dy = 0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
                sContainer.childNode(withName: "sOtherVehicle_\(i)")?.physicsBody?.velocity.dy = -0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
            }
        }
        
/*        switch toggleSpeed {
        case 0:
        for i in 1...numVehicles {
            sContainer.childNode(withName: "sKLVehicle_\(i)")?.physicsBody?.velocity.dx = 0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
            sContainer.childNode(withName: "sOtherVehicle_\(i)")?.physicsBody?.velocity.dx = -0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
        }
        case 1:
            for i in 1...numVehicles {
                sContainer.childNode(withName: "sKLVehicle_\(i)")?.physicsBody?.velocity.dx = kph * multiplier   //1000 = metres in km. 3600 = secs in hour.
//                sContainer.childNode(withName: "sOtherVehicle_\(i)")?.physicsBody?.velocity.dx = -0 * multiplier   //1000 = metres in km. 3600 = secs in hour. (NOTE: THE INSTRUCTIONS COMMENTED OUT DON'T CHANGE THE SPEED!)
            }
        case 2:
            for i in 1...numVehicles {
                sContainer.childNode(withName: "sKLVehicle_\(i)")?.physicsBody?.velocity.dx = kph * multiplier   //1000 = metres in km. 3600 = secs in hour.
                sContainer.childNode(withName: "sOtherVehicle_\(i)")?.physicsBody?.velocity.dx = -kph * multiplier   //1000 = metres in km. 3600 = secs in hour.
            }
        case 3:
            for i in 1...numVehicles {
                sContainer.childNode(withName: "sKLVehicle_\(i)")?.physicsBody?.velocity.dx = 0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
//                sContainer.childNode(withName: "sOtherVehicle_\(i)")?.physicsBody?.velocity.dx = -kph * multiplier   //1000 = metres in km. 3600 = secs in hour.
            }
        default:
            for i in 1...numVehicles {
//                sContainer.childNode(withName: "sKLVehicle_\(i)")?.physicsBody?.velocity.dx = 0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
                sContainer.childNode(withName: "sOtherVehicle_\(i)")?.physicsBody?.velocity.dx = -0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
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
        
        if dONTrEPEAT == false {
        let veh = makeVehicle()
            dONTrEPEAT = true
        }
    }   //End addRoads
    
    func createKLSRoad() {
    let sKLRoad = createRoadSurface(xOffset: -((roadWidth + centreStrip) / 2), parent: sContainer)
    createCentreLines(xOffset: -((roadWidth + centreStrip) / 2), parent: sContainer)    //NOTE: Changing parent also changes origin!!!
    createInsideLines(xOffset: -(shoulderWidth + (shoulderLineWidth / 2) + (centreStrip / 2)), parent: sContainer)
    createOutsideLines(xOffset: -(roadWidth + (centreStrip / 2) - (shoulderWidth + (shoulderLineWidth / 2))), parent: sContainer)
    }   //End
    
    func createOtherSRoad() {
    let sOtherRoad = createRoadSurface(xOffset: ((roadWidth + centreStrip) / 2), parent: sContainer)
    createCentreLines(xOffset: ((roadWidth + centreStrip) / 2), parent: sContainer)    //NOTE: Changing parent also changes origin!!!
    createInsideLines(xOffset: (shoulderWidth + (shoulderLineWidth / 2) + (centreStrip / 2)), parent: sContainer)
    createOutsideLines(xOffset: (roadWidth + (centreStrip / 2) - (shoulderWidth + (shoulderLineWidth / 2))), parent: sContainer)
    }   //End
    
    func createRoadSurface(xOffset: CGFloat = 0, parent: SKNode) -> SKNode {
//    var roadLength: CGFloat = 1000.0
//    var roadWidth: CGFloat = 8.0
//    var yOffset: CGFloat = -500.0  //default = -500
    var zPos: CGFloat = -54
        
    let line = createLine(xOffset: xOffset, lWidth: roadWidth, lLength: roadLength, colour: asphalt, zPos: zPos, parent: parent)   //Lay down bitumen

        return line
    }

    func createCentreLines(xOffset: CGFloat = 0, parent: SKNode) {
        var yOffset = -500.0    //Starting point for first line = -500m
//        let xOffset = (roadWidth / 2) + (centreStrip / 2)     //metres (no change from road surfaces)
//        let numLines: CGFloat = trunc(roadLength / linePeriod)
        let lineSpacing: CGFloat = 1000/83  //where 1000 = track length & 83 = no lines per km
        for i in 0..<83 {   //83 = no times centre line is drawn per 1km
            yOffset = (CGFloat(i) * lineSpacing) - 500  //metres
            createLine(xOffset: xOffset, yOffset: yOffset, lLength: lineLength, parent: parent)
//            print("Line Spacing = \(yOffset) metres : sMetre1 = \(sMetre1)")
        }   //end for loop
    }

    func createInsideLines(xOffset: CGFloat = 0, parent: SKNode) {
        let yOffset = -500.0
//        let xOffset = (shoulderLineWidth / 2) + (shoulderWidth) + (centreStrip / 2)     //metres (no change from road surfaces)
//        let roadLength = 1000.0
//        let lWidth = lineWidth    //Default = lineWidth
//        zPos = -53                 //Default = -53
        createLine(xOffset: xOffset, yOffset: yOffset, lWidth: shoulderLineWidth, lLength: roadLength, parent: parent)
    }

    func createOutsideLines(xOffset: CGFloat = 0, parent: SKNode) {
        let yOffset = -500.0
//        let xOffset = (roadWidth - ((shoulderLineWidth / 2) + (shoulderWidth))) + (centreStrip / 2)
//        let roadLength = 1000.0
//        let lWidth = lineWidth  //Default = lineWidth
//        zPos = -53    //createLine defaults to -53 & colour defaults to white
        createLine(xOffset: xOffset, yOffset: yOffset, lWidth: shoulderLineWidth, lLength: roadLength, parent: parent)
//        Line().createLine(xOffset: xOffset, yOffset: yOffset, lWidth: shoulderLineWidth, lLength: roadLength, lineParent: self)
//        print("size.width = \(size.width)")
    }
    
    func createLine(xOffset: CGFloat = 0, yOffset: CGFloat = -500, lWidth: CGFloat = lineWidth, lLength: CGFloat = lineLength, colour: SKColor = .white, zPos: CGFloat = -53, parent: SKNode) -> SKNode {
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
////        sContainer.addChild(veh)
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
            
//            sKLVehicle = SKSpriteNode(imageNamed: vehImage + String(fName))
            var sKLVehicle: Vehicle = Vehicle(imageName: vehImage + String(fName))
            
//            vWidth = 2  //Temporary to force all vehicles to 2m width!
            setAspectForWidth(sprite: sKLVehicle, width: vWidth)  //Sets veh width = 2m (default) & maintains aspect ratio
            let vehSize = sKLVehicle.size
            
            sKLVehicle.zPosition = -49
            sKLVehicle.name = "sKLVehicle_\(i)"  //sKLVehicle_x -> Straight Track 1, f1Vehicle_x -> Figure 8 Track 1, g1Vehicle_x -> Game Track 1.
            sKLVehicle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: vehSize.width, height: vehSize.height + (1 * straightScene.metre1)))   //Make rectangle same size as sprite + 0.5m front and back!
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
            
            sContainer.addChild(sKLVehicle)

//            sOtherVehicle = SKSpriteNode(imageNamed: vehImage + String(fName))
            
            var sOtherVehicle: Vehicle = Vehicle(imageName: vehImage + String(fName))
            setAspectForWidth(sprite: sOtherVehicle, width: vWidth)  //Sets veh width = 2m (default) & maintains aspect ratio
            let secSize = sOtherVehicle.size
            
            sOtherVehicle.zPosition = -49
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
            
            sContainer.addChild(sOtherVehicle)

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
        sKLVehicle.position.y = (randomPos * straightScene.metre1)
//        sKLVehicle.position.x = (randomLane == 0) ? ((sSceneWidth / 2.0) - (((roadWidth / 2) + (laneWidth / 2) + (lineWidth / 2) + (centreStrip/2)) * straightScene.metre1)) : ((sSceneWidth / 2.0) - (((roadWidth / 2) - (laneWidth / 2) - (lineWidth / 2) + (centreStrip/2)) * straightScene.metre1))
        sKLVehicle.position.x = (randomLane == 0) ? ( -(((roadWidth / 2) + (laneWidth / 2) + (lineWidth / 2) + (centreStrip/2)) * straightScene.metre1)) : ( -(((roadWidth / 2) - (laneWidth / 2) - (lineWidth / 2) + (centreStrip/2)) * straightScene.metre1))
        sOtherVehicle.position.y = (1000 * straightScene.metre1) - sKLVehicle.position.y
//        sOtherVehicle.position.x = (randomLane == 0) ? ((sSceneWidth / 2.0) + (((roadWidth / 2) + (laneWidth / 2) + (lineWidth / 2) + (centreStrip/2)) * straightScene.metre1)) : ((sSceneWidth / 2.0) + (((roadWidth / 2) - (laneWidth / 2) - (lineWidth / 2) + (centreStrip/2)) * straightScene.metre1))
        sOtherVehicle.position.x = (randomLane == 0) ? ( +(((roadWidth / 2) + (laneWidth / 2) + (lineWidth / 2) + (centreStrip/2)) * straightScene.metre1)) : ( +(((roadWidth / 2) - (laneWidth / 2) - (lineWidth / 2) + (centreStrip/2)) * straightScene.metre1))
        spriteClear = true
        
        //        veh.position = CGPoint(x: ((view?.bounds.size.width)! / 2.0) - ((5.85 + centreStrip/2) * sMetre1), y: 400.0 * sMetre1)
        //MARK: - Ensure vehicle doesn't overlap existing vehicle!
        for sprite in t1allVehicles {
            if (sKLVehicle.intersects(sprite)) {
                spriteClear = false
            }
        }
    } while !spriteClear
    
    t1allVehicles.append(sKLVehicle)
    t2allVehicles.append(sOtherVehicle)
    
    return sKLVehicle
}

    func setAspectForWidth(sprite: Vehicle, width: CGFloat = 2) {
        let aspectRatio: CGFloat = sprite.size.height/sprite.size.width
        sprite.size = CGSize(width: width * straightScene.metre1, height: width * aspectRatio * straightScene.metre1)
//        return sprite
    }
}

