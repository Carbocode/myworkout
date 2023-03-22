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
    
    @State var warming = false
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
                Spacer()
                
                HStack{
                    ZStack{
                        Capsule()
                            .rotation(.degrees(180))
                            .fill(Color.darkEnd)
                            .frame(width: 150)
                            
                        ZStack{
                            Circle()
                                .fill(warming ? Color.red : Color.green)
                                .opacity(0.7)
                            warming ?
                            Text("🔥").font(.system(size: 50))
                            :
                            Text("🏋️").font(.system(size: 50))
                        }
                        .frame(height: 60)
                        .padding(.leading, 80)
                        
                    }
                    .frame(height: 70)
                    .padding(.leading, -75)
                    Spacer()
                }
                
                ZStack{
                    //MARK: - Timer
                    TimerClock(time: $time, startTime: .constant(workout.exercises[index].rest))
                        .onReceive(timer){ time in
                            if timerRunning {
                                if self.time < workout.exercises[index].rest{
                                    self.time+=1
                                }else{
                                    AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)){}
                                    NextEx()
                                }
                            }
                        }
                    
                    //MARK: - Skip
                    Image(systemName: "forward.fill")
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
                    
                    
                    ZStack{
                        //MARK: - Fatto
                        Image(systemName: "forward.end.fill")
                            .scaleEffect(isDone ? 0.7 : 1)
                            .animation(.spring(response: 0.1, dampingFraction: 0.35), value: isDone)
                            .padding(.leading, 135)
                            .background(Circle()
                                .trim(from: 0.5, to: 1)
                                .rotation(.degrees(90))
                                .fill(timerRunning ? Color.gray : Color.accentColor)
                                .frame(width: 280, height: 280))
                            .gesture(LongPressGesture(minimumDuration: 0.3)
                                .updating($isDone) { currentState, gestureState, transaction in
                                    gestureState = currentState
                                    generator.notificationOccurred(.success)
                                }
                                .onEnded { value in
                                    print("\(workout.exercises[index].rest)s Timer Started")
                                    
                                    timerRunning.toggle()
                                    
                                    UNUserNotificationCenter.current().requestAuthorization(options: [.badge,.sound,.alert])
                                    { (_, _) in}
                                    
                                    UNUserNotificationCenter.current().delegate = date
                                    
                                    if workout.exercises[index].rest>0{
                                        //performNotification()
                                    }
                                    
                                    generator.notificationOccurred(.success)
                                })
                            .opacity(timerRunning ? 0 : 1)
                            
                        //MARK: - Fallito (come me KEK)
                        Image(systemName: "xmark.circle.fill")
                            .scaleEffect(isFailed ?  0.7 : 1)
                            .animation(.spring(response: 0.1, dampingFraction: 0.35), value: isFailed)
                            .padding(.trailing, 135)
                            .background(Circle()
                                .trim(from: 0.5, to: 1)
                                .rotation(.degrees(-90))
                                .fill(timerRunning ? Color.gray : Color.red)
                                .frame(width: 280, height: 280))
                            .gesture(LongPressGesture(minimumDuration: 0.3)
                            .updating($isFailed) { currentState, gestureState, transaction in
                                gestureState = currentState
                                generator.notificationOccurred(.success)
                            }
                            .onEnded { value in
                                print("\(workout.exercises[index].rest)s Timer Started")
                                
                                timerRunning.toggle()
                                generator.notificationOccurred(.success)
                            })
                            .opacity(timerRunning ? 0 : 1)
                    }
                    .foregroundColor(.black)
                    .font(.system(size: 50))
                    if !timerRunning {
                        Circle()
                            .trim(from: 0.5, to: 1)
                            .rotation(.degrees(-45))
                            .stroke(Color.white, lineWidth: 40)
                            .frame(width: 280, height: 280)
                            .blur(radius: 10)
                            .opacity(0.2)
                            .mask(Circle())
                            
                        
                        Circle()
                            .trim(from: 0.5, to: 1)
                            .rotation(.degrees(135))
                            .stroke(Color.gray, lineWidth: 40)
                            .frame(width: 280, height: 280)
                            .blur(radius: 10)
                            .opacity(0.4)
                            .mask(Circle())
                    }
                    
                }
                .padding()
                
                if details.count>0{
                    ZStack{
                        HStack{
                            Spacer()
                            Text("\(details[0].nSets)")
                                .frame(width: 60, height: 70)
                                .background(Color.black)
                            
                            Spacer()
                            
                            HStack{
                                Text("\(miniSet)/\(details[1].nSets)")
                                Text("\(details[1].text)")
                            }
                            .frame(width: 170, height: 70)
                            .background(Color.black)
                            
                            Spacer()
                            
                            if workout.exercises[index].sets[currentSet].weight > 0 {
                                VStack(alignment: .trailing){
                                    Text("\(workout.exercises[index].sets[currentSet].weight, specifier: "%.1f")")
                                    Text(kgLb).font(.custom("alarm clock", size: 20))
                                }
                                
                                    .frame(width: 100, height: 70)
                                    .background(Color.black)
                            }
                            Spacer()
                        }
                        .font(.custom("alarm clock", size: 30))
                        .textCase(.uppercase)
                        
                        
                        HStack{
                            Spacer()
                            Text("SETS")
                            .frame(width: 60, height: 70)
                            .background(Color.clear)
                            
                            Spacer()
                            
                            Text("REPS")
                                .frame(width: 170, height: 70)
                                .background(Color.clear)
                            
                            Spacer()
                            
                            if workout.exercises[index].sets[currentSet].weight > 0 {
                                Text("PESO")
                                    .frame(width: 100, height: 70)
                                    .background(Color.clear)
                            }
                            Spacer()
                        }
                        .padding(.bottom, 70)
                        .font(.custom("alarm clock", size: 20))
                        .textCase(.uppercase)
                    }.background(Color.darkEnd)
                }
                HStack{
                    Text("Next:")
                    if details.count>2{
                        ForEach(2..<details.count, id:\.self) { i in
                            Text("\(details[i].nSets)\(details[i].text)")
                                .padding(3)
                                .background(Rectangle()
                                    .foregroundColor(details[2].color)
                                    .cornerRadius(5))
                        }
                    }
                }
                .frame(height: 15)
                .padding()
                .font(.footnote)
                .fontWeight(.heavy)
                
                Spacer()
            }
            .navigationBarTitle(appData.ReturnName(unkID: workout.exercises[index].exID), displayMode: .inline)
            .background(LinearGradient(Color.darkStart, Color.darkEnd))
            .scrollContentBackground(.hidden)
        }
        .edgesIgnoringSafeArea(.all)
        .foregroundColor(.primary)
        .preferredColorScheme(.dark)
        .onAppear{
            print("New EX Started")
            
            if !workout.exercises[index].warmingSets.isEmpty{
                warming=true
            }
            
            if warming{
                details=appData.ExDetails(sets: workout.exercises[index].warmingSets)
            }
            else{
                details=appData.ExDetails(sets: workout.exercises[index].sets)
            }
            
        }
        .onChange(of: index){ _ in
            if !workout.exercises[index].warmingSets.isEmpty{
                warming=true
            }
            
            if warming{
                details=appData.ExDetails(sets: workout.exercises[index].warmingSets)
            }
            else{
                details=appData.ExDetails(sets: workout.exercises[index].sets)
            }
        }
        .onChange(of: date.timeDiff){ _ in
            if timerRunning {
                print("\nEnlapsed:\t\(time) \t\t+")
                print("BG Time:\t\(date.timeDiff) \t\t=")
                print("-------------------")
                time += date.timeDiff
                print("\t\t\t\(time)\n")
            }
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
        
        time=0
        
        if warming{
            let set = workout.exercises[index].warmingSets[currentSet].nSets
            if miniSet < set {
                miniSet+=1
                details[0].nSets-=1
            }
            else if (currentSet+1) < workout.exercises[index].warmingSets.count{
                if details.count>2{
                    details.remove(at: 1)
                }
                currentSet+=1
                miniSet=1
                details[0].nSets-=1
            }
            else{
                miniSet=1
                currentSet=0
                details=appData.ExDetails(sets: workout.exercises[index].sets)
                warming.toggle()
            }
        }
        else{
            let set = workout.exercises[index].sets[currentSet].nSets
            if miniSet < set {
                miniSet+=1
                details[0].nSets-=1
            }
            else if (currentSet+1) < workout.exercises[index].sets.count{
                if details.count>2{
                    details.remove(at: 1)
                }
                currentSet+=1
                miniSet=1
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
}

struct ExExecution_Previews: PreviewProvider {
    static var previews: some View {
        ExExecution(
            workout: .constant(AppData().Workouts[0]),
            index: .constant(0),
            details: .constant(AppData().ExDetails(sets: AppData().Workouts[0].exercises[0].sets)),
            timer: .constant(Timer.publish(every: 1, on: .main, in: .common).autoconnect())
        )
        .environmentObject(AppData())
        .environmentObject(TimerData())
    }
}
