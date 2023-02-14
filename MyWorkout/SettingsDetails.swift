//
//  SettingsDetails.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 23/01/23.
//

import SwiftUI

struct SettingsDetails: View {
    @EnvironmentObject var appData : AppData
    
    let timeArray = (0...300).filter { number -> Bool in
        return number % 10 == 0}
    
    var body: some View {
        NavigationStack{
            List{
                Toggle("Recupero di fine esercizio", isOn: $appData.SettingsData.lastREST)
                DisclosureGroup(
                    content:{
                        Picker("Tempo default di Recupero", selection: $appData.SettingsData.defaultREST){
                            ForEach(timeArray, id: \.self) {
                                    Text("\($0)s")
                                }
                        }
                        .pickerStyle(WheelPickerStyle())},
                    label: {
                        HStack{Text("Tempo recupero di Default"); Spacer();Text("\(appData.SettingsData.defaultREST)s").foregroundColor(.accentColor)}
                    }
                )
                    
                
                NavigationLink{
                    ExerciseList(isSelecting: false)
                }label: {
                    Text("Tutti gli Esercizi")
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Impostazioni")
        }
        
    }
}

struct SettingsDetails_Previews: PreviewProvider {
    static var previews: some View {
        SettingsDetails()
            .environmentObject(AppData())
    }
}
