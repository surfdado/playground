//
//  ContentView.swift
//  OnlineTuneCards
//
//  Created by Adin Ackerman on 4/14/23.
//

import SwiftUI

struct ContentView: View {
    @State var tunes: [TuneCardData] = []
    
    private let url = URL(string: "http://us-central1-mimetic-union-377520.cloudfunctions.net/float_package_tunes_via_http")!
    
    func update() async {
        let csv = try! await OnlineTuneCards.fetchCSV(from: url)
        withAnimation {
            tunes = OnlineTuneCards.tunesFromCSV(csv)
        }
    }
    
    var body: some View {
        NavigationView {
            List(tunes, id: \.self) { tune in
                NavigationLink(tune["_name"]!!) {
                    TuneCardDetailView(tunecard: tune)
                }
            }
            .refreshable {
                await update()
            }
            .task {
                await update()
            }
            .navigationTitle("Tune Cards")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
