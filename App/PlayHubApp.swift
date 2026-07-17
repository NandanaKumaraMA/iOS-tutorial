//
//  IOS_TutorialApp.swift
//  IOS Tutorial
//
//  Created by student3 on 2026-06-06.
//

import SwiftUI

@main
struct IOS_TutorialApp: App {
    @StateObject private var sessionManager = SessionManager()
    @StateObject private var locationService = LocationService()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(sessionManager)
                .environmentObject(locationService)
        }
    }
}
