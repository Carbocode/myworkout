//
//  Sets.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 01/03/23.
//

import SwiftUI
import UIKit

struct Sets: View {
    
    @EnvironmentObject var appData : AppData
    
    var workIndex: Int
    var index: Int
    @Binding var editMode: EditMode
    
    @State private var decimal = 0
    
    let timeArray = (0...300).filter { number -> Bool in
        return number % 10 == 0}
    let weightArray = [0, 5]
    
    var body: some View {
        //Perchantage, Kilograms or Libs
        let rmWeight: Bool = appData.Workouts[workIndex].exercises[index].rmOrW
        let kgLb: String = (UserDefaults.standard.bool(forKey: "imperial") ? "lb" : "Kg")
        let kgLbPerc: String = appData.Workouts[workIndex].exercises[index].rmOrW ? "%" : kgLb
        
        //Sets
        let sets = appData.Workouts[workIndex].exercises[index].sets
        Section{
            ForEach(Array(sets.enumerated()), id: \.element) { i, singleSet in
                //MARK: - SET
                DisclosureGroup(
                    content: {
                        HStack{
                            //Sets Number
                            Picker("Numero di Serie", selection: $appData.Workouts[workIndex].exercises[index].sets[i].nSets){
                                ForEach((1...20), id: \.self) {
                                        Text("\($0)")
                                    }
                            }
                            Text("x")
                            //Reps Number
                            Picker("Numero di Rep", selection: $appData.Workouts[workIndex].exercises[index].sets[i].reps){
                                ForEach((1...50), id: \.self) {
                                        Text("\($0)")
                                    }
                            }
                            //Weight Number
                            Picker("Peso per ogni Serie", selection: $appData.Workouts[workIndex].exercises[index].sets[i].weight){
                                ForEach(0...200, id: \.self) {
                                    Text("\($0)").tag(Double($0))
                                }
                            }
                            if !rmWeight{
                                Text(",")
                                //Decimal Weight
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
                        VStack(alignment: .leading){
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
                            if appData.debug {
                                Text(singleSet.id.uuidString).font(.caption2).foregroundColor(.primary)
                            }
                        }
                    }
                )
            }
            .onDelete(perform: onDelete)
            .onMove(perform: onMove)
            //TODO: Improve 1RM calc
            .onAppear(perform: {
                appData.Workouts[workIndex].exercises[index].maxWeight = appData.Massimale(sets: sets)})
        }
        header:{
            HStack{
                HStack{
                    Image(systemName: "timer")
                    Text("Serie")
                }
                .font(.title2)
                Spacer()
                EditButton(editMode: $editMode)
                Spacer()
                
                Stepper("",
                        onIncrement: {onCreate()},
                        onDecrement: {onDelete(offsets: IndexSet([sets.count-1]))}
                )
                .cornerRadius(8)
                .frame(width: 100, height: 35)
                .offset(x: -4)
                .shadow(color: Color.darkEnd.opacity(0.7), radius: 10, x: 10, y: 10)
                .shadow(color: Color.darkStart.opacity(1), radius: 10, x: -5, y: -5)
                
            }
            .padding(.vertical, 7.0)
            .font(.footnote)
            
        }
        footer:{
            if !appData.Workouts[workIndex].exercises[index].rmOrW{
                Text("(1RM) Massimale Teorico: \(appData.Workouts[workIndex].exercises[index].maxWeight, specifier: "%.0f")±1\(kgLb)")
            }
        }
    }
    
    //Create
    func onCreate() {
        var prevReps = 10
        var prevWeight = 0.0
        let setsCount = appData.Workouts[workIndex].exercises[index].sets.count
        
        //Copy the settings from previous Set
        if setsCount > 1 {
            prevReps = appData.Workouts[workIndex].exercises[index].sets[setsCount-1].reps
            prevWeight = appData.Workouts[workIndex].exercises[index].sets[setsCount-1].weight
        }
        
        appData.Workouts[workIndex].exercises[index].sets.append(Set(id: UUID(), nSets: 1, reps: prevReps, weight: prevWeight))
    }
    
    //Delete
    func onDelete(offsets: IndexSet) {
        for i in offsets{
            if i>=0{
                appData.Workouts[workIndex].exercises[index].sets.remove(atOffsets: offsets)
            }
        }
    }
    
    //Move
    func onMove(source: IndexSet, destination: Int) {
        appData.Workouts[workIndex].exercises[index].sets.move(fromOffsets: source, toOffset: destination)
    }
}

struct Sets_Previews: PreviewProvider {
    static var previews: some View {
        Sets(workIndex: 0, index: 0, editMode: .constant(EditMode.active))
            .environmentObject(AppData())
    }
}
