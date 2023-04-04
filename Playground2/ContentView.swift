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

    let headerMargin: CGFloat = 30

    var body: some View {
        ZStack {
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
            }

            if !hideMapSymbol {//}&& !overlayManager.isOverlayMode {
            GeometryReader{proxy -> AnyView in
                let height = proxy.frame(in: .global).height
                
                return AnyView(
                    VStack {
                        if (-offset < 30) {
                            HStack {
                                if (!hideMapSymbol) {
                                    Image(systemName: "map")
                                        .offset(x: -10, y: -60)
                                }
                                Spacer()
                            }
                            .padding(10)
                            .padding(.horizontal, 35)
                            .onTapGesture {
                                let maxHeight = height - headerMargin
                                offset = -(maxHeight * 0.48)
                                mapHeight = maxHeight * 0.48
                                lastOffset = offset
                            }
                        }
                        ZStack {
                            BlurView(style: .systemThinMaterialDark)
                                .clipShape(CustomCorner(corners: [.topLeft, .topRight], radius: 20))
                                .opacity(0.8)
                            
                            VStack (spacing:0) {
                                HStack {
                                    /*Button(action: {
                                                locationMgr.userSpan = nil
                                           }) {
                                               Image(systemName: "location")
                                                .padding(.horizontal, 8)
                                                .foregroundColor(white)
                                                .scaleEffect(1.3)
                                            }*/
                                    
                                    Button(action: {
                                        LocationManager.shared.resetView()
                                    }) {
                                        Image(systemName: "location")
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 8)
                                            .scaleEffect(1.5)
                                    }
                                    Button(action: {
                                        LocationManager.shared.restartTrip()
                                    }) {
                                        Image(systemName: "arrow.clockwise")
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 8)
                                            .scaleEffect(1.5)
                                    }
                                    Spacer()
                                    Capsule()
                                        //.fill(black)
                                        .frame(width: 60, height: 4)
                                        .padding()
                                    Spacer()
                            
                                    Button(action: {
                                        offset = 0
                                        lastOffset = 0
                                    }) {
                                        Image(systemName: "xmark.circle")
                                            .padding(.horizontal, 8)
                                            .foregroundColor(.white)
                                            .scaleEffect(1.5)
                                            .opacity(0)
                                    }
                                    Button(action: {
                                        offset = 0
                                        lastOffset = 0
                                    }) {
                                        Image(systemName: "xmark.circle")
                                            .padding(.horizontal, 8)
                                            .foregroundColor(.white)
                                            .scaleEffect(1.5)
                                    }
                                }
                                .padding(.top, 8)
                                .padding(.horizontal, 6)

                                MapView(isActiveRide: true)
                                    .environmentObject(locationMgr)
                                    .padding(.horizontal, 8)
                                    .padding(.top, 8)
                                    .frame(maxHeight: mapHeight)
                                    .alert(isPresented: $locationMgr.showAlertDetails) {
                                        Alert(
                                            title: Text(locationMgr.alertTitle),
                                            message: Text(locationMgr.alertMessage)
                                        )
                                    }
                            }
                            .frame(maxHeight: .infinity, alignment: .top)
                        }
                    }
                        .offset(y: height - headerMargin)
                        .offset(y: -offset > 0 ? -offset <= (height - headerMargin) ? offset : -(height - headerMargin) : 0)
                        .gesture(DragGesture()
                                    .updating($gestureOffset, body: { value, out, _ in
                                        out = value.translation.height
                                        updateOffset()
                                    })
                                    .onEnded({ value in
                                        let maxHeight = height - headerMargin
                                        withAnimation {
                                            if -offset > 100 && -offset < maxHeight / 2 {
                                                offset = -(maxHeight * 0.48)
                                                mapHeight = maxHeight * 0.48
                                                //locationMgr.setFullscreen(enable: false)
                                            }
                                            else if -offset > maxHeight / 2 {
                                                offset   = -maxHeight * 0.94
                                                mapHeight = maxHeight * 0.94
                                                //locationMgr.setFullscreen(enable: true)
                                            }
                                            else {
                                                offset = 0
                                            }
                                        }
                                        lastOffset = offset
                                    }
                                            )
                                ) // .gesture
                )
            } // GeometryReader
            .ignoresSafeArea(.all, edges: .bottom)
            } // if isOverlay
        } // ZStack
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
