//
//  NodeData.swift
//  Keep Left
//
//  Created by Bill Drayton on 5/10/2022.
//

import Foundation
import SpriteKit


struct NodeData {
    var name: String
    
    ///x-y position in metres
    var position: CGPoint
    var size: CGSize
    var lane: CGFloat
    var speed: CGFloat
    var laps: CGFloat
    var gap: CGFloat
    var otherGap: CGFloat
    var rearGap: CGFloat
    var preferredSpeed: CGFloat
    var currentSpeed: CGFloat
    var goalSpeed: CGFloat
    var changeTime: CGFloat
    var frontUnit: String       //Name of vehicle in front = 1 - numVehicles
    var frontPos: CGPoint       //Position of vehicle in front
    var equivF8Name: String
    var key: String
    var f8Pos: CGPoint
    var otherTrack: Bool
    var f8zPos: CGFloat
    var f8Rot: CGFloat
    var startPos: CGFloat
    
    var distance: CGFloat
    var distanceMin: CGFloat
    var distanceMax: CGFloat
    var speedAvg: CGFloat
    var speedMin: CGFloat
    var speedMax: CGFloat
    
    init() {
        name = " "
        position = CGPoint(x: 0, y: 0)
        size = CGSize(width: 1, height: 1)
        lane = 0
        speed = 0
        laps = 0
        gap = 0
        otherGap = 0
        rearGap = 0
        preferredSpeed = 0
        currentSpeed = 0
        goalSpeed = 0
        changeTime = 0
        frontUnit = ""
        frontPos = CGPoint(x: 0, y: 0)
        equivF8Name = ""
        key = ""
        f8Pos = CGPoint(x: 0, y: 0)
        otherTrack = false
        f8zPos = 10     //Initial zPosition < bridge (which is 15)
        f8Rot = 0
        startPos = 0
        
        distance = 0
        distanceMin = 0
        distanceMax = 0
        speedAvg = 0
        speedMin = 99999999
        speedMax = 0
    }
    
    
    //    mutating func findObstacles(t1Vehicle: inout [NodeData]) async -> (t1Vehicle: [NodeData], t2Vehicle: [NodeData]) {
    func findObstacles(t1Vehicle: inout [NodeData], t2Vehicle: inout [NodeData]) async -> (t1Vehicle: [NodeData], t2Vehicle: [NodeData]) {
        //Create copy of vehicles for calculating proximity to other vehicles
        //  Do calculations on background thread
        //
        //    var t1Vehicle = sKLAllVehicles.map{ $0.copy() }      //Straight Track Vehicles: Ignore 'All Vehicles'
        //    var t1Vehicle = sKLAllVehicles.dropFirst()
        //    t1Vehicle.sort(by: {$0.position.y < $1.position.y}) //Sort into positional order, 000 - 999.999
        
        //        print("\(t1Vehicle[1].position)")
        
        var gapSpeed: CGFloat = 0       //Speed required to catch vehicle in front in 3 secs
        var goalSpeed: CGFloat = 0      //Lesser of gapSpeed & preferredSpeed (reduced if closer than 3 secs to veh in front)
        var gapTime: CGFloat = 0        //Time in secs to catch vehicle in front @ current speed
        var decel: CGFloat = 4          // m/sec2. Typical. Varies!
        
        //########################### rearGap calc loop #######################################
        t1Vehicle.sort(by: {$0.position.y > $1.position.y}) //Sort into positional order, 999.999 - 000
        //        var t1Vehicle: [NodeData] = t1Vehicle
        
        var unitNumb: Int
        var rearGap: CGFloat = 0.0      //Distance behind in OTHER lane
        var nextIndex: Int = 0
        var past1km = false
        
        //print("\nrearGap Calcs")
        //Loop through arrays to confirm distance to vehicle behind in the other lane
        //Loop through Track 1 (KL) first
        for (index, veh1Node) in t1Vehicle.enumerated() {
            
            //THIS Vehicle = veh1Node = sKLAllVehicles[unitNumb] = t1Vehicle[index]
            //NEXT Vehicle = t1Vehicle[nextIndex]
            
            unitNumb = Int.extractNum(from: veh1Node.name)! //NOTE: Use [unitNumb] for sKLAllVehicles. Use [index] OR [nextIndex] for t1Vehicles!
            
            nextIndex = index
            //print("nam1: \(veh1Node.name)\tNo: \(unitNumb)\tindex: \(index)")   // XXXXXXX !!!
            
            while rearGap == 0 {
                
                nextIndex = nextIndex + 1       // same as nextIndex += 1
                
                if nextIndex >= numVehicles {
                    
                    nextIndex = 0       //Crossed 1km barrier. Continue search
                    past1km = true      //Flag indicates vehicle behind is beyond 1km boundary
                    
                }           //end nextIndex 'if' statement
                
                let sameLane = (veh1Node.lane - 0.5)...(veh1Node.lane + 0.5)   //Scan for vehicles within 0.5 lanes either side
                let sameLap = (veh1Node.position.y - (veh1Node.size.height / 2)) - (t1Vehicle[nextIndex].position.y + (t1Vehicle[nextIndex].size.height / 2)) //Vehicle in front on same side of 1km boundary
                let lastLap = ((veh1Node.position.y + sTrackLength) - (veh1Node.size.height / 2)) - (t1Vehicle[nextIndex].position.y + (t1Vehicle[nextIndex].size.height / 2))    //Vehicle in front is over the 1km boundary!
                
                
                //NOTE: 0.5 lanewidth used for now due to in & out. May extend to 0.7 or so later!!!
                if !sameLane.contains(t1Vehicle[nextIndex].lane) {
                    //Both vehicles in different lanes
                    rearGap = (past1km == false) ? sameLap : lastLap
                    if rearGap <= 0 { rearGap = 0.1 }
                    //                    veh1Node.rearGap = rearGap
                    //                    } else {
                    //                        //The two vehicles are in the same lane
                    //                        nextIndex += 1  //Move onto next vehicle
                    //                        if nextIndex == index {         //All other vehicles checked. rearGap sb 0 here!
                    //                            if rearGap == 0 { rearGap = 1000 }
                    //                        }    //Continue until spacing for BOTH lanes != 0
                    
                }       //end lane check
                
            }               //end while
            
            t1Vehicle[index].rearGap = rearGap  // same as veh1Node.rearGap
            past1km = false
            rearGap = 0
            
        }               //end 1st for loop
        //########################### end rearGap calc loop #######################################
        
        t1Vehicle.sort(by: {$0.position.y < $1.position.y}) //Sort into positional order, 000 - 999.999
        
        t2Vehicle.sort(by: {$0.position.y < $1.position.y}) //Sort into positional order, 000 - 999.999
        
        var gap: CGFloat = 0.0      //Distance ahead in THIS lane
        var otherGap: CGFloat = 0.0     //Distance ahead in OTHER lane
        //    nextIndex = 0               //Not required - value loaded below!
        past1km = false
        
        //print("\nFront Gap Calcs")
        //print("No\tsKLName\t\tPos\t\tFrntN\t\tFPos\tGap")
        //Loop through arrays to confirm distance to vehicle in front
        //Loop through Track 1 (KL) first
        for (index, veh1Node) in t1Vehicle.enumerated() {
            
            //THIS Vehicle = veh1Node = sKLAllVehicles[unitNumb] = t1Vehicle[index]
            //NEXT Vehicle = t1Vehicle[nextIndex]
            
            unitNumb = Int.extractNum(from: veh1Node.name)! //NOTE: Use [unitNumb] for sKLAllVehicles. Use [index] OR [nextIndex] for t1Vehicles!
            
            nextIndex = index
            
            while gap == 0 || otherGap == 0 {       //Find both gap & otherGap
                
                nextIndex = nextIndex + 1       // same as nextIndex += 1
                
                if nextIndex >= numVehicles {
                    
                    nextIndex = 0       //Crossed 1km barrier. Continue search
                    past1km = true      //Flag indicates vehicle in front is beyond 1km boundary
                    
                }           //end nextIndex 'if' statement
                
                let sameLane = (veh1Node.lane - 0.5)...(veh1Node.lane + 0.5)   //Scan for vehicles within 0.5 lanes either side
                let sameLap = (t1Vehicle[nextIndex].position.y - (t1Vehicle[nextIndex].size.height / 2)) - (veh1Node.position.y + (veh1Node.size.height / 2))                             //Vehicle in front on same side of 1km boundary
                let lastLap = ((t1Vehicle[nextIndex].position.y + sTrackLength) - (t1Vehicle[nextIndex].size.height / 2)) - (veh1Node.position.y + (veh1Node.size.height / 2))      //Vehicle in front is over the 1km boundary!
                
                //NOTE: 0.5 lanewidth used for now due to in & out. May extend to 0.7 or so later!!!
                if sameLane.contains(t1Vehicle[nextIndex].lane) {
                    //Both vehicles in same lane
                    if gap == 0 {
                        gap = (past1km == false) ? sameLap : lastLap
                        if gap <= 0 { gap = 0.1 } //Should NEVER happen! (due to self braking)
                        //                    veh1Node.spacing = gap
                        t1Vehicle[index].frontUnit = t1Vehicle[nextIndex].name      //Save identity of front unit
                        t1Vehicle[index].frontPos = t1Vehicle[nextIndex].position   //Save position of front unit
                    }
                } else {
                    //The two vehicles are in different lanes
                    if otherGap == 0 {
                        otherGap = (past1km == false) ? sameLap : lastLap
                        if otherGap <= 0 { otherGap = 0.1 } //Could prevent -ve values by using <= here
                        //                    veh1Node.otherGap = otherGap
                    }
                }       //end lane check
                
                //                nextIndex += 1  //Move onto next vehicle
                //                if nextIndex == index {
                //                    if gap == 0 { gap = 1000 }
                //                    if otherGap == 0 { otherGap = 1000 } //NOTE: Don't yet know distance to vehicle behind in other lane!
                //                }    //Continue until spacing for BOTH lanes != 0
                ////            }           //end nextIndex 'if' statement
                
            }               //end While
            
            t1Vehicle[index].gap = gap              // same as veh1Node.gap
            t1Vehicle[index].otherGap = otherGap    // same as veh1Node.otherGap
            
            //MARK: - At this point spacing = distance to vehicle in front(gap: same lane, otherGap: other lane)
            //MARK:   rearGap = distance of first vehicle behind & in other lane.
            //NOTE: ALL values above can read negative IF position differences < vehicle lengths!
            //       (can be changed by using <= instead of == above)
            
            gapSpeed = (gap * 3.6) / gapVal     //Max allowable speed for current gap. gapVal = 3 secs
            goalSpeed = gapSpeed  //Aim for this speed while in this lane
            
            if gapSpeed > veh1Node.preferredSpeed {
                goalSpeed = veh1Node.preferredSpeed
            }
            else {          //
                //                goalSpeed = gapSpeed  //Already = gapSpeed
            }
            
            //Acceleration & deceleration fixed FOR NOW!!!
            //        var accel: CGFloat = 3    // m per sec2 (use 2?)
            var accel: CGFloat = 4.5    // m per sec2 (use 2?)
            //        var accel: CGFloat = 2    // m per sec2
            //    var truckAccel: CGFloat = 1.0
            //        var decelMax: CGFloat = 6.5 // m/sec2
            var decelMax: CGFloat = 8 // m/sec2
            //        var decelMin: CGFloat = 3.4  // m/sec2
            var decelMin: CGFloat = 4  // m/sec2
            //        var decel: CGFloat = 4    // m per sec2
            //    var truckDecel: CGFloat = 0.9
            let spdChange = abs(goalSpeed - veh1Node.currentSpeed)
            gapTime = (gap * 3.6) / veh1Node.currentSpeed   //Time in secs to catch vehicle in front @ current speed
            
            //MARK: - Create variable value of decel when gap 1 - 3 secs from vehicle in front
            if gapTime < (gapVal * 0.33) {
                decel = decelMax + 1                        //Max decel! Gap < 1 second. (+1 is TEMPORARY!!!)
            } else {
                if gapTime > gapVal {
                    decel = decelMin                        //Min decel! Gap > 3 seconds
                } else {                                    //Gap 1 - 3 seconds
                    gapTime = gapTime - (gapVal * 0.33)     //Change value from 1-3 to 0-2 (secs for gapVal = 3)
                    gapTime = gapTime / (gapVal * 0.67)     //Convert to ratio of 0-1
                    decel = decelMax - ((decelMax - decelMin) * gapTime)
                }
            }
            
            var changeTime: CGFloat = 1     //Set initial value = 1 second
            //    if sKLAllVehicles[index].currentSpeed >= goalSpeed {
            if veh1Node.currentSpeed >= goalSpeed {
                //Decelerate to goalSpeed which can be preferredSpeed or gapSpeed
                
                //MARK: - IF GAP << 3 SECS THEN INCREASE DECELERATION!!! See above
                if (spdChange / 3.6) > decel {      //spdChange in kph / 3.6 = m/s
                    changeTime = ((spdChange / 3.6) / decel)
                }   //else { changeTime = 1 }   //already = 1. Slows final deceleration
                
            } else {
                //Accelerate to goalSpeed which can be preferredSpeed or gapSpeed
                
                if (spdChange / 3.6) > accel {      //spdChange in kph / 3.6 = m/s
                    changeTime = ((spdChange / 3.6) / accel)
                }   //else { changeTime = 1 }   //already = 1. Slows final acceleration
                
            }
            
            //MARK: - aim for 'goalSpeed' after 'changeTime' seconds
            t1Vehicle[index].goalSpeed = goalSpeed   //Store ready for SKAction
            t1Vehicle[index].changeTime = changeTime //Store run time for next SKAction
            
            past1km = false
            gap = 0
            otherGap = 0
            
            //print("\(index)\t\(veh1Node.name)\t\t\(veh1Node.position.y.dp2)\t\(t1Vehicle[index].frontUnit)\t\t\(t1Vehicle[index].frontPos.y.dp2)\t\(t1Vehicle[index].gap.dp2)") //veh1Node.name) = sKLAllVehicles[unitNumb].name = t1Vehicle[index].name = THIS Vehicle
            
        }           //end 2nd for loop
        
        return (t1Vehicle, t2Vehicle)
    }       //End findObstacles method
    
    //This method calculates the position of vehicles on the Fig 8 Track from equiv positions on Straight Track
    //Make the method below part of the NodeData Struct
    func findF8Pos(t1Veh: inout [NodeData]) async -> ([NodeData]) {         //Note: t1Veh has stKL_0 or stOt_0 removed!
        
        var f8EquivName: String = ""
        
        for (indx, t1Node) in t1Veh.enumerated() {
            if indx == 0 {continue}         //Skip loop for element[0] = All Vehicles

            //MARK: - Find name of Fig 8 Track equivalent to Straight Track Vehicle
            //          eg.stKL_8 -> f8KL_8 OR stOT_35 -> f8Ot_35
            f8EquivName = String(t1Node.name.dropFirst(2))        //Remove 'st' from start of name
            f8EquivName.insert(contentsOf: "//f8", at: f8EquivName.startIndex)
            t1Veh[indx].equivF8Name = f8EquivName
            
            //    guard let f8Node = childNode(withName: f8EquivName) else {
            //        return
            //    }
            
            //May? need following ??
            var lanePos: CGFloat = ((FarLane - CloseLane) * (1 - t1Node.lane) + CloseLane)
            if t1Node.otherTrack == true {     //If tracks back to front, reverse polarity here!!! Swaps Fig 8 vehicles from one
                //track to the other AND swaps left/right lanes. Doesn't affect Straight Track!
                lanePos = -lanePos
            }
            
            var newF8NodePos = t1Node.f8Pos         //???
            var currentSNodePos = t1Node.position   //???
            
            //MARK: - Calculate position of figure 8 vehicle based on straight track vehicle
            switch t1Node.position.y {
            case let y1 where y1 <= F8Radius:
                //1st straight stretch 45' from origin dn and to right
                //Origin = (0,0) so move immediately
                newF8NodePos.x = 0 + (cos45Deg * y1)
                newF8NodePos.y = 0 - (sin45Deg * y1)
                
                newF8NodePos.x = newF8NodePos.x + (cos45Deg * lanePos)
                newF8NodePos.y = newF8NodePos.y + (sin45Deg * lanePos)
                
                t1Veh[indx].f8Rot = t1Node.otherTrack ? CGFloat(45).degrees() : -CGFloat(135).degrees()
                
                t1Veh[indx].f8Pos = CGPoint(x: newF8NodePos.x, y: newF8NodePos.y)
                t1Veh[indx].f8zPos = 10       //Set zPosition lower than bridge (zPos: 15)
                
                //            let newF8Pos = SKAction.move(to: f8NodePos, duration: actionTimeF8)
                //            let newF8Rot = SKAction.rotate(toAngle: f8NodeRot, duration: actionTimeF8, shortestUnitArc: true)
                //            let group = SKAction.group([newF8Pos, newF8Rot])
                //
                //            f8Node.run(group, withKey: "key")
                //
            case var y1 where y1 <= (F8Radius + (piBy1p5 * F8Radius)):
                //1st 3/4 circle heading down and to left
                y1 = y1 - F8Radius
                
                var y1Deg: CGFloat = -y1 * y1Mx      //Defines angle change from start of 3/4 circle to current position
                y1Deg = y1Deg + 45                  //Start from angle 3 o'clock
                
                newF8NodePos.x = CGFloat(0)         //Sets starting position to circle centre
                newF8NodePos.y = -f8CircleCentre - fudgeFactor  //If fudgeFactor used, need to move centre of circle!
                let laneRadius: CGFloat = F8Radius + lanePos
                
                newF8NodePos.x = newF8NodePos.x + ((laneRadius + fudgeFactor) * cos(CGFloat(y1Deg).degrees()))
                newF8NodePos.y = newF8NodePos.y + ((laneRadius + fudgeFactor) * sin(CGFloat(y1Deg).degrees()))
                
                t1Veh[indx].f8Pos = CGPoint(x: newF8NodePos.x, y: newF8NodePos.y)
                
                if t1Node.otherTrack == false { y1Deg = y1Deg - 180}    //Turns vehicle 180 degrees
                if y1Deg < -180 { y1Deg = y1Deg + 360 }  //Resolves node spinning problem
                t1Veh[indx].f8Rot = y1Deg.degrees()
                
                //        let newF8Pos = SKAction.move(to: f8NodePos, duration: actionTimeF8)
                //        let newF8Rot = SKAction.rotate(toAngle: f8NodeRot, duration: actionTimeF8, shortestUnitArc: true)
                //        let group = SKAction.group([newF8Pos, newF8Rot])
                //
                //        f8Node.run(group, withKey: "key")
                
            case var y1 where y1 <= ((3 * F8Radius) + (piBy1p5 * F8Radius)):
                //2nd straight stretch 45' up to right
                y1 = y1 - (F8Radius + (piBy1p5 * F8Radius))
                
                newF8NodePos.x = -halfDiagonalXY    //Point 75m diagonally down & to left of origin
                newF8NodePos.y = -halfDiagonalXY
                
                newF8NodePos.x = newF8NodePos.x + (cos45Deg * y1)
                newF8NodePos.y = newF8NodePos.y + (sin45Deg * y1)
                
                newF8NodePos.x = newF8NodePos.x - (cos45Deg * lanePos)
                newF8NodePos.y = newF8NodePos.y + (sin45Deg * lanePos)
                
                t1Veh[indx].f8Rot = t1Node.otherTrack ? CGFloat(135).degrees() : -CGFloat(45).degrees()
                
                t1Veh[indx].f8Pos = CGPoint(x: newF8NodePos.x, y: newF8NodePos.y)
                t1Veh[indx].f8zPos = 20       //Set zPosition higher than bridge (zPos: 15)
                
                //        let newF8Pos = SKAction.move(to: f8NodePos, duration: actionTimeF8)
                //        let newF8Rot = SKAction.rotate(toAngle: f8NodeRot, duration: actionTimeF8, shortestUnitArc: true)
                //        let group = SKAction.group([newF8Pos, newF8Rot])
                //
                //        f8Node.run(group, withKey: "key")
                
            case var y1 where y1 <= ((3 * F8Radius) + (piBy3 * F8Radius)):
                //2nd 3/4 circle heading up and to left
                y1 = y1 - ((3 * F8Radius) + (piBy1p5 * F8Radius))
                
                var y1Deg: CGFloat = y1 * y1Mx      //Defines angle change from start of 3/4 circle to current position
                y1Deg = y1Deg - 45                  //Start from angle 3 o'clock
                
                newF8NodePos.x = CGFloat(0)         //Sets starting position to circle centre
                newF8NodePos.y = f8CircleCentre + fudgeFactor  //If fudgeFactor used, need to move centre of circle!
                let laneRadius: CGFloat = F8Radius - lanePos
                
                newF8NodePos.x = newF8NodePos.x + ((laneRadius + fudgeFactor) * cos(CGFloat(y1Deg).degrees()))
                newF8NodePos.y = newF8NodePos.y + ((laneRadius + fudgeFactor) * sin(CGFloat(y1Deg).degrees()))
                
                t1Veh[indx].f8Pos = CGPoint(x: newF8NodePos.x, y: newF8NodePos.y)
                
                if t1Node.otherTrack == true { y1Deg = y1Deg + 180}    //Turns vehicle 180 degrees
                if y1Deg > 180 { y1Deg = y1Deg - 360 }  //Resolves node spinning problem
                t1Veh[indx].f8Rot = y1Deg.degrees()
                
                //        let newF8Pos = SKAction.move(to: f8NodePos, duration: actionTimeF8)
                //        let newF8Rot = SKAction.rotate(toAngle: f8NodeRot, duration: actionTimeF8, shortestUnitArc: true)
                //        let group = SKAction.group([newF8Pos, newF8Rot])
                //
                //        f8Node.removeAction(forKey: "key")
                //        f8Node.run(group, withKey: "key")
                
            case var y1 where y1 <= ((4 * F8Radius) + (piBy3 * F8Radius)):
                //3rd & final straight stretch 45' down & back to origin
                //            y1 = y1 - ((3 * F8Radius) + (piBy3 * F8Radius))
                y1 = ((4 * F8Radius) + (piBy3 * F8Radius)) - y1    //Changes y1 so 1006.858 (for F8Radius = 75m) = the origin (easier calculation)
                
                newF8NodePos.x = -(cos45Deg * y1)
                newF8NodePos.y = (sin45Deg * y1)
                
                newF8NodePos.x = newF8NodePos.x + (cos45Deg * lanePos)
                newF8NodePos.y = newF8NodePos.y + (sin45Deg * lanePos)
                
                t1Veh[indx].f8Rot = t1Node.otherTrack ? CGFloat(45).degrees() : -CGFloat(135).degrees()
                
                t1Veh[indx].f8Pos = CGPoint(x: newF8NodePos.x, y: newF8NodePos.y)
                t1Veh[indx].f8zPos = 10       //Set zPosition lower than bridge (zPos: 15)
                
                //        let newF8Pos = SKAction.move(to: f8NodePos, duration: actionTimeF8)
                //        let newF8Rot = SKAction.rotate(toAngle: f8NodeRot, duration: actionTimeF8, shortestUnitArc: true)
                //        let group = SKAction.group([newF8Pos, newF8Rot])
                //
                //        f8Node.run(group, withKey: "key")
                
            default:
                break
                
            }           //end Switch statement
            
        }           //End t1Node 'for' loop
        
        return t1Veh
    }           //end findF8Pos method
    
    //MARK: - Method below is to calculate display values. Once every 500-600ms sufficient.
    //Note element[0] (All Vehicles) already removed!
    func calcAvgData(t1Veh: inout [NodeData]) async -> ([NodeData]) {
        
//        print("3x.\tMax: \(t1Veh[1].speedMax.dp2)\tAvg: \(t1Veh[1].speedAvg.dp2)\tMin: \(t1Veh[1].speedMin.dp2)")
//        print("3y.\tMax: \(t1Veh[1].distanceMax.dp2)\tAvg: \(t1Veh[1].distance.dp2)\tMin: \(t1Veh[1].distanceMin.dp2)")

//        var t1Vehicle = sKLAllVehicles   //Straight Track Vehicles
        var t2Veh = sOtherAllVehicles       //TEMP!!!
        
        var sumKL: CGFloat = 0
        var maxSumKL: CGFloat = 0
        var minSumKL: CGFloat = 99999999
//        var sumOther: CGFloat = 0         //Other Track - May use separate routine???
//        var maxSumOther: CGFloat = 0
//        var minSumOther: CGFloat = 99999999
        
//        var tempSpd: CGFloat = 0          //Needed?
        
        //MARK: - Set timeMx = hours of vehicle run time to now!
        let timeMx: CGFloat = 3600 / runTimer
        
        var unitNo: Int = 0
        var uNum: Int = 0
        //Loop through both arrays simultaneously. Move back 1km when they've travelled 1km!
        //IF OTHER TRACK RUN SEPARATELY THIS MAY CHANGE! NOTE TOO THAT ARRAYS NOT IN ORDER!
        for (innDex, sKLNode) in t1Veh.enumerated() {
//        for (var sKLNode, var sOtherNode) in zip(t1Veh, t2Veh) {
            if innDex == 0 {continue}       //Skip loop for element[0] = All Vehicles

//          //Check below elsewhere!
//            if sKLNode.position.y >= sTrackLength {
//                //IMPORTANT!!! ??? Prevent change to pos.y in other thread during the following instruction !!!
//                sKLNode.position.y = (sKLNode.position.y - sTrackLength)
//                sKLNode.laps += 1
//            }
            
            unitNo += 1
            
//            //Check below elsewhere!
//            //MARK: - Flash vehicle when data displayed for single vehicle only
//            flashVehicle(thisVehicle: sKLNode)
            
//            print("1.\t\(t1Veh[innDex].speedMax.dp2)\t\(t1Veh[innDex].speedMin.dp2)")
            t1Veh[innDex].distance = (t1Veh[innDex].position.y - t1Veh[innDex].startPos) / sTrackLength + t1Veh[innDex].laps                //Distance travelled in km

            if firstThru == true {                  //Ensures initial reading > max possible speed
                t1Veh[innDex].speedMin = 900
//                sOtherNode.speedMin = 900
            }
            
            t1Veh[innDex].speedAvg = t1Veh[innDex].distance * timeMx                //Average speed for vehicle
            t1Veh[innDex].speedMax = max(t1Veh[innDex].speedMax, t1Veh[innDex].speedAvg)  //Max avg speed for vehicle
            if enableMinSpeed == true {         //Currently 12secs? Later wait for vehicles up to speed
                t1Veh[innDex].speedMin = min(t1Veh[innDex].speedMin, t1Veh[innDex].speedAvg)
            }           //Min avg speed for vehicle. Ignores acceleration period.
            
            sumKL += t1Veh[innDex].distance                   //All veh's: Total distance for all summed
            maxSumKL = max(maxSumKL, t1Veh[innDex].distance)  //Max distance by a single vehicle NOW
            minSumKL = min(minSumKL, t1Veh[innDex].distance)  //Min distance for a single vehicle NOW
            
//            print("2.\t\(t1Veh[innDex].speedMax.dp2)\t\(t1Veh[innDex].speedMin.dp2)")

//            print("3a.\tMax: \(t1Veh[1].speedMax.dp2)\tAvg: \(t1Veh[1].speedAvg.dp2)\tMin: \(t1Veh[1].speedMin.dp2)")
//            print("3b.\tMax: \(t1Veh[1].distanceMax.dp2)\tAvg: \(t1Veh[1].distance.dp2)\tMin: \(t1Veh[1].distanceMin.dp2)")

//            //Check below elsewhere!
//            if sOtherNode.position.y < 0 {
//                //IMPORTANT!!! ??? Prevent change to pos.y in other thread during the following instruction !!!
//                sOtherNode.position.y = (sOtherNode.position.y + sTrackLength)
//                sOtherNode.laps += 1
//            }
            
//            //Other Track - May use separate routine???
//            sOtherNode.distance = (sOtherNode.startPos - sOtherNode.position.y) / sTrackLength + sOtherNode.laps    //Distance travelled in km
//
//            sOtherNode.speedAvg = sOtherNode.distance * timeMx                  //Average speed for vehicle
//            sOtherNode.speedMax = max(sOtherNode.speedMax, sOtherNode.speedAvg) //Max avg speed for vehicle
//            if enableMinSpeed == true {
//                sOtherNode.speedMin = min(sOtherNode.speedMin, sOtherNode.speedAvg)
//            }           //Min avg speed for vehicle. Ignores acceleration period.
//
//            sumOther += sOtherNode.distance   //Total distance
//            maxSumOther = max(maxSumOther, sOtherNode.distance)
//            minSumOther = min(minSumOther, sOtherNode.distance)
            
//            uNum = Int.extractNum(from: sKLNode.name)!  //Find current unit number
//            t1Veh[uNum] = sKLNode                     //t1Veh[0] (All Vehicles) has been removed
            
//            print("Spd\t1\(t1Veh[unitNo].name)\tMax: \(t1Veh[unitNo].speedMax.dp2)\tAvg: \(t1Veh[unitNo].speedAvg.dp2)\tMin: \(t1Veh[unitNo].speedMin.dp2)\ttimeX: \(timeMx.dp2)")
//            print("Dis\t1\(t1Veh[unitNo].name)\tMax: \(t1Veh[unitNo].distanceMax.dp2)\tAvg: \(t1Veh[unitNo].distance.dp2)\tMin: \(t1Veh[unitNo].distanceMin.dp2)")

        }   //End of 'for' loop

        firstThru = false       //NEVER = true again !!!
        
        //MARK: - Calculate distances & speeds for 'All Vehicles'
        //Note: Avg Speed = speed to drive Avg Distance.
        //      Max Speed = Avg Speed of vehicle that has driven furthest
        //      Min Speed = Avg Speed of vehicle that has driven the least distance
        //(Note: @ present (24/8/22) avg, max & min the same as all vehicles driven at same speed over same distance.
        klDistance0 = sumKL / CGFloat(numVehicles)
        klDistanceMax0 = maxSumKL
        klDistanceMin0 = minSumKL
        
        klSpeedAvg0 = klDistance0 * timeMx
        klSpeedMax0 = maxSumKL * timeMx
        klSpeedMin0 = minSumKL * timeMx
        
//        //Other Track - May use separate routine???
//        oDistance0 = sumOther / CGFloat(numVehicles)
//        oDistanceMax0 = maxSumOther
//        oDistanceMin0 = minSumOther
//
//        oSpeedAvg0 = oDistance0 * timeMx
//        oSpeedMax0 = maxSumOther * timeMx
//        oSpeedMin0 = minSumOther * timeMx
        
//        topLabel.updateLabel(topLabel: true, vehicel: sKLAllVehicles[f8DisplayDat])
//        bottomLabel.updateLabel(topLabel: false, vehicel: sOtherAllVehicles[f8DisplayDat])
        
//        print("3a.\tMax: \(t1Veh[1].speedMax.dp2)\tAvg: \(t1Veh[1].speedAvg.dp2)\tMin: \(t1Veh[1].speedMin.dp2)")

    return t1Veh
}       //end calcAvgData


}       //end of struct NodeData
