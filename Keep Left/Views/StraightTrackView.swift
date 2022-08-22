//
//  StraightTrackView.swift
//  Keep Left
//
//  Created by Bill Drayton on 2/6/2022.
//

import SwiftUI
import SpriteKit

struct StraightTrackView: View {
    
//    //Reference the top and bottom figure 8 labels
//    @ObservedObject var topLabel = LabelData()
//    @ObservedObject var bottomLabel = LabelData()
//
//    var straitScene: SKScene {
    let straitScene = StraightTrackScene()
//        straitScene.topLabel = topLabel
//        straitScene.bottomLabel = bottomLabel
////            straitScene.size = CGSize(width: view?.bounds.size.width, height: view.bounds.size.height)
////            straitScene.scaleMode = .aspectFill
//        return straitScene
//    }
    let gameScene = GameScene()

    @State private var angle: Angle = .degrees(0)
//    @State var straitScene = StraightTrackScene()
//    @State private static var straitScene = StraightTrackScene()  //try later !!! x2

    var body: some View {
        
        var scale: CGFloat = 1.875 - 0.25
        
        ZStack {
            SpriteView(scene: straitScene, options: .ignoresSiblingOrder)
//            SpriteView(scene: gameScene, options: .ignoresSiblingOrder)
//            SpriteView(scene: straitScene, options: .ignoresSiblingOrder, debugOptions: [.showsFPS, .showsNodeCount])
//            SpriteView(scene: StraightTrackView.straitScene, options: .ignoresSiblingOrder, debugOptions: [.showsFPS, .showsNodeCount]) //try later !!! x2
//                .frame(width: 1000, height: 1200)
                .ignoresSafeArea()
                .rotationEffect(angle, anchor: .center)
            
        /*  StraightScene ONLY for now!!!
            SpriteView(scene: fig8Scene)
                .ignoresSafeArea()
         */ //  StraightScene ONLY for now!!!

//            if (whichScene != .figure8) {
//            VStack {
//                Spacer()
////                ResultsView()
////                    .scaleEffect(scale)
//                Spacer(minLength: UIScreen.main.bounds.height / 2.6)
////                Spacer(minLength: UIScreen.main.bounds.height / 2.2)    //iPad 12.9"
////                Spacer(minLength: UIScreen.main.bounds.height / 2.6)    //iPh 13
//                OtherResultsView()
//                    .scaleEffect(scale)
//                Spacer(minLength: UIScreen.main.bounds.height / 5.5)
//            }
//            }

        }
        .statusBar(hidden: true)
        .onAppear {
            self.updateOrintation()
//            self.switchViews()
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
//            print("Landscape Left")
            self.angle = .degrees(0)    //.degrees(90)
        case .landscapeRight:
//            print("Landscape Right")
            self.angle = .degrees(0)    //.degrees(90)
        case .portraitUpsideDown:
            self.angle = .degrees(0)    //0 OK for iPad - use 90 for iPhone?
        default:
            self.angle = .degrees(0)
        }
    }
    
    private func switchViews() {
                if whichScene == .figure8 {
                 whichScene = .straight
                } else {
                    whichScene = .figure8
                }
//        print ("whichScene = \(whichScene)")
    }

}


struct StraightTrackView_Previews: PreviewProvider {
    static var previews: some View {
        StraightTrackView()
    }
}
