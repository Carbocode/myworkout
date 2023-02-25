//
//  ContentView.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 12/01/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appData : AppData
    
    @State var editMode = EditMode.inactive
    
    @State private var showEditAlert = false
    @State private var showWorkoutAlert = false
    @State private var selectedItem: Int?
    @State private var textBuffer=""
    
    var body: some View {
        NavigationStack{
            List{
                //Workouts
                let workouts = appData.Workouts
                Section{
                    ForEach(Array(workouts.enumerated()), id:\.element) { i, workout in
                        NavigationLink{
                            WorkoutDetails(index: i)
                        }
                        label: {
                            HStack{ 
                                //MARK: - Workout
                                Text(workout.name)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.accentColor)
                                    .contextMenu {
                                        Button(action: {selectedItem=i; showEditAlert.toggle()
                                            textBuffer = appData.Workouts[selectedItem ?? 0].name
                                        }) {Label("Cambia Nome", systemImage: "pencil")}
                                        Button(action: {appData.DupWork(index: i)
                                            appData.SaveWorkouts()
                                        }) {Label("Duplica", systemImage: "doc.on.doc.fill")}
                                    }
                                
                                Spacer()
                            }
                            .padding()
                            .listRowBackground(Color("BW"))
                        }
                    }
                    .onDelete(perform: onDelete)
                    .onMove(perform: onMove)
                    .alert("Cambia Nome", isPresented: $showEditAlert, actions: {
                        TextField("Inserisci nuovo nome", text: $textBuffer )
                        Button("Ok", action: onEdit)
                        Button("Cancel", role: .cancel, action: {textBuffer=""})
                    })
                }
                header:{
                    HStack{
                        //MARK: - Title
                        HStack{
                            Image(systemName: "list.clipboard.fill")
                            Text("Piani")
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
                        Button(action: {showWorkoutAlert.toggle()}){
                            Text("Aggiungi")
                                .foregroundColor(.white)
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                        .font(.caption)
                        .padding(.all, 8.0)
                        .alert("Aggiungi Workout", isPresented: $showWorkoutAlert, actions: {
                            TextField("Inserisci nome", text: $textBuffer)
                            Button("Ok", action: onAdd)
                            Button("Cancel", role: .cancel, action: {textBuffer=""})
                        })
                        .background(Capsule()
                            .foregroundColor(Color("LightBlack"))
                            .shadow(radius: 5))
                    }
                    .padding(.vertical, 7.0)
                }
            }
            .listStyle(.inset)
            .environment(\.editMode, $editMode)
            .navigationTitle("MyWorkouts")
        }
    }
    
    private func onAdd() {
        appData.Workouts.append(Workout(id: "3-\(appData.Workouts.count)", name: textBuffer, exercises: []))
        textBuffer=""
        
        appData.SaveWorkouts()
    }
    
    private func onDelete(offsets: IndexSet) {
        appData.Workouts.remove(atOffsets: offsets)
        appData.SaveWorkouts()
    }
    
    private func onMove(source: IndexSet, destination: Int) {
        appData.Workouts.move(fromOffsets: source, toOffset: destination)
        appData.SaveWorkouts()
    }
    
    private func onEdit(){
        appData.Workouts[selectedItem ?? 0].name=textBuffer
        textBuffer = ""
        appData.SaveWorkouts()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppData())
    }
}
