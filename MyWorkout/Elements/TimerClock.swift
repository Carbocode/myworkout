//
//  Timer.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 02/03/23.
//

import SwiftUI

struct TimerClock: View {
    
    @Binding var time: Int
    @Binding var startTime: Int
    
    var body: some View {
            //MARK: - Timer
            ZStack{
                //MARK: - Frame
                Circle()
                    .fill(LinearGradient(Color.darkEnd, Color.darkStart))
                    .frame(width: 330)
                    .shadow(color: Color.darkEnd.opacity(0.7), radius: 10, x: 10, y: 10)
                    .shadow(color: Color.darkStart.opacity(1), radius: 10, x: -5, y: -5)
                    .overlay(
                        ForEach(1...60, id:\.self){ i in
                                Rectangle()
                                    .frame(width: 2, height: i % 5 == 0 ? 15: 5)
                                    .offset(y: (365-60)/2)
                                    .rotationEffect(.degrees(Double(i)*6))
                                    .foregroundColor(.gray)
                                    .shadow(radius: 5)
                            
                        }
                        
                    )
                //MARK: - Display
                Circle()
                    .fill(Color.darkEnd)
                    .frame(width: 280)
                //MARK: - RoundBar
                Circle()
                    .rotation(.degrees(-90))
                    .stroke(style:StrokeStyle(lineWidth: 15))
                    .foregroundColor(Color.darkStart)
                    .opacity(0.2)
                    .frame(width: 265)
                //MARK: - RoundBar Background
                let vTime = startTime-time
                Circle()
                    .trim(from:lineCalc(time: time, startTime: startTime), to:1)
                    .rotation(.degrees(-90))
                    .stroke(style:StrokeStyle(lineWidth: 15, lineCap: .round))
                    .foregroundColor(.accentColor)
                    .frame(width: 265)
                    .overlay(
                        HStack(alignment: .bottom){
                            Text("\(vTime/100)")
                                .font(.custom("alarm clock", size: 85))
                                .frame(width: 55, alignment: .center)
                                .padding(-5)
                            Text("\(vTime/10%10)")
                                .font(.custom("alarm clock", size: 85))
                                .frame(width: 55, alignment: .center)
                                .padding(-5)
                            Text("\(vTime%10)")
                                .font(.custom("alarm clock", size: 85))
                                .frame(width: 55, alignment: .center)
                                .padding(-5)
                            Text("00")
                                .font(.custom("alarm clock", size: 35))
                                .frame(width: 55, alignment: .center)
                                .padding(-5)
                        }
                        .foregroundColor(.white)
                    )
            }
    }
    
    func lineCalc(time: Int, startTime: Int) -> CGFloat {
        let perc: Float = ((Float(time*100)/Float(startTime))/100)
        return CGFloat(perc)
    }
}

struct TimerClock_Previews: PreviewProvider {
    static var previews: some View {
        TimerClock(time: .constant(78), startTime: .constant(120))
    }
}
