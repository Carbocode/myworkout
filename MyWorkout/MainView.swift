//
//  MainView.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 23/01/23.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var appData : AppData
    
    var body: some View {
        TabView {
            ContentView()
                .environmentObject(appData)
                .tabItem{
                    Label("Home", systemImage: "house")
                }
            SettingsDetails()
                .environmentObject(appData)
                .tabItem{
                    Label("Impostazioni", systemImage: "gear")
                }
        }
        .foregroundColor(.primary)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(AppData())
    }
}
