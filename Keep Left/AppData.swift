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

let gapVal: CGFloat = 3     //Time gap in seconds to vehicle in front

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

///Returns the x or y distance from origin for a 45' line of length f8Radius (sin45 = cos45)
let halfDiagonalXY: CGFloat = sin45Deg * f8Radius //x/y length in metres

///Returns a multiplier. Multiply y1Mx by a distance around the circumference to get the angle change
let y1Mx: CGFloat = 270 / (1.5 * .pi * f8Radius)

///Returns y coordinate change between (0,0) and the fig 8 circle centre in metres
let f8CircleCentre: CGFloat = f8Radius / cos45Deg

///All but 8 LSBs cleared once all vehicles created. Value then dictates which code runs during 'update'
var gameStage: Int = 1024   //1024 = 100 0000 0000 H

var carXWidth: CGFloat = .zero
var carXLength: CGFloat = .zero
var carXRatio: CGFloat = .zero

//Number of each vehicle type for which there are images available (obsolete!)
var numCar: Int = 6
var numTruck: Int = 2
var numBus: Int = 2

let vehicles = ["C1", "C2", "C3", "C4", "C5", "C6"] //Obsolete!

//The following arrays represent all vehicles for which there are images. Names match filenames!
let cars = ["C1", "C2", "C3", "C4", "C5", "C6"]
let trucks = ["T1", "T2", "T3"]
let buses = ["B1", "B2", "B3"]
let vehImage = "VehicleImage/"

var maxCars = cars.count
var maxTrucks = trucks.count
var maxBuses = buses.count

//This variable is defined in Settings and defines how many vehicles will be driving around track
var numVehicles = 28 //28

var sKLAllVehicles: [Vehicle] = []      //Array of vehicles on Keep Left Straight Track
var sOtherAllVehicles: [Vehicle] = []   //Array of vehicles on Other Straight Track
var f8KLAllVehicles: [F8Vehicle] = []     //Array of vehicles on Keep Left Figure 8 Track
var f8OtherAllVehicles: [F8Vehicle] = []  //Array of vehicles on Other Figure 8 Track

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
let roadLength: CGFloat = 1000.0   //Road length
let laneWidth: CGFloat = 3.5        //Width of single lane measured between lines
let lineWidth: CGFloat = 0.2        //Sets width of centre line markings in metres XXX
let lineLength: CGFloat = 3         //Length of each centre line
let lineGap: CGFloat = 9            //Gap between consecutive lines
let shoulderLineWidth:CGFloat = 0.2 //Sets width of outer edge lines on road
let shoulderWidth: CGFloat = 0.25    //Sets width of bitumen outside of shoulder line markings
let roadWidth = (laneWidth * 2) + lineWidth + (shoulderLineWidth * 2) + (shoulderWidth * 2)
let linePeriod: CGFloat = (lineLength + lineGap)

let asphalt: SKColor = SKColor(red: 42/256, green: 41/256, blue: 34/256, alpha: 1)

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
var runTimer: CGFloat = 0.5         //Timer increments once/sec (+0.5 every 500ms) when runStop != .stop
let runTimerDelay: CGFloat = 12     //Seconds delay before speed is acknowledged
var enableMinSpeed: Bool = false
var runStop: runCondition = .stop

//MARK: - These values are for the straight line auto track
//var sMetre1: CGFloat = 0.0       //Multiply metres by this constant to get display points
//var sSceneWidth: CGFloat = 0.0  //Straight Track Scene Width in Points
//var sSceneHeight: CGFloat = 0.0 //Straight Track Scene Height in Points
//var portrait = true
let sTrackWidth: CGFloat = 120.0 //Width of straight track scene in metres
let sTrackLength: CGFloat = 1000.0 //Length of straight track scene in metres
let centreStrip: CGFloat = 4    //Width of centre strip in metres

var sBackgroundColour: UIColor = backgroundColour

//MARK: - These values are for the figure 8 auto track
var f8Metre1: CGFloat = 1.0         //Multiply metres by this constant to get display points
var f8SceneWidth: CGFloat = 0.0     //Figure 8 Track Scene Width in Points
var f8SceneHeight: CGFloat = 0.0    //Figure 8 Track Scene Height in Points
var f8ScreenHeight: CGFloat = 400.0    //Figure 8 track screen height (longest axis) in metres
let f8ScreenWidth: CGFloat = 200.0      //Figure 8 track screen width (shortest axis) in metres
var f8Radius: CGFloat = sTrackLength / (4 + piBy3)       //Radius of centre of figure 8 curves
//var f8Radius: CGFloat = 75.0       //Radius of centre of figure 8 curves (see above: ~ 74.489m)
let f8CentreStrip: CGFloat = 9.5    //Width of centre strip in metres

let closeLane: CGFloat = (f8CentreStrip / 2) + shoulderWidth + shoulderLineWidth + (laneWidth / 2)
let farLane: CGFloat = closeLane + (laneWidth / 2) + lineWidth + (laneWidth / 2)

var f8ScreenRatio: CGFloat = 0  //If height of screen > 2 x width then scale metres from width else use height

var f8BackgroundColour: UIColor = backgroundColour

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

let fudgeFactor: CGFloat = 0.75     //TEMPORARY!!!  Value is added to radius of fig 8 to offset sideways vehicle movement due to lag
                                    //              Note: will push stationary & low speed vehicles further out!

//MARK: - These values are for the game track (one direction only - Vehicle_1 is under User Control!)
var gMetre1: CGFloat = 0.0         //Multiply metres by this constant to get display points
var gSceneWidth: CGFloat = 0.0  //Game Track Scene Width in Points
var gSceneHeight: CGFloat = 0.0 //Game Track Scene Height in Points

let backgroundColour: UIColor = UIColor(red: 0.19, green: 0.38, blue: 0.16, alpha: 1)   //Green
var gBackgroundColour: UIColor = backgroundColour

extension CGFloat {
    ///Formats number as string with maximum of 2 decimal places
    var dp2: String {
        return String(format: "%.2f", self)
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
