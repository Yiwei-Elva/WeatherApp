//
//  Weather.swift
//  WeatherApp
//
//  Created by Yiwei Lyu on 5/12/23.
//

import Foundation

struct Weather: Codable {
    var coord: Coordinate?
    var weather: [WeatherData]
    var name: String
    var main: Temperature?
}

struct Coordinate: Codable {
    var lon: Double
    var lat: Double
}

struct WeatherData: Codable {
    var id: Int
    var main: String
    var description: String
    var icon: String
}

struct Temperature: Codable {
    var temp: Double?
    var feels_like: Double?
    var temp_min: Double?
    var temp_max: Double?
    var pressure: Double?
    var humidity: Double?
}

extension Weather {
    func temperatureString(_ temp: Double?) -> String? {
        guard let temperature = temp else  { return nil }
        return String(temperature)
    }
}
