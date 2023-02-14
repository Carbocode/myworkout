//
//  ExerciseDetails.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 13/01/23.
//

import SwiftUI

struct ExerciseDetails: View {
    @EnvironmentObject var appData : AppData
    
    var workIndex: Int
    var index: Int
    
    @State private var editMode = EditMode.inactive
    @State private var showSetAlert = false
    @State private var expandDrop = false
    let timeArray = (0...300).filter { number -> Bool in
        return number % 10 == 0}
    
    
    var body: some View {
        NavigationStack{
            List{
                let sets = appData.Workouts[workIndex].exercises[index].sets
                Section{
                    ForEach(Array(sets.enumerated()), id: \.element) { i, singleSet in
                        DisclosureGroup(
                            content: {
                                HStack{
                                    Picker("Numero di Serie", selection: $appData.Workouts[workIndex].exercises[index].sets[i].reps){
                                        ForEach((1...100), id: \.self) {
                                                Text("\($0)x")
                                            }
                                    }
                                    Picker("Peso per ogni Serie", selection: $appData.Workouts[workIndex].exercises[index].sets[i].weight){
                                        ForEach(0...100, id: \.self) {
                                                Text("\(Double($0), specifier: "%.2f")Kg")
                                            }
                                    }
                                }.pickerStyle(WheelPickerStyle())
                                
                            },
                            label:{
                                HStack{
                                    ZStack{
                                        Circle()
                                            .foregroundColor(.accentColor)
                                            .frame(width: 55)
                                        Text("\(singleSet.reps)x")
                                    }
                                    .font(.title3)
                                    .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Text("\(singleSet.weight, specifier: "%.2f")Kg").font(.title3)
                                }
                            }
                        )
                    }
                    .onDelete(perform: onDelete)
                    .onMove(perform: onMove)
                }
                header:{
                    Stepper(
                            onIncrement: {onAdd()},
                            onDecrement: {onDelete(offsets: IndexSet([sets.count-1]))}
                    ){
                        HStack{
                            HStack{
                                Image(systemName: "timer")
                                Text("Serie")
                            }
                            .font(.title2)
                            Spacer()
                            HStack{
                                EditButton()
                                    .foregroundColor(.white)
                                    .font(.caption)
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundColor(.white)
                            }
                            .padding(.all, 8.0)
                            .background(Capsule()
                                .foregroundColor(.blue)
                                .shadow(radius: 5))
                            Spacer()
                        }
                    }
                    .padding(.vertical, 7.0)
                }
                Section{
                    DisclosureGroup(
                        content: {
                            Picker("Numero di Set", selection: $appData.Workouts[workIndex].exercises[index].rest){
                                ForEach(timeArray, id: \.self) {
                                        Text("\($0)s")
                                    }
                            }
                            .pickerStyle(WheelPickerStyle())
                        },
                        label:{
                            HStack{
                                Text("Tempo di recupero")
                                Spacer()
                                if(appData.Workouts[workIndex].exercises[index].rest>0){
                                    Text("\(appData.Workouts[workIndex].exercises[index].rest)s").foregroundColor(.accentColor)
                                }
                                else{
                                    Text("NO").foregroundColor(.accentColor)
                                }
                            }
                        }
                    )
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
                                    Picker("Di quanto ridurre il peso", selection: $appData.Workouts[workIndex].exercises[index].dropWeight){
                                        ForEach(0...100, id: \.self) {
                                                Text("\(Double($0), specifier: "%.2f")Kg")
                                            }
                                    }
                                }
                                
                            }
                            .pickerStyle(WheelPickerStyle())
                        },
                        label: {
                            HStack{
                                Text("Dropset")
                                Spacer()
                                if (appData.Workouts[workIndex].exercises[index].dropSet>0){
                                    Text("Ogni \(appData.Workouts[workIndex].exercises[index].dropSet)").foregroundColor(.accentColor)
                                    if(appData.Workouts[workIndex].exercises[index].dropWeight>0){
                                        Text("-\(appData.Workouts[workIndex].exercises[index].dropWeight)Kg")
                                    }
                                }
                                else{
                                    Text("NO").foregroundColor(.accentColor)
                                }
                                
                            }
                        }
                    )
                    Toggle("Superset", isOn: $appData.Workouts[workIndex].exercises[index].superset)
                }
                header:{
                    HStack{
                        Image(systemName: "gearshape.2.fill")
                        Text("Impostazioni")
                    }
                    .font(.title2)
                }
            }
            .navigationBarTitle(Text(appData.ReturnName(unkID: appData.Workouts[workIndex].exercises[index].exID)), displayMode: .inline)
             .environment(\.editMode, $editMode)
            .listStyle(.insetGrouped)
        }
    }
        
    func onAdd() {
        appData.Workouts[workIndex].exercises[index].sets.append(Set(id: "1-\(appData.Workouts[workIndex].exercises[index].sets.count)", reps: 1, weight: 0))
        showSetAlert.toggle()
    }
    func onDelete(offsets: IndexSet) {
        appData.Workouts[workIndex].exercises[index].sets.remove(atOffsets: offsets)
    }
    func onMove(source: IndexSet, destination: Int) {
        appData.Workouts[workIndex].exercises[index].sets.move(fromOffsets: source, toOffset: destination)
    }
    
}


struct ExerciseDetails_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseDetails(workIndex: 0, index: 0)
            .environmentObject(AppData())
    }
}
