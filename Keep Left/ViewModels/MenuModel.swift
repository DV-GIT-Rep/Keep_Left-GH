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
        self.mainMenu = DataService.getLocalData(fileName: "menus", fileType: "json")
        
    }
}
