//
//  WeatherInteractor.swift
//  WeatherApp
//
//  Created by Yiwei Lyu on 5/12/23.
//

import Foundation

protocol WeatherInteractorProtocal {
    func fetchWeather(type: FetchWeatherType, completion: @escaping(Weather?) -> Void)
}

class WeatherInteractor: WeatherInteractorProtocal {

    func fetchWeather(type: FetchWeatherType, completion: @escaping(Weather?) -> Void) {
        guard let urlString = getApiConfiguationWithType(type) else { return }
        buildRequest(urlString: urlString) { result in
            switch result {
            case .success(let data):
                do {
                    let weatherData = try JSONDecoder().decode(Weather.self, from: data)
                    completion(weatherData)
                } catch {
                    completion(nil)
                }
            case .failure (let error):
                completion(nil)
            }
        }
    }

    func buildRequest(urlString: String, result: @escaping((NetworkResult<Data>) -> Void)) {
        guard let url = URL(string: urlString) else {
            result(.failure(NetworkingError.invalidUrl))
            return
        }
        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let jsonData = data else {
                result(.failure(NetworkingError.noData))
                return
            }
            if let networkError = error {
                result(.failure(networkError))
            }
            result(.success(jsonData))
        }
        task.resume()
    }
    /// Get different url based on search type
    /// - Parameter type: enum type for fetch weather
    ///                   api key: 486f26527cfb805893d2bff1d6630c86
    /// - Returns: url string
    private func getApiConfiguationWithType(_ type: FetchWeatherType) -> String? {
        switch type {
        case .search(let inputLocation):
            guard let encodedLocation =
                    inputLocation.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
            return "https://api.openweathermap.org/data/2.5/weather?q=\(encodedLocation)&appid=486f26527cfb805893d2bff1d6630c86"
        case .location(let location):
            guard let lat = location.latitude, let log = location.longitude else { return nil }
            return "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(log)&appid=486f26527cfb805893d2bff1d6630c86"
        }
    }
}

enum NetworkingError: Error {
    case invalidUrl
    case noData
}

enum NetworkResult<T> {
    case success(Data)
    case failure(Error)
}


#if DEBUG
class MockWeatherInteractor: WeatherInteractorProtocal {
    static let shared = MockWeatherInteractor()
    func fetchWeather(type: FetchWeatherType, completion: @escaping(Weather?) -> Void) {
        var weather: Weather?
        readLocalFile(type: Weather.self, forName: "Weather", cmpletion: { (object: Weather?) in
            if let weatherObject = object {
                weather = weatherObject
            }
        })
        completion(weather)
    }
    
    private func readLocalFile<T>(type: T.Type,
                                  forName name: String,
                                  cmpletion: @escaping(T?) -> Void) where T: Decodable {
        do {
            if let bundlePath = Bundle.main.path(forResource: name,
                                                 ofType: "json"),
                let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                do {
                    let result = try JSONDecoder().decode(type.self, from: jsonData)
                    cmpletion(result)
                } catch {
                    print(error)
                    cmpletion(nil)
                }
            }
        } catch {
            print(error)
            cmpletion(nil)
        }
        cmpletion(nil)
    }
}
#endif
