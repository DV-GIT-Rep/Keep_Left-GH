//
//  NodeData.swift
//  Keep Left
//
//  Created by Bill Drayton on 5/10/2022.
//

import Foundation
import SpriteKit


struct NodeData {

//    enum Indicator {
//        case off                //Vehicle in left or right lane
//        case overtake           //Vehicle changing to overtaking (right) lane
//        case end_overtake       //Vehicle returning to normal (left) lane
//    }
//
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
    
    var sumKL: CGFloat
    var maxSumKL: CGFloat
    var minSumKL: CGFloat
    
    var spdClk: Int
    var reachedSpd: Bool     //Set for each vehicle when it reaches speed. Cleared when vehicles stopped.
    var indicator: Indicator
    
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
        changeTime = 1.0
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
        speedMin = 999999       //Set to >500 to start
        speedMax = 0
        
        sumKL = 0               //Used to calculate distance in km for ALL vehicles.
        maxSumKL = 0            //Used to hold the MAX distance ANY vehicle on THIS track has travelled.
        minSumKL = 99999999     //Used to hold the MIN distance ANY vehicle on THIS track has travelled.
        
        spdClk = 60         //Dummy value to start. 0.12sec * 60 = 7.2 secs
        reachedSpd = false
        
        indicator = .off
    }
    
//*****************************
//Flowchart Page 1 of 4     :Determine Rear Gaps etc
//*****************************
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
        tVehicle.sort(by: keepLeft ? {$0.position.y > $1.position.y} : {$0.position.y <= $1.position.y}) //Sort into positional order, 999.999 - 000
        
        var unitNumb: Int
        var rearGap: CGFloat = 0.0      //Distance behind in this lane
        var oRearGap: CGFloat = 0.0     //Distance behind in OTHER lane
        var nextIndex: Int = 0
        var past1km = false
        let midLanes = 0.2...0.8
        
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
                
                let sameLane = (vehNode.lane - 0.8)...(vehNode.lane + 0.8)   //Scan for vehicles within 0.8 lanes either side
                //                let sameLane = (vehNode.lane - 0.5) < 0 ? 0...(vehNode.lane + 0.5) : (vehNode.lane + 0.5) <= 1 ? (vehNode.lane - 0.5)...(vehNode.lane + 0.5) : (vehNode.lane - 0.5)...1   //Scan for vehicles within 0.5 lanes either side
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
                    if midLanes.contains(tVehicle[nextIndex].lane) {
                        //If this vehicle is mid-lane, set oRearGap = rearGap
                        if oRearGap == 0 {
                            oRearGap = (past1km == false) ? sameLap : lastLap
                            if oRearGap <= 0 { oRearGap = 0.1 } //Could prevent -ve values by using <= here
                            //                    vehNode.oRearGap = oRearGap
                            tVehicle[index].oRearSpd = tVehicle[nextIndex].currentSpeed   //Save speed of oRear unit
                        }
                    }
                } else {
                    //The two vehicles are in different lanes
                    if oRearGap == 0 {
                        oRearGap = (past1km == false) ? sameLap : lastLap
                        if oRearGap <= 0 { oRearGap = 0.1 } //Could prevent -ve values by using <= here
                        //                    vehNode.oRearGap = oRearGap
                        tVehicle[index].oRearSpd = tVehicle[nextIndex].currentSpeed   //Save speed of oRear unit
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
                
            }               //end 'While' loop
            
            tVehicle[index].rearGap = rearGap      // same as vehNode.rearGap
            tVehicle[index].oRearGap = oRearGap    // same as vehNode.oRearGap
            past1km = false
            rearGap = 0
            oRearGap = 0
            
        }               //end 1st 'For' loop
        //########################### end RearGap calc loop #######################################
        
        //*****************************
        //Flowchart Page 2 of 4     :Determine Front Gaps etc
        //*****************************
        tVehicle.sort(by: keepLeft ? {$0.position.y < $1.position.y} : {$0.position.y >= $1.position.y}) //Sort into positional order, 000 - 999.999
        
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
                
                let sameLane = (vehNode.lane - 0.8)...(vehNode.lane + 0.8)   //Scan for vehicles within 0.8 lanes either side
                //                let sameLane = (vehNode.lane - 0.5) < 0 ? 0...(vehNode.lane + 0.5) : (vehNode.lane + 0.5) <= 1 ? (vehNode.lane - 0.5)...(vehNode.lane + 0.5) : (vehNode.lane - 0.5)...1   //Scan for vehicles within 0.5 lanes either side
                let sameLap = (tVehicle[nextIndex].position.y - (tVehicle[nextIndex].size.height / 2)) - (vehNode.position.y + (vehNode.size.height / 2))                             //Vehicle in front on same side of 1km boundary
                let lastLap = ((tVehicle[nextIndex].position.y + sTrackLength) - (tVehicle[nextIndex].size.height / 2)) - (vehNode.position.y + (vehNode.size.height / 2))      //Vehicle in front is over the 1km boundary!
                
                //NOTE: 0.5 lanewidth used for now due to in & out. May extend to 0.7 or so later!!!
                if sameLane.contains(tVehicle[nextIndex].lane) {
                    //Both vehicles in same lane +/- 0.8
                    if gap == 0 {
                        gap = (past1km == false) ? sameLap : lastLap
                        if gap <= 0 { gap = 0.1 } //Should NEVER happen! (due to self braking)
                        //                    vehNode.spacing = gap
                        tVehicle[index].frontUnit = tVehicle[nextIndex].name      //Save identity of front unit
                        tVehicle[index].frontPos = tVehicle[nextIndex].position   //Save position of front unit
                        tVehicle[index].frontSpd = tVehicle[nextIndex].currentSpeed   //Save speed of front unit
                    }
                    if midLanes.contains(tVehicle[nextIndex].lane) {            //midLanes = 0.2 - 0.8
                        //If this vehicle is mid-lane, set otherGap = gap
                        if otherGap == 0 {
                            otherGap = (past1km == false) ? sameLap : lastLap
                            if otherGap <= 0 { otherGap = 0.1 } //Could prevent -ve values by using <= here
                            //                    vehNode.otherGap = otherGap
                            tVehicle[index].oFrontSpd = tVehicle[nextIndex].currentSpeed   //Save speed of oFront unit
                        }
                    }
                } else {
                    //The two vehicles are in different lanes ie.> 0.8 lanes away from this lane!
                    if otherGap == 0 {
                        otherGap = (past1km == false) ? sameLap : lastLap
                        if otherGap <= 0 { otherGap = 0.1 } //Could prevent -ve values by using <= here
                        //                    vehNode.otherGap = otherGap
                        tVehicle[index].oFrontSpd = tVehicle[nextIndex].currentSpeed   //Save speed of oFront unit
                    }
                }       //end lane check
                
            }               //end While
            
            tVehicle[index].gap = gap              // same as vehNode.gap
            tVehicle[index].otherGap = otherGap    // same as vehNode.otherGap
            
            //*****************************
            //Flowchart Page 3 of 4     :Determine decel & goalSpeed etc
            //*****************************
            //MARK: - At this point spacing = distance to vehicle in front(gap: same lane, otherGap: other lane)
            //MARK:   oRearGap = distance of first vehicle behind & in other lane.
            //NOTE: ALL values above can read negative IF position differences < vehicle lengths!
            //       (Has been changed by using <= instead of == above)
            
            //Acceleration & deceleration fixed FOR NOW!!!
            var accel: CGFloat = 4.5    // m per sec2 (use 2?)
            var accelMin: CGFloat = accel   //NOT USED YET! Use to determine spdClk.
            //    var truckAccel: CGFloat = 1.0
            var decelMax: CGFloat = 8 // m/sec2
            var decelMin: CGFloat = 4  // m/sec2
            var decelCoast: CGFloat = 0.1       // m/sec2. Rate when vehicle in front is faster
            //        var decel: CGFloat = 4    // m per sec2
            //    var truckDecel: CGFloat = 0.9
            
            gapTime = (gap * 3.6) / vehNode.currentSpeed   //Time in secs to catch vehicle in front @ current speed

            //MARK: - Create variable value of decel when gap 1 - 3 secs from vehicle in front
            //        Note gapVal = max allowed gap = 3 seconds.
            if gapTime > gapVal {                   //gapTime > 3 secs? (gapVal = 3 secs)
                decel = decelMin                    //Min decel! Gap >= 3 seconds

                goalSpeed = (gap * 3.6) / gapVal     //Max allowable speed for current gap. gapVal = 3 secs
                //  gap = metres to vehicle in front.
                //  Multiply 'gap' * 3.6 & then divide by no. of secs (=3 secs) gives kph required to traverse gap in 3 secs.
                //  Therefore gapSpeed is in kph!
                //gapSpeed = goalSpeed              //gapSpeed no longer used but sb speed to close 'gap' in 3s
                
            } else {                                //gapTime <= 3 secs
                if currentSpeed < frontSpd {        //currentSpeed < frontSpd
                    decel = decelCoast              //Min deceleration as vehicle in front going faster
                    
                    goalSpeed = currentSpeed - 0.05 //Set goalSpeed = (currentSpeed - 0.05 kph)
                } else {                            //currentSpeed >= frontSpeed
                    if gapTime < (gapVal * 0.333) { //gapTime < (1/3 x 3s) = 1 sec
                        decel = decelMax + 2        //Max decel! Gap < 1 second. (+2 is TEMPORARY!!!)
                    } else {                        //gapTime >= 1 sec
                        gapTime = gapTime - (gapVal * 0.33)     //Change value from 1-3 to 0-2 (secs for gapVal = 3)
                        gapTime = gapTime / (gapVal * 0.67)     //Convert to ratio of 0-1
                        decel = decelMax - ((decelMax - decelMin) * gapTime)
                        
                        goalSpeed = frontSpd - 0.05 //Set goalSpeed = (frontSpd - 0.05kph)
                    }
                }
            }
            
            var changeTime: CGFloat = 1     //Set initial value = 1 second
            
            if goalSpeed > vehNode.preferredSpeed {
                goalSpeed = vehNode.preferredSpeed  //Don't allow goalSpeed > preferredSpeed!
            }
            //Aim for this speed while in this lane
            
            let spdChange = abs(goalSpeed - vehNode.currentSpeed)
            
            //*****************************
            //Flowchart Page 4 of 4     :Determine 'reachedSpd', changeTime & save values etc
            //*****************************
            let maxPreferredSpd: CGFloat = 120    //Set maxPreferredSpd = 120kph for now!
            
            if ignoreSpd == true || preferredSpeed == 0 {   //ignoreSpd = true OR preferredSpeed = 0
                tVehicle[index].spdClk = Int((maxPreferredSpd/30)/accelMin) //Set spdClk = no of 120ms cycles
                
                tVehicle[index].reachedSpd = false  //reachedSpd cleared when vehicle NOT up to speed
                
            } else {                                //ignoreSpd = false AND preferredSpeed != 0
                if currentSpeed < 3 {               //currentSpeed < 3 kph
                    tVehicle[index].spdClk = Int((preferredSpeed/30)/accelMin) //Set spdClk = no of 120ms cycles
                    
                    tVehicle[index].reachedSpd = false  //reachedSpd cleared when vehicle NOT up to speed
                    
                } else {                                //currentSpeed >= 3 kph
                    if tVehicle[index].spdClk == 0 {    //spdClk timed out
                        tVehicle[index].reachedSpd = true   //reachedSpd set when vehicle up to speed
                    } else {                            //spdClk NOT timed out
                        tVehicle[index].spdClk = tVehicle[index].spdClk - 1 //Decrement spdClk
                    }                                   //End spdClk check
                }                                   //End currentSpeed check gt or lt 3 kph
            }                                       //End ignoreSpd = true OR false

            if vehNode.currentSpeed >= goalSpeed {  //currentSpeed >= goalSpeed
                //DECELERATE to goalSpeed
                if (spdChange / 3.6) > decel {      //spdChange in kph / 3.6 = m/s
                    changeTime = ((spdChange / 3.6) / decel)
                }
                
            } else {                                //currentSpeed < goalSpeed
                //NEVER allow accel = 0! (may get divide by zero error)
                //ACCELERATE to goalSpeed
                if (spdChange / 3.6) > accel {      //spdChange in kph / 3.6 = m/s
                    changeTime = ((spdChange / 3.6) / accel)
                }   //else { changeTime = 1 }       //already = 1. Slows final acceleration
            }                                       //End currentSpeed >= goalSpeed
            
            //MARK: - aim for 'goalSpeed' after 'changeTime' seconds
            tVehicle[index].goalSpeed = goalSpeed   //Store ready for SKAction
            tVehicle[index].changeTime = changeTime //Store run time for next SKAction
            
            past1km = false
            gap = 0
            otherGap = 0
            
            //            if tVehicle[index].otherTrack == false {
            //                print("kVeh \(index):\tReached Speed?: \(tVehicle[index].reachedSpd)")
            //            } else {
            //                print("oVeh \(index):\tReached Speed?: \(tVehicle[index].reachedSpd)")
            //            }
            
        }           //end 2nd For loop
        
        //        return (tVehicle, t2Vehicle)
        return tVehicle
    }       //End findObstacles method
    
//***************************************************************
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
            var y1 = t1Node.position.y
            var lanePos: CGFloat = ((FarLane - CloseLane) * (1 - t1Node.lane) + CloseLane)
            if t1Node.otherTrack == true {     //If tracks back to front, reverse polarity here!!! Swaps Fig 8 vehicles from one
                //track to the other AND swaps left/right lanes. Doesn't affect Straight Track!
                y1 = sTrackLength - t1Node.position.y
                lanePos = -lanePos
            }
            
            var newF8NodePos = t1Node.f8Pos         //???
            var currentSNodePos = t1Node.position   //???
            
            //MARK: - Calculate position of figure 8 vehicle based on straight track vehicle
            switch y1 {
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
    func calcAvgData(t1xVeh: inout [NodeData]) async -> ([NodeData]) {
        
        //        print("3x.\tMax: \(t1Veh[1].speedMax.dp2)\tAvg: \(t1Veh[1].speedAvg.dp2)\tMin: \(t1Veh[1].speedMin.dp2)")
        //        print("3y.\tMax: \(t1Veh[1].distanceMax.dp2)\tAvg: \(t1Veh[1].distance.dp2)\tMin: \(t1Veh[1].distanceMin.dp2)")
        
        //        var t1Vehicle = sKLAllVehicles   //Straight Track Vehicles
        //        var t2Veh = sOtherAllVehicles       //TEMP!!!
        
        t1xVeh[0].sumKL = 0
        t1xVeh[0].maxSumKL = 0
        t1xVeh[0].minSumKL = 99999
        
        //        if runStop == .stop {
        //            maxSumKL = 0
        //            minSumKL = 99999999
        //        }
        //
        //        var sumOther: CGFloat = 0         //Other Track - May use separate routine???
        //        var maxSumOther: CGFloat = 0
        //        var minSumOther: CGFloat = 99999999
        
        //        var tempSpd: CGFloat = 0          //Needed?
        
        //MARK: - Set timeMx = hours of vehicle run time to now!
        let timeMx: CGFloat = 3600 / runTimer
        
        var yPos: CGFloat = 0
        var yStrtPos: CGFloat = 0
        var unitNo: Int = 0
        var uNum: Int = 0
        //Loop through both arrays simultaneously. Move back 1km when they've travelled 1km!
        //IF OTHER TRACK RUN SEPARATELY THIS MAY CHANGE! NOTE TOO THAT ARRAYS NOT IN ORDER!
        for (innDex, sKLNode) in t1xVeh.enumerated() {
            //        for (var sKLNode, var sOtherNode) in zip(t1Veh, t2Veh) {
            if innDex == 0 {continue}       //Skip loop for element[0] = All Vehicles
            
            yPos = sKLNode.otherTrack ? (sTrackLength - t1xVeh[innDex].position.y) : t1xVeh[innDex].position.y
            yStrtPos = sKLNode.otherTrack ? (sTrackLength - t1xVeh[innDex].startPos) : t1xVeh[innDex].startPos
            //            if sKLNode.otherTrack == false {
            //                let yPos =
            //            }
            
            //          //Check below elsewhere!
            //            if sKLNode.position.y >= sTrackLength {
            //                //IMPORTANT!!! ??? Prevent change to pos.y in other thread during the following instruction !!!
            //                sKLNode.position.y = (sKLNode.position.y - sTrackLength)
            //                sKLNode.laps += 1
            //            }
            
            //            unitNo += 1
            
            //            print("\(t1Veh[innDex].otherTrack == false ? "KL" : "Ot")\t\(innDex)\tfGap: \(t1Veh[innDex].gap.dp1)\tofGp: \(t1Veh[innDex].otherGap.dp1)\trGap: \(t1Veh[innDex].rearGap.dp1)\torGap: \(t1Veh[innDex].oRearGap.dp1)")
            
            
            //            //Check below elsewhere!
            //            //MARK: - Flash vehicle when data displayed for single vehicle only
            //            flashVehicle(thisVehicle: sKLNode)
            
            //            print("1.\t\(t1Veh[innDex].speedMax.dp2)\t\(t1Veh[innDex].speedMin.dp2)")
            t1xVeh[innDex].distance = (t1xVeh[innDex].position.y - yStrtPos) / sTrackLength + t1xVeh[innDex].laps                //Distance travelled in km
            //            t1xVeh[innDex].distance = (yPos - yStrtPos) / sTrackLength + t1Veh[innDex].laps                //Distance travelled in km
            
            if firstThru == true {                  //Ensures initial reading > max possible speed
                t1xVeh[innDex].speedMin = 900
                //                sOtherNode.speedMin = 900
            }
            
            t1xVeh[innDex].speedAvg = t1xVeh[innDex].distance * timeMx                //Average speed for vehicle
            t1xVeh[innDex].speedMax = max(t1xVeh[innDex].speedMax, t1xVeh[innDex].speedAvg)  //Max avg speed for vehicle
            if enableMinSpeed == true {         //Wait for ALL vehicles up to speed
                //            if t1Veh[innDex].reachedSpd == true {         //Wait for individual vehicles up to speed
                t1xVeh[innDex].speedMin = min(t1xVeh[innDex].speedMin, t1xVeh[innDex].speedAvg)
            }           //Min avg speed for vehicle. Ignores acceleration period.
            //            if t1Veh[innDex].otherTrack == true {
            //                print("oVeh \(innDex) spdMin: \(t1Veh[innDex].speedMin.dp1)\t\(t1Veh[innDex].otherTrack)\t\(enableMinSpeed)")
            //            } else {
            //                print("kVeh \(innDex) spdMin: \(t1Veh[innDex].speedMin.dp1)\t\(t1Veh[innDex].otherTrack)\t\(enableMinSpeed)")
            //            }
            //            print("b4:\tMin: \(t1Veh[0].minSumKL.dp2)\tAvg: \(((t1Veh[0].sumKL) / CGFloat(numVehicles)).dp2)\tMax: \(t1Veh[0].maxSumKL.dp2)")
            t1xVeh[0].sumKL += t1xVeh[innDex].distance                   //All veh's: Total distance for all summed
            t1xVeh[0].maxSumKL = max(t1xVeh[0].maxSumKL, t1xVeh[innDex].distance)  //Max distance by a single vehicle NOW
            t1xVeh[0].minSumKL = min(t1xVeh[0].minSumKL, t1xVeh[innDex].distance)  //Min distance for a single vehicle NOW
            //            print("af:\tMin: \(t1Veh[0].minSumKL.dp2)\tAvg: \(((t1Veh[0].sumKL) / CGFloat(numVehicles)).dp2)\tMax: \(t1Veh[0].maxSumKL.dp2)\n")
            
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
        
        if t1xVeh[1].otherTrack == false {
            
            //Keep Left Track
            klDistance0 = t1xVeh[0].sumKL / CGFloat(numVehicles)
            klDistanceMax0 = t1xVeh[0].maxSumKL
            klDistanceMin0 = t1xVeh[0].minSumKL
        
            klSpeedAvg0 = klDistance0 * timeMx
            klSpeedMax0 = t1xVeh[0].maxSumKL * timeMx
            klSpeedMin0 = t1xVeh[0].minSumKL * timeMx
        
        } else {

            //Other Track
            oDistance0 = t1xVeh[0].sumKL / CGFloat(numVehicles)
            oDistanceMax0 = t1xVeh[0].maxSumKL
            oDistanceMin0 = t1xVeh[0].minSumKL
            
            oSpeedAvg0 = oDistance0 * timeMx
            oSpeedMax0 = t1xVeh[0].maxSumKL * timeMx
            oSpeedMin0 = t1xVeh[0].minSumKL * timeMx

    }

        return t1xVeh
    }       //end calcAvgData
    
    
    //MARK: - goLeft decides whether to change lanes or not
    func goLeft(teeVeh: inout [NodeData]) async -> ([NodeData]) {
        //    func goLeft(teeVeh: inout [NodeData]) -> ([NodeData]) {
        
        //gapVal = 3 = 3 secs = min gap to vehicle in front
        //These values used to test distance between this vehicle & the one behind in the other lane.
        let oRearDecel: CGFloat = 5                     //m/s2 used to calc diff eg. (3 x 5) = 15 kph
        let oRearMaxGap: CGFloat = gapVal               //3 secs
        let oRearMinGap: CGFloat = (oRearMaxGap / 6)    //(3 secs / 6) = 0.5 secs = min gap for overtaking
        let oRearGapRange: CGFloat = (oRearMaxGap - oRearMinGap)
        let maxORearSpdDiff: CGFloat = (oRearMaxGap * oRearDecel)   //eg. (3 x 5) = 15 kph
        
        var oRearSub: CGFloat               //Used to calc speed difference
        var oRearOKGap: CGFloat             //Used to store min allowable oRearGap

        var oFrontSub: CGFloat               //Used to calc speed difference
        var oFrontOKGap: CGFloat             //Used to store min allowable oRearGap

        var bigGap: CGFloat = 0             //bigGap = 110% of 3 sec gap. Calc'd for each vehicle during loop.
//        print("\n")
        let minChangeLaneSpd: CGFloat = 1.2
        
        for indx in teeVeh.indices {
//        for (indx, vehc) in teeVeh.enumerated() {
            if indx == 0 { continue }       //Skip loop for element[0] = All Vehicles
            
//            print("\(indx)\t\(teeVeh[indx])")
            
            if teeVeh[indx].currentSpeed < minChangeLaneSpd { continue }   //Vehicle MUST be >= 1.2 kph to change lanes
            
            //****************  Test for permissible oRearGap \/   ****************
            oRearSub = (teeVeh[indx].oRearSpd - teeVeh[indx].currentSpeed)  //Used to calc speed difference
            
            if oRearSub < 0 {
                oRearSub = 0
            } else {
                if oRearSub > maxORearSpdDiff {
                    oRearSub = maxORearSpdDiff
                }
            }
            
            oRearOKGap = oRearMinGap + (oRearGapRange / maxORearSpdDiff * oRearSub) //returns min gap allowed = 0.5 - 3 secs
            oRearOKGap = (teeVeh[indx].oRearSpd * oRearOKGap) / 3.6                 //converts to metres
            
            if oRearOKGap <= 1.5 { oRearOKGap = 1.5 }       //Limit minimum gap to 1.5m ( + 1m = 2.5m) at low speeds
//            tmp3Gap = teeVeh[indx].oRearSpd * 3 / 3.6
//            ttt = "OK"
//            if teeVeh[indx].oRearGap <= oRearOKGap { ttt = "No" }
//            print("\(indx)\toRGap: \(teeVeh[indx].oRearGap.dp0)\toROKGap: \(oRearOKGap.dp0)\toRSub: \(oRearSub.dp0)\t\t3: \(tmp3Gap.dp0)\t\(ttt)\tSpd: \(teeVeh[indx].oRearSpd.dp0)")

            if teeVeh[indx].oRearGap <= oRearOKGap { continue } //oRearGap insufficient to change lanes. End.
                                                        //oRearGap OK - Test other factors.
            
            //****************  Test for permissible oRearGap /\   ****************
            //****************  Test for permissible oFrontGap \/  ****************
            //For now same constants used for front as for back. Name not changed as may later be changed.
            oFrontSub = (teeVeh[indx].oFrontSpd - teeVeh[indx].currentSpeed)  //Used to calc speed difference

            if oFrontSub < 0 {
                oFrontSub = 0
            } else {
                if oFrontSub > maxORearSpdDiff {
                    oFrontSub = maxORearSpdDiff
                }
            }

            oFrontOKGap = oRearMinGap + (oRearGapRange / maxORearSpdDiff * oFrontSub) //returns min gap allowed = 0.5 - 3 secs
            oFrontOKGap = (teeVeh[indx].oFrontSpd * oFrontOKGap) / 3.6                 //converts to metres

            if oFrontOKGap <= 1.5 { oFrontOKGap = 1.5 }       //Limit minimum gap to 1.5m ( + 1m = 2.5m) at low speeds

            if teeVeh[indx].otherGap <= oFrontOKGap { continue } //oFrontGap insufficient to change lanes. End.
                                                        //oRearGap OK - Test other factors.
            
            //****************  Test for permissible oFrontGap /\  ****************
            //*********  Test for minimum speed to permit lane change \/  ****************
            if teeVeh[indx].currentSpeed < 1.5 { continue }     //Don't permit lane change when vehicle speed < 1.5 kph.
            
            //*********  Test for minimum speed to permit lane change /\  ****************

            bigGap = ((1.1 * gapVal) * teeVeh[indx].currentSpeed) / 3.6    //bigGap = 110% of 3 sec gap.
            
            if teeVeh[indx].lane == 0 {             //Preferred lane (Left)
                //****************  Test for permissible gap/otherGap from lane 0 \/  ****************
                if teeVeh[indx].frontSpd >= teeVeh[indx].currentSpeed {
                    continue        //Stay in left lane
                } else {            //Going faster than vehicle in front
                    if teeVeh[indx].gap > bigGap {
                        continue    //gap > 110% 3 sec gap. Stay in left lane.
                    } else {
                        if teeVeh[indx].gap >= teeVeh[indx].otherGap {
                            continue    //LHS gap > otherGap. Stay in this lane.
                        } else {
                            if teeVeh[indx].otherGap <= 1 { continue }      //Limit minimum gap to 1m ( + 1m = 2m) at low speeds
//                            print("to 1\t\(indx)\t\(teeVeh[indx].lane)")
                            teeVeh[indx].lane = 1       //Overtake
                            teeVeh[indx].indicator = .overtake              //Move to right (overtaking) lane
//                            print("to 1\t\(indx)\t\(teeVeh[indx].lane)")
                            continue
                        }
                    }
                }
                //May later compare frontSpd to oFrontSpd too!
                
                //****************  Test for permissible gap/otherGap from lane 0 /\  ****************
            }               //End in lane 0 checks

            if teeVeh[indx].lane == 1 {             //Overtaking lane (Right)
                //****************  Test for permissible gap/otherGap from lane 1 \/  ****************
                if teeVeh[indx].otherGap > bigGap {
//                    print("indicator \(indicator)")
//                    print("ta 0\t\(indx)\t\(teeVeh[indx].lane)")
//                    if teeVeh[indx].otherTrack == false {
//                        print("Spd1: \(allAtSpeed1)\tSpd2: \(allAtSpeed2)\tignoreSpd: \(ignoreSpd)\t\(indx): \(teeVeh[indx].reachedSpd)")   //allAtSpeed1 == true && allAtSpeed2 == true && ignoreSpd == false. rtnT2Veh[i].reachedSpd
//                    }
                    
//                    if enableMinSpeed == false {
////                        print("enablSpd: \(enableMinSpeed)")
//                        continue
//                    }
                    teeVeh[indx].lane = 0       //Return to left lane
                    teeVeh[indx].indicator = .end_overtake              //Return to left lane
//                    print("ta\t\(indx)\t\(teeVeh[indx].lane)\tenablSpd: \(enableMinSpeed)")
                    continue                    //End this vehicle
                } else {
                    if teeVeh[indx].otherGap >= teeVeh[indx].gap {
                        if teeVeh[indx].otherGap <= 1 { continue }      //Limit minimum gap to 1m ( + 1m = 2m) at low speeds
//                        print("tb 0\t\(indx)\t\(teeVeh[indx].lane)")
                        teeVeh[indx].lane = 0       //Return to left lane
                        teeVeh[indx].indicator = .end_overtake              //Return to left lane
//                        print("tb 0\t\(indx)\t\(teeVeh[indx].lane)")
                        continue
                    }
                }
                
                //****************  Test for permissible gap/otherGap from lane 1 /\  ****************
            }               //End in lane 1 checks

            //######################  New Code Above  #########################
            
            /*
            
            var oRearLength = teeVeh[Int(vehc.rearUnit.dropFirst(5))!].size.height  //Length of oRear vehicle in metres
            
            let approachRange = (vehc.preferredSpeed * 3.1) / 3.6      //3.1 secs
            let encroachRange = (vehc.currentSpeed * 1) / 3.6        //1 sec
            //            let okRange = (vehc.oRearSpd * 2.1) / 3.6                //oRear < 1.1 secs behind
            let okRange = (vehc.currentSpeed * 0.8) / 3.6                //oRear < 0.5 secs behind
            
            if vehc.currentSpeed < 3 {                            //Stop near stationary vehicles from changing lanes if they don't want to go faster
                if vehc.preferredSpeed < 2.5 {
                    continue
//                    return teeVeh
                }
            }
            
            if vehc.lane == 0 {
                //                if vehc.frontSpd < (vehc.currentSpeed + 0.5) {      //+ 0.5kph?
                if vehc.frontSpd <= (vehc.currentSpeed + 2) {      //+ 2kph?
                    if vehc.gap < approachRange {
                        if vehc.otherGap > encroachRange {
//                            if vehc.oRearGap > okRange {
                            if vehc.oRearGap > (vehc.size.height / 2) + (oRearLength / 2) + 2 {  //Total combined vehicle length + 2 metres
//                                if vehc.oFrontSpd <= vehc.frontSpd {
//                                    return teeVeh
//                                }
                                //Overtake
                                teeVeh[indx].lane = 1
                                continue
//                                return teeVeh
                            } else {
                                if (vehc.oRearGap > (okRange / 1.2)) && (oRearSpd <= vehc.currentSpeed) {
                                    //Overtake
                                    teeVeh[indx].lane = 1
                                }
                            }
                        }
                    }
                }
            }
            
            if vehc.lane == 1 {
                if vehc.oFrontSpd > vehc.preferredSpeed {
                    if vehc.otherGap > encroachRange {
//                        if vehc.oRearGap > okRange {
                        if vehc.oRearGap > (vehc.size.height / 2) + (oRearLength / 2) + 2 {  //Total combined vehicle length + 2 metres
                            teeVeh[indx].lane = 0
                            //                            sKLAllVehicles[indx].lane = 0
                            continue
//                            return teeVeh
                        }
                    }
                }
                
                //                if vehc.otherGap > (approachRange + 12) {         //2 being an extra 2 metres
                if vehc.otherGap > approachRange {         //2 being an extra 2 metres
//                    if vehc.oRearGap > okRange {
                    if vehc.oRearGap > (vehc.size.height / 2) + (oRearLength / 2) + 2 {  //Total combined vehicle length + 2 metres
                        teeVeh[indx].lane = 0
                        continue
//                        return teeVeh
                    }
                }
                
                if vehc.gap < vehc.otherGap {
                    if vehc.frontSpd <= (vehc.oFrontSpd + 0.5) {
//                        if oRearGap > okRange {
                        if vehc.oRearGap > (vehc.size.height / 2) + (oRearLength / 2) + 2 {  //Total combined vehicle length + 2 metres
                            teeVeh[indx].lane = 0
                            continue
//                            return teeVeh
                        }
                    }
                }
                
            }           //end if lane == 1
            */
            
        }           //End 'for' loop
        
        return teeVeh
    }
    
}       //end of struct NodeData

//gapSpeed = (gap * 3.6) / gapVal     //Max allowable speed for current gap. gapVal = 3 secs
