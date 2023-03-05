//
//  BeginWorkout.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 25/02/23.
//

import SwiftUI
import UserNotifications

class TimerData: NSObject, UNUserNotificationCenterDelegate, ObservableObject {
    @Published var leftTime: Date = Date()
    
    //Action when app in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    //On Tap
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}

struct BeginWorkout: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appData : AppData
    
    @StateObject var date = TimerData()
    
    var index: Int
    
    @State var enlapsedSeconds = 0
    @State var enlapsedMinutes = 0
    
    @Environment(\.scenePhase) var scene
    
    var body: some View {
        ZStack{
            NavigationStack{
                List{
                    Section{
                        let exercises = appData.Workouts[index].exercises
                        ForEach(Array(exercises.enumerated()), id: \.element){ i, exercise in
                            let exName = appData.ReturnName(unkID: exercise.exID)
                            NavigationLink(destination:
                                            ExExecution(workIndex: index, index: i, name: exName).environmentObject(date)
                            ){
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
                                            ForEach(ExDetails(ex: exercise)){ visualSet in
                                                Text(visualSet.text)
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
                .background(LinearGradient(Color.darkStart, Color.darkEnd))
                .scrollContentBackground(.hidden)
                .listStyle(.inset)
                .navigationTitle(appData.Workouts[index].name)
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
                .background(.ultraThinMaterial)
                .cornerRadius(5)
                .shadow(radius: 10)
                .font(.headline)
                .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()){ time in
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
        .preferredColorScheme(.dark)
        .onChange(of: scene){ (newScene) in
            if newScene == .background{
                print("BG")
            }
            
        }
    }
    
    private func ExDetails(ex: Exercise) -> [VisualSet]{
        var visualSets : [VisualSet] = []
        var totalSets = 0
        visualSets.append(VisualSet(text: "", color: Color(.systemBlue)))
        for set in ex.sets {
            totalSets+=set.nSets
            if set.nSets != 1{
                
                visualSets.append(VisualSet(text: "\(set.nSets)x"))
            }else{
                visualSets.append(VisualSet(text: ""))
            }
            
            if ex.dropSet == 0 {
                visualSets[visualSets.count-1].text+="\(set.reps)"
            }else{
                visualSets[visualSets.count-1].color = Color(.systemRed)
                visualSets[visualSets.count-1].text+=""
                
                visualSets[visualSets.count-1].text+="("
                var drop = set.reps
                while(drop >= ex.dropSet){
                    visualSets[visualSets.count-1].text+="\(ex.dropSet)"
                    drop-=ex.dropSet
                    if (drop >= ex.dropSet){
                        visualSets[visualSets.count-1].text+="+"
                    }
                }
                visualSets[visualSets.count-1].text+=")"
            }
        }
        visualSets[0].text="\(totalSets) Sets"
        
        return visualSets
    }
}

struct BeginWorkout_Previews: PreviewProvider {
    static var previews: some View {
        BeginWorkout(index: 0)
            .environmentObject(AppData())
    }
}
