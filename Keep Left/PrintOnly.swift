////  7 May 2024
//
////Run on Main Thread!
//if gameStage < 0x80 {           //Prevents code from running before vehicles are created.
//    //MSB cleared when vehicles created ie. #7FH -> gameStage
//    //Above changed from 0xFF to 0x80 7/1/24. Should make NO DIFFERENCE TO OPERATION!
//    //'noVehTest' flag (40H) set prior to 'Task' & set to 0 at end of Task.
//    if gameStage < 0x40 {
//        
//        let noVehTest: Int = 0x40   //Test Flag
//        var testNo: Int
//        
////gameStage bit 40H set indicates below is in progress
////          bits 1 & 0 indicate stage: 10 -> 01 -> 00 -> 11
////            testNo = (gameStage & noOfCycles)   //Only interested in 2 LSBs gameStage. Set other bits = 0.
//        testNo = (gameStage & 0x03)   //Only interested in 2 LSBs gameStage. Set other bits = 0.
////Changed from 'noOfCycles' to 0x03 7/1/24
////Result = 00, 01, 10 or 11
//        if testNo != 0 {
//            gameStage -= 1      //Decrement gameStage only when > 0
//        } else {
//    //                    gameStage = gameStage & 0xFC        //0 -> 2 LSBs. 2 LSBs ALREADY = 0!!!
//            gameStage = gameStage | noOfCycles  //Set 2 LSBs = noOfCycles
//    //                    gameStage = gameStage | 0x03      //Set 2 LSBs (same effect as above IF noOfCycles = 03).
//        }   //End else
//        
//        gameStage = gameStage | noVehTest       //Set 2nd MSB. Don't clear until all below done!
//                
//        var t1Vehicle = Array(t1xVehicle.dropFirst())       //Ignore 'All Vehicles'
//        
//        var t2Vehicle = Array(t2xVehicle.dropFirst())       //Ignore 'All Vehicles'
//        
////MARK: - TASK
//        Task {
//            let doT2: Int = 1
//            if (gameStage & doT2) == 0 {    //Bit 0 = 0 then update Keep Left Track
//        //***************  1. findObstacles + updateSpeeds  ***************
//        //Keep Left Track (Track 1)  = gameStage bit 0 = 0
//                allAtSpeed1 = true
//                
//                var ret1urn: [NodeData] = t1Vehicle        //Used for both Track 1 & Track 2
//                var result1 = await nodeData.findObstacles(tVehicle: &t1Vehicle)
//                ret1urn = result1
//                
//                updateSpeeds(retVeh: result1, allVeh: &sKLAllVehicles)      //Update vehicle speeds
//                
//        //***************  2. Restore Array  ***************
//        //NOT in Vehicle order! Arranged by Y Position!
//        //Sort back into Vehicle No order. Note [0] is missing
//                ret1urn.sort {
//                    $0.name.localizedStandardCompare($1.name) == .orderedAscending
//                }                               //'localizedStandardCompare' ensures 21 sorted AFTER 3
//                ret1urn.insert(t1xVehicle[0], at: 0)   //Copy All Vehicles into position [0].
//                ret1urn[0].name = "All Vehicles"
//                
//        //***************  2a. KL Overtake  ***************
//                var re1turnV: [NodeData] = await nodeData.goLeft(teeVeh: &ret1urn)
//                
//        //***************  3. findF8Pos + updateF8Spots  ***************
//                var f8T1Spots = await nodeData.findF8Pos(t1Veh: &re1turnV)
//                
//                updateF8TSpots(t1Vehicle: f8T1Spots, kLTrack: true)
//                
//        //***************  4. updateLabel  ***************
//        //Once every 500-600ms sufficient for display calcs below
//                var rtnT1Veh = await nodeData.calcAvgData(t1xVeh: &re1turnV)
//                
//                for i in 1..<rtnT1Veh.count {
//                    if i == 0 {continue}       //Skip loop for element[0] = All Vehicles
//                    
////If vehicle crosses 1km boundary then subtract tracklength from the y position.
//                    if sKLAllVehicles[i].position.y >= sTrackLength {
////IMPORTANT!!! ??? Prevent change to pos.y in other thread during the following instruction !!!
//                        sKLAllVehicles[i].position.y = (sKLAllVehicles[i].position.y - sTrackLength)
//                        sKLAllVehicles[i].laps += 1
//                    }
//                    
////Code below starts lane change & indicators where required for the Keep Left track
//                    let cLResult1 = nodeData.changeLanes(retnVeh: rtnT1Veh, i: i, kLTrack: true)
//                    rtnT1Veh = cLResult1
//                }               //End 'for' loop
//        //All vehicles on Track 1 (Keep Left Track) checked
//                
//        //MARK: - Calculate distances & speeds for 'All Vehicles'
//                
//            topLabel.updateLabel(topLabel: true, vehicel: rtnT1Veh[f8DisplayDat])  //rtnT1Veh has no element 0!
//                
//            } else {            //Bit 0 = 1 then update Other Track
//        //***************  1. findObstacles + updateSpeeds  ***************
//        //Other Track (Track 2)  = gameStage bit 0 = 1
//                allAtSpeed2 = true
//                
//                var ret2urn: [NodeData] = t2Vehicle        //Used for both Track 2
//                var result2 = await nodeData.findObstacles(tVehicle: &t2Vehicle)
//                ret2urn = result2
//                
//                updateSpeeds(retVeh: result2, allVeh: &sOtherAllVehicles)      //Update vehicle speeds
//                
//        //***************  2. Restore Array  ***************
//        //NOT in Vehicle order! Arranged by Y Position!
//        //Sort back into Vehicle No order. Note [0] is missing
//                ret2urn.sort {
//                    $0.name.localizedStandardCompare($1.name) == .orderedAscending
//                }                               //'localizedStandardCompare' ensures 21 sorted AFTER 3
//                ret2urn.insert(t2xVehicle[0], at: 0)   //Copy All Vehicles into position [0].
//                ret2urn[0].name = "All Vehicles"
//                
//        //***************  2a. KL Overtake  ***************
//        //NOTE: Other Track doesn't Keep Left!
//                var re2turnV: [NodeData] = await nodeData.goLeft(teeVeh: &ret2urn)
//        //                            var re2turnV: [NodeData] = ret2urn
//        //Toggle above 2 instructions to run or disable goLeft function! (currently only KL Track)
//                
//        //***************  3. findF8Pos + updateF8Spots  ***************
//                var f8T2Spots = await nodeData.findF8Pos(t1Veh: &re2turnV)
//                
//                updateF8TSpots(t1Vehicle: f8T2Spots, kLTrack: false)
//                
//        //***************  4. updateLabel  ***************
//        //Once every 500-600ms sufficient for display calcs below
//                var rtnT2Veh = await nodeData.calcAvgData(t1xVeh: &re2turnV)
//                
//                for i in 1..<rtnT2Veh.count {
//                    
////If vehicle crosses 1km boundary then add tracklength to the y position.
//                if sOtherAllVehicles[i].position.y < 0 {
////IMPORTANT!!! ??? Prevent change to pos.y in other thread during the following instruction !!!
//                    sOtherAllVehicles[i].position.y = (sOtherAllVehicles[i].position.y + sTrackLength)
//                    sOtherAllVehicles[i].laps += 1
//                }
//                    
////Code below starts lane change & indicators where required for the Keep Left track
//                let cLResult2 = nodeData.changeLanes(retnVeh: rtnT2Veh, i: i, kLTrack: false)
//                rtnT2Veh = cLResult2
//            }
//        //All vehicles on Track 2 (Other Track) checked
//                
//        //MARK: - Calculate distances & speeds for 'All Vehicles'
//                
//            bottomLabel.updateLabel(topLabel: false, vehicel: rtnT2Veh[f8DisplayDat])  //TEMP! Same data as Top Label!!!
//                
//        }   //Both tracks done
//    }       //End Task
//        
//        gameStage = gameStage & (0xFF - noVehTest)       //Clear 2nd MSB. Don't clear until all above done!
//        
//    }       //End gameStage < 0x40
//}   //End gameStage < 0xFF
