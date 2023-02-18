//
//  SettingsDetails.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 23/01/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct JSONFile: FileDocument {
    static var readableContentTypes = [UTType.json]
    static var writableContentTypes = [UTType.json]

    //Contenuto File
    var text = ""

    //Initializer
    init(initialText: String = "") {
        text = initialText
    }

    // this initializer loads data that has been saved previously
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        }
    }

    // this will be called when the system wants to write our data to disk
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: Data(text.utf8))
    }
}

struct SettingsDetails: View {
    @EnvironmentObject var appData : AppData
    
    //File per import/export di dati
    @State private var workoutFile = JSONFile()
    @State private var exlistFile = JSONFile()
    
    @State private var isImporting = false //Avvio importazione
    @State private var isExporting = false //Avvio esportazione
    
    //Impostazioni utente
    @AppStorage("defaultRest", store: .standard) private var defaultRest = 90
    @AppStorage("lastRest", store: .standard) private var lastRest = true
    @AppStorage("imperial", store: .standard) private var imperial = false
    
    
    let timeArray = (0...300).filter { number -> Bool in
        return number % 10 == 0}
    
    var body: some View {
        NavigationStack{
            List{
                Section{
                    Toggle("Recupero di fine esercizio", isOn: $lastRest)
                    DisclosureGroup(
                        content:{
                            Picker("Tempo default di Recupero", selection: $defaultRest){
                                ForEach(timeArray, id: \.self) {
                                        Text("\($0)s")
                                    }
                            }
                            .pickerStyle(WheelPickerStyle())},
                        label: {
                            HStack{Text("Tempo recupero di Default"); Spacer();Text("\(defaultRest)s").foregroundColor(.accentColor)}
                        }
                    )
                    
                    Toggle("Sistema Imperiale", isOn: $imperial)
                        
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
                            onCompletion: { (result) in
                                do {
                                    guard let selectedFile: URL = try result.get().first else {return} //prendo URL
                                    appData.Workouts = Bundle.main.import([Workout].self, from: selectedFile) //Decodifico contenuto
                                    appData.SaveWorkouts() //Salvo il contenuto importato
                                } catch {
                                    print("Error reading doc")
                                    print(error.localizedDescription)
                                }
                            })
                        Button(action: {
                            workoutFile.text = Bundle.main.encode(appData.Workouts) //Aggiorno il contenuto
                            isExporting.toggle() //Avvio esportazione
                            
                        }){
                            Spacer(); Text("Esporta"); Image(systemName: "square.and.arrow.up"); Spacer()
                        }
                        .fileExporter(isPresented: $isExporting, document: workoutFile, contentType: .json, onCompletion: { result in
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
