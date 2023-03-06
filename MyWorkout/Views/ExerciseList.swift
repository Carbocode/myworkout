//
//  ExerciseList.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 24/01/23.
//

import SwiftUI

struct ExerciseList: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appData : AppData
    
    @State var isSelecting: Bool
    @State var isSwitching: Bool
    @State var selectedWorkout: Int?
    
    @Binding var selectedExercise: Int
    
    @State private var showExerciseAlert = false //Alert where to INSERT Ex name
    @State private var showEditAlert = false //Alert where to MODIFY Ex name
    
    @State private var textBuffer = ""
    @State private var searchingText = "" //Searching Text
    @State private var multiSelection = Swift.Set<UUID>()
    @State private var selectedItem = 0
    @State private var kgLb: String = UserDefaults.standard.bool(forKey: "imperial") ? "lb" : "Kg"
    
    var weights: [ExList] { searchingText.isEmpty ? appData.Exlist.sorted() :
        appData.Exlist.filter{$0.name.localizedCaseInsensitiveContains(searchingText)}.sorted()
    }
    
    var body: some View {
        ZStack{
            NavigationStack{
                List(weights, selection: $multiSelection){ exercise in
                    Button(action:{
                        if isSwitching{
                            appData.Workouts[selectedWorkout ?? 0].exercises[selectedExercise].exID=exercise.id
                            dismiss()
                        }
                    }){
                        VStack(alignment: .leading){
                            Text("\(exercise.name)")
                            Text("Massimale: \(exercise.topWeight, specifier: "%.1f") \(kgLb)")
                                .font(.footnote)
                            if appData.debug{
                                Text(exercise.id.uuidString).font(.caption2)
                            }
                        }
                    }
                    .contextMenu {
                        Button(action: {selectedItem = exactIndex(id: exercise.id); showEditAlert.toggle()
                            textBuffer = appData.Exlist[selectedItem].name
                        }) {Label("Cambia Nome", systemImage: "pencil")}
                    }
                    .swipeActions{
                        Button(role: .destructive, action: {onDelete(id: exercise.id)} ){
                            Label("delete", systemImage: "trash.fill").foregroundColor(.red)
                        }
                    }
                }
                .environment(\.editMode, isSelecting ? .constant(EditMode.active) : .constant(EditMode.inactive))
                .searchable(text: $searchingText, placement: .navigationBarDrawer(displayMode: .always))
                .listStyle(.inset)
                .navigationTitle("Esercizi")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading:
                    Button("Cancel", role: .cancel, action: {dismiss()})
                        .foregroundColor(.accentColor).fontWeight(.bold).font(.body),
                    trailing:
                        Button(action: {showExerciseAlert.toggle(); textBuffer=searchingText}){
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                )
                .alert("Cambia Nome", isPresented: $showEditAlert, actions: {
                    TextField("Inserisci nuovo nome", text: $textBuffer)
                    Button("Ok", action: onEdit)
                    Button("Cancel", role: .cancel, action: {textBuffer=""})
                 })
                .alert("Aggiungi Esercizio", isPresented: $showExerciseAlert, actions: {
                    TextField("Inserisci nome", text: $textBuffer)
                    Button("Cancel", role: .cancel, action: {textBuffer=""; searchingText=""})
                    Button("Ok", action: onAdd)
                })
                
                Rectangle().frame(height: 50).opacity(0)
            }
            VStack{
                Spacer()
                if weights.isEmpty{
                    HStack{
                        Spacer()
                        VStack{
                            Button(action: {showExerciseAlert.toggle(); textBuffer=searchingText}){
                                Text("Aggiungi esercizio")
                            }
                            .padding()
                            .buttonStyle(.borderedProminent)
                            .font(.headline)
                            .foregroundColor(.black)
                        }
                        Spacer()
                    }
                    .background(.regularMaterial)
                }
                if !weights.isEmpty && isSelecting {
                    HStack{
                        Spacer()
                        Spacer()
                        Text("\(multiSelection.count) Elementi")
                        Spacer()
                        Button(action: {appData.AddExToWorkout(exIDs: multiSelection, index:selectedWorkout ?? 0); dismiss()}){
                            Text("Aggiungi")
                        }
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                        .disabled(multiSelection.isEmpty)
                    }
                    .font(.body)
                    .padding()
                    .background(.regularMaterial)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    func onAdd() {
        appData.Exlist.append(ExList(id: UUID(), name: textBuffer, topWeight: 0.0))
        textBuffer=""
        searchingText=""
        
        appData.SaveSettings()
    }
    
    private func exactIndex(id: UUID) -> Int {
        var index = 0
        //Ciclo tra tutti gli esercizi
        for ex in appData.Exlist{
            //Cerco l'id dell'esercizio corrisponde all'elemento della lista
            if (ex.id == id){
                return index
            }
            index+=1
        }
        
        return 0
    }
    
    //Modify by ID
    private func onEdit() {
        appData.Exlist[selectedItem].name=textBuffer
        textBuffer=""
        
        appData.SaveSettings()
    }
    
    //Delete by ID
    private func onDelete(id: UUID) {
        let exactIndex = exactIndex(id: id)
        appData.DeleteExFromWorkout(exID: appData.Exlist[exactIndex].id)
        appData.Exlist.remove(at: exactIndex)
        
        appData.SaveSettings()
        appData.SaveWorkouts()
    }
    
    struct ExerciseList_Previews: PreviewProvider {
        static var previews: some View {
            ExerciseList(isSelecting: true, isSwitching: false, selectedExercise: Binding.constant(0))
                .environmentObject(AppData())
        }
    }
}
