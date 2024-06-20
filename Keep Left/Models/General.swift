//
//  General.swift
//  Keep Left
//
//  Created by Bill Drayton on 13/6/2024.
//

import Foundation
import SpriteKit
import SwiftUI

/// Creates indirectly addressed CGFloat
///  ## Example Use:
///     let testPointer = PointerCGFloat(value: 10)
///     print(testPointer.value)
class PointerCGFloat {
  var value: CGFloat

  init(value: CGFloat) {
    self.value = value
  }
}

func indirectDouble(_ testPointer: PointerCGFloat) { //func will double addressed value
  testPointer.value += testPointer.value // Updating the value here changes the value on the original copy
}

/*
 +++ Example use cases
let testPointer = PointerCGFloat(value: 10)
print(testPointer.value) // prints 10
indirectDouble(testPointer) // passing testPointer variable to the function
print(testPointer.value) // prints 100
*/
