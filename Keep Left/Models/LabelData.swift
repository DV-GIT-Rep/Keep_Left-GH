//
//  LabelData.swift
//  Keep Left
//
//  Created by Bill Drayton on 13/8/2022.
//

import SpriteKit
import Combine

class LabelData: SKLabelNode, ObservableObject {
    
    override init() {
//        var texture = SKTexture(imageNamed: "runIcon")
        super.init()
//        super.init(texture: texture, color: UIColor.clear, size: texture.size())

        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Variables for the figure 8 labels
    @Published var kLTitle: String = "Keep \(Left)"
//    @Published var allVehicles: String = "All Vehicles"
//    @Published var avgSpeed: CGFloat = 0.0
//    @Published var maxSpeed: CGFloat = 0.0
//    @Published var minSpeed: CGFloat = 0.0
//    @Published var avgDistance: CGFloat = 0.0
//    @Published var maxDistance: CGFloat = 0.0
//    @Published var minDistance: CGFloat = 0.0
    
    @Published var f8KLLabelTitle = SKLabelNode(fontNamed: "Helvetica Neue Bold")
    @Published var f8KLLabelDescription = SKLabelNode(fontNamed: "Chalkduster")
    
    @Published var avgSpdDesc = SKLabelNode(fontNamed: "Helvetica Neue Medium")
    @Published var maxSpdDesc = SKLabelNode(fontNamed: "Helvetica Neue Light")
    @Published var minSpdDesc = SKLabelNode(fontNamed: "Helvetica Neue Light")
    
    @Published var avgDistanceDesc = SKLabelNode(fontNamed: "Helvetica Neue Medium")
    @Published var maxDistanceDesc = SKLabelNode(fontNamed: "Helvetica Neue Light")
    @Published var minDistanceDesc = SKLabelNode(fontNamed: "Helvetica Neue Light")
    
    @Published var avgSpd = SKLabelNode(fontNamed: "Helvetica Neue Medium")
    @Published var maxSpd = SKLabelNode(fontNamed: "Helvetica Neue Light")
    @Published var minSpd = SKLabelNode(fontNamed: "Helvetica Neue Light")
    
    @Published var avgDistance = SKLabelNode(fontNamed: "Helvetica Neue Medium")
    @Published var maxDistance = SKLabelNode(fontNamed: "Helvetica Neue Light")
    @Published var minDistance = SKLabelNode(fontNamed: "Helvetica Neue Light")

    let subTitleColour: SKColor = SKColor(red: 0.15, green: 0.3, blue: 0.15, alpha: 1)      //"All vehicles" or "Vehicle x"

    let titleColour: SKColor = SKColor(red: 0, green: 0.12, blue: 0, alpha: 1)              //"Keep Left" or "Keep Right"
//        let subTitleColour: SKColor = SKColor(red: 0.15, green: 0.3, blue: 0.15, alpha: 1)      //"All vehicles" or "Vehicle x"
    let spdTitleColour: SKColor = SKColor(red: 0, green: 0.12, blue: 0, alpha: 1)           //"Avg Spd", "Avg Distance" & data
    let spdSubTitleColour: SKColor = SKColor(red: 0.26, green: 0.4, blue: 0.26, alpha: 1)   //"Min" & "Max" text & data
    
    //MARK: - Add Keep Left labelNode
    public func createTrackLabels(labelParent: SKNode, topLabel: Bool) {
        
        //Title
        f8KLLabelTitle.text = "\(kLTitle)"
//        (text: "\(kLTitle)")
        f8KLLabelTitle.name = "line1"
    f8KLLabelTitle.fontSize = 17
//    f8KLLabelTitle.fontName = "Helvetica Neue Bold"
    f8KLLabelTitle.fontColor = titleColour
    //            f8KLLabelTitle.zPosition = 0
    f8KLLabelTitle.horizontalAlignmentMode = .center
    f8KLLabelTitle.position = CGPoint(x: 0, y: 0.25 * f8CircleCentre)
        labelParent.addChild(f8KLLabelTitle)

        //Subtitle
    f8KLLabelDescription.fontSize = 8.6
//    f8KLLabelDescription.fontName = "Chalkduster"
//    f8KLLabelDescription.fontColor = subTitleColour
    //            f8KLLabelDescription.zPosition = 0
    f8KLLabelDescription.horizontalAlignmentMode = .center
    f8KLLabelDescription.position = CGPoint(x: 0, y: 0.13 * f8CircleCentre)
        labelParent.addChild(f8KLLabelDescription)
        
        //Line 1L
        avgSpdDesc.fontSize = 7.8
//    avgSpdDesc.fontName = "Helvetica Neue Medium"
//    avgSpdDesc.fontColor = spdTitleColour
//        avgSpdDesc.fontColor = UIColor(displayP3Red: 0.85, green: 0.9, blue: 0.7, alpha: 1)
//            avgSpdDesc.zPosition = 0
    avgSpdDesc.horizontalAlignmentMode = .right
    avgSpdDesc.position = CGPoint(x: -0.01 * f8CircleCentre, y: 0.025 * f8CircleCentre)
        labelParent.addChild(avgSpdDesc)

        //Line 2L
    maxSpdDesc.fontSize = 7.8
//    maxSpdDesc.fontName = "Helvetica Neue Light"
//    maxSpdDesc.fontColor = spdSubTitleColour
    //            maxSpdDesc.zPosition = 0
    maxSpdDesc.horizontalAlignmentMode = .right
    maxSpdDesc.position = CGPoint(x: -0.01 * f8CircleCentre, y: -0.06 * f8CircleCentre)
        labelParent.addChild(maxSpdDesc)

        //Line 3L
    minSpdDesc.fontSize = 7.8
//    minSpdDesc.fontName = "Helvetica Neue Light"
//    minSpdDesc.fontColor = spdSubTitleColour
    //            minSpdDesc.zPosition = 0
    minSpdDesc.horizontalAlignmentMode = .right
    minSpdDesc.position = CGPoint(x: -0.01 * f8CircleCentre, y: -0.145 * f8CircleCentre)
        labelParent.addChild(minSpdDesc)

        //Line 4L
    avgDistanceDesc.fontSize = 7.8
//    avgDistanceDesc.fontName = "Helvetica Neue Medium"
//    avgDistanceDesc.fontColor = spdTitleColour
//        avgDistanceDesc.fontColor = UIColor(displayP3Red: 0.85, green: 0.9, blue: 0.7, alpha: 1)
    //            avgDistanceDesc.zPosition = 0
    avgDistanceDesc.horizontalAlignmentMode = .right
    avgDistanceDesc.position = CGPoint(x: -0.01 * f8CircleCentre, y: -0.23 * f8CircleCentre)
        labelParent.addChild(avgDistanceDesc)

        //Line 5L
    maxDistanceDesc.fontSize = 7.8
//    maxDistanceDesc.fontName = f8DisplayDat == 0 ? "Helvetica Neue Light" : "Helvetica Neue Medium"
    maxDistanceDesc.fontColor = f8DisplayDat == 0 ? spdSubTitleColour : spdTitleColour
    //            maxDistanceDesc.zPosition = 0
    maxDistanceDesc.horizontalAlignmentMode = .right
    maxDistanceDesc.position = CGPoint(x: -0.01 * f8CircleCentre, y: -0.315 * f8CircleCentre)
        labelParent.addChild(maxDistanceDesc)

        //Line 6L
    minDistanceDesc.fontSize = 7.8
//    minDistanceDesc.fontName = "Helvetica Neue Light"
//    minDistanceDesc.fontColor = spdSubTitleColour
    //            minDistanceDesc.zPosition = 0
    minDistanceDesc.horizontalAlignmentMode = .right
    minDistanceDesc.position = CGPoint(x: -0.01 * f8CircleCentre, y: -0.4 * f8CircleCentre)
        labelParent.addChild(minDistanceDesc)

//    //            var avgSpeed = CGFloat(108)     //TEMP !!! Replace by actual reading !!!
//    var avgSpeed: CGFloat = CGFloat.random(in: 105...130)    //TEMP !!! Replace by actual reading !!!
//
//    var maxSpeed = avgSpeed * 1.2   //TEMP
//    var minSpeed = avgSpeed * 0.76  //TEMP !!!
        
    //    var nameKL = sKLAllVehicles[2].name
    //
    //    var sumKL: CGFloat = sKLAllVehicles[0].physicsBody!.velocity.dy
    //    print("sumKL: \(sumKL * 3.6)")

        //Line 1R
    avgSpd.fontSize = 7.8
//    avgSpd.fontName = "Helvetica Neue Medium"
//    avgSpd.fontColor = spdTitleColour
//        avgSpd.fontColor = UIColor(displayP3Red: 0.6, green: 1, blue: 0.67, alpha: 1)
    //            avgSpd.zPosition = 0
    avgSpd.horizontalAlignmentMode = .left
    avgSpd.position = CGPoint(x: -0.005 * f8CircleCentre, y: 0.025 * f8CircleCentre)
        labelParent.addChild(avgSpd)

        //Line 2R
    maxSpd.fontSize = 7.8
//    maxSpd.fontName = "Helvetica Neue Light"
    maxSpd.fontColor = spdSubTitleColour
    //            maxSpd.zPosition = 0
    maxSpd.horizontalAlignmentMode = .left
    maxSpd.position = CGPoint(x: -0.005 * f8CircleCentre, y: -0.06 * f8CircleCentre)
        labelParent.addChild(maxSpd)

        //Line 3R
    minSpd.fontSize = 7.8
//    minSpd.fontName = "Helvetica Neue Light"
    minSpd.fontColor = spdSubTitleColour
    //            minSpd.zPosition = 0
    minSpd.horizontalAlignmentMode = .left
    minSpd.position = CGPoint(x: -0.005 * f8CircleCentre, y: -0.145 * f8CircleCentre)
        labelParent.addChild(minSpd)

        //Line 4R
    avgDistance.fontSize = 7.8
//    avgDistance.fontName = "Helvetica Neue Medium"
//    avgDistance.fontColor = spdTitleColour
        avgDistance.fontName = f8DisplayDat == 0 ? "Helvetica Neue Medium" : "Helvetica Neue Light"
//        avgDistance.fontColor = UIColor(displayP3Red: 0.6, green: 1, blue: 0.67, alpha: 1)
    //            avgDistance.zPosition = 0
    avgDistance.horizontalAlignmentMode = .left
    avgDistance.position = CGPoint(x: -0.005 * f8CircleCentre, y: -0.23 * f8CircleCentre)
        labelParent.addChild(avgDistance)

        //Line 5R
    maxDistance.fontSize = 7.8
        maxDistance.fontName = f8DisplayDat == 0 ? "Helvetica Neue Light" : "Helvetica Neue Medium"
//        maxDistance.fontColor = f8DisplayDat == 0 ? spdSubTitleColour : spdTitleColour
    //            maxDistance.zPosition = 0
    maxDistance.horizontalAlignmentMode = .left
    maxDistance.position = CGPoint(x: -0.005 * f8CircleCentre, y: -0.315 * f8CircleCentre)
        labelParent.addChild(maxDistance)

        //Line 6R
    minDistance.fontSize = 7.8
//    minDistance.fontName = "Helvetica Neue Light"
    minDistance.fontColor = spdSubTitleColour
    //            minDistance.zPosition = 0
    minDistance.horizontalAlignmentMode = .left
        minDistance.position = CGPoint(x: -0.005 * f8CircleCentre, y: -0.4 * f8CircleCentre)
        labelParent.addChild(minDistance)
        
    //    StraightTrackScene.updateF8Labels()

    }       //end createTrackLabels func
    
    func updateLabel(topLabel: Bool, vehicel: NodeData) {
        //Title
        f8KLLabelTitle.text = topLabel ? "\(kLTitle)" : "Std Track"
        
        //SubTitle
        f8KLLabelDescription.text = f8DisplayDat == 0 ? "All Vehicles" : flashOffFlag ? "Vehicle \(f8DisplayDat)" : ""
        f8KLLabelDescription.fontColor = f8DisplayDat == 0 ? subTitleColour : UIColor(displayP3Red: 0.98, green: 1, blue: 0.84, alpha: 1)
//        UIColor(displayP3Red: 0.85, green: 0.9, blue: 0.7, alpha: 1)
        
        //Lines 1L-3L
        avgSpdDesc.text = f8DisplayDat == 0 ? "Avg Speed" : "Speed"
        avgSpdDesc.fontColor = f8DisplayDat == 0 ? UIColor(displayP3Red: 0.85, green: 0.9, blue: 0.7, alpha: 1) : spdTitleColour.withAlphaComponent(0.3)
        avgSpdDesc.fontName = f8DisplayDat == 0 ? "Helvetica Neue Medium" : "Helvetica Neue Light Italic"
        maxSpdDesc.text = f8DisplayDat == 0 ? "Max Speed" : "Avg Speed"
        maxSpdDesc.fontColor = f8DisplayDat == 0 ? spdSubTitleColour : UIColor(displayP3Red: 0.85, green: 0.9, blue: 0.7, alpha: 1)
        maxSpdDesc.fontName = f8DisplayDat == 0 ? "Helvetica Neue Light" : "Helvetica Neue Medium"
        minSpdDesc.text = f8DisplayDat == 0 ? "Min Speed" : "Max Speed"
        minSpdDesc.fontColor = spdSubTitleColour
        minSpdDesc.fontName = f8DisplayDat == 0 ? "Helvetica Neue Light" : "Helvetica Neue Light"

        //Lines 4L-6L
        avgDistanceDesc.text = f8DisplayDat == 0 ? "Avg \(Km)" : "Min Speed"
        avgDistanceDesc.fontColor = f8DisplayDat == 0 ? UIColor(displayP3Red: 0.85, green: 0.9, blue: 0.7, alpha: 1) : spdSubTitleColour
        avgDistanceDesc.fontName = f8DisplayDat == 0 ? "Helvetica Neue Medium" : "Helvetica Neue Light"
        maxDistanceDesc.text = f8DisplayDat == 0 ? "Max \(Km)" : "Total \(Km)"
        maxDistanceDesc.fontColor = f8DisplayDat == 0 ? spdSubTitleColour : UIColor(displayP3Red: 0.85, green: 0.9, blue: 0.7, alpha: 1)
        maxDistanceDesc.fontName = f8DisplayDat == 0 ? "Helvetica Neue Light" : "Helvetica Neue Medium"
//        minDistanceDesc.text = f8DisplayDat == 0 ? "Min \(Km)" : topLabel ? "Honda" : ""
        //Temp - move down 1 line & center later!
        minDistanceDesc.text = f8DisplayDat == 0 ? "Min \(Km)" : topLabel ? "\(sKLAllVehicles[f8DisplayDat].vehType)" : ""
        minDistanceDesc.fontColor = spdSubTitleColour
        minDistanceDesc.fontName = f8DisplayDat == 0 ? "Helvetica Neue Light" : "Helvetica Neue Medium"

        //Lines 1R-3R
        avgSpd.text = f8DisplayDat == 0 ? "\(Int(vehicel.speedAvg)) \(kph)" : "\(Int(vehicel.currentSpeed)) \(kph)"
        avgSpd.fontColor = f8DisplayDat == 0 ? UIColor(displayP3Red: 0.6, green: 1, blue: 0.67, alpha: 1) : spdTitleColour.withAlphaComponent(0.3)
        avgSpd.fontName = f8DisplayDat == 0 ? "Helvetica Neue Medium" : "Helvetica Neue Light"
        maxSpd.text = f8DisplayDat == 0 ? "\(Int(vehicel.speedMax)) \(kph)" : "\(Int(vehicel.speedAvg)) \(kph)"
        maxSpd.fontColor = f8DisplayDat == 0 ? spdSubTitleColour : UIColor(displayP3Red: 0.6, green: 1, blue: 0.67, alpha: 1)
        maxSpd.fontName = f8DisplayDat == 0 ? "Helvetica Neue Light" : "Helvetica Neue Medium"
        minSpd.text = f8DisplayDat == 0 ? "\(vehicel.speedMin < 500 ? Int(vehicel.speedMin) : Int(vehicel.speedAvg)) \(kph)" : "\(Int(vehicel.speedMax)) \(kph)"
        
//        avgSpd.text = f8DisplayDat == 0 ? "\(Int(vehicel.speedAvg)) \(kph)" : "\(Int(vehicel.speedAvg)) \(kph)"
//        maxSpd.text = f8DisplayDat == 0 ? "\(Int(vehicel.speedMax)) \(kph)" : "\(Int(vehicel.speedMax)) \(kph)"
//        minSpd.text = f8DisplayDat == 0 ? "\(vehicel.speedMin < 500 ? Int(vehicel.speedMin) : Int(vehicel.speedAvg)) \(kph)" : "\(vehicel.speedMin < 500 ? Int(vehicel.speedMin) : Int(vehicel.speedAvg)) \(kph)"
        
        //Lines 4R-6R
        avgDistance.text = f8DisplayDat == 0 ? "\(abs(vehicel.distance).varDP)" : "\(vehicel.speedMin < 500 ? Int(vehicel.speedMin) : Int(vehicel.speedAvg)) \(kph)"
        avgDistance.fontColor = f8DisplayDat == 0 ? UIColor(displayP3Red: 0.6, green: 1, blue: 0.67, alpha: 1) : spdSubTitleColour
        avgDistance.fontName = f8DisplayDat == 0 ? "Helvetica Neue Medium" : "Helvetica Neue Light"
        maxDistance.text = f8DisplayDat == 0 ? "\(abs(vehicel.distanceMax).varDP)" : "\(abs(vehicel.distance).varDP)"
        maxDistance.fontColor = f8DisplayDat == 0 ? spdSubTitleColour : UIColor(displayP3Red: 0.6, green: 1, blue: 0.67, alpha: 1)
        maxDistance.fontName = f8DisplayDat == 0 ? "Helvetica Neue Light" : "Helvetica Neue Medium"
//        minDistance.text = f8DisplayDat == 0 ? "\(abs(vehicel.distanceMin).varDP)" : topLabel ? "S2000" : ""
        //Temp - move down 1 line & center later!
        minDistance.text = f8DisplayDat == 0 ? "\(abs(vehicel.distanceMin).varDP)" : topLabel ? "" : ""
        minDistance.fontName = f8DisplayDat == 0 ? "Helvetica Neue Light" : "Helvetica Neue Medium"
        
        //May require the following to refresh between 'All Vehicles' and single vehicle display!!!
//        maxDistanceDesc.fontName = f8DisplayDat == 0 ? "Helvetica Neue Light" : "Helvetica Neue Medium"
//        maxDistanceDesc.fontColor = f8DisplayDat == 0 ? spdSubTitleColour : spdTitleColour
//        maxDistance.fontName = f8DisplayDat == 0 ? "Helvetica Neue Light" : "Helvetica Neue Medium"
//        maxDistance.fontColor = f8DisplayDat == 0 ? spdSubTitleColour : spdTitleColour
    }       //end updateLabel
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else {return}   //Exit if not first touch!
//        
////        nodes(at: CGPoint)
//        
//        print("f8DisplayDat b4: \(f8DisplayDat)")
//        f8DisplayDat += 1
//        print("f8DisplayDat afta: \(f8DisplayDat)")
//
//    }

}           //end LabelData class
