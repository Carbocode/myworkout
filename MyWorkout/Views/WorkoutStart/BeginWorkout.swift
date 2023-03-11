//
//  BeginWorkout.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 25/02/23.
//

import SwiftUI

struct BeginWorkout: View {
    @EnvironmentObject var appData : AppData
    @EnvironmentObject var date : TimerData
    @Environment(\.dismiss) private var dismiss
    
    @State var workout : Workout
    
    @State var enlapsedSeconds = 0
    @State var enlapsedMinutes = 0
    @State var visualSet: [VisualSet] = []
    @State var startEx = false
    @State var selectedItem = 0
    
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack{
            NavigationStack{
                List{
                    Section{
                        let exercises = workout.exercises
                        ForEach(Array(exercises.enumerated()), id: \.element){ i, exercise in
                            let exName = appData.ReturnName(unkID: exercise.exID)
                            Button(action: {
                                selectedItem=i; startEx.toggle()
                            }){
                                HStack{
                                    ZStack{
                                        if exercise.superset{
                                            Rectangle().fill(Color.accentColor).frame(width: 5)
                                                .padding(.top, 40).cornerRadius(5)
                                        }
                                        if i != 0 {
                                            if exercises[i-1].superset{
                                                Rectangle().fill(Color.accentColor).frame(width: 5)
                                                    .padding(.bottom, 40).cornerRadius(5)
                                            }
                                        }
                                        
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
                                        // MARK: - Name
                                        HStack{
                                            Text("\(i+1)°").font(.headline)
                                            //ExName
                                            Text(exName)
                                                .foregroundColor(.accentColor)
                                                .font(.body)
                                                .fontWeight(.bold)
                                        }
                                        
                                        // MARK: - Sets x Reps
                                        HStack{
                                            ForEach(appData.ExDetails(ex: workout.exercises[i])){ visualSet in
                                                Text("\(visualSet.nSets)\(visualSet.text)")
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
                                        
                                    }
                                    .padding()
                                }
                            }
                            .listRowSeparatorTint(.gray)
                            .listRowBackground(Color.darkEnd)
                        }
                        Rectangle()
                            .frame(height: 50)
                            .opacity(0).listRowBackground(Color.clear).listRowSeparatorTint(.clear)
                    }
                    header:{
                        HStack{
                            Image(systemName: "list.bullet.clipboard.fill")
                            Text("Scegli Esercizio")
                        }
                        .font(.title2)
                    }
                }
                .navigationDestination(isPresented: $startEx){ExExecution(workout: $workout, index: $selectedItem, details: $visualSet, timer: $timer)}
                .background(LinearGradient(Color.darkStart, Color.darkEnd))
                .scrollContentBackground(.hidden)
                .listStyle(.inset)
                .navigationTitle(workout.name)
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
                        .font(.title3)
                        .fontWeight(.heavy)
                    Spacer()
                    ZStack{
                        HStack{
                            Text(" ")
                                .frame(width: 30)
                                .background(Color.red).padding(.trailing, -6.0)
                            Text(" ")
                                .frame(width: 30)
                                .background(Color.white).padding(.bottom, 0.0)
                            Text(":").frame(width: 7)
                            Text("8").frame(width: 20)
                            Text("8").frame(width: 20)
                        }
                        .foregroundColor(Color.darkStart)
                        .padding(5)
                        .background(Color.darkEnd)
                        HStack{
                            Text("\(enlapsedMinutes/10)")
                                .frame(width: 30).padding(.trailing, -6.0)
                            Text("\(enlapsedMinutes%10)")
                                .frame(width: 30)
                                .foregroundColor(.black).padding(.bottom, 0.0)
                            Text(":").frame(width: 7)
                            Text("\(enlapsedSeconds/10)").frame(width: 20)
                            Text("\(enlapsedSeconds%10)").frame(width: 20)
                        }
                        .foregroundColor(.white)
                        
                    }
                    .font(.custom("alarm clock", size: 40))
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .background(.regularMaterial)
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
        }
        .foregroundColor(.primary)
        .preferredColorScheme(.dark)
    }
}

struct BeginWorkout_Previews: PreviewProvider {
    static var previews: some View {
        BeginWorkout(workout: AppData().Workouts[0])
            .environmentObject(AppData())
            .environmentObject(TimerData())
    }
}
