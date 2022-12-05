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
    var oRearGap: CGFloat
    var preferredSpeed: CGFloat
    var currentSpeed: CGFloat
    var goalSpeed: CGFloat
    var changeTime: CGFloat
    var frontUnit: String       //Name of vehicle in front = 1 - numVehicles
    var frontPos: CGPoint       //Position of vehicle in front
    var frontSpd: CGFloat       //Speed of vehicle in front
    var oFrontSpd: CGFloat      //Speed of vehicle in front in Other lane
    var rearUnit: String        //Name of vehicle behind
    var rearPos: CGPoint        //Position of vehicle behind
    var oRearSpd: CGFloat       //Speed of vehicle behind in Other lane
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
        oRearGap = 0
        preferredSpeed = 0
        currentSpeed = 0
        goalSpeed = 0
        changeTime = 0
        frontUnit = ""
        frontPos = CGPoint(x: 0, y: 0)
        frontSpd = 0
        oFrontSpd = 0
        rearUnit = ""
        rearPos = CGPoint(x: 0, y: 0)
        oRearSpd = 0
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
    
    
    //    mutating func findObstacles(tVehicle: inout [NodeData]) async -> (tVehicle: [NodeData], t2Vehicle: [NodeData]) {
    func findObstacles(tVehicle: inout [NodeData]) async -> ([NodeData]) {
        //Create copy of vehicles for calculating proximity to other vehicles
        //  Do calculations on background thread
        //
        //    var tVehicle = sKLAllVehicles.map{ $0.copy() }      //Straight Track Vehicles: Ignore 'All Vehicles'
        //    var tVehicle = sKLAllVehicles.dropFirst()
        //    tVehicle.sort(by: {$0.position.y < $1.position.y}) //Sort into positional order, 000 - 999.999
        
        var gapSpeed: CGFloat = 0       //Speed required to catch vehicle in front in 3 secs
        var goalSpeed: CGFloat = 0      //Lesser of gapSpeed & preferredSpeed (reduced if closer than 3 secs to veh in front)
        var gapTime: CGFloat = 0        //Time in secs to catch vehicle in front @ current speed
        var decel: CGFloat = 4          // m/sec2. Typical. Varies!
        
        //########################### RearGap calc loop #######################################
        tVehicle.sort(by: {$0.position.y > $1.position.y}) //Sort into positional order, 999.999 - 000
        
        var unitNumb: Int
        var rearGap: CGFloat = 0.0      //Distance behind in this lane
        var oRearGap: CGFloat = 0.0     //Distance behind in OTHER lane
        var nextIndex: Int = 0
        var past1km = false
        
        //Loop through arrays to confirm distance to vehicle behind in the other lane
        //Loop through Track 1 (KL) first
        for (index, vehNode) in tVehicle.enumerated() {
            
            //THIS Vehicle = vehNode = sKLAllVehicles[unitNumb] = tVehicle[index]
            //NEXT Vehicle = tVehicle[nextIndex]
            
            unitNumb = Int.extractNum(from: vehNode.name)! //NOTE: Use [unitNumb] for sKLAllVehicles. Use [index] OR [nextIndex] for tVehicles!
            
            nextIndex = index
            
            while rearGap == 0 || oRearGap == 0 {
                
                nextIndex = nextIndex + 1       // same as nextIndex += 1
                
                if nextIndex >= numVehicles {
                    
                    nextIndex = 0       //Crossed 1km barrier. Continue search
                    past1km = true      //Flag indicates vehicle behind is beyond 1km boundary
                    
                }           //end nextIndex 'if' statement
                
                let sameLane = (vehNode.lane - 0.5)...(vehNode.lane + 0.5)   //Scan for vehicles within 0.5 lanes either side
                let sameLap = (vehNode.position.y - (vehNode.size.height / 2)) - (tVehicle[nextIndex].position.y + (tVehicle[nextIndex].size.height / 2)) //Vehicle in front on same side of 1km boundary
                let lastLap = ((vehNode.position.y + sTrackLength) - (vehNode.size.height / 2)) - (tVehicle[nextIndex].position.y + (tVehicle[nextIndex].size.height / 2))    //Vehicle in front is over the 1km boundary!
                
                
                //NOTE: 0.5 lanewidth used for now due to in & out. May extend to 0.7 or so later!!!
                if sameLane.contains(tVehicle[nextIndex].lane) {
                    //Both vehicles in same lane
                    if rearGap == 0 {
                        rearGap = (past1km == false) ? sameLap : lastLap
                        if rearGap <= 0 { rearGap = 0.1 } //Should NEVER happen! (due to self braking)
                        //                    vehNode.spacing = gap
                        tVehicle[index].rearUnit = tVehicle[nextIndex].name      //Save identity of rear unit (NOT Required?)
                        tVehicle[index].rearPos = tVehicle[nextIndex].position   //Save position of rear unit (NOT Required?)
                    }
                } else {
                    //The two vehicles are in different lanes
                    if oRearGap == 0 {
                        oRearGap = (past1km == false) ? sameLap : lastLap
                        if oRearGap <= 0 { oRearGap = 0.1 } //Could prevent -ve values by using <= here
                        //                    vehNode.oRearGap = oRearGap
                        tVehicle[index].oRearSpd = tVehicle[nextIndex].currentSpeed   //Save identity of rear unit (NOT Required?)
                    }
                }       //end lane check
                
//                //@@@@@@@@@@@@ Old Lane Check - Start @@@@@@@
//                //NOTE: 0.5 lanewidth used for now due to in & out. May extend to 0.7 or so later!!!
//                if !sameLane.contains(tVehicle[nextIndex].lane) {
//                    //Both vehicles in different lanes
//                    oRearGap = (past1km == false) ? sameLap : lastLap
//                    if oRearGap <= 0 { oRearGap = 0.1 }
//                    //                    vehNode.oRearGap = oRearGap
//                    //                    } else {
//                    //                        //The two vehicles are in the same lane
//                    //                        nextIndex += 1  //Move onto next vehicle
//                    //                        if nextIndex == index {         //All other vehicles checked. oRearGap sb 0 here!
//                    //                            if oRearGap == 0 { oRearGap = 1000 }
//                    //                        }    //Continue until spacing for BOTH lanes != 0
//
//                }       //end lane check
//                //@@@@@@@@@@@@ Old Lane Check - End   @@@@@@@

            }               //end while
            
            tVehicle[index].rearGap = rearGap      // same as vehNode.rearGap
            tVehicle[index].oRearGap = oRearGap    // same as vehNode.oRearGap
            past1km = false
            rearGap = 0
            oRearGap = 0
            
        }               //end 1st for loop
        //########################### end RearGap calc loop #######################################
        
        tVehicle.sort(by: {$0.position.y < $1.position.y}) //Sort into positional order, 000 - 999.999
        
//        t2Vehicle.sort(by: {$0.position.y < $1.position.y}) //Sort into positional order, 000 - 999.999
        
        var gap: CGFloat = 0.0      //Distance ahead in THIS lane
        var otherGap: CGFloat = 0.0     //Distance ahead in OTHER lane
        //    nextIndex = 0               //Not required - value loaded below!
        past1km = false
        
        //Loop through arrays to confirm distance to vehicle in front
        //Loop through Track 1 (KL) first
        for (index, vehNode) in tVehicle.enumerated() {
            
            //THIS Vehicle = vehNode = sKLAllVehicles[unitNumb] = tVehicle[index]
            //NEXT Vehicle = tVehicle[nextIndex]
            
            unitNumb = Int.extractNum(from: vehNode.name)! //NOTE: Use [unitNumb] for sKLAllVehicles. Use [index] OR [nextIndex] for tVehicles!
            
            nextIndex = index
            
            while gap == 0 || otherGap == 0 {       //Find both gap & otherGap
                
                nextIndex = nextIndex + 1       // same as nextIndex += 1
                
                if nextIndex >= numVehicles {
                    
                    nextIndex = 0       //Crossed 1km barrier. Continue search
                    past1km = true      //Flag indicates vehicle in front is beyond 1km boundary
                    
                }           //end nextIndex 'if' statement
                
                let sameLane = (vehNode.lane - 0.5)...(vehNode.lane + 0.5)   //Scan for vehicles within 0.5 lanes either side
                let sameLap = (tVehicle[nextIndex].position.y - (tVehicle[nextIndex].size.height / 2)) - (vehNode.position.y + (vehNode.size.height / 2))                             //Vehicle in front on same side of 1km boundary
                let lastLap = ((tVehicle[nextIndex].position.y + sTrackLength) - (tVehicle[nextIndex].size.height / 2)) - (vehNode.position.y + (vehNode.size.height / 2))      //Vehicle in front is over the 1km boundary!
                
                //NOTE: 0.5 lanewidth used for now due to in & out. May extend to 0.7 or so later!!!
                if sameLane.contains(tVehicle[nextIndex].lane) {
                    //Both vehicles in same lane
                    if gap == 0 {
                        gap = (past1km == false) ? sameLap : lastLap
                        if gap <= 0 { gap = 0.1 } //Should NEVER happen! (due to self braking)
                        //                    vehNode.spacing = gap
                        tVehicle[index].frontUnit = tVehicle[nextIndex].name      //Save identity of front unit
                        tVehicle[index].frontPos = tVehicle[nextIndex].position   //Save position of front unit
                        tVehicle[index].frontSpd = tVehicle[nextIndex].currentSpeed   //Save identity of rear unit (NOT Required?)
                    }
                } else {
                    //The two vehicles are in different lanes
                    if otherGap == 0 {
                        otherGap = (past1km == false) ? sameLap : lastLap
                        if otherGap <= 0 { otherGap = 0.1 } //Could prevent -ve values by using <= here
                        //                    vehNode.otherGap = otherGap
                        tVehicle[index].oFrontSpd = tVehicle[nextIndex].currentSpeed   //Save identity of rear unit (NOT Required?)
                    }
                }       //end lane check
                
            }               //end While
            
            tVehicle[index].gap = gap              // same as vehNode.gap
            tVehicle[index].otherGap = otherGap    // same as vehNode.otherGap
            
            //MARK: - At this point spacing = distance to vehicle in front(gap: same lane, otherGap: other lane)
            //MARK:   oRearGap = distance of first vehicle behind & in other lane.
            //NOTE: ALL values above can read negative IF position differences < vehicle lengths!
            //       (Has been changed by using <= instead of == above)
            
            gapSpeed = (gap * 3.6) / gapVal     //Max allowable speed for current gap. gapVal = 3 secs
            goalSpeed = gapSpeed  //Aim for this speed while in this lane
            
            if gapSpeed > vehNode.preferredSpeed {
                goalSpeed = vehNode.preferredSpeed
            }
            else {          //
                //                goalSpeed = gapSpeed  //Already = gapSpeed
            }
            
            //Acceleration & deceleration fixed FOR NOW!!!
            var accel: CGFloat = 4.5    // m per sec2 (use 2?)
            //    var truckAccel: CGFloat = 1.0
            var decelMax: CGFloat = 8 // m/sec2
            var decelMin: CGFloat = 4  // m/sec2
            //        var decel: CGFloat = 4    // m per sec2
            //    var truckDecel: CGFloat = 0.9
            let spdChange = abs(goalSpeed - vehNode.currentSpeed)
            gapTime = (gap * 3.6) / vehNode.currentSpeed   //Time in secs to catch vehicle in front @ current speed
            
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
            if vehNode.currentSpeed >= goalSpeed {
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
            tVehicle[index].goalSpeed = goalSpeed   //Store ready for SKAction
            tVehicle[index].changeTime = changeTime //Store run time for next SKAction
            
            past1km = false
            gap = 0
            otherGap = 0
            
        }           //end 2nd for loop
        
//        return (tVehicle, t2Vehicle)
        return tVehicle
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
//        var t2Veh = sOtherAllVehicles       //TEMP!!!
        
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
