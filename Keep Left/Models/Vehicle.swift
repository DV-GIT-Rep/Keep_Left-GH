//
//  Vehicle.swift
//  Keep Left
//
//  Created by Bill Drayton on 16/3/2022.
//

import Foundation
import SpriteKit
import SwiftUI

class Vehicle: SKSpriteNode, ObservableObject {
    
    @Published var txVehicle = [Vehicle]()

    //MARK: - Init
    init(imageName: String) {
        let texture = SKTexture(imageNamed: imageName)
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
//        super.init(imageName: imageName)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init()

    }
    
    //MARK: - Setup
    func setup() {
        
    }
    
    //MARK: - tbc Move vehicle by required amount???
    func animate() {
        
    }
    
    //MARK: - Flash indicators as required - see enum (not yet added)
    func indicate() {
        
        enum Indicator: CaseIterable {
            case off
            case left
            case right
        }
        // eg.  Indicator.off
        //      Indicator.allCases.forEach { ... }
    }
    
    //MARK: - Lights and taillights on/off as per enum - ALL Vehicles!
    func lights() {
        
        enum Lights: CaseIterable {
            case off        //Lights Off
            case low        //Low Beam On
            case high       //High Beam On
        }
    }
}

class f8Vehicle: Vehicle {
//    self.physicsBody.rotationEffect(.degrees(45))
//    static var straightName: String = replacingCharacters(in: name, with: <#T##String#>)
    
    
    func moveF8Vehicle(f8Node: SKNode, meta1: CGFloat, F8YZero: CGFloat) {
        
//        guard let sEquiv = self else {
//            return
//        }
        //Note: self = f8 Node
        var sEquivName: String = f8Node.name!  //lazy???

        //MARK: - Find name of Straight Track equivalent to Fig 8 Track Vehicle
        //          eg.f8KLVehicle_5 -> sKLVehicle_5 OR f8OtherVehicle_69 -> sOtherVehicle_69
        var newPosition: CGPoint = CGPoint(x: 0, y: 0)
//        var sEquivName: String = self.name!
        sEquivName.remove(at: sEquivName.startIndex)        //Remove "f" from start of name
        sEquivName.remove(at: sEquivName.startIndex)        //Remove "8" from start of name
        sEquivName.insert("s", at: sEquivName.startIndex)   //Replace "f8" with "s"
        sEquivName.insert("/", at: sEquivName.startIndex)   //Add "/"
        sEquivName.insert("/", at: sEquivName.startIndex)   //Add "/"
//        print("0. self = f8Node = \(f8Node)\nsEquivName = \(sEquivName) : childNode = \(childNode(withName: sEquivName)) or \(childNode(withName: "//sKLVehicle_5"))")
        guard let tempNode = childNode(withName: sEquivName) else {
            return
        }
        let sEquivVehiclePos = tempNode.position
        
        //__________________________________________________________________________________________
        f8Node.position.x = (CGFloat(50) * meta1)
        f8Node.position.y = (CGFloat(50) * meta1)
//        print("1.,\(tempNode.name!):,\(sEquivVehiclePos.y.dp2),\(f8Node.name!):,\(f8Node.position.y.dp2)")
        return
        //__________________________________________________________________________________________

//        print("a.,\(tempNode.name!):,\(tempNode.position.x.dp2),\(tempNode.position.y.dp2),,\(f8Node.name!):,\(f8Node.position.x.dp2),\(f8Node.position.y.dp2)")
        //MARK: - Calculate position of figure 8 vehicle based on straight track vehicle
        switch sEquivVehiclePos.y {
        case let y where y <= (f8Radius * meta1):
            print("1.,y,\(y.dp2),\(tempNode.name!),\(sEquivVehiclePos.y.dp2),meta1:,\(meta1)")
            //1st straight stretch 45' from origin up and to right
            f8Node.position.x = ((cos(CGFloat(45).degrees()) / sEquivVehiclePos.y) * meta1)
            f8Node.position.y = F8YZero + ((sin(45 * degreesToRadians) / sEquivVehiclePos.y) * meta1)
//            print("1. self = \(self) : f8Node = \(f8Node) : sEquivVehiclePos = \(sEquivVehiclePos)")
        case let y where y <= ((f8Radius + (1.5 * .pi * f8Radius)) * meta1):
            //1st 3/4 circle heading up and to left
//            f8Node.position.x = -(cos(45 * degreesToRadians) / sEquivVehiclePos.y) * meta1
//            f8Node.position.y = F8YZero + ((sin(45 * degreesToRadians) / sEquivVehiclePos.y) * meta1)
            print("2.,y,\(y.dp2),\(tempNode.name!),\(sEquivVehiclePos.y.dp2),meta1:,\(meta1)")

        case let y where y <= (((3 * f8Radius) + (1.5 * .pi * f8Radius)) * meta1):
            //2nd straight stretch 45' down to right
//            f8Node.position.x = (cos(45 * degreesToRadians) / sEquivVehiclePos.y) * meta1
//            f8Node.position.y = F8YZero - ((sin(45 * degreesToRadians) / sEquivVehiclePos.y) * meta1)
            print("3.,y,\(y.dp2),\(tempNode.name!),\(sEquivVehiclePos.y.dp2),meta1:,\(meta1)")

        case let y where y <= (((3 * f8Radius) + (3 * .pi * f8Radius)) * meta1):
            //2nd 3/4 circle heading down and to left
//            f8Node.position.x = -(cos(45 * degreesToRadians) / sEquivVehiclePos.y) * meta1
//            f8Node.position.y = F8YZero - ((sin(45 * degreesToRadians) / sEquivVehiclePos.y) * meta1)
            print("4.,y,\(y.dp2),\(tempNode.name!),\(sEquivVehiclePos.y.dp2),meta1:,\(meta1)")

        case let y where y <= (((4 * f8Radius) + (3 * .pi * f8Radius)) * meta1):
            //3rd straight stretch 45' up & back to origin
//        default:
//            f8Node.position.x = (0.08) * meta1
//            f8Node.position.y = F8YZero + ((0.08) * meta1)
            print("5.,y,\(y.dp2),\(tempNode.name!),\(sEquivVehiclePos.y.dp2),meta1:,\(meta1)")
//            \\childNode(withName: "f8KLVehicle_5").position = CGP
        default:
            print("6.,y,\(sEquivVehiclePos.y.dp2),\(tempNode.name!),\(sEquivVehiclePos.y.dp2),meta1:,\(meta1),Default:")
            return

        }
        
    }
    
}
