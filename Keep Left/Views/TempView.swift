//
//  TempView.swift
//  Keep Left
//
//  Created by Bill Drayton on 21/6/2022.
//

import SwiftUI

struct TempView: View {
    @State var tapCount = 0

    var body: some View {
        VStack {
            Spacer()
            Button("Tap count: \(tapCount)") {
                tapCount += 1
            }
            Spacer()
            Button("Tap decrement: \(tapCount)") {
                tapCount -= 1
            }
            Spacer()
        }
    }
}

struct TempView_Previews: PreviewProvider {
    static var previews: some View {
        TempView()
    }
}
