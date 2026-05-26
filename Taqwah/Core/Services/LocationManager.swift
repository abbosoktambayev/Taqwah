import Foundation
import CoreLocation
import Combine

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
        "\(cityName), \(countryName)"
    }

    // MARK: - Private

    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
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
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            Task { @MainActor in
                guard let self = self else { return }

                if let placemark = placemarks?.first {
                    self.cityName = placemark.locality
                        ?? placemark.administrativeArea
                        ?? "Unknown"
                    self.countryName = placemark.country ?? "Unknown"
                }

                self.isLocating = false
                self.hasResolvedOnce = true
            }
        }
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
            print("Location error: \(error.localizedDescription)")
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
