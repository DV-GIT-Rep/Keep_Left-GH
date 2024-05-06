//  6 May 2024

////Code below starts lane change & indicators where required
//func changeLanes(retnVeh: [NodeData], i: Int, kLTrack: Bool) -> ([NodeData]) {
//    var rtnVeh: [NodeData] = retnVeh
//    if rtnVeh[i].startIndicator == true { //Code only runs to Start Flashing
//        rtnVeh[i].startIndicator = false
//        if kLTrack {    //KL Track
//            sKLAllVehicles[i].startIndicator = false
//        } else {        //Not KL Track
//            sOtherAllVehicles[i].startIndicator = false
//        }               //end KL Track
//        if rtnVeh[i].indicator == .overtake { //About to Overtake
//            let halfFlash: CGFloat = 0.3    //Time indicators are ON or OFF
//            let numFlash = 6        //No of full indicator flashes
//            let flashTime: CGFloat = CGFloat(numFlash) * halfFlash * 1.8
//            let indicatorOn = SKAction.unhide() //Overtaking indicators ON
//            let indicatorOff = SKAction.hide()  //Overtaking indicators OFF
//            let deelay = SKAction.wait(forDuration: halfFlash)  //Delay halfFlash secs
//            let pulseIndicators = SKAction.sequence([indicatorOn, deelay, indicatorOff, deelay])
//            let flash1 = SKAction.repeat(pulseIndicators, count: numFlash)
//            let endLane1 = SKAction.run {
//                if kLTrack {    //KL Track
//                    sKLAllVehicles[i].lane = 1      //Ensure lane only = 1 or 0 when here!
//                    sKLAllVehicles[i].indicator = .off
//                    if printOvertake != 0 {
//                        print("\t\(i)   End Overtake\tLane \(sKLAllVehicles[i].lane.dp0)\tInd = \(sKLAllVehicles[i].indicator)")
//                    }           //end Print
//                } else {        //Not KL Track
//                    sOtherAllVehicles[i].lane = 1      //Ensure lane only = 1 or 0 when here!
//                    sOtherAllVehicles[i].indicator = .off
//                }               //end KL Track
//                rtnVeh[i].lane = 1      //Ensure lane only = 1 or 0 when here!
//                rtnVeh[i].indicator = .off
//            }                   //end SKAction.run
//            
//            let goToLane1 = SKAction.customAction(withDuration: flashTime, actionBlock: {
//                (node, elapsedTime) in
//                if kLTrack {
//                    sKLAllVehicles[i].lane = elapsedTime / flashTime
//                    rtnVeh[i].lane = sKLAllVehicles[i].lane //rtnVeh[i].lane = elapsedTime / flashTime
//                    if printOvertake > 1 {  //
//                        if whichOT == i {
//                            print("\(i) \(sKLAllVehicles[i].lane)") //All dig's. EndOT set to 3.
//                        }
//                    }
//                } else {   //end if kLTrack
//                    sOtherAllVehicles[i].lane = elapsedTime / flashTime
//                    rtnVeh[i].lane = sOtherAllVehicles[i].lane //rtnVeh[i].lane = elapsedTime / flashTime
//                    if printOvertake > 1 {  //
//                        if whichOT == i {
//                            print("\(i) \(sOtherAllVehicles[i].lane)") //All dig's. EndOT set to 3.
//                        }
//                    }
//                }
//            })
//            let laneChange = SKAction.group([goToLane1, flash1])
//            
//            if kLTrack {    //KL Track
//                sOtherAllVehicles[i].indicator = rtnVeh[i].indicator
//                sOtherAllVehicles[i].startIndicator = rtnVeh[i].startIndicator
//                sOtherAllVehicles[i].lane = rtnVeh[i].lane
//                
//                if printOvertake != 0 {
//                    let startMsg1 = SKAction.run {print("\t\(i) Start Overtake\tLane \(sKLAllVehicles[i].lane.dp0)\tInd = \(sKLAllVehicles[i].indicator)\tsInd = \(sKLAllVehicles[i].startIndicator)")}
//                    let laneFlash1 = SKAction.sequence([startMsg1, laneChange, endLane1])
//                    let newLanePos: Void = sKLAllVehicles[i].childNode(withName: "rightInd\(i)")!.run(laneFlash1)
//                    let lFlash1 = SKAction.sequence([laneChange, endLane1])
//                    let newF8LanePos: Void = f8KLAllVehicles[i].childNode(withName: "rightInd\(i)")!.run(lFlash1)
//                } else {
//                    let laneFlash1 = SKAction.sequence([laneChange, endLane1])
//                    let newLanePos: Void = sKLAllVehicles[i].childNode(withName: "rightInd\(i)")!.run(laneFlash1)
//                    let newF8LanePos: Void = f8KLAllVehicles[i].childNode(withName: "rightInd\(i)")!.run(laneFlash1)
//                }
//                
//            } else {    //Not KL Track
//                sOtherAllVehicles[i].indicator = rtnVeh[i].indicator
//                sOtherAllVehicles[i].startIndicator = rtnVeh[i].startIndicator
//                sOtherAllVehicles[i].lane = rtnVeh[i].lane
//                
//                if printOvertake != 0 { //Print
//                    let startMsg1 = SKAction.run {print("\t\(i) Start Overtake\tLane \(sOtherAllVehicles[i].lane.dp0)\tInd = \(sOtherAllVehicles[i].indicator)")}
//                    let laneFlash1 = SKAction.sequence([startMsg1, laneChange, endLane1])
//                    let newLanePos: Void = sOtherAllVehicles[i].childNode(withName: "rightInd\(i)")!.run(laneFlash1)
//                    let lFlash1 = SKAction.sequence([laneChange, endLane1])
//                    let newF8LanePos: Void = sOtherAllVehicles[i].childNode(withName: "rightInd\(i)")!.run(lFlash1)
//                } else {                //Don't print
//                    let laneFlash1 = SKAction.sequence([laneChange, endLane1])
//                    let newLanePos: Void = sOtherAllVehicles[i].childNode(withName: "rightInd\(i)")!.run(laneFlash1)
//                    let newF8LanePos: Void = sOtherAllVehicles[i].childNode(withName: "rightInd\(i)")!.run(laneFlash1)
//                }
//            }   //end KL Track
//            
//        } else {        //About to go back to left lane
//            if rtnVeh[i].indicator == .endOvertake {
//                let halfFlash: CGFloat = 0.3    //Time indicators are ON or OFF
//                let numFlash = 6        //No of full indicator flashes
//                let flashTime: CGFloat = CGFloat(numFlash) * halfFlash * 1.8
//                let indicatorOn = SKAction.unhide() //Overtaking indicators ON
//                let indicatorOff = SKAction.hide()  //Overtaking indicators OFF
//                let deelay = SKAction.wait(forDuration: halfFlash)  //Delay halfFlash secs
//                let pulseIndicators = SKAction.sequence([indicatorOn, deelay, indicatorOff, deelay])
//                let flash0 = SKAction.repeat(pulseIndicators, count: numFlash)
//                let endLane0 = SKAction.run {
//                    rtnVeh[i].lane = 0      //Ensure lane only = 1 or 0 when here!
//                    rtnVeh[i].indicator = .off
//                    if kLTrack {    //KL Track
//                        sKLAllVehicles[i].lane = 0      //Ensure lane only = 1 or 0 when here!
//                        sKLAllVehicles[i].indicator = .off
//                        if printOvertake != 0 {
//                            print("\t\t\t\t\t\t\(i)   End Back\tLane \(sKLAllVehicles[i].lane.dp0)\tInd = \(sKLAllVehicles[i].indicator)")
//                        }       //end Print
//                    } else {    //Not KL Track
//                        sOtherAllVehicles[i].lane = 0      //Ensure lane only = 1 or 0 when here!
//                        sOtherAllVehicles[i].indicator = .off
//                        if printOvertake != 0 {
//                            print("\t\t\t\t\t\t\(i)   End Back\tLane \(sOtherAllVehicles[i].lane.dp0)\tInd = \(sOtherAllVehicles[i].indicator)")
//                        }   //end Print
//                    }       //end KL Track
//                }           //End endLane0 action
//                
//                let startMsg = SKAction.run {
//                    if printOvertake != 0 {
//                        if kLTrack {    //KL Track
//                            print("\t\t\t\t\t\t\(i) Start Back\tLane \(sKLAllVehicles[i].lane.dp0)\tInd = \(sKLAllVehicles[i].indicator)")
//                        } else {    //Not KL Track
//                            print("\t\t\t\t\t\t\(i) Start Back\tLane \(sOtherAllVehicles[i].lane.dp0)\tInd = \(sOtherAllVehicles[i].indicator)")
//                        }       //end KL Track
//                    }           //end Print
//                }               //end SKAction.run
//                
//                let goToLane0 = SKAction.customAction(withDuration: flashTime, actionBlock: {
//                    (node, elapsedTime) in
//                    if kLTrack {    //KL Track
//                        sKLAllVehicles[i].lane = (1 - (elapsedTime / flashTime))
//                        rtnVeh[i].lane = sKLAllVehicles[i].lane
//                        if printOvertake > 1 {  //
//                            if whichOT == i {
//                                print("\(i) \(sKLAllVehicles[i].lane.dp3)")
//                            }
//                        }
//                    } else {    //Not KL Track
//                        sOtherAllVehicles[i].lane = (1 - (elapsedTime / flashTime))
//                        rtnVeh[i].lane = sOtherAllVehicles[i].lane
//                        if printOvertake > 1 {  //
//                            if whichOT == i {
//                                print("\(i) \(sOtherAllVehicles[i].lane.dp3)")
//                            }   //end specific vehicle
//                        }       //end Print
//                    }           //end KL Track
//                })               //End goToLane0 action
//                
//                let goLane0 = SKAction.group([goToLane0, flash0])
//                let laneFlash0 = SKAction.sequence([startMsg, goLane0, endLane0])
//                let lFlash0 = SKAction.sequence([goLane0, endLane0])
//                
//                if kLTrack {    //KL Track
//                    sKLAllVehicles[i].indicator = rtnVeh[i].indicator
//                    sKLAllVehicles[i].startIndicator = rtnVeh[i].startIndicator
//                    sKLAllVehicles[i].lane = rtnVeh[i].lane
//                    
//                    let newLanePos: Void = sKLAllVehicles[i].childNode(withName: "leftInd\(i)")!.run(laneFlash0)
//                    let newF8LanePos: Void = f8KLAllVehicles[i].childNode(withName: "leftInd\(i)")!.run(lFlash0)
//                    
//                } else {        //Not KL Track
//                    sOtherAllVehicles[i].indicator = rtnVeh[i].indicator
//                    sOtherAllVehicles[i].startIndicator = rtnVeh[i].startIndicator
//                    sOtherAllVehicles[i].lane = rtnVeh[i].lane
//                    
//                    let newLanePos: Void = sOtherAllVehicles[i].childNode(withName: "leftInd\(i)")!.run(laneFlash0)
//                    let newF8LanePos: Void = f8OtherAllVehicles[i].childNode(withName: "leftInd\(i)")!.run(lFlash0)
//                    
//                }               //end KL Track
//                
//            } else {    //.startIndicator was set BUT .indicator WASN'T O/T or endO/T!
//                if kLTrack {    //KL Track
//                    if sKLAllVehicles[i].lane > 0.5 {
//                        sKLAllVehicles[i].lane = 1      //Ensure lane only = 1 or 0 when here!
//                    } else {    //lane <= 0.5
//                        sKLAllVehicles[i].lane = 0      //Ensure lane only = 1 or 0 when here!
//                    }   //end lane check
//                    rtnVeh[i].lane = sKLAllVehicles[i].lane      //Ensure lane only = 1 or 0 when here!
//                    sKLAllVehicles[i].indicator = .off  //Ensure 'goLeft' can run!
//                    rtnVeh[i].indicator = .off
//                } else {    //Not KL Track
//                    if sOtherAllVehicles[i].lane > 0.5 {
//                        sOtherAllVehicles[i].lane = 1      //Ensure lane only = 1 or 0 when here!
//                    } else {    //lane <= 0.5
//                        sOtherAllVehicles[i].lane = 0      //Ensure lane only = 1 or 0 when here!
//                    }           //end lane test
//                    rtnVeh[i].lane = sOtherAllVehicles[i].lane      //Ensure lane only = 1 or 0 when here!
//                    sOtherAllVehicles[i].indicator = .off  //Ensure 'goLeft' can run!
//                    rtnVeh[i].indicator = .off
//                }       //end KL Track
//            }           //end .startIndicator test
//        }               //end of about to overtake OR back to left lane
//    }           //End startFlashing - End of .startIndicator was true routine
//    //skips above & direct to here when .startIndicator not true
//    return rtnVeh
//}   //end of changeLanes function
