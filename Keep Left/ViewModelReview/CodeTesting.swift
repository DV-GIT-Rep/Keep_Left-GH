
import Foundation
 import SpriteKit


//func findObstacle(thisVehicle: Vehicle) {
//
//    let frontOfVehicle = CGPoint(x: thisVehicle.position.x, y: thisVehicle.position.y + (thisVehicle.size.height / 2))
//    let rayStart = frontOfVehicle
//
//    let y3Sec = (thisVehicle.physicsBody?.velocity.dy ?? 27.78) * 3    //Calc metres per 3 sec from m/sec. 27.7 = m/s @ 100kph
//
//    let rayEnd = CGPoint(x: thisVehicle.position.x, y: rayStart.y + y3Sec)
//
//    //MARK: - DOESN'T currently test for vehicles beyond 1km boundary !!!
//    if let frontObject1 = straightScene.physicsWorld.body(alongRayStart: rayStart, end: rayEnd) {
//        let distanceAhead1 = (frontObject1.position.y - (frontObject1.size.height / 2)) - rayStart.y
//    } else {    //Next ray is 1m to right of first ray
//        if let frontObject2 = straightScene.physicsWorld.body(alongRayStart: CGPoint(x: rayStart.x + 1, y: rayStart.y), end: CGPoint(x: rayEnd.x + 1, y: rayEnd.y)) {
//            let distanceAhead2 = (frontObject2.position.y - (frontObject2.size.height / 2)) - rayStart.y
//        } else { return }   //No vehicles detected within 3 secs in front
//    }
//
//
//
//
//
//
//    let frontObject2 = straightScene.physicsWorld.body(alongRayStart: CGPoint(x: rayStart.x + 1, y: rayStart.y), end: CGPoint(x: rayEnd.x + 1, y: rayEnd.y))    //Ray is 1m to right of first ray
//    //NOTE: NULL result means no vehicle detected !!!
//    let distanceAhead2 = (frontObject2.position.y - (frontObject2.size.height / 2)) - rayStart.y
//
//    if distanceAhead1 <= distanceAhead2 {
//        let frontObject = frontObject1
//        let distanceAhead = distanceAhead1
//    } else {
//        let frontObject = frontObject2
//        let distanceAhead = distanceAhead2
//    }
//}
//
//func findCarInFront(thisVehicle: Vehicle) {
//
//
//}
//
    
////Loop through both arrays simultaneously. Move back 1km when they've travelled 1km!
//    for (sKLNode, sOtherNode) in zip(t1Vehicle.dropFirst(), t2Vehicle.dropFirst()) {
//    if sKLNode.position.y >= 1000 {
//        //IMPORTANT!!! ??? Prevent change to pos.y in other thread during the following instruction !!!
//        sKLNode.position.y = (sKLNode.position.y - 1000)
//        sKLNode.laps += 1
//    }
        

//struct NodeData {
//    var name: String
//    
/////x-y position in metres
//    var position: CGPoint
//    var size: CGSize
//    var lane: CGFloat
//    var speed: CGFloat
//    var laps: CGFloat
//    var gap: CGFloat
//    var otherGap: CGFloat
//    var rearGap: CGFloat
//    var preferredSpeed: CGFloat
//    var currentSpeed: CGFloat
//    var goalSpeed: CGFloat
//    var changeTime: CGFloat
//
//    init() {
//        name = "nil"
//        position = CGPoint(x: 0, y: 0)
//        size = CGSize(width: 1, height: 1)
//        lane = 0
//        speed = 0
//        laps = 0
//        gap = 0
//        otherGap = 0
//        rearGap = 0
//        preferredSpeed = 0
//        currentSpeed = 0
//        goalSpeed = 0
//        changeTime = 0
//    }
//
//    
////    mutating func findObstacles(t1Vehicle: inout [NodeData]) async -> (t1Vehicle: [NodeData], t2Vehicle: [NodeData]) {
//    mutating func findObstacles(t1Vehicle: inout [NodeData], t2Vehicle: inout [NodeData]) async -> (t1Vehicle: [NodeData], t2Vehicle: [NodeData]) {
//    //Create copy of vehicles for calculating proximity to other vehicles
//    //  Do calculations on background thread
//        //
//        //    var t1Vehicle = sKLAllVehicles.map{ $0.copy() }      //Straight Track Vehicles: Ignore 'All Vehicles'
//        //    var t1Vehicle = sKLAllVehicles.dropFirst()
//        //    t1Vehicle.sort(by: {$0.position.y < $1.position.y}) //Sort into positional order, 000 - 999.999
//
////        print("\(t1Vehicle[1].position)")
//        
//    t1Vehicle.sort(by: {$0.position.y < $1.position.y}) //Sort into positional order, 000 - 999.999
//        var t1Vehicle = t1Vehicle
//
//    t2Vehicle.sort(by: {$0.position.y < $1.position.y}) //Sort into positional order, 000 - 999.999
//    
//    var gap: CGFloat = 0.0      //Distance ahead in THIS lane
//    var otherGap: CGFloat = 0.0     //Distance ahead in OTHER lane
//    var rearGap: CGFloat = 0.0      //Distance behind in OTHER lane
//    
//    //Loop through arrays to confirm distance to vehicle in front
//    //Loop through Track 1 (KL) first
//    for (index, veh1Node) in t1Vehicle.enumerated() {
//        
//        var nextIndex = index + 1
//        var past1km = false
//        
//        let sameLane = (veh1Node.lane - 0.5)...(veh1Node.lane + 0.5)   //Scan for vehicles within 0.5 lanes either side
//        let sameLap = (t1Vehicle[nextIndex].position.y - (t1Vehicle[nextIndex].size.height / 2)) - (veh1Node.position.y + (veh1Node.size.height / 2))                             //Vehicle in front on same side of 1km boundary
//        let lastLap = ((t1Vehicle[nextIndex].position.y + 1000) - (t1Vehicle[nextIndex].size.height / 2)) - (veh1Node.position.y + (veh1Node.size.height / 2))      //Vehicle in front is over the 1km boundary!
//        
//        while gap == 0 && otherGap == 0 {
//            
//            if nextIndex >= numVehicles {
//                
//                nextIndex = 0       //Crossed 1km barrier. Continue search
//                past1km = true      //Flag indicates vehicle in front is beyond 1km boundary
//                continue            //Skip past else & continue with code below
//                
//            } else {
//                //NOTE: 0.5 lanewidth used for now due to in & out. May extend to 0.7 or so later!!!
//                if sameLane.contains(t1Vehicle[nextIndex].lane) {
//                    //Both vehicles in same lane
//                    if gap == 0 {
//                        gap = (past1km == false) ? sameLap : lastLap
//                        if gap == 0 { gap = 0.1 } //Should NEVER happen! (due to self braking)
//                        //                    veh1Node.spacing = gap
//                    }
//                } else {
//                    //The two vehicles are in different lanes
//                    if otherGap == 0 {
//                        otherGap = (past1km == false) ? sameLap : lastLap
//                        if otherGap == 0 { otherGap = 0.1 } //Could prevent -ve values by using <= here
//                        //                    veh1Node.otherGap = otherGap
//                    }
//                }       //end lane check
//                
//                nextIndex += 1  //Move onto next vehicle
//                if nextIndex == index {
//                    if gap == 0 { gap = 1000 }
//                    if otherGap == 0 { otherGap = 1000 } //NOTE: Don't yet know distance to vehicle behind in other lane!
//                }    //Continue until spacing for BOTH lanes != 0
//                
//            }           //end nextIndex 'if' statement
//            
//        }               //end While
//        t1Vehicle[index].gap = gap
//        t1Vehicle[index].otherGap = otherGap
//        
//        t1Vehicle.sort(by: {$0.position.y > $1.position.y}) //Sort into positional order, 999.999 - 000
//        var t1Vehicle: [NodeData] = t1Vehicle
//        
//        //Loop through arrays to confirm distance to vehicle behind in the other lane
//        //Loop through Track 1 (KL) first
//        for (index, veh1Node) in t1Vehicle.enumerated() {
//            
//            var nextIndex = index + 1
//            var past1km = false
//            
//            let sameLap = (veh1Node.position.y - (veh1Node.size.height / 2)) - (t1Vehicle[nextIndex].position.y + (t1Vehicle[nextIndex].size.height / 2)) //Vehicle in front on same side of 1km boundary
//            let lastLap = ((veh1Node.position.y + 1000) - (veh1Node.size.height / 2)) - (t1Vehicle[nextIndex].position.y + (t1Vehicle[nextIndex].size.height / 2))    //Vehicle in front is over the 1km boundary!
//            
//            
//            while rearGap == 0 {
//                
//                if nextIndex >= numVehicles {
//                    
//                    nextIndex = 0       //Crossed 1km barrier. Continue search
//                    past1km = true      //Flag indicates vehicle in front is beyond 1km boundary
//                    continue            //Skip past else & continue with code below
//                    
//                } else {
//                    //NOTE: 0.5 lanewidth used for now due to in & out. May extend to 0.7 or so later!!!
//                    if !sameLane.contains(t1Vehicle[nextIndex].lane) {
//                        //Both vehicles in different lanes
//                        rearGap = (past1km == false) ? sameLap : lastLap
//                        if rearGap == 0 { rearGap = 0.1 }
//                        //                    veh1Node.rearGap = rearGap
//                    } else {
//                        //The two vehicles are in the same lane
//                        nextIndex += 1  //Move onto next vehicle
//                        if nextIndex == index {         //All other vehicles checked. rearGap sb 0 here!
//                            if rearGap == 0 { rearGap = 1000 }
//                        }    //Continue until spacing for BOTH lanes != 0
//                        
//                    }       //end lane check
//                    
//                }           //end nextIndex 'if' statement
//                
//                
//            }               //end while
//            
//            
//            t1Vehicle[index].rearGap = rearGap
//            
//        }
//        
//        //MARK: - At this point spacing = distance to vehicle in front(gap: same lane, otherGap: other lane)
//        //MARK:   rearGap = distance of first vehicle behind & in other lane.
//        //NOTE: ALL values above can read negative IF position differences < vehicle lengths!
//        //       (can be changed by using <= instead of == above)
//        
//        var gapSpeed = gap * 1.2    //Max allowable speed for current gap
//        var goalSpeed: CGFloat = gapSpeed  //Aim for this speed while in this lane
//        
//        if gapSpeed > veh1Node.preferredSpeed {
//            goalSpeed = veh1Node.preferredSpeed
//        }
//        //    else {
//        //        goalSpeed = gapSpeed  //Already = gapSpeed
//        //    }
//        
//        //Acceleration & deceleration fixed FOR NOW!!!
//        var accel: CGFloat = 2    // m per sec2
//        //    var truckAccel: CGFloat = 1.0
//        var decel: CGFloat = 4    // m per sec2
//        //    var truckDecel: CGFloat = 0.9
//        let spdChange = abs(goalSpeed - veh1Node.currentSpeed)
//        var changeTime: CGFloat = 1     //Set initial value = 1 second
//        //    if sKLAllVehicles[index].currentSpeed >= goalSpeed {
//        if veh1Node.currentSpeed >= goalSpeed {
//            //Slow to goalSpeed which can be preferredSpeed or gapSpeed
//            
//            if (spdChange / 3.6) > decel {      //where spdChange is in km
//                changeTime = ((spdChange / 3.6) / decel)
//            }   //else { changeTime = 1 }   //already = 1. Slows final deceleration
//            
//        } else {
//            //Accelerate to goalSpeed which can be preferredSpeed or gapSpeed
//            
//            if (spdChange / 3.6) > accel {      //where spdChange is in km
//                changeTime = ((spdChange / 3.6) / accel)
//            }   //else { changeTime = 1 }   //already = 1. Slows final acceleration
//            
//        }
//        
//        t1Vehicle[index].goalSpeed = goalSpeed   //Store ready for SKAction
//        t1Vehicle[index].changeTime = changeTime //Store run time for next SKAction
//    }
//    
//    return (t1Vehicle, t2Vehicle)
//}
//
//}       //end of struct NodeData


//$$$$$$$$$$$$$$$$$  START HERE   $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

////Run on Main Thread!
//var temp1 = sKLAllVehicles.dropFirst()      //Straight Track Vehicles: Ignore 'All Vehicles'
//var nodeData: NodeData = NodeData()
//var t1Vehicle: [NodeData] = []
//
//for (index, veh1Node) in temp1.enumerated() {
//    nodeData.name = veh1Node.name!      //OR = (index + 1)?
//    nodeData.size = veh1Node.size
//    nodeData.position = veh1Node.position
//    nodeData.lane = veh1Node.lane
//    nodeData.laps = veh1Node.laps
//    nodeData.speed = veh1Node.physicsBody!.velocity.dy      //  ????? or veh1Node.speed ????
//    t1Vehicle.append(nodeData)
//}
//
//var temp2 = sOtherAllVehicles.dropFirst()      //Straight Track Vehicles: Ignore 'All Vehicles'
////var nodeData: NodeData = NodeData()
//var t2Vehicle: [NodeData] = []
//
//for (index, veh2Node) in temp2.enumerated() {
//    nodeData.name = veh2Node.name!      //OR = (index + 1)?
//    nodeData.size = veh2Node.size
//    nodeData.position = veh2Node.position
//    nodeData.lane = veh2Node.lane
//    nodeData.laps = veh2Node.laps
//    nodeData.speed = veh2Node.physicsBody!.velocity.dy      //  ????? or veh1Node.speed ????
//    t1Vehicle.append(nodeData)
//}
//
//Task {
//    var result = await findObstacles(t1Vehicle, t2Vehicle)
//    let t1Vehicle = result.t1Vehicle
//    let t2Vehicle = result.t2Vehicle
//}
//




