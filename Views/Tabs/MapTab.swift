import SwiftUI
import MapKit

struct MapTab: View {
    @EnvironmentObject var sessionManager: SessionManager

    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var currentRegion: MKCoordinateRegion?

    private var pinnedSessions: [GameSession] {
        sessionManager.sessions.filter { $0.latitude != 0.0 || $0.longitude != 0.0 }
    }

    // A session plus the (possibly offset) coordinate it should actually be drawn at
    private struct PlacedSession: Identifiable {
        let id: UUID
        let mode: GameMode
        let coordinate: CLLocationCoordinate2D
    }

    // Groups sessions that landed at (roughly) the same spot and fans them out in a
    // small ring around the shared point so identical/near-identical markers don't
    // stack directly on top of one another and hide each other.
    private var placedSessions: [PlacedSession] {
        let grouped = Dictionary(grouping: pinnedSessions) { session in
            // ~11m precision — close enough to count as "the same spot"
            "\(round(session.latitude * 10_000))_\(round(session.longitude * 10_000))"
        }

        var result: [PlacedSession] = []
        for group in grouped.values {
            if group.count == 1, let only = group.first {
                result.append(PlacedSession(
                    id: only.id,
                    mode: only.mode,
                    coordinate: CLLocationCoordinate2D(latitude: only.latitude, longitude: only.longitude)
                ))
            } else {
                let center = CLLocationCoordinate2D(latitude: group[0].latitude, longitude: group[0].longitude)
                let radius = 0.00045 + Double(group.count) * 0.00004
                let latCorrection = max(cos(center.latitude * .pi / 180), 0.2)

                for (index, session) in group.enumerated() {
                    let angle = (2 * Double.pi / Double(group.count)) * Double(index)
                    let coordinate = CLLocationCoordinate2D(
                        latitude: center.latitude + radius * sin(angle),
                        longitude: center.longitude + (radius * cos(angle)) / latCorrection
                    )
                    result.append(PlacedSession(id: session.id, mode: session.mode, coordinate: coordinate))
                }
            }
        }
        return result
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Map(position: $cameraPosition) {
                    ForEach(placedSessions) { placed in
                        Marker(placed.mode.rawValue, systemImage: icon(for: placed.mode), coordinate: placed.coordinate)
                            .tint(color(for: placed.mode))
                    }
                }
                .mapControls {
                    MapCompass()
                }
                .onMapCameraChange { context in
                    currentRegion = context.region
                }
                .onAppear {
                    fitToPins()
                }

                VStack(spacing: 0) {
                    Button { zoom(by: 0.5) } label: {
                        Image(systemName: "plus").frame(width: 44, height: 44)
                    }
                    Divider().frame(width: 28)
                    Button { zoom(by: 2.0) } label: {
                        Image(systemName: "minus").frame(width: 44, height: 44)
                    }
                }
                .foregroundColor(.white)
                .background(.ultraThinMaterial)
                .cornerRadius(10)
                .shadow(radius: 4)
                .padding()
            }
            .navigationTitle("Global Leaderboard")
            .preferredColorScheme(.dark)
        }
    }

    private func zoom(by factor: Double) {
        guard let region = currentRegion else { return }
        let newSpan = MKCoordinateSpan(
            latitudeDelta: min(max(region.span.latitudeDelta * factor, 0.005), 130),
            longitudeDelta: min(max(region.span.longitudeDelta * factor, 0.005), 130)
        )
        withAnimation {
            cameraPosition = .region(MKCoordinateRegion(center: region.center, span: newSpan))
        }
    }

    private func fitToPins() {
        let region: MKCoordinateRegion
        if pinnedSessions.isEmpty {
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 20, longitude: 0),
                span: MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100)
            )
        } else {
            let coords = pinnedSessions.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
            let lats = coords.map(\.latitude)
            let lons = coords.map(\.longitude)
            let center = CLLocationCoordinate2D(
                latitude: (lats.min()! + lats.max()!) / 2,
                longitude: (lons.min()! + lons.max()!) / 2
            )
            let span = MKCoordinateSpan(
                latitudeDelta: max((lats.max()! - lats.min()!) * 1.6, 0.05),
                longitudeDelta: max((lons.max()! - lons.min()!) * 1.6, 0.05)
            )
            region = MKCoordinateRegion(center: center, span: span)
        }
        cameraPosition = .region(region)
        currentRegion = region
    }

    func color(for mode: GameMode) -> Color {
        switch mode {
        case .tapFrenzy: return .blue
        case .lightItUp: return .orange
        case .quizRush: return .green
        }
    }

    func icon(for mode: GameMode) -> String {
        switch mode {
        case .tapFrenzy: return "hand.tap.fill"
        case .lightItUp: return "lightbulb.max.fill"
        case .quizRush: return "questionmark.bubble.fill"
        }
    }
}
