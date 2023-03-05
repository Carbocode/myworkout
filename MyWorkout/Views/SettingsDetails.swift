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
    @State private var showAddSheet = false
    
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
                            HStack{Text("Tempo recupero di Default"); Spacer();Text("\(defaultRest)s")
                                .foregroundColor(.accentColor).fontWeight(.bold)}
                        }
                    )
                    
                    Toggle("Sistema Imperiale", isOn: $imperial)
                        
                    Button("Tutti gli Esercizi", action: {showAddSheet.toggle()}).foregroundColor(.primary)
                    .sheet(isPresented: $showAddSheet){
                        ExerciseList(isSelecting: false, isSwitching: false, selectedExercise: Binding.constant(0))
                    }
                }
                header:{
                    HStack{
                        Spacer()
                        Text("Impostazioni Generali")
                        Spacer()
                    }
                }
                .listRowSeparatorTint(.gray)
                .listRowBackground(Color.darkEnd)
                
                Section{
                    HStack{
                        //MARK: - Import
                        Button(action: {isImporting.toggle()}){
                            HStack{Spacer(); Image(systemName: "square.and.arrow.down"); Text("Importa"); Spacer()}
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
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10)
                            .fill(Color.accentColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 4)
                                        .blur(radius: 4)
                                        .offset(x: 2, y: 2)
                                        .mask(RoundedRectangle(cornerRadius: 10).fill(LinearGradient(Color.black, Color.clear)))
                                )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: 8)
                                    .blur(radius: 4)
                                    .offset(x: -2, y: -2)
                                    .mask(RoundedRectangle(cornerRadius: 10).fill(LinearGradient(Color.clear, Color.black)))
                            ))
                        //MARK: - Export
                        Button(action: {
                            workoutFile.text = Bundle.main.encode(appData.Workouts) //Aggiorno il contenuto
                            isExporting.toggle() //Avvio esportazione
                            
                        }){
                            HStack{Spacer(); Text("Esporta"); Image(systemName: "square.and.arrow.up"); Spacer()}
                        }
                        .fileExporter(isPresented: $isExporting, document: workoutFile, contentType: .json, onCompletion: { result in
                            switch result {
                                case .success(let url):
                                    print("Saved to \(url)")
                                case .failure(let error):
                                    print(error.localizedDescription)
                            }
                        })
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10)
                            .fill(Color.accentColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 4)
                                        .blur(radius: 4)
                                        .offset(x: 2, y: 2)
                                        .mask(RoundedRectangle(cornerRadius: 10).fill(LinearGradient(Color.black, Color.clear)))
                                )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: 8)
                                    .blur(radius: 4)
                                    .offset(x: -2, y: -2)
                                    .mask(RoundedRectangle(cornerRadius: 10).fill(LinearGradient(Color.clear, Color.black)))
                            ))
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .font(.headline)
                    .foregroundColor(.black)
                    
                }
                header:{
                    HStack{
                        Spacer()
                        Text("Trasferisci i tuoi piani d'allenamento")
                        Spacer()
                    }
                }
                .listRowSeparatorTint(.gray)
                .listRowBackground(Color.darkEnd)
            }
            .background(LinearGradient(Color.darkStart, Color.darkEnd))
            .scrollContentBackground(.hidden)
            .shadow(color: Color.darkEnd.opacity(0.7), radius: 10, x: 10, y: 10)
            .shadow(color: Color.darkStart.opacity(1), radius: 10, x: -5, y: -5)
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
