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
    @State var selectedWorkout: Int?
    
    @State private var showExerciseAlert = false //Alert where to INSERT Ex name
    @State private var showEditAlert = false //Alert where to MODIFY Ex name
    
    @State private var textBuffer = ""
    @State private var searchingText = "" //Searching Text
    @State private var multiSelection = Swift.Set<String>()
    @State private var selectedItem = ""
    
    var weights: [ExList] { searchingText.isEmpty ? appData.Exlist.sorted() :
        appData.Exlist.filter{$0.name.localizedCaseInsensitiveContains(searchingText)}.sorted()
    }
    
    
    
    var body: some View {
        NavigationStack{
            List(weights, selection: $multiSelection){ exercise in
                    HStack{
                        Text(exercise.name)
                            .font(.subheadline)
                    }
                    .contextMenu {
                        Button(action: {selectedItem = exercise.id; showEditAlert.toggle()}) {
                                Text("Cambia Nome")
                                Image(systemName: "pencil")
                        }
                    }
                    .swipeActions{
                        Button(role: .destructive, action: {onDelete(id: exercise.id)} ){
                            Label("delete", systemImage: "trash.fill")
                        }
                    }
                }
                .environment(\.editMode, isSelecting ? .constant(EditMode.active) : .constant(EditMode.inactive))
                .searchable(text: $searchingText,placement: .navigationBarDrawer(displayMode: .always))
                .navigationTitle("Esercizi")
                .navigationBarItems(trailing: isSelecting ?
                                    Button("Aggiungi", action: {appData.AddExToWorkout(exIDs: multiSelection, index:selectedWorkout ?? 0); dismiss()})
                                    .foregroundColor(.accentColor)
                                    : nil)
                .alert("Cambia Nome", isPresented: $showEditAlert, actions: {
                    TextField("Inserisci nuovo nome", text: $textBuffer)
                    Button("Ok", action: onEdit)
                    Button("Cancel", role: .cancel, action: {})
                })
            
                if weights.isEmpty{
                    HStack{
                        Spacer()
                        VStack{
                            Button(action: {showExerciseAlert.toggle(); textBuffer=searchingText}){
                                Text("Aggiungi esercizio")
                            }
                            .padding()
                            .buttonStyle(.borderedProminent)
                            .font(.title2)
                            .foregroundColor(.black)
                            .alert("Aggiungi Esercizio", isPresented: $showExerciseAlert, actions: {
                                TextField("Inserisci nome", text: $textBuffer)
                                Button("Ok", action: onAdd)
                            })
                        }
                        Spacer()
                    }
                }
            
        }
    }
    
    func onAdd() {
        appData.Exlist.append(ExList(id: "1-\(appData.Exlist.count)", name: textBuffer))
        textBuffer=""
        searchingText=""
        
        appData.SaveSettings()
    }
    
    //Modify by ID
    private func onEdit() {
        var exactIndex = 0
        var index = 0
        //Ciclo tra tutti gli esercizi
        for ex in appData.Exlist{
            //Cerco l'id dell'esercizio corrisponde all'elemento della lista
            if (ex.id == selectedItem){
                exactIndex=index
            }
            index+=1
        }
        
        appData.Exlist[exactIndex].name=textBuffer
        textBuffer=""
        
        appData.SaveSettings()
    }
    
    //Delete by ID
    private func onDelete(id: String) {
        var exactIndex=0 //Indice corretto da eliminare
        var index = 0
        //Ciclo tra tutti gli esercizi
        for ex in appData.Exlist{
            //Cerco l'id dell'esercizio corrisponde all'elemento della lista
            if (ex.id == id){
                exactIndex=index
            }
            index+=1
        }
        appData.DeleteExFromWorkout(exID: appData.Exlist[exactIndex].id)
        appData.Exlist.remove(at: exactIndex)
        
        appData.SaveSettings()
        appData.SaveWorkouts()
    }
    
    struct ExerciseList_Previews: PreviewProvider {
        static var previews: some View {
            ExerciseList(isSelecting: false, selectedWorkout: 0)
                .environmentObject(AppData())
        }
    }
}
