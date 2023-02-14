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
                                //Nome Workout
                                Text(workout.name)
                                    .font(.title2)
                                    .foregroundColor(.accentColor)
                                    .contextMenu {
                                        Button(action: {selectedItem=i; showEditAlert.toggle()}) {
                                                Text("Cambia Nome")
                                                Image(systemName: "pencil")
                                        }
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
                        Button("Cancel", role: .cancel, action: {})
                    })
                }
                header:{
                    HStack{
                        //Titolo
                        HStack{
                            Image(systemName: "list.clipboard.fill")
                            Text("Piani")
                        }
                        .font(.title2)
                        
                        Spacer()
                        //Modifica i Set
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
                        
                        //Aggiungi un piano di allenamento
                        Button(action: {showWorkoutAlert.toggle()}){
                            Text("Aggiungi")
                                .foregroundColor(.white)
                                .font(.caption)
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                        .padding(.all, 8.0)
                        .alert("Aggiungi Workout", isPresented: $showWorkoutAlert, actions: {
                            TextField("Inserisci nome", text: $textBuffer)
                            Button("Ok", action: onAdd)
                            Button("Cancel", role: .cancel, action: {})
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
    }
    
    private func onDelete(offsets: IndexSet) {
        appData.Workouts.remove(atOffsets: offsets)
    }
    
    private func onMove(source: IndexSet, destination: Int) {
        appData.Workouts.move(fromOffsets: source, toOffset: destination)
        
    }
    
    private func onEdit(){
        appData.Workouts[selectedItem ?? 0].name=textBuffer
        textBuffer = ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppData())
    }
}
