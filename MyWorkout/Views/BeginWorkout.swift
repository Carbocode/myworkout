//
//  BeginWorkout.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 25/02/23.
//

import SwiftUI

struct BeginWorkout: View {
    
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appData : AppData
    
    var index: Int
    
    @State private var showExSheet = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var enlapsedSeconds = 0
    @State var enlapsedMinutes = 0
    
    var body: some View {
        ZStack{
            NavigationStack{
                List{
                    Section{
                        let exercises = appData.Workouts[index].exercises
                        ForEach(Array(exercises.enumerated()), id: \.element){ i, exercise in
                            Button(action: {showExSheet.toggle()}){
                                VStack(alignment: .leading){
                                    // MARK: - Name
                                    HStack{
                                        Text("\(i+1)°").font(.headline)
                                        //ExName
                                        Text(appData.ReturnName(unkID: exercise.exID))
                                            .foregroundColor(.accentColor)
                                            .font(.body)
                                            .fontWeight(.bold)
                                    }
                                    
                                    // MARK: - Sets x Reps
                                    HStack{
                                        Text("\(exercise.sets.count) Sets")
                                            .padding(3)
                                            .foregroundColor(.white)
                                            .background(Rectangle().foregroundColor(.blue).cornerRadius(5))
                                        
                                        ForEach(ExDetails(ex: exercise)){ visualSet in
                                            Text(visualSet.text)
                                                .padding(3)
                                                .foregroundColor(.white)
                                                .background(Rectangle()
                                                    .foregroundColor(.gray)
                                                    .cornerRadius(5))
                                                .padding(.trailing, -5.0)
                                        }
                                        
                                    }
                                    .font(.footnote)
                                    .fontWeight(.heavy)
                                }
                                .padding()
                            }
                        }
                        Rectangle().frame(height: 50).opacity(0).listRowSeparator(.hidden)
                    }
                    header:{
                        HStack{
                            Image(systemName: "list.bullet.clipboard.fill")
                            Text("Scegli Esercizio")
                        }
                        .font(.title2)
                    }
                }
                .navigationTitle(appData.Workouts[index].name)
                .listStyle(.inset)
                .navigationBarItems(
                    leading:
                        Button("Esci", role: .cancel, action: {dismiss()})
                            .foregroundColor(.orange).fontWeight(.bold).font(.body),
                    trailing:
                        Button("Termina", role: .cancel, action: {dismiss()})
                        .foregroundColor(.accentColor).fontWeight(.bold).font(.body)
                    )
            }
            VStack{
                Spacer()
                HStack{
                    Text("Total Time: ")
                    Spacer()
                    Text("\(enlapsedMinutes) : \(enlapsedSeconds)")
                        .fontWeight(.heavy)
                        .foregroundColor(.accentColor)
                    Spacer()
                    Spacer()
                }
                .padding()
                .background(.thinMaterial)
                .cornerRadius(5)
                .shadow(radius: 10)
                .font(.headline)
                .onReceive(timer){ time in
                    if enlapsedSeconds == 59 {
                        enlapsedSeconds = 0
                        enlapsedMinutes += 1
                    }
                    else{
                        enlapsedSeconds+=1
                    }
                }
            }
            .padding()
            
        }
        
    }
    
    private func ExDetails(ex: Exercise) -> [VisualSet]{
        var repArray: [(Int, Int)] = [] //Array grafico di sets
        
        if ex.sets.count > 0 {
            var prevReps = 0
            for exSet in ex.sets{//Ciclo per ogni set
                if exSet.reps != prevReps { //Se set attuale diverso da precedente
                    repArray.append((exSet.reps, 1)) //Lo aggiungo all'array grafico
                    prevReps = exSet.reps //L'attuale diventa il precedente
                }else{
                    repArray[repArray.count-1].1 += 1
                }
            }
        }
        
        var visualSets : [VisualSet] = []
        for array in repArray {
            if ex.dropSet == 0 {
                visualSets.append(VisualSet(text:" \(array.0)"))
            }else{
                visualSets.append(VisualSet(text:" "))
                
                visualSets[visualSets.count-1].text+="("
                var drop = array.0
                while(drop >= ex.dropSet){
                    visualSets[visualSets.count-1].text+="\(ex.dropSet)"
                    drop-=ex.dropSet
                    if (drop >= ex.dropSet){
                        visualSets[visualSets.count-1].text+="+"
                    }
                }
                visualSets[visualSets.count-1].text+=")"
            }
            if array.1 != 1{
                visualSets[visualSets.count-1].text+="x\(array.1) "
            }else{
                visualSets[visualSets.count-1].text+=" "
            }
        }
        
        return visualSets
    }
}

struct BeginWorkout_Previews: PreviewProvider {
    static var previews: some View {
        BeginWorkout(index: 0)
            .environmentObject(AppData())
    }
}
