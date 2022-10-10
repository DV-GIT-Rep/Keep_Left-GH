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

    init() {
        name = "nil"
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
        
        //########################### rearGap calc loop #######################################
        t1Vehicle.sort(by: {$0.position.y > $1.position.y}) //Sort into positional order, 999.999 - 000
//        var t1Vehicle: [NodeData] = t1Vehicle
        
        var rearGap: CGFloat = 0.0      //Distance behind in OTHER lane
        var indexCopy: Int = 0
        var past1km = false

        //Loop through arrays to confirm distance to vehicle behind in the other lane
        //Loop through Track 1 (KL) first
        for (index, veh1Node) in t1Vehicle.enumerated() {
            
            indexCopy = index
            
            while rearGap == 0 {
                
            indexCopy = indexCopy + 1       // same as indexCopy += 1
            
                if indexCopy >= numVehicles {
                    
                    indexCopy = 0       //Crossed 1km barrier. Continue search
                    past1km = true      //Flag indicates vehicle behind is beyond 1km boundary

                }           //end indexCopy 'if' statement
                

//            print ("index = \(index) : indexCopy = \(indexCopy)")
//            print ("veh1N.pos = \(veh1Node.position.y.dp2) : veh1N.size/2 = \((veh1Node.size.height / 2).dp2)\nt1Veh[indexCopy].pos = \(t1Vehicle[indexCopy].position.y.dp2) : t1Veh[indexCopy].size/2 = \((t1Vehicle[indexCopy].size.height / 2).dp2)")

            let sameLane = (veh1Node.lane - 0.5)...(veh1Node.lane + 0.5)   //Scan for vehicles within 0.5 lanes either side
            let sameLap = (veh1Node.position.y - (veh1Node.size.height / 2)) - (t1Vehicle[indexCopy].position.y + (t1Vehicle[indexCopy].size.height / 2)) //Vehicle in front on same side of 1km boundary
            let lastLap = ((veh1Node.position.y + 1000) - (veh1Node.size.height / 2)) - (t1Vehicle[indexCopy].position.y + (t1Vehicle[indexCopy].size.height / 2))    //Vehicle in front is over the 1km boundary!
            
            
                    //NOTE: 0.5 lanewidth used for now due to in & out. May extend to 0.7 or so later!!!
                    if !sameLane.contains(t1Vehicle[indexCopy].lane) {
                        //Both vehicles in different lanes
                        rearGap = (past1km == false) ? sameLap : lastLap
                        if rearGap == 0 { rearGap = 0.1 }
                        //                    veh1Node.rearGap = rearGap
//                    } else {
//                        //The two vehicles are in the same lane
//                        indexCopy += 1  //Move onto next vehicle
//                        if indexCopy == index {         //All other vehicles checked. rearGap sb 0 here!
//                            if rearGap == 0 { rearGap = 1000 }
//                        }    //Continue until spacing for BOTH lanes != 0
                        
                    }       //end lane check
                                    
            }               //end while
            
//            print ("index2 = \(index) : indexCopy2 = \(indexCopy)")
//            print("\(index+1).\t\(t1Vehicle[index].name)\trearGap: \(rearGap.dp2)")

            t1Vehicle[index].rearGap = rearGap
            past1km = false
            rearGap = 0
            
        }               //end 1st for loop
        //########################### end rearGap calc loop #######################################

    t1Vehicle.sort(by: {$0.position.y < $1.position.y}) //Sort into positional order, 000 - 999.999
//        var t1Vehicle = t1Vehicle

    t2Vehicle.sort(by: {$0.position.y < $1.position.y}) //Sort into positional order, 000 - 999.999
    
    var gap: CGFloat = 0.0      //Distance ahead in THIS lane
    var otherGap: CGFloat = 0.0     //Distance ahead in OTHER lane
    indexCopy = 0
    past1km = false

    //Loop through arrays to confirm distance to vehicle in front
    //Loop through Track 1 (KL) first
    for (index, veh1Node) in t1Vehicle.enumerated() {
        
        indexCopy = index
        
        while gap == 0 || otherGap == 0 {
            
        indexCopy = indexCopy + 1       // same as indexCopy += 1
        
            if indexCopy >= numVehicles {
                
                indexCopy = 0       //Crossed 1km barrier. Continue search
                past1km = true      //Flag indicates vehicle in front is beyond 1km boundary

            }           //end indexCopy 'if' statement
            
        let sameLane = (veh1Node.lane - 0.5)...(veh1Node.lane + 0.5)   //Scan for vehicles within 0.5 lanes either side
        let sameLap = (t1Vehicle[indexCopy].position.y - (t1Vehicle[indexCopy].size.height / 2)) - (veh1Node.position.y + (veh1Node.size.height / 2))                             //Vehicle in front on same side of 1km boundary
        let lastLap = ((t1Vehicle[indexCopy].position.y + 1000) - (t1Vehicle[indexCopy].size.height / 2)) - (veh1Node.position.y + (veh1Node.size.height / 2))      //Vehicle in front is over the 1km boundary!
        
                //NOTE: 0.5 lanewidth used for now due to in & out. May extend to 0.7 or so later!!!
                if sameLane.contains(t1Vehicle[indexCopy].lane) {
                    //Both vehicles in same lane
                    if gap == 0 {
                        gap = (past1km == false) ? sameLap : lastLap
                        if gap == 0 { gap = 0.1 } //Should NEVER happen! (due to self braking)
                        //                    veh1Node.spacing = gap
                    }
                } else {
                    //The two vehicles are in different lanes
                    if otherGap == 0 {
                        otherGap = (past1km == false) ? sameLap : lastLap
                        if otherGap == 0 { otherGap = 0.1 } //Could prevent -ve values by using <= here
                        //                    veh1Node.otherGap = otherGap
                    }
                }       //end lane check
                
//                indexCopy += 1  //Move onto next vehicle
//                if indexCopy == index {
//                    if gap == 0 { gap = 1000 }
//                    if otherGap == 0 { otherGap = 1000 } //NOTE: Don't yet know distance to vehicle behind in other lane!
//                }    //Continue until spacing for BOTH lanes != 0
////            }           //end indexCopy 'if' statement
            
        }               //end While
        
        t1Vehicle[index].gap = gap
        t1Vehicle[index].otherGap = otherGap
        past1km = false
        gap = 0
        otherGap = 0

//        print("\(index+1).\t\(t1Vehicle[index].name)\tgap: \(t1Vehicle[index].gap.dp2)\totherGap: \(t1Vehicle[index].otherGap.dp2)\trearGap: \(t1Vehicle[index].rearGap.dp2)")

        //MARK: - At this point spacing = distance to vehicle in front(gap: same lane, otherGap: other lane)
        //MARK:   rearGap = distance of first vehicle behind & in other lane.
        //NOTE: ALL values above can read negative IF position differences < vehicle lengths!
        //       (can be changed by using <= instead of == above)
        
        var gapSpeed = gap * 1.2    //Max allowable speed for current gap
        var goalSpeed: CGFloat = gapSpeed  //Aim for this speed while in this lane
        
        if gapSpeed > veh1Node.preferredSpeed {
            goalSpeed = veh1Node.preferredSpeed
        }
        //    else {
        //        goalSpeed = gapSpeed  //Already = gapSpeed
        //    }
        
        //Acceleration & deceleration fixed FOR NOW!!!
        var accel: CGFloat = 2    // m per sec2
        //    var truckAccel: CGFloat = 1.0
        var decel: CGFloat = 4    // m per sec2
        //    var truckDecel: CGFloat = 0.9
        let spdChange = abs(goalSpeed - veh1Node.currentSpeed)
        var changeTime: CGFloat = 1     //Set initial value = 1 second
        //    if sKLAllVehicles[index].currentSpeed >= goalSpeed {
        if veh1Node.currentSpeed >= goalSpeed {
            //Slow to goalSpeed which can be preferredSpeed or gapSpeed
            
            if (spdChange / 3.6) > decel {      //where spdChange is in km
                changeTime = ((spdChange / 3.6) / decel)
            }   //else { changeTime = 1 }   //already = 1. Slows final deceleration
            
        } else {
            //Accelerate to goalSpeed which can be preferredSpeed or gapSpeed
            
            if (spdChange / 3.6) > accel {      //where spdChange is in km
                changeTime = ((spdChange / 3.6) / accel)
            }   //else { changeTime = 1 }   //already = 1. Slows final acceleration
            
        }
        
        //MARK: - aim for 'goalSpeed' after 'changeTime' seconds
        t1Vehicle[index].goalSpeed = goalSpeed   //Store ready for SKAction
        t1Vehicle[index].changeTime = changeTime //Store run time for next SKAction
//        print("\tgoalSpd: \(goalSpeed.dp2)\tfor \(changeTime.dp2) secs\tprefSpd: \(t1Vehicle[index].preferredSpeed.dp2)\t\(t1Vehicle[index].position.y.dp2)")
    }           //end 2nd for loop
    
    return (t1Vehicle, t2Vehicle)
}

}       //end of struct NodeData
