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
}

