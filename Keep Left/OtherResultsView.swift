//
//  OtherResultsView.swift
//  Keep Left
//
//  Created by Bill Drayton on 3/6/2022.
//

import SwiftUI

struct OtherResultsView: View {
    var body: some View {
        OtherSummaryView()
    }
}

struct OtherSummaryView: View {

    var body: some View {
        VStack {
            Text("Other")
                .font(.system(size: 17.0))
                .bold()
            Text("All Vehicles")
                .font(.system(size: 8.6))
                .bold()
            HStack {
                OtherSummaryDescriptionView()
                OtherSummaryResultsView()
            }
            .font(.system(size: 7.8))
        }
    }
}

struct OtherSummaryDescriptionView: View {
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

struct OtherSummaryResultsView: View {
    var body: some View {
        VStack (alignment: .leading) {
            Text("84 kph")
                .bold()
                .foregroundColor(.black)
            Text("110 kph")
            Text("31 kph")
            Text("318,624")
                .bold()
                .foregroundColor(.black)
            Text("473,379")
            Text("231,593")
        }
    }
}

struct OtherResultsView_Previews: PreviewProvider {
    static var previews: some View {
        OtherResultsView()
            .previewLayout(.sizeThatFits)
            .padding()

        OtherResultsView()
            .preferredColorScheme(.dark)    //View in Dark Mode
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
