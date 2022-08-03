//
//  SceneModel.swift
//  Keep Left
//
//  Created by Bill Drayton on 16/6/2022.
//

import Foundation
import SwiftUI
import SpriteKit

class SceneModel: ObservableObject {
    
    @Published var metre1: CGFloat  //Multiply metres by this constant to get points
    @Published var height: CGFloat  //Height of screen in points
    @Published var width: CGFloat   //Width of screen in points
    @Published var sceneHeight: CGFloat //Height of screen in metres
    @Published var sceneWidth: CGFloat  //Width of screen in metres
    @Published var portrait: Bool
    @Published var size: CGSize

    init() {
        metre1 = 1.0
        height = 1.0
        width = 1.0
        sceneHeight = 1.0
        sceneWidth = 1.0
        portrait = true
        size = CGSize(width: 1.0, height: 1.0)
    }
    
    /*
    init(size: CGSize) {
        self.size = size
    }
    */

    func calcF8Scene(f8Size: CGSize = UIScreen.main.bounds.size) -> Bool {
        
    var hGTWx2: Bool = false

        if (f8Size.width < f8Size.height) {
            
            portrait = true
            
            height = f8Size.height
            width = f8Size.width
            
            //MARK: - Use width to calculate scale factor for very tall screens Fig 8 Track only!
            if ((f8Size.height > (2 * f8Size.width))) {
                hGTWx2 = true
                metre1 = f8Size.width / f8ScreenWidth
            } else {
                metre1 = f8Size.height / f8ScreenHeight
            }
            
        } else {
            
            portrait = false
            
            height = f8Size.width
            width = f8Size.height
            
            //MARK: - Use width to calculate scale factor for very tall screens Fig 8 Track only!
            if ((f8Size.height > (2 * f8Size.width))) {
                hGTWx2 = true
                metre1 = f8Size.width / f8ScreenWidth
            } else {
                metre1 = f8Size.height / f8ScreenHeight
            }
            
//            //MARK: - Use height to calculate scale factor for very wide screens Fig 8 Track only!
//            if (f8Size.width > (2 * f8Size.height)) {
//                metre1 = f8Size.height / f8ScreenHeight
//            } else {
//                metre1 = f8Size.width / f8ScreenWidth
//            }
        }
        return hGTWx2
    }
    
    func calcStraightScene(sSize: CGSize = UIScreen.main.bounds.size) {

        if (sSize.width < sSize.height) {
            
            portrait = true
            
            height = sSize.height
            width = sSize.width
            
            //MARK: - Use width to calculate scale factor. sTrackWidth can vary to set scale.
            metre1 = width / sTrackWidth

//            sceneWidth = sTrackWidth
//            sceneHeight = 1000 * metre1 = sTrackLength

        } else {
            
            portrait = false
            
            height = sSize.width
            width = sSize.height
            
            //MARK: - Use width to calculate scale factor. sTrackWidth can vary to set scale.
            metre1 = width / sTrackWidth

//            sceneWidth = sTrackWidth
//            sceneHeight = 1000 * metre1 = sTrackLength

        }
    }
}
