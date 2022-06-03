//
//  MainMenuView.swift
//  Keep Left
//
//  Created by Bill Drayton on 1/6/2022.
//

import SwiftUI

struct MainMenuView: View {
    
    //Reference the View Model
    @ObservedObject var model = MenuModel()
    
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
    }
}

//MARK: - Add views to Select Screen -
func getView(viewNo: Int) -> AnyView {
    
    switch viewNo {
    case 1:
        let destinationView: AnyView = AnyView(Fig8TrackView())
        return destinationView
    case 2:
        let destinationView: AnyView = AnyView(StraightTrackView())
//        let destinationView: AnyView = AnyView(StraightTrackScene())
        return destinationView
    case 3:
        let destinationView: AnyView = AnyView(GameTrackView())
        return destinationView
    case 4:
        let destinationView: AnyView = AnyView(ScreenShotView())
        return destinationView
    case 5:
        let destinationView: AnyView = AnyView(UserGuideView())
        return destinationView
    default:
        let destinationView: AnyView = AnyView(SettingsView())
        return destinationView
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}
