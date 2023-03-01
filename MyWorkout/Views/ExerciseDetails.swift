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
    @State private var showSetAlert = false
    @State private var expandDrop = false
    @State private var decimal = 0
    
    let timeArray = (0...300).filter { number -> Bool in
        return number % 10 == 0}
    let weightArray = [0, 5]
    
    
    var body: some View {
        NavigationStack{
            let rmWeight: Bool = appData.Workouts[workIndex].exercises[index].rmOrW
            let kgLb: String = (UserDefaults.standard.bool(forKey: "imperial") ? "lb" : "Kg")
            let kgLbPerc: String = appData.Workouts[workIndex].exercises[index].rmOrW ? "%" : kgLb
            
            List{
                let sets = appData.Workouts[workIndex].exercises[index].sets
                Section{
                    ForEach(Array(sets.enumerated()), id: \.element) { i, singleSet in
                        DisclosureGroup(
                            content: {
                                HStack{
                                    Picker("Numero di Serie", selection: $appData.Workouts[workIndex].exercises[index].sets[i].nSets){
                                        ForEach((1...20), id: \.self) {
                                                Text("\($0)")
                                            }
                                    }
                                    Text("x")
                                    Picker("Numero di Rep", selection: $appData.Workouts[workIndex].exercises[index].sets[i].reps){
                                        ForEach((1...50), id: \.self) {
                                                Text("\($0)")
                                            }
                                    }
                                    Picker("Peso per ogni Serie", selection: $appData.Workouts[workIndex].exercises[index].sets[i].weight){
                                        ForEach(0...200, id: \.self) {
                                            Text("\($0)").tag(Double($0))
                                        }
                                    }
                                    if !rmWeight{
                                        Text(",")
                                        Picker("Peso decimale per ogni Serie", selection: $decimal){
                                            ForEach(weightArray, id: \.self) {
                                                Text("\($0)").tag($0)
                                            }
                                        }
                                    }
                                    Text(kgLbPerc)
                                }
                                .pickerStyle(WheelPickerStyle())
                                Toggle("Set di Riscaldamento", isOn: $appData.Workouts[workIndex].exercises[index].sets[i].warm)
                            },
                            label:{
                                HStack{
                                    HStack{
                                        Text("\(singleSet.nSets) x \(singleSet.reps)")
                                            .foregroundColor(.black)
                                            .padding(4)
                                            .background(Rectangle().cornerRadius(5).foregroundColor(.accentColor))
                                        Spacer()
                                        if rmWeight{
                                            Text("\(singleSet.weight, specifier: "%.0f")")
                                        }
                                        else{
                                            Text("\(singleSet.weight, specifier: "%.1f")")
                                        }
                                        Text(kgLbPerc)
                                    }
                                }
                            }
                        )
                    }
                    .onDelete(perform: onDelete)
                    .onMove(perform: onMove)                    .onAppear(perform: {
                        appData.Workouts[workIndex].exercises[index].maxWeight = appData.Massimale(sets: sets)})
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
                    .font(.footnote)
                    .padding(.vertical, 7.0)
                }
                footer:{
                    if !appData.Workouts[workIndex].exercises[index].rmOrW{
                        Text("(1RM) Massimale Teorico: \(appData.Workouts[workIndex].exercises[index].maxWeight, specifier: "%.0f")\(kgLb)")
                    }
                }
                Section{
                    //MARK: - Peso Massimo
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
                    
                    //MARK: - Tempo di recupero
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
                    //MARK: - Dropset
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
                    //MARK: - Superset
                    Toggle("Superset", isOn: $appData.Workouts[workIndex].exercises[index].superset)
                }
                header:{
                    HStack{
                        Image(systemName: "gearshape.2.fill")
                        Text("Impostazioni")
                    }
                    .font(.title3)
                }
                .pickerStyle(WheelPickerStyle())
            }
            .navigationBarTitle(Text(appData.ReturnName(unkID: appData.Workouts[workIndex].exercises[index].exID)), displayMode: .inline)
             .environment(\.editMode, $editMode)
            .listStyle(.insetGrouped)
        }
    }
        
    func onAdd() {
        var prevReps = 10
        var prevWeight = 0.0
        let setsCount = appData.Workouts[workIndex].exercises[index].sets.count
        if setsCount > 1 {
            prevReps = appData.Workouts[workIndex].exercises[index].sets[setsCount-1].reps
            prevWeight = appData.Workouts[workIndex].exercises[index].sets[setsCount-1].weight
        }
        
        appData.Workouts[workIndex].exercises[index].sets.append(Set(id: "1-\(appData.Workouts[workIndex].exercises[index].sets.count)", nSets: 1, reps: prevReps, weight: prevWeight, warm: false))
        showSetAlert.toggle()
    }
    func onDelete(offsets: IndexSet) {
        for i in offsets{
            if i>=0{
                appData.Workouts[workIndex].exercises[index].sets.remove(atOffsets: offsets)
            }
        }
    }
    
    func onMove(source: IndexSet, destination: Int) {
        appData.Workouts[workIndex].exercises[index].sets.move(fromOffsets: source, toOffset: destination)
    }
    
}


struct ExerciseDetails_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseDetails(workIndex: 0, index: Binding.constant(0))
            .environmentObject(AppData())
    }
}
