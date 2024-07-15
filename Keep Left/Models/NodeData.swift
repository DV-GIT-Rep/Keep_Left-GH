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
    //        case endOvertake       //Vehicle returning to normal (left) lane
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
    var preDistance: CGFloat     //Records distance for 1st 10secs of travel

    var speedAvg: CGFloat
    var speedMin: CGFloat
    var speedMax: CGFloat
    
    var sumKL: CGFloat
    var maxSumKL: CGFloat
    var minSumKL: CGFloat
    var sumSpd: CGFloat
    var maxSumSpd: CGFloat
    var minSumSpd: CGFloat

    var spdClk: Int
    var upToSpd: Bool     //Set for each vehicle when it reaches speed. Cleared when vehicles stopped.
    var startIndicator:Bool
    var indicator: Indicator
    
    var mySetGap: CGFloat = 3
    var decelMin: CGFloat = 3
    var decelMax: CGFloat = 9
    var myMinGap: CGFloat = 0.9
    
//    var laneProb: CGFloat = 0.0
    var laneMode: CGFloat = 50.0

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
        preDistance = 0
        speedAvg = 0
        speedMin = 999999       //Set to >500 to start
        speedMax = 0
        
        sumKL = 0               //Used to calculate distance in km for ALL vehicles.
        maxSumKL = 0            //Used to hold the MAX distance ANY vehicle on THIS track has travelled.
        minSumKL = 99999999     //Used to hold the MIN distance ANY vehicle on THIS track has travelled.
        sumSpd = 0              //Used to calculate speed in kph for ALL vehicles.
        maxSumSpd = 0           //Used to hold the MAX speed ANY vehicle on THIS track has travelled.
        minSumSpd = 99999999    //Used to hold the MIN speed ANY vehicle on THIS track has travelled.

        spdClk = 600         //Dummy value to start. 0.083sec * 600 = 5 secs
        upToSpd = false
        
        startIndicator = false
        indicator = .off
    }
    
    //*****************************
    //findObstacles Flowchart Page 1 of 4     :Determine Rear Gaps etc
    //*****************************
    func findObstacles(tVehicle: inout [NodeData]) async {
        //Create copy of vehicles for calculating proximity to other vehicles
        //  Do calculations on background thread
        //
        //    var tVehicle = sKLAllVehicles.map{ $0.copy() }      //Straight Track Vehicles: Ignore 'All Vehicles'
        //    var tVehicle = sKLAllVehicles.dropFirst()
        //    tVehicle.sort(by: {$0.position.y < $1.position.y}) //Sort into positional order, 000 - 999.999
        
        var gapSpeed: CGFloat = 0       //Speed required to catch vehicle in front in 3 secs
        var golSpeed: CGFloat = 0      //Lesser of gapSpeed & preferredSpeed (reduced if closer than 3 secs to veh in front)
        var gapTime: CGFloat = 0        //Time in secs to catch vehicle in front @ current speed
        var decel: CGFloat = 4          // m/sec2. Typical. Varies!
        
        //########################### RearGap calc loop #######################################
        tVehicle.sort(by: keepLeft ? {$0.position.y > $1.position.y} : {$0.position.y < $1.position.y}) //Sort into positional order for REAR detection, 999.999 - 000
        
        var unitNumb: Int
        var reerGap: CGFloat = 0.0      //Distance behind in this lane
        var oReerGap: CGFloat = 0.0     //Distance behind in OTHER lane
        var nextIndex: Int = 0
        var past1km = false
        
        //Below was originally 0.2-0.8. Trying new values but may change back!
        let laneMin = 0.3
        let laneMax = 0.7
        let midLanes = laneMin...laneMax
        
        //Loop through arrays to confirm distance to vehicle behind in the other lane
        //Loop through Track 1 (KL) first
        for (index, vehNode) in tVehicle.enumerated() {
            
            //THIS Vehicle = vehNode = sKLAllVehicles[unitNumb] = tVehicle[index]
            //NEXT Vehicle = tVehicle[nextIndex]
            
            unitNumb = Int.extractNum(from: vehNode.name)! //NOTE: Use [unitNumb] for sKLAllVehicles. Use [index] OR [nextIndex] for tVehicles!
            
            if index != 0 {     //Check for duplicates yPos = yPos. Ignore index = 0 as any equals will be found.
                if vehNode.position.y == tVehicle[index-1].position.y {
                    oReerGap = 0.1  //Equal found! Assume no gap to vehicle in other lane
                }                   //Checked here as same pos may not be picked up in both directions!
            }
            
            nextIndex = index
            var tmpIndex = (index - 1)
            while reerGap == 0 || oReerGap == 0 {
                
                nextIndex = nextIndex + 1       // same as nextIndex += 1
                
                if nextIndex >= numVehicles {
                    
                    nextIndex = 0       //Crossed 1km barrier. Continue search
                    past1km = true      //Flag indicates vehicle behind is beyond 1km boundary
                    
                }           //end nextIndex 'if' statement
                
                let sameLane = (vehNode.lane - laneMax)...(vehNode.lane + laneMax)   //Scan for vehicles within 0.8 lanes either side
                //                let sameLane = (vehNode.lane - 0.5) < 0 ? 0...(vehNode.lane + 0.5) : (vehNode.lane + 0.5) <= 1 ? (vehNode.lane - 0.5)...(vehNode.lane + 0.5) : (vehNode.lane - 0.5)...1   //Scan for vehicles within 0.5 lanes either side
                let sameLap = (vehNode.position.y - (vehNode.size.height / 2)) - (tVehicle[nextIndex].position.y + (tVehicle[nextIndex].size.height / 2)) //Vehicle in front on same side of 1km boundary
                let lastLap = ((vehNode.position.y + sTrackLength) - (vehNode.size.height / 2)) - (tVehicle[nextIndex].position.y + (tVehicle[nextIndex].size.height / 2))    //Vehicle in front is over the 1km boundary!
                
                //NOTE: 0.5 lanewidth used for now due to in & out. May extend to 0.7 or so later!!!
                if sameLane.contains(tVehicle[nextIndex].lane) {
                    //Both vehicles in same lane (@ least partially)
                    if reerGap == 0 {
                        reerGap = (past1km == false) ? sameLap : lastLap
                        if reerGap < 0.1 { reerGap = 0.1 } //Should NEVER happen! (due to self braking)
                        //                    vehNode.spacing = gap
                        tVehicle[index].rearUnit = tVehicle[nextIndex].name      //Save identity of rear unit (NOT Required?)
                        tVehicle[index].rearPos = tVehicle[nextIndex].position   //Save position of rear unit (NOT Required?)
                    }
                    if midLanes.contains(tVehicle[nextIndex].lane) {
                        //If this vehicle is mid-lane, set oRearGap = rearGap
                        if oReerGap == 0 {
                            oReerGap = (past1km == false) ? sameLap : lastLap
                            if oReerGap < 0.1 { oReerGap = 0.1 } //Could prevent -ve values by using <= here
                            //                    vehNode.oRearGap = oReerGap
                            tVehicle[index].oRearSpd = tVehicle[nextIndex].currentSpeed   //Save speed of oRear unit
                        }
                    }
                } else {
                    //The two vehicles are in different lanes
                    if oReerGap == 0 {
                        oReerGap = (past1km == false) ? sameLap : lastLap
                        if oReerGap < 0.1 {
                            oReerGap = 0.1
                        } //Could prevent -ve values by using <= here
                        //                    vehNode.oRearGap = oReerGap
                        tVehicle[index].oRearSpd = tVehicle[nextIndex].currentSpeed   //Save speed of oRear unit
                    }
                }       //end lane check
                
                //Code here checks if ALL vehicles checked in while loop
                tmpIndex = (index - 1)
                if index == 0 {
                    tmpIndex = (tmpIndex + numVehicles)
                }   //tmpIndex == test value
                if nextIndex == tmpIndex {      //ALL vehicles checked - end while loop
                    if reerGap == 0 { reerGap = sTrackLength }      //No other vehicles detected in this lane - end
                    if oReerGap == 0 { oReerGap = sTrackLength }    //No vehicles detected in other lane - end
                }
                
            }               //end 'While' loop
            
            tVehicle[index].rearGap = reerGap      // same as vehNode.rearGap
            tVehicle[index].oRearGap = oReerGap    // same as vehNode.oRearGap
            past1km = false
            reerGap = 0
            oReerGap = 0
            
        }               //end 1st 'For' loop
        //########################### end RearGap calc loop #######################################
        
        //*****************************
        //findObstacles Flowchart Page 2 of 4     :Determine Front Gaps etc
        //*****************************
        //########################### Front Gap calc loop #######################################
        tVehicle.sort(by: keepLeft ? {$0.position.y < $1.position.y} : {$0.position.y > $1.position.y}) //Sort into positional order for FRONT detection, 000 - 999.999
        //NOTE: <= complements > for rear KL AND > complements <= for rear Other
//        tVehicle.sort(by: keepLeft ? {$0.position.y < $1.position.y} : {$0.position.y >= $1.position.y}) //Sort into positional order for FRONT detection, 000 - 999.999

        var gapp: CGFloat = 0.0      //Distance ahead in THIS lane
        var othergapp: CGFloat = 0.0     //Distance ahead in OTHER lane
        //    nextIndex = 0               //Not required - value loaded below!
        past1km = false
        
        //Loop through arrays to confirm distance to vehicle in front
        //Loop through Track 1 (KL) first
        for (index, vehNode) in tVehicle.enumerated() {
            
            //THIS Vehicle = vehNode = sKLAllVehicles[unitNumb] = tVehicle[index]
            //NEXT Vehicle = tVehicle[nextIndex]
            
            unitNumb = Int.extractNum(from: vehNode.name)! //NOTE: Use [unitNumb] for sKLAllVehicles. Use [index] OR [nextIndex] for tVehicles!
            
            if index != 0 {     //Check for duplicates yPos = yPos. Ignore index = 0 as any equals will be found.
                if vehNode.position.y == tVehicle[index-1].position.y {
                    othergapp = 0.1     //Equal found! Assume no gap to vehicle in other lane
                }                       //Checked here as same pos may not be picked up in both directions!
            }
            
            nextIndex = index
            var tmpIndex = (index - 1)
            while gapp == 0 || othergapp == 0 {       //Find both gap & otherGap
                
                nextIndex = nextIndex + 1       // same as nextIndex += 1
                
                if nextIndex >= numVehicles {
                    
                    nextIndex = 0       //Crossed 1km barrier. Continue search
                    past1km = true      //Flag indicates vehicle in front is beyond 1km boundary
                    
                }           //end nextIndex 'if' statement
                
                let sameLane = (vehNode.lane - laneMax)...(vehNode.lane + laneMax)   //Scan for vehicles within 0.8 lanes either side
                //                let sameLane = (vehNode.lane - 0.5) < 0 ? 0...(vehNode.lane + 0.5) : (vehNode.lane + 0.5) <= 1 ? (vehNode.lane - 0.5)...(vehNode.lane + 0.5) : (vehNode.lane - 0.5)...1   //Scan for vehicles within 0.5 lanes either side
                let sameLap = (tVehicle[nextIndex].position.y - (tVehicle[nextIndex].size.height / 2)) - (vehNode.position.y + (vehNode.size.height / 2))                             //Vehicle in front on same side of 1km boundary
                let lastLap = ((tVehicle[nextIndex].position.y + sTrackLength) - (tVehicle[nextIndex].size.height / 2)) - (vehNode.position.y + (vehNode.size.height / 2))      //Vehicle in front is over the 1km boundary!
                
                //NOTE: 0.5 lanewidth used for now due to in & out. May extend to 0.7 or so later!!!
                if sameLane.contains(tVehicle[nextIndex].lane) {
                    //Both vehicles in same lane +/- 0.8 (laneMax)
                    if gapp == 0 {
                        gapp = (past1km == false) ? sameLap : lastLap
                        if gapp < 0.1 { gapp = 0.1 } //Should NEVER happen! (due to self braking)
                        //                    vehNode.spacing = gap
                        tVehicle[index].frontUnit = tVehicle[nextIndex].name      //Save identity of front unit
                        tVehicle[index].frontPos = tVehicle[nextIndex].position   //Save position of front unit
                        tVehicle[index].frontSpd = tVehicle[nextIndex].currentSpeed   //Save speed of front unit
                    }
                    if midLanes.contains(tVehicle[nextIndex].lane) {            //midLanes = 0.25...0.75
                        //If this vehicle is mid-lane, set otherGap = gap
                        if othergapp == 0 {
                            othergapp = (past1km == false) ? sameLap : lastLap
                            if othergapp < 0.1 { othergapp = 0.1 } //Could prevent -ve values by using <= here
                            //                    vehNode.othergap = othergapp
                            tVehicle[index].oFrontSpd = tVehicle[nextIndex].currentSpeed   //Save speed of oFront unit
                        }
                    }
                } else {
                    //The two vehicles are in different lanes ie.> 0.8 lanes away from this lane!
                    if othergapp == 0 {
                        othergapp = (past1km == false) ? sameLap : lastLap
                        if othergapp < 0.1 {
                            othergapp = 0.1
                        } //Could prevent -ve values by using <= here
                        //                    vehNode.otherGap = othergapp
                        tVehicle[index].oFrontSpd = tVehicle[nextIndex].currentSpeed   //Save speed of oFront unit
                    }
                }       //end lane check
                
                //Code here checks if ALL vehicles checked in while loop
                tmpIndex = (index - 1)
                if index == 0 {
                    tmpIndex = (tmpIndex + numVehicles)
                }   //tmpIndex == test value
                if nextIndex == tmpIndex {      //ALL vehicles checked - end while loop
                    if gapp == 0 { gapp = sTrackLength }      //No other vehicles detected in this lane - end
                    if othergapp == 0 { othergapp = sTrackLength }    //No vehicles detected in other lane - end
                }
                
            }               //end While loop
            
            tVehicle[index].gap = gapp              // same as vehNode.gap
            tVehicle[index].otherGap = othergapp    // same as vehNode.otherGap
            
            //*****************************
            //findObstacles Flowchart Page 3 of 4     :Determine decel & goalSpeed etc
            //*****************************
            //MARK: - At this point spacing = distance to vehicle in front(gap: same lane, otherGap: other lane)
            //MARK:   oRearGap = distance of first vehicle behind & in other lane.
            //NOTE: ALL values above can read negative IF position differences < vehicle lengths!
            //       (Has been changed by using <= instead of == above)
            
            //Acceleration & deceleration fixed FOR NOW!!!
            var accel: CGFloat = 4.5    // m per sec2 (use 2?)
            var accelMin: CGFloat = accel   //NOT USED YET! Use to determine spdClk.
            //    var truckAccel: CGFloat = 1.0
            accel = 1       //temp!!
            accelMin = 0.5  //temp!!
//            var decelMax: CGFloat = 8 // m/sec2
//            var decelMin: CGFloat = 4  // m/sec2
            let decelXtreme: CGFloat = 10   //m/s2. Extreme braking if very close to vehicle in front!
//            var decelCoast: CGFloat = 0.01       // m/sec2. Rate when vehicle in front is faster
            var decelCoast: CGFloat = tVehicle[index].myMinGap / 40 // m/sec2. Rate when vehicle in front is faster
            //NOTE: myMinGap is time. Used here as random no. is more suitable. Units irrelevant!
            //'myMinGap' cld be anywhere from 0.4 - 1.2. Therefore set decelCoast = 0.01 - 0.03

            gapTime = (gapp * 3.6) / vehNode.currentSpeed   //Time in secs to catch vehicle in front @ current speed
            if gapTime > 9.9 { gapTime = 9.9 }    //Avoid infinite result!
            
            if gapp <= (0.7 * minGap) {
                golSpeed = 0    //Force speed to 0 if gap is less than min allowed! (0.7*3.5=2.45m)
            } else {
                
                //MARK: - Create variable value of decel when gap 1 - 3 secs from vehicle in front
                //        Note tVehicle[index].mySetGap = max allowed gap (approx. 3 seconds).
                if gapTime > tVehicle[index].mySetGap {                   //gapTime > approx. 3 secs?
                    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                    if printSpd == 1 && (Int.extractNum(from: vehNode.name)!) == WHICH {
                        //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                        if gapTime.isInfinite {
                            PATH = "1" + "inf"
                        } else {
                            PATH = "1 " + String(gapTime.dp1)
                        }
                        CS = vehNode.currentSpeed
                        FS = tVehicle[index].frontSpd   //Can't use vehNode here as not updated yet!
                    }
                    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                    
                    decel = tVehicle[index].decelMin                    //Min decel! Gap >= (mySetGap)~3 seconds
                    
                    golSpeed = (gapp * 3.6) / tVehicle[index].mySetGap     //Max allowable speed for current gap. tVehicle[index].mySetGap ~ 3 secs
                    //  gapp = metres to vehicle in front.
                    //  Multiply 'gapp' * 3.6 & then divide by no. of secs (=3 secs) gives kph required to traverse gap in 3 secs.
                    //  Therefore gapSpeed is in kph!
                    //gapSpeed = golSpeed              //gapSpeed no longer used but sb speed to close 'gap' in 3s
                    
                } else {                                //gapTime <= mySetGap secs (~3s)
                    if vehNode.currentSpeed < tVehicle[index].frontSpd {        //currentSpeed < frontSpd
                        //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                        if printSpd == 1 && (Int.extractNum(from: vehNode.name)!) == WHICH {
                            //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                            if gapTime.isInfinite {
                                PATH = "3" + "inf"
                            } else {
                                PATH = "3 " + String(gapTime.dp1)
                            }
                            CS = vehNode.currentSpeed
                            FS = tVehicle[index].frontSpd   //Can't use vehNode here as not updated yet!
                        }
                        //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                        
                        decel = decelCoast              //Min deceleration as vehicle in front going faster
                        
                        // golSpeed = vehNode.currentSpeed - 0.0001 //Set goalSpeed = (currentSpeed - 0.0001 kph)
//                        golSpeed = vehNode.currentSpeed             //Set goalSpeed = (currentSpeed)
                        golSpeed = tVehicle[index].frontSpd * 0.96  //Set goalSpeed = (currentSpeed)

                    } else {                            //currentSpeed >= frontSpeed
                        //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                        if printSpd == 1 && (Int.extractNum(from: vehNode.name)!) == WHICH {
                            //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                            if gapTime.isInfinite {
                                PATH = "2" + "inf"
                            } else {
                                PATH = "2 " + String(gapTime.dp1)
                            }
                            CS = vehNode.currentSpeed
                            FS = tVehicle[index].frontSpd   //Can't use vehNode here as not updated yet!
                        }
                        //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                        
                        if gapTime < tVehicle[index].myMinGap { //gapTime < myMinGap secs? (~ 1 sec)
                            decel = decelXtreme        //Max decel! Gap < 1 second. (+2 is TEMPORARY!!!)
                        } else {                        //gapTime >= 1 sec
                            gapTime = gapTime - tVehicle[index].myMinGap     //Change value from 1-3 to 0-2 (secs for mySetGap = 3)
                            gapTime = gapTime / (tVehicle[index].mySetGap - tVehicle[index].myMinGap)     //Convert to ratio of 0-1
                            decel = tVehicle[index].decelMax - ((tVehicle[index].decelMax - tVehicle[index].decelMin) * gapTime)
                            if decel == 0 {decel = decelCoast} //Ensure decel CAN'T = 0!
                        }
                        
                        if tVehicle[index].frontSpd >= 0.5 {
                            golSpeed = tVehicle[index].frontSpd * 0.97
                        } else {
                            golSpeed = 0    //Ensure value can't be negative
                        }
                    }
                }
            }
            
            //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            if printSpd == 1 && (Int.extractNum(from: vehNode.name)!) == WHICH {
                //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                GS = golSpeed
            }
            //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            
            var chngeTime: CGFloat = 1     //Set initial value = 1 second
            
            if golSpeed > vehNode.preferredSpeed {
                golSpeed = vehNode.preferredSpeed  //Don't allow goalSpeed > preferredSpeed!
            }
            //Aim for this speed while in this lane
            
            let spdChange = abs(golSpeed - vehNode.currentSpeed)
            
            //*****************************
            //findObstacles Flowchart Page 4 of 4     :Determine 'upToSpd', changeTime & save values etc
            //*****************************
            let maxPreferredSpd: CGFloat = 120    //Set maxPreferredSpd = 120kph for now!
            
            if ignoreSpd == true || vehNode.preferredSpeed == 0 {   //ignoreSpd = true OR preferredSpeed = 0
                tVehicle[index].spdClk = Int((maxPreferredSpd/30)/accelMin) //Set spdClk = no of 120ms cycles
                
                tVehicle[index].upToSpd = false  //upToSpd cleared when vehicle NOT up to speed
                
            } else {                                //ignoreSpd = false AND preferredSpeed != 0
                if vehNode.currentSpeed < 3 {               //currentSpeed < 3 kph
                    tVehicle[index].spdClk = Int((vehNode.preferredSpeed/30)/accelMin) //Set spdClk = no of 120ms cycles
                    
                    tVehicle[index].upToSpd = false  //upToSpd cleared when vehicle NOT up to speed
                    
                } else {                                //currentSpeed >= 3 kph
                    if tVehicle[index].spdClk == 0 {    //spdClk timed out
                        tVehicle[index].upToSpd = true   //upToSpd set when vehicle up to speed
                    } else {                            //spdClk NOT timed out
                        tVehicle[index].spdClk = tVehicle[index].spdClk - 1 //Decrement spdClk
                    }                                   //End spdClk check
                }                                   //End currentSpeed check gt or lt 3 kph
            }                                       //End ignoreSpd = true OR false
            
            if vehNode.currentSpeed >= golSpeed {  //currentSpeed >= goalSpeed
                //DECELERATE to goalSpeed
                if (spdChange / 3.6) > decel {      //spdChange in kph / 3.6 = m/s
                    chngeTime = ((spdChange / 3.6) / decel)
                }
                
            } else {                                //currentSpeed < goalSpeed
                //NEVER allow accel = 0! (may get divide by zero error)
                //ACCELERATE to goalSpeed
                if (spdChange / 3.6) > accel {      //spdChange in kph / 3.6 = m/s
                    chngeTime = ((spdChange / 3.6) / accel)
                }   //else { chngeTime = 1 }       //already = 1. Slows final acceleration
            }                                       //End currentSpeed >= goalSpeed
            
            //MARK: - aim for 'goalSpeed' after 'changeTime' seconds (???)
            tVehicle[index].goalSpeed = golSpeed   //Store ready for SKAction
            tVehicle[index].changeTime = chngeTime //= secs to accel/decel for next SKAction
            
            past1km = false
            gapp = 0
            othergapp = 0
            
            //            if tVehicle[index].otherTrack == false {
            //                print("kVeh \(index):\tReached Speed?: \(tVehicle[index].upToSpd)")
            //            } else {
            //                print("oVeh \(index):\tReached Speed?: \(tVehicle[index].upToSpd)")
            //            }
            
        }           //end 2nd For loop
        
        //***************  Restore Array to numbered order  ***************
        //NOT in Vehicle order! Arranged by Y Position!
        //Sort back into Vehicle No order. Note [0] is missing
        tVehicle.sort {
            $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }                               //'localizedStandardCompare' ensures 21 sorted AFTER 3
        tVehicle.insert(tVehicle[0], at: 0)   //Copy All Vehicles into position [0].
        tVehicle[0].name = "All Vehicles"
        //***************  Array Restored to numbered order  ***************
        
        //        return tVehicle
    }       //End findObstacles method
    
    //***************************************************************
    //This method calculates the position of vehicles on the Fig 8 Track from equiv positions on Straight Track
    //Make the method below part of the NodeData Struct
    func findF8Pos(t1Veh: inout [NodeData]) async {         //Note: t1Veh has stKL_0 or stOt_0 removed!
        
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
                
                //            case var y1 where y1 <= ((4 * F8Radius) + (piBy3 * F8Radius)):
            default:
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
                
                //            default:
                break
                
            }           //end Switch statement
            
        }           //End t1Node 'for' loop
        
        //        return t1Veh
    }           //end findF8Pos method
    
    //MARK: - Method below is to calculate display values. Once every 500-600ms sufficient.
    //Note element[0] (All Vehicles) already removed!
    func calcAvgData(t1xVeh: inout [NodeData]) async -> ([NodeData]) {
        
        //        print("3x.\tMax: \(t1Veh[1].speedMax.dp2)\tAvg: \(t1Veh[1].speedAvg.dp2)\tMin: \(t1Veh[1].speedMin.dp2)")
        //        print("3y.\tMax: \(t1Veh[1].distanceMax.dp2)\tAvg: \(t1Veh[1].distance.dp2)\tMin: \(t1Veh[1].distanceMin.dp2)")
        
        t1xVeh[0].sumKL = 0
        t1xVeh[0].maxSumKL = 0
        t1xVeh[0].minSumKL = 99999
        
        t1xVeh[0].sumSpd = 0
        t1xVeh[0].maxSumSpd = 0
        t1xVeh[0].minSumSpd = 99999
        
        //MARK: - Set timeMx = hours of vehicle run time to now!
        var timeMx: CGFloat = 0
        if runTimer != 0 { timeMx = 3600 / runTimer } else { timeMx = 3600 / 0.01 }
        
        var yPos: CGFloat = 0
        var yStrtPos: CGFloat = 0
        var unitNo: Int = 0
        var uNum: Int = 0
        
        if ignoreSpd == false {     //see Avg, Min & Max Speed calculations description in readme.md
            kISpd2 = false
            oISpd2 = false
        }
        
        //Loop through both arrays simultaneously. Move back 1km when they've travelled 1km!
        //IF OTHER TRACK RUN SEPARATELY THIS MAY CHANGE! NOTE TOO THAT ARRAYS NOT IN ORDER!
        for (innDex, sKLNode) in t1xVeh.enumerated() {
            //        for (var sKLNode, var sOtherNode) in zip(t1Veh, t2Veh) {
            if innDex == 0 {continue}       //Skip loop for element[0] = All Vehicles
            
            yPos = sKLNode.otherTrack ? (sTrackLength - t1xVeh[innDex].position.y) : t1xVeh[innDex].position.y
            yStrtPos = sKLNode.otherTrack ? (sTrackLength - t1xVeh[innDex].startPos) : t1xVeh[innDex].startPos
            
            
            //            //Check below elsewhere!
            //            //MARK: - Flash vehicle when data displayed for single vehicle only
            //            flashVehicle(thisVehicle: sKLNode)
            
            t1xVeh[innDex].distance = ((t1xVeh[innDex].position.y - yStrtPos) / sTrackLength + t1xVeh[innDex].laps)                //Distance travelled in km
//            t1xVeh[innDex].distance = (yPos - yStrtPos) / sTrackLength + t1Veh[innDex].laps                //Distance travelled in km
            
            if firstThru == true {                  //Ensures initial reading > max possible speed
                t1xVeh[innDex].speedMin = 900
                //                sOtherNode.speedMin = 900
            }

//Calc speedAvg for each vehicle
//Only ever use currentSpd for temporary display of currentSpeed!
            if t1xVeh[innDex].otherTrack == false { //Calc speedAvg for Keep Left Track
                if kISpd2 == true {         //xISpd2: true = 10s NOT up yet. Use currentSpeed
                    t1xVeh[innDex].speedAvg = CGFloat(t1xVeh[innDex].currentSpeed)    //Average speed for vehicle
                } else {                    //xISpd2: false
                    if kISpd3 == false {    //xISpd2: false, xISpd3: false = Normal Avg'd display
                        t1xVeh[innDex].speedAvg = CGFloat((t1xVeh[innDex].distance) * timeMx)    //Average speed for vehicle
                    } else {                //xISpd2: false, xISpd3: true = 10s just up, save preDistance etc
                        t1xVeh[innDex].speedAvg = CGFloat(t1xVeh[innDex].currentSpeed)    //Average speed for vehicle
                    }   //end xISpd3 test
                }       //end xISpd2 test
            } else {                                //Calc speedAvg for Other Track
                if oISpd2 == true {         //xISpd2: true = 10s NOT up yet. Use currentSpeed
                    t1xVeh[innDex].speedAvg = CGFloat((t1xVeh[innDex].currentSpeed))    //Average speed for vehicle
                } else {                    //xISpd2: false
                    if oISpd3 == false {    //xISpd2: false, xISpd3: false = Normal Avg'd display
                        t1xVeh[innDex].speedAvg = CGFloat((t1xVeh[innDex].distance) * timeMx)    //Average speed for vehicle
                    } else {                //xISpd2: false, xISpd3: true = 10s just up, save preDistance etc
                        t1xVeh[innDex].speedAvg = CGFloat(Int(t1xVeh[innDex].currentSpeed))    //Average speed for vehicle
                    }   //end xISpd3 test
                }       //end xISpd2 test
            }                                       //end Calc speedAvg for KL or Other Track
                        
            //+++++++++ Changed below to use currentSpeed instead of speedAvg. +++++++++
            //+++++++++ CHANGED BACK! NEED MIN & MAX AVG SPEED FOR EACH VEHICLE! +++++++++
//            t1xVeh[innDex].speedMax = max(t1xVeh[innDex].speedMax, t1xVeh[innDex].speedAvg)  //Max avg speed for vehicle
            t1xVeh[innDex].speedMax = max(t1xVeh[innDex].speedMax, t1xVeh[innDex].currentSpeed, t1xVeh[innDex].speedAvg)  //Max avg speed for vehicle
            if enableMinSpeed == true {         //Wait for ALL vehicles up to speed
                //            if t1Veh[innDex].upToSpd == true {         //Wait for individual vehicles up to speed
//                t1xVeh[innDex].speedMin = min(t1xVeh[innDex].speedMin, t1xVeh[innDex].speedAvg)
                t1xVeh[innDex].speedMin = min(t1xVeh[innDex].speedMin, t1xVeh[innDex].currentSpeed)
            }           //Min avg speed for vehicle. Ignores acceleration period.
            //+++++++++ Changed above to use currentSpeed instead of speedAvg - NO! +++++++++
            //USE AVG SPEED FOR ALL CALCS!
//            t1xVeh[innDex].speedMax = max(t1xVeh[innDex].speedMax, t1xVeh[innDex].currentSpeed)  //Max avg speed for vehicle
//            if enableMinSpeed == true {         //Wait for ALL vehicles up to speed
//                //            if t1Veh[innDex].upToSpd == true {         //Wait for individual vehicles up to speed
//                t1xVeh[innDex].speedMin = min(t1xVeh[innDex].speedMin, t1xVeh[innDex].currentSpeed)
//            }           //Min avg speed for vehicle. Ignores acceleration period.
            //+++++++++ Changed above to use currentSpeed instead of speedAvg - NO! +++++++++

            t1xVeh[0].sumKL += t1xVeh[innDex].distance                   //All veh's: Total distance for all summed
            t1xVeh[0].maxSumKL = max(t1xVeh[0].maxSumKL, t1xVeh[innDex].distance)  //Max distance by a single vehicle NOW
            t1xVeh[0].minSumKL = min(t1xVeh[0].minSumKL, t1xVeh[innDex].distance)  //Min distance for a single vehicle NOW
            
            t1xVeh[0].sumSpd += t1xVeh[innDex].speedAvg                   //All veh's: Total speed for all summed
            t1xVeh[0].maxSumSpd = max(t1xVeh[0].maxSumSpd, t1xVeh[innDex].speedMax)  //Max speed by a single vehicle ever
            t1xVeh[0].minSumSpd = min(t1xVeh[0].minSumSpd, t1xVeh[innDex].speedMin)  //Min distance for a single vehicle ever
            
        }   //End of 'for' loop
        
        firstThru = false       //NEVER = true again !!!
        
        //MARK: - Calculate distances & speeds for 'All Vehicles'
        //Note: Avg Speed = speed to drive Avg Distance.
        //      Max Speed = Avg Speed of vehicle that has driven furthest
        //      Min Speed = Avg Speed of vehicle that has driven the least distance
        //(Note: @ present (24/8/22) avg, max & min the same as all vehicles driven at same speed over same distance.
        
        if t1xVeh[1].otherTrack == false {      //Calculate distances & speeds for 'All Vehicles' on Keep Left Track
                        
            //Condition true if 10 secs (runTimerDelay) since vehicles 1st started
            if kISpd2 == false && kISpd3 == true {  //End of 1st pass thru calcAvgData 10secs after veh's started
                kISpd3 = false
//                runTimer = 0.0  //Will also set to 0.5 for Other Track - sb OK as within 16.7ms.
                if t1xVeh[1].speedAvg != 0 && t1xVeh[1].distance != 0 {
                    runTimer = (3600 / (t1xVeh[1].speedAvg / t1xVeh[1].distance)) //One-off adjustment after 10secs
                } else {
                    runTimer = 999999999
                }
//                runTimer = runTimer - ((3600 * t1xVeh[1].distance) / t1xVeh[1].currentSpeed) //* 2 //One-off adjustment after 10secs
            }
            
            //Keep Left Track
            klDistance0 = t1xVeh[0].sumKL / CGFloat(numVehicles)
            klDistanceMax0 = t1xVeh[0].maxSumKL
            klDistanceMin0 = t1xVeh[0].minSumKL
            
//            klSpeedAvg0 = klDistance0 * timeMx
//            klSpeedMax0 = t1xVeh[0].maxSumKL * timeMx
//            klSpeedMin0 = t1xVeh[0].minSumKL * timeMx
            klSpeedAvg0 = t1xVeh[0].sumSpd / CGFloat(numVehicles)
            klSpeedMax0 = t1xVeh[0].maxSumSpd
            klSpeedMin0 = t1xVeh[0].minSumSpd

        } else {        //Calculate distances & speeds for 'All Vehicles' on Other Track
            
            //Condition true if 10 secs (runTimerDelay) since vehicles 1st started
            if oISpd2 == false && oISpd3 == true {  //End of 1st pass thru calcAvgData 10secs after veh's started
                oISpd3 = false
//                runTimer = 0.5  //Will also set to 0.5 for Keep Left Track - sb OK as within 16.7ms.
            }
            
            //Other Track
            oDistance0 = t1xVeh[0].sumKL / CGFloat(numVehicles)
            oDistanceMax0 = t1xVeh[0].maxSumKL
            oDistanceMin0 = t1xVeh[0].minSumKL
            
//            oSpeedAvg0 = oDistance0 * timeMx
//            oSpeedMax0 = t1xVeh[0].maxSumKL * timeMx
//            oSpeedMin0 = t1xVeh[0].minSumKL * timeMx
            oSpeedAvg0 = t1xVeh[0].sumSpd / CGFloat(numVehicles)
            oSpeedMax0 = t1xVeh[0].maxSumSpd
            oSpeedMin0 = t1xVeh[0].minSumSpd

        }   //end Calculating distances & speeds for 'All Vehicles' on both tracks
        
        return t1xVeh
    }       //end calcAvgData
    
    
    //MARK: - goLeft decides whether to change lanes or not
    func goLeft(teeVeh: inout [NodeData]) async {
        
        //Constants below dictate lane change of otherTrack vehicles. laneMode = 0-100
        // ...for KL Track laneMode = -1
        //bigGap IGNORED FOR NOW!!!
        let goRightOnly = 0..<10.0  //Force vehicle into the Right Lane (need to use ~= to compare)
        let do3 = 10..<20.0         //3. goLeft if Left Lane gap >= Right Lane gap
        let do2 = 20..<30.0         //2. goLeft if Left Lane gap >= bigGap
        let do1 = 30..<40.0         //1. goLeft if Speed <= (Left Lane)frontSpd
        let doAll = 40..<60.0       //do 1, 2 & 3
        let do2_3 = 60..<70.0       //do 2 & 3
        let do1_3 = 70..<80.0       //do 1 & 3
        let do1_2 = 80..<90.0       //do 1 & 2
        let goLeftOnly = 90.0...100 //Force vehicle into the Left Lane (need to use ~= to compare)

        //teeVeh[index].mySetGap ~3 secs = min gap to vehicle in front
        //These values used to test distance between this vehicle & the one behind in the other lane.
        let oRearDecel: CGFloat = 3.5   //m/s2 used to calc spd diff (2.4-5.8secs x 3.5m/s2) = 8.4-20.3 kph
        var oRearMaxGap: CGFloat    //(2.4-5.8) secs
        var oRearMinGap: CGFloat    //min gap for overtaking XXX
        var oRearGapRange: CGFloat
        var maxORearSpdDiff: CGFloat   //(2.4-5.8secs x 3.5m/s2) = 8.4-20.3 kph
        
        var oRearSub: CGFloat               //Used to calc speed difference
        var oRearOKGap: CGFloat             //Used to store min allowable oRearGap
        
        var oFrontSub: CGFloat               //Used to calc speed difference
        var oFrontOKGap: CGFloat             //Used to store min allowable oRearGap
        
        var bigGap: CGFloat = 0             //bigGap = 105% of 3 sec gap. Calc'd for each vehicle during loop.
        
        /// Setup multiplier to work out minimum speed for change into left lane
        ///- Result = (100-numVehicles)[result capped @ 80] * 11/80 + 5
        ///-     min spd = 16kph if <= 20 Vehicles
        ///-     min spd = 5kph  if 100 Vehicles
        var minChangeLaneSpdL: CGFloat //Minimum speed where lane change permitted!
        /// Setup multiplier to work out minimum speed for change into right lane
        ///- Result = (100-numVehicles)[result capped @ 80] * 23/80 + 5
        ///-     min spd = 28kph if <= 20 Vehicles
        ///-     min spd = 5kph  if 100 Vehicles
        var minChangeLaneSpdR: CGFloat //Minimum speed where lane change permitted!
        //NOTE: May have to reduce the above when 'numVehicles' becomes large!!!
        var tmp = CGFloat(numVehicles)
        if tmp < 20 { tmp = 20 }
        tmp = 100 - tmp
        var tmp2: CGFloat = 23 / 80             //= 0.2875 = kph diff
        //23 = 28kph - 5kph
        minChangeLaneSpdR = tmp * tmp2 + 5.0
        
        tmp2 = 11 / 80             //= 0.1375 = kph diff
        //11 = 16kph - 5kph
        minChangeLaneSpdL = tmp * tmp2 + 5.0
        
        //Tests indicated vehicle speeds for various numVehicles limited as follows (due to proximity to vehicle in front):
        //  20 Vehicles 32kph       ;Formulas above prevent lane changes @ low speeds
        //  30 Vehicles 24kph       ;subject to no. of vehicles.
        //  40 Vehicles 22kph       ;
        //  50 Vehicles 19kph       ;   -> Left Lane    5kph 100 vehicles
        //  60 Vehicles 15kph       ;                   28kph 20 vehicles
        //  70 Vehicles 11kph       ;
        //  80 Vehicles 8kph        ;   -> Right Lane   5kph 100 vehicles
        //  110 Vehicles 6kph       ;                   16kph 20 vehicles

        //Start loop
        for indx in teeVeh.indices {
            //        for (indx, vehc) in teeVeh.enumerated() {
            if indx == 0 { continue }       //Skip loop for element[0] = All Vehicles
            
            var frontNum = Int.extractNum(from: teeVeh[indx].frontUnit) ?? nil //UnitNum of vehicle in front. Same lane.
            //Returns nil if there's no other vehicles in THIS lane!
            
            //vvvvvvvvvv Force Lane to 0 or 1 vvvvvvvvvv
            if teeVeh[indx].indicator != .off { continue }  //Lane change already in progress
            //NOTE: If inst's below omitted then each veh will O/T or return ONLY once!
            //  (value of indicator changed by 0.002! - laneChange not EXACTLY 1.0 lanes)
            if teeVeh[indx].lane > 0.5 {    //Ensure lane only = 1 or 0 when here!
                teeVeh[indx].lane = 1
            } else {
                teeVeh[indx].lane = 0
            }
            //^^^^^^^^^^ Force Lane to 0 or 1 ^^^^^^^^^^

            oRearMaxGap = teeVeh[indx].mySetGap    //~ 3 secs (2.4-5.8 secs)
//            oRearMinGap = (oRearMaxGap / 6)    //(~3 secs / 6) = ~0.5 secs (0.4-0.933s) = min gap for overtaking
            oRearMinGap = (teeVeh[indx].myMinGap * 0.75)    //(0.4-1.2secs * 2) = (0.8-2.4secs) = min gap for overtaking
            oRearGapRange = (oRearMaxGap - oRearMinGap)
            maxORearSpdDiff = (oRearMaxGap * oRearDecel) //(2.4-5.8secs @ 3.5m/s2) = 8.4-20.3kph (was~15 kph)

            //****************  Test for permissible oRearGap \/   ****************
            oRearSub = (teeVeh[indx].oRearSpd - teeVeh[indx].currentSpeed)  //Used to calc speed difference
            
            if oRearSub < 0 {
                oRearSub = 0                        //This vehicle faster than oRearSpd - SAFE to allow min gap
                //NOTE: the minimum gap = 'myMinGap' (0.4-1.2secs) or 'minGap' (3.5m), whichever is greater.
                //      'myMinGap' calc'd on oRearSpd for rear or currentSpeed for front!
            } else {
                if oRearSub > maxORearSpdDiff {
                    oRearSub = maxORearSpdDiff      //This vehicle slower than (oRearSpd - 8.4to20.3kph) - require max gap
                }
            }
            
            oRearOKGap = oRearMinGap + ((oRearGapRange / maxORearSpdDiff) * oRearSub) //returns min gap allowed = 0.5 - 3 secs
            oRearOKGap = (teeVeh[indx].oRearSpd * oRearOKGap) / 3.6 // = permissible gap in metres
            
            if oRearOKGap < minGap { oRearOKGap = minGap }       //Limit minimum gap to 3.5m at low speeds
            
            if teeVeh[indx].oRearGap <= oRearOKGap { continue } //oRearGap insufficient to change lanes. End.
            //oRearGap OK - Test other factors.
            
            //****************  Test for permissible oRearGap /\   ****************
            //****************  Test for permissible oFrontGap \/  ****************
            //For now same constants used for front as for back. Name not changed as may later be changed.
            oFrontSub = (teeVeh[indx].currentSpeed - teeVeh[indx].oFrontSpd)  //Used to calc speed difference
            
            if oFrontSub < 0 {
                oFrontSub = 0                       //This vehicle slower than oFrontSpd - SAFE to allow min gap
                //NOTE: the minimum gap = 'myMinGap' (0.4-1.2secs) or 'minGap' (3.5m), whichever is greater.
                //      'myMinGap' calc'd on oRearSpd for rear or currentSpeed for front!
            } else {
                if oFrontSub > maxORearSpdDiff {
                    oFrontSub = maxORearSpdDiff     //This vehicle faster than (oFrontSpd + ~15kph) - require max gap
                }
            }
            
            oFrontOKGap = oRearMinGap + (oRearGapRange / maxORearSpdDiff * oFrontSub) //returns min gap allowed = ~0.5 - ~3 secs
            oFrontOKGap = (teeVeh[indx].currentSpeed * oFrontOKGap) / 3.6 // = permissible gap in metres
            
            if oFrontOKGap <= minGap { oFrontOKGap = minGap }       //Limit minimum gap to 3.5m at low speeds
            
            if teeVeh[indx].otherGap <= oFrontOKGap { continue } //oFrontGap insufficient to change lanes. End.
            //oRearGap OK - Test other factors.
            
            //****************  Test for permissible oFrontGap /\  ****************
            //*********  Test for minimum speed to permit lane change \/  ****************
//            if teeVeh[indx].currentSpeed < minChangeLaneSpdR { continue }     //Don't permit lane change when vehicle speed < 5-28 kph.
            
            //*********  Test for minimum speed to permit lane change /\  ****************
            
            bigGap = ((1.05 * teeVeh[indx].mySetGap) * teeVeh[indx].currentSpeed) / 3.6 //bigGap = 105% of 2.4-5.8 sec gap = 2.52-6.09sec gap
            //bigGap = metres travelled during (1.05 * 'mySetGap') seconds @ currentSpeed.
            //Bigger so lane change starts b4 vehicle slows down.
            //Can't be too big ????? TBC ?????

            if teeVeh[indx].lane == 0 {             //In Preferred Lane (Left)
                var switchLanes: Bool = false
                //****************  Test for permissible gap/otherGap from lane 0 (Left Lane) \/  ****************
                //Only permit lane change above 5-28kph
                if teeVeh[indx].currentSpeed < minChangeLaneSpdR { continue }     //Don't permit lane change when vehicle speed < 5-28 kph (subject to numVehicles).
                
                if frontNum != nil {    //nil if no other vehicles in this lane
                    if teeVeh[frontNum!].indicator == .overtake { continue } //No overtake if vehicle in front is too
                }
                
                //Force into Right Lane?
                if teeVeh[indx].otherTrack == true {            //OtherTrack
                    if goRightOnly ~= teeVeh[indx].laneMode {   //Go To Right Lane - No Reason
                        teeVeh[indx].indicator = .overtake      //Move to right (overtaking) lane
                        teeVeh[indx].startIndicator = true      //Flag used to start lane change
                        continue                                //Lane change initiated - end
                    } else {                    //Normal - don't force right lane
                        switchLanes = false     //Already false. Normal - don't force right lane
                    }   //end force lane check
                }       //end KL Track test
                
                //Condition 1. Lane Change Test
                if teeVeh[indx].otherTrack == false || do1 ~= teeVeh[indx].laneMode || do1_3 ~= teeVeh[indx].laneMode || do1_2 ~= teeVeh[indx].laneMode || doAll ~= teeVeh[indx].laneMode {
                    if teeVeh[indx].currentSpeed <= teeVeh[indx].frontSpd { //Stay in left lane
                        continue                //Condition 1 to change lanes not met - end
                    } else {                    //Speed > frontSpd
                        switchLanes = true      //Condition 1 to change lanes met - Continue tests
                    }   //end speed check
                }       //FrontSpd test ended - do next test
                
                //Condition 2. bigGap Test
//                if teeVeh[indx].otherTrack == false || do2 ~= teeVeh[indx].laneMode || do2_3 ~= teeVeh[indx].laneMode || do1_2 ~= teeVeh[indx].laneMode || doAll ~= teeVeh[indx].laneMode {
// To reinstate condition 2 for otherTrack uncomment above & comment below!
                if teeVeh[indx].otherTrack == false {
                    if teeVeh[indx].gap >= bigGap { //Stay in left lane
                        continue                //Condition 2 to change lanes not met - end
                    } else {                    //gap < bigGap
                        switchLanes = true      //Condition 2 to change lanes met - Continue tests
                    }   //end bigGap check
                }       //bigGap test ended - do next test
                
                //Condition 3. oGap Test
                if teeVeh[indx].otherTrack == false || do3 ~= teeVeh[indx].laneMode || do2_3 ~= teeVeh[indx].laneMode || do1_3 ~= teeVeh[indx].laneMode || doAll ~= teeVeh[indx].laneMode {
                    if teeVeh[indx].gap >= teeVeh[indx].otherGap { //Stay in left lane
                        continue                //Condition 3 to change lanes not met - end
                    } else {                    //LHS gap < otherGap.
                        switchLanes = true      //Condition 3 to change lanes met - Continue tests
                    }   //end oGap check
                }       //oGap test ended - do next test
                
                if switchLanes == false {
                    continue
                }
                
                //Move into Right Lane (1)\
                teeVeh[indx].indicator = .overtake  //Move to right (overtaking) lane
                teeVeh[indx].startIndicator = true  //Flag used to start lane change
                continue
                
                //****************  Test for permissible gap/otherGap from lane 0 /\  ****************
            }               //End in lane 0 checks

            
            if teeVeh[indx].lane == 1 {             //In Overtaking Lane (Right)
                //****************  Test for permissible gap/otherGap from lane 1 \/  ****************
                //Only permit lane change above 5-16kph
                if teeVeh[indx].currentSpeed < minChangeLaneSpdL { continue }     //Don't permit lane change when vehicle speed < 5-16 kph (subject to numVehicles).
                
                if frontNum != nil {    //nil if no other vehicles in this lane
                    if teeVeh[frontNum!].indicator == .endOvertake { continue } //Don't move left if vehicle in front is too
                }
                
                //Force into Left Lane?
                if teeVeh[indx].otherTrack == true {            //OtherTrack
                    if goLeftOnly ~= teeVeh[indx].laneMode {    //Go To Left Lane - No Reason
                        teeVeh[indx].indicator = .endOvertake   //Move to Left Lane
                        teeVeh[indx].startIndicator = true      //Flag used to start lane change
                        continue                                //Lane change initiated - end
                    }   //Normal - don't force Left Lane. End force lane check
                }       //end KL Track test
                
                //Condition 1. Slower than Left Lane FrontSpd?
                if teeVeh[indx].currentSpeed < teeVeh[indx].oFrontSpd {    //Safe in Left Lane?
//                    if teeVeh[indx].otherTrack == false || do1 ~= teeVeh[indx].laneMode || do1_3 ~= teeVeh[indx].laneMode || do1_2 ~= teeVeh[indx].laneMode || doAll ~= teeVeh[indx].laneMode {
// To reinstate condition 2 for otherTrack uncomment above & comment below!
                    if teeVeh[indx].otherTrack == false {
                        teeVeh[indx].indicator = .endOvertake   //Move to Left Lane
                        teeVeh[indx].startIndicator = true      //Flag used to start lane change
                        continue                                //Lane change initiated - end
                    }   //end - condition to change lanes not met!
                }       //Left Lane FrontSpd test ended - do next test

                //Condition 2. bigGap vs Left Lane Gap Test
                if teeVeh[indx].otherGap > bigGap {    //Safe in Left Lane?
                    if teeVeh[indx].otherTrack == false || do2 ~= teeVeh[indx].laneMode || do2_3 ~= teeVeh[indx].laneMode || do1_2 ~= teeVeh[indx].laneMode || doAll ~= teeVeh[indx].laneMode {
                        teeVeh[indx].indicator = .endOvertake   //Move to Left Lane
                        teeVeh[indx].startIndicator = true      //Flag used to start lane change
                        continue                                //Lane change initiated - end
                    }   //end - condition to change lanes not met!
                }       //Left Lane bigGap test ended - do next test

                //Condition 3. This (Right) Gap vs Left Lane Gap Test
                if teeVeh[indx].otherGap > teeVeh[indx].gap {
                    if teeVeh[indx].otherTrack == false || do3 ~= teeVeh[indx].laneMode || do2_3 ~= teeVeh[indx].laneMode || do1_3 ~= teeVeh[indx].laneMode || doAll ~= teeVeh[indx].laneMode {
                        teeVeh[indx].indicator = .endOvertake   //Move to Left Lane
                        teeVeh[indx].startIndicator = true      //Flag used to start lane change
                        continue                                //Lane change initiated - end
                    }   //end - condition to change lanes not met!
                }       //Left Lane bigGap test ended - do next test
                //****************  Test for permissible gap/otherGap from lane 1 /\  ****************
            }               //End in lane 1 checks

            
        }                   //End 'for' loop
        //        return teeVeh
    }                       //end of goLeft function
    
    //Code below starts lane change & indicators where required
    func changeLanes(retnVeh: [NodeData], i: Int, kLTrack: Bool) -> ([NodeData]) {
        var rtnVeh: [NodeData] = retnVeh
        if rtnVeh[i].startIndicator == true { //Code only runs to Start Flashing
            rtnVeh[i].startIndicator = false
            if kLTrack {    //KL Track
                sKLAllVehicles[i].startIndicator = false
            } else {        //Not KL Track
                sOtherAllVehicles[i].startIndicator = false
            }               //end KL Track
            
            if rtnVeh[i].indicator == .overtake { //About to Overtake
//                let halfFlash: CGFloat = 0.3    //Time indicators are ON or OFF
//                let numFlash = 6        //No of full indicator flashes
//                let laneChangeTime: CGFloat = CGFloat(numFlash) * halfFlash * 1.8
                let indicatorOn = SKAction.unhide() //Overtaking indicators ON
                let indicatorOff = SKAction.hide()  //Overtaking indicators OFF
                let deelay = SKAction.wait(forDuration: halfFlash)  //Delay halfFlash secs
                let pulseIndicators = SKAction.sequence([indicatorOn, deelay, indicatorOff, deelay])
                let flash1 = SKAction.repeat(pulseIndicators, count: numFlash)
                let endLane1 = SKAction.run {
                    if kLTrack {    //KL Track
//                        Int(truncating: mounths as NSNumber)
                        sKLAllVehicles[i].lane = 1      //Ensure lane only = 1 or 0 when here!
                        sKLAllVehicles[i].indicator = .off
                        if printOvertake != 0 {
                            print("\t\(i)   End KLOvertake\tLane \(sKLAllVehicles[i].lane.dp0)\tInd = \(sKLAllVehicles[i].indicator)")  //Currently prints twice! Not omitted below.
                        }           //end Print
                    } else {        //Not KL Track
                        sOtherAllVehicles[i].lane = 1      //Ensure lane only = 1 or 0 when here!
                        sOtherAllVehicles[i].indicator = .off
                        //                        if printOvertake != 0 {
                        //                            print("\t\(i)   End OtOvertake\tLane \(sOtherAllVehicles[i].lane.dp0)\tInd = \(sOtherAllVehicles[i].indicator)")
                        //                        }           //end Print
                    }               //end KL Track
                    rtnVeh[i].lane = 1      //Ensure lane only = 1 or 0 when here!
                    rtnVeh[i].indicator = .off
                }                   //end SKAction.run
                
                let goToLane1 = SKAction.customAction(withDuration: laneChangeTime, actionBlock: {
                    (node, elapsedTime) in
                    if kLTrack {    //KL Track
                        sKLAllVehicles[i].lane = elapsedTime / laneChangeTime
                        rtnVeh[i].lane = sKLAllVehicles[i].lane //rtnVeh[i].lane = elapsedTime / laneChangeTime
                        if printOvertake > 1 {  //
                            if whichOT == i {
                                print("\(i) KL\(sKLAllVehicles[i].lane)") //All dig's. EndOT set to 3.
                            }
                        }
                    } else {        //Not KL Track
                        sOtherAllVehicles[i].lane = elapsedTime / laneChangeTime
                        rtnVeh[i].lane = sOtherAllVehicles[i].lane //rtnVeh[i].lane = elapsedTime / laneChangeTime
                        //                        if printOvertake > 1 {  //
                        //                            if whichOT == i {
                        //                                print("\(i) Ot\(sOtherAllVehicles[i].lane)") //All dig's. EndOT set to 3.
                        //                            }       //end specific print
                        //                        }           //end Print
                    }               //end KL Track
                })                  //end .customAction
                let laneChange = SKAction.group([goToLane1, flash1])
                
                if kLTrack {    //KL Track
                    sKLAllVehicles[i].indicator = rtnVeh[i].indicator
                    sKLAllVehicles[i].startIndicator = rtnVeh[i].startIndicator
                    sKLAllVehicles[i].lane = rtnVeh[i].lane
                    
                    //                    if printOvertake != 0 {
                    //                        let startMsg1 = SKAction.run {print("\t\(i) Start KLOvertake\tLane \(sKLAllVehicles[i].lane.dp0)\tInd = \(sKLAllVehicles[i].indicator)\tsInd = \(sKLAllVehicles[i].startIndicator)")}
                    //                        let laneFlash1 = SKAction.sequence([startMsg1, laneChange, endLane1])
                    //                        let newLanePos: Void = sKLAllVehicles[i].childNode(withName: "rightInd\(i)")!.run(laneFlash1)
                    //                        let lFlash1 = SKAction.sequence([laneChange, endLane1])
                    ////                        let newF8LanePos: Void = f8KLAllVehicles[i].childNode(withName: "rightInd\(i)")!.run(lFlash1)
                    //                        let newF8LanePos: Void = f8KLAllVehicles[i].childNode(withName: "rightInd\(i)")!.run(flash1)
                    //                    } else {
                    let laneFlash1 = SKAction.sequence([laneChange, endLane1])
                    let newLanePos: Void = sKLAllVehicles[i].childNode(withName: "rightInd\(i)")!.run(laneFlash1)
                    //                        let newF8LanePos: Void = f8KLAllVehicles[i].childNode(withName: "rightInd\(i)")!.run(laneFlash1)
                    let newF8LanePos: Void = f8KLAllVehicles[i].childNode(withName: "rightInd\(i)")!.run(flash1)
                    //                    } //end Print
                    
                } else {    //Not KL Track
                    sOtherAllVehicles[i].indicator = rtnVeh[i].indicator
                    sOtherAllVehicles[i].startIndicator = rtnVeh[i].startIndicator
                    sOtherAllVehicles[i].lane = rtnVeh[i].lane
                    
                    //                    if printOvertake != 0 { //Print
                    //                        let startMsg1 = SKAction.run {print("\t\(i) Start OtOvertake\tLane \(sOtherAllVehicles[i].lane.dp0)\tInd = \(sOtherAllVehicles[i].indicator)")}
                    //                        let laneFlash1 = SKAction.sequence([startMsg1, laneChange, endLane1])
                    //                        let newLanePos: Void = sOtherAllVehicles[i].childNode(withName: "rightInd\(i)")!.run(laneFlash1)
                    //                        let lFlash1 = SKAction.sequence([laneChange, endLane1])
                    //                        let newF8LanePos: Void = f8OtherAllVehicles[i].childNode(withName: "rightInd\(i)")!.run(lFlash1) //Don't print Other Track
                    //                    } else {                //Don't print
                    let tmpP = printOvertake    //Only print KL Track - ignore here!
                    printOvertake = 0
                    let laneFlash1 = SKAction.sequence([laneChange, endLane1])
                    let newLanePos: Void = sOtherAllVehicles[i].childNode(withName: "rightInd\(i)")!.run(laneFlash1)
                    let newF8LanePos: Void = f8OtherAllVehicles[i].childNode(withName: "rightInd\(i)")!.run(laneFlash1)
                    printOvertake = tmpP
                    //                    }   //end Print
                }       //end KL Track
                
            } else {        //About to go back to left lane
                if rtnVeh[i].indicator == .endOvertake {
//                    let halfFlash: CGFloat = 0.3    //Time indicators are ON or OFF
//                    let numFlash = 6        //No of full indicator flashes
//                    let laneChangeTime: CGFloat = CGFloat(numFlash) * halfFlash * 1.8
                    let indicatorOn = SKAction.unhide() //Overtaking indicators ON
                    let indicatorOff = SKAction.hide()  //Overtaking indicators OFF
                    let deelay = SKAction.wait(forDuration: halfFlash)  //Delay halfFlash secs
                    let pulseIndicators = SKAction.sequence([indicatorOn, deelay, indicatorOff, deelay])
                    let flash0 = SKAction.repeat(pulseIndicators, count: numFlash)
                    let endLane0 = SKAction.run {
                        rtnVeh[i].lane = 0      //Ensure lane only = 1 or 0 when here!
                        rtnVeh[i].indicator = .off
                        if kLTrack {    //KL Track
                            sKLAllVehicles[i].lane = 0      //Ensure lane only = 1 or 0 when here!
                            sKLAllVehicles[i].indicator = .off
                            if printOvertake != 0 {
                                print("\t\t\t\t\t\t\(i)   End KLBack\tLane \(sKLAllVehicles[i].lane.dp0)\tInd = \(sKLAllVehicles[i].indicator)")
                            }       //end Print
                        } else {    //Not KL Track
                            sOtherAllVehicles[i].lane = 0      //Ensure lane only = 1 or 0 when here!
                            sOtherAllVehicles[i].indicator = .off
                            //                            if printOvertake != 0 {
                            //                                print("\t\t\t\t\t\t\(i)   End OtBack\tLane \(sOtherAllVehicles[i].lane.dp0)\tInd = \(sOtherAllVehicles[i].indicator)")
                            //                            }   //end Print
                        }       //end KL Track
                    }           //End endLane0 action
                    
                    let startMsg = SKAction.run {
                        if printOvertake != 0 {
                            if kLTrack {    //KL Track
                                print("\t\t\t\t\t\t\(i) Start KLBack\tLane \(sKLAllVehicles[i].lane.dp0)\tInd = \(sKLAllVehicles[i].indicator)")
                            } else {    //Not KL Track
                                //                                print("\t\t\t\t\t\t\(i) Start OtBack\tLane \(sOtherAllVehicles[i].lane.dp0)\tInd = \(sOtherAllVehicles[i].indicator)")
                            }       //end KL Track
                        }           //end Print
                    }               //end SKAction.run
                    
                    let goToLane0 = SKAction.customAction(withDuration: laneChangeTime, actionBlock: {
                        (node, elapsedTime) in
                        if kLTrack {    //KL Track
                            sKLAllVehicles[i].lane = (1 - (elapsedTime / laneChangeTime))
                            //  rtnVeh[i].lane = (1 - (elapsedTime / laneChangeTime))
                            rtnVeh[i].lane = sKLAllVehicles[i].lane
                            if printOvertake > 1 {  //
                                if whichOT == i {
                                    print("\(i) KL\(sKLAllVehicles[i].lane.dp3)\teT: \(elapsedTime)\ttT: \(laneChangeTime)")
                                }
                            }
                        } else {    //Not KL Track
                            sOtherAllVehicles[i].lane = (1 - (elapsedTime / laneChangeTime))
                            //  rtnVeh[i].lane = (1 - (elapsedTime / laneChangeTime))
                            rtnVeh[i].lane = sOtherAllVehicles[i].lane
                            //                            if printOvertake > 1 {  //
                            //                                if whichOT == i {
                            //                                    print("\(i) Ot\(sOtherAllVehicles[i].lane.dp3)")
                            //                                }   //end specific vehicle
                            //                            }       //end Print
                        }           //end KL Track
                    })               //End goToLane0 action
                    
                    let goLane0 = SKAction.group([goToLane0, flash0])
                    let laneFlash0 = SKAction.sequence([startMsg, goLane0, endLane0])
                    let lFlash0 = SKAction.sequence([goLane0, endLane0])
                    
                    if kLTrack {    //KL Track
                        sKLAllVehicles[i].indicator = rtnVeh[i].indicator
                        sKLAllVehicles[i].startIndicator = rtnVeh[i].startIndicator
                        sKLAllVehicles[i].lane = rtnVeh[i].lane
                        
                        let newLanePos: Void = sKLAllVehicles[i].childNode(withName: "leftInd\(i)")!.run(laneFlash0)
                        //                    let newF8LanePos: Void = f8KLAllVehicles[i].childNode(withName: "leftInd\(i)")!.run(lFlash0)
                        let newF8LanePos: Void = f8KLAllVehicles[i].childNode(withName: "leftInd\(i)")!.run(flash0)
                        
                    } else {        //Not KL Track
                        sOtherAllVehicles[i].indicator = rtnVeh[i].indicator
                        sOtherAllVehicles[i].startIndicator = rtnVeh[i].startIndicator
                        sOtherAllVehicles[i].lane = rtnVeh[i].lane
                        
                        let tmpP = printOvertake
                        printOvertake = 0
                        let newLanePos: Void = sOtherAllVehicles[i].childNode(withName: "leftInd\(i)")!.run(laneFlash0)
                        //                        let newF8LanePos: Void = f8OtherAllVehicles[i].childNode(withName: "leftInd\(i)")!.run(lFlash0)
                        let newF8LanePos: Void = f8OtherAllVehicles[i].childNode(withName: "leftInd\(i)")!.run(flash0)
                        printOvertake = tmpP
                        
                    }               //end KL Track
                    
                } else {    //.startIndicator was set BUT .indicator WASN'T O/T or endO/T!
                    if kLTrack {    //KL Track
                        if sKLAllVehicles[i].lane > 0.5 {
                            sKLAllVehicles[i].lane = 1      //Ensure lane only = 1 or 0 when here!
                        } else {    //lane <= 0.5
                            sKLAllVehicles[i].lane = 0      //Ensure lane only = 1 or 0 when here!
                        }   //end lane check
                        rtnVeh[i].lane = sKLAllVehicles[i].lane      //Ensure lane only = 1 or 0 when here!
                        sKLAllVehicles[i].indicator = .off  //Ensure 'goLeft' can run!
                        rtnVeh[i].indicator = .off
                    } else {    //Not KL Track
                        if sOtherAllVehicles[i].lane > 0.5 {
                            sOtherAllVehicles[i].lane = 1      //Ensure lane only = 1 or 0 when here!
                        } else {    //lane <= 0.5
                            sOtherAllVehicles[i].lane = 0      //Ensure lane only = 1 or 0 when here!
                        }           //end lane test
                        rtnVeh[i].lane = sOtherAllVehicles[i].lane      //Ensure lane only = 1 or 0 when here!
                        sOtherAllVehicles[i].indicator = .off  //Ensure 'goLeft' can run!
                        rtnVeh[i].indicator = .off
                    }       //end KL Track
                }           //end .startIndicator test
            }               //end of about to overtake OR back to left lane
            //                                    rtnVeh[i].startIndicator = false
        }           //End startFlashing - End of .startIndicator was true routine
        //skips above & direct to here when .startIndicator not true
        return rtnVeh
    }   //end of changeLanes function
    
}       //end of struct NodeData

extension Date.ISO8601FormatStyle {
    static let secs: Self = .init(includingFractionalSeconds: true)
}

