//
//  Fig8Scene.swift
//  Keep Left
//
//  Created by Bill Drayton on 25/2/2022.
//

import Foundation
import SpriteKit
import SwiftUI

class Fig8Scene: SKScene, SKPhysicsContactDelegate {
    
    var f8Scene = SceneModel()

    override func didMove(to view: SKView) {
        
        
        //MARK: - Create background colour width: screenwidth height: 1km. Define sMetre1 = multiplier for metres to points
//        calcF8Size()
        
        f8Scene.calcF8Scene(f8Size: view.bounds.size)
//        portrait = f8Scene.portrait
        f8Metre1 = f8Scene.metre1
        f8SceneWidth = f8Scene.width
        f8SceneHeight = f8Scene.height
        scene?.size.width = f8SceneWidth
        scene?.size.height = f8SceneHeight

        
        //MARK: - Add 2x figure 8 roads to StraightTrackScene
        addF8Roads()
        
        get_KLVehicles()
        
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
////        guard let touch = touches.first else {return}   //Exit if not first touch!
////        toggleSpeed = 2 ZZZ
//        var transition: SKTransition = SKTransition.fade(withDuration: 2)
//        var scene = StraightTrackScene()
//        self.view?.presentScene(scene, transition: transition)
//    }

    
    //Create a straight dual carriageway, dual lane 1km long track and orient accordingly
    func createStraightTrack() {
        //blah! blah! blah!
        return
    }
    
    func addF8Roads() {
        
        addFig8Image()
        
    }
    
    func addFig8Image() {
        let f8Image: SKSpriteNode = SKSpriteNode(imageNamed: "Fig 8 Track")

        setF8AspectFromHeight(sprite: f8Image, height: 400, metreScale: f8Metre1)  //Sets veh width = 2m (default) & keeps aspect ratio
        let f8Size = f8Image.size
        f8Image.position = CGPoint(x: ((scene?.size.width)! / 2), y: ((scene?.size.height)! / 2))
        
        addChild(f8Image)
    }
    
// func createF8RoadSurfaces() {
////    var roadLength: CGFloat = 1000.0
////    var roadWidth: CGFloat = 8.0
//// var xOffset: CGFloat = ((scene?.size.width)! / 2)     //Centre of screen
//// var yOffset: CGFloat = ((scene?.size.height)! / 2)    //Centre of screen
//     var xOffset: CGFloat = (roadWidth / 2) + (centreStrip / 2)     //metres
//     var yOffset: CGFloat = 0.0  //metres
//var zPos: Int = -4
// createF8Line(xOffset: xOffset, yOffset: yOffset, lWidth: roadWidth, lLength: roadLength, colour: SKColor(red: 42/256, green: 41/256, blue: 34/256, alpha: 1), zPos: -4)   //Lay down bitumen
// }
//
//    func createF8CentreLines() {
//        var yOffset = 0.0
//        let xOffset = (roadWidth / 2) + (centreStrip / 2)     //metres (no change from road surfaces)
////        let numLines: CGFloat = trunc(roadLength / linePeriod)
//        let lineSpacing: CGFloat = 1000/83  //where 1000 = track length & 83 = no lines per km
////let lineLength = 3
////        zPos = -3    //createLine defaults to -3
//        for i in 0..<83 {   //83 = no times centre line is drawn per 1km
//            yOffset = CGFloat(i) * lineSpacing  //metres
//            createF8Line(xOffset: xOffset, yOffset: yOffset, lLength: lineLength)
////            print("Line Spacing = \(yOffset) metres : sMetre1 = \(sMetre1)")
//        }   //end for loop
//    }
//
// func createF8InsideLines() {
//     let yOffset = 0.0
//     let xOffset = (shoulderLineWidth / 2) + (shoulderWidth) + (centreStrip / 2)     //metres (no change from road surfaces)
////        let roadLength = 1000.0
////        let lWidth = lineWidth    //Default = lineWidth
////        zPos = -3                 //Default = -3
// createF8Line(xOffset: xOffset, yOffset: yOffset, lWidth: shoulderLineWidth, lLength: roadLength)
// }
//
// func createF8OutsideLines() {
//     let yOffset = 0.0
//     let xOffset = (roadWidth - ((shoulderLineWidth / 2) + (shoulderWidth))) + (centreStrip / 2)
////        let roadLength = 1000.0
////        let lWidth = lineWidth  //Default = lineWidth
////        zPos = -3    //createLine defaults to -3 & colour defaults to white
//     createF8Line(xOffset: xOffset, yOffset: yOffset, lWidth: shoulderLineWidth, lLength: roadLength)
// }
 
// func createF8Line(xOffset: CGFloat, yOffset: CGFloat, lWidth: CGFloat = lineWidth, lLength: CGFloat, colour: SKColor = .white, zPos: CGFloat = -3, multiLine: Bool = true) {
//     //SKSpriteNode has better performance than SKShape!
//     var line1 = SKSpriteNode(color: colour, size: CGSize(width: (lWidth * sMetre1), height: (lLength * sMetre1)))
////        line1.name = "line1A"
//     line1.anchorPoint = CGPoint(x: 0.5, y: 0) //Set anchorpoint to middle bottom
////        line1.position = CGPoint(x: size.width/2, y: size.height/2)
//     line1.position.y = (yOffset * sMetre1)
//     line1.position.x = (size.width / 2) - (xOffset * sMetre1)
//     line1.zPosition = zPos
//     self.addChild(line1)
//
//     if multiLine {
//     var line2 = SKSpriteNode(color: colour, size: CGSize(width: (lWidth * sMetre1), height: (lLength * sMetre1)))
////        line2.name = "line1B"
//     line2.anchorPoint = CGPoint(x: 0.5, y: 0) //Set anchorpoint to middle bottom
//     line2.position.y = (yOffset * sMetre1)
//     line2.position.x = (size.width / 2) + (xOffset * sMetre1)
//     line2.zPosition = zPos
//     self.addChild(line2)
//     }
//
//     return
// }
    
    func get_KLVehicles() {
//        let node = "sKLVehicle_1"
//        print("Vehicle 1 Node = \(childNode(withName: "sKLVehicle_1")!)")
//        var node_1 = get_node(
//        let KLVehicle1 = childNode(withName: "sKLVehicle_1")!.copy() as! SKSpriteNode
//        let KLVehicle1: SKNode = childNode(withName: node)!
//        addChild(KLVehicle1)
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        var transition: SKTransition = SKTransition.fade(withDuration: 2)
//        var scene = StraightTrackScene()
//        self.view?.presentScene(scene)
//    }

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
 
}       //end of Fig8Scene
