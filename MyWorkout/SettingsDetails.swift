//
//  SettingsDetails.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 23/01/23.
//

import SwiftUI

struct SettingsDetails: View {
    @EnvironmentObject var appData : AppData
    
    @State var isImporting = false
    @State var isExporting = false
    
    let timeArray = (0...300).filter { number -> Bool in
        return number % 10 == 0}
    
    var body: some View {
        NavigationStack{
            List{
                Section{
                    Toggle("Recupero di fine esercizio", isOn: $appData.SettingsData.lastREST)
                    DisclosureGroup(
                        content:{
                            Picker("Tempo default di Recupero", selection: $appData.SettingsData.defaultREST){
                                ForEach(timeArray, id: \.self) {
                                        Text("\($0)s")
                                    }
                            }
                            .pickerStyle(WheelPickerStyle())},
                        label: {
                            HStack{Text("Tempo recupero di Default"); Spacer();Text("\(appData.SettingsData.defaultREST)s").foregroundColor(.accentColor)}
                        }
                    )
                    Toggle("Sistema Imperiale", isOn: $appData.SettingsData.imperial)
                    NavigationLink{
                        ExerciseList(isSelecting: false)
                    }label: {
                        Text("Tutti gli Esercizi")
                    }
                }
                header:{
                    HStack{
                        Spacer()
                        Text("Impostazioni Generali")
                        Spacer()
                    }
                }
                
                Section{
                    HStack{
                        Button(action: {isImporting.toggle()}){
                            Spacer(); Image(systemName: "square.and.arrow.down"); Text("Importa"); Spacer()
                        }
                        .fileImporter(isPresented: $isImporting, allowedContentTypes: [.json], allowsMultipleSelection: false,
                            onCompletion: { result in
                                do {
                                    guard let selectedFile: URL = try result.get().first else { return }
                                    guard let message = String(data: try Data(contentsOf: selectedFile), encoding: .utf8) else { return }
                                    
                                    appData.workoutFiles.text = message
                                } catch {
                                    // Handle failure.
                                }
                            })
                        Button(action: {isExporting.toggle()}){
                            Spacer(); Text("Esporta"); Image(systemName: "square.and.arrow.up"); Spacer()
                        }
                        .fileExporter(isPresented: $isExporting, document: appData.workoutFiles, contentType: .json, onCompletion: { result in
                            switch result {
                                case .success(let url):
                                    print("Saved to \(url)")
                                case .failure(let error):
                                    print(error.localizedDescription)
                            }
                        })
                    }
                    .foregroundColor(.black)
                    .buttonStyle(.borderedProminent)
                }
                header:{
                    HStack{
                        Spacer()
                        Text("Trasferisci i tuoi piani d'allenamento")
                        Spacer()
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Impostazioni")
        }
        
    }
}

struct SettingsDetails_Previews: PreviewProvider {
    static var previews: some View {
        SettingsDetails()
            .environmentObject(AppData())
    }
}
