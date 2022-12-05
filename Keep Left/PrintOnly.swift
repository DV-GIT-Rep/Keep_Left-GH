////$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
////Run on Main Thread!
//
//if gameStage < 0xFF {           //Prevents code from running before vehicles are created.
//                                //MSB cleared when vehicles created ie. #7FH -> gameStage
//    
//        let noVehTest: Int = 0x40   //Test Flag
//        var testNo: Int
//
//    //gameStage bit 40H set indicates below is in progress
//    //          bits 1 & 0 indicate stage: 10 -> 01 -> 00 -> 11
//    testNo = (gameStage & noOfCycles)   //Only interested in 2 LSBs gameStage
//        if testNo != 0 {
//            gameStage -= 1      //Decrement gameStage
//        } else {
//            gameStage = gameStage | noOfCycles      //Set 2 LSBs
//            
//            if gameStage < 0x40 {
//                
//            gameStage = gameStage | noVehTest       //Set 2nd MSB. Don't clear until all below done!
//
//            
//            var temp1 = sKLAllVehicles.dropFirst()      //Straight Track Vehicles: Ignore 'All Vehicles'
//            var nodeData: NodeData = NodeData()
//            var t1Vehicle: [NodeData] = []
//            
//            for (index, veh1Node) in temp1.enumerated() {
//                nodeData.name = veh1Node.name!      //OR = (index + 1)?
//                nodeData.size = veh1Node.size
//                nodeData.position = veh1Node.position
//                nodeData.lane = veh1Node.lane
//                nodeData.laps = veh1Node.laps
//                nodeData.preferredSpeed = veh1Node.preferredSpeed
//                nodeData.currentSpeed = veh1Node.physicsBody!.velocity.dy * 3.6      //  ????? x 3.6 for kph?
//                nodeData.otherTrack = veh1Node.otherTrack
//                nodeData.startPos = veh1Node.startPos
//                nodeData.speedMax = veh1Node.speedMax
//                nodeData.speedMin = veh1Node.speedMin
//                t1Vehicle.append(nodeData)
//            }
//            
//            var temp2 = sOtherAllVehicles.dropFirst()      //Straight Track Vehicles: Ignore 'All Vehicles'
//            var t2Vehicle: [NodeData] = []
//            
//            for (index, veh2Node) in temp2.enumerated() {
//                nodeData.name = veh2Node.name!      //OR = (index + 1)?
//                nodeData.size = veh2Node.size
//                nodeData.position = veh2Node.position
//                nodeData.lane = veh2Node.lane
//                nodeData.laps = veh2Node.laps
//                nodeData.preferredSpeed = veh2Node.preferredSpeed
//                nodeData.currentSpeed = veh2Node.physicsBody!.velocity.dy * 3.6      //  ????? x 3.6 for kph?
//                nodeData.otherTrack = veh2Node.otherTrack
//                nodeData.startPos = veh2Node.startPos
//                nodeData.speedMax = veh2Node.speedMax
//                nodeData.speedMin = veh2Node.speedMin
//                t2Vehicle.append(nodeData)
//            }
//                
//            var returnKL: [NodeData] = t1Vehicle
//            var returnOther: [NodeData] = t2Vehicle
//            Task {
//                var result = await nodeData.findObstacles(t1Vehicle: &t1Vehicle, t2Vehicle: &t2Vehicle)
//                returnKL = result.t1Vehicle
//                returnOther = result.t2Vehicle
//                
//                updateSpeeds(returnKL: returnKL, returnOther: returnOther)      //Update vehicle speeds
//                
//                //NOT in Vehicle order! Arranged by Y Position!
//                //Sort back into Vehicle No order. Note [0] is missing
//                returnKL.sort {
//                    $0.name.localizedStandardCompare($1.name) == .orderedAscending
//                }                               //'lacalizedStandardCompare' ensures 21 sorted AFTER 3
//                returnKL.insert(returnKL[2], at: 0)   //Copy dummy into position [0] (All Vehicles).
//                returnKL[0].name = "All Vehicles"
//                
//                var f8T1Spots = await nodeData.findF8Pos(t1Veh: &returnKL)
//                
//                updateF8T1Spots(t1Vehicle: f8T1Spots)
//                
//                //Once every 500-600ms sufficient for display calcs below
//                var rtnKL = await nodeData.calcAvgData(t1Veh: &f8T1Spots)
//                
//                for i in 1..<rtnKL.count {
//                    sKLAllVehicles[i].speedMax = rtnKL[i].speedMax
//                    sKLAllVehicles[i].speedMin = rtnKL[i].speedMin
//                }
//
//                rtnKL[0].distance = klDistance0
//                rtnKL[0].distanceMax = klDistanceMax0
//                rtnKL[0].distanceMin = klDistanceMin0
//                rtnKL[0].speedAvg = klSpeedAvg0
//                rtnKL[0].speedMax = klSpeedMax0
//                rtnKL[0].speedMin = klSpeedMin0
//                
////                        //Other Track - May use separate routine???
////                        sOtherAllVehicles[0].distance = oDistance0
////                        sOtherAllVehicles[0].distanceMax = oDistanceMax0
////                        sOtherAllVehicles[0].distanceMin = oDistanceMin0
////                        sOtherAllVehicles[0].speedAvg = oSpeedAvg0
////                        sOtherAllVehicles[0].speedMax = oSpeedMax0
////                        sOtherAllVehicles[0].speedMin = oSpeedMin0
////                        print("f8DisplayDat: \(f8DisplayDat)\tAvg Speed: \(rtnKL[f8DisplayDat].speedAvg.dp2)")
//
//                topLabel.updateLabel(topLabel: true, vehicel: rtnKL[f8DisplayDat])  //rtnKL has no element 0!
//                bottomLabel.updateLabel(topLabel: false, vehicel: rtnKL[f8DisplayDat])  //TEMP! Same data as Top Label!!!
//                
//            }       //End Task
//            
//                gameStage = gameStage & (0xFF - noVehTest)       //Clear 2nd MSB. Don't clear until all above done!
//                
//            }       //End gameStage < 0x3F
//            
//        }   //End else
//    
//}           //End gameStage < 0xFF
//
////$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
//
