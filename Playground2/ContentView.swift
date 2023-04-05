//
//  ContentView.swift
//  Playground2
//
//  Created by Davorin Mista on 12/23/21.
//

import SwiftUI

struct CustomCorner: Shape {
    var corners: UIRectCorner
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

/// BlurView: doesn't actually work as intended..
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return view
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
    }
}

struct ContentView3: View {
    @EnvironmentObject var locationMgr: LocationManager

    // Gesture properties
    @State var offset: CGFloat = 0
    @State var lastOffset: CGFloat = 0
    @GestureState var gestureOffset: CGFloat = 0
    @State var mapHeight: CGFloat = 200
    @State var stopRequested = false
    @State var hideMapSymbol = false

    @State private var detent: PresentationDetent?
    @State private var mapshown = false

    let headerMargin: CGFloat = 30

    var body: some View {
        let btncolor = Color(.systemOrange)
        
        VStack {
            Spacer()
            Text("Voltage: 60V")
                .bold()
                .scaleEffect(2)
                .padding(.horizontal, 70.0)
                .padding(.vertical, 20.0)
                .background(LinearGradient(gradient: Gradient(colors: [btncolor, btncolor.opacity(0.5), btncolor.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .cornerRadius(10)
            Spacer()
            Text("Speed: 12mph")
                .bold()
                .scaleEffect(2)
                .padding(.horizontal, 70.0)
                .padding(.vertical, 20.0)
                .background(LinearGradient(gradient: Gradient(colors: [btncolor, btncolor.opacity(0.5), btncolor.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .cornerRadius(10)
            Spacer()
            Text("Duty: 50%")
                .bold()
                .scaleEffect(2)
                .padding(.horizontal, 70.0)
                .padding(.vertical, 20.0)
                .background(LinearGradient(gradient: Gradient(colors: [btncolor, btncolor.opacity(0.5), btncolor.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .cornerRadius(10)
            Spacer()
            Text("Temps: 35C")
                .bold()
                .padding(.horizontal, 70.0)
                .padding(.vertical, 20.0)
                .scaleEffect(2)
                .background(LinearGradient(gradient: Gradient(colors: [btncolor, btncolor.opacity(0.5), btncolor.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .cornerRadius(10)
            Spacer()
            
            HStack {
                Button {
                    mapshown = true
                    detent = .medium
                } label: {
                    Image(systemName: "map")
                }
                .buttonStyle(.borderless)
                .padding()
                .scaleEffect(2)
                
                Spacer()
            }
        }
        .sheet(isPresented: $mapshown) {
            MapView(isActiveRide: true)
                .environmentObject(locationMgr)
                .padding(.horizontal, 8)
                .padding(.top, 20)
                .alert(isPresented: $locationMgr.showAlertDetails) {
                    Alert(
                        title: Text(locationMgr.alertTitle),
                        message: Text(locationMgr.alertMessage)
                    )
                }
        }
        .presentationDetents([.large, .medium])
        .presentationDragIndicator(.visible)
        //.edgeAttachedInCompactHeight(true)
    }
    func updateOffset() {
        DispatchQueue.main.async {
            self.offset = gestureOffset + lastOffset
        }
    }
}

struct ContentView3_Previews: PreviewProvider {
    static var previews: some View {
        ContentView3()
            .environmentObject(LocationManager.shared)
    }
}
