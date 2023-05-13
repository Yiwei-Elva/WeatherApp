//
//  ImageCache.swift
//  WeatherApp
//
//  Created by Yiwei Lyu on 5/12/23.
//

import Foundation
import UIKit
class ImageCache: NSObject {
    static let share = ImageCache()
    let cache = NSCache<NSURL, UIImage>()
    let interactor = WeatherInteractor()
    func fetchImage(_ url: URL, completion: @escaping((UIImage?) -> Void)) {
        if let image = cache.object(forKey: url as NSURL) {
            completion(image)
        }
        interactor.buildRequest(urlString: url.absoluteString) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    strongSelf.cache.setObject(image, forKey: url as NSURL)
                    completion(image)
                }
            case .failure(let error):
                completion(nil)
            }
        }
    }
}
