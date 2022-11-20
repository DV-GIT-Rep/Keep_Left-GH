//Date: 20/11/22

////########################### frontGap calc loop #######
//    var unitNumb: Int
//    var oRearGap: CGFloat = 0.0      //Distance behind in OTHER lane
//    var nextIndex: Int = 0
//    var past1km = false
//    
//    t1Vehicle.sort(by: {$0.position.y < $1.position.y}) //Sort into positional order, 000 - 999.999
//    
//    var gap: CGFloat = 0.0      //Distance ahead in THIS lane
//    var otherGap: CGFloat = 0.0     //Distance ahead in OTHER lane
//    //    nextIndex = 0               //Not required - value loaded below!
//    past1km = false
//    
//    //Loop through arrays to confirm distance to vehicle in front
//    //Loop through Track 1 (KL) first
//    for (index, veh1Node) in t1Vehicle.enumerated() {
//        
//        //THIS Vehicle = veh1Node = sKLAllVehicles[unitNumb] = t1Vehicle[index]
//        //NEXT Vehicle = t1Vehicle[nextIndex]
//        
//        unitNumb = Int.extractNum(from: veh1Node.name)! //NOTE: Use [unitNumb] for sKLAllVehicles. Use [index] OR [nextIndex] for t1Vehicles!
//        
//        nextIndex = index
//        
//        while gap == 0 || otherGap == 0 {       //Find both gap & otherGap
//            
//            nextIndex = nextIndex + 1       // same as nextIndex += 1
//            
//            if nextIndex >= numVehicles {
//                
//                nextIndex = 0       //Crossed 1km barrier. Continue search
//                past1km = true      //Flag indicates vehicle in front is beyond 1km boundary
//                
//            }           //end nextIndex 'if' statement
//            
//            let sameLane = (veh1Node.lane - 0.5)...(veh1Node.lane + 0.5)   //Scan for vehicles within 0.5 lanes either side
//            let sameLap = (t1Vehicle[nextIndex].position.y - (t1Vehicle[nextIndex].size.height / 2)) - (veh1Node.position.y + (veh1Node.size.height / 2))                             //Vehicle in front on same side of 1km boundary
//            let lastLap = ((t1Vehicle[nextIndex].position.y + sTrackLength) - (t1Vehicle[nextIndex].size.height / 2)) - (veh1Node.position.y + (veh1Node.size.height / 2))      //Vehicle in front is over the 1km boundary!
//            
//            //NOTE: 0.5 lanewidth used for now due to in & out. May extend to 0.7 or so later!!!
//            if sameLane.contains(t1Vehicle[nextIndex].lane) {
//                //Both vehicles in same lane
//                if gap == 0 {
//                    gap = (past1km == false) ? sameLap : lastLap
//                    if gap <= 0 { gap = 0.1 } //Should NEVER happen! (due to self braking)
//                    //                    veh1Node.spacing = gap
//                    t1Vehicle[index].frontUnit = t1Vehicle[nextIndex].name      //Save identity of front unit
//                    t1Vehicle[index].frontPos = t1Vehicle[nextIndex].position   //Save position of front unit
//                }
//            } else {
//                //The two vehicles are in different lanes
//                if otherGap == 0 {
//                    otherGap = (past1km == false) ? sameLap : lastLap
//                    if otherGap <= 0 { otherGap = 0.1 } //Could prevent -ve values by using <= here
//                    //                    veh1Node.otherGap = otherGap
//                }
//            }       //end lane check
//            
//        }               //end While
//        
//        t1Vehicle[index].gap = gap              // same as veh1Node.gap
//        t1Vehicle[index].otherGap = otherGap    // same as veh1Node.otherGap
//        
//        //MARK: - At this point spacing = distance to vehicle in front(gap: same lane, otherGap: other lane)
//        //MARK:   oRearGap = distance of first vehicle behind & in other lane.
//        //NOTE: ALL values above can read negative IF position differences < vehicle lengths!
//        //       (Has been changed by using <= instead of == above)
//        
//        gapSpeed = (gap * 3.6) / gapVal     //Max allowable speed for current gap. gapVal = 3 secs
//        goalSpeed = gapSpeed  //Aim for this speed while in this lane
//        
//        if gapSpeed > veh1Node.preferredSpeed {
//            goalSpeed = veh1Node.preferredSpeed
//        }
//        else {          //
//            //                goalSpeed = gapSpeed  //Already = gapSpeed
//        }
//        
//        //Acceleration & deceleration fixed FOR NOW!!!
//        var accel: CGFloat = 4.5    // m per sec2 (use 2?)
//        //    var truckAccel: CGFloat = 1.0
//        var decelMax: CGFloat = 8 // m/sec2
//        var decelMin: CGFloat = 4  // m/sec2
//        //        var decel: CGFloat = 4    // m per sec2
//        //    var truckDecel: CGFloat = 0.9
//        let spdChange = abs(goalSpeed - veh1Node.currentSpeed)
//        gapTime = (gap * 3.6) / veh1Node.currentSpeed   //Time in secs to catch vehicle in front @ current speed
//        
//        //MARK: - Create variable value of decel when gap 1 - 3 secs from vehicle in front
//        if gapTime < (gapVal * 0.33) {
//            decel = decelMax + 1                        //Max decel! Gap < 1 second. (+1 is TEMPORARY!!!)
//        } else {
//            if gapTime > gapVal {
//                decel = decelMin                        //Min decel! Gap > 3 seconds
//            } else {                                    //Gap 1 - 3 seconds
//                gapTime = gapTime - (gapVal * 0.33)     //Change value from 1-3 to 0-2 (secs for gapVal = 3)
//                gapTime = gapTime / (gapVal * 0.67)     //Convert to ratio of 0-1
//                decel = decelMax - ((decelMax - decelMin) * gapTime)
//            }
//        }
//        
//        var changeTime: CGFloat = 1     //Set initial value = 1 second
//        if veh1Node.currentSpeed >= goalSpeed {
//            //Decelerate to goalSpeed which can be preferredSpeed or gapSpeed
//            
//            //MARK: - IF GAP << 3 SECS THEN INCREASE DECELERATION!!! See above
//            if (spdChange / 3.6) > decel {      //spdChange in kph / 3.6 = m/s
//                changeTime = ((spdChange / 3.6) / decel)
//            }   //else { changeTime = 1 }   //already = 1. Slows final deceleration
//            
//        } else {
//            //Accelerate to goalSpeed which can be preferredSpeed or gapSpeed
//            
//            if (spdChange / 3.6) > accel {      //spdChange in kph / 3.6 = m/s
//                changeTime = ((spdChange / 3.6) / accel)
//            }   //else { changeTime = 1 }   //already = 1. Slows final acceleration
//            
//        }
//        
//        //MARK: - aim for 'goalSpeed' after 'changeTime' seconds
//        t1Vehicle[index].goalSpeed = goalSpeed   //Store ready for SKAction
//        t1Vehicle[index].changeTime = changeTime //Store run time for next SKAction
//        
//        past1km = false
//        gap = 0
//        otherGap = 0
//        
//    }           //end 2nd for loop
//    
//    return (t1Vehicle, t2Vehicle)
//}       //End findObstacles method
