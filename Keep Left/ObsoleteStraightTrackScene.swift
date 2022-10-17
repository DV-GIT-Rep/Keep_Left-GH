/*
//
//  StraightTrackScene.swift
//  Keep Left
//
//  Created by Bill Drayton on 13/1/22.
//

import Foundation
import SpriteKit
import GameKit
//import SwiftUI

class StraightTrackScene: SKScene {
    
//    let background = SKSpriteNode(imageNamed: "Fig 8 Track iPad")
    let background = SKSpriteNode(color: SKColor(red: 180/255, green: 180/255, blue: 180/255, alpha: 0.8), size: CGSize(width: 500, height: 1000)) //Grey background
    let car1 = SKSpriteNode(imageNamed: "VehicleImage/C3")
    let car2 = SKSpriteNode(imageNamed: "VehicleImage/C5")
    let car3 = SKSpriteNode(imageNamed: "VehicleImage/C6")
    let car4 = SKSpriteNode(imageNamed: "VehicleImage/C2")

    override func didMove(to view: SKView) {
        sKLAllVehicles.removeAll()
        
        self.view?.ignoresSiblingOrder = true   //Faster: use zPosition for layering

        scene?.size = view.bounds.size
        scene?.scaleMode = .aspectFill
        physicsWorld.gravity = .zero
        
        //Add background
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
//        background.setScale(2)
        background.aspectFitToSize(scrnSize: size)
        addChild(background)
        /*
        //Track 1
        //Add Car1
        car1.position = CGPoint(x: (size.width/2 - 200), y: 100)
        car1.zPosition = 1
        car1.size = CGSize(width: 50, height: 110)
//        car1.physicsBody = SKPhysicsBody(texture: car1.texture!, size: car1.texture!.size())    //SpriteKit creates size/shape
        car1.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 110))   //Make rectangle same size as sprite!
        car1.physicsBody?.friction = 0
//        car1.physicsBody?.affectedByGravity = false
        car1.physicsBody?.restitution = 0
        car1.physicsBody?.linearDamping = 0
        car1.physicsBody?.angularDamping = 0
        car1.physicsBody?.allowsRotation = true
        addChild(car1)
        
//        car1.physicsBody?.node?.speed = 2500
        car1.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 150))

        //Add Car2
        car2.position = CGPoint(x: (size.width/2 - 110), y: 200)
        car2.zPosition = 1
        car2.size = CGSize(width: 50, height: 110)
        addChild(car2)

        //Track 2
        //Add Car3
        car3.position = CGPoint(x: (size.width/2 + 110), y: 200)
        car3.zPosition = 1
        car3.size = CGSize(width: 50, height: 110)
        car3.zRotation = .pi          //Rotate 180'
        addChild(car3)

        //Add Car4
        car4.position = CGPoint(x: (size.width/2 + 200), y: 200)
        car4.zPosition = 1
        car4.size = CGSize(width: 50, height: 110)
        car4.zRotation = .pi          //Rotate 180'
        addChild(car4)
        
         */
//        makeVehicle()
    }
    
    override func update(_ currentTime: TimeInterval) {
        for vehicle in sKLAllVehicles {
            if vehicle.position.y >= (1000 * sMetre1) {
                vehicle.position.y = (vehicle.position.y - 1000)
            }
        }
    }
    
/*    func makeVehicle() {
        var fName: String = ""
        let maxVehicles: Int = (maxCars+maxTrucks+maxBuses)
        
        for i in 1...numVehicles {
//            for i in 1...1 {
            var randomVehicle = Int.random(in: 1...maxVehicles)
    //        fName = {
            switch randomVehicle {
            case 1...maxCars:
                fName = "C\(randomVehicle)"
            case maxCars...(maxCars+maxTrucks):
                fName = "T\(randomVehicle-maxCars)"
            default:
                fName = "B\(randomVehicle-maxCars-maxTrucks)"
            }
    //        }()
            let sKLVehicle = SKSpriteNode(imageNamed: vehicle + String(fName))
//            sKLVehicle.name = "Vehicle \(i) Type \(fName)"
            sKLVehicle.name = "stKL_\(i)"
//            sKLVehicle.position = CGPoint(x: size.width / 2, y: 300)
            sKLVehicle.scale(to: CGSize(width: 50, height: 110))
            sKLVehicle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 110))   //Make rectangle same size as sprite!
            sKLVehicle.physicsBody?.friction = 0
    //        car1.physicsBody?.affectedByGravity = false
            sKLVehicle.physicsBody?.restitution = 0
            sKLVehicle.physicsBody?.linearDamping = 0
            sKLVehicle.physicsBody?.angularDamping = 0
            sKLVehicle.physicsBody?.allowsRotation = false
//            sKLVehicle.physicsBody?.isDynamic = false
//            print("Name = \(sKLVehicle.name!)")
//            print("sKLVehicle Dimensions = \(Int(sKLVehicle.size.width)) wide x \(Int(sKLVehicle.size.height)) long")
//            sKLVehicle.physicsBody?.isDynamic = false   //Prevents reaction to other physics bodies!
            
                placeVehicle(sKLVehicle: sKLVehicle)

            t1Stats["Name"]?.append(sKLVehicle.name!)
            t1Stats["Actual Speed"]?.append(0.0)
            if let unwrapped = t1Stats["Name"]?[i] {
                if let speed = t1Stats["Actual Speed"]?[i] {
                print("Name in Dictionary = \(unwrapped) : Speed = \(speed)")
                
                    let frontBuffer = addFrontBuffer(sKLVehicle: sKLVehicle, speed: speed as! Double, i: i)
                    addChild(frontBuffer)
                    
//                    print(<#T##items: Any...##Any#>)
                    
//                    let fJoint = SKPhysicsJointFixed.joint(withBodyA: sKLVehicle.physicsBody!, bodyB: frontBuffer.physicsBody!, anchor: sKLVehicle.position)
//                    self.physicsWorld.add(fJoint)
                    
                    
                    sKLVehicle.position = CGPoint(x: 500, y: 100)
//                    sKLVehicle.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 80))

                    let Vehicle1 = childNode(withName: "sKLVehicle_1")
                    if childNode(withName: "sKLVehicle_2") != nil {
                        Vehicle1?.position = CGPoint(x: 500, y: 600)
                        sKLVehicle.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 150))
//                        sKLVehicle.physicsBody?.isDynamic = false

                        let thisNode = childNode(withName: "fBuff_2")
                        let action = SKAction.resize(toHeight: 100, duration: 6)
                        let actionBlock = SKAction.run({
                            thisNode!.run(action)
                            thisNode!.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: thisNode!.frame.size.width, height: thisNode!.frame.size.height))   //Make rectangle same size as sprite!
//                            thisNode!.anchorPoint = CGPoint(x: 0.5, y:0)
                            thisNode!.position = CGPoint(x: sKLVehicle.position.x, y: sKLVehicle.position.y + sKLVehicle.size.height / 2)
                            let fJoint = SKPhysicsJointFixed.joint(withBodyA: sKLVehicle.physicsBody!, bodyB: frontBuffer.physicsBody!, anchor: sKLVehicle.position)
                            self.physicsWorld.add(fJoint)
                        })
                        thisNode?.run(actionBlock)

                    }

                }}
            
//            joint
            
//        vehicleStats = ["Name": String, "Actual Speed": CGFloat, "Intended Speed": CGFloat, "Speed Limited": Bool, "Algorithm": Int]()

//            Image(vehicle + String(fName))
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 50)   //Set vehicle width = 2m for cars and 2.5m for trucks and buses
        }

    }   */
    
    func placeVehicle(sKLVehicle: SKSpriteNode) {
        var spriteClear = false
        var randomPos: CGFloat
        var randomLane: Int
/*
        repeat {
            randomPos = CGFloat.random(in: 0..<1000)
            randomLane = Int.random(in: 0...1)
            sKLVehicle.position.y = (randomPos / 1000) * (size.height * 2)
            sKLVehicle.position.x = (size.width / 2) + CGFloat(randomLane * 100)
            spriteClear = true
            
            //MARK: - Ensure vehicle doesn't overlap existing vehicle!
            for sprite in awlVehicles {
                if (sKLVehicle.intersects(sprite)) {
                    spriteClear = false
                }
            }
        } while !spriteClear
*/
        sKLAllVehicles.append(sKLVehicle)
        addChild(sKLVehicle)
        
//        sKLVehicle.physicsBody?.applyImpulse(CGVector(dx: 0, dy: randomLane == 0 ? 80 : 120))
        
    }
    
 /*   func addFrontBuffer(sKLVehicle: SKSpriteNode, speed: Double, i: Int) -> SKSpriteNode {
        //frontBuffer.size.height = (kph/1.2 + 1) metres
        let frontBuffer = SKSpriteNode(color: UIColor(red: 1, green: 1, blue: 0.1, alpha: fBuffVisible ? 0.2 : 0), size: CGSize(width: sKLVehicle.size.width, height: ((speed/1.2)*(sKLVehicle.size.width/2))+(sKLVehicle.size.width/2)))
        frontBuffer.name = "fBuff_\(i)"
        frontBuffer.anchorPoint = CGPoint(x: 0.5, y:0)
        frontBuffer.position = CGPoint(x: 0, y: 58)
        frontBuffer.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 110))   //Make rectangle same size as sprite!
        frontBuffer.zPosition = 10
        frontBuffer.physicsBody?.friction = 0
        frontBuffer.physicsBody?.restitution = 0
        frontBuffer.physicsBody?.linearDamping = 0
        frontBuffer.physicsBody?.angularDamping = 0
//        frontBuffer.physicsBody?.allowsRotation = false
//        frontBuffer.physicsBody?.isDynamic = false
        return frontBuffer
    }   */
    
}

extension SKSpriteNode {
    
    //MARK: - FUNCTION TO SCALE BACKGROUND IMAGE TO FILL VIEW
    func aspectFillToSize(scrnSize: CGSize) {
        let background = self
        
        let hRatio = scrnSize.width / background.size.width
        let vRatio = scrnSize.height / background.size.height
        let fillRatio = hRatio < vRatio ? vRatio : hRatio
        size = CGSize(width: background.size.width *  fillRatio, height: background.size.height * fillRatio)
    }
    
    //MARK: - FUNCTION TO SCALE BACKGROUND IMAGE TO FIT VIEW
    func aspectFitToSize(scrnSize: CGSize) {
        let background = self
        
        let hRatio = scrnSize.width / background.size.width
        let vRatio = scrnSize.height / background.size.height
        let fitRatio = hRatio < vRatio ? hRatio : vRatio
        size = CGSize(width: background.size.width *  fitRatio, height: background.size.height * fitRatio)
    }
}

*/
