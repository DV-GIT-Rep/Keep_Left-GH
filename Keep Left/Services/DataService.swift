//
//  DataService.swift
//  Keep Left
//
//  Created by Bill Drayton on 1/6/2022.
//

import Foundation

class DataService: ObservableObject {
    
    static func getLocalData() -> [Menu] {
        
        //Parse local JSON file
        
        //Get the URL path to the JSON file
        let pathString = Bundle.main.path(forResource: "menus", ofType: "json")

        //Verify pathString is not equal to nil, else return an empty recipe
        guard pathString != nil else {
            return [Menu]()
        }
        
        //Create a URL object (assume data != nil as pathString returned a value!!!
        let url = URL(fileURLWithPath: pathString!)
        
        do {
            
            //Create a Data object
            let data = try Data(contentsOf: url)
            
            //Decode the Data with a JSON decoder
            let decoder = JSONDecoder()
            
            do {
                
                let menuData = try decoder.decode([Menu].self, from: data)
                
                //Add the unique IDs
                for men in menuData {
                    men.id = UUID()
                }
                
                //Return the menu items from the JSON data
                return menuData
                
            } catch {
                //Error parsing JSON
                print("Error parsing JSON data: \(error)")
            }
            
        } catch {
            //Error retrieving data
            print("Error retrieving Data: \(error)")
        }
        
        //Only gets here if there is an error! Return empty recipe array!
        return [Menu]()
    }
}
