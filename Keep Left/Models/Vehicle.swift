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
    
    @Published var preferredSpeed: CGFloat  //Vehicle speed without obstacles (kph)
    @Published var currentSpeed: CGFloat    //Vehicle speed NOW
    
    @Published var speedKPH: CGFloat
    @Published var km: CGFloat
    @Published var lane: CGFloat
    
    @Published var laps: CGFloat
    @Published var distance: CGFloat        //Distance travelled in km
    @Published var distanceMax: CGFloat     //Distance travelled in km
    @Published var distanceMin: CGFloat     //Distance travelled in km
    @Published var preDistance: CGFloat     //Records distance for 1st 10secs of travel

    @Published var otherTrack: Bool
    
    @Published var startPos: CGFloat        //Set to position.y when vehicle defined
    
    @Published var speedAvg: CGFloat        //Speed in kph
    @Published var speedMax: CGFloat        //Speed in kph
    @Published var speedMin: CGFloat        //Speed in kph

    @Published var kmAvg: CGFloat     //Distance in km
    @Published var kmMax: CGFloat     //Distance in km
    @Published var kmMin: CGFloat     //Distance in km
    
    @Published var gap: CGFloat         //Distance between this vehicle and one in front (same lane!)
    @Published var otherGap: CGFloat    //Distance between this vehicle and one in front (OTHER lane!)
    @Published var oRearGap: CGFloat    //Distance between this vehicle and one behind (OTHER lane!)
    @Published var rearGap: CGFloat     //Distance between this vehicle and one behind (same lane!)
    
    @Published var goalSpeed: CGFloat   //Used to temp store immediate goal speed following proximity check
    @Published var changeTime: CGFloat  //Time in seconds for next SKAction on Straight Track vehicles
    
    @Published var spdClk: Int          //Clk decs every 'findObstacles'. upToSpd set when spdClk times out.
    var upToSpd: Bool     //Set for each vehicle when it reaches speed. Cleared when vehicles stopped.
    
    var indicator: Indicator
    var startIndicator: Bool    //Triggers start of lane change
    
    /// Use for Trucks & Buses - 100kph limit in NSW. Full spdLimit range for Cars.
    enum VType {
        case car, truck, bus
    }        //Ref from sKL vehicles ONLY! OtherTrack types match!
    @Published var vehType = VType.car
    
    /// -1 to +1 sets distribution in randomValue. Calc spdPref with +1 for cars, +0.6? for trucks & +0.25? for buses.
    @Published var spdPref: CGFloat = 1            //Ref from sKL vehicles ONLY! OtherTrack speeds match!
    /// % of spdLimit used for 'max' in 'randomValue' to calc preferredSpeed = 40-105%
    @Published var topRange: CGFloat = 1.05        //Ref from sKL vehicles ONLY! OtherTrack speeds match!
    /// % of spdLimit used for 'min' in 'randomValue' to calc preferredSpeed = 25-topRange%
    @Published var lowRange: CGFloat = 0.25        //Ref from sKL vehicles ONLY! OtherTrack speeds match!
    /// -1 to +1. Actively sets time to next speed change for this vehicle. varTime = fixed probability.
    /// - Time range = minChangeTime to maxChangeTime (initially 1 to 180 seconds)
    /// - eg. randomValue(distribution: sKLVehicle[x].varTime, min: minChangeTime, max: maxChangeTime)
    @Published var varTime: CGFloat = 1            //-1 to +1. Ref from sKL vehicles ONLY! OtherTrack speeds match!
    
    /// -1 to +1. Actively sets delay between speed changes for this vehicle. holdTime = fixed probability.
    /// - Time range = minChangeTime to maxChangeTime (initially 1 to 180 seconds)
    /// - eg. randomValue(distribution: sKLVehicle[x].varTime, min: minChangeTime, max: maxChangeTime)
    @Published var holdTime: CGFloat = -1          //-1 to +1. Ref from sKL vehicles ONLY! OtherTrack speeds match!
    
    /// Stay 'mySetGap' secs behind vehicle in front or further
    ///  -     Skew     |   Vehicle   |    Range
    ///  -     -0.5     |    Cars     |   2.4-3.4
    ///  -      0       |    Buses    |   2.8-4.2
    ///  -     +0.25    |    Trucks   |   2.9-5.8
    @Published var mySetGap: CGFloat = 3    //Gap in secs between vehicles individually set
    /// Sets deceleration rate when >= mySetGap from vehicle in front in m/s2
    ///  -     Skew     |   Vehicle   |   Range
    ///  -     +1.0     |    Cars     |  2.5-4.0
    ///  -      -0.2    |    Buses    |  1.4-3.8
    ///  -     -1.0     |    Trucks   |  1.0-3.5
    @Published var decelMin: CGFloat = 3    //m/s2
    /// Sets deceleration rate when within 'myMinGap' of vehicle in front
    ///  -     Skew     |   Vehicle   |   Range
    ///  -     +0.5     |    Cars     |  8.0-10.0
    ///  -      0       |    Buses    |  7.0-8.5
    ///  -     -0.5     |    Trucks   |  6.5-8.0
    @Published var decelMax: CGFloat = 9   //Deceleration rate when within 'myMinGap' of vehicle in front
    /// Apply emergency deceleration within myMinGap of vehicle in front in secs
    ///  -     Skew     |   Vehicle   |    Range
    ///  -     -1.0     |    Cars     |   0.4-0.8
    ///  -      0.0     |    Buses    |   0.6-0.9
    ///  -     +1.0     |    Trucks   |   0.8-1.2
    @Published var myMinGap: CGFloat = 0.9  //Apply emergency deceleration within myMinGap of vehicle in front

    /// Probability of this vehicle setting .laneMode to hi or low value: 0-100
    /// - Value -1 to +1. Fixed when vehicle created.
    /// - Used as 'distribution' when redefining .laneMode.
    @Published var laneProb: CGFloat = 0.0
    /// Random value 0-100 set during SKAction with distribution = .laneProb
    /// - see .laneProb
    @Published var laneMode: CGFloat = 50.0
    
    /// Timer increments when vehicle going slow & hasn't changed lanes
    /// - Increments every 10 secs if Speed < (preferredSpeed - 2)
    /// - Cleared every 10 secs if Speed > (preferredSpeed - 1)
    /// - From left lane considered 'stuck' if timer > 'stuckLLow' to 'stuckLHi'
    /// - From right lane considered 'stuck' if timer > 'stuckRLow' to 'stuckRHi'
    /// - Actual time within these ranges determined as (vehNo/numVehicles*(stuckXLow-stuckXHi)+stuckXLow)
    @Published var stuckTimer: CGFloat = 0

    //Create variables used in 'setVariables'
//    @Published var strtSpd: CGFloat = 0             //Capture preferredSpeed @ start of action sequence
//    @Published var adjustTime: CGFloat = 0          //Defines time preferredSpeed takes to get from strtSpd to targetSpd
//    @Published var targetSpd: CGFloat = 110         //Value of preferredSpeed @ end of adjustTime period
//    @Published var fixedTime: CGFloat = 2           //Time that preferredSpeed remains unchanged after being altered

//    @Published var indicate: String
//    @Published var lights: Bool
    
    //MARK: - Init
    init(imageName: String) {
        let texture = SKTexture(imageNamed: imageName)
        preferredSpeed = 0.0
        currentSpeed = 0.0
        speedKPH = 0.0
        km = 0.0
        lane = 0.0
        laps = 0.0
        distance = 0.0
        distanceMax = 0.0
        distanceMin = 0.0
        preDistance = 0.0
        startPos = 0.0
        otherTrack = false
        speedAvg = 0.0
        speedMax = 0.0
        speedMin = 900.0        //Set to >500 to start
        kmAvg = 0.0
        kmMax = 0.0
        kmMin = 0.0
        gap = 0.0
        otherGap = 0.0
        oRearGap = 0.0
        rearGap = 0.0
        goalSpeed = 0.0     //Overwritten later!
        changeTime = 1.0    //seconds. Overwritten later!
        spdClk = 600         //Dummy value to start. 0.083sec * 600 = 5 secs
        upToSpd = false
        
        indicator = .off
        startIndicator = false

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
        f8EquivName.remove(at: f8EquivName.startIndex)        //Remove "t" from start of name
        f8EquivName.insert("8", at: f8EquivName.startIndex)   //Replace "st" with "//f8"
        f8EquivName.insert("f", at: f8EquivName.startIndex)   //Replace "st" with "//f8"
        f8EquivName.insert("/", at: f8EquivName.startIndex)   //Add "/"
        f8EquivName.insert("/", at: f8EquivName.startIndex)   //Add "/"

        guard let f8Node = childNode(withName: f8EquivName) else {
            return
        }
        
        var f8NodeRot: CGFloat = 0
        let aniDuration: CGFloat = 0.5  //SAME period as 'every500ms' timer!
        
        var key = f8Node.name           //rewrite using Int.extractNum?
        key = String(key!.suffix(3))
        key = "key\(key!)"
        
        var lanePos: CGFloat = ((FarLane - CloseLane) * lane + CloseLane)
        if otherTrack == true {     //If tracks back to front, reverse polarity here!!!
            lanePos = -lanePos
        }
        
        var newF8NodePos = f8Node.position
        var currentSNodePos = sNode.position
        
        //MARK: - Calculate position of figure 8 vehicle based on straight track vehicle
        switch currentSNodePos.y {          //NOTE: self = the current vehicle
        case let y1 where y1 <= F8Radius:
            //1st straight stretch 45' from origin up and to right
            
            newF8NodePos.x = (cos45Deg * y1)
            newF8NodePos.y = (sin45Deg * y1)
            
            newF8NodePos.x = newF8NodePos.x - (cos45Deg * lanePos)
            newF8NodePos.y = newF8NodePos.y + (sin45Deg * lanePos)

            f8NodeRot = otherTrack ? CGFloat(135).degrees() : -CGFloat(45).degrees()

            let f8NodePos = CGPoint(x: newF8NodePos.x, y: newF8NodePos.y)
            f8Node.zPosition = 20       //Set zPosition lower than bridge (zPos: 15)

            let newF8Pos = SKAction.move(to: f8NodePos, duration: aniDuration)
            let newF8Rot = SKAction.rotate(toAngle: f8NodeRot, duration: aniDuration, shortestUnitArc: true)
            let group = SKAction.group([newF8Pos, newF8Rot])
            
            f8Node.run(group, withKey: "key")

        case var y1 where y1 <= (F8Radius + (piBy1p5 * F8Radius)):
            //1st 3/4 circle heading up and to left
            y1 = y1 - F8Radius
            
            var y1Deg: CGFloat = y1 * y1Mx               //Defines angle change from start of 3/4 circle to current position
            y1Deg = y1Deg - 45                  //Start from angle 3 o'clock
            
            newF8NodePos.x = CGFloat(0)         //Sets starting position to circle centre
            newF8NodePos.y = f8CircleCentre
            let laneRadius: CGFloat = F8Radius - lanePos

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

        case var y1 where y1 <= ((3 * F8Radius) + (piBy1p5 * F8Radius)):
            //2nd straight stretch 45' down to right
            y1 = y1 - (F8Radius + (piBy1p5 * F8Radius))
            
            newF8NodePos.x = -halfDiagonalXY    //Point 75m diagonally up & to left of origin
            newF8NodePos.y = halfDiagonalXY
            
            newF8NodePos.x = newF8NodePos.x + (cos45Deg * y1)
            newF8NodePos.y = newF8NodePos.y - (sin45Deg * y1)
            
            newF8NodePos.x = newF8NodePos.x + (cos45Deg * lanePos)
            newF8NodePos.y = newF8NodePos.y + (sin45Deg * lanePos)

            f8NodeRot = otherTrack ? CGFloat(45).degrees() : -CGFloat(135).degrees()

            let f8NodePos = CGPoint(x: newF8NodePos.x, y: newF8NodePos.y)
            f8Node.zPosition = 10       //Set zPosition higher than bridge (zPos: 15)

            let newF8Pos = SKAction.move(to: f8NodePos, duration: aniDuration)
            let newF8Rot = SKAction.rotate(toAngle: f8NodeRot, duration: aniDuration, shortestUnitArc: true)
            let group = SKAction.group([newF8Pos, newF8Rot])
            
//            let sss = SKAction.customAction(withDuration: <#T##TimeInterval#>, actionBlock: <#T##(SKNode, CGFloat) -> Void#>)
            
            f8Node.run(group, withKey: "key")

        case var y1 where y1 <= ((3 * F8Radius) + (piBy3 * F8Radius)):
            //2nd 3/4 circle heading down and to left
            y1 = y1 - ((3 * F8Radius) + (piBy1p5 * F8Radius))
            
            var y1Deg: CGFloat = -y1 * y1Mx      //Defines angle change from start of 3/4 circle to current position
            y1Deg = y1Deg + 45                  //Start from angle 3 o'clock
            
            newF8NodePos.x = CGFloat(0)         //Sets starting position to circle centre
            newF8NodePos.y = -f8CircleCentre
            let laneRadius: CGFloat = F8Radius + lanePos

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

        case var y1 where y1 <= ((4 * F8Radius) + (piBy3 * F8Radius)):
            //3rd straight stretch 45' up & back to origin
//            y1 = y1 - ((3 * F8Radius) + (piBy3 * F8Radius))
            y1 = ((4 * F8Radius) + (piBy3 * F8Radius)) - y1    //Changes y1 so 1006.858 (for F8Radius = 75m) = the origin (easier calculation)
            
            newF8NodePos.x = -(cos45Deg * y1)
            newF8NodePos.y = -(sin45Deg * y1)
            
            newF8NodePos.x = newF8NodePos.x - (cos45Deg * lanePos)
            newF8NodePos.y = newF8NodePos.y + (sin45Deg * lanePos)

            f8NodeRot = otherTrack ? CGFloat(135).degrees() : -CGFloat(45).degrees()

            let f8NodePos = CGPoint(x: newF8NodePos.x, y: newF8NodePos.y)
            f8Node.zPosition = 20       //Set zPosition lower than bridge (zPos: 15)

            let newF8Pos = SKAction.move(to: f8NodePos, duration: aniDuration)
            let newF8Rot = SKAction.rotate(toAngle: f8NodeRot, duration: aniDuration, shortestUnitArc: true)
            let group = SKAction.group([newF8Pos, newF8Rot])
            
            f8Node.run(group, withKey: "key")

        default:
            return

        }   //end Switch statement
    }       //end moveF8Vehicle method
    
//    func startOvertake(vehC: Vehicle) async {
//        let flashTime: Double = 6     //6 secs ~ 6 flashes of indicator
//        var tmpLane: CGFloat = 0
//        let plusLane = SKAction.customAction(withDuration: flashTime) {
//            (node, elapsedTime) in
//            let timeLeft = flashTime - elapsedTime
//            tmpLane = elapsedTime / flashTime
//            print(tmpLane.dp2)
//            vehC.lane = tmpLane
//        }
//        await self.run(plusLane)
//    }
//
    

    /// Creates a new value of preferredSpeed, sets it over a random period (1-180s), holds it over a new random period (1-180s), and then repeats with new random values indefinitely
    /// - Parameters:
    ///   - vehicle: To be setup - Straight Keep Left Track ONLY! Others are copied
    ///   - vehNo: Number of this vehicle
    func setVehicleSpeed() {
        let vehNo = Int.extractNum(from: self.name ?? "999")! //vehicle = sKLAllVehicles[vehNo]
        //var fixedTime: CGFloat = 2 //Time preferredSpeed is held steady after being altered (to be overwritten)
        //var adjustTime: CGFloat = 1
        //adjustTime = period preferredSpeed changed over
        //fixedTime  = time period where preferredSpeed remains unchanged. Alternates with adjustTime.
        let strtSpd = preferredSpeed  //Set to preferredSpeed @ start
        var adjustTime: CGFloat = 5
        if strtSpd < 10 || runStop == .stop {   //Limit initial acceleration time & stop time
            if runStop == .run {    //Starting
                adjustTime = randomValue(distribution: -0.6, min: 1, max: 30) //1 through 30 secs skew faster
            } else {                //Stopping
                adjustTime = randomValue(distribution: -0.6, min: 1, max: 5) //1 through 5 secs skew faster
            }
        } else {
            adjustTime = randomValue(distribution: self.varTime, min: 1, max: 180) //1 through 180 secs
        }
        var targetSpd: CGFloat
        if runStop == .run {
            targetSpd = randomValue(distribution: spdPref, min: (lowRange * CGFloat(spdLimit)), max: (topRange * CGFloat(spdLimit))) //Intended 'preferredSpeed' @ end of 'adjustTime'
        } else {
            targetSpd = 0  //Set preferredSpeed = 0 when not running
        }
        let fixedTime: CGFloat = randomValue(distribution: self.holdTime, min: 1, max: 180) //1 through 180 secs
//        let fixedTime: CGFloat = 0.01 //TEST - All time spent adjusting preferredSpeed
        let tote2 = String.minSec(from: CGFloat(adjustTime + fixedTime))
        let date = Date()
        let calendar = Calendar.current
        let nowS = String(format: "%02d", calendar.component(.second, from: date))
        let nowM = String(format: "%2d", calendar.component(.minute, from: date))
        let now: String = ("\(nowM):\(nowS)")
        let sS1 = String(format: "%3.f", strtSpd)
        let tS1 = String(format: "%3.f", targetSpd)
        //        let aT1 = String(format: "%5.1f", adjustTime)
        //        let fT1 = String(format: "%5.1f", fixedTime)
        let aT2 = String.minSec(from: adjustTime)
        let fT2 = String.minSec(from: fixedTime)
        let lR1 = String(format: "%3.f", lowRange * 100)
        let tR1 = String(format: "%3.f", topRange * 100)
        var vTipe: String = ""
        if self.vehType == .bus { vTipe = "b" } else if self.vehType == .truck { vTipe = "t" } else { vTipe = "Car" }
        if vehNo == 1 { print("\nVeh\tkph\t ->\tkph\t\tadTim\tHold\tTotal\t Now\tlowR\t topR\tType") }
        print("\(vehNo)\t\(sS1)\t\t\(tS1)\t\t\(aT2)\t\(fT2)\t\(tote2)\t\(now)\t\(lR1)%\t \(tR1)%\t\(vTipe)")
        if strtSpd == 0 {
            print("\t  mySetGap-\(sKLAllVehicles[vehNo].mySetGap.dp2)_decelMin-\(sKLAllVehicles[vehNo].decelMin.dp1)_decelMax-\(sKLAllVehicles[vehNo].decelMax.dp1)_myMinGap-\(sKLAllVehicles[vehNo].myMinGap.dp2)")
        }
//        if vehNo == numVehicles { print("\n")}
        
        //Updates preferredSpeed with next calculated value over period 'adjustTime'
        //FUTURE REF: Duration can't be subset of node as value will NEVER change!
        let setSpeed = SKAction.customAction(withDuration: TimeInterval(adjustTime)) {
            (node, elapsedTime) in
//            if let node = node as? Vehicle {          //for this case, 'node' is identical to 'self'
                let intTime = elapsedTime / adjustTime
                self.preferredSpeed = (targetSpd - strtSpd) * intTime + strtSpd
//            sKLAllVehicles[vehNo].preferredSpeed = (targetSpd - strtSpd) * intTime + strtSpd
                sOtherAllVehicles[vehNo].preferredSpeed = self.preferredSpeed
            
//            } //end of 'if let node = node as? Vehicle {'
        }       //end setSpeed action
        
        //Delay of 'fixedTime' where preferredSpeed remains unchanged
        let delay = SKAction.wait(forDuration: TimeInterval(fixedTime)) //Time when preferredSpeed held steady
        //FUTURE REF: Duration can't be subset of node as value will NEVER change!

        //########################
//        let a1 = SKAction.run {
//            let date = Date()
//            let calendar = Calendar.current
//            let now = calendar.component(.second, from: date)
//            print("\(vehNo)\ta1. Start\t\t\t\t\t\t\tTime: \(now)") }
//        let a2 = SKAction.run {
//            let date = Date()
//            let calendar = Calendar.current
//            let nowS = calendar.component(.second, from: date)
//            let nowM = calendar.component(.minute, from: date)
//            let now: String = ("\(nowM):\(nowS)")
//            print("\(vehNo)\ta2. Speed Next\ttS: \(targetSpd.dp1)\t\t\tTime: \(now) \taT: \(adjustTime.dp1)") }
//        let a3 = SKAction.run {
//            let date = Date()
//            let calendar = Calendar.current
//            let nowS = calendar.component(.second, from: date)
//            let nowM = calendar.component(.minute, from: date)
//            let now: String = ("\(nowM):\(nowS)")
//            print("\(vehNo)\ta3. Delay Nxt\ttS: \(targetSpd.dp1)\tfT: \(fixedTime.dp1)\tTime: \(now) \taT: \(adjustTime.dp1)") }
//        let a4 = SKAction.run {
//            let date = Date()
//            let calendar = Calendar.current
//            let nowS = calendar.component(.second, from: date)
//            let nowM = calendar.component(.minute, from: date)
//            let now: String = ("\(nowM):\(nowS)")
//            print("\(vehNo)\ta4. Delay Done\t fT: \(fixedTime.dp1)\t\t\tTime: \(now)\taT: \(adjustTime.dp1)\n") }

//        //Sequence of SKActions
//        let spdSequence = SKAction.sequence([setSpeed, delay]) //Alter preferredSpeed slowly followed by 'delay'
//
//        run(spdSequence, withKey: "spdAct\(vehNo)")
//        
        //Sequence of SKActions
        let reRun = SKAction.run { self.setVehicleSpeed() }    //Recursion here! Call func again @ end of current call
        let spdSequence = SKAction.sequence([setSpeed, delay, reRun]) //Alter preferredSpeed slowly followed by 'delay'

        run(spdSequence, withKey: "spdAct\(vehNo)") //Overrides & cancels existing SKAction
        
    }           //end of setVehicleSpeed function
    
    func setLaneMode() {
        let vehNo = Int.extractNum(from: self.name ?? "999")! //vehicle = sKLAllVehicles[vehNo]
        let runTime = randomValue(distribution: 0, min: 5*60, max: 30*60) //Value 5 mins - 30 mins
        let fixedLaneLevel: CGFloat = 10 //% @ zero & 100 ends where vehicle only wants to be in left or right lane
        
        if sOtherAllVehicles[vehNo].laneMode > fixedLaneLevel && sOtherAllVehicles[vehNo].laneMode < (100 - fixedLaneLevel) {   //If condition NOT met then leave laneMode value as is!
            //Able to adjust .laneMode value.
            let setMode = SKAction.run {
                sOtherAllVehicles[vehNo].laneMode = randomValue(distribution: sKLAllVehicles[vehNo].laneProb, min: fixedLaneLevel, max: (100 - fixedLaneLevel)) //Only used for otherTrack tho laneProb stored in sKL.
            }   //end SKAction.run
            let delay = SKAction.wait(forDuration: runTime) //Hold new setMode for the next 5-30 mins (randomly selected)
            let reRun = SKAction.run { self.setLaneMode() } //Recursion here! Call func again @ end of current call
            let laneSequence = SKAction.sequence([setMode, delay, reRun])
            
            run(laneSequence, withKey: "laneAct\(vehNo)") //Overrides & cancels existing SKAction
            
        }       //end laneMode value check
    }           //end of setLaneMode function
    
    func getUnStuck() {
        let vehNo = Int.extractNum(from: self.name ?? "999")! //vehicle = sOtherAllVehicles[vehNo]
        let adjStuckTmr = SKAction.run {
            if self.currentSpeed < (self.preferredSpeed - 2) {
                self.stuckTimer += 1
                sKLAllVehicles[vehNo].stuckTimer = self.stuckTimer
                if vehNo == Int(tmpTst) {  //Print 1st 4 vehicles ONLY
                    print("\(vehNo) Spd: \(self.currentSpeed.dp1)\tPrefS: \(self.preferredSpeed.dp1)\tstuckTmr: \(self.stuckTimer.dp1)")
                }   //end Print
            } else {
                if self.currentSpeed > (self.preferredSpeed - 1) {
                    if vehNo == Int(tmpTst) {  //Print 1st 4 vehicles ONLY
                        print("\(vehNo) stuckTmr Cleared in 'getUnStuck'")
                    }   //end Print
                    self.stuckTimer = 0
                }   //end if spd > (prefSpd - 1)
            }       //end if spd < (prefSpd - 2)
        }           //end SKAction.run
        let delay = SKAction.wait(forDuration: 10) //Runs every 10 seconds
        let reRun = SKAction.run { sKLAllVehicles[vehNo].getUnStuck() } //Recursion here! Call func again @ end of current call
        let laneSequence = SKAction.sequence([adjStuckTmr, delay, reRun])
        
        run(laneSequence, withKey: "unStick\(vehNo)") //Overrides & cancels existing SKAction
        
    }               //end getUnStuck func

    
}           //End of Vehicle class

class F8Vehicle: Vehicle {
//    self.physicsBody.rotationEffect(.degrees(45))
//    static var straightName: String = replacingCharacters(in: name, with: <#T##String#>)
    
    var f8RotTweak: CGFloat = 0


}

//extension Vehicle {
//
//    func addGlow(radius: Float = 80) {
//        let effectNode = SKEffectNode()
//        effectNode.name = "GlowEffect"
//        effectNode.shouldRasterize = true
//        effectNode.shouldEnableEffects = true
//        addChild(effectNode)
//        let effect = SKSpriteNode(texture: texture)
//        effect.color = self.color
//        effect.colorBlendFactor = 1
//        effectNode.addChild(effect)
//        effectNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius":radius])
//    }
//}
