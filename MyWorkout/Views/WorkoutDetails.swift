//
//  WorkoutDetails.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 13/01/23.
//

import SwiftUI

struct VisualSet : Hashable, Identifiable {
    let id: UUID = UUID()
    var text: String
}

struct WorkoutDetails: View {
    @EnvironmentObject var appData : AppData
    var index: Int
    @State private var editMode = EditMode.inactive
    @State private var showAddSheet = false
    @State private var showSwitchSheet = false
    @State private var showExSheet = false
    @State private var selectedItem = 0
    
    var body: some View {
        //Lista Esercizi
        let exercises = appData.Workouts[index].exercises
        ZStack{
            NavigationStack{
                List{
                    Section{
                        ForEach(Array(exercises.enumerated()), id: \.element) { i, exercise in
                            //MARK: - Exercise
                            Button(action: {selectedItem=i; showExSheet.toggle()}){
                                        HStack{
                                            //Rest Time
                                            ZStack{
                                                Circle()
                                                    .foregroundColor(.accentColor)
                                                    .frame(width: 50)
                                                Text("\(exercise.rest)s")
                                            }
                                            .font(.callout)
                                            
                                            .foregroundColor(.black)
                                            .fontWeight(.bold)
                                            
                                            VStack(alignment: .leading){
                                                //ExName
                                                Text(appData.ReturnName(unkID: exercise.exID))
                                                    .foregroundColor(.accentColor)
                                                    .font(.body)
                                                
                                                //Sets x Reps
                                                HStack{
                                                    Text("\(exercise.sets.count) Sets")
                                                        .padding(3)
                                                        .foregroundColor(.white)
                                                        .background(Rectangle().foregroundColor(.blue).cornerRadius(5))
                                                    
                                                    ForEach(ExDetails(ex: exercise)){ visualSet in
                                                        Text(visualSet.text)
                                                            .padding(3)
                                                            .foregroundColor(.white)
                                                            .background(Rectangle()
                                                                .foregroundColor(.gray)
                                                                .cornerRadius(5))
                                                            .padding(.trailing, -5.0)
                                                    }
                                                    
                                                }
                                                .font(.footnote)
                                                .fontWeight(.heavy)
                                            }
                                            .padding()
                                        }
                                }
                            .contextMenu {
                                Button(action: {appData.DupEx(workIndex: index, index: i); appData.SaveWorkouts()
                                }) {Label("Duplica", systemImage: "doc.on.doc.fill")}
                                Button(action: {selectedItem=i; showSwitchSheet.toggle()
                                }) {Label("Sostituisci", systemImage: "repeat")}
                            }
                        }
                        .onDelete(perform: onDelete)
                        .onMove(perform: onMove)
                        Rectangle().frame(height: 50).opacity(0).listRowSeparator(.hidden)
                    }
                    header:{
                        HStack{
                            //MARK: - Title
                            HStack{
                                Image(systemName: "dumbbell.fill")
                                Text("Pesi")
                            }
                            .font(.title2)
                            
                            Spacer()
                            //MARK: - Edit
                            HStack{
                                EditButton()
                                    .foregroundColor(.white)
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundColor(.white)
                            }
                            .font(.caption)
                            .padding(.all, 8.0)
                            .background(Capsule()
                                .foregroundColor(.blue)
                                .shadow(radius: 5))
                            
                            Spacer()
                            //MARK: - Add
                            Button(action: {showAddSheet.toggle()}){
                                Text("Aggiungi")
                                    .foregroundColor(.white)
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                            .font(.caption)
                            .sheet(isPresented: $showAddSheet){
                                ExerciseList(isSelecting: true, isSwitching: false, selectedWorkout: index)
                            }
                            .padding(.all, 8.0)
                            .background(Capsule()
                                .foregroundColor(Color("LightBlack"))
                                .shadow(radius: 5))
                        }
                        .padding(.vertical, 7.0)
                    }
                    
                }
                .listStyle(.inset)
                .navigationBarTitle(Text("\(appData.Workouts[index].name)"), displayMode: .large)
                .sheet(isPresented: $showExSheet, onDismiss: appData.SaveWorkouts){
                    ExerciseDetails(workIndex: index, index: selectedItem)
                }
                .sheet(isPresented: $showSwitchSheet, onDismiss: appData.SaveWorkouts){
                    ExerciseList(isSelecting: false, isSwitching: true, selectedWorkout: index, selectedExercise: selectedItem)
                }
                .environment(\.editMode, $editMode)
            }
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    Button(action: {}){
                        Image(systemName: "figure.mixed.cardio")
                        Text("Inizia Workout")
                        Image(systemName: "figure.strengthtraining.functional")
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                    .font(.headline)
                    .foregroundColor(.black)
                    .disabled(exercises.isEmpty)
                    Spacer()
                }
                .background(.regularMaterial)
            }
        }
    }
    
    private func onDelete(offsets: IndexSet) {
        appData.Workouts[index].exercises.remove(atOffsets: offsets)
        appData.SaveWorkouts()
    }
    private func onMove(source: IndexSet, destination: Int) {
        appData.Workouts[index].exercises.move(fromOffsets: source, toOffset: destination)
        appData.SaveWorkouts()
    }
    
    private func ExDetails(ex: Exercise) -> [VisualSet]{
        var repArray: [(Int, Int)] = [] //Array grafico di sets
        
        if ex.sets.count > 0 {
            var prevReps = 0
            for exSet in ex.sets{//Ciclo per ogni set
                if exSet.reps != prevReps { //Se set attuale diverso da precedente
                    repArray.append((exSet.reps, 1)) //Lo aggiungo all'array grafico
                    prevReps = exSet.reps //L'attuale diventa il precedente
                }else{
                    repArray[repArray.count-1].1 += 1
                }
            }
        }
        
        var visualSets : [VisualSet] = []
        for array in repArray {
            if ex.dropSet == 0 {
                visualSets.append(VisualSet(text:" \(array.0)"))
            }else{
                visualSets.append(VisualSet(text:" "))
                
                visualSets[visualSets.count-1].text+="("
                var drop = array.0
                while(drop >= ex.dropSet){
                    visualSets[visualSets.count-1].text+="\(ex.dropSet)"
                    drop-=ex.dropSet
                    if (drop >= ex.dropSet){
                        visualSets[visualSets.count-1].text+="+"
                    }
                }
                visualSets[visualSets.count-1].text+=")"
            }
            if array.1 != 1{
                visualSets[visualSets.count-1].text+="x\(array.1) "
            }else{
                visualSets[visualSets.count-1].text+=" "
            }
        }
        
        return visualSets
    }
    
    
}

struct WorkoutDetails_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutDetails(index: 0)
            .environmentObject(AppData())
    }
}
