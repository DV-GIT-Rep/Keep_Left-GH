//
//  ContentView.swift
//  Keep Left
//
//  Created by Bill Drayton on 13/1/22.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    
//    var scene = StraightTrackScene()
    var straightScene = StraightTrackScene()
    var fig8Scene = Fig8Scene()
//    var scene = Fig8Scene()

    var body: some View {
//        NavigationView {
//            Text("First Page")
        
        //NOTE: Loading f8Metre1 into 'scale' here DOESN'T WORK as it's never recomputed!!!
        var scale: CGFloat = 1.875 - 0.25
        
        ZStack {
            SpriteView(scene: straightScene)
//                .frame(width: 1000, height: 1200)
                .ignoresSafeArea()
            
        /*  StraightScene ONLY for now!!!
            SpriteView(scene: fig8Scene)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                ResultsView()
                    .scaleEffect(scale)
                Spacer()
                Text("f8Metre1 = \(f8Metre1)")
                Spacer()
//                Spacer(minLength: UIScreen.main.bounds.height / 2.2)    //iPad 12.9"
//                Spacer(minLength: UIScreen.main.bounds.height / 2.6)    //iPh 13
                ResultsView()
                    .scaleEffect(scale)
                Spacer()
            }
         */ //  StraightScene ONLY for now!!!

////            var transition: SKTransition = SKTransition.fade(withDuration: 2)
//            SpriteView(scene: fig8Scene)
//                .frame(width: 1000, height: 1200)
//                .ignoresSafeArea()
            
//            VStack {
//                ProgressView(value: 15, total: 100)   //Creates a Progress indicator
//                    .padding([.leading, .trailing], 50)
//                Label("Progress View", systemImage: "hourglass.bottomhalf.fill")
//                    .scaleEffect(2)
//                    .padding()
//            }
        }
//        }
        .statusBar(hidden: true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
//            .previewInterfaceOrientation(.portrait)
    }
}
