//
//  Menu.swift
//  Keep Left
//
//  Created by Bill Drayton on 1/6/2022.
//

import Foundation
import SwiftUI

class Menu: Identifiable, Decodable {
    
    var id: UUID?
    var name: String
    var image: String
    var view: Int
    var features: [String]
    
}
