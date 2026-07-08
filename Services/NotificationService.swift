
import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            if granted {
                print("Notification permission granted.")
            }
        }
    }
    
    func scheduleDailyReminder(at time: Date) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests() // Clear old ones
        
        let content = UNMutableNotificationContent()
        content.title = "Time to Play!"
        content.body = "Keep your streak alive! Come play a quick round on PlayHub."
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        
        center.add(request)
    }
    
    func cancelNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
