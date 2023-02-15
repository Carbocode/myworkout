//
//  AppData.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 14/02/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct TextFile: FileDocument {
    static var readableContentTypes = [UTType.json]

    // by default our document is empty
    var text = ""

    // a simple initializer that creates new, empty documents
    init(initialText: String = "") {
        text = initialText
    }

    // this initializer loads data that has been saved previously
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        }
    }

    // this will be called when the system wants to write our data to disk
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: Data(text.utf8))
    }
}

class AppData: ObservableObject {
    @Published var Workouts : [Workout]
    @Published var SettingsData : Settings
    var workoutFiles = TextFile()
    var settingsFiles = TextFile()
    
    init(){
        if !workoutFiles.text.isEmpty{
            Workouts = Bundle.main.decode([Workout].self, from: workoutFiles)
        }else{
            Workouts = []
        }
        
        if !settingsFiles.text.isEmpty{
            SettingsData = Bundle.main.decode(Settings.self, from: settingsFiles)
        }
        else{
            SettingsData = Settings(defaultREST: 60, lastREST: true, imperial: false, weights: [])
        }
        
    }
    
    func Save(){
        workoutFiles.text = Bundle.main.encode(Workouts)
        settingsFiles.text = Bundle.main.encode(SettingsData)
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

