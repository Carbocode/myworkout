//
//  ExerciseDetails.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 13/01/23.
//

import SwiftUI

struct ExerciseDetails: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appData : AppData
    
    var workIndex: Int
    @Binding var index: Int
    
    @State private var editMode = EditMode.inactive
    @State private var expandDrop = false
    @State private var decimal = 0
    
    let timeArray = (0...300).filter { number -> Bool in
        return number % 10 == 0}
    let weightArray = [0, 5]
    
    
    var body: some View {
        //Show perchantage, Kilograms or Librs
        let kgLb: String = (UserDefaults.standard.bool(forKey: "imperial") ? "lb" : "Kg")
        let kgLbPerc: String = appData.Workouts[workIndex].exercises[index].rmOrW ? "%" : kgLb
        
        NavigationStack{
            List{
                //MARK: - SETS
                Sets(workIndex: workIndex, index: index, editMode: $editMode)
                    .listRowSeparatorTint(.gray)
                    .listRowBackground(Color.darkEnd)
                
                //MARK: - Settings
                Section{
                    //MARK: Peso Massimo
                    Toggle("Usa %-1RM", isOn: $appData.Workouts[workIndex].exercises[index].rmOrW)
                    if appData.Workouts[workIndex].exercises[index].rmOrW {
                        DisclosureGroup(
                            content: {
                                HStack{
                                    Picker("Peso per ogni Serie", selection: $appData.Workouts[workIndex].exercises[index].maxWeight){
                                        ForEach(0...200, id: \.self) {
                                            Text("\($0)").tag(Double($0))
                                        }
                                    }
                                    Text(",")
                                    Picker("Peso decimale per ogni Serie", selection: $decimal){
                                        ForEach(weightArray, id: \.self) {
                                            Text("\($0)").tag($0)
                                        }
                                    }
                                    Text(kgLb)
                                }
                            },
                            label:{
                                HStack{
                                    Text("1RM")
                                    Spacer()
                                    Text("\(appData.Workouts[workIndex].exercises[index].maxWeight, specifier: "%.1f")\(kgLb)")
                                }
                            }
                        )
                    }
                    
                    //MARK: Tempo di recupero
                    DisclosureGroup(
                        content: {
                            Picker("Tempo di Recupero", selection: $appData.Workouts[workIndex].exercises[index].rest){
                                ForEach(timeArray, id: \.self) {
                                    Text("\($0)s")
                                }
                            }
                        },
                        label:{
                            HStack{
                                Text("Tempo di Recupero")
                                Spacer()
                                if(appData.Workouts[workIndex].exercises[index].rest>0){
                                    Text("\(appData.Workouts[workIndex].exercises[index].rest)s")
                                        .foregroundColor(.accentColor)
                                        .fontWeight(.bold)
                                }
                                else{
                                    Text("NO")
                                        .foregroundColor(.accentColor)
                                        .fontWeight(.bold)
                                }
                            }
                        }
                    )
                    //MARK: Dropset
                    DisclosureGroup(
                        content: {
                            HStack{
                                Picker("Ogni quanto ridurre il peso", selection: $appData.Workouts[workIndex].exercises[index].dropSet){
                                    Text("NO").tag(0)
                                    ForEach(1...25, id: \.self) {
                                        Text("\($0)")
                                        }
                                }
                                if(appData.Workouts[workIndex].exercises[index].dropSet>0){
                                    Text("-")
                                    Picker("Di quanto ridurre il peso", selection: $appData.Workouts[workIndex].exercises[index].dropWeight){
                                        ForEach(0...100, id: \.self) {
                                                Text("\($0)").tag(Double($0))
                                            }
                                    }
                                    Text(kgLbPerc)

                                }
                                
                            }
                        },
                        label: {
                            HStack{
                                Text("Dropset").foregroundColor(.primary).fontWeight(.none)
                                Spacer()
                                if (appData.Workouts[workIndex].exercises[index].dropSet>0){
                                    Text("Ogni \(appData.Workouts[workIndex].exercises[index].dropSet)")
                                    if(appData.Workouts[workIndex].exercises[index].dropWeight>0){
                                        Text("-\(appData.Workouts[workIndex].exercises[index].dropWeight, specifier: "%.0f")")
                                        Text(kgLbPerc)
                                            
                                    }
                                }
                                else{
                                    Text("NO")
                                }
                                
                            }.foregroundColor(.accentColor).fontWeight(.bold)
                        }
                    )
                    //MARK: Superset
                    Toggle("Superset", isOn: $appData.Workouts[workIndex].exercises[index].superset)
                }
                header:{
                    HStack{
                        Image(systemName: "list.bullet.rectangle.portrait.fill")
                        Text("Impostazioni")
                    }
                    .font(.title3)
                }
                .listRowSeparatorTint(.gray)
                .listRowBackground(Color.darkEnd)
                
                //MARK: - WARMING Sets
                WarmingSets(workIndex: workIndex, index: index, editMode: $editMode)
                    .listRowSeparatorTint(.gray)
                    .listRowBackground(Color.darkEnd)
            }
            .background(LinearGradient(Color.darkStart, Color.darkEnd))
            .scrollContentBackground(.hidden)
            .shadow(color: Color.darkEnd.opacity(0.7), radius: 10, x: 10, y: 10)
            .shadow(color: Color.darkStart.opacity(1), radius: 10, x: -5, y: -5)
            .navigationBarTitle(Text(appData.ReturnName(unkID: appData.Workouts[workIndex].exercises[index].exID)), displayMode: .inline)
             .environment(\.editMode, $editMode)
             .pickerStyle(WheelPickerStyle())
            .listStyle(.insetGrouped)
        }
        .foregroundColor(.primary)
        .preferredColorScheme(.dark)
    }
    
}


struct ExerciseDetails_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseDetails(workIndex: 0, index: Binding.constant(0))
            .environmentObject(AppData())
    }
}
