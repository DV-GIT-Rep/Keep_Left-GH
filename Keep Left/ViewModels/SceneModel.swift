//
//  SceneModel.swift
//  Keep Left
//
//  Created by Bill Drayton on 16/6/2022.
//

import Foundation
import SwiftUI

class SceneModel: ObservableObject {
    
    @Published var f8Metre1: CGFloat
    @Published var f8Height: CGFloat
    @Published var f8Width: CGFloat
    @Published var f8Portrait: Bool

    @Published var sMetre1: CGFloat
    @Published var sHeight: CGFloat
    @Published var sWidth: CGFloat
    @Published var sPortrait: Bool
    
    init() {
        f8Metre1 = 1.0
        f8Height = 1.0
        f8Width = 1.0
        f8Portrait = true

        sMetre1 = 1.0
        sHeight = 1.0
        sWidth = 1.0
        sPortrait = true
    }
    
    func calcF8Scene(height: CGFloat = UIScreen.main.bounds.size.height,
                   width: CGFloat = UIScreen.main.bounds.size.width) -> (height: CGFloat,
                                         width: CGFloat,
                                         metre1: CGFloat,
                                         portrait: Bool) {
        
        let f8Height = height
        let f8Width = width
        
        if (width < height) {
            
            f8Portrait = true
            
            //MARK: - Use width to calculate scale factor for very tall screens Fig 8 Track only!
            if ((f8Height > (2 * f8Width))) {
                f8Metre1 = f8Width / f8ScreenWidth
            } else {
                f8Metre1 = f8Height / f8ScreenHeight
            }
            
        } else {
            
            f8Portrait = false
            
            //MARK: - Use height to calculate scale factor for very wide screens Fig 8 Track only!
            if (f8Width > (2 * f8Height)) {
                f8Metre1 = f8Height / f8ScreenHeight
            } else {
                f8Metre1 = f8Width / f8ScreenWidth
            }
            
        }
        
        return (f8Height, f8Width, f8Metre1, f8Portrait)
    }
    
    func calcStraightScene(height: CGFloat = UIScreen.main.bounds.size.height,
                   width: CGFloat = UIScreen.main.bounds.size.width) -> (height: CGFloat,
                                         width: CGFloat,
                                         metre1: CGFloat,
                                         portrait: Bool) {
        
        let sHeight = height
        let sWidth = width
        
        if (sWidth < sHeight) {
            
            sPortrait = true
            
            //MARK: - Use width to calculate scale factor. sTrackWidth can vary to set scale.
                sMetre1 = sWidth / sTrackWidth

            sSceneWidth = sWidth
            sSceneHeight = 1000 * sMetre1

        } else {
            
            sPortrait = false
            
            //MARK: - Use width to calculate scale factor. sTrackWidth can vary to set scale.
            sMetre1 = sHeight / sTrackWidth

            sSceneWidth = 1000 * sMetre1
            sSceneHeight = sHeight

        }
        
        return (sSceneHeight, sSceneWidth, sMetre1, sPortrait)
    }
    

}
