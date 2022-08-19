//  Fig8TrackView.swift
//  Keep Left



import SwiftUI
import SpriteKit

struct Fig8TrackView: View {
    
    var fig8Scene = Fig8Scene()

    var body: some View {

        //NOTE: Loading f8Metre1 into 'scale' here DOESN'T WORK as it's never recomputed!!!
        var scale: CGFloat = 1.875 - 0.25
        
        ZStack {
            SpriteView(scene: fig8Scene)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                ResultsView()
                    .scaleEffect(scale)
//                Spacer()
//                Text("f8Metre1 = \(f8Metre1)")
                Spacer(minLength: UIScreen.main.bounds.height / 2.6)
//                Spacer(minLength: UIScreen.main.bounds.height / 2.2)    //iPad 12.9"
//                Spacer(minLength: UIScreen.main.bounds.height / 2.6)    //iPh 13
                OtherResultsView()
                    .scaleEffect(scale)
                Spacer(minLength: UIScreen.main.bounds.height / 5.5)
            }
            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
        }
        .statusBar(hidden: true)
    }
}

struct Fig8TrackView_Previews: PreviewProvider {
    static var previews: some View {
        Fig8TrackView()
            .previewInterfaceOrientation(.portraitUpsideDown)
    }
}
