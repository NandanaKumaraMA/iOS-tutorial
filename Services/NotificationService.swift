import Foundation
import UserNotifications

class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()

    private override init() {
        super.init()
    }

    // MARK: - Permission

    /// Requests permission if needed, reporting whether reminders can actually
    /// be scheduled. Always calls back on the main thread.
    func requestPermission(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                DispatchQueue.main.async { completion(true) }
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                    if let error {
                        print("⚠️ Notification permission request failed: \(error.localizedDescription)")
                    }
                    DispatchQueue.main.async { completion(granted) }
                }
            case .denied:
                DispatchQueue.main.async { completion(false) }
            @unknown default:
                DispatchQueue.main.async { completion(false) }
            }
        }
    }

    /// Checks OS-level authorization without prompting — used to keep a
    /// Settings toggle in sync if the person revoked access outside the app.
    func currentlyAuthorized(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let authorized = settings.authorizationStatus == .authorized
                || settings.authorizationStatus == .provisional
                || settings.authorizationStatus == .ephemeral
            DispatchQueue.main.async { completion(authorized) }
        }
    }

    // MARK: - Scheduling

    func scheduleDailyReminder(at time: Date) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])

        let content = UNMutableNotificationContent()
        content.title = "Time to Play!"
        content.body = "Keep your streak alive! Come play a quick round on PlayHub."
        content.sound = .default

        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)

        center.add(request) { error in
            if let error {
                print("⚠️ Failed to schedule daily reminder: \(error.localizedDescription)")
            } else {
                print("✅ Daily reminder scheduled for \(components.hour ?? 0):\(components.minute ?? 0)")
            }
        }
    }

    /// Fires 5 seconds out — lets you verify reminders work without waiting up to 24 hours.
    func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time to Play!"
        content.body = "This is a preview of your daily reminder."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "testReminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("⚠️ Failed to send test notification: \(error.localizedDescription)")
            }
        }
    }

    func cancelNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])
    }

    // MARK: - UNUserNotificationCenterDelegate

    // Without this, a notification firing while the app is in the foreground
    // is delivered silently — no banner, no sound. This is the #1 reason a
    // reminder "looks like it's not sending" when tested with the app open.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}
