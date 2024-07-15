//  12 July 2024
/*
//MARK: - goLeft decides whether to change lanes or not
func goLeft(teeVeh: inout [NodeData]) async {
    
    //Constants below dictate lane change of otherTrack vehicles. laneMode = 0-100
    // ...for KL Track laneMode = -1
    let div_ROnly: CGFloat = 6      //0 to div_ROnly           -> RLane Only
    let div_B: CGFloat = 11       //div_ROnly to div_B
    let div_C: CGFloat = 20   //div_B to div_C
    let div_All: CGFloat = 30       //div_C_RL5 to div_All
    let div_E: CGFloat = 84       //div_All to div_E       ->
    let div_F: CGFloat = 89       //div_E to div_F
    let div_LOnly: CGFloat = 94     //div_F to div_LOnly
                                    //> div_LOnly            -> LLane Only
    let div_Test = 0...20       //Use range??? (need to use ~= to compare)

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
    
    var bigGap: CGFloat = 0             //bigGap = 110% of 3 sec gap. Calc'd for each vehicle during loop.
    
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
            //****************  Test for permissible gap/otherGap from lane 0 \/  ****************
            if teeVeh[indx].currentSpeed < minChangeLaneSpdR { continue }     //Don't permit lane change when vehicle speed < 5-28 kph (subject to numVehicles).
            if teeVeh[indx].currentSpeed <= teeVeh[indx].frontSpd { continue } //Stay in left lane
            //Going faster than vehicle in front
            if teeVeh[indx].gap >= bigGap { continue } //gap > 105% 3 sec gap. Stay in left lane.
            if teeVeh[indx].gap >= teeVeh[indx].otherGap { continue } //LHS gap > otherGap. Stay in this lane.
// if teeVeh[indx].otherGap <= minGap { continue } //Limit minimum gap to 3.5m at low speeds. ALREADY DONE!
// print("to 1\t\(indx)\t\(teeVeh[indx].lane)")
// teeVeh[indx].lane = 1       //Overtake (done elsewhere in SKAction)
            teeVeh[indx].indicator = .overtake              //Move to right (overtaking) lane
// sKLAllVehicles[indx].indicator = .overtake      //Move to right (overtaking) lane
            teeVeh[indx].startIndicator = true  //Flag used to start lane change
// print("to 1\t\(indx)\t\(teeVeh[indx].lane)")
            continue
//May later compare frontSpd to oFrontSpd too!
            
            //****************  Test for permissible gap/otherGap from lane 0 /\  ****************
        }               //End in lane 0 checks
        
        if teeVeh[indx].lane == 1 {             //In Overtaking Lane (Right)
            //****************  Test for permissible gap/otherGap from lane 1 \/  ****************
            if teeVeh[indx].currentSpeed < minChangeLaneSpdL { continue }     //Don't permit lane change when vehicle speed < 5-16 kph (subject to numVehicles).
//                if teeVeh[indx].otherGap > teeVeh[indx].mySetGap {
            if teeVeh[indx].otherGap > bigGap {
                if teeVeh[indx].otherTrack == true { continue } //Stay in lane if otherTrack
                //                    teeVeh[indx].lane = 0       //Return to left lane
                teeVeh[indx].indicator = .endOvertake               //Return to left lane
                //                    sKLAllVehicles[indx].indicator = .endOvertake       //Return to left lane
                teeVeh[indx].startIndicator = true      //Flag used to start lane change
                //                    print("ta\t\(indx)\t\(teeVeh[indx].lane)\tenablSpd: \(enableMinSpeed)")
                continue                    //End this vehicle
            } else {    //otherGap <= mySetGap
                if teeVeh[indx].currentSpeed <= teeVeh[indx].oFrontSpd {
                    teeVeh[indx].indicator = .endOvertake               //Return to left lane
                    //                    sKLAllVehicles[indx].indicator = .endOvertake       //Return to left lane
                    teeVeh[indx].startIndicator = true      //Flag used to start lane change
                    continue
                }
                if teeVeh[indx].otherGap >= teeVeh[indx].gap {
//                    if true == true {   //Temporarily REPLACES INSTRUCTION ABOVE - FOR TESTING ONLY!!!
//if teeVeh[indx].otherGap <= minGap { continue }      //Limit minimum gap to 3.5m at low speeds ALREADY DONE!
                    //                        teeVeh[indx].lane = 0       //Return to left lane
                    teeVeh[indx].indicator = .endOvertake              //Return to left lane
                    //                        sKLAllVehicles[indx].indicator = .endOvertake       //Return to left lane
                    teeVeh[indx].startIndicator = true      //Flag used to start lane change
                    //                        print("tb 0\t\(indx)\t\(teeVeh[indx].lane)")
                    //                        let tst = Vehicle.startOvertake(sKLAllVehicles[indx])
                    continue
                }
            }
            //****************  Test for permissible gap/otherGap from lane 1 /\  ****************
        }               //End in lane 1 checks
        
    }                   //End 'for' loop
    //        return teeVeh
}                       //end of goLeft function


if teeVeh[indx].lane == 0 {             //In Preferred Lane (Left)
    var switchLanes: Bool = false
    //****************  Test for permissible gap/otherGap from lane 0 (Left Lane) \/  ****************
    //Only permit lane change above 5-28kph
    if teeVeh[indx].currentSpeed < minChangeLaneSpdR { continue }     //Don't permit lane change when vehicle speed < 5-28 kph (subject to numVehicles).
    
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
    if teeVeh[indx].otherTrack == false || do2 ~= teeVeh[indx].laneMode || do2_3 ~= teeVeh[indx].laneMode || do1_2 ~= teeVeh[indx].laneMode || doAll ~= teeVeh[indx].laneMode {
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
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

//Constants below dictate lane change of otherTrack vehicles. laneMode = 0-100
// ...for KL Track laneMode = -1
let goRightOnly = 0..<7.5   //Force vehicle into the Right Lane (need to use ~= to compare)
let do3 = 7.5..<15          //3. goLeft if Left Lane gap >= Right Lane gap
let do2 = 15..<22.5         //2. goLeft if Left Lane gap >= bigGap
let do1 = 22.5..<30
let doAll = 30..<70
let do2_3 = 70..<77.5
let do1_3 = 77.5..<85
let do1_2 = 85..<92.5
let goLeftOnly = 92.5...100 //Force vehicle into the Left Lane (need to use ~= to compare)



if teeVeh[indx].lane == 1 {             //In Overtaking Lane (Right)
    //****************  Test for permissible gap/otherGap from lane 1 \/  ****************
    //Only permit lane change above 5-16kph
    if teeVeh[indx].currentSpeed < minChangeLaneSpdL { continue }     //Don't permit lane change when vehicle speed < 5-16 kph (subject to numVehicles).
    
    //Force into Left Lane?
    if teeVeh[indx].otherTrack == true {            //OtherTrack
        if goLeftOnly ~= teeVeh[indx].laneMode {    //Go To Left Lane - No Reason
            teeVeh[indx].indicator = .endOvertake   //Move to Left Lane
            teeVeh[indx].startIndicator = true      //Flag used to start lane change
            continue                                //Lane change initiated - end
        }   //Normal - don't force Left Lane. End force lane check
    }       //end KL Track test
    
    //Condition 1. Slower than Left Lane FrontSpd?
    if teeVeh[indx].currentSpeed <= teeVeh[indx].oFrontSpd {    //Safe in Left Lane?
        if teeVeh[indx].otherTrack == false || do1 ~= teeVeh[indx].laneMode || do1_3 ~= teeVeh[indx].laneMode || do1_2 ~= teeVeh[indx].laneMode || doAll ~= teeVeh[indx].laneMode {
            teeVeh[indx].indicator = .endOvertake   //Move to Left Lane
            teeVeh[indx].startIndicator = true      //Flag used to start lane change
            continue                                //Lane change initiated - end
        }   //end - condition to change lanes not met!
    }       //Left Lane FrontSpd test ended - do next test

    //Condition 2. bigGap vs Left Lane Gap Test
    if teeVeh[indx].otherGap >= bigGap {    //Safe in Left Lane?
        if teeVeh[indx].otherTrack == false || do2 ~= teeVeh[indx].laneMode || do2_3 ~= teeVeh[indx].laneMode || do1_2 ~= teeVeh[indx].laneMode || doAll ~= teeVeh[indx].laneMode {
            teeVeh[indx].indicator = .endOvertake   //Move to Left Lane
            teeVeh[indx].startIndicator = true      //Flag used to start lane change
            continue                                //Lane change initiated - end
        }   //end - condition to change lanes not met!
    }       //Left Lane bigGap test ended - do next test

    //Condition 3. This (Right) Gap vs Left Lane Gap Test
    if teeVeh[indx].otherGap >= teeVeh[indx].gap {
        if teeVeh[indx].otherTrack == false || do3 ~= teeVeh[indx].laneMode || do2_3 ~= teeVeh[indx].laneMode || do1_3 ~= teeVeh[indx].laneMode || doAll ~= teeVeh[indx].laneMode {
            teeVeh[indx].indicator = .endOvertake   //Move to Left Lane
            teeVeh[indx].startIndicator = true      //Flag used to start lane change
            continue                                //Lane change initiated - end
        }   //end - condition to change lanes not met!
    }       //Left Lane bigGap test ended - do next test
    //****************  Test for permissible gap/otherGap from lane 1 /\  ****************
}               //End in lane 1 checks
      */*/*/*/*/*/*/*/*/*/*/*/*/*/*/
