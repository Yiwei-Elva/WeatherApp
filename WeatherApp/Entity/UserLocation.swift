//
//  UserLocation.swift
//  WeatherApp
//
//  Created by Yiwei Lyu on 5/12/23.
//

import Foundation
import CoreLocation
class UserLocation: NSObject {

    static let share = UserLocation()
    var locationManager: CLLocationManager
    static let updateLocationNotification = Notification.Name("updateCurrentLocationNotification")
    var currentLocation: Location? {
        didSet {
            NotificationCenter.default.post(name: UserLocation.updateLocationNotification, object: nil)
        }
    }

    override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func requestPermission() {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
}

extension UserLocation: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let strongSelf = self, let placemark = placemarks?.first else { return }
            strongSelf.currentLocation = Location(latitude: location.coordinate.latitude,
                                                  longitude: location.coordinate.longitude,
                                                  city: placemark.locality)
        }
    }
}
