//  5 May 2024

//***************  1. findObstacles + updateSpeeds  ***************
//Other Track (Track 2)  = gameStage bit 0 = 1
allAtSpeed2 = true

var ret2urn: [NodeData] = t2Vehicle        //Used for both Track 2
var result2 = await nodeData.findObstacles(tVehicle: &t2Vehicle)
ret2urn = result2

updateSpeeds(retVeh: result2, allVeh: &sOtherAllVehicles)      //Update vehicle speeds

//***************  2. Restore Array  ***************
//NOT in Vehicle order! Arranged by Y Position!
//Sort back into Vehicle No order. Note [0] is missing
ret2urn.sort {
    $0.name.localizedStandardCompare($1.name) == .orderedAscending
}                               //'localizedStandardCompare' ensures 21 sorted AFTER 3
ret2urn.insert(t2xVehicle[0], at: 0)   //Copy All Vehicles into position [0].
ret2urn[0].name = "All Vehicles"

//***************  2a. KL Overtake  ***************
//NOTE: Other Track doesn't Keep Left!
var re2turnV: [NodeData] = await nodeData.goLeft(teeVeh: &ret2urn)
//                            var re2turnV: [NodeData] = ret2urn
//Toggle above 2 instructions to run or disable goLeft function! (currently only KL Track)

//***************  3. findF8Pos + updateF8Spots  ***************
var f8T2Spots = await nodeData.findF8Pos(t1Veh: &re2turnV)

updateF8TSpots(t1Vehicle: f8T2Spots, kLTrack: false)

//***************  4. updateLabel  ***************
//Once every 500-600ms sufficient for display calcs below
//                            var rtnT2Veh = await nodeData.calcAvgData(t1Veh: &f8T2Spots)
var rtnT2Veh = await nodeData.calcAvgData(t1xVeh: &re2turnV)

for i in 1..<rtnT2Veh.count {
    
