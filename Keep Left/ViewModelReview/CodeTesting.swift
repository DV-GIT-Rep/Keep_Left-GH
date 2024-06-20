
import Foundation
import SpriteKit
import SwiftUI

//
///// Creates a new value of preferredSpeed, sets it over a random period, holds it over a new random period, and then repeats with new random values indefinitely
///// - Parameters:
/////   - vehicle: To be setup - Straight Keep Left Track ONLY! Others are copied
/////   - vehNo: Number of this vehicle
//func setVehicleSpeed(vehicle: Vehicle) {
////    func setVehicleSpeed(vehicle: Vehicle, vehNo: Int) {
//    let vehNo = Int.extractNum(from: vehicle.name!)!                //vehicle = sKLAllVehicles[vehNo]
//
//    let setVariables = SKAction.customAction(withDuration: 0) {
//        (node, elapsedTime) in
//        
////        //Create variables for life of 'setVariables'
////        var strtSpd: CGFloat = 0            //Capture preferredSpeed @ start of actions
////        var adjustTime: CGFloat = 0         //Defines time preferredSpeed takes to get from strtSpd to targetSpd
////        var targetSpd: CGFloat = 110          //Value of preferredSpeed @ end of adjustTime period
////        var fixedTime: CGFloat = 2          //Time that preferredSpeed remains unchanged after being altered
//////        var intTime: CGFloat
//        
//        if let node = node as? Vehicle {    //Without this, node is treated just as 'SKNode'
//            //1ST DEFINE INPUTS TO RANDOM EXPRESSIONS BELOW SO THEY DON'T CHANGE DURING ACTIONS!
//            print("node: \(node)")
//            //NOTE THAT ACCELERATION & DECELERATION RATES ARE LIMITED IN m/s2 REGARDLESS OF THE BELOW!
//            //adjustTime = time that preferredSpeed changes here in seconds (setSpeed action)
//            node.adjustTime = randomValue(distribution: node.varTime, min: 1, max: 180) //1 through 180 secs
//            node.adjustTime = 0.1
//            //strtSpd = preferredSpeed @ start of adjustTime period
//            node.strtSpd = node.preferredSpeed  //Set to preferredSpeed @ start
//            //targetSpd = preferredSpeed @ end of adjustTime period
//            node.targetSpd = randomValue(distribution: node.spdPref, min: (node.lowRange * CGFloat(spdLimit)), max: (node.topRange * CGFloat(spdLimit)))
//            //preferredSpeed remains fixed for 'fixTime' seconds
//            node.fixedTime = randomValue(distribution: node.holdTime, min: 1, max: 180) //1 through 180 secs
//            node.fixedTime = 10
//            
//        }       //end 'if let node' at 'setVariables' level
//    }       //end setVariables action
//
//
//            //Updates preferredSpeed with next calculated value over period 'adjustTime'
//            let setSpeed = SKAction.customAction(withDuration: self.adjustTime) {
//                (node, elapsedTime) in
//                if let node = node as? Vehicle {
//                    let intTime = elapsedTime / node.adjustTime
//                    node.preferredSpeed = (node.targetSpd - node.strtSpd) * intTime + node.strtSpd
//                    sOtherAllVehicles[vehNo].preferredSpeed = node.preferredSpeed
//                }
//            }       //end setSpeed action
//            
////            SKAction.run {
////                <#code#>
////            }
////            SKAction.customAction(withDuration: 5) {
////                (node, elapsedTime) in 
////                <#T##(SKNode, CGFloat) -> Void#>
////            }
////            
//            
//            //Delay of 'fixedTime' where preferredSpeed remains unchanged
//            let delay = SKAction.wait(forDuration: node.fixedTime)       //Fixed time delay where preferredSpeed DOESN'T change
//            
//            //Sequence of SKActions
//            let spdSequence = SKAction.sequence([setVariables, setSpeed, delay])  //Alter preferredSpeed slowly followed by 'delay'
//            
//            node.run(spdSequence)                               //Run the action above (spdSequence)!
//            
//let spdActions = SKAction.repeatForever(setVariables)           //Repeat actions above indefinitely when run
//
//////Set new preferred speed for this vehicle!
////sKLAllVehicles[vehNo].run(spdActions, withKey: "spdAction\(vehNo)") //Run then repeat actions above indefinitely
////                                                                    //& create action names
////                                                                    // OR...
////Set new preferred speed for this vehicle!
////    sKLAllVehicles[vehNo].run(spdActions) {                     //Run then repeat actions above indefinitely
////        print("spdAction\(vehNo) ended Prematurely!!!")         //Print error msg if actions ever end!
////    }
//    sKLAllVehicles[vehNo].run(spdActions)
////Line above replaces the one below! (moved ")" forward & deleted ", completion:") - sb identical operation!
////    sKLAllVehicles[vehNo].run(spdActions, completion: {print("spdAction\(vehNo) ended Prematurely!!!")})
//
//}           //end of setVehicleSpeed function
