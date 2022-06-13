//
//  Vehicle.swift
//  Keep Left
//
//  Created by Bill Drayton on 16/3/2022.
//

import SpriteKit

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
