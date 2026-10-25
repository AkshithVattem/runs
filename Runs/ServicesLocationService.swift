//
//  LocationService.swift
//  Runs
//
//  Created by Akshith Vattem on 10/25/26.
//

import Foundation
import CoreLocation
import Observation

@Observable
final class LocationService: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    var currentLocation: CLLocation?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var isMonitoringGeofences = false
    
    // Completion handlers for geofence events
    var onEnterCourt: ((UUID) -> Void)?
    var onExitCourt: ((UUID) -> Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Update every 10 meters
        authorizationStatus = locationManager.authorizationStatus
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestAlwaysAuthorization() {
        // Required for background geofence monitoring
        locationManager.requestAlwaysAuthorization()
    }
    
    // MARK: - Location Updates
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Geofencing
    
    func startMonitoring(court: Court) {
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
            print("Geofence monitoring not available")
            return
        }
        
        let region = CLCircularRegion(
            center: court.coordinate,
            radius: CLLocationDistance(court.geofenceRadiusMeters),
            identifier: court.id.uuidString
        )
        region.notifyOnEntry = true
        region.notifyOnExit = true
        
        locationManager.startMonitoring(for: region)
        isMonitoringGeofences = true
    }
    
    func stopMonitoring(courtID: UUID) {
        for region in locationManager.monitoredRegions {
            if region.identifier == courtID.uuidString {
                locationManager.stopMonitoring(for: region)
            }
        }
    }
    
    func stopAllMonitoring() {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        isMonitoringGeofences = false
    }
    
    // MARK: - Utilities
    
    func isLocationWithinGeofence(of court: Court) -> Bool {
        guard let currentLocation = currentLocation else { return false }
        let distance = currentLocation.distance(from: court.location)
        return distance <= Double(court.geofenceRadiusMeters)
    }
    
    func distance(to court: Court) -> CLLocationDistance? {
        guard let currentLocation = currentLocation else { return nil }
        return currentLocation.distance(from: court.location)
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let courtID = UUID(uuidString: region.identifier) else { return }
        onEnterCourt?(courtID)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard let courtID = UUID(uuidString: region.identifier) else { return }
        onExitCourt?(courtID)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Geofence monitoring failed for region \(region?.identifier ?? "unknown"): \(error.localizedDescription)")
    }
}
