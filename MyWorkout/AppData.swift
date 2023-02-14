//
//  AppData.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 14/02/23.
//

import SwiftUI

class AppData: ObservableObject {
    @Published var Workouts : [Workout]
    @Published var SettingsData : Settings
    
    init(){
        Workouts = Bundle.main.decode([Workout].self, from: "workouts.json")
        SettingsData = Bundle.main.decode(Settings.self, from: "settings.json")
    }
    
    func ReturnName(unkID: String) -> String{
        for weight in SettingsData.weights{
            if(weight.id==unkID){
                return weight.name
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
                    rest: SettingsData.defaultREST,
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

