
import Foundation
import SpriteKit


////Make the method below part of the NodeData Struct
//func findF8Pos(t1Veh: inout [NodeData]) async -> ([NodeData]) {         //Note: t1Veh has stKL_0 or stOt_0 removed!
//    
//    var f8EquivName: String = ""
//    var key: String = ""            //
//    
//    for (indx, t1Node) in t1Veh.enumerated() {
//
//    //MARK: - Find name of Fig 8 Track equivalent to Straight Track Vehicle
//    //          eg.stKL_8 -> f8KL_8 OR stOT_35 -> f8Ot_35
//        f8EquivName = String(t1Node.name.dropFirst(2))        //Remove 'st' from start of name
//        f8EquivName.insert(contentsOf: "//f8", at: f8EquivName.startIndex)
//        t1Veh[indx].equivF8Name = f8EquivName
//    
////    guard let f8Node = childNode(withName: f8EquivName) else {
////        return
////    }
//    
//        //May? need following ??
////    let actionTimeF8: CGFloat = 0.5  //SAME period as 'every500ms' timer!
//    
////    key = String(t1Node.name.suffix(3))     //Move these 2 lines to "MainActor"?
////    key = "key\(key)"
//    
//        //May? need following ??
//        var lanePos: CGFloat = ((FarLane - CloseLane) * t1Node.lane + CloseLane)
//        if t1Node.otherTrack == true {     //If tracks back to front, reverse polarity here!!!
//        lanePos = -lanePos
//    }
//    
//    var newF8NodePos = t1Node.f8Pos         //???
//    var currentSNodePos = t1Node.position   //???
//    
//    //MARK: - Calculate position of figure 8 vehicle based on straight track vehicle
//    switch t1Node.position.y {
//    case let y1 where y1 <= F8Radius:
//        //1st straight stretch 45' from origin dn and to right
//        //Origin = (0,0) so move immediately
//        newF8NodePos.x = 0 + (cos45Deg * y1)
//        newF8NodePos.y = 0 - (sin45Deg * y1)
//        
//        newF8NodePos.x = newF8NodePos.x + (cos45Deg * lanePos)
//        newF8NodePos.y = newF8NodePos.y - (sin45Deg * lanePos)
//
//        t1Veh[indx].f8Rot = t1Node.otherTrack ? CGFloat(45).degrees() : -CGFloat(135).degrees()
//
//        t1Veh[indx].f8Pos = CGPoint(x: newF8NodePos.x, y: newF8NodePos.y)
//        t1Veh[indx].f8zPos = 10       //Set zPosition lower than bridge (zPos: 15)
//
////        let newF8Pos = SKAction.move(to: f8NodePos, duration: actionTimeF8)
////        let newF8Rot = SKAction.rotate(toAngle: f8NodeRot, duration: actionTimeF8, shortestUnitArc: true)
////        let group = SKAction.group([newF8Pos, newF8Rot])
////
////        f8Node.run(group, withKey: "key")
//
//    case var y1 where y1 <= (F8Radius + (piBy1p5 * F8Radius)):
//        //1st 3/4 circle heading down and to left
//        y1 = y1 - F8Radius
//        
//        var y1Deg: CGFloat = -y1 * y1Mx      //Defines angle change from start of 3/4 circle to current position
//        y1Deg = y1Deg + 45                  //Start from angle 3 o'clock
//        
//        newF8NodePos.x = CGFloat(0)         //Sets starting position to circle centre
//        newF8NodePos.y = -f8CircleCentre
//        let laneRadius: CGFloat = F8Radius + lanePos
//
//        newF8NodePos.x = newF8NodePos.x + ((laneRadius + fudgeFactor) * cos(CGFloat(y1Deg).degrees()))
//        newF8NodePos.y = newF8NodePos.y + ((laneRadius + fudgeFactor) * sin(CGFloat(y1Deg).degrees()))
//            
//        t1Veh[indx].f8Pos = CGPoint(x: newF8NodePos.x, y: newF8NodePos.y)
//
//        if t1Node.otherTrack == false { y1Deg = y1Deg - 180}    //Turns vehicle 180 degrees
//        if y1Deg < -180 { y1Deg = y1Deg + 360 }  //Resolves node spinning problem
//        t1Veh[indx].f8Rot = y1Deg.degrees()
//
////        let newF8Pos = SKAction.move(to: f8NodePos, duration: actionTimeF8)
////        let newF8Rot = SKAction.rotate(toAngle: f8NodeRot, duration: actionTimeF8, shortestUnitArc: true)
////        let group = SKAction.group([newF8Pos, newF8Rot])
////
////        f8Node.run(group, withKey: "key")
//
//    case var y1 where y1 <= ((3 * F8Radius) + (piBy1p5 * F8Radius)):
//        //2nd straight stretch 45' up to right
//        y1 = y1 - (F8Radius + (piBy1p5 * F8Radius))
//
//        newF8NodePos.x = -halfDiagonalXY    //Point 75m diagonally down & to left of origin
//        newF8NodePos.y = -halfDiagonalXY
//
//        newF8NodePos.x = newF8NodePos.x + (cos45Deg * y1)
//        newF8NodePos.y = newF8NodePos.y + (sin45Deg * y1)
//
//        newF8NodePos.x = newF8NodePos.x - (cos45Deg * lanePos)
//        newF8NodePos.y = newF8NodePos.y + (sin45Deg * lanePos)
//
//        t1Veh[indx].f8Rot = t1Node.otherTrack ? CGFloat(135).degrees() : -CGFloat(45).degrees()
//
//        t1Veh[indx].f8Pos = CGPoint(x: newF8NodePos.x, y: newF8NodePos.y)
//        t1Veh[indx].f8zPos = 20       //Set zPosition higher than bridge (zPos: 15)
//
////        let newF8Pos = SKAction.move(to: f8NodePos, duration: actionTimeF8)
////        let newF8Rot = SKAction.rotate(toAngle: f8NodeRot, duration: actionTimeF8, shortestUnitArc: true)
////        let group = SKAction.group([newF8Pos, newF8Rot])
////
////        f8Node.run(group, withKey: "key")
//
//    case var y1 where y1 <= ((3 * F8Radius) + (piBy3 * F8Radius)):
//        //2nd 3/4 circle heading up and to left
//        y1 = y1 - ((3 * F8Radius) + (piBy1p5 * F8Radius))
//        
//        var y1Deg: CGFloat = y1 * y1Mx      //Defines angle change from start of 3/4 circle to current position
//        y1Deg = y1Deg - 45                  //Start from angle 3 o'clock
//        
//        newF8NodePos.x = CGFloat(0)         //Sets starting position to circle centre
//        newF8NodePos.y = f8CircleCentre
//        let laneRadius: CGFloat = F8Radius - lanePos
//
//        newF8NodePos.x = newF8NodePos.x + ((laneRadius + fudgeFactor) * cos(CGFloat(y1Deg).degrees()))
//        newF8NodePos.y = newF8NodePos.y + ((laneRadius + fudgeFactor) * sin(CGFloat(y1Deg).degrees()))
//
//        t1Veh[indx].f8Pos = CGPoint(x: newF8NodePos.x, y: newF8NodePos.y)
//
//        if t1Node.otherTrack == true { y1Deg = y1Deg + 180}    //Turns vehicle 180 degrees
//        if y1Deg > 180 { y1Deg = y1Deg - 360 }  //Resolves node spinning problem
//        t1Veh[indx].f8Rot = y1Deg.degrees()
//
////        let newF8Pos = SKAction.move(to: f8NodePos, duration: actionTimeF8)
////        let newF8Rot = SKAction.rotate(toAngle: f8NodeRot, duration: actionTimeF8, shortestUnitArc: true)
////        let group = SKAction.group([newF8Pos, newF8Rot])
////
////        f8Node.removeAction(forKey: "key")
////        f8Node.run(group, withKey: "key")
//
//    case var y1 where y1 <= ((4 * F8Radius) + (piBy3 * F8Radius)):
//        //3rd & final straight stretch 45' down & back to origin
////            y1 = y1 - ((3 * F8Radius) + (piBy3 * F8Radius))
//        y1 = ((4 * F8Radius) + (piBy3 * F8Radius)) - y1    //Changes y1 so 1006.858 (for F8Radius = 75m) = the origin (easier calculation)
//        
//        newF8NodePos.x = -(cos45Deg * y1)
//        newF8NodePos.y = (sin45Deg * y1)
//        
//        newF8NodePos.x = newF8NodePos.x + (cos45Deg * lanePos)
//        newF8NodePos.y = newF8NodePos.y - (sin45Deg * lanePos)
//
//        t1Veh[indx].f8Rot = t1Node.otherTrack ? CGFloat(45).degrees() : -CGFloat(135).degrees()
//
//        t1Veh[indx].f8Pos = CGPoint(x: newF8NodePos.x, y: newF8NodePos.y)
//        t1Veh[indx].f8zPos = 10       //Set zPosition lower than bridge (zPos: 15)
//
////        let newF8Pos = SKAction.move(to: f8NodePos, duration: actionTimeF8)
////        let newF8Rot = SKAction.rotate(toAngle: f8NodeRot, duration: actionTimeF8, shortestUnitArc: true)
////        let group = SKAction.group([newF8Pos, newF8Rot])
////
////        f8Node.run(group, withKey: "key")
//
//    default:
//        break
//
//    }           //end Switch statement
//        
//    }           //End t1Node 'for' loop
//
//    return t1Veh
//}           //end moveF8Vehicle method
