//
//  AppData.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 14/02/23.
//

import SwiftUI

class AppData: ObservableObject {
    var debug = true
    
    @Published var Workouts : [Workout]
    @Published var Exlist : [ExList]
    var workoutPath : URL
    var exlistPath : URL
    
    init(){
        let id = UUID()
        Exlist = [ExList(id: id, name: "Random Ex", topWeight: 0.0), ExList(id: UUID(), name: "Random Ex 2", topWeight: 0.0), ExList(id: UUID(), name: "Random Ex 3", topWeight: 0.0)]
        
        let singleSet = Set(id: UUID(), nSets: 3, reps: 10, weight: 0.0)
        let exercises = Exercise(id: UUID(), exID: id, maxWeight: 0.0, rmOrW: false, rest: 90, dropSet: 0, dropWeight: 0.0, warmingSets: [singleSet], sets: [singleSet], superset: false)
        Workouts = [Workout(id: UUID(), name: "Default Workout", exercises: [exercises])]
        
        
        workoutPath = Bundle.load("ex6")
        exlistPath = Bundle.load("workout6")
        
        Workouts = Bundle.main.decode([Workout].self, from: workoutPath)
        Exlist = Bundle.main.decode([ExList].self, from: exlistPath)
    }
    
    func SaveWorkouts(){
        try? JSONEncoder().encode(Workouts).write(to: workoutPath, options: .atomic)
        print("Workout saved")
    }
    
    func SaveSettings(){
        try? JSONEncoder().encode(Exlist).write(to: exlistPath, options: .atomic)
        print("Settings saved")
    }
    
    
    func ReturnName(unkID: UUID) -> String{
        for ex in Exlist{
            if(ex.id==unkID){
                return ex.name
            }
        }
        return "Unknown"
    }
    
    func DeleteExFromWorkout(exID: UUID){
        var i = 0
        for workout in Workouts {
            var j = 0
            for ex in workout.exercises{
                if(ex.exID==exID){
                    Workouts[i].exercises.remove(at: j)
                }
                j+=1
            }
            i+=1
        }
    }
    
    func AddExToWorkout(exIDs: Swift.Set<UUID>, index: Int){
        
        for exID in exIDs {
            Workouts[index].exercises.append(
                Exercise(
                    id: UUID(),
                    exID: exID,
                    maxWeight: 0.0,
                    rmOrW: false,
                    rest: UserDefaults.standard.integer(forKey: "defaultRest"),
                    dropSet: 0,
                    dropWeight: 0.0,
                    warmingSets: [],
                    sets: [
                        Set(id: UUID(), nSets: 3, reps: 10, weight: 0.0),
                    ],
                    superset: false)
            )
        }
    }
    
    func DupEx(workIndex: Int, index: Int){
        Workouts[workIndex].exercises.append(Workouts[workIndex].exercises[index])
        Workouts[workIndex].exercises[Workouts[workIndex].exercises.count-1].id = UUID()
    }
    
    func DupWork(index: Int){
        Workouts.append(Workouts[index])
        Workouts[Workouts.count-1].id = UUID()
    }
    
    func SwitchEx(workIndex: Int, index: Int, newId: UUID) {
        Workouts[workIndex].exercises[index].exID=newId
    }
    
    func Massimale(sets: [Set]) -> Double {
        var massimale: Double = 0.0
        
        for singleSet in sets {
            let bufferMax = (singleSet.weight / (1.0278 - (0.0278 * Double(singleSet.reps)))).rounded() //Equazione di Brzycky
            if bufferMax > massimale {
                massimale = bufferMax
            }
        }
        
        return massimale
    }
}

