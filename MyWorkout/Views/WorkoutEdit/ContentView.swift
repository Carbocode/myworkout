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
                        NavigationLink(destination: WorkoutDetails(index: i)){
                            //MARK: - Workout
                            VStack(alignment: .leading){
                                Text(workout.name)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.accentColor)
                                //MARK: Context MENU
                                    .contextMenu {
                                        Button(action: {selectedItem=i; showEditAlert.toggle()
                                            textBuffer = appData.Workouts[selectedItem ?? 0].name
                                        }) {Label("Cambia Nome", systemImage: "pencil")}
                                        Button(action: {appData.DupWork(index: i)
                                            appData.SaveWorkouts()
                                        }) {Label("Duplica", systemImage: "doc.on.doc.fill")}
                                    }
                                if appData.debug {
                                    Text(workout.id.uuidString).font(.caption2)
                                }
                            }
                        }
                        .padding()
                        .listRowSeparatorTint(.gray)
                        .listRowBackground(Color.darkEnd)
                    }
                    .onDelete(perform: onDelete)
                    .onMove(perform: onMove)
                    //MARK: Change name Alert
                    .alert("Cambia Nome", isPresented: $showEditAlert, actions: {
                        TextField("Inserisci nuovo nome", text: $textBuffer )
                        Button("Ok", action: onUpdate)
                        Button("Cancel", role: .cancel, action: {textBuffer=""})
                    })
                }
                //MARK: - Header
                header:{
                    HStack{
                        //MARK: Title
                        HStack{
                            Image(systemName: "list.clipboard.fill")
                            Text("Piani")
                        }
                        .font(.title2)
                        
                        Spacer()
                        //MARK: Edit button
                        EditButton(editMode: $editMode)
                        
                        Spacer()
                        
                        //MARK: Add button
                        Button(action: {showWorkoutAlert.toggle()}){
                            Text("Aggiungi")
                                .foregroundColor(.white)
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                        .font(.caption)
                        .padding(.all, 8.0)
                        //MARK: ADD Workout Alert
                        .alert("Aggiungi Workout", isPresented: $showWorkoutAlert, actions: {
                            TextField("Inserisci nome", text: $textBuffer)
                            Button("Ok", action: onCreate)
                            Button("Cancel", role: .cancel, action: {textBuffer=""})
                        })
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
            .environment(\.editMode, $editMode)
            .navigationTitle("MyWorkouts")
        }
        .foregroundColor(.primary)
        .preferredColorScheme(.dark)
    }
    
    //Create
    private func onCreate() {
        appData.Workouts.append(Workout(id: UUID(), name: textBuffer, exercises: []))
        textBuffer=""
        
        appData.SaveWorkouts()
    }
    
    //Delete
    private func onDelete(offsets: IndexSet) {
        appData.Workouts.remove(atOffsets: offsets)
        appData.SaveWorkouts()
    }
    
    //Update
    private func onUpdate(){
        appData.Workouts[selectedItem ?? 0].name=textBuffer
        textBuffer = ""
        appData.SaveWorkouts()
    }
    
    private func onMove(source: IndexSet, destination: Int) {
        appData.Workouts.move(fromOffsets: source, toOffset: destination)
        appData.SaveWorkouts()
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppData())
    }
}
