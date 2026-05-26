import SwiftUI
import CoreLocation
import Combine

// MARK: - Qibla Manager

@MainActor
final class QiblaManager: NSObject, ObservableObject {
    
    private let locationManager = CLLocationManager()
    
    @Published var heading: Double = 0
    @Published var qiblaBearing: Double = 0
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var hasHeading: Bool = false
    @Published var userLocation: CLLocationCoordinate2D?
    
    // Mecca coordinates
    private let meccaLat = 21.4225 * .pi / 180
    private let meccaLon = 39.8262 * .pi / 180
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.headingFilter = 1
    }
    
    func start() {
        authorizationStatus = locationManager.authorizationStatus
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            beginUpdates()
        default:
            break
        }
    }
    
    func stop() {
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
    }
    
    private func beginUpdates() {
        locationManager.startUpdatingLocation()
        if CLLocationManager.headingAvailable() {
            locationManager.startUpdatingHeading()
        }
    }
    
    private func calculateQiblaBearing(from coordinate: CLLocationCoordinate2D) {
        let userLat = coordinate.latitude * .pi / 180
        let userLon = coordinate.longitude * .pi / 180
        
        let deltaLon = meccaLon - userLon
        
        let y = sin(deltaLon)
        let x = cos(userLat) * tan(meccaLat) - sin(userLat) * cos(deltaLon)
        
        var bearing = atan2(y, x) * 180 / .pi
        if bearing < 0 { bearing += 360 }
        
        qiblaBearing = bearing
    }
}

extension QiblaManager: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard newHeading.headingAccuracy >= 0 else { return }
        Task { @MainActor in
            self.heading = newHeading.magneticHeading
            self.hasHeading = true
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.userLocation = location.coordinate
            self.calculateQiblaBearing(from: location.coordinate)
        }
    }
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorizationStatus = status
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.beginUpdates()
            default:
                break
            }
        }
    }
}

// MARK: - Qibla View

struct QiblaView: View {
    @Environment(\.colorScheme) private var scheme
    @StateObject private var manager = QiblaManager()
    
    private var qiblaAngle: Double {
        manager.qiblaBearing - manager.heading
    }
    
    var body: some View {
        ZStack {
            AppBackground()
            
            switch manager.authorizationStatus {
            case .denied, .restricted:
                permissionDeniedView
            case .notDetermined:
                requestingPermissionView
            default:
                compassContent
            }
        }
        .navigationTitle("Qibla")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { manager.start() }
        .onDisappear { manager.stop() }
    }
    
    // MARK: - Compass Content
    
    private var compassContent: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Degree display
            VStack(spacing: 4) {
                Text("\(Int(manager.qiblaBearing))°")
                    .font(.system(size: 56, weight: .thin, design: .rounded))
                    .foregroundColor(.adaptiveText(scheme))
                
                Text("Qibla Direction")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondaryText(scheme))
            }
            
            // Compass
            ZStack {
                // Outer ring
                Circle()
                    .stroke(Color.glassBorder(scheme), lineWidth: 2)
                    .frame(width: 280, height: 280)
                
                // Tick marks and cardinal directions
                CompassDialView(scheme: scheme, heading: manager.heading)
                    .frame(width: 280, height: 280)
                    .rotationEffect(.degrees(-manager.heading))
                
                // Inner circle
                Circle()
                    .fill(Color.glassFill(scheme))
                    .frame(width: 200, height: 200)
                
                Circle()
                    .stroke(Color.glassBorder(scheme), lineWidth: 1)
                    .frame(width: 200, height: 200)
                
                // Qibla needle
                QiblaNeedleView(scheme: scheme)
                    .rotationEffect(.degrees(qiblaAngle))
                
                // Center kaaba icon
                ZStack {
                    Circle()
                        .fill(Color.adaptiveAccent(scheme))
                        .frame(width: 16, height: 16)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: manager.heading)
            .animation(.easeInOut(duration: 0.3), value: manager.qiblaBearing)
            
            // Kaaba label
            HStack(spacing: 8) {
                Image(systemName: "building.columns.fill")
                    .foregroundColor(.adaptiveAccent(scheme))
                Text("Kaaba · Mecca")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondaryText(scheme))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color.glassFill(scheme))
            )
            .overlay(
                Capsule()
                    .stroke(Color.glassBorder(scheme), lineWidth: 1)
            )
            
            if !manager.hasHeading {
                HStack(spacing: 8) {
                    ProgressView()
                        .tint(.adaptiveAccent(scheme))
                    Text("Calibrating compass...")
                        .font(.caption)
                        .foregroundColor(.secondaryText(scheme))
                }
            }
            
            Spacer()
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Permission Views
    
    private var permissionDeniedView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "location.slash.fill")
                .font(.system(size: 56))
                .foregroundColor(.secondaryText(scheme))
            
            Text("Location Access Required")
                .font(.title3.weight(.semibold))
                .foregroundColor(.adaptiveText(scheme))
            
            Text("Taqwah needs access to your location and compass to determine the Qibla direction. Please enable Location Services in Settings.")
                .font(.subheadline)
                .foregroundColor(.secondaryText(scheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Open Settings")
                    .font(.body.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(Color.adaptiveAccent(scheme))
                    )
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var requestingPermissionView: some View {
        VStack(spacing: 20) {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
                .tint(.adaptiveAccent(scheme))
            Text("Requesting permission...")
                .font(.subheadline)
                .foregroundColor(.secondaryText(scheme))
            Spacer()
        }
    }
}

// MARK: - Compass Dial

struct CompassDialView: View {
    let scheme: ColorScheme
    let heading: Double
    
    var body: some View {
        ZStack {
            // Tick marks
            ForEach(0..<72, id: \.self) { i in
                let angle = Double(i) * 5
                let isMajor = i % 6 == 0 // Every 30 degrees
                let isCardinal = i % 18 == 0 // Every 90 degrees
                
                Rectangle()
                    .fill(isCardinal
                          ? Color.adaptiveAccent(scheme)
                          : Color.secondaryText(scheme).opacity(isMajor ? 0.8 : 0.3))
                    .frame(width: isCardinal ? 2.5 : (isMajor ? 1.5 : 1),
                           height: isCardinal ? 16 : (isMajor ? 10 : 6))
                    .offset(y: -130)
                    .rotationEffect(.degrees(angle))
            }
            
            // Cardinal directions
            cardinalLabel("N", angle: 0, color: .adaptiveAccent(scheme))
            cardinalLabel("E", angle: 90, color: .secondaryText(scheme))
            cardinalLabel("S", angle: 180, color: .secondaryText(scheme))
            cardinalLabel("W", angle: 270, color: .secondaryText(scheme))
        }
    }
    
    private func cardinalLabel(_ text: String, angle: Double, color: Color) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundColor(color)
            .offset(y: -108)
            .rotationEffect(.degrees(angle))
    }
}

// MARK: - Qibla Needle

struct QiblaNeedleView: View {
    let scheme: ColorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Arrow pointing up (toward qibla)
            Image(systemName: "arrowtriangle.up.fill")
                .font(.system(size: 20))
                .foregroundColor(.adaptiveAccent(scheme))
                .offset(y: 6)
            
            Rectangle()
                .fill(Color.adaptiveAccent(scheme))
                .frame(width: 3, height: 75)
            
            Circle()
                .fill(Color.adaptiveAccent(scheme))
                .frame(width: 10, height: 10)
            
            Rectangle()
                .fill(Color.secondaryText(scheme).opacity(0.4))
                .frame(width: 2, height: 60)
        }
        .offset(y: -18)
    }
}

// MARK: - Previews

#Preview("Dark") {
    NavigationStack {
        QiblaView()
    }
    .preferredColorScheme(.dark)
}

#Preview("Light") {
    NavigationStack {
        QiblaView()
    }
    .preferredColorScheme(.light)
}
