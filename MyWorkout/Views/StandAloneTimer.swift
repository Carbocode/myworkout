//
//  StandAloneTimer.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 12/03/23.
//

import SwiftUI

struct StandAloneTimer: View {
    
    @State var totalTime = 0
    @State var time = 0
    
    @State var timerRunning = false
    
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let timeArray = (0...300).filter { number -> Bool in
        return number % 5 == 0}
    
    var body: some View {
        NavigationStack{
            VStack{
                Spacer()
                if timerRunning{
                    HStack{
                        Spacer()
                        TimerClock(time: $time, startTime: $totalTime)
                            .onReceive(timer){ time in
                                if timerRunning {
                                    if self.time != totalTime{
                                        self.time+=1
                                    }else{
                                        timerRunning.toggle()
                                        //AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)){}
                                    }
                                }
                            }
                        Spacer()
                    }
                }else{
                    HStack{
                        Picker("Tempo", selection: $totalTime){
                            ForEach(timeArray, id: \.self) {
                                Text("\($0)s").tag(Double($0))
                            }
                            
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    
                    Button("Start", action: {timerRunning.toggle()})
                        .buttonStyle(.bordered)
                        .disabled(totalTime != 0 ? false : true)
                }
                Spacer()
            }
            .background(LinearGradient(Color.darkStart, Color.darkEnd))
            .navigationBarTitle("Timer")
        }
        .edgesIgnoringSafeArea(.all)
        .foregroundColor(.primary)
        .preferredColorScheme(.dark)
        
    }
}


struct StandAloneTimer_Previews: PreviewProvider {
    static var previews: some View {
        StandAloneTimer()
    }
}
