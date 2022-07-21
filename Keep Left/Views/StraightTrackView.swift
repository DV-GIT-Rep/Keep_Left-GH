//
//  StraightTrackView.swift
//  Keep Left
//
//  Created by Bill Drayton on 2/6/2022.
//

import SwiftUI
import SpriteKit

struct StraightTrackView: View {
    
    @State private var angle: Angle = .degrees(0)
    @State private var straitScene = StraightTrackScene()

    var body: some View {

        ZStack {
            SpriteView(scene: straitScene, options: .ignoresSiblingOrder, debugOptions: [.showsFPS, .showsNodeCount])
//                .frame(width: 1000, height: 1200)
                .ignoresSafeArea()
                .rotationEffect(angle, anchor: .center)
            
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
        .onAppear {
            self.updateOrintation()
    }
//
////            let value = UIInterfaceOrientation.portrait.rawValue
////            UIDevice.current.setValue(value, forKey: "orientation")
////
//            //Code below replaced by camera. Located in StraightTrackScene.swift.
//            //            let isLandscape = UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight
////            let rotation = isLandscape ? CGFloat.pi/2 : 0
////            straitScene.set(sContainerZRotation:rotation)

//        .statusBar(hidden: true)
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            
            self.updateOrintation()
        }
        .edgesIgnoringSafeArea(.all)
//        .scaledToFill()   //Fills view (stops letterboxing) but screws up scaling

    }
    
//    private func updateOrintation() {
//        switch UIDevice.current.orientation {
//        case .landscapeLeft:
//            self.angle = .radians(-.pi / 2) //.degrees(90)
//        case .landscapeRight:
//            self.angle = .radians(.pi / 2)
//        case .portraitUpsideDown:
//            self.angle = .radians(.pi)
//        default:
//            self.angle = .radians(0)
//        }
//    }
    private func updateOrintation() {
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            self.angle = .degrees(0)    //.degrees(90)
        case .landscapeRight:
            self.angle = .degrees(0)    //.degrees(90)
        case .portraitUpsideDown:
            self.angle = .degrees(0)    //0 OK for iPad - use 90 for iPhone?
        default:
            self.angle = .degrees(0)
        }
    }

}


struct StraightTrackView_Previews: PreviewProvider {
    static var previews: some View {
        StraightTrackView()
    }
}
