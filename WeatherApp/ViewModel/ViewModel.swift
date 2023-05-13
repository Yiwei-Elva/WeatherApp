//
//  ViewModel.swift
//  WeatherApp
//
//  Created by Yiwei Lyu on 5/12/23.
//

import Foundation

enum FetchWeatherType {
    case search(city: String)
    case location(location: Location)
}
class ViewModel {

    var weather: Weather?
    var interactor: WeatherInteractor
    var currentLocation: Location?
    var updateWeather: ((Weather?) -> Void)?

    init() {
        self.interactor = WeatherInteractor()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateLocation), name: UserLocation.updateLocationNotification, object: nil)
        UserLocation.share.requestPermission()
    }

    /// if the user gives permission to access the location and never search before, retrieve weather by current location, otherwise fetch the weather of  last searched city
    @objc private func updateLocation() {
        if currentLocation == nil {
            currentLocation = UserLocation.share.currentLocation
        }
        if let location = currentLocation {
            fetchWeather(.location(location: location))
        }
    }

    func fetchWeather(_ type: FetchWeatherType) {
        interactor.fetchWeather(type: type) { [weak self] weather in
            guard let strongSelf = self else { return }
            strongSelf.weather = weather
            strongSelf.updateWeather?(weather)
            //Save last searched city
            strongSelf.currentLocation = Location(latitude: weather?.coord?.lat,
                                                  longitude: weather?.coord?.lon,
                                                  city: weather?.name,
                                                  weather: weather)
        }
    }
}
