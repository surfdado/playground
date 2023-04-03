//
//  ContentView.swift
//  Playground2
//
//  Created by Davorin Mista on 12/23/21.
//

import SwiftUI

struct ContentView3: View {
    var body: some View {
        ZStack{
            
            MapView(isActiveRide: true)
                .environmentObject(LocationManager.shared)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Button(action: {
                        LocationManager.shared.resetView()
                    }) {
                        Image(systemName: "location")
                            .padding(.horizontal, 8)
                            .scaleEffect(2)
                    }
                    Spacer()
                    Button(action: {
                        LocationManager.shared.restartTrip()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .padding(.horizontal, 8)
                            .scaleEffect(2)
                    }
                }
                .padding()
                
                Spacer()
            }
        }
    }
}

struct ContentView3_Previews: PreviewProvider {
    static var previews: some View {
        ContentView3()
    }
}
