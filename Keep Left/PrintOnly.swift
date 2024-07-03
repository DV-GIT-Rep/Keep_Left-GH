//  1 July 2024

////MARK: - goLeft decides whether to change lanes or not
//func goLeft(teeVeh: inout [NodeData]) async {
//    //teeVeh[index].mySetGap ~3 secs = min gap to vehicle in front
//    //These values used to test distance between this vehicle & the one behind in the other lane.
//    let oRearDecel: CGFloat = 5                     //m/s2 used to calc diff eg. (3 x 5) = 15 kph
//    var oRearMaxGap: CGFloat    //~ 3 secs
//    var oRearMinGap: CGFloat    //(3 secs / 6) = 0.5 secs = min gap for overtaking
//    var oRearGapRange: CGFloat
//    var maxORearSpdDiff: CGFloat   //eg. (3 x 5) = 15 kph
//    
//    var oRearSub: CGFloat               //Used to calc speed difference
//    var oRearOKGap: CGFloat             //Used to store min allowable oRearGap
//    
//    var oFrontSub: CGFloat               //Used to calc speed difference
//    var oFrontOKGap: CGFloat             //Used to store min allowable oRearGap
//    
//    var bigGap: CGFloat = 0             //bigGap = 110% of 3 sec gap. Calc'd for each vehicle during loop.
//    let minChangeLaneSpdL: CGFloat = 16 //Minimum speed where lane change permitted!
//    let minChangeLaneSpdR: CGFloat = 28 //Minimum speed where lane change permitted!
//    //NOTE: May have to reduce the above when 'numVehicles' becomes large!!!
//
//    for indx in teeVeh.indices {
//        if indx == 0 { continue }       //Skip loop for element[0] = All Vehicles
//        
//        if teeVeh[indx].indicator != .off { continue }  //Lane change already in progress
//        //NOTE: If inst's below omitted then each veh will O/T or return ONLY once!
//        //  (value of indicator changed by 0.002! - laneChange not EXACTLY 1.0 lanes)
//        if teeVeh[indx].lane > 0.5 {    //Ensure lane only = 1 or 0 when here!
//            teeVeh[indx].lane = 1
//        } else {
//            teeVeh[indx].lane = 0
//        }
//        oRearMaxGap = teeVeh[indx].mySetGap    //~ 3 secs
//        oRearMinGap = (oRearMaxGap / 6)    //(3 secs / 6) = 0.5 secs = min gap for overtaking
//        oRearGapRange = (oRearMaxGap - oRearMinGap)
//        maxORearSpdDiff = (oRearMaxGap * oRearDecel)   //eg. (3 x 5) = 15 kph
//
//        //****************  Test for permissible oRearGap \/   ****************
//        oRearSub = (teeVeh[indx].oRearSpd - teeVeh[indx].currentSpeed)  //Used to calc speed difference
//        if oRearSub < 0 {
//            oRearSub = 0
//        } else {
//            if oRearSub > maxORearSpdDiff {
//                oRearSub = maxORearSpdDiff
//            }
//        }
//        oRearOKGap = oRearMinGap + (oRearGapRange / maxORearSpdDiff * oRearSub) //returns min gap allowed = 0.5 - 3 secs
//        oRearOKGap = (teeVeh[indx].oRearSpd * oRearOKGap) / 3.6                 //converts to metres
//        if oRearOKGap < minGap { oRearOKGap = minGap }       //Limit minimum gap to 2.5m ( + 1m = 3.5m?) at low speeds
//        if teeVeh[indx].oRearGap <= oRearOKGap { continue } //oRearGap insufficient to change lanes. End.
//        //oRearGap OK - Test other factors.
//        //****************  Test for permissible oRearGap /\   ****************
//        
//        //****************  Test for permissible oFrontGap \/  ****************
//        //For now same constants used for front as for back. Name not changed as may later be changed.
//        oFrontSub = (teeVeh[indx].oFrontSpd - teeVeh[indx].currentSpeed)  //Used to calc speed difference
//        if oFrontSub < 0 {
//            oFrontSub = 0
//        } else {
//            if oFrontSub > maxORearSpdDiff {
//                oFrontSub = maxORearSpdDiff
//            }
//        }
//        oFrontOKGap = oRearMinGap + (oRearGapRange / maxORearSpdDiff * oFrontSub) //returns min gap allowed = 0.5 - 3 secs
//        oFrontOKGap = (teeVeh[indx].oFrontSpd * oFrontOKGap) / 3.6                 //converts to metres
//        if oFrontOKGap <= minGap { oFrontOKGap = minGap }       //Limit minimum gap to 2.5m ( + 1m = 3.5m?) at low speeds
//        if teeVeh[indx].otherGap <= oFrontOKGap { continue } //oFrontGap insufficient to change lanes. End.
//        //oRearGap OK - Test other factors.
//        //****************  Test for permissible oFrontGap /\  ****************
//        
//        bigGap = ((1.05 * teeVeh[indx].mySetGap) * teeVeh[indx].currentSpeed) / 3.6    //bigGap = 105% of 3 sec gap.
//        
//        if teeVeh[indx].lane == 0 {             //Preferred lane (Left)
//            //****************  Test for permissible gap/otherGap from lane 0 \/  ****************
//            if teeVeh[indx].currentSpeed < minChangeLaneSpdR { continue }     //Don't permit lane change when vehicle speed < 2.5? kph.
//            if teeVeh[indx].frontSpd >= teeVeh[indx].currentSpeed {
//                continue        //Stay in left lane
//            } else {            //Going faster than vehicle in front
//                if teeVeh[indx].gap > bigGap {
//                    continue    //gap > 110% 3 sec gap. Stay in left lane.
//                } else {
//                    if teeVeh[indx].gap >= teeVeh[indx].otherGap {
//                        continue    //LHS gap > otherGap. Stay in this lane.
//                    } else {
//                        if teeVeh[indx].otherGap <= minGap { continue }      //Limit minimum gap to 2.5m ( + 1m = 2m) at low speeds
//                        //                            print("to 1\t\(indx)\t\(teeVeh[indx].lane)")
//                        //                            teeVeh[indx].lane = 1       //Overtake (done elsewhere in SKAction)
//                        teeVeh[indx].indicator = .overtake              //Move to right (overtaking) lane
//                        //                            sKLAllVehicles[indx].indicator = .overtake      //Move to right (overtaking) lane
//                        teeVeh[indx].startIndicator = true  //Flag used to start lane change
//                        //                            print("to 1\t\(indx)\t\(teeVeh[indx].lane)")
//                        continue
//                    }
//                }
//            }
//            //May later compare frontSpd to oFrontSpd too!
//            //****************  Test for permissible gap/otherGap from lane 0 /\  ****************
//        }               //End in lane 0 checks
//        
//        if teeVeh[indx].lane == 1 {             //Overtaking lane (Right)
//            //****************  Test for permissible gap/otherGap from lane 1 \/  ****************
//            if teeVeh[indx].currentSpeed < minChangeLaneSpdL { continue }     //Don't permit lane change when vehicle speed < 2.5? kph.
//            if teeVeh[indx].otherGap > bigGap {
//                //                    teeVeh[indx].lane = 0       //Return to left lane
//                teeVeh[indx].indicator = .endOvertake               //Return to left lane
//                //                    sKLAllVehicles[indx].indicator = .endOvertake       //Return to left lane
//                teeVeh[indx].startIndicator = true      //Flag used to start lane change
//                //                    print("ta\t\(indx)\t\(teeVeh[indx].lane)\tenablSpd: \(enableMinSpeed)")
//                continue                    //End this vehicle
//            } else {
//                if teeVeh[indx].otherGap >= teeVeh[indx].gap {
//                    if teeVeh[indx].otherGap <= minGap { continue }      //Limit minimum gap to 2.5m ( + 1m = 2m) at low speeds
//                    //                        teeVeh[indx].lane = 0       //Return to left lane
//                    teeVeh[indx].indicator = .endOvertake              //Return to left lane
//                    //                        sKLAllVehicles[indx].indicator = .endOvertake       //Return to left lane
//                    teeVeh[indx].startIndicator = true      //Flag used to start lane change
//                    //                        print("tb 0\t\(indx)\t\(teeVeh[indx].lane)")
//                    //                        let tst = Vehicle.startOvertake(sKLAllVehicles[indx])
//                    continue
//                }
//            }
//            //****************  Test for permissible gap/otherGap from lane 1 /\  ****************
//        }               //End in lane 1 checks
//    }                   //End 'for' loop
//}                       //end of goLeft function
