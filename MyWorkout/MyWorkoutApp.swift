//
//  MyWorkoutApp.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 12/01/23.
//

import SwiftUI

@main
struct MyWorkoutApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appData = AppData()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appData)
        }
    }
    
    class AppDelegate : UIResponder, UIApplicationDelegate {
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            print("App Launched")
            return true
        }
    }
}
