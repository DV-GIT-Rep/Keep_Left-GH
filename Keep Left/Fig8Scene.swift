//
//  Fig8Track.swift
//  Keep Left
//
//  Created by Bill Drayton on 25/2/2022.
//

import Foundation
import SpriteKit
import SwiftUI

//var fBuff: SKSpriteNode!
//var vBody: SKSpriteNode!
//var rBuff: SKSpriteNode!

//var sprite: SKSpriteNode!   //Temporary to stop XCode errors!

//Track scene may be temporary. Functions below MUST be called from within a scene!
class Fig8Scene: SKScene {
    
    var toggleSpeed: Int = 0
    
//    let self.view?.showsNodeCount = true
    
//    override func viewWillTransition( {
//        //MARK: - Create background colour width: screenwidth height: 1km. Define sMetre1 = multiplier for metres to points
//        calcF8Size()
//    }
    
    override func didMove(to view: SKView) {
        
        
        //MARK: - Create background colour width: screenwidth height: 1km. Define sMetre1 = multiplier for metres to points
        calcF8Size()
        
        //MARK: - Add 2x figure 8 roads to StraightTrackScene
        addF8Roads()
        
        getKLVehicles()
        
    }
    
//    override func update(_ currentTime: TimeInterval) {
//        
//        let t1Vehicle = t1allVehicles
//        let t2Vehicle = t2allVehicles
//
//        //Loop through both arrays simultaneously. Move back 1km when they've travelled 1km!
//        for (vehT1, vehT2) in zip(t1Vehicle, t2Vehicle) {
//            if vehT1.position.y >= (1000 * sMetre1) {
//                vehT1.position.y = (vehT1.position.y - (1000 * sMetre1))
//            }
//            if vehT2.position.y < 0 {
//                vehT2.position.y = (vehT2.position.y + (1000 * sMetre1))
//            }
//        }   //End of 'for' loop
//        
//    }   //End of override update
    
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
//        guard let touch = touches.first else {return}   //Exit if not first touch!
        toggleSpeed = 2
        var transition: SKTransition = SKTransition.fade(withDuration: 2)
        var scene = StraightTrackScene()
        self.view?.presentScene(scene, transition: transition)
    }
/*
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        var kph: CGFloat = 110
        let multiplier: CGFloat = 1000 / 3600 * sMetre1  //Value by kph gives m/sec
        
        switch toggleSpeed {
        case 0:
        for i in 1...numVehicles {
            childNode(withName: "s1Vehicle_\(i)")?.physicsBody?.velocity.dy = kph * multiplier   //1000 = metres in km. 3600 = secs in hour.
            childNode(withName: "s2Vehicle_\(i)")?.physicsBody?.velocity.dy = -0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
        }
            toggleSpeed = toggleSpeed + 1   //Skip case 1: (OFF step) b4 both directions running
        case 1:
            for i in 1...numVehicles {
                childNode(withName: "s1Vehicle_\(i)")?.physicsBody?.velocity.dy = 0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
//                childNode(withName: "s2Vehicle_\(i)")?.physicsBody?.velocity.dy = -0 * multiplier * sMetre1   //1000 = metres in km. 3600 = secs in hour. (NOTE: THE INSTRUCTIONS COMMENTED OUT DON'T CHANGE THE SPEED!)
            }
        case 2:
            for i in 1...numVehicles {
                childNode(withName: "s1Vehicle_\(i)")?.physicsBody?.velocity.dy = kph * multiplier   //1000 = metres in km. 3600 = secs in hour.
                childNode(withName: "s2Vehicle_\(i)")?.physicsBody?.velocity.dy = -kph * multiplier   //1000 = metres in km. 3600 = secs in hour.
            }
        case 3:
            for i in 1...numVehicles {
                childNode(withName: "s1Vehicle_\(i)")?.physicsBody?.velocity.dy = 0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
//                childNode(withName: "s2Vehicle_\(i)")?.physicsBody?.velocity.dy = -kph * multiplier   //1000 = metres in km. 3600 = secs in hour.
            }
        default:
            for i in 1...numVehicles {
//                childNode(withName: "s1Vehicle_\(i)")?.physicsBody?.velocity.dy = 0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
                childNode(withName: "s2Vehicle_\(i)")?.physicsBody?.velocity.dy = -0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
            }
            toggleSpeed = -1
        }
        toggleSpeed = toggleSpeed + 1
    }   */
    
    //Calculate scale of the display and return display orientation
//    func calcF8Size() -> (f8km1: CGFloat, f8TrackPortrait: Bool) {
    func calcF8Size() -> () {
        if (view!.bounds.size.width < view!.bounds.size.height) {
            portrait = true
//            scene?.anchorPoint = CGPoint(x: 0.5, y: 0.0)
            scene?.size.width = view!.bounds.size.width
            scene?.size.height = view!.bounds.size.height
            if (scene?.size.height)! > (2 * (scene?.size.width)!) {
                f8Metre1 = (scene?.size.width)! / f8ScreenWidth
            } else {
                f8Metre1 = (scene?.size.height)! / f8ScreenHeight
            }
            print("f8Metre1: \(f8Metre1)\nHeight: \(scene?.size.height)!    Width: \(scene?.size.width)!\nf8ScrnHgt: \(f8ScreenHeight)    f8ScrnWdth: \(f8ScreenWidth)")
//            scene?.position = CGPoint(x: view!.bounds.size.width/2, y: 0)
        } else {
            portrait = false
//            f8Metre1 = view!.bounds.size.height/f8ScreenWidth
//            scene?.size.width = 1000 * f8Metre1  //Set screen width = 1,000 metres
//            scene?.size.height = view!.bounds.size.height
//            scene?.position = CGPoint(x: view!.bounds.size.width/2, y: 0)
        }
        
        scene?.backgroundColor = UIColor(red: 0.657, green: 0.657, blue: 0.657, alpha: 1)    //Equivalent colour to image background
//        scene?.backgroundColor = UIColor(red: 0.19, green: 0.38, blue: 0.16, alpha: 1)
//        scene?.zPosition = -5
        scene?.scaleMode = .aspectFill
        physicsWorld.gravity = .zero
        
//        return (km1, sTrackPortrait)
        return ()
    }

    //Create a straight dual carriageway, dual lane 1km long track and orient accordingly
    func createStraightTrack() {
        //blah! blah! blah!
        
        return
    }
    
    func addF8Roads() {
        
        addFig8Image()
        
/*    createF8RoadSurfaces()
    createF8CentreLines()
    createF8InsideLines()
    createF8OutsideLines()
        
    let veh = makeVehicle()
 */
    }
    
    func addFig8Image() {
//        let f8Image: SKSpriteNode = SKSpriteNode(imageNamed: "Fig 8 Track iPad")
        let f8Image: SKSpriteNode = SKSpriteNode(imageNamed: "Fig 8 Track")

        setF8AspectFromHeight(sprite: f8Image, height: 400, metreScale: f8Metre1)  //Sets veh width = 2m (default) & keeps aspect ratio
        let f8Size = f8Image.size
        f8Image.position = CGPoint(x: ((scene?.size.width)! / 2), y: ((scene?.size.height)! / 2))
        
        addChild(f8Image)
    }
    
 func createF8RoadSurfaces() {
 //Create road surfaces
//    var roadLength: CGFloat = 1000.0
//    var roadWidth: CGFloat = 8.0
// var xOffset: CGFloat = ((scene?.size.width)! / 2)     //Centre of screen
// var yOffset: CGFloat = ((scene?.size.height)! / 2)    //Centre of screen
     var xOffset: CGFloat = (roadWidth / 2) + (centreStrip / 2)     //metres
     var yOffset: CGFloat = 0.0  //metres
var zPos: Int = -4
 createF8Line(xOffset: xOffset, yOffset: yOffset, lWidth: roadWidth, lLength: roadLength, colour: SKColor(red: 42/256, green: 41/256, blue: 34/256, alpha: 1), zPos: -4)   //Lay down bitumen
 }

 func createF8CentreLines() {
 //Create centre lines
     var yOffset = 0.0
     let xOffset = (roadWidth / 2) + (centreStrip / 2)     //metres (no change from road surfaces)
//        let numLines: CGFloat = trunc(roadLength / linePeriod)
     let lineSpacing: CGFloat = 1000/83  //where 1000 = track length & 83 = no lines per km
     //let lineLength = 3
//        zPos = -3    //createLine defaults to -3
 for i in 0..<83 {   //83 = no times centre line is drawn per 1km
 yOffset = CGFloat(i) * lineSpacing  //metres
 createF8Line(xOffset: xOffset, yOffset: yOffset, lLength: lineLength)
//            print("Line Spacing = \(yOffset) metres : sMetre1 = \(sMetre1)")
}   //end for loop
 }

 func createF8InsideLines() {
 //Create Inside Lines
     let yOffset = 0.0
     let xOffset = (shoulderLineWidth / 2) + (shoulderWidth) + (centreStrip / 2)     //metres (no change from road surfaces)
//        let roadLength = 1000.0
//        let lWidth = lineWidth    //Default = lineWidth
//        zPos = -3                 //Default = -3
 createF8Line(xOffset: xOffset, yOffset: yOffset, lWidth: shoulderLineWidth, lLength: roadLength)
 }

 func createF8OutsideLines() {
     //Create Outside Lines
     let yOffset = 0.0
     let xOffset = (roadWidth - ((shoulderLineWidth / 2) + (shoulderWidth))) + (centreStrip / 2)
//        let roadLength = 1000.0
//        let lWidth = lineWidth  //Default = lineWidth
//        zPos = -3    //createLine defaults to -3 & colour defaults to white
     createF8Line(xOffset: xOffset, yOffset: yOffset, lWidth: shoulderLineWidth, lLength: roadLength)
 }
 
 func createF8Line(xOffset: CGFloat, yOffset: CGFloat, lWidth: CGFloat = lineWidth, lLength: CGFloat, colour: SKColor = .white, zPos: CGFloat = -3, multiLine: Bool = true) {
     //SKSpriteNode has better performance than SKShape!
     var line1 = SKSpriteNode(color: colour, size: CGSize(width: (lWidth * sMetre1), height: (lLength * sMetre1)))
//        line1.name = "line1A"
     line1.anchorPoint = CGPoint(x: 0.5, y: 0) //Set anchorpoint to middle bottom
//        line1.position = CGPoint(x: size.width/2, y: size.height/2)
     line1.position.y = (yOffset * sMetre1)
     line1.position.x = (size.width / 2) - (xOffset * sMetre1)
     line1.zPosition = zPos
     self.addChild(line1)

     if multiLine {
     var line2 = SKSpriteNode(color: colour, size: CGSize(width: (lWidth * sMetre1), height: (lLength * sMetre1)))
//        line2.name = "line1B"
     line2.anchorPoint = CGPoint(x: 0.5, y: 0) //Set anchorpoint to middle bottom
     line2.position.y = (yOffset * sMetre1)
     line2.position.x = (size.width / 2) + (xOffset * sMetre1)
     line2.zPosition = zPos
     self.addChild(line2)
     }

     return
 }
    
    func getKLVehicles() {
//        let node = "s1Vehicle_1"
//        print("Vehicle 1 Node = \(childNode(withName: "s1Vehicle_1")!)")
//        var node_1 = get_node(
//        let KLVehicle1 = childNode(withName: "s1Vehicle_1")!.copy() as! SKSpriteNode
//        let KLVehicle1: SKNode = childNode(withName: node)!
//        addChild(KLVehicle1)
    }
 
    /*
 func putVehicle() -> SKSpriteNode {
     let veh = SKSpriteNode(imageNamed: "VehicleImage/T1")
     
//     setAspectForWidth(sprite: veh)  //Sets veh width = 2m (default) & keeps aspect ratio
     let vehSize = veh.size
//        veh.position = CGPoint(x: ((view?.bounds.size.width)! / 2.0) - ((5.85 + centreStrip/2) * sMetre1), y: 400.0 * sMetre1)
     veh.zPosition = 1
     veh.physicsBody = SKPhysicsBody(rectangleOf: vehSize)
     veh.physicsBody?.friction = 0
     veh.physicsBody?.restitution = 0
     veh.physicsBody?.linearDamping = 0
     veh.physicsBody?.angularDamping = 0
     veh.physicsBody?.allowsRotation = false
//        addChild(veh)
     
     return veh
 }

 func makeVehicle() -> SKSpriteNode {
     var fName: String = ""
     let maxVehicles: Int = (maxCars+maxTrucks+maxBuses)
     var s1Vehicle: SKSpriteNode = SKSpriteNode(imageNamed: "\(vehImage)C1")
     var s2Vehicle: SKSpriteNode = SKSpriteNode(imageNamed: "\(vehImage)C1")

     for i in 1...numVehicles {
         var randomVehicle = Int.random(in: 1...maxVehicles)
         var vWidth: CGFloat = 2.0   //Car width. Set truck & bus width = 2.5m
         switch randomVehicle {
         case 1...maxCars:
             fName = "C\(randomVehicle)"
         case maxCars...(maxCars+maxTrucks):
             fName = "T\(randomVehicle-maxCars)"
             vWidth = 2.5
         default:
             fName = "B\(randomVehicle-maxCars-maxTrucks)"
             vWidth = 2.5
         }

         vWidth = 2
         s1Vehicle = SKSpriteNode(imageNamed: vehicle + String(fName))
//         setAspectForWidth(sprite: s1Vehicle, width: vWidth)  //Sets veh width = 2m (default) & keeps aspect ratio
         let vehSize = s1Vehicle.size
         
         s1Vehicle.zPosition = 1
         s1Vehicle.name = "s1Vehicle_\(i)"
         s1Vehicle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: vehSize.width, height: vehSize.height + (1 * sMetre1)))   //Make rectangle same size as sprite + 0.5m front and back!
         s1Vehicle.physicsBody?.friction = 0
 //        car1.physicsBody?.affectedByGravity = false
         s1Vehicle.physicsBody?.restitution = 0
         s1Vehicle.physicsBody?.linearDamping = 0
         s1Vehicle.physicsBody?.angularDamping = 0
         s1Vehicle.physicsBody?.allowsRotation = false
         s1Vehicle.physicsBody?.isDynamic = true
//            s1Vehicle.physicsBody?.node?.zRotation = 0.0
//            print("Name = \(s1Vehicle.name!)")
//            print("s1Vehicle Dimensions = \(Int(s1Vehicle.size.width)) wide x \(Int(s1Vehicle.size.height)) long")
//            s1Vehicle.physicsBody?.isDynamic = false   //Prevents reaction to other physics bodies!
         
         addChild(s1Vehicle)

         s2Vehicle = SKSpriteNode(imageNamed: vehicle + String(fName))
//         setAspectForWidth(sprite: s2Vehicle, width: vWidth)  //Sets veh width = 2m (default) & keeps aspect ratio
         let secSize = s2Vehicle.size
         
         s2Vehicle.zPosition = 1
         s2Vehicle.name = "s2Vehicle_\(i)"
         s2Vehicle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: secSize.width, height: secSize.height + (1 * sMetre1)))   //Make rectangle same size as sprite + 0.5m front and back!
         s2Vehicle.physicsBody?.friction = 0
         s2Vehicle.zRotation = CGFloat(Double.pi)  //rotate 180 degrees
 //        car1.physicsBody?.affectedByGravity = false
         s2Vehicle.physicsBody?.restitution = 0
         s2Vehicle.physicsBody?.linearDamping = 0
         s2Vehicle.physicsBody?.angularDamping = 0
         s2Vehicle.physicsBody?.allowsRotation = false
         s2Vehicle.physicsBody?.isDynamic = true
//            s1Vehicle.physicsBody?.node?.zRotation = 0.0
//            print("Name = \(s1Vehicle.name!)")
//            print("s1Vehicle Dimensions = \(Int(s1Vehicle.size.width)) wide x \(Int(s1Vehicle.size.height)) long")
//            s1Vehicle.physicsBody?.isDynamic = false   //Prevents reaction to other physics bodies!
         
         addChild(s2Vehicle)

         s1Vehicle = placeVehicle(s1Vehicle: s1Vehicle, s2Vehicle: s2Vehicle)

//
         t1Stats["Name"]?.append(s1Vehicle.name!)
         t1Stats["Actual Speed"]?.append(0.0)
         if let unwrapped = t1Stats["Name"]?[i] {
             if let speed = t1Stats["Actual Speed"]?[i] {
//                print("Name in Dictionary = \(unwrapped) : Speed = \(speed)")
             
             }
         }
     }
     
//        //Create a sprite 1/3 screen height and width to test scene size & aspect ratio
//        var tmpSprite = SKSpriteNode(color: UIColor(red: 0.8, green: 0.8, blue: 0.1, alpha: 0.4), size: CGSize(width: size.width * (1/3), height: size.height * (1/3)))
//        tmpSprite.position = CGPoint(x: size.width / 2, y: size.height / 2)
//        tmpSprite.zPosition = 2
//        addChild(tmpSprite)

//        //Place red square centre screen surrounded by 4x cyan squares 9m apart for screen check
//        var tmpSprite2 = SKSpriteNode(color: UIColor(red: 1.0, green: 0, blue: 0.1, alpha: 0.6), size: CGSize(width: sMetre1, height: sMetre1))
//        tmpSprite2.position = CGPoint(x: size.width / 2, y: size.height / 2)
//        tmpSprite2.zPosition = 3
//        addChild(tmpSprite2)
//
//        var tmpSprite3 = SKSpriteNode(color: UIColor(red: 0.0, green: 1, blue: 1, alpha: 0.6), size: CGSize(width: sMetre1, height: sMetre1))
//        tmpSprite3.position = CGPoint(x: (size.width / 2) - (4.5 * sMetre1), y: (size.height / 2) + (4.5 * sMetre1))
//        tmpSprite3.zPosition = 3
//        addChild(tmpSprite3)
//
//        var tmpSprite4 = SKSpriteNode(color: UIColor(red: 0.0, green: 1, blue: 1, alpha: 0.6), size: CGSize(width: sMetre1, height: sMetre1))
//        tmpSprite4.position = CGPoint(x: (size.width / 2) + (4.5 * sMetre1), y: (size.height / 2) + (4.5 * sMetre1))
//        tmpSprite4.zPosition = 3
//        addChild(tmpSprite4)
//
//        var tmpSprite5 = SKSpriteNode(color: UIColor(red: 0.0, green: 1, blue: 1, alpha: 0.6), size: CGSize(width: sMetre1, height: sMetre1))
//        tmpSprite5.position = CGPoint(x: (size.width / 2) - (4.5 * sMetre1), y: (size.height / 2) - (4.5 * sMetre1))
//        tmpSprite5.zPosition = 3
//        addChild(tmpSprite5)
//
//        var tmpSprite6 = SKSpriteNode(color: UIColor(red: 0.0, green: 1, blue: 1, alpha: 0.6), size: CGSize(width: sMetre1, height: sMetre1))
//        tmpSprite6.position = CGPoint(x: (size.width / 2) + (4.5 * sMetre1), y: (size.height / 2) - (4.5 * sMetre1))
//        tmpSprite6.zPosition = 3
//        addChild(tmpSprite6)

     //Change size of last vehicle created and place it centre screen
//        s1Vehicle.size = CGSize(width: 150 * sMetre1, height: 300 * sMetre1)
//        s1Vehicle.position = CGPoint(x: (size.width)/2, y: (size.height)/2)

     print("s1Vehicle position 5 = \(s1Vehicle.position)")
     print("sMetre1 = \(sMetre1)")
     print("s1Vehicle anchorPoint = \(s1Vehicle.anchorPoint)")
     return s1Vehicle
 }
 
//Creates and returns a new vehicle
func addVehicleBody() -> SKSpriteNode {
 //blah! blah! blah!

 return sprite
}

/* //Creates and returns a new vehicle c/w front and rear force fields (buffers)
func createVehicle() -> SKSpriteNode {
 
 vBody = addVehicleBody()
///    fBuff = addFrontBuffer()
//    rBuff = addRearBuffer()
 self.addChild(vBody)
 self.addChild(fBuff)

 //Set front join to force field
 let fAnchor = CGPoint(x: 0.5, y: 0.5)   //ANCHOR POSITION YET TO BE SET!!!
 let fJoint = SKPhysicsJointFixed.joint(withBodyA: vBody.physicsBody!, bodyB: fBuff.physicsBody!, anchor: fAnchor)
 physicsWorld.add(fJoint)
 
//    //Set rear join to force field
//    self.addChild(rBuff)
//    let rAnchor = CGPoint(x: 0, y: 0)   //ANCHOR POSITION YET TO BE SET!!!
//    let rJoint = SKPhysicsJointFixed.joint(withBodyA: vBody.physicsBody!, bodyB: rBuff.physicsBody!, anchor: rAnchor)
//    physicsWorld.add(rJoint)

 //blah! blah! blah!

 return sprite
}

//Create and add ALL new randomly selected vehicles to screen. Placement around track is random
func addVehicles() {
 //blah! blah! blah!

 return
} */


//Function will randomly place vehicles onscreen.
 func placeVehicle(s1Vehicle: SKSpriteNode, s2Vehicle: SKSpriteNode) -> SKSpriteNode {
 var spriteClear = false
 var randomPos: CGFloat
 var randomLane: Int
 
 repeat {
     randomPos = CGFloat.random(in: 0..<1000)    //Sets random y position in metres (0 - 999.99999 etc)
     randomLane = Int.random(in: 0...1)          //Sets initial Lane 0 (LHS) or 1 (RHS)
     s1Vehicle.position.y = (randomPos * sMetre1)
     s1Vehicle.position.x = (randomLane == 0) ? (((scene?.size.width)! / 2.0) - (((roadWidth / 2) + (laneWidth / 2) + (lineWidth / 2) + (centreStrip/2)) * sMetre1)) : (((scene?.size.width)! / 2.0) - (((roadWidth / 2) - (laneWidth / 2) - (lineWidth / 2) + (centreStrip/2)) * sMetre1))
     s2Vehicle.position.y = (1000 * sMetre1) - s1Vehicle.position.y
     s2Vehicle.position.x = (randomLane == 0) ? (((scene?.size.width)! / 2.0) + (((roadWidth / 2) + (laneWidth / 2) + (lineWidth / 2) + (centreStrip/2)) * sMetre1)) : (((scene?.size.width)! / 2.0) + (((roadWidth / 2) - (laneWidth / 2) - (lineWidth / 2) + (centreStrip/2)) * sMetre1))
     spriteClear = true
     
     //        veh.position = CGPoint(x: ((view?.bounds.size.width)! / 2.0) - ((5.85 + centreStrip/2) * sMetre1), y: 400.0 * sMetre1)
     //MARK: - Ensure vehicle doesn't overlap existing vehicle!
     for sprite in t1allVehicles {
         if (s1Vehicle.intersects(sprite)) {
             spriteClear = false
         }
     }
 } while !spriteClear
 
 t1allVehicles.append(s1Vehicle)
 t2allVehicles.append(s2Vehicle)
 
 return s1Vehicle
}
     */
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        var transition: SKTransition = SKTransition.fade(withDuration: 2)
//        var scene = StraightTrackScene()
//        self.view?.presentScene(scene)
//    }

//    func setHeightForWidth(sprite: SKSpriteNode, width: CGFloat = 2) -> SKSpriteNode {
 //return sprite not required!
    func setF8AspectFromHeight(sprite: SKSpriteNode, height: CGFloat = f8ScreenHeight, metreScale: CGFloat = f8Metre1) {
     let aspectRatio: CGFloat = sprite.size.height/sprite.size.width
//        print(" aspectAFHRatio = \(aspectRatio)")
        sprite.size = CGSize(width: ((height * metreScale) / aspectRatio), height: (height * metreScale))
//        return sprite
 }
 
    func setF8AspectFromWidth(sprite: SKSpriteNode, width: CGFloat = f8ScreenWidth, metreScale: CGFloat = f8Metre1) {
     let aspectRatio: CGFloat = sprite.size.height/sprite.size.width
//        print(" aspectAFWRatio = \(aspectRatio)")
        sprite.size = CGSize(width: (width * metreScale), height: (width * metreScale * aspectRatio))
//        return sprite
 }
 
}

