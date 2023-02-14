//
//  WorkoutDetails.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 13/01/23.
//

import SwiftUI

struct WorkoutDetails: View {
    @EnvironmentObject var appData : AppData
    var index: Int
    @State private var editMode = EditMode.inactive
    @State private var showAddSheet = false
    @State private var showExSheet = false
    @State private var selectedItem = 0
    
    var body: some View {
        NavigationStack{
            
            List{
                //Lista Esercizi
                let exercises = appData.Workouts[index].exercises
                Section{
                    ForEach(Array(exercises.enumerated()), id: \.element) { i, exercise in
                        Button(action: {selectedItem=i; showExSheet.toggle()}){
                                VStack(alignment: .leading){
                                    Text(appData.ReturnName(unkID: exercise.exID))
                                        .foregroundColor(.accentColor)
                                        .font(.title3)
                                    
                                    HStack{
                                        let setsNumber = exercise.sets.count
                                        Text("\(setsNumber) Sets x \(exercise.sets[0].reps) Reps | \(exercise.rest)s")
                                    }.font(.subheadline)
                                }
                                .padding()
                            }
                    }
                    .onDelete(perform: onDelete)
                    .onMove(perform: onMove)
                    .sheet(isPresented: $showExSheet){
                        ExerciseDetails(workIndex: index, index: selectedItem)
                    }
                }
                header:{
                    //Titolo
                    HStack{
                        HStack{
                            Image(systemName: "dumbbell.fill")
                            Text("Pesi")
                        }
                        .font(.title2)
                        
                        Spacer()
                        //Modifica esercizi
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
                        //Aggiungi un esercizio
                        HStack{
                            Button("Aggiungi", action: {showAddSheet.toggle()})
                                .foregroundColor(.white)
                                .font(.caption)
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                        .sheet(isPresented: $showAddSheet){
                            ExerciseList(isSelecting: true, selectedWorkout: index)
                        }
                        .padding(.all, 8.0)
                        .background(Capsule()
                            .foregroundColor(Color("LightBlack"))
                            .shadow(radius: 5))
                    }
                    .padding(.vertical, 7.0)
                }
                footer: {
                    //Pulsante di inizio workout
                    HStack{
                        Spacer()
                        Button(action: {}){
                            Image(systemName: "figure.mixed.cardio")
                            Text("Inizia Workout")
                            Image(systemName: "figure.strengthtraining.functional")
                        }
                        .padding()
                        .buttonStyle(.borderedProminent)
                        .font(.title2)
                        .foregroundColor(.black)
                        .disabled(exercises.isEmpty)
                        Spacer()
                    }
                    
                    
                }
            }
            .listStyle(.inset)
            .navigationBarTitle(Text("\(appData.Workouts[index].name)"), displayMode: .large)
            .environment(\.editMode, $editMode)
            
        }
        
        
        
    }
    
    private func onDelete(offsets: IndexSet) {
        appData.Workouts[index].exercises.remove(atOffsets: offsets)
    }
    private func onMove(source: IndexSet, destination: Int) {
        appData.Workouts[index].exercises.move(fromOffsets: source, toOffset: destination)
    }
    
    
}

struct WorkoutDetails_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutDetails(index: 0)
            .environmentObject(AppData())
    }
}
