import SwiftUI
import UIKit
internal import CoreLocation

struct SettingsTab: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var locationService: LocationService

    @AppStorage("remindersEnabled") private var notificationsEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 9
    @AppStorage("reminderMinute") private var reminderMinute = 0
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true

    @AppStorage("tapFrenzyHighScore") private var tapFrenzyHighScore = 0
    @AppStorage("lightItUpHighScore") private var lightItUpHighScore = 0
    @AppStorage("quizRushHighScore") private var quizRushHighScore = 0

    @State private var showResetConfirmation = false
    @State private var showPermissionDeniedAlert = false

    // Backed by AppStorage hour/minute so the picker reflects the real
    // scheduled time even after the app has been relaunched.
    private var reminderTimeBinding: Binding<Date> {
        Binding<Date>(
            get: {
                var components = DateComponents()
                components.hour = reminderHour
                components.minute = reminderMinute
                return Calendar.current.date(from: components) ?? Date()
            },
            set: { newValue in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                reminderHour = components.hour ?? 9
                reminderMinute = components.minute ?? 0
                NotificationService.shared.scheduleDailyReminder(at: newValue)
            }
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.1).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 22) {
                        SettingsSection(title: "High Scores", icon: "trophy.fill", tint: .yellow) {
                            HStack(spacing: 10) {
                                ScoreBadge(title: "TAP", score: tapFrenzyHighScore, glowColor: .blue)
                                ScoreBadge(title: "LIGHT", score: lightItUpHighScore, glowColor: .cyan)
                                ScoreBadge(title: "QUIZ", score: quizRushHighScore, glowColor: .green)
                            }
                        }

                        SettingsSection(title: "Daily Challenge", icon: "bell.badge.fill", tint: .pink) {
                            VStack(spacing: 16) {
                                Toggle(isOn: $notificationsEnabled) {
                                    Label("Enable Reminders", systemImage: "bell.fill")
                                        .foregroundColor(.white)
                                }
                                .tint(.pink)
                                .onChange(of: notificationsEnabled) { isEnabled in
                                    if isEnabled {
                                        NotificationService.shared.requestPermission { granted in
                                            if granted {
                                                NotificationService.shared.scheduleDailyReminder(at: reminderTimeBinding.wrappedValue)
                                            } else {
                                                notificationsEnabled = false
                                                showPermissionDeniedAlert = true
                                            }
                                        }
                                    } else {
                                        NotificationService.shared.cancelNotifications()
                                    }
                                }

                                if notificationsEnabled {
                                    Divider().background(Color.white.opacity(0.1))
                                    DatePicker(
                                        selection: reminderTimeBinding,
                                        displayedComponents: .hourAndMinute
                                    ) {
                                        Label("Reminder Time", systemImage: "clock.fill")
                                            .foregroundColor(.white)
                                    }
                                    .datePickerStyle(.compact)
                                    .tint(.pink)

                                    Divider().background(Color.white.opacity(0.1))
                                    Button {
                                        NotificationService.shared.sendTestNotification()
                                    } label: {
                                        Label("Send Test Reminder Now", systemImage: "paperplane.fill")
                                            .font(.subheadline)
                                            .foregroundColor(.pink)
                                    }
                                }
                            }
                        }

                        SettingsSection(title: "Game Preferences", icon: "gamecontroller.fill", tint: .cyan) {
                            Toggle(isOn: $hapticsEnabled) {
                                Label("Haptic Feedback", systemImage: "waveform")
                                    .foregroundColor(.white)
                            }
                            .tint(.cyan)
                        }

                        SettingsSection(title: "Location", icon: "location.fill", tint: .purple) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: locationIcon)
                                        .foregroundColor(locationColor)
                                    Text(locationStatusText)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                    Spacer()
                                }

                                Text("Used to pin your games on the Map tab.")
                                    .font(.caption)
                                    .foregroundColor(.gray)

                                if locationService.authorizationStatus == .denied
                                    || locationService.authorizationStatus == .restricted {
                                    Button {
                                        if let url = URL(string: UIApplication.openSettingsURLString) {
                                            UIApplication.shared.open(url)
                                        }
                                    } label: {
                                        Text("Open Settings")
                                            .font(.subheadline).bold()
                                            .foregroundColor(.purple)
                                    }
                                }
                            }
                        }

                        SettingsSection(title: "Data Management", icon: "trash.fill", tint: .red) {
                            Button(role: .destructive) {
                                showResetConfirmation = true
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("Reset All Statistics")
                                    Spacer()
                                }
                                .foregroundColor(.red)
                            }
                        }

                        SettingsSection(title: "About", icon: "info.circle.fill", tint: .white) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Version").foregroundColor(.white.opacity(0.7))
                                    Spacer()
                                    Text(appVersionString).foregroundColor(.white.opacity(0.5))
                                }
                                HStack {
                                    Text("Games").foregroundColor(.white.opacity(0.7))
                                    Spacer()
                                    Text("Tap Frenzy · Light It Up · Quiz Rush")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Settings")
            .preferredColorScheme(.dark)
            .onAppear {
                // If the person revoked notification access from iOS Settings
                // directly, reflect that here instead of showing a toggle
                // that's silently lying about reminders being active.
                NotificationService.shared.currentlyAuthorized { authorized in
                    if notificationsEnabled && !authorized {
                        notificationsEnabled = false
                    }
                }
            }
            .alert("Reset All Statistics?", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    sessionManager.resetStats()
                    tapFrenzyHighScore = 0
                    lightItUpHighScore = 0
                    quizRushHighScore = 0
                }
            } message: {
                Text("This clears every saved session, map pin, and high score. This can't be undone.")
            }
            .alert("Notifications Disabled", isPresented: $showPermissionDeniedAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("PlayHub needs notification permission to send daily reminders. You can enable it in iOS Settings.")
            }
        }
    }

    private var locationStatusText: String {
        switch locationService.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse: return "Location access granted"
        case .denied: return "Location access denied"
        case .restricted: return "Location access restricted"
        case .notDetermined: return "Location access not yet requested"
        @unknown default: return "Unknown status"
        }
    }

    private var locationIcon: String {
        switch locationService.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse: return "checkmark.circle.fill"
        case .denied, .restricted: return "xmark.circle.fill"
        default: return "questionmark.circle.fill"
        }
    }

    private var locationColor: Color {
        switch locationService.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse: return .green
        case .denied, .restricted: return .red
        default: return .yellow
        }
    }

    private var appVersionString: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

private struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let tint: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: icon).foregroundColor(tint)
                Text(title.uppercased())
                    .font(.caption).bold()
                    .foregroundColor(tint)
            }
            content
        }
        .padding(18)
        .background(Color.white.opacity(0.05))
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(tint.opacity(0.3), lineWidth: 1))
    }
}
