//
//  createTrackLabels.swift
//  Keep Left
//
//  Created by Bill Drayton on 9/8/2022.
//

import SpriteKit

////MARK: - Add Keep Left labelNode
//public func createTrackLabels(labelParent: SKNode, whichLabel: LabelData) {
//    
//    let titleColour: SKColor = SKColor(red: 0, green: 0.12, blue: 0, alpha: 1)              //"Keep Left" or "Keep Right"
//    let subTitleColour: SKColor = SKColor(red: 0.15, green: 0.3, blue: 0.15, alpha: 1)      //"All vehicles" or "Vehicle x"
//    let spdTitleColour: SKColor = SKColor(red: 0, green: 0.12, blue: 0, alpha: 1)           //"Avg Spd", "Avg Distance" & data
//    let spdSubTitleColour: SKColor = SKColor(red: 0.26, green: 0.4, blue: 0.26, alpha: 1)   //"Min" & "Max" text & data
//    
//var f8KLLabelTitle = SKLabelNode(text: topLabel ? "Keep \(Left)" : "Other")
//f8KLLabelTitle.fontSize = 17
//f8KLLabelTitle.fontName = "Helvetica Neue Bold"
//f8KLLabelTitle.fontColor = titleColour
////            f8KLLabelTitle.zPosition = 0
//f8KLLabelTitle.horizontalAlignmentMode = .center
//f8KLLabelTitle.position = CGPoint(x: 0, y: 0.25 * f8CircleCentre)
//    labelParent.addChild(f8KLLabelTitle)
//
//    var f8KLLabelDescription = SKLabelNode(text: "\(allVehicles)")
////    var f8KLLabelDescription = SKLabelNode(text: "All Vehicles")
//f8KLLabelDescription.fontSize = 8.6
//f8KLLabelDescription.fontName = "Chalkduster"
//f8KLLabelDescription.fontColor = subTitleColour
////            f8KLLabelDescription.zPosition = 0
//f8KLLabelDescription.horizontalAlignmentMode = .center
//f8KLLabelDescription.position = CGPoint(x: 0, y: 0.13 * f8CircleCentre)
//    labelParent.addChild(f8KLLabelDescription)
//    
//var avgSpdDesc = SKLabelNode(text: "Avg Speed")
//avgSpdDesc.fontSize = 7.8
//avgSpdDesc.fontName = "Helvetica Neue Medium"
//avgSpdDesc.fontColor = spdTitleColour
////            avgSpdDesc.zPosition = 0
//avgSpdDesc.horizontalAlignmentMode = .right
//avgSpdDesc.position = CGPoint(x: -0.0 * f8CircleCentre, y: 0.025 * f8CircleCentre)
//    labelParent.addChild(avgSpdDesc)
//
//var maxSpdDesc = SKLabelNode(text: "Max Speed")
//maxSpdDesc.fontSize = 7.8
//maxSpdDesc.fontName = "Helvetica Neue Light"
//maxSpdDesc.fontColor = spdSubTitleColour
////            maxSpdDesc.zPosition = 0
//maxSpdDesc.horizontalAlignmentMode = .right
//maxSpdDesc.position = CGPoint(x: -0.0 * f8CircleCentre, y: -0.06 * f8CircleCentre)
//    labelParent.addChild(maxSpdDesc)
//
//var minSpdDesc = SKLabelNode(text: "Min Speed")
//minSpdDesc.fontSize = 7.8
//minSpdDesc.fontName = "Helvetica Neue Light"
//minSpdDesc.fontColor = spdSubTitleColour
////            minSpdDesc.zPosition = 0
//minSpdDesc.horizontalAlignmentMode = .right
//minSpdDesc.position = CGPoint(x: -0.0 * f8CircleCentre, y: -0.145 * f8CircleCentre)
//    labelParent.addChild(minSpdDesc)
//
//var avgDistanceDesc = SKLabelNode(text: "Avg \(Km)")
//avgDistanceDesc.fontSize = 7.8
//avgDistanceDesc.fontName = "Helvetica Neue Medium"
//avgDistanceDesc.fontColor = spdTitleColour
////            avgDistanceDesc.zPosition = 0
//avgDistanceDesc.horizontalAlignmentMode = .right
//avgDistanceDesc.position = CGPoint(x: -0.0 * f8CircleCentre, y: -0.23 * f8CircleCentre)
//    labelParent.addChild(avgDistanceDesc)
//
//var maxDistanceDesc = SKLabelNode(text: "Max \(Km)")
//maxDistanceDesc.fontSize = 7.8
//maxDistanceDesc.fontName = "Helvetica Neue Light"
//maxDistanceDesc.fontColor = spdSubTitleColour
////            maxDistanceDesc.zPosition = 0
//maxDistanceDesc.horizontalAlignmentMode = .right
//maxDistanceDesc.position = CGPoint(x: -0.0 * f8CircleCentre, y: -0.315 * f8CircleCentre)
//    labelParent.addChild(maxDistanceDesc)
//
//var minDistanceDesc = SKLabelNode(text: "Min \(Km)")
//minDistanceDesc.fontSize = 7.8
//minDistanceDesc.fontName = "Helvetica Neue Light"
//minDistanceDesc.fontColor = spdSubTitleColour
////            minDistanceDesc.zPosition = 0
//minDistanceDesc.horizontalAlignmentMode = .right
//minDistanceDesc.position = CGPoint(x: -0.0 * f8CircleCentre, y: -0.4 * f8CircleCentre)
//    labelParent.addChild(minDistanceDesc)
//
////            var avgSpeed = CGFloat(108)     //TEMP !!! Replace by actual reading !!!
//var avgSpeed: CGFloat = CGFloat.random(in: 105...130)    //TEMP !!! Replace by actual reading !!!
//
//var maxSpeed = avgSpeed * 1.2   //TEMP
//var minSpeed = avgSpeed * 0.76  //TEMP !!!
//    
////    var nameKL = sKLAllVehicles[2].name
////    
////    var sumKL: CGFloat = sKLAllVehicles[0].physicsBody!.velocity.dy
////    print("sumKL: \(sumKL * 3.6)")
//
//var avgSpd = SKLabelNode(text: "\(round(avgSpeed)) \(kph)")
////var avgSpd = SKLabelNode(text: "\(round(avgSpeed)) \(kph)")
//avgSpd.fontSize = 7.8
//avgSpd.fontName = "Helvetica Neue Medium"
//avgSpd.fontColor = spdTitleColour
////            avgSpd.zPosition = 0
//avgSpd.horizontalAlignmentMode = .left
//avgSpd.position = CGPoint(x: 0.01 * f8CircleCentre, y: 0.025 * f8CircleCentre)
//    labelParent.addChild(avgSpd)
//
//var maxSpd = SKLabelNode(text: "\(round(maxSpeed)) \(kph)")
//maxSpd.fontSize = 7.8
//maxSpd.fontName = "Helvetica Neue Light"
//maxSpd.fontColor = spdSubTitleColour
////            maxSpd.zPosition = 0
//maxSpd.horizontalAlignmentMode = .left
//maxSpd.position = CGPoint(x: 0.01 * f8CircleCentre, y: -0.06 * f8CircleCentre)
//    labelParent.addChild(maxSpd)
//
//var minSpd = SKLabelNode(text: "\(round(minSpeed)) \(kph)")
//minSpd.fontSize = 7.8
//minSpd.fontName = "Helvetica Neue Light"
//minSpd.fontColor = spdSubTitleColour
////            minSpd.zPosition = 0
//minSpd.horizontalAlignmentMode = .left
//minSpd.position = CGPoint(x: 0.01 * f8CircleCentre, y: -0.145 * f8CircleCentre)
//    labelParent.addChild(minSpd)
//
////var avgDistance = SKLabelNode(text: "325,428")
//    var avgDistance = SKLabelNode(text: "\((sKLAllVehicles[17].distance + 103.0).dp2)")
//avgDistance.fontSize = 7.8
//avgDistance.fontName = "Helvetica Neue Medium"
//avgDistance.fontColor = spdTitleColour
////            avgDistance.zPosition = 0
//avgDistance.horizontalAlignmentMode = .left
//avgDistance.position = CGPoint(x: 0.01 * f8CircleCentre, y: -0.23 * f8CircleCentre)
//    labelParent.addChild(avgDistance)
//
//var maxDistance = SKLabelNode(text: "478,414")
//maxDistance.fontSize = 7.8
//maxDistance.fontName = "Helvetica Neue Light"
//maxDistance.fontColor = spdSubTitleColour
////            maxDistance.zPosition = 0
//maxDistance.horizontalAlignmentMode = .left
//maxDistance.position = CGPoint(x: 0.01 * f8CircleCentre, y: -0.315 * f8CircleCentre)
//    labelParent.addChild(maxDistance)
//
//var minDistance = SKLabelNode(text: "18,233,826")
//minDistance.fontSize = 7.8
//minDistance.fontName = "Helvetica Neue Light"
//minDistance.fontColor = spdSubTitleColour
////            minDistance.zPosition = 0
//minDistance.horizontalAlignmentMode = .left
//minDistance.position = CGPoint(x: 0.01 * f8CircleCentre, y: -0.4 * f8CircleCentre)
//    labelParent.addChild(minDistance)
//    
////    StraightTrackScene.updateF8Labels()
//
//}
