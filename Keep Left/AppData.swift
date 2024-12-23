//  AppData.swift
//  Keep Left
//
//  Created by Bill Drayton on 19/1/22.

import Foundation
import SwiftUI
import SpriteKit

///Keep Left - true or false?
var keepLeft = true         //Determines which side of the road vehicles travel on

///Metric - true or false? True = km, false = miles
var Metric = true           //Determines whether km or miles are used

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
var TEMPAA = false
var TEMPBB = false
//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

//Metric string constants
///Returns "km" or "Miles"
var Km = Metric ? "km" : "Miles"
///Returns "km" or "miles"
var km = Metric ? "km" : "miles"
///Returns "kph" or "mph"
var kph = Metric ? "kph" : "mph"

//Keep Left string constants
///Returns "Left" or "Right"
var Left = keepLeft ? "Left" : "Right"

///Returns CGFloat of sin(45deg) as constant. Saves calculation time.
let sin45Deg = sin(CGFloat(45).degrees())   //Replace calculation by constant

///Returns CGFloat of cos(45deg) as constant. Saves calculation time.
let cos45Deg = cos(CGFloat(45).degrees())   //Replace calculation by constant

///Returns a value of (1.5 times pi) as a CGFloat
let piBy1p5 = CGFloat(1.5) * .pi

///Returns a value of (2 times pi) as a CGFloat
let piBy2 = CGFloat(2) * .pi

///Returns a value of (3 times pi) as a CGFloat
let piBy3 = CGFloat(3) * .pi

///Returns the x or y distance from origin for a 45' line of length F8Radius (sin45 = cos45)
let halfDiagonalXY: CGFloat = sin45Deg * F8Radius //x/y length in metres

///Returns a multiplier. Multiply y1Mx by a distance around the circumference to get the angle change
let y1Mx: CGFloat = 270 / (1.5 * .pi * F8Radius)

///Returns y coordinate change between (0,0) and the fig 8 circle centre in metres
let f8CircleCentre: CGFloat = F8Radius / cos45Deg

var carXWidth: CGFloat = .zero
var carXLength: CGFloat = .zero
var carXRatio: CGFloat = .zero

//Number of each vehicle type for which there are images available (obsolete!)
var numCar: Int = 6
var numTruck: Int = 2
var numBus: Int = 2

//let vehicles = ["C1", "C2", "C3", "C4", "C5", "C6"] //Obsolete!

//The following arrays represent all vehicles for which there are images. Names match filenames!
let cars = ["C1", "C2", "C3", "C4", "C5", "C6"]
let trucks = ["T1", "T2", "T3", "T4"]
let buses = ["B1", "B2", "B3"]
//let cars = ["No1", "No2", "No3", "No4", "No5", "No6"]
//let trucks = ["No7", "No8", "No9", "NoA"]
//let buses = ["NoB", "NoC", "NoD"]
let vehImage = "VehicleImage/"

var maxCars = cars.count
var maxTrucks = trucks.count
var maxBuses = buses.count

//Nxt 2 are compile options!!!
let NumberedVehicles = false    //Display no's instead of veh's when = true. MAX 13 NO'S - see Assets!

var printSpd = 0    //Prints Speed details if = 1. Set to 0 to disable!
var WHICH = 1       //TEMP for printing !!! MUST set if printSpd != 0 !
var PATH = ""       //Only used when printSpd != 0 !
var CS:CGFloat = 0
var FS:CGFloat = 0
var GS:CGFloat = 0
var TEST: Int = 0

///This variable is configured in Settings and defines how many vehicles will be driving around each track
/// - Legal values: 1 - 100
var numVehicles = 32        //28 - NOTE: NEVER set to 0! Illegal value.
let minGap: CGFloat = 3.0   //minGap + 0.1secs = min permissible gap to change lanes between vehicles in metres.
                            // -see 'myMinGap' for min gap between vehicles in same lane in seconds!
var tmpTst: CGFloat = 1

enum Zone: CaseIterable {               //Define Zone with different speed limits, L/R Hand Drive etc
    case NSW, Vic, Qld, SA, Tas, WA, NT //May make a subset of AUS
    case Cal, Nev, NY                   //May make a subset of US
}

//enum SpdLimit: CaseIterable {         //CAN'T create an enum with Ints!
//    case 40, 50, 60, 70, 80, 90, 100, 110, 120, 130
//}
let spdLimits = [40, 50, 60, 70, 80, 90, 100, 110, 120, 130]    //Available speed limits (120 & 130 NT ONLY!)
let spdLimit = CGFloat(spdLimits[6]) + 0.5       //Set Speed Limit = 100 kph for now (won't get there without +0.5)

var sKLAllVehicles: [Vehicle] = []      //Array of vehicles on Keep Left Straight Track
var sOtherAllVehicles: [Vehicle] = []   //Array of vehicles on Other Straight Track
var f8KLAllVehicles: [F8Vehicle] = []     //Array of vehicles on Keep Left Figure 8 Track
var f8OtherAllVehicles: [F8Vehicle] = []  //Array of vehicles on Other Figure 8 Track

let backgroundCategory: UInt32 = 0b0001     //Flags used for physicsBody detection
let carCategory: UInt32 = 0b0010
let busCategory: UInt32 = 0b0100
let truckCategory: UInt32 = 0b1000
let vehicleCategory: UInt32 = carCategory | busCategory | truckCategory

var flashOffFlag = false        //Used to flash "Vehicle x" where x = vehicle no being displayed.

//Vehicle Stats = Inner Dictionary =
//  Name, Actual Speed, Intended Speed, Speed Limited, Algorithm
//Outer Dictionary Array:
//  Element 0 = Track Stats (avg, max, min etc)
//  Element 1-maxVehicles = Vehicle stats for that track (avg, max, min etc)
//var vehicleStats = ["Node": SKSpriteNode, "Name": String, "Actual Speed": CGFloat, "Intended Speed": CGFloat, "Speed Limited": Bool, "Algorithm": Int]()
var t1Stats = ["Name": [" "], "Actual Speed": [0.0], "Intended Speed": [0.0], "Speed Limited": [false], "Algorithm": [1]]
var t2Stats: [String: [Any]] = ["Name": [" "], "Actual Speed": [0.0], "Intended Speed": [0.0], "Speed Limited": [false], "Algorithm": [1]]
//let statTitles = ["Name", "Actual Speed", "Intended Speed", "Speed Limited", "Algorithm"]

let fBuffVisible = true
let rBuffVisible = true

//iconColour refers to colour of the back (Select) button. Other icons stored with this colour!
let iconColour: UIColor = UIColor(red: 0.05, green: 0.2, blue: 0.05, alpha: 1)

//Later delete following 2 lines and StraightTrackScene.swift
var km1: CGFloat = 1
var sTrackPortrait = true

//m400 = no. of points that equal 400 metres (display length) on the Figure 8 Track Scene
//fig8TrackPortrait = true then the Figure 8 Track Scene is in portrait mode else landscape
var m400: CGFloat = 1
var fig8TrackPortrait = true

//MARK: - Road Dimensions (metres) used for all views
let roadLength: CGFloat = 1000.0   //Road length. (USE sTrackLength INSTEAD???)
//let roadLength: CGFloat = 1008.0   //Road length in metres: FUDGED TO FIT FIG 8 IMAGE !!! TEMP !!!
let laneWidth: CGFloat = 3.5        //Width of single lane measured between lines
let lineWidth: CGFloat = 0.2        //Sets width of centre line markings in metres XXX
let lineLength: CGFloat = 3         //Length of each centre line
let lineGap: CGFloat = 9            //Gap between consecutive lines
let shoulderLineWidth:CGFloat = 0.2 //Sets width of outer edge lines on road
let shoulderWidth: CGFloat = 0.25    //Sets width of bitumen outside of shoulder line markings
let roadWidth = (laneWidth * 2) + lineWidth + (shoulderLineWidth * 2) + (shoulderWidth * 2)
let linePeriod: CGFloat = (lineLength + lineGap)

let numFlash: Int = 6           //Sets no of flashes during a Lane Change
let halfFlash: CGFloat = 0.3        //On/Off time for indicators during Lane Change
let laneChangeTime: CGFloat = CGFloat(numFlash) * halfFlash * 1.8
                                    //Time each vehicle takes to change lanes
///Average speed (kph) required to change lanes in 'laneChangeTime'
/// - Distance between lanes = (laneWidth + lineWidth)
/// - xLaneVelocity used to calculate vehicle rotation during a Lane Change
/// - - Angle = atan(xLaneVelocity / velocity)
let xLaneVelocity: CGFloat = ((laneWidth + lineWidth) * 3.6) / laneChangeTime
let rotFudgeFactor: CGFloat = 0.2     //Amplify rotation angle when changing lanes
                                    //NOTE: Max level at half way
//May reduce further for long vehicles (0.15?) & increase for shorter vehicles (0.3?)

//MARK: - Colours of 1st Fig 8 image:
//                  R       G       B
//          Grey    168     168     168
//          Green   142     167     141
//          Bitumen 104     104     104
//          
let asphalt: SKColor = SKColor(red: 42/256, green: 41/256, blue: 34/256, alpha: 1)      //Darker as first proposed
//let asphalt: SKColor = SKColor(red: 104/256, green: 104/256, blue: 104/256, alpha: 1)   //Lighter as per Fig 8 Track

let numLines: CGFloat = trunc(roadLength / linePeriod)  //Number of centre lines for road length

let degreesToRadians = CGFloat.pi / 180
let radiansToDegrees = 180 / CGFloat.pi

//MARK: - These values pass info between SwiftUI and SpriteViews
enum sceneName {
case figure8, straight, game
}
var whichScene: sceneName = .figure8    //Value determines which scene is displayed
var F8YZero: CGFloat = 0.0
enum runCondition {
    case stop, run
}
enum runCondSwitch {
    case switched, stable
}

var runTimer: CGFloat = 0.0         //Timer increments once/sec (+0.5 every 500ms) when runStop != .stop
let runTimerDelay: CGFloat = 15      //Secs delay before minSpeed is calc'd. Accel of 4.5m/s2 to 130kph takes ~8secs
var enableMinSpeed: Bool = false    //Minimum speed is only calculated after this flag is set
///runStop has 2 possible values, .stop & .run
var runStop: runCondition = .run
var runSwitched: runCondSwitch = .switched  //Indicates run/stop condition just changed
var ignoreSpd: Bool = true          //Set when veh's stopped. Rst when started plus 10 secs (runTimerDelay)
var kISpd2: Bool = true             //Used with ignoreSpd for KL Track avg, min & max spd calculations
var kISpd3: Bool = true             //Used with ignoreSpd for KL Track avg, min & max spd calculations
var oISpd2: Bool = true             //Used with ignoreSpd for Other Track avg, min & max spd calculations
var oISpd3: Bool = true             //Used with ignoreSpd for Other Track avg, min & max spd calculations


///All but 8 LSBs cleared once all vehicles created. Value then dictates which code runs during 'update'
/// - 0xFF = Max value
///   - Bit  7   = 1 UNTIL vehicles created then set to 0!
///   - Bits 6-4 = Not used (yet).
///   - Bits 3-2 = Clr'd when vehicles created. Not used (yet).
///   - Bit  1   = Set during KLTask then Rst. Flags operation in progress
///   - Bit  0   = Set during OtherTask then Rst. Flags operation in progress
var gameStage: Int = 0xFF   //0xFF = Max value
                            //Bit  7   = 1 UNTIL vehicles created then set to 0!
                            //Bits 6-4 = Not used (yet).
                            //Bits 3-2 = Clr'd when vehicles created. Not used (yet).
                            //Bit  1   = Set during KLTask - clr'd at end.
                            //Bit  0   = Set during OtherTask - clr'd at end.

////Set ONLY to 01 or 11! Track 1 & 2 alternate based on value of bit 0!
//let noOfCycles = 0x00       //Calc speeds & f8Pos once every 'noOfCycles' 16.67ms (60Hz) periods.
//                            //0 - No Delay                  60fps   (smoothest)
//                            //1 - Run every 2nd 60ms cycle  30fps   (good)
//                            //2 - Run every 3rd 60ms cycle  20fps   (a little jumpy)
//                            //3 - Run every 4th 60ms cycle  15fps
//                            //NOTE: Larger no. here quickens speed change in vehicles! Compensates
//                            //      for fact that routine runs less often! (also set by this constant)

//MARK: - These values are for the straight line auto track
//var sMetre1: CGFloat = 0.0       //Multiply metres by this constant to get display points
//var sSceneWidth: CGFloat = 0.0  //Straight Track Scene Width in Points
//var sSceneHeight: CGFloat = 0.0 //Straight Track Scene Height in Points
//var portrait = true
//let sTrackWidth: CGFloat = 760.0 //Width of straight track scene in metres
let sTrackWidth: CGFloat = 120.0 //Width of straight track scene in metres. 750m ~max value on 12.9" iPad.
//let sTrackWidth: CGFloat = 600.0 //Width of straight track scene in metres. 750m ~max value on 12.9" iPad.
let sTrackLength: CGFloat = 1008.0 //Length of straight track scene in metres: FUDGED TO FIT FIG 8 IMAGE !!! TEMP !!!
//let sTrackLength: CGFloat = 1000.0 //Length of straight track scene in metres
let centreStrip: CGFloat = 4    //Width of centre strip in metres

var sBackgroundColour: UIColor = backgroundColour

//MARK: - These values are for the figure 8 auto track
var f8Metre1: CGFloat = 1.0         //Multiply metres by this constant to get display points
var f8SceneWidth: CGFloat = 0.0     //Figure 8 Track Scene Width in Points
var f8SceneHeight: CGFloat = 0.0    //Figure 8 Track Scene Height in Points
var f8ScreenHeight: CGFloat = 400.0    //Figure 8 track screen height (longest axis) in metres
let f8ScreenWidth: CGFloat = 200.0      //Figure 8 track screen width (shortest axis) in metres
///Radius of either end of Figure 8 Track along centre strip of green divider
var F8Radius: CGFloat = sTrackLength / (4 + piBy3)       //Radius of centre of figure 8 curves
//var F8Radius: CGFloat = 75.0       //Radius of centre of figure 8 curves (see above: ~ 74.489m)
let f8CentreStrip: CGFloat = 9.5    //Width of centre strip in metres

    //CloseLane = distance from centre of median strip to centre of the nearest lane
let CloseLane: CGFloat = (f8CentreStrip / 2) + shoulderWidth + shoulderLineWidth + (laneWidth / 2)
    //FarLane = distance from centre of median strip to centre of the farthest lane
let FarLane: CGFloat = CloseLane + (laneWidth / 2) + lineWidth + (laneWidth / 2)

var f8ScreenRatio: CGFloat = 0  //If height of screen > 2 x width then scale metres from width else use height

var f8BackgroundColour: UIColor = UIColor(red: 168/255, green: 168/255, blue: 168/255, alpha: 1)

let f8ImageWidth: CGFloat = 2406
let f8ImageHeight: CGFloat = 4096
let f8ImageSize: CGSize = CGSize(width: f8ImageWidth, height: f8ImageHeight)
let f8ImageAspect: CGFloat = f8ImageHeight / f8ImageWidth

let bridgeRailWidth: CGFloat = 0.35
let bridgeWidth: CGFloat = (2 * roadWidth) + f8CentreStrip + (2 * bridgeRailWidth)

var f8DisplayDat: Int = 0 {
    didSet {            //Code runs whenever value of f8DisplayDat changes
//        print("Change Fig 8 Vehicle Display")   //Load display here: 0 = "All Vehicles", 1 = "Vehicle 1", 2 = "Vehicle 2" etc
    }
}

var oneVehicleDisplayTime: CGFloat = 60    //Labels will revert to 'All Vehicles' after this many seconds

let fudgeFactor: CGFloat = 0     //TEMPORARY!!!  Don't use!
//let fudgeFactor: CGFloat = 0.75     //TEMPORARY!!!  Value is added to radius of fig 8 to offset sideways vehicle movement due to lag
                                    //              Note: will push stationary & low speed vehicles further out!

//MARK: - These values are for the game track (one direction only - Vehicle_1 is under User Control!)
var gMetre1: CGFloat = 0.0         //Multiply metres by this constant to get display points
var gSceneWidth: CGFloat = 0.0  //Game Track Scene Width in Points
var gSceneHeight: CGFloat = 0.0 //Game Track Scene Height in Points

//let backgroundColour: UIColor = UIColor(red: 0.19, green: 0.38, blue: 0.16, alpha: 1)   //Green
let backgroundColour: UIColor = UIColor(red: 48.45/255, green: 96.9/255, blue: 40.8/255, alpha: 1)   //Green
//let backgroundColour: UIColor = UIColor(white: 1, alpha: 1)   //White
//let backgroundColour: UIColor = UIColor(red: 168/255, green: 168/255, blue: 168/255, alpha: 1)   //Light Grey
var gBackgroundColour: UIColor = backgroundColour

//MARK: - These values are stats for 'AllVehicles'
var klDistance0: CGFloat = 0
var klDistanceMax0: CGFloat = 0
var klDistanceMin0: CGFloat = 0
var oDistance0: CGFloat = 0
var oDistanceMax0: CGFloat = 0
var oDistanceMin0: CGFloat = 0
var klSpeedAvg0: CGFloat = 0
var klSpeedMax0: CGFloat = 0
var klSpeedMin0: CGFloat = 99999999
var oSpeedAvg0: CGFloat = 0
var oSpeedMax0: CGFloat = 0
var oSpeedMin0: CGFloat = 99999999

extension CGFloat {
    ///Formats number as string with maximum of 5 decimal places
    var dp5: String {
        return String(format: "%.5f", self)
    }
    ///Formats number as string with maximum of 4 decimal places
    var dp4: String {
        return String(format: "%.4f", self)
    }
    ///Formats number as string with maximum of 3 decimal places
    var dp3: String {
        return String(format: "%.3f", self)
    }
    ///Formats number as string with maximum of 2 decimal places
    var dp2: String {
        return String(format: "%.2f", self)
    }
    ///Formats number as string with maximum of 1 decimal place
    var dp1: String {
        return String(format: "%.1f", self)
    }
    ///Formats number as string with maximum of 0 decimal places
    var dp0: String {
        return String(format: "%.0f", self)
    }
}

extension CGFloat {
    ///Max 2 dp's to 10,000, 1 dp to 1,000,000 then 0 dp's. Adds thousands separater.
    var varDP: String {
        var val = self
        var dp = 0
        var result: String = ""
        
        if self < 10000 {
            dp = 2  //return String(format: "%.2f", self)
        } else if self < 1000000 {
            dp = 1  //return String(format: "%.1f", self)
        } else {
            dp = 0  //return String(format: "%.0f", self)
        }
        
        let formatter = NumberFormatter()
        formatter.locale = Locale.current // Change this to another locale if you want to force a specific locale, otherwise this is redundant as the current locale is the default already
        formatter.maximumFractionDigits = dp
        formatter.numberStyle = .decimal
        result = formatter.string(from: val as NSNumber)  ?? " "
        return result
    }
}

extension Int {
    ///Extract number from string: if let <var> = Int.extractNum(from: <String>) { use here }
    static func extractNum(from string: String) -> Int? {
        return Int(string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
        //Cld probably hv used Int(String(string.dropFirst(x))) //where x = num of digits to remove
    }
}

extension String {
    static func minSec(from num: CGFloat) -> String {
        return String("\(Int(num / 60))m\(String(format: "%02d", Int(num.truncatingRemainder(dividingBy: 60))))")
    }
}

//extension CGFloat {
//    static func minSec(_: CGFloat) -> String? {
//        return String("\(Int(self) / 60)m\(String(format: "%2.0f", self.truncatingRemainder(dividingBy: 60)))")
//    }
//}

var randNo: CGFloat = 120
var randUnitNo: Int = 1

var allAtSpeed1: Bool = false
var allAtSpeed2: Bool = false

enum Indicator {
    case off                //Vehicle in left or right lane
    case overtake           //Vehicle changing to overtaking (right) lane
    case endOvertake       //Vehicle returning to normal (left) lane
}

var printOvertake = 0       //0 = Don't print. 1 = Print ea overtake & return. 2 = Show lane value throughout
var whichOT = 1             //Defines which unit no shown when printOvertake = 2
