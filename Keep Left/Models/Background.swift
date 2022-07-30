//
//  Background.swift
//  Keep Left
//
//  Created by Bill Drayton on 24/7/2022.
//

import SpriteKit

class Background: SKSpriteNode, ObservableObject {
    
//    @Published var size: CGSize
//    @Published var txVehicle = [Vehicle]()

    //MARK: - Init
    init(size: CGSize = CGSize(width: 1, height: 1), colour: UIColor = sBackgroundColour, zPos: Int = -200) {
//        let size = CGSize(width: 1, height: 1)
//        let colour = UIColor(red: 0.19, green: 0.38, blue: 0.16, alpha: 1)    //Green background
//        let texture = SKTexture()
        super.init(texture: nil, color: colour, size: size)

    }
    
    func makeBackground(size: CGSize, colour: UIColor = sBackgroundColour, image: String? = nil, zPos: CGFloat = -200) {
        self.size = size
        self.zPosition = zPos
        self.position = CGPoint(x: 0, y: 0)

        if let image = image {
            self.texture = SKTexture(imageNamed: image)
        } else {
        self.color = colour
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    convenience init() {
//        self.init()
//
//    }
    
    //MARK: - Setup
    func setup() {
        
    }
    
    //MARK: - tbc Move background by required amount???
    func animate() {
        
    }
    
}
