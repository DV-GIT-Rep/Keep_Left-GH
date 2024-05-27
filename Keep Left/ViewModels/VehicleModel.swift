//
//  VehicleModel.swift
//  Keep Left
//
//  Created by Bill Drayton on 12/6/2022.
//

import Foundation

class VehicleModel: ObservableObject {
    
    @Published var txVehicle = [Vehicle]()

    init() {
        
//        //Retrieve the local data using the getLocalMenuData function in the DataService class
//        self.txVehicle = DataService.getLocalVehicleData(fileName: "vehicles", fileType: "json")
        
    }
}
