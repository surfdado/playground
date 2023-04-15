//
//  Playground2App.swift
//  Playground2
//
//  Created by Davorin Mista on 12/23/21.
//

import SwiftUI

@main
struct Playground2App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(LocationManager.shared)
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            if error != nil {
                print(error?.localizedDescription ?? "No error for authorization permission")
            }
        }
        let locationManager = LocationManager.shared.cll
        if (locationManager.authorizationStatus == .notDetermined) {
            locationManager.requestAlwaysAuthorization()
        }
        return true
    }
}
