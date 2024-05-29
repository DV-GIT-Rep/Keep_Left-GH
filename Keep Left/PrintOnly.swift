//  29 May 2024

//for (innDex, sKLNode) in t1xVeh.enumerated() {
//    if innDex == 0 {continue}       //Skip loop for element[0] = All Vehicles
//    
//    yPos = sKLNode.otherTrack ? (sTrackLength - t1xVeh[innDex].position.y) : t1xVeh[innDex].position.y
//    yStrtPos = sKLNode.otherTrack ? (sTrackLength - t1xVeh[innDex].startPos) : t1xVeh[innDex].startPos
//    
//    t1xVeh[innDex].distance = ((t1xVeh[innDex].position.y - yStrtPos) / sTrackLength + t1xVeh[innDex].laps) + t1xVeh[innDex].preDistance                //Distance travelled in km
//    
//    if firstThru == true {                  //Ensures initial reading > max possible speed
//        t1xVeh[innDex].speedMin = 900
//    }
//
////Only ever use currentSpd for temporary display of currentSpeed!
//    if t1xVeh[innDex].otherTrack == false { //Keep Left Track
//        if kISpd2 == true {         //xISpd2: true = 10s NOT up yet. Use currentSpeed
//            t1xVeh[innDex].speedAvg = CGFloat(Int(t1xVeh[innDex].currentSpeed))    //Average speed for vehicle
//        } else {                    //xISpd2: false
//            if kISpd3 == false {    //xISpd2: false, xISpd3: false = Normal Avg'd display
//                t1xVeh[innDex].speedAvg = CGFloat(Int(t1xVeh[innDex].distance * timeMx))    //Average speed for vehicle
//            } else {                //xISpd2: false, xISpd3: true = 10s just up, save preDistance etc
//                t1xVeh[innDex].speedAvg = CGFloat(Int(t1xVeh[innDex].currentSpeed))    //Average speed for vehicle
//                t1xVeh[innDex].preDistance = t1xVeh[innDex].distance
//                t1xVeh[innDex].startPos = t1xVeh[innDex].position.y
////                        t1xVeh[innDex].distance = 0
//                t1xVeh[innDex].laps = 0
//            }   //end xISpd3 test
//        }       //end xISpd2 test
//    } else {                                //Other Track
//        if oISpd2 == true {         //xISpd2: true = 10s NOT up yet. Use currentSpeed
//            t1xVeh[innDex].speedAvg = CGFloat(Int(t1xVeh[innDex].currentSpeed))    //Average speed for vehicle
//        } else {                    //xISpd2: false
//            if oISpd3 == false {    //xISpd2: false, xISpd3: false = Normal Avg'd display
//                t1xVeh[innDex].speedAvg = CGFloat(Int(t1xVeh[innDex].distance * timeMx))    //Average speed for vehicle
//            } else {                //xISpd2: false, xISpd3: true = 10s just up, save preDistance etc
//                t1xVeh[innDex].speedAvg = CGFloat(Int(t1xVeh[innDex].currentSpeed))    //Average speed for vehicle
//                t1xVeh[innDex].preDistance = t1xVeh[innDex].distance
//                t1xVeh[innDex].startPos = t1xVeh[innDex].position.y
////                        t1xVeh[innDex].distance = 0
//                t1xVeh[innDex].laps = 0
//            }   //end xISpd3 test
//        }       //end xISpd2 test
//    }                                       //end KL or Other Track test
//                
//    //+++++++++ Changed below to use currentSpeed instead of speedAvg. +++++++++
//    //+++++++++ CHANGED BACK! NEED MIN & MAX AVG SPEED FOR EACH VEHICLE! +++++++++
//    t1xVeh[innDex].speedMax = max(t1xVeh[innDex].speedMax, t1xVeh[innDex].speedAvg)  //Max avg speed for vehicle
//    if enableMinSpeed == true {         //Wait for ALL vehicles up to speed
//        t1xVeh[innDex].speedMin = min(t1xVeh[innDex].speedMin, t1xVeh[innDex].speedAvg)
//    }           //Min avg speed for vehicle. Ignores acceleration period.
//
//    t1xVeh[0].sumKL += t1xVeh[innDex].distance                   //All veh's: Total distance for all summed
//    t1xVeh[0].maxSumKL = max(t1xVeh[0].maxSumKL, t1xVeh[innDex].distance)  //Max distance by a single vehicle NOW
//    t1xVeh[0].minSumKL = min(t1xVeh[0].minSumKL, t1xVeh[innDex].distance)  //Min distance for a single vehicle NOW
//    
//}   //End of 'for' loop
