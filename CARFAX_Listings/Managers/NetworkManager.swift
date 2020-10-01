//
//  NetworkManager.swift
//  CARFAX_Listings
//
//  Created by Chris Song on 2020-09-30.
//

import UIKit

class NetworkManager {
    static let shared = NetworkManager()
    private let url = "https://carfax-for-consumers.firebaseio.com/assignment.json"
    let cache = NSCache<NSString, UIImage>()
    
    private init() {}
    
    func getListing(completionHandler: @escaping (Result<CARFAXData, CFError>) -> Void) {
        guard let url = URL(string: url) else {
            completionHandler(.failure(.invalidResponse))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let _ = error {
                completionHandler(.failure(.unableToComplete))
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completionHandler(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completionHandler(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                
                let listings = try decoder.decode(CARFAXData.self, from: data)
                completionHandler(.success(listings))
            } catch {
                completionHandler(.failure(.invalidData))
            }
        }
        
        task.resume()
    }
    
    func downloadImage(from urlString: String, completionHandler: @escaping (UIImage?) -> Void) {
        let cacheKey = NSString(string: urlString)
        
        if let image = cache.object(forKey: cacheKey) {
            completionHandler(image)
            return
        }
        
        guard let url = URL(string: urlString) else {
            completionHandler(nil)
            return
        }
        
        let imageTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                error == nil,
                let response = response as? HTTPURLResponse, response.statusCode == 200,
                let data = data,
                let image = UIImage(data: data) else {
                    completionHandler(nil)
                    return
            }
            self.cache.setObject(image, forKey: cacheKey)
            completionHandler(image)
        }
        imageTask.resume()
    }
}

