//
//  MyWorkoutApp.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 12/01/23.
//

import SwiftUI
import UserNotifications

//MARK: - Colors used for styling
extension Color {
    static let darkStart = Color(red: 50 / 255, green: 60 / 255, blue: 65 / 255)
    static let darkEnd = Color(red: 25 / 255, green: 25 / 255, blue: 30 / 255)
    static let offWhite = Color(red: 225 / 255, green: 225 / 255, blue: 235 / 255)
}

//MARK: - Gradient Generator
extension LinearGradient {
    init(_ colors: Color...) {
        self.init(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

//MARK: - Timer Background handler
class TimerData: NSObject, UNUserNotificationCenterDelegate, ObservableObject {
    @Published var leftTime: Date = Date()
    @Published var timeDiff: Int = 0

    
    //Action when app in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    //On Tap
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}

@main
struct MyWorkoutApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate //App Delegator
    @Environment(\.scenePhase) var scene //Scene handler
    @StateObject private var appData = AppData()
    @StateObject var date = TimerData()
    
    @State var isBackground = false
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appData)
                .environmentObject(date)
        }
        .onChange(of: scene){ (newScene) in
            //If in background save the date
            if newScene == .background{
                date.leftTime = Date()
                
                isBackground = true
                print("BG")
            }
            
            //If returns in foreground returns the Time difference in seconds
            if isBackground{
                if newScene == .active{
                    date.timeDiff = Int(Date().timeIntervalSince(date.leftTime))
                    if date.timeDiff > 0 {
                        print("Time Enlapsed in BG: \(date.timeDiff)")
                    }
                    isBackground=false
                }
            }
        }
    }
    
    //MARK: - App Delegator
    class AppDelegate : UIResponder, UIApplicationDelegate {
        //Action when App Launches
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            print("App Launched")
            return true
        }
    }
}
