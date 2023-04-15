//
//  ContentView.swift
//  Playground2
//
//  Created by Davorin Mista on 12/23/21.
//

import SwiftUI

struct ContentView: View {
    @State private var showRideView = false
    @State private var showDownloads = false

    var body: some View {
        //let bgcolor: Color = colorScheme == .dark ? Color.black : Color.white
        let headercolor: Color = Color(.systemGray)
        NavigationView {
            VStack (spacing: 10) {
                Text("Title")
                
                Text("Connect")
                    .onTapGesture {
                        showRideView = true
                    }
                
                Spacer()

                Text("Bla bla")

                HStack {
                    Button {
                        showDownloads = true
                    } label: {
                        Text("Download Presets")
                    }
                    .buttonStyle(.borderless)
                    .padding()
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle(Text(""))
            .navigationBarHidden(true)
            .background(
                NavigationLink(destination:  RideView(), isActive: $showRideView) {
                    EmptyView()
                }
                    .hidden()
            )
            .sheet(isPresented: $showDownloads) {
                InternetPresetsView()
            }
        }.navigationBarTitle(Text(""))
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarHidden(true)
    }
}


