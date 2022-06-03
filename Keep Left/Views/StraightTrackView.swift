//
//  StraightTrackView.swift
//  Keep Left
//
//  Created by Bill Drayton on 2/6/2022.
//

import SwiftUI
import SpriteKit

struct StraightTrackView: View {
    
    var straightScene = StraightTrackScene()

    var body: some View {

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

        }
        .statusBar(hidden: true)

    }
}


struct StraightTrackView_Previews: PreviewProvider {
    static var previews: some View {
        StraightTrackView()
    }
}
