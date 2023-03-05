//
//  WarmingSets.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 01/03/23.
//

import SwiftUI

struct WarmingSets: View {
    @EnvironmentObject var appData : AppData
    
    var workIndex: Int
    var index: Int
    @Binding var editMode: EditMode
    
    @State private var decimal = 0
    
    let timeArray = (0...300).filter { number -> Bool in
        return number % 10 == 0}
    let weightArray = [0, 5]
    
    var body: some View {
        let rmWeight: Bool = appData.Workouts[workIndex].exercises[index].rmOrW
        let kgLb: String = (UserDefaults.standard.bool(forKey: "imperial") ? "lb" : "Kg")
        let kgLbPerc: String = appData.Workouts[workIndex].exercises[index].rmOrW ? "%" : kgLb
        
        let warmingSets = appData.Workouts[workIndex].exercises[index].warmingSets
        Section{
            ForEach(Array(warmingSets.enumerated()), id: \.element) { i, singleSet in
                DisclosureGroup(
                    content: {
                        HStack{
                            Picker("Numero di Serie", selection: $appData.Workouts[workIndex].exercises[index].warmingSets[i].nSets){
                                ForEach((1...20), id: \.self) {
                                        Text("\($0)")
                                    }
                            }
                            Text("x")
                            Picker("Numero di Rep", selection: $appData.Workouts[workIndex].exercises[index].warmingSets[i].reps){
                                ForEach((1...50), id: \.self) {
                                        Text("\($0)")
                                    }
                            }
                            Picker("Peso per ogni Serie", selection: $appData.Workouts[workIndex].exercises[index].warmingSets[i].weight){
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
            .onDelete(perform: onWarmDelete)
            .onMove(perform: onWarmMove)
        }
        header:{
            Stepper(
                    onIncrement: {onWarmAdd()},
                    onDecrement: {onWarmDelete(offsets: IndexSet([warmingSets.count-1]))}
            ){
                HStack{
                    HStack{
                        Image(systemName: "flame.fill")
                        Text("Riscaldo")
                    }
                    .font(.title2)
                    Spacer()
                    EditButton(editMode: $editMode)
                    Spacer()
                }
            }
            .font(.footnote)
            .padding(.vertical, 7.0)
        }
    }
    
    func onWarmAdd() {
        var prevReps = 10
        var prevWeight = 0.0
        let setsCount = appData.Workouts[workIndex].exercises[index].warmingSets.count
        if setsCount > 1 {
            prevReps = appData.Workouts[workIndex].exercises[index].warmingSets[setsCount-1].reps
            prevWeight = appData.Workouts[workIndex].exercises[index].warmingSets[setsCount-1].weight
        }
        
        appData.Workouts[workIndex].exercises[index].warmingSets.append(Set(id: "1-\(appData.Workouts[workIndex].exercises[index].warmingSets.count)", nSets: 1, reps: prevReps, weight: prevWeight))
    }
    
    func onWarmDelete(offsets: IndexSet) {
        for i in offsets{
            if i>=0{
                appData.Workouts[workIndex].exercises[index].warmingSets.remove(atOffsets: offsets)
            }
        }
    }
    
    func onWarmMove(source: IndexSet, destination: Int) {
        appData.Workouts[workIndex].exercises[index].warmingSets.move(fromOffsets: source, toOffset: destination)
    }
}

struct WarmingSets_Previews: PreviewProvider {
    static var previews: some View {
        WarmingSets(workIndex: 0, index: 0, editMode: .constant(EditMode.active))
            .environmentObject(AppData())
    }
}
