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
                .tabItem{
                    Label("Home", systemImage: "house")
                }
            StandAloneTimer()
                .tabItem{
                    Label("Timer", systemImage: "timer")
                }
            SettingsDetails()
                .tabItem{
                    Label("Impostazioni", systemImage: "gear")
                }
        }
        .foregroundColor(.primary)
        .preferredColorScheme(.dark)
        .tint(.accentColor)
        .lineLimit(/*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
        
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(AppData())
    }
}
