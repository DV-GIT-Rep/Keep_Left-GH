//
//  RandomExp.swift
//  Keep Left
//
//  Created by Bill Drayton on 7/6/2024.
//

import Foundation
import SpriteKit
import SwiftUI

//Example usage for both 'randomValue' & 'testRun':
// testRun(distribution: -1, min: 500, max: 2000)      //Test code: I/P = 0-1
// print(randomValue(distribution: -1, min: 650, max: 8000).dp2)      //Test code: I/P = 0-1

/// Generates a Random Number between 'min' & 'max'
/// - Parameters:
///   - distribution: Value between -1 & +1. -1 has distribution skewed to low end, +1 skews distribution to high end & 0 gives flat distribution, default = 0
///   - min: Low end of Random range, default = 0
///   - max: High end of Random range, default = 1
/// - Returns: Random value between 'min' & 'max'
/// - to test distribution, use 'testRun(distribution: _, min: _, max: _)'
func randomValue(distribution d: CGFloat = 0, min: CGFloat = 0, max: CGFloat = 1) -> CGFloat {
    assert((-1.2...1.2).contains(d), "\n\nERROR: distribution in 'randomValue' MUST be in range -1.2 to +1.2!")         //Error if d not in range
    let u = CGFloat.random(in: 0...1)

    // k ranges from 0 to 2
    let k = d * 2
    var result01: CGFloat

    if k == 0 {
        result01 = u
    } else {
        result01 = (sqrt(k*k + k*(8*u - 4) + 4) + k - 2)/(2*k)
    }
    return result01 * (max - min) + min      //Full result reads: result01 * ((max - min) ➗ (1-0)) + min
}
//see https://stackoverflow.com/questions/75661798/function-to-change-random-distribution-in-swift by Rob Napier re above (restricted to distribution = 0 to +1. Min/Max always 0/1)

//Example usage for both 'randomValue' & 'testRun':
// testRun(distribution: -1, min: 500, max: 2000)      //Test code: I/P = 0-1
// print(randomValue(distribution: -1, min: 650, max: 8000).dp2)      //Test code: I/P = 0-1

/// Generates 10,000 Random Numbers & returns the distribution - for testing only!
/// - Parameters:
///   - d: Value between -1 & +1. -1 skews distribution to low end, +1 skews distribution to high end & 0 gives flat distribution
/// - Returns: Random Number between 'min' & 'max'
func testRun(distribution d: CGFloat) {
    print("Distribution for \(d)")
    let n = 10_000

    // How many results begin with a given digit after the decimal point?
    var h: [Substring:Int] = [:]
    for _ in 0..<n {
        let value = randomValue(distribution: d, min: 0, max: 1)
        let firstDigit = "\(value)".prefix(3).suffix(1)
        h[firstDigit, default: 0] += 1
    }

    for digit in h.keys.sorted() {
        let ratio = Double(h[digit]!)/Double(n)
        print("\(digit) -> \(ratio.formatted(.percent.precision(.fractionLength(2))))")
    }
}

/*
eg.
testRun(distribution: 0)
testRun(distribution: 0.5)
testRun(distribution: -0.5)
testRun(distribution: 1)
testRun(distribution: -1)

===>
Distribution for 0.0
0 -> 10%
1 -> 10%
2 -> 10%
3 -> 11%
4 -> 10%
5 -> 10%
6 -> 10%
7 -> 10%
8 -> 10%
9 -> 10%
Distribution for +0.5           Distribution for -0.5
0 -> 6%                         0 -> 14%
1 -> 6%                         1 -> 13%
2 -> 7%                         2 -> 13%
3 -> 9%                         3 -> 11%
4 -> 10%                        4 -> 11%
5 -> 11%                        5 -> 10%
6 -> 11%                        6 -> 9%
7 -> 13%                        7 -> 7%
8 -> 13%                        8 -> 6%
9 -> 14%                        9 -> 6%
Distribution for +1.0           Distribution for -1.0
0 -> 1%                         0 -> 19%
1 -> 3%                         0 -> 17%
2 -> 5%                         0 -> 15%
3 -> 7%                         0 -> 13%
4 -> 9%                         0 -> 11%
5 -> 11%                        0 -> 9%
6 -> 13%                        0 -> 7%
7 -> 15%                        0 -> 5%
8 -> 17%                        0 -> 3%
9 -> 19%                        0 -> 1%
 
NOTE: Extending min/max beyond -1/+1 will skew distribution even further (requires modifying/deleting 'assert')
eg.
 Distribution for +1.2          Distribution for +1.25         Distribution for +1.5          Distribution for -2.5
 0 -> 0%                        0 -> 0%                        0 -> 0%                        0 -> 33%
 1 -> 1%                        1 -> 0%                        1 -> 0%                        1 -> 27%
 2 -> 4%                        2 -> 4%                        2 -> 0%                        2 -> 23%
 3 -> 6%                        3 -> 6%                        3 -> 4%                        3 -> 17%
 4 -> 9%                        4 -> 9%                        4 -> 8%                        4 -> 0%
 5 -> 11%                       5 -> 11%                       5 -> 12%                       5 -> 0%
 6 -> 13%                       6 -> 14%                       6 -> 14%                       6 -> 0%
 7 -> 16%                       7 -> 17%                       7 -> 17%                       7 -> 0%
 8 -> 19%                       8 -> 20%                       8 -> 21%                       8 -> 0%
 9 -> 21%                       9 -> 21%                       9 -> 24%                       9 -> 0%
 
*/
