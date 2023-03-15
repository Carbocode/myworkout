//
//  SingleSet.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 15/03/23.
//

import SwiftUI

struct SingleSet: View {
    @EnvironmentObject var appData : AppData
    
    var workIndex: Int
    var index: Int
    var i: Int
    
    @State private var nSets = 0
    @State private var reps = 0
    @State private var decimal = 0
    @State private var integer = 0
    
    let timeArray = (0...300).filter { number -> Bool in
        return number % 10 == 0}
    let weightArray = [0, 5]
    
    
    var body: some View {
        let sets = appData.Workouts[workIndex].exercises[index].sets
        
        //Perchantage, Kilograms or Libs
        let rmWeight: Bool = appData.Workouts[workIndex].exercises[index].rmOrW
        let kgLb: String = (UserDefaults.standard.bool(forKey: "imperial") ? "lb" : "Kg")
        let kgLbPerc: String = appData.Workouts[workIndex].exercises[index].rmOrW ? "%" : kgLb
        
        
        DisclosureGroup(
            content: {
                HStack{
                    //Sets Number
                    Picker("Numero di Serie", selection: $nSets){
                        ForEach((1...20), id: \.self) {
                                Text("\($0)")
                            }
                    }
                    Text("x")
                    //Reps Number
                    Picker("Numero di Rep", selection: $reps){
                        ForEach((1...50), id: \.self) {
                                Text("\($0)")
                            }
                    }
                    //Weight Number
                    Picker("Peso per ogni Serie", selection: $integer) {
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
                    let singleSet = appData.Workouts[workIndex].exercises[index].sets[i]
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
        .onAppear(){
            nSets = appData.Workouts[workIndex].exercises[index].sets[i].nSets
            reps = appData.Workouts[workIndex].exercises[index].sets[i].reps
            integer = Int(appData.Workouts[workIndex].exercises[index].sets[i].weight)
            decimal = Int(appData.Workouts[workIndex].exercises[index].sets[i].weight*10)%10
        }
        .onChange(of: decimal){ _ in
            onUpdate(sets: sets)
        }
        .onChange(of: integer){ _ in
            onUpdate(sets: sets)
        }
        .onChange(of: nSets){ _ in
            onUpdate(sets: sets)
        }
        .onChange(of: reps){ _ in
            onUpdate(sets: sets)
        }
    }
    
    func onUpdate(sets: [Set]) {
        appData.Workouts[workIndex].exercises[index].maxWeight = appData.Massimale(sets: sets)
        appData.Workouts[workIndex].exercises[index].sets[i].weight = Double(integer) + (Double(decimal)/10)
        appData.Workouts[workIndex].exercises[index].sets[i].nSets = nSets
        appData.Workouts[workIndex].exercises[index].sets[i].reps = reps
    }
}

struct SingleSet_Previews: PreviewProvider {
    static var previews: some View {
        SingleSet(workIndex: 0, index: 0, i: 0)
            .environmentObject(AppData())
    }
}
