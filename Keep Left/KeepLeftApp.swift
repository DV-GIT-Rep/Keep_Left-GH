//
//  Keep Left.swift
//  Keep Left
//
//  Created by Bill Drayton on 13/1/22.
//

//NOTE: - For both the Straight Track View and the Figure 8 View, the Straight Track will be included
// in the view at a lower Z level. This allows vehicles to operate at all times.

import SwiftUI

@main
struct Keep_Left: App {
    
//    init () {
//        Fig8TrackView()
//        StraightTrackView()
//        GameTrackView()
//        ScreenShotView()
//        SettingsView()
//    }
    var body: some Scene {
        WindowGroup {
            MainMenuView()
        }
    }
}
