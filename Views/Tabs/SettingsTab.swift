
import SwiftUI

struct SettingsTab: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var reminderTime = Date()
    @State private var notificationsEnabled = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Daily Challenge")) {
                    Toggle("Enable Reminders", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { isEnabled in
                            if isEnabled {
                                NotificationService.shared.requestPermission()
                                NotificationService.shared.scheduleDailyReminder(at: reminderTime)
                            } else {
                                NotificationService.shared.cancelNotifications()
                            }
                        }
                    
                    if notificationsEnabled {
                        DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                            .onChange(of: reminderTime) { newTime in
                                NotificationService.shared.scheduleDailyReminder(at: newTime)
                            }
                    }
                }
                
                Section(header: Text("Data Management")) {
                    Button(role: .destructive) {
                        sessionManager.resetStats()
                    } label: {
                        Text("Reset All Statistics")
                    }
                }
            }
            .navigationTitle("Settings")
            .preferredColorScheme(.dark)
        }
    }
}
