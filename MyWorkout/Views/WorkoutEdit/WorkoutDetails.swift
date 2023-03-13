//
//  WorkoutDetails.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 13/01/23.
//

import SwiftUI

struct Item : Identifiable {
    var id = UUID()
    var i: Int
}

struct WorkoutDetails: View {
    @EnvironmentObject var appData : AppData
    
    var index: Int
    
    let generator = UINotificationFeedbackGenerator()
    
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
                //MARK: - Ex List
                List{
                    Section{
                        ForEach(Array(exercises.enumerated()), id: \.element) { i, exercise in
                            //MARK: - Exercise
                            if editMode != EditMode.active{
                                Button(action: {selectedItem=i; showExSheet.toggle()}){
                                    HStack{
                                        //MARK: Rest Time
                                        ZStack{
                                            //Superset top line
                                            if exercise.superset{
                                                Rectangle().fill(Color.accentColor).frame(width: 5)
                                                    .padding(.top, 40.0).cornerRadius(5)
                                            }
                                            //Superset bottom line
                                            if i != 0 {
                                                if exercises[i-1].superset{
                                                    Rectangle().fill(Color.accentColor).frame(width: 5)
                                                        .padding(.bottom, 40.0).cornerRadius(5)
                                                }
                                            }
                                            
                                            //Rest Time background
                                            Circle()
                                                .fill(Color.accentColor)
                                                .frame(width: 50)
                                                .overlay(
                                                    Circle()
                                                            .stroke(Color.white, lineWidth: 4)
                                                            .blur(radius: 4)
                                                            .offset(x: 2, y: 2)
                                                            .mask(Circle().fill(LinearGradient(Color.black, Color.clear)))
                                                    )
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.gray, lineWidth: 8)
                                                        .blur(radius: 5)
                                                        .offset(x: -2, y: -2)
                                                        .mask(Circle().fill(LinearGradient(Color.clear, Color.black)))
                                                )
                                            
                                            Text("\(exercise.rest)s")
                                            
                                        }
                                        .font(.callout)
                                        .foregroundColor(.black)
                                        .fontWeight(.bold)
                                        
                                        VStack(alignment: .leading){
                                            //MARK: ExName
                                            HStack{
                                                Text("\(i+1)°").font(.headline)
                                                //ExName
                                                Text(appData.ReturnName(unkID: exercise.exID))
                                                    .foregroundColor(.accentColor)
                                                    .font(.body)
                                                    .fontWeight(.bold)
                                            }
                                            HStack{
                                                //MARK: Sets x Reps
                                                ForEach(appData.ExDetails(sets: exercise.sets)){ visualSet in
                                                    Text("\(visualSet.nSets) \(visualSet.text)")
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
                                            if appData.debug {
                                                Text(exercise.id.uuidString).font(.caption2)
                                                Text("exID: \n \(exercise.exID.uuidString)").font(.caption2)
                                            }
                                            
                                        }
                                        .padding()
                                    }
                                }
                                .listRowSeparatorTint(.gray)
                                .listRowBackground(Color.darkEnd)
                                //MARK: Context MENU
                                .contextMenu {
                                    Button(action: {appData.DupEx(workIndex: index, index: i); appData.SaveWorkouts()
                                    }) {Label("Duplica", systemImage: "doc.on.doc.fill")}
                                    Button(action: {selectedItem=i; showSwitchSheet.toggle()
                                    }) {Label("Sostituisci", systemImage: "repeat")}
                                }
                            }
                            else{
                                HStack{
                                    Text("\(i+1)°").font(.headline)
                                    //ExName
                                    Text(appData.ReturnName(unkID: exercise.exID))
                                        .foregroundColor(.accentColor)
                                        .font(.body)
                                        .fontWeight(.bold)
                                }
                            }
                        }
                        .onDelete(perform: onDelete)
                        .onMove(perform: onMove)
                        .listRowSeparatorTint(.gray)
                        .listRowBackground(Color.darkEnd)
                        
                        Rectangle()
                            .frame(height: 50)
                            .opacity(0).listRowBackground(Color.clear).listRowSeparatorTint(.clear)
                    }
                    header:{
                        HStack{
                            //MARK: Title
                            HStack{
                                Image(systemName: "dumbbell.fill")
                                Text("Pesi")
                            }
                            .font(.title2)
                            
                            Spacer()
                            //MARK: Edit Button
                            EditButton(editMode: $editMode)
                            
                            Spacer()
                            //MARK: ADD Button
                            Button(action: {showAddSheet.toggle()}){
                                Text("Aggiungi")
                                    .foregroundColor(.white)
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                            .font(.caption)
                            //MARK: - ADD Sheet
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
                //MARK: - Exercise Detail Sheet
                .sheet(isPresented: $showExSheet, onDismiss: appData.SaveWorkouts){
                    ExerciseDetails(workIndex: index, index: $selectedItem)
                }
                //MARK: - Switch Sheet
                .sheet(isPresented: $showSwitchSheet, onDismiss: appData.SaveWorkouts){
                    ExerciseList(isSelecting: false, isSwitching: true, selectedWorkout: index, selectedExercise: $selectedItem)
                }
                .environment(\.editMode, $editMode)
            }
            
            //MARK: - Start Button
            if editMode != EditMode.active {
                VStack{
                    Spacer()
                    HStack{
                        Spacer()
                        Button(action: {
                            startWorkout.toggle()
                            generator.notificationOccurred(.success)
                        }){
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
                            BeginWorkout(workout: appData.Workouts[index])
                        }
                        Spacer()
                    }
                    .background(.regularMaterial)
                }
            }
        }
        .foregroundColor(.primary)
        .preferredColorScheme(.dark)
    }
    
    //Delete
    private func onDelete(offsets: IndexSet) {
        appData.Workouts[index].exercises.remove(atOffsets: offsets)
        appData.SaveWorkouts()
    }
    
    //Move
    private func onMove(source: IndexSet, destination: Int) {
        appData.Workouts[index].exercises.move(fromOffsets: source, toOffset: destination)
        appData.SaveWorkouts()
    }
    
}

struct WorkoutDetails_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutDetails(index: 0)
            .environmentObject(AppData())
    }
}
