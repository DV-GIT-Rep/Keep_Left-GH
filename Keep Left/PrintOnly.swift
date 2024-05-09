//  8 May 2024

//nextIndex = index
//
//while reerGap == 0 || oReerGap == 0 {
//    
//    nextIndex = nextIndex + 1       // same as nextIndex += 1
//    
//    if nextIndex >= numVehicles {
//        
//        nextIndex = 0       //Crossed 1km barrier. Continue search
//        past1km = true      //Flag indicates vehicle behind is beyond 1km boundary
//        
//    }           //end nextIndex 'if' statement
//    
//    let sameLane = (vehNode.lane - laneMax)...(vehNode.lane + laneMax)   //Scan for vehicles within 0.8 lanes either side
//    let sameLap = (vehNode.position.y - (vehNode.size.height / 2)) - (tVehicle[nextIndex].position.y + (tVehicle[nextIndex].size.height / 2)) //Vehicle in front on same side of 1km boundary
//    let lastLap = ((vehNode.position.y + sTrackLength) - (vehNode.size.height / 2)) - (tVehicle[nextIndex].position.y + (tVehicle[nextIndex].size.height / 2))    //Vehicle in front is over the 1km boundary!
//    
//    //NOTE: 0.5 lanewidth used for now due to in & out. May extend to 0.7 or so later!!!
//    if sameLane.contains(tVehicle[nextIndex].lane) {
//        //Both vehicles in same lane
//        if reerGap == 0 {
//            reerGap = (past1km == false) ? sameLap : lastLap
//            if reerGap <= 0 { reerGap = 0.1 } //Should NEVER happen! (due to self braking)
//            //                    vehNode.spacing = gap
//            tVehicle[index].rearUnit = tVehicle[nextIndex].name      //Save identity of rear unit (NOT Required?)
//            tVehicle[index].rearPos = tVehicle[nextIndex].position   //Save position of rear unit (NOT Required?)
//        }
//        if midLanes.contains(tVehicle[nextIndex].lane) {
//            //If this vehicle is mid-lane, set oRearGap = rearGap
//            if oReerGap == 0 {
//                oReerGap = (past1km == false) ? sameLap : lastLap
//                if oReerGap <= 0 { oReerGap = 0.1 } //Could prevent -ve values by using <= here
//                //                    vehNode.oRearGap = oReerGap
//                tVehicle[index].oRearSpd = tVehicle[nextIndex].currentSpeed   //Save speed of oRear unit
//            }
//        }
//    } else {
//        //The two vehicles are in different lanes
//        if oReerGap == 0 {
//            oReerGap = (past1km == false) ? sameLap : lastLap
//            if oReerGap <= 0 { oReerGap = 0.1 } //Could prevent -ve values by using <= here
//            //                    vehNode.oRearGap = oReerGap
//            tVehicle[index].oRearSpd = tVehicle[nextIndex].currentSpeed   //Save speed of oRear unit
//        }
//    }       //end lane check
//    
//}               //end 'While' loop
//
//tVehicle[index].rearGap = reerGap      // same as vehNode.rearGap
//tVehicle[index].oRearGap = oReerGap    // same as vehNode.oRearGap
//past1km = false
//reerGap = 0
//oReerGap = 0
//
//}               //end 1st 'For' loop
