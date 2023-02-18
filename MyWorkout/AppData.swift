//
//  AppData.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 14/02/23.
//

import SwiftUI

class AppData: ObservableObject {
    
    @Published var Workouts : [Workout]
    @Published var Exlist : [ExList]
    var workoutPath : URL
    var exlistPath : URL
    
    init(){
        workoutPath = Bundle.load("workouts")
        exlistPath = Bundle.load("exercises")
        
        Workouts = Bundle.main.decode([Workout].self, from: workoutPath)
        Exlist = Bundle.main.decode([ExList].self, from: exlistPath)
    }
    
    func SaveWorkouts(){
        try? JSONEncoder().encode(Workouts).write(to: workoutPath, options: .atomic)
    }
    
    func SaveSettings(){
        try? JSONEncoder().encode(Exlist).write(to: exlistPath, options: .atomic)
    }
    
    
    func ReturnName(unkID: String) -> String{
        for ex in Exlist{
            if(ex.id==unkID){
                return ex.name
            }
        }
        return "Unknown"
    }
    
    func DeleteExFromWorkout(exID: String){
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
    
    func AddExToWorkout(exIDs: Swift.Set<String>, index: Int){
        
        for exID in exIDs {
            Workouts[index].exercises.append(
                Exercise(
                    id: "2-\(Workouts[index].exercises.count)",
                    exID: exID,
                    rest: UserDefaults.standard.integer(forKey: "defaultRest"),
                    dropSet: 0,
                    dropWeight: 0.0,
                    sets: [
                        Set(id: "1-0", reps: 10, weight: 0.0),
                        Set(id: "1-1", reps: 10, weight: 0.0),
                        Set(id: "1-2", reps: 10, weight: 0.0)
                    ],
                    superset: false)
            )
        }
    }
}

