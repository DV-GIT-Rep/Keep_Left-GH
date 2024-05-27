//  26 May 2024

//public func createTrackLabels(labelParent: SKNode, topLabel: Bool) {
//    
//    let titleColour: SKColor = SKColor(red: 0, green: 0.12, blue: 0, alpha: 1)              //"Keep Left" or "Keep Right"
//    let spdTitleColour: SKColor = SKColor(red: 0, green: 0.12, blue: 0, alpha: 1)           //"Avg Spd", "Avg Distance" & data
//    let spdSubTitleColour: SKColor = SKColor(red: 0.26, green: 0.4, blue: 0.26, alpha: 1)   //"Min" & "Max" text & data
//    
//    f8KLLabelTitle.text = "\(kLTitle)"
//    f8KLLabelTitle.name = "line1"
//    f8KLLabelTitle.fontSize = 17
//    f8KLLabelTitle.fontColor = titleColour
//    f8KLLabelTitle.horizontalAlignmentMode = .center
//    f8KLLabelTitle.position = CGPoint(x: 0, y: 0.25 * f8CircleCentre)
//    labelParent.addChild(f8KLLabelTitle)
//    
//    f8KLLabelDescription.fontSize = 8.6
//    f8KLLabelDescription.horizontalAlignmentMode = .center
//    f8KLLabelDescription.position = CGPoint(x: 0, y: 0.13 * f8CircleCentre)
//    labelParent.addChild(f8KLLabelDescription)
//    
//    avgSpdDesc.text = "Avg Speed"
//    avgSpdDesc.fontSize = 7.8
//    avgSpdDesc.fontColor = UIColor(displayP3Red: 0.85, green: 0.9, blue: 0.7, alpha: 1)
//    avgSpdDesc.horizontalAlignmentMode = .right
//    avgSpdDesc.position = CGPoint(x: -0.01 * f8CircleCentre, y: 0.025 * f8CircleCentre)
//    labelParent.addChild(avgSpdDesc)
//    
//    var maxSpdDesc = SKLabelNode(text: "Max Speed")
//    maxSpdDesc.fontSize = 7.8
//    maxSpdDesc.fontName = "Helvetica Neue Light"
//    maxSpdDesc.fontColor = spdSubTitleColour
//    maxSpdDesc.horizontalAlignmentMode = .right
//    maxSpdDesc.position = CGPoint(x: -0.01 * f8CircleCentre, y: -0.06 * f8CircleCentre)
//    labelParent.addChild(maxSpdDesc)
//    
//    var minSpdDesc = SKLabelNode(text: "Min Speed")
//    minSpdDesc.fontSize = 7.8
//    minSpdDesc.fontName = "Helvetica Neue Light"
//    minSpdDesc.fontColor = spdSubTitleColour
//    minSpdDesc.horizontalAlignmentMode = .right
//    minSpdDesc.position = CGPoint(x: -0.01 * f8CircleCentre, y: -0.145 * f8CircleCentre)
//    labelParent.addChild(minSpdDesc)
//    
//    avgDistanceDesc.fontSize = 7.8
//    avgDistanceDesc.fontColor = UIColor(displayP3Red: 0.85, green: 0.9, blue: 0.7, alpha: 1)
//    avgDistanceDesc.horizontalAlignmentMode = .right
//    avgDistanceDesc.position = CGPoint(x: -0.01 * f8CircleCentre, y: -0.23 * f8CircleCentre)
//    labelParent.addChild(avgDistanceDesc)
//    
//    maxDistanceDesc.fontSize = 7.8
//    maxDistanceDesc.fontName = f8DisplayDat == 0 ? "Helvetica Neue Light" : "Helvetica Neue Medium"
//    maxDistanceDesc.fontColor = f8DisplayDat == 0 ? spdSubTitleColour : spdTitleColour
//    maxDistanceDesc.horizontalAlignmentMode = .right
//    maxDistanceDesc.position = CGPoint(x: -0.01 * f8CircleCentre, y: -0.315 * f8CircleCentre)
//    labelParent.addChild(maxDistanceDesc)
//    
//    minDistanceDesc.fontSize = 7.8
//    minDistanceDesc.fontColor = spdSubTitleColour
//    minDistanceDesc.horizontalAlignmentMode = .right
//    minDistanceDesc.position = CGPoint(x: -0.01 * f8CircleCentre, y: -0.4 * f8CircleCentre)
//    labelParent.addChild(minDistanceDesc)
//    
//    var avgSpeed: CGFloat = CGFloat.random(in: 105...130)    //TEMP !!! Replace by actual reading !!!
//    
//    var maxSpeed = avgSpeed * 1.2   //TEMP
//    var minSpeed = avgSpeed * 0.76  //TEMP !!!
//    
//    avgSpd.fontSize = 7.8
//    avgSpd.fontColor = UIColor(displayP3Red: 0.6, green: 1, blue: 0.67, alpha: 1)
//    avgSpd.horizontalAlignmentMode = .left
//    avgSpd.position = CGPoint(x: -0.005 * f8CircleCentre, y: 0.025 * f8CircleCentre)
//    labelParent.addChild(avgSpd)
//    
//    maxSpd.fontSize = 7.8
//    maxSpd.fontColor = spdSubTitleColour
//    maxSpd.horizontalAlignmentMode = .left
//    maxSpd.position = CGPoint(x: -0.005 * f8CircleCentre, y: -0.06 * f8CircleCentre)
//    labelParent.addChild(maxSpd)
//    
//    minSpd.fontSize = 7.8
//    minSpd.fontColor = spdSubTitleColour
//    minSpd.horizontalAlignmentMode = .left
//    minSpd.position = CGPoint(x: -0.005 * f8CircleCentre, y: -0.145 * f8CircleCentre)
//    labelParent.addChild(minSpd)
//    
//    avgDistance.fontSize = 7.8
//    avgDistance.fontName = "Helvetica Neue Medium"
//    avgDistance.fontColor = UIColor(displayP3Red: 0.6, green: 1, blue: 0.67, alpha: 1)
//    avgDistance.horizontalAlignmentMode = .left
//    avgDistance.position = CGPoint(x: -0.005 * f8CircleCentre, y: -0.23 * f8CircleCentre)
//    labelParent.addChild(avgDistance)
//    
//    maxDistance.fontSize = 7.8
//    maxDistance.fontName = f8DisplayDat == 0 ? "Helvetica Neue Light" : "Helvetica Neue Medium"
//    maxDistance.fontColor = f8DisplayDat == 0 ? spdSubTitleColour : spdTitleColour
//    maxDistance.horizontalAlignmentMode = .left
//    maxDistance.position = CGPoint(x: -0.005 * f8CircleCentre, y: -0.315 * f8CircleCentre)
//    labelParent.addChild(maxDistance)
//    
//    minDistance.fontSize = 7.8
//    minDistance.fontColor = spdSubTitleColour
//    minDistance.horizontalAlignmentMode = .left
//    minDistance.position = CGPoint(x: -0.005 * f8CircleCentre, y: -0.4 * f8CircleCentre)
//    labelParent.addChild(minDistance)
//}
