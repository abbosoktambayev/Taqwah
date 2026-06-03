import Foundation
import CoreLocation
import Combine
import MapKit

@MainActor
final class LocationManager: NSObject, ObservableObject {

    static let shared = LocationManager()

    // MARK: - Published Properties

    @Published var latitude: Double = 51.133333   // Default: Astana
    @Published var longitude: Double = 71.433333
    @Published var cityName: String = "Astana"
    @Published var countryName: String = "Kazakhstan"
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocating: Bool = false

    /// Full display string: "Astana, Kazakhstan"
    var displayLocation: String {
        countryName.isEmpty ? cityName : "\(cityName), \(countryName)"
    }

    // MARK: - Private

    private let locationManager = CLLocationManager()
    private var reverseGeocodingTask: Task<Void, Never>?
    private var hasResolvedOnce = false

    // MARK: - Init

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        authorizationStatus = locationManager.authorizationStatus
    }

    // MARK: - Public API

    /// Request location permission and start locating
    func requestLocationIfNeeded() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            startLocating()
        case .denied, .restricted:
            // Use default Astana coordinates
            break
        @unknown default:
            break
        }
    }

    // MARK: - Private Helpers

    private func startLocating() {
        guard !hasResolvedOnce else { return }
        isLocating = true
        locationManager.requestLocation()
    }

    private func reverseGeocode(_ location: CLLocation) {
        reverseGeocodingTask?.cancel()
        reverseGeocodingTask = Task { @MainActor [location] in
            defer {
                self.isLocating = false
                self.hasResolvedOnce = true
                self.reverseGeocodingTask = nil
            }

            guard let request = MKReverseGeocodingRequest(location: location) else { return }

            do {
                let mapItem = try await request.mapItems.first
                guard !Task.isCancelled else { return }

                let address = mapItem?.addressRepresentations
                self.cityName = address?.cityName
                    ?? address?.cityWithContext(.short)
                    ?? mapItem?.address?.shortAddress
                    ?? Self.coordinateName(for: location)
                self.countryName = address?.regionName ?? ""
            } catch {
                self.cityName = Self.coordinateName(for: location)
                self.countryName = ""
            }
        }
    }

    private static func coordinateName(for location: CLLocation) -> String {
        String(
            format: "%.2f, %.2f",
            location.coordinate.latitude,
            location.coordinate.longitude
        )
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }

        Task { @MainActor in
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            self.reverseGeocode(location)
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        Task { @MainActor in
            // Keep default Astana coordinates
            self.isLocating = false
            self.hasResolvedOnce = true
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus

            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                self.startLocating()
            default:
                break
            }
        }
    }
}
