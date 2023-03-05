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
    var color = Color(.gray)
}

struct Item : Identifiable {
    var id = UUID()
    var i: Int
}

struct WorkoutDetails: View {
    @EnvironmentObject var appData : AppData
    
    var index: Int
    
    @State private var editMode = EditMode.inactive
    @State private var showAddSheet     = false
    @State private var showSwitchSheet  = false
    @State private var showExSheet      = false
    @State private var startWorkout     = false
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
                                        
                                        HStack{
                                            //Sets x Reps
                                            ForEach(ExDetails(ex: exercise)){ visualSet in
                                                Text(visualSet.text)
                                                    .padding(3)
                                                    .foregroundColor(.white)
                                                    .background(Rectangle()
                                                        .foregroundColor(visualSet.color)
                                                        .cornerRadius(5))
                                                    .padding(.trailing, -5.0)
                                                    .font(.footnote)
                                                    .fontWeight(.heavy)
                                            }
                                        }
                                    }
                                    .padding()
                                }
                            }
                            .listRowSeparatorTint(.gray)
                            .listRowBackground(Color.darkEnd)
                            .contextMenu {
                                Button(action: {appData.DupEx(workIndex: index, index: i); appData.SaveWorkouts()
                                }) {Label("Duplica", systemImage: "doc.on.doc.fill")}
                                Button(action: {selectedItem=i; showSwitchSheet.toggle()
                                }) {Label("Sostituisci", systemImage: "repeat")}
                            }
                        }
                        .onDelete(perform: onDelete)
                        .onMove(perform: onMove)
                        Rectangle()
                            .frame(height: 50)
                            .opacity(0).listRowBackground(Color.clear).listRowSeparatorTint(.clear)
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
                            EditButton(editMode: $editMode)
                            
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
                                ExerciseList(isSelecting: true, isSwitching: false, selectedWorkout: index, selectedExercise: Binding.constant(0))
                            }
                            .padding(.all, 8.0)
                            .background(Capsule()
                                .foregroundColor(Color("LightBlack"))
                                .shadow(color: Color.darkEnd.opacity(0.7), radius: 10, x: 10, y: 10)
                                .shadow(color: Color.darkStart.opacity(1), radius: 10, x: -5, y: -5))
                        }
                        .padding(.vertical, 7.0)
                    }
                    
                }
                .background(LinearGradient(Color.darkStart, Color.darkEnd))
                .scrollContentBackground(.hidden)
                .listStyle(.inset)
                .navigationBarTitle(Text("\(appData.Workouts[index].name)"), displayMode: .large)
                .sheet(isPresented: $showExSheet, onDismiss: appData.SaveWorkouts){
                    ExerciseDetails(workIndex: index, index: $selectedItem)
                }
                .sheet(isPresented: $showSwitchSheet, onDismiss: appData.SaveWorkouts){
                    ExerciseList(isSelecting: false, isSwitching: true, selectedWorkout: index, selectedExercise: $selectedItem)
                }
                .environment(\.editMode, $editMode)
            }
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    Button(action: {startWorkout.toggle()}){
                        Image(systemName: "figure.mixed.cardio")
                        Text("Inizia Workout")
                        Image(systemName: "figure.strengthtraining.functional")
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                    .font(.headline)
                    .foregroundColor(.black)
                    .disabled(exercises.isEmpty)
                    .fullScreenCover(isPresented: $startWorkout){
                        BeginWorkout(index: index)
                    }
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
        var visualSets : [VisualSet] = []
        var totalSets = 0
        visualSets.append(VisualSet(text: "", color: Color(.systemBlue)))
        for set in ex.sets {
            totalSets+=set.nSets
            if set.nSets != 1{
                
                visualSets.append(VisualSet(text: "\(set.nSets)x"))
            }else{
                visualSets.append(VisualSet(text: ""))
            }
            
            if ex.dropSet == 0 {
                visualSets[visualSets.count-1].text+="\(set.reps)"
            }else{
                visualSets[visualSets.count-1].color = Color(.systemRed)
                visualSets[visualSets.count-1].text+=""
                
                visualSets[visualSets.count-1].text+="("
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
        visualSets[0].text="\(totalSets) Sets"
        
        return visualSets
    }
    
    
}

struct WorkoutDetails_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutDetails(index: 0)
            .environmentObject(AppData())
    }
}
