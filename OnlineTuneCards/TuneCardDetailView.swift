//
//  TuneCardDetailView.swift
//  OnlineTuneCards
//
//  Created by Adin Ackerman on 4/14/23.
//

import SwiftUI

struct TuneCardDetailView: View {
    let tunecard: TuneCardData
    
    var body: some View {
        List(tunecard.keys.sorted(), id: \.self) { field in
            HStack {
                Text(field)
                Spacer()
                if let value = tunecard[field]! {
                    Text("\(value)")
                } else {
                    Text("-")
                }
            }
        }
    }
}
