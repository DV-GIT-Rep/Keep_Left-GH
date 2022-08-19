//
//  DataService.swift
//  Keep Left
//
//  Created by Bill Drayton on 1/6/2022.
//

import Foundation

class DataService: ObservableObject {
    
    static func getLocalMenuData(fileName: String, fileType: String = "json") -> [Menu] {

        //Parse local JSON file

        //Get the URL path to the JSON file
        let pathString = Bundle.main.path(forResource: fileName, ofType: fileType)

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
                print("Error parsing JSON data for \(fileName).\(fileType):\n   \(error)")
            }

        } catch {
            //Error retrieving data
            print("Error retrieving Data from \(fileName).\(fileType):\n   \(error)")
        }

        //Only gets here if there is an error! Return empty recipe array!
        return [Menu]()
    }
    
//    static func getLocalLabelData(fileName: String, fileType: String = "json") -> [F8DataLabel] {
//        
//        //Parse local JSON file
//        
//        //Get the URL path to the JSON file
//        let pathString = Bundle.main.path(forResource: fileName, ofType: fileType)
//
//        //Verify pathString is not equal to nil, else return an empty recipe
//        guard pathString != nil else {
//            return [F8DataLabel]()
//        }
//        
//        //Create a URL object (assume data != nil as pathString returned a value!!!
//        let url = URL(fileURLWithPath: pathString!)
//        
//        do {
//            
//            //Create a Data object
//            let data = try Data(contentsOf: url)
//            
//            //Decode the Data with a JSON decoder
//            let decoder = JSONDecoder()
//            
//            do {
//                
//                let labelData = try decoder.decode([F8DataLabel].self, from: data)
//                
//                //Add the unique IDs
//                for var lbl in labelData {
//                    lbl.id = UUID()
//                }
//                
//                //Return the menu items from the JSON data
//                return labelData
//                
//            } catch {
//                //Error parsing JSON
//                print("Error parsing JSON data for \(fileName).\(fileType):\n   \(error)")
//            }
//            
//        } catch {
//            //Error retrieving data
//            print("Error retrieving Data from \(fileName).\(fileType):\n   \(error)")
//        }
//        
//        //Only gets here if there is an error! Return empty recipe array!
//        return [F8DataLabel]()
//    }
    
}

/*  frm Paul Hudson - not used
extension Bundle {
    func decode<T: Decodable>(_ type: T.Type, from file: String, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.keyDecodingStrategy = keyDecodingStrategy

        do {
            return try decoder.decode(T.self, from: data)
        } catch DecodingError.keyNotFound(let key, let context) {
            fatalError("Failed to decode \(file) from bundle due to missing key '\(key.stringValue)' not found – \(context.debugDescription)")
        } catch DecodingError.typeMismatch(_, let context) {
            fatalError("Failed to decode \(file) from bundle due to type mismatch – \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let type, let context) {
            fatalError("Failed to decode \(file) from bundle due to missing \(type) value – \(context.debugDescription)")
        } catch DecodingError.dataCorrupted(_) {
            fatalError("Failed to decode \(file) from bundle because it appears to be invalid JSON")
        } catch {
            fatalError("Failed to decode \(file) from bundle: \(error.localizedDescription)")
        }
    }
}
*/
