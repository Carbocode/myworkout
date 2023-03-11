//
//  AppData.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 14/02/23.
//

import SwiftUI

struct VisualSet : Hashable, Identifiable {
    let id: UUID = UUID()
    var nSets: Int
    var text: String
    var color = Color(.gray)
}

class AppData: ObservableObject {
    var debug = false //set Debug Mode
    
    @Published var Workouts : [Workout] //Object for all the Workouts
    @Published var Exlist : [ExList] //Object for all the Exercises
    
    //Path to JSON
    var workoutPath : URL
    var exlistPath : URL
    
    init(){
        /*
        let id = UUID()
        Exlist = [ExList(id: id, name: "Random Ex", topWeight: 0.0), ExList(id: UUID(), name: "Random Ex 2", topWeight: 0.0), ExList(id: UUID(), name: "Random Ex 3", topWeight: 0.0)]
        
        let singleSet = Set(id: UUID(), nSets: 3, reps: 10, weight: 0.0)
        let exercises = Exercise(id: UUID(), exID: id, maxWeight: 0.0, rmOrW: false, rest: 90, dropSet: 0, dropWeight: 0.0, warmingSets: [singleSet], sets: [singleSet], superset: false)
        Workouts = [Workout(id: UUID(), name: "Default Workout", exercises: [exercises])]
        */
        
        //Load the Path
        workoutPath = Bundle.load("workout8")
        exlistPath = Bundle.load("ex8")
        
        //Load the Objects
        Workouts = Bundle.main.decode([Workout].self, from: workoutPath)
        Exlist = Bundle.main.decode([ExList].self, from: exlistPath)
    }
    
    //MARK: - Save all Workouts changes
    func SaveWorkouts(){
        try? JSONEncoder().encode(Workouts).write(to: workoutPath, options: .atomic)
        print("Workout saved")
    }
    
    //MARK: - Save all Exercises changes
    func SaveSettings(){
        try? JSONEncoder().encode(Exlist).write(to: exlistPath, options: .atomic)
        print("Settings saved")
    }
    
    //MARK: - Given UUID returns the name
    func ReturnName(unkID: UUID) -> String{
        for ex in Exlist{
            if(ex.id==unkID){
                return ex.name
            }
        }
        return "Unknown"
    }
    
    //MARK: - When deleting an Ex, removes it from every Workout
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
    
    //MARK: - Generate new Exercise for each selected element
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
    
    //MARK: - Duplicate exercise
    func DupEx(workIndex: Int, index: Int){
        Workouts[workIndex].exercises.append(Workouts[workIndex].exercises[index])
        Workouts[workIndex].exercises[Workouts[workIndex].exercises.count-1].id = UUID()
    }
    
    //MARK: - Duplicate Workout
    func DupWork(index: Int){
        Workouts.append(Workouts[index])
        Workouts[Workouts.count-1].id = UUID()
    }
    
    //MARK: - Change exercise name
    func SwitchEx(workIndex: Int, index: Int, newId: UUID) {
        Workouts[workIndex].exercises[index].exID=newId
    }
    
    //MARK: - Calc the 1RM by using the weight used in each Set
    func Massimale(sets: [Set]) -> Double {
        var massimale: Double = 0.0
        
        for singleSet in sets {
            //Brzycky equation
            let bufferMax = (singleSet.weight / (1.0278 - (0.0278 * Double(singleSet.reps)))).rounded()
            if bufferMax > massimale {
                massimale = bufferMax
            }
        }
        
        return massimale
    }
    
    //MARK: - Returns Exercise Set Details
    func ExDetails(ex: Exercise) -> [VisualSet]{
        var visualSets : [VisualSet] = [] //Create the array to return
        var totalSets = 0 //Sets counter
        
        //Create the first element, which contains the total sets for the whole exercise
        visualSets.append(VisualSet(nSets: 0, text: " Sets", color: Color(.systemBlue)))
        
        //Cycle through each set
        for set in ex.sets {
            totalSets+=set.nSets //adds the sets to the counter
            
            //Creates a new element for the visualSet, but adds the string if different from 1
            visualSets.append(VisualSet(nSets: set.nSets,text: "x"))
            
            
            if ex.dropSet == 0 { //If NOT dropset just appends the reps
                visualSets[visualSets.count-1].text+="\(set.reps)"
            }else{ //If dropset generate the string
                visualSets[visualSets.count-1].color = Color(.systemRed)
                visualSets[visualSets.count-1].text+=""
                
                visualSets[visualSets.count-1].text+="("
                
                //Given the reps, calcs how many times drop the weight
                var drop = set.reps
                while(drop >= ex.dropSet){
                    visualSets[visualSets.count-1].text+="\(ex.dropSet)"
                    drop-=ex.dropSet
                    if (drop >= ex.dropSet){
                        visualSets[visualSets.count-1].text+="+"
                    }
                }
                
                visualSets[visualSets.count-1].text+=")"
            }
        }
        visualSets[0].nSets=totalSets
        
        return visualSets
    }
}

