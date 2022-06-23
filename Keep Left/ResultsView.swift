//
//  ResultsView.swift
//  Keep Left
//
//  Created by Bill Drayton on 24/4/2022.
//

import SwiftUI

struct ResultsView: View {
    var body: some View {
        SummaryView()
    }
}

struct SummaryView: View {

    var body: some View {
        VStack {
            Text("Keep Left")
                .font(.system(size: 17.0))
                .bold()
            Text("All Vehicles")
                .font(.system(size: 8.6))
                .bold()
            HStack {
                SummaryDescriptionView()
                SummaryResultsView()
            }
            .font(.system(size: 7.8))
        }
    }
}

struct SummaryDescriptionView: View {
    var body: some View {
        VStack(alignment: .trailing) {
            Text("Avg Speed")
                .bold()
                .foregroundColor(.black)
            Text("Max Speed")
            Text("Min Speed")
            Text("Avg Miles")
                .bold()
                .foregroundColor(.black)
            Text("Max Miles")
            Text("Min Miles")
        }
    }
}

struct SummaryResultsView: View {
    var body: some View {
        VStack (alignment: .leading) {
            Text("87 kph")
                .bold()
                .foregroundColor(.black)
            Text("110 kph")
            Text("36 kph")
            Text("325,248")
                .bold()
                .foregroundColor(.black)
            Text("478,414")
            Text("233,823")
        }
    }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView()
            .previewLayout(.sizeThatFits)
            .padding()

        ResultsView()
            .preferredColorScheme(.dark)    //View in Dark Mode
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
