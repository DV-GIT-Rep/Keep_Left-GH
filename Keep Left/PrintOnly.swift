//  VehicleFunctions.swift
/*
import SpriteKit
import SwiftUI

var vBody: SKSpriteNode!

var sprite: SKSpriteNode!   //Temporary to stop XCode errors!

var dONTrEPEAT = false

//Track scene may be temporary. Functions below MUST be called from within a scene!
class StraightTrackScene: SKScene {
    
    //property and function for handling rotation
    let sContainer = SKNode()
    func set(sContainerZRotation:CGFloat) {
        sContainer.zRotation = sContainerZRotation
    }
    
    var straightScene = SceneModel()
    var toggleSpeed: Int = 2
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.addChild(sContainer) //add sContainer

        //MARK: - Create background colour (width: screenwidth, height: 1km). Define sMetre1 = multiplier for metres to points
//        calcScale()

        straightScene.calcStraightScene(size: view.bounds.size)
        portrait = straightScene.portrait
        sMetre1 = straightScene.metre1
        sSceneWidth = straightScene.width
        sSceneHeight = straightScene.height
        scene?.size.width = sSceneWidth
        scene?.size.height = sSceneHeight
        
        scene?.backgroundColor = UIColor(red: 0.19, green: 0.38, blue: 0.16, alpha: 1)
        scene?.scaleMode = .aspectFill
        physicsWorld.gravity = .zero
        
        //MARK: - Add 2x straight roads to StraightTrackScene
        addRoads()
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        let t1Vehicle = t1allVehicles
        let t2Vehicle = t2allVehicles

        //Loop through both arrays simultaneously. Move back 1km when they've travelled 1km!
        for (vehT1, vehT2) in zip(t1Vehicle, t2Vehicle) {
            if vehT1.position.y >= (1000 * sMetre1) {
                vehT1.position.y = (vehT1.position.y - (1000 * sMetre1))
            }
            if vehT2.position.y < 0 {
                vehT2.position.y = (vehT2.position.y + (1000 * sMetre1))
            }
        }   //End of 'for' loop
    }   //End of override update
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}   //Exit if not first touch!
        var kph: CGFloat = 110
        let multiplier: CGFloat = 1000 / 3600 * sMetre1  //Value by kph gives m/sec
        
        switch toggleSpeed {
        case 0:
        for i in 1...numVehicles {
            childNode(withName: "s1Vehicle_\(i)")?.physicsBody?.velocity.dy = 0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
            childNode(withName: "s2Vehicle_\(i)")?.physicsBody?.velocity.dy = -0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
        }
        case 1:
            for i in 1...numVehicles {
                childNode(withName: "s1Vehicle_\(i)")?.physicsBody?.velocity.dy = kph * multiplier   //1000 = metres in km. 3600 = secs in hour.
            }
        case 2:
            for i in 1...numVehicles {
                childNode(withName: "s1Vehicle_\(i)")?.physicsBody?.velocity.dy = kph * multiplier   //1000 = metres in km. 3600 = secs in hour.
                childNode(withName: "s2Vehicle_\(i)")?.physicsBody?.velocity.dy = -kph * multiplier   //1000 = metres in km. 3600 = secs in hour.
            }
        case 3:
            for i in 1...numVehicles {
                childNode(withName: "s1Vehicle_\(i)")?.physicsBody?.velocity.dy = 0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
            }
        default:
            for i in 1...numVehicles {
                childNode(withName: "s2Vehicle_\(i)")?.physicsBody?.velocity.dy = -0 * multiplier   //1000 = metres in km. 3600 = secs in hour.
            }
        }

        if toggleSpeed == 4 {

            toggleSpeed = 0 // WAS toggleSpeed = 0 when Fig8Scene accessed from here!!!
        } else if toggleSpeed == 6 {
            toggleSpeed = 0
        }
        toggleSpeed = toggleSpeed + 1
    } // //ZZZ
    
    //Create a straight dual carriageway, dual lane 1km long track and orient accordingly
    func createStraightTrack() {
        //blah! blah! blah!
        return
    }
    
    func addRoads() {
    createRoadSurfaces()
    createCentreLines()
    createInsideLines()
    createOutsideLines()
        
        if dONTrEPEAT == false {
        let veh = makeVehicle()
            dONTrEPEAT = true
        }
    }
    
    func createRoadSurfaces() {
    //Create road surfaces
//    var roadLength: CGFloat = 1000.0
//    var roadWidth: CGFloat = 8.0
    var xOffset: CGFloat = (roadWidth / 2) + (centreStrip / 2)     //metres
    var yOffset: CGFloat = 0.0  //metres
    var zPos: CGFloat = -54
    createLine(xOffset: xOffset, yOffset: yOffset, lWidth: roadWidth, lLength: roadLength, colour: SKColor(red: 42/256, green: 41/256, blue: 34/256, alpha: 1), zPos: zPos)   //Lay down bitumen
    }

    func createCentreLines() {
    //Create centre lines
        var yOffset = 0.0
        let xOffset = (roadWidth / 2) + (centreStrip / 2)     //metres (no change from road surfaces)
        let lineSpacing: CGFloat = 1000/83  //where 1000 = track length & 83 = no lines per km
    for i in 0..<83 {   //83 = no times centre line is drawn per 1km
    yOffset = CGFloat(i) * lineSpacing  //metres
        createLine(xOffset: xOffset, yOffset: yOffset, lLength: lineLength)
//            print("Line Spacing = \(yOffset) metres : sMetre1 = \(sMetre1)")
}   //end for loop
    }

    func createInsideLines() {
    //Create Inside Lines
        let yOffset = 0.0
        let xOffset = (shoulderLineWidth / 2) + (shoulderWidth) + (centreStrip / 2)     //metres (no change from road surfaces)
        createLine(xOffset: xOffset, yOffset: yOffset, lWidth: shoulderLineWidth, lLength: roadLength)
    }

    func createOutsideLines() {
        //Create Outside Lines
        let yOffset = 0.0
        let xOffset = (roadWidth - ((shoulderLineWidth / 2) + (shoulderWidth))) + (centreStrip / 2)
        createLine(xOffset: xOffset, yOffset: yOffset, lWidth: shoulderLineWidth, lLength: roadLength)
    }
    
    func createLine(xOffset: CGFloat, yOffset: CGFloat, lWidth: CGFloat = lineWidth, lLength: CGFloat, colour: SKColor = .white, zPos: CGFloat = -53, multiLine: Bool = true) {
//SKSpriteNode has better performance than SKShape!
        
//        var line1 = SKSpriteNode(color: colour, size: CGSize(width: (lWidth * sMetre1), height: (lLength * sMetre1)))
        let line1 = Line()
        line1.size = CGSize(width: (lWidth * sMetre1), height: (lLength * sMetre1))
        line1.color = colour
        line1.anchorPoint = CGPoint(x: 0.5, y: 0) //Set anchorpoint to middle bottom
        line1.position.y = (yOffset * sMetre1)
        line1.position.x = (size.width / 2) - (xOffset * sMetre1)
        line1.zPosition = zPos
        self.addChild(line1)
        
        if multiLine {
//        var line2 = SKSpriteNode(color: colour, size: CGSize(width: (lWidth * sMetre1), height: (lLength * sMetre1)))
            let line2 = Line()
            line2.size = CGSize(width: (lWidth * sMetre1), height: (lLength * sMetre1))
            line2.color = colour
            line2.anchorPoint = CGPoint(x: 0.5, y: 0) //Set anchorpoint to middle bottom
            line2.position.y = (yOffset * sMetre1)
            line2.position.x = (size.width / 2) + (xOffset * sMetre1)
            line2.zPosition = zPos
            self.addChild(line2)
        }
        
        return
    }
    
    func putVehicle() -> SKSpriteNode {
        let veh = Vehicle(imageName: "VehicleImage/T1")

        setAspectForWidth(sprite: veh)  //Sets veh width = 2m (default) & keeps aspect ratio
        let vehSize = veh.size
        veh.zPosition = -49
        veh.physicsBody = SKPhysicsBody(rectangleOf: vehSize)
        veh.physicsBody?.friction = 0
        veh.physicsBody?.restitution = 0
        veh.physicsBody?.linearDamping = 0
        veh.physicsBody?.angularDamping = 0
        veh.physicsBody?.allowsRotation = false
        
        return veh
    }

    func makeVehicle() {
        var fName: String = ""
        let maxVehicles: Int = (maxCars+maxTrucks+maxBuses)

        for i in 1...numVehicles {
            var randomVehicle = Int.random(in: 1...maxVehicles)
            var vWidth: CGFloat = 2.3   //Car width. Set truck & bus width = 2.5m (allow 300mm for side mirrors?)
            switch randomVehicle {
            case 1...maxCars:
                fName = "C\(randomVehicle)"
            case (maxCars+1)...(maxCars+maxTrucks):
                fName = "T\(randomVehicle-maxCars)"
                vWidth = 2.5
            default:
                fName = "B\(randomVehicle-maxCars-maxTrucks)"
                vWidth = 2.5
            }
            
            var s1Vehicle: Vehicle = Vehicle(imageName: vehImage + String(fName))
            
            setAspectForWidth(sprite: s1Vehicle, width: vWidth)  //Sets veh width = 2m (default) & maintains aspect ratio
            let vehSize = s1Vehicle.size
            
            s1Vehicle.zPosition = -49
            s1Vehicle.name = "s1Vehicle_\(i)"  //s1Vehicle_x -> Straight Track 1, f1Vehicle_x -> Figure 8 Track 1, g1Vehicle_x -> Game Track 1.
            s1Vehicle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: vehSize.width, height: vehSize.height + (1 * sMetre1)))   //Make rectangle same size as sprite + 0.5m front and back!
            s1Vehicle.physicsBody?.friction = 0
            s1Vehicle.physicsBody?.restitution = 0
            s1Vehicle.physicsBody?.linearDamping = 0
            s1Vehicle.physicsBody?.angularDamping = 0
            s1Vehicle.physicsBody?.allowsRotation = false
            s1Vehicle.physicsBody?.isDynamic = true
            
            addChild(s1Vehicle)

            var s2Vehicle: Vehicle = Vehicle(imageName: vehImage + String(fName))
            setAspectForWidth(sprite: s2Vehicle, width: vWidth)  //Sets veh width = 2m (default) & maintains aspect ratio
            let secSize = s2Vehicle.size
            
            s2Vehicle.zPosition = -49
            s2Vehicle.name = "s2Vehicle_\(i)"  //s2Vehicle_x -> Straight Track 2, f2Vehicle_x -> Figure 8 Track 2, g2Vehicle_x -> Game Track 2.
            s2Vehicle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: secSize.width, height: secSize.height + (1 * sMetre1)))   //Make rectangle same size as sprite + 0.5m front and back!
            s2Vehicle.physicsBody?.friction = 0
            s2Vehicle.zRotation = CGFloat(Double.pi)  //rotate 180 degrees //XXXXXXXXXX
            s2Vehicle.physicsBody?.restitution = 0
            s2Vehicle.physicsBody?.linearDamping = 0
            s2Vehicle.physicsBody?.angularDamping = 0
            s2Vehicle.physicsBody?.allowsRotation = false
            s2Vehicle.physicsBody?.isDynamic = true
            
            addChild(s2Vehicle)

            s1Vehicle = placeVehicle(s1Vehicle: s1Vehicle, s2Vehicle: s2Vehicle)

            t1Stats["Name"]?.append(s1Vehicle.name!)
            t1Stats["Actual Speed"]?.append(0.0)
            if let unwrapped = t1Stats["Name"]?[i] {
                if let speed = t1Stats["Actual Speed"]?[i] {
//                print("Name in Dictionary = \(unwrapped) : Speed = \(speed)")
                
                }
            }
        }
        return
//        return s1Vehicle
    }
    
//Creates and returns a new vehicle
func addVehicleBody() -> SKSpriteNode {
    //blah! blah! blah!

    return sprite
}

//Function will randomly place vehicles onscreen.
    func placeVehicle(s1Vehicle: Vehicle, s2Vehicle: Vehicle) -> Vehicle {
    var spriteClear = false
    var randomPos: CGFloat
    var randomLane: Int
    
    repeat {
        randomPos = CGFloat.random(in: 0..<1000)    //Sets random y position in metres (0 - 999.99999 etc)
        randomLane = Int.random(in: 0...1)          //Sets initial Lane 0 (LHS) or 1 (RHS)
        s1Vehicle.position.y = (randomPos * sMetre1)
        s1Vehicle.position.x = (randomLane == 0) ? ((sSceneWidth / 2.0) - (((roadWidth / 2) + (laneWidth / 2) + (lineWidth / 2) + (centreStrip/2)) * sMetre1)) : ((sSceneWidth / 2.0) - (((roadWidth / 2) - (laneWidth / 2) - (lineWidth / 2) + (centreStrip/2)) * sMetre1))
        s2Vehicle.position.y = (1000 * sMetre1) - s1Vehicle.position.y
        s2Vehicle.position.x = (randomLane == 0) ? ((sSceneWidth / 2.0) + (((roadWidth / 2) + (laneWidth / 2) + (lineWidth / 2) + (centreStrip/2)) * sMetre1)) : ((sSceneWidth / 2.0) + (((roadWidth / 2) - (laneWidth / 2) - (lineWidth / 2) + (centreStrip/2)) * sMetre1))
        spriteClear = true
        
        //        veh.position = CGPoint(x: ((view?.bounds.size.width)! / 2.0) - ((5.85 + centreStrip/2) * sMetre1), y: 400.0 * sMetre1)
        //MARK: - Ensure vehicle doesn't overlap existing vehicle!
        for sprite in t1allVehicles {
            if (s1Vehicle.intersects(sprite)) {
                spriteClear = false
            }
        }
    } while !spriteClear
    
    t1allVehicles.append(s1Vehicle)
    t2allVehicles.append(s2Vehicle)
    
    return s1Vehicle
}

//    func setHeightForWidth(sprite: SKSpriteNode, width: CGFloat = 2) -> SKSpriteNode {
    //return sprite not required!
    func setAspectForWidth(sprite: Vehicle, width: CGFloat = 2) {
        let aspectRatio: CGFloat = sprite.size.height/sprite.size.width
        sprite.size = CGSize(width: width * sMetre1, height: width * aspectRatio * sMetre1)
//        return sprite
    }
    
}


*/

