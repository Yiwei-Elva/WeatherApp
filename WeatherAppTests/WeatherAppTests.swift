//
//  WeatherAppTests.swift
//  WeatherAppTests
//
//  Created by Yiwei Lyu on 5/12/23.
//

import XCTest
@testable import WeatherApp

final class WeatherAppTests: XCTestCase {
    
    private func createViewController() -> (ViewController, ViewModel) {
        let vc = ViewController()
        let viewModel = ViewModel()
        return (vc, viewModel)
    }
    
    func testMockResponse() {
        let mock = MockWeatherInteractor()
        let location = Location(latitude: 37.78831478829981,
                                longitude: -122.40759160742873)
        mock.fetchWeather(type: .location(location: location)) { weather in
            guard let testWeather = weather else {
                XCTFail("Fail to fetch weather json data")
                return
            }
            assert(testWeather.main?.temp == 282.55)
            assert(testWeather.main?.temp_min == 280.37)
            assert(testWeather.main?.temp_max == 284.26)
            guard let weather = testWeather.weather.first else {
                XCTFail("Fail to fetch weatherData parameter from weather.json")
                return
            }
            assert(weather.main == "Clear")
            assert(weather.description == "clear sky")
        }
    }
}
