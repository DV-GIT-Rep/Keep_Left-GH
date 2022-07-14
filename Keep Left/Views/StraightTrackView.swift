//
//  StraightTrackView.swift
//  Keep Left
//
//  Created by Bill Drayton on 2/6/2022.
//

import SwiftUI
import SpriteKit

struct StraightTrackView: View {
    
    @State private var straitScene = StraightTrackScene()

    var body: some View {

        ZStack {
            SpriteView(scene: straitScene, options: .ignoresSiblingOrder, debugOptions: [.showsFPS, .showsNodeCount])
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
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            let isLandscape = UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight
            let rotation = isLandscape ? CGFloat.pi/2 : 0
            straitScene.set(sContainerZRotation:rotation)
        }

    }
}


struct StraightTrackView_Previews: PreviewProvider {
    static var previews: some View {
        StraightTrackView()
    }
}
