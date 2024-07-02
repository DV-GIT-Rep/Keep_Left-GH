//
//  MainMenuView.swift
//  Keep Left
//
//  Created by Bill Drayton on 1/6/2022.
//

import SwiftUI
import SpriteKit

struct MainMenuView: View {
    
//    //Create an instance of LabelData
//    @StateObject var ld = LabelData()       //Instance of state of truth created at root level

    //Reference the Scene and View Models
    @StateObject var scene = SceneModel()
    @StateObject var model = MenuModel()
    
    
    var body: some View {
        
        NavigationView {
            List(model.mainMenu) { men in
                
//                let model = MenuModel()
                
//                var viewName1: String = men.view
//                var viewName2: AnyView = AnyView(viewName1)
//                var destinationView: AnyView = AnyView(viewName1())
////                print("\(destinationView) ")

                var viewNo = men.view
//                var destinationView: AnyView = AnyView(Fig8TrackView())
                
                var destinationView: AnyView = getView(viewNo: viewNo)
                
                NavigationLink(
                    destination: destinationView,
                    label: {
                        //MARK: Row item
                        HStack(spacing: 18.0) {
                            Image(men.image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50, alignment: .center)
                                .clipped()
                                .cornerRadius(5)
                            Text(men.name)
//                            Text(ViewName)
                            
//                            Text(destinationView)
//                            Text("Image")
//                            Text(men.image)
                        }
                    })
            }
            .navigationTitle("Select")
        }
        .accentColor(Color(iconColour))
//        .accentColor(Color(UIColor(red: 0.05, green: 0.2, blue: 0.05, alpha: 1)))
        .environmentObject(scene)   //Anything inside NavigationView to access SceneModel class
        .environmentObject(model)   //Anything inside NavigationView to access MenuModel class
//        .environmentObject(ld)      //Modifier to pass source of truth to child views (doesn't require same name!)
    }
}

//MARK: - Add views to Select Screen -
func getView(viewNo: Int) -> AnyView {
    
    switch viewNo {
    case 1:
//        let destinationView: AnyView = AnyView(Fig8TrackView())
        let destinationView: AnyView = AnyView(StraightTrackView())
//        whichScene = .figure8
        return destinationView
    case 2:
        let destinationView: AnyView = AnyView(GameTrackView())
//        let destinationView: AnyView = AnyView(StraightTrackScene())
//        whichScene = .straight
//        if whichScene == .figure8 {
//         whichScene = .straight
//        } else {
//            whichScene = .figure8
//        }
//        print ("whichScene = \(whichScene)")
//        print("!!! XXXXXXXXXXXXXXXXXXX  !!!")
        return destinationView
    case 3:
        let destinationView: AnyView = AnyView(ScreenShotView())
//        whichScene = .game
//        print("!!! XXXXXXXXXXXXXXXXXXX  !!!")
        return destinationView
   case 4:
        let destinationView: AnyView = AnyView(QuizView())
//        whichScene = .game
//        print("!!! XXXXXXXXXXXXXXXXXXX  !!!")
        return destinationView
    case 5:
        let destinationView: AnyView = AnyView(StatsView())
        return destinationView
    case 6:
        let destinationView: AnyView = AnyView(UserGuideView())
        return destinationView
    default:
        let destinationView: AnyView = AnyView(SettingsView())
        return destinationView
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
//        MainMenuView(topLabel: LabelData(), bottomLabel: LabelData())
        MainMenuView()
            .previewInterfaceOrientation(.portrait)
    }
}
