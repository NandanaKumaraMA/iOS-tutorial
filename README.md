# PlayHub iOS App

Welcome to **PlayHub**, a comprehensive, feature-rich iOS tutorial and mini-game hub application built entirely using **SwiftUI**, following the **MVVM (Model-View-ViewModel)** architectural pattern. 

This project demonstrates iOS development best practices, including native feature integration, custom UI component engineering, and clean application state management.

---

## 📱 Features & Game Modes

PlayHub comes loaded with three uniquely engineered mini-game modules alongside deep tab-based statistics and system management tools:

### 1. Mini-Game Hub
*   **Tap Frenzy:** A high-intensity, speed-based tapping challenge designed to test reflex thresholds with rapid state updates.
*   **Quiz Rush:** A dynamic trivia engine that loads questions with multiple-choice formats, maintaining timed scoring metrics.
*   **Light It Up:** A sequential pattern or toggle puzzle designed to test logic and memory retention using custom tile models.

### 2. Tab Navigation Structure
*   **🏠 Home Tab:** Central dashboard listing available mini-games, custom shortcuts, and immediate session access points.
*   **🗺️ Map Tab:** Demonstrates integration with Apple's **CoreLocation** and **MapKit**, tracking coordinates and rendering local geography.
*   **📊 Stats Tab:** Aggregates telemetry from historical game sessions, showing user performance charts and top scores.
*   **⚙️ Settings Tab:** Controls system-wide features like haptic configurations, notification policies, and persistent storage preferences.

### 3. Core Core Services & System Infrastructure
*   **Haptics Manager:** Uses native Taptic Engine patterns to give real-time sensory feedback on button triggers, correct answers, or game failures.
*   **Location Service:** Connects to system GPS configurations using secure authorization prompts to draw and refresh maps.
*   **Notification Service:** Dispatches local reminders and alerts to boost app engagement and display streak achievements.
*   **Session Manager:** Manages active game models, caching local achievements and passing stats instantly to the dashboard.

---

## 🛠️ System Architecture

The project strictly follows the **MVVM** pattern to maximize modularity, separation of concerns, and clean testability:

```
iOS-tutorial/
│
├── App/                  # App Entry Point (PlayHubApp.swift)
├── Models/               # Core Structs (Card, GameMode, GameSession, Level, TriviaQuestion)
├── ViewModels/           # Business Logic (LightItUpVM, QuizRushVM)
├── Services/             # Hardware & Storage (Haptics, Location, Notification, SessionManager)
└── Views/
    ├── Games/            # Interactive Views (TapFrenzyView, QuizRushView, LightItUpView)
    ├── Shared/           # Reusable Components (GameMenuButton, ResultView, ScoreBadge)
    └── Tabs/             # Primary Hub Interfaces (MainTabView, HomeTab, MapTab, StatsTab, SettingsTab)
```

---

## 🚀 Setup & Installation

### Prerequisites
*   A Mac running **macOS Sonoma** (or later)
*   **Xcode 15** or newer
*   **iOS 17+ SDK**

### Steps to Run
1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/yourusername/PlayHubApp.git
    cd PlayHubApp
    ```
2.  **Open the Project:**
    Locate `IOS Tutorial.xcodeproj` inside the project root and open it using Xcode.
3.  **Configure Target Signing:**
    Select the root project node, navigate to the **Signing & Capabilities** tab, and assign your Apple Development Team.
4.  **Select Device & Compile:**
    Choose an iOS Simulator (e.g., iPhone 15) or your connected physical device, then press `📋 + R` or click the **Play** button to build and execute.

---

## 🛡️ License

This project is open-source and available under the **MIT License**. Feel free to use it as a reference baseline for your personal or educational SwiftUI portfolios!
