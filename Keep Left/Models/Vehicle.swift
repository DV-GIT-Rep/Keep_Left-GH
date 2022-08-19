//
//  Vehicle.swift
//  Keep Left
//
//  Created by Bill Drayton on 16/3/2022.
//

import Foundation
import SpriteKit
import SwiftUI

class Vehicle: SKSpriteNode, ObservableObject {
    
//    @Published var txVehicle = [Vehicle]()
    
    @Published var speedKPH: CGFloat
    @Published var km: CGFloat
    @Published var lane: CGFloat
    
    @Published var laps: CGFloat
    @Published var distance: CGFloat        //Distance travelled in km
    @Published var distanceMax: CGFloat        //Distance travelled in km
    @Published var distanceMin: CGFloat        //Distance travelled in km

    @Published var otherTrack: Bool
    
    @Published var startPos: CGFloat        //Set to position.y when vehicle defined
    
    @Published var speedAvg: CGFloat        //Speed in kph
    @Published var speedMax: CGFloat        //Speed in kph
    @Published var speedMin: CGFloat        //Speed in kph

    @Published var kmAvg: CGFloat     //Distance in km
    @Published var kmMax: CGFloat     //Distance in km
    @Published var kmMin: CGFloat     //Distance in km

//    @Published var indicate: String
//    @Published var lights: Bool
    
    //MARK: - Init
    init(imageName: String) {
        let texture = SKTexture(imageNamed: imageName)
        speedKPH = 0.0
        km = 0.0
        lane = 0.0
        laps = 0.0
        distance = 0.0
        distanceMax = 0.0
        distanceMin = 0.0
        startPos = 0.0
        otherTrack = false
        speedAvg = 0.0
        speedMax = 0.0
        speedMin = 0.0
        kmAvg = 0.0
        kmMax = 0.0
        kmMin = 0.0

        super.init(texture: texture, color: UIColor.clear, size: texture.size())
//        super.init(imageName: imageName)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init()

    }
    
    //MARK: - Setup
    func setup() {
        
    }
    
    //MARK: - tbc Move vehicle by required amount???
    func animate() {
        
    }
    
    //MARK: - Flash indicators as required - see enum (not yet added)
    func indicate() {
        
        enum Indicator: CaseIterable {
            case off
            case left
            case right
        }
        // eg.  Indicator.off
        //      Indicator.allCases.forEach { ... }

    }
    
    //MARK: - Lights and taillights on/off as per enum - ALL Vehicles!
        enum Lights: CaseIterable {
            case off        //Lights Off
            case low        //Low Beam On
            case high       //High Beam On
            
            mutating func toggleLights() {
                switch self {
                case .off: self = .low
                case .low: self = .off
                case .high: self = .off
             }
        }
    }
    
//    //MARK: - Lights and taillights on/off as per enum - ALL Vehicles!
//    func lights() {
//
//        enum Lights: CaseIterable {
//            case off        //Lights Off
//            case low        //Low Beam On
//            case high       //High Beam On
//        }
//    }

    @State var oneGo = false

    func moveF8Vehicle(sNode: SKNode, sNodePos: CGPoint, meta1: CGFloat, F8YZero: CGFloat) {
        
        //Note: self = f8 Node
        var f8EquivName: String = sNode.name!  //lazy???

        //MARK: - Find name of Straight Track equivalent to Fig 8 Track Vehicle
        //          eg.f8KLVehicle_5 -> sKLVehicle_5 OR f8OtherVehicle_69 -> sOtherVehicle_69
        f8EquivName.remove(at: f8EquivName.startIndex)        //Remove "s" from start of name
        f8EquivName.insert("8", at: f8EquivName.startIndex)   //Replace "s" with "//f8"
        f8EquivName.insert("f", at: f8EquivName.startIndex)   //Replace "s" with "//f8"
        f8EquivName.insert("/", at: f8EquivName.startIndex)   //Add "/"
        f8EquivName.insert("/", at: f8EquivName.startIndex)   //Add "/"

        guard let f8Node = childNode(withName: f8EquivName) else {
            return
        }
        
        var f8NodeRot: CGFloat = 0
        let aniDuration: CGFloat = 0.4
        
        var key = f8Node.name
        key = String(key!.suffix(3))
        key = "key\(key!)"
        
        var lanePos: CGFloat = ((farLane - closeLane) * lane + closeLane)
        if otherTrack == true {     //If tracks back to front, reverse polarity here!!!
            lanePos = -lanePos
        }
        
        var newF8NodePos = f8Node.position
        var currentSNodePos = sNode.position
        
        //MARK: - Calculate position of figure 8 vehicle based on straight track vehicle
        switch currentSNodePos.y {          //NOTE: self = the current vehicle
        case let y1 where y1 <= f8Radius:
            //1st straight stretch 45' from origin up and to right
            
            newF8NodePos.x = (cos45Deg * y1)
            newF8NodePos.y = (sin45Deg * y1)
            
            newF8NodePos.x = newF8NodePos.x - (cos45Deg * lanePos)
            newF8NodePos.y = newF8NodePos.y + (sin45Deg * lanePos)

            f8NodeRot = otherTrack ? CGFloat(135).degrees() : -CGFloat(45).degrees()

            let f8NodePos = CGPoint(x: newF8NodePos.x, y: newF8NodePos.y)
            f8Node.zPosition = 10       //Set zPosition lower than bridge (zPos: 15)

            let newF8Pos = SKAction.move(to: f8NodePos, duration: aniDuration)
            let newF8Rot = SKAction.rotate(toAngle: f8NodeRot, duration: aniDuration, shortestUnitArc: true)
            let group = SKAction.group([newF8Pos, newF8Rot])
            
            f8Node.run(group, withKey: "key")

        case var y1 where y1 <= (f8Radius + (piBy1p5 * f8Radius)):
            //1st 3/4 circle heading up and to left
            y1 = y1 - f8Radius
            
            var y1Deg: CGFloat = y1 * y1Mx               //Defines angle change from start of 3/4 circle to current position
            y1Deg = y1Deg - 45                  //Start from angle 3 o'clock
            
            newF8NodePos.x = CGFloat(0)         //Sets starting position to circle centre
            newF8NodePos.y = f8CircleCentre
            let laneRadius: CGFloat = f8Radius - lanePos

            newF8NodePos.x = newF8NodePos.x + ((laneRadius + fudgeFactor) * cos(CGFloat(y1Deg).degrees()))
            newF8NodePos.y = newF8NodePos.y + ((laneRadius + fudgeFactor) * sin(CGFloat(y1Deg).degrees()))
                
            let f8NodePos = CGPoint(x: newF8NodePos.x, y: newF8NodePos.y)

            if otherTrack == true { y1Deg = y1Deg + 180}    //Turns vehicle 180 degrees
            if y1Deg > 180 { y1Deg = y1Deg - 360 }  //Resolves node spinning problem
            let f8NodeRot: CGFloat = y1Deg.degrees()

            let newF8Pos = SKAction.move(to: f8NodePos, duration: aniDuration)
            let newF8Rot = SKAction.rotate(toAngle: f8NodeRot, duration: aniDuration, shortestUnitArc: true)
            let group = SKAction.group([newF8Pos, newF8Rot])
            
            f8Node.run(group, withKey: "key")

        case var y1 where y1 <= ((3 * f8Radius) + (piBy1p5 * f8Radius)):
            //2nd straight stretch 45' down to right
            y1 = y1 - (f8Radius + (piBy1p5 * f8Radius))
            
            newF8NodePos.x = -halfDiagonalXY    //Point 75m diagonally up & to left of origin
            newF8NodePos.y = halfDiagonalXY
            
            newF8NodePos.x = newF8NodePos.x + (cos45Deg * y1)
            newF8NodePos.y = newF8NodePos.y - (sin45Deg * y1)
            
            newF8NodePos.x = newF8NodePos.x + (cos45Deg * lanePos)
            newF8NodePos.y = newF8NodePos.y + (sin45Deg * lanePos)

            f8NodeRot = otherTrack ? CGFloat(45).degrees() : -CGFloat(135).degrees()

            let f8NodePos = CGPoint(x: newF8NodePos.x, y: newF8NodePos.y)
            f8Node.zPosition = 20       //Set zPosition higher than bridge (zPos: 15)

            let newF8Pos = SKAction.move(to: f8NodePos, duration: aniDuration)
            let newF8Rot = SKAction.rotate(toAngle: f8NodeRot, duration: aniDuration, shortestUnitArc: true)
            let group = SKAction.group([newF8Pos, newF8Rot])
            
            f8Node.run(group, withKey: "key")

        case var y1 where y1 <= ((3 * f8Radius) + (piBy3 * f8Radius)):
            //2nd 3/4 circle heading down and to left
            y1 = y1 - ((3 * f8Radius) + (piBy1p5 * f8Radius))
            
            var y1Deg: CGFloat = -y1 * y1Mx      //Defines angle change from start of 3/4 circle to current position
            y1Deg = y1Deg + 45                  //Start from angle 3 o'clock
            
            newF8NodePos.x = CGFloat(0)         //Sets starting position to circle centre
            newF8NodePos.y = -f8CircleCentre
            let laneRadius: CGFloat = f8Radius + lanePos

            newF8NodePos.x = newF8NodePos.x + ((laneRadius + fudgeFactor) * cos(CGFloat(y1Deg).degrees()))
            newF8NodePos.y = newF8NodePos.y + ((laneRadius + fudgeFactor) * sin(CGFloat(y1Deg).degrees()))

            let f8NodePos = CGPoint(x: newF8NodePos.x, y: newF8NodePos.y)

            if otherTrack == false { y1Deg = y1Deg - 180}    //Turns vehicle 180 degrees
            if y1Deg < -180 { y1Deg = y1Deg + 360 }  //Resolves node spinning problem
            let f8NodeRot: CGFloat = y1Deg.degrees()

            let newF8Pos = SKAction.move(to: f8NodePos, duration: aniDuration)
            let newF8Rot = SKAction.rotate(toAngle: f8NodeRot, duration: aniDuration, shortestUnitArc: true)
            let group = SKAction.group([newF8Pos, newF8Rot])

            f8Node.removeAction(forKey: "key")
            f8Node.run(group, withKey: "key")

        case var y1 where y1 <= ((4 * f8Radius) + (piBy3 * f8Radius)):
            //3rd straight stretch 45' up & back to origin
//            y1 = y1 - ((3 * f8Radius) + (piBy3 * f8Radius))
            y1 = ((4 * f8Radius) + (piBy3 * f8Radius)) - y1    //Changes y1 so 1006.858 (for f8Radius = 75m) = the origin (easier calculation)
            
            newF8NodePos.x = -(cos45Deg * y1)
            newF8NodePos.y = -(sin45Deg * y1)
            
            newF8NodePos.x = newF8NodePos.x - (cos45Deg * lanePos)
            newF8NodePos.y = newF8NodePos.y + (sin45Deg * lanePos)

            f8NodeRot = otherTrack ? CGFloat(135).degrees() : -CGFloat(45).degrees()

            let f8NodePos = CGPoint(x: newF8NodePos.x, y: newF8NodePos.y)
            f8Node.zPosition = 10       //Set zPosition lower than bridge (zPos: 15)

            let newF8Pos = SKAction.move(to: f8NodePos, duration: aniDuration)
            let newF8Rot = SKAction.rotate(toAngle: f8NodeRot, duration: aniDuration, shortestUnitArc: true)
            let group = SKAction.group([newF8Pos, newF8Rot])
            
            f8Node.run(group, withKey: "key")

        default:
            return

        }
    }
    
}           //End of Vehicle class

class F8Vehicle: Vehicle {
//    self.physicsBody.rotationEffect(.degrees(45))
//    static var straightName: String = replacingCharacters(in: name, with: <#T##String#>)
    
}
