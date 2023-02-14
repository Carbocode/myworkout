//
//  MyWorkoutApp.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 12/01/23.
//

import SwiftUI

@main
struct MyWorkoutApp: App {
    @StateObject private var appData = AppData()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appData)
        }
    }
}
