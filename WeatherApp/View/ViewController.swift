//
//  ViewController.swift
//  WeatherApp
//
//  Created by Yiwei Lyu on 5/12/23.
//

import UIKit

class ViewController: UIViewController {
    private var viewModel: ViewModel?
    @IBOutlet weak var weatherSearchBar: UISearchBar!
    
    @IBOutlet weak var weatherStackView: UIStackView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var lowestTemp: UILabel!
    @IBOutlet weak var highestTemp: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        weatherSearchBar.delegate = self
        weatherStackView.isHidden = true
        viewModel = ViewModel()
        viewModel?.updateWeather = { [weak self] weather in
            DispatchQueue.main.async {
                self?.updateWeatherUI(weather)
            }
        }
    }
    
    private func updateWeatherUI(_ weatherData: Weather?){
        guard let weather = weatherData else {
            weatherStackView.isHidden = true
            return
        }
        weatherStackView.isHidden = false
        cityLabel.text = weather.name
        
        let temperatureFormat = NSLocalizedString("%@ °F", comment: "")
        temperatureLabel.text = .localizedStringWithFormat(temperatureFormat, weather.temperatureString(weather.main?.temp) ?? "--")
        weatherLabel.text  = weather.weather.first?.description
        lowestTemp.text = .localizedStringWithFormat(temperatureFormat, weather.temperatureString(weather.main?.temp_min) ?? "--")
        highestTemp.text = .localizedStringWithFormat(temperatureFormat, weather.temperatureString(weather.main?.temp_max) ?? "--")
        if let icon = weather.weather.first?.icon, let url = URL(string: "https://openweathermap.org/img/wn/\(icon).png") {
            ImageCache.share.fetchImage(url) { [weak self] image in
                DispatchQueue.main.async {
                    self?.weatherIcon.image = image
                }
            }
        }
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //service call for weather information
        searchBar.resignFirstResponder()
        if let inputCity = searchBar.text {
            viewModel?.fetchWeather(.search(city: inputCity))
        }
    }
}

