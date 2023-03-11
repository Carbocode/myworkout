//
//  ExExecution.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 04/03/23.
//

import SwiftUI
import AudioToolbox
import Combine

struct ExExecution: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var appData : AppData
    @EnvironmentObject var date : TimerData
    
    @Binding var workout: Workout
    @Binding var index: Int
    @Binding var details: [VisualSet]
    
    @State var time = 0
    @State var currentSet = 0
    @State var miniSet = 1
    @State var timerRunning = false
    
    @GestureState var isFailed = false
    @GestureState var isSkip = false
    @GestureState var isDone = false
    
    @Binding var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    
    let generator = UINotificationFeedbackGenerator()
    
    var body: some View {
        let kgLb: String = (UserDefaults.standard.bool(forKey: "imperial") ? "lb" : "Kg")
        NavigationStack{
            VStack{
                ZStack{
                    TimerClock(time: $time, startTime: .constant(workout.exercises[index].rest))
                        .onReceive(timer){ time in
                            if timerRunning {
                                if self.time != workout.exercises[index].rest{
                                    self.time+=1
                                }else{
                                    AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)){}
                                    NextEx()
                                }
                            }
                        }
                    
                    //MARK: - Skip
                    Label("Skip", systemImage: "forward.fill")
                        .gesture(LongPressGesture(minimumDuration: 0.6)
                            .updating($isSkip) { currentState, gestureState, transaction in
                                gestureState = currentState
                                generator.notificationOccurred(.success)
                            }
                            .onEnded { value in
                                NextEx()
                                generator.notificationOccurred(.success)
                            })
                        .padding()
                        .background(.thinMaterial)
                        .cornerRadius(10)
                        .opacity(!timerRunning ? 0 : 1)
                        .scaleEffect(isSkip ? 1.2 : 1)
                        .animation(.spring(response: 0.2, dampingFraction: 0.3), value: isSkip)
                        .padding(.top, 150)
                        .font(.headline)
                        .foregroundColor(.yellow)
                    
                    //MARK: - Fatto
                    Label("Fatto", systemImage: "forward.end.fill")
                        .background(Circle()
                            .fill(timerRunning ? Color.gray : Color.accentColor)
                            .frame(width: 280, height: 280)
                            .overlay(
                                Circle()
                                        .stroke(Color.gray, lineWidth: 20)
                                        .blur(radius: 6)
                                        .opacity(0.5)
                                        .offset(x: 2, y: 2)
                                        .mask(Circle().fill(LinearGradient(Color.black, Color.clear)))
                                )
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 20)
                                    .blur(radius: 6)
                                    .opacity(0.5)
                                    .offset(x: -4, y: -4)
                                    .mask(Circle().fill(LinearGradient(Color.clear, Color.black)))
                            ))
                        .gesture(LongPressGesture(minimumDuration: 0.6)
                            .updating($isDone) { currentState, gestureState, transaction in
                                gestureState = currentState
                                generator.notificationOccurred(.success)
                            }
                            .onEnded { value in
                                timerRunning.toggle()
                                
                                UNUserNotificationCenter.current().requestAuthorization(options: [.badge,.sound,.alert])
                                { (_, _) in}
                                
                                UNUserNotificationCenter.current().delegate = date
                                
                                if workout.exercises[index].rest>0{
                                    performNotification()
                                }
                                
                                generator.notificationOccurred(.success)
                            })
                        .padding()
                        .foregroundColor(.black)
                        .font(.title)
                        .opacity(timerRunning ? 0 : 1)
                        .scaleEffect(isDone ? 0.9 : 1)
                        .animation(.spring(response: 0.1, dampingFraction: 0.6), value: isDone)
                }
                Label("Fallito", systemImage: "xmark.circle.fill")
                    .gesture(LongPressGesture(minimumDuration: 0.6)
                    .updating($isFailed) { currentState, gestureState, transaction in
                        gestureState = currentState
                        generator.notificationOccurred(.success)
                    }
                    .onEnded { value in
                        timerRunning.toggle()
                        generator.notificationOccurred(.success)
                    })
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(10)
                    .opacity(timerRunning ? 0 : 1)
                    .scaleEffect(isFailed ? 1.2 : 1)
                    .animation(.spring(response: 0.2, dampingFraction: 0.3), value: isFailed)
                    .font(.headline)
                    .foregroundColor(.red)
                
                HStack{
                    if details.count>0{
                        Text("\(details[0].nSets)\(details[0].text)").padding(.leading, 25).padding(.trailing, 15).frame(height: 70).background(.blue).font(.custom("", size: 20))
                        HStack{
                            Text("\(miniSet)/\(details[1].nSets)")
                            Text("\(details[1].text)")
                            if workout.exercises[index].sets[currentSet].weight > 0 {
                                Text("\(workout.exercises[index].sets[currentSet].weight, specifier: "%.1f")\(kgLb)").font(.title3)
                            }
                            Spacer()
                        }.frame(height: 70).background(Color.darkEnd).font(.custom("", size: 30))
                    }
                }
                HStack{
                    HStack{
                        Text("Next:")
                        if details.count>2{
                            ForEach(2..<details.count, id:\.self) { i in
                                Text("\(details[i].nSets)\(details[i].text)")
                                    .padding(3)
                                    .foregroundColor(.white)
                                    .background(Rectangle()
                                        .foregroundColor(details[2].color)
                                        .cornerRadius(5))
                                    .padding(.trailing, -5.0)
                            }
                        }
                    }
                    .frame(height: 10)
                    .padding()
                    .font(.footnote)
                    .fontWeight(.heavy)
                }
                .padding(.bottom,100)
                
            }
            .navigationBarTitle(appData.ReturnName(unkID: workout.exercises[index].exID), displayMode: .inline)
            .background(LinearGradient(Color.darkStart, Color.darkEnd))
            .scrollContentBackground(.hidden)
        }
        .edgesIgnoringSafeArea(.all)
        .foregroundColor(.primary)
        .preferredColorScheme(.dark)
        .onAppear{
            details=appData.ExDetails(ex: workout.exercises[index])
        }
        .onChange(of: index){ _ in
            details=appData.ExDetails(ex: workout.exercises[index])
        }
        
    }
    
    func performNotification() {
        let content = UNMutableNotificationContent()
        content.title = "MyWorkout Timer"
        content.body = "Timer finito!!!!!"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(workout.exercises[index].rest), repeats: false)
        
        let request = UNNotificationRequest(identifier: "TIMER", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (err) in
            if err != nil {
                print(err!.localizedDescription)
            }
            
        }
    }
    
    func NextEx(){
        timerRunning.toggle()
        let set = workout.exercises[index].sets[currentSet].nSets
        if miniSet < set {
            miniSet+=1
            time=0
            details[0].nSets-=1
        }
        else if (currentSet+1) < workout.exercises[index].sets.count{
            if details.count>2{
                details.remove(at: 1)
            }
            currentSet+=1
            miniSet=1
            time=0
            details[0].nSets-=1
        }
        else{
            /*if (index+1) < workout.exercises.count {
                time=0
                miniSet=1
                currentSet=0
                index+=1
            }
            else{*/
                dismiss()
            //}
            
        }
    }
}

struct ExExecution_Previews: PreviewProvider {
    static var previews: some View {
        ExExecution(
            workout: .constant(AppData().Workouts[0]),
            index: .constant(0),
            details: .constant(AppData().ExDetails(ex: AppData().Workouts[0].exercises[0])),
            timer: .constant(Timer.publish(every: 1, on: .main, in: .common).autoconnect())
        )
        .environmentObject(AppData())
        .environmentObject(TimerData())
    }
}
