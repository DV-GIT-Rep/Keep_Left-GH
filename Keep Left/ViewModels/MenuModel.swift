//
//  MenuModel.swift
//  Keep Left
//
//  Created by Bill Drayton on 1/6/2022.
//

import Foundation
import SwiftUI

class MenuModel: ObservableObject {
    
    @Published var mainMenu = [Menu]()
    
    init() {
        
        //Retrieve the local data using the getLocalData function in the DataService class
        self.mainMenu = DataService.getLocalData()
        
    }
    
//    public func getView(viewNo: Int) -> AnyView {
//        
//        switch viewNo {
//        case 1:
//            let destinationView: AnyView = AnyView(Fig8TrackView())
//            return destinationView
//        case 2:
//            let destinationView: AnyView = AnyView(StraightTrackView())
//            return destinationView
//        case 3:
//            let destinationView: AnyView = AnyView(GameTrackView())
//            return destinationView
//        case 4:
//            let destinationView: AnyView = AnyView(ScreenShotView())
//            return destinationView
//        default:
//            let destinationView: AnyView = AnyView(SettingsView())
//            return destinationView
//        }
//    }
//    
}
