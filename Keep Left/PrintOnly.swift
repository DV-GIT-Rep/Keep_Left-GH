////MARK: - Update speed of vehicles on Straight Track, braking for obstacles
//@MainActor func updateSpeeds(returnKL: [NodeData], returnOther: [NodeData]) {
//    var speedChange: CGFloat
//    var newTime: CGFloat
//    var newSpeed: CGFloat
//    var action: SKAction
//    var unitNum: Int
//
//    let printGoals = false
//    if printGoals {
//        print("\nUnit\tprefSpd\tgoalSpd\tcurrSpd\tnewSpd\tchTm\tgap\t\tnewT")
//    }
//for (index, veh1Node) in returnKL.enumerated() {            //index = 0 - (numVehicles - 1)
//    
//    //THIS Vehicle = veh1Node = sKLAllVehicles[unitNum] = returnKL[index]
//    unitNum = Int.extractNum(from: veh1Node.name)!  //NOTE: Use [unitNum] for sKLAllVehicles. Use [index] for returnKL!
//    
//    speedChange = (veh1Node.goalSpeed - veh1Node.currentSpeed)
//    newTime = veh1Node.changeTime * (60 / (CGFloat(noOfCycles) + 1))     //newTime = no of cycles @60/30/20Hz in changeTime
//    newSpeed = veh1Node.currentSpeed + (speedChange / newTime)
//    //print("1.\t\(unitNum)\t\t\(veh1Node.preferredSpeed.dp2)\t\(veh1Node.goalSpeed.dp2)\t\(veh1Node.currentSpeed.dp2)\t\(newSpeed.dp2)\t\(veh1Node.changeTime.dp2)\t\(veh1Node.gap.dp2)\t\(newTime.dp2)")
//    sKLAllVehicles[unitNum].physicsBody?.velocity.dy = newSpeed / 3.6
//    
//    if veh1Node.lane == 0 {         //Reinforce xPos when in centre of lane - sKLVehicle
//        sKLAllVehicles[unitNum].position.x = -((roadWidth / 2) + (laneWidth / 2) + (lineWidth / 2) + (centreStrip/2))
//    } else if veh1Node.lane == 1 {
//        sKLAllVehicles[unitNum].position.x = -((roadWidth / 2) - (laneWidth / 2) - (lineWidth / 2) + (centreStrip/2))
//    }
//
//    if printGoals {
//        print("\(unitNum)\t\t\(veh1Node.preferredSpeed.dp2)\t\(veh1Node.goalSpeed.dp2)\t\(veh1Node.currentSpeed.dp2)\t\(newSpeed.dp2)\t\(veh1Node.changeTime.dp2)\t\(veh1Node.gap.dp2)\t\(newTime.dp2)")
//    }
//}
//}       //end @MainActor func updateSpeeds
