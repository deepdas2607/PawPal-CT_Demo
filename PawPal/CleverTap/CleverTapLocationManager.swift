//
//  CleverTapLocationManager.swift
//  PawPal - CleverTap Integration Layer
//
//  GEOFENCE & LOCATION TRACKING LAYER:
//  Manages CoreLocation permissions, location updates, CleverTap.setLocation() reporting,
//  and CleverTap Geofence Region Monitoring (CleverTapGeofence SDK).
//

import Foundation
import CoreLocation
import Combine
import CleverTapSDK
import CleverTapGeofence

/// Central manager for user location tracking and CleverTap Geofencing.
class CleverTapLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = CleverTapLocationManager()
    
    private let locationManager = CLLocationManager()
    
    // Published states for SwiftUI views
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var lastKnownLocation: CLLocationCoordinate2D? = nil
    @Published var isGeofenceMonitoringActive: Bool = false
    @Published var lastLocationUpdateTimestamp: String = "No location recorded yet"
    @Published var geofenceStatusText: String = "Geofence SDK idle"
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authorizationStatus = locationManager.authorizationStatus
    }
    
    // MARK: - Authorization Requests
    
    /// Requests "When In Use" location permission from the user.
    func requestWhenInUsePermission() {
        locationManager.requestWhenInUseAuthorization()
        
        LiveInspectorViewModel.shared.log(
            title: "Location: Requested When-In-Use Permission",
            category: .cleverTap,
            payload: [
                "action": "requestWhenInUseAuthorization",
                "currentStatus": authorizationDescription(authorizationStatus)
            ]
        )
    }
    
    /// Requests "Always" location authorization (required for background Geofence region triggers).
    func requestAlwaysPermission() {
        locationManager.requestAlwaysAuthorization()
        
        LiveInspectorViewModel.shared.log(
            title: "Location: Requested Always Authorization (Geofence)",
            category: .cleverTap,
            payload: [
                "action": "requestAlwaysAuthorization",
                "currentStatus": authorizationDescription(authorizationStatus)
            ]
        )
    }
    
    /// Starts one-time or ongoing location updates to send coordinate to CleverTap.
    func requestLocationUpdate() {
        locationManager.requestLocation()
    }
    
    // MARK: - CleverTap Geofence SDK Lifecycle
    
    /// Starts CleverTap Geofence region monitoring.
    /// Can be called during app launch or when location permissions are granted.
    func startGeofencing(launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) {
        #if DEBUG
        CleverTapGeofence.logLevel = .debug
        #else
        CleverTapGeofence.logLevel = .error
        #endif
        
        CleverTapGeofence.monitor.start(didFinishLaunchingWithOptions: launchOptions)
        isGeofenceMonitoringActive = true
        geofenceStatusText = "Monitoring Geofences Active"
        
        LiveInspectorViewModel.shared.log(
            title: "CleverTap Geofence: Started Monitoring",
            category: .cleverTap,
            payload: [
                "status": "Monitoring active",
                "distanceFilter": "200m",
                "timeFilter": "1800s",
                "timestamp": DateFormatterHelper.toISOString(Date())
            ]
        )
    }
    
    /// Stops CleverTap Geofence region monitoring.
    func stopGeofencing() {
        CleverTapGeofence.monitor.stop()
        isGeofenceMonitoringActive = false
        geofenceStatusText = "Geofence Monitoring Stopped"
        
        LiveInspectorViewModel.shared.log(
            title: "CleverTap Geofence: Stopped Monitoring",
            category: .cleverTap,
            payload: ["status": "Monitoring stopped"]
        )
    }
    
    /// Manually sets coordinates for simulated testing on simulator or specific pet clinic locations.
    func recordManualLocation(latitude: Double, longitude: Double, label: String = "Custom Location") {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        lastKnownLocation = coordinate
        lastLocationUpdateTimestamp = DateFormatterHelper.formatTime(Date())
        
        // Push coordinate to CleverTap SDK
        CleverTap.setLocation(coordinate)
        
        LiveInspectorViewModel.shared.log(
            title: "CleverTap: Location Recorded (\(label))",
            category: .cleverTap,
            payload: [
                "label": label,
                "latitude": latitude,
                "longitude": longitude,
                "timestamp": lastLocationUpdateTimestamp
            ]
        )
    }
    
    // MARK: - CLLocationManagerDelegate Callbacks
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.authorizationStatus = manager.authorizationStatus
            let statusDesc = self.authorizationDescription(manager.authorizationStatus)
            
            LiveInspectorViewModel.shared.log(
                title: "Location: Authorization Changed",
                category: .cleverTap,
                payload: [
                    "authorizationStatus": statusDesc,
                    "accuracyAuthorization": "\(manager.accuracyAuthorization)"
                ]
            )
            
            // If authorized, start Geofence monitoring automatically
            if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
                self.startGeofencing()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.lastKnownLocation = location.coordinate
            self.lastLocationUpdateTimestamp = DateFormatterHelper.formatTime(Date())
            
            // Set user's live location in CleverTap SDK
            CleverTap.setLocation(location.coordinate)
            
            LiveInspectorViewModel.shared.log(
                title: "Location: Did Update Locations",
                category: .cleverTap,
                payload: [
                    "latitude": location.coordinate.latitude,
                    "longitude": location.coordinate.longitude,
                    "altitude": location.altitude,
                    "horizontalAccuracy": location.horizontalAccuracy,
                    "timestamp": self.lastLocationUpdateTimestamp
                ]
            )
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("[LocationManager] didFailWithError: %@", error.localizedDescription)
        
        LiveInspectorViewModel.shared.log(
            title: "Location: Manager Error",
            category: .cleverTap,
            payload: ["error": error.localizedDescription]
        )
    }
    
    // MARK: - Helpers
    
    private func authorizationDescription(_ status: CLAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorizedAlways: return "Authorized Always"
        case .authorizedWhenInUse: return "Authorized When In Use"
        @unknown default: return "Unknown"
        }
    }
}
