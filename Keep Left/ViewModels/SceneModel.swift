//
//  SceneModel.swift
//  Keep Left
//
//  Created by Bill Drayton on 16/6/2022.
//

import Foundation
import SwiftUI

class SceneModel: ObservableObject {
    
    @Published var metre1: CGFloat
    @Published var height: CGFloat
    @Published var width: CGFloat
    @Published var portrait: Bool
    @Published var size: CGSize

    init() {
        metre1 = 1.0
        height = 1.0
        width = 1.0
        portrait = true
        size = CGSize(width: 1.0, height: 1.0)
    }
    
    /*
    init(size: CGSize) {
        self.size = size
    }
    */

    func calcF8Scene(size: CGSize = UIScreen.main.bounds.size) {

        height = size.height
        width = size.width
        
        if (width < height) {
            
            portrait = true
            
            //MARK: - Use width to calculate scale factor for very tall screens Fig 8 Track only!
            if ((height > (2 * width))) {
                metre1 = width / f8ScreenWidth
            } else {
                metre1 = height / f8ScreenHeight
            }
            
        } else {
            
            portrait = false
            
            //MARK: - Use height to calculate scale factor for very wide screens Fig 8 Track only!
            if (width > (2 * height)) {
                metre1 = height / f8ScreenHeight
            } else {
                metre1 = width / f8ScreenWidth
            }
            
        }
    }
    
    func calcStraightScene(size: CGSize = UIScreen.main.bounds.size) {

        height = size.height
        width = size.width
        
        if (width < height) {
            
            portrait = true
            
            //MARK: - Use width to calculate scale factor. sTrackWidth can vary to set scale.
            metre1 = width / sTrackWidth

            sSceneWidth = width
            sSceneHeight = 1000 * metre1

        } else {
            
            portrait = false
            
            //MARK: - Use width to calculate scale factor. sTrackWidth can vary to set scale.
            metre1 = height / sTrackWidth

            sSceneWidth = 1000 * metre1
            sSceneHeight = height

        }
    }

}
