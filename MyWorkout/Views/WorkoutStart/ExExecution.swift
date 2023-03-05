//
//  ExExecution.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 04/03/23.
//

import SwiftUI

struct ExExecution: View {
    @EnvironmentObject var appData : AppData
    @EnvironmentObject var date : TimerData
    
    var workIndex: Int
    var index: Int
    var name: String
    
    @State var time = 0
    
    var body: some View {
        ZStack{
            LinearGradient(Color.darkStart, Color.darkEnd)
            VStack{
                TimerClock(time: $time, startTime: .constant(appData.Workouts[workIndex].exercises[index].rest))
                    .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()){ time in
                        if self.time != appData.Workouts[workIndex].exercises[index].rest{
                            self.time+=1
                        }
                    }
                    .onAppear(perform: {
                        UNUserNotificationCenter.current().requestAuthorization(options: [.badge,.sound,.alert])
                        { (_, _) in
                            
                        }
                        
                        UNUserNotificationCenter.current().delegate = date
                        
                        performNotification()
                    })
            }.navigationTitle(name)
            
        }.edgesIgnoringSafeArea(.all)
    }
    
    func performNotification() {
        let content = UNMutableNotificationContent()
        content.title = "MyWorkout Timer"
        content.body = "Timer finito!!!!!"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(appData.Workouts[workIndex].exercises[index].rest), repeats: false)
        
        let request = UNNotificationRequest(identifier: "TIMER", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (err) in
            if err != nil {
                print(err!.localizedDescription)
            }
            
        }
    }
}

struct ExExecution_Previews: PreviewProvider {
    static var previews: some View {
        ExExecution(workIndex: 0, index: 0, name: "Test")
            .environmentObject(AppData())
            .environmentObject(TimerData())
    }
}
