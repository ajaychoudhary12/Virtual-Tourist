//
//  Flickr Client.swift
//  Virtual Tourist
//
//  Created by Ajay Choudhary on 22/08/19.
//  Copyright © 2019 Ajay Choudhary. All rights reserved.
//

import UIKit

class FlickrClient {
    static let apiKey = "c5ab0ffa22d2dad9ec251304df5a73a7"
    
    class func getImageIDs(lat: String, lon: String, newCollection: Bool, completion: @escaping ([Photo]) -> Void) {
        
        var url : URL{
            var components = URLComponents()
            components.scheme = Constants.FlickrURLParams.scheme
            components.host = Constants.FlickrURLParams.host
            components.path = Constants.FlickrURLParams.path
            
            components.queryItems = [URLQueryItem]()
            
            components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.APIKey, value: Constants.FlickrAPIValues.APIKey))
            components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.SearchMethod, value: Constants.FlickrAPIValues.SearchMethod))
            components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.ResponseFormat, value: Constants.FlickrAPIValues.ResponseFormat))
            components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.SafeSearch, value: Constants.FlickrAPIValues.SafeSearch))
            components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.PerPage, value: Constants.FlickrAPIValues.PerPage))
            components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.Lat, value: lat))
            components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.Lon, value: lon))
            
            if newCollection {
                let randNumber = Int.random(in: 0..<20)
                components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.Page, value: String(randNumber)))
            }
            return components.url!
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                return
            }
            let range = 14..<data.count - 1
            let newData = data.subdata(in: range)
            do {
                let responseObject = try JSONDecoder().decode(PhotoData.self, from: newData)
                completion(responseObject.photos.photo)
            } catch {
                print(error)
                completion([])
            }
        }
        task.resume()
    }
    
    class func requestImageFile(photoArray: [Photo], completion: @escaping ([UIImage]) -> Void) {
        var uiImages: [UIImage] = []
        print(photoArray.count)
        for i in 0..<photoArray.count {
            let id = photoArray[i].id
            let farmId = photoArray[i].farm
            let serverId = photoArray[i].server
            let secret = photoArray[i].secret
            
            DispatchQueue.global(qos: .userInitiated).async {
                let urlString = "https://farm\(farmId).staticflickr.com/\(serverId)/\(id)_\(secret).jpg"
                let url = URL(string: urlString)!
                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                    guard let data = data else {
                        return
                    }
                    let image = UIImage(data: data)
                    uiImages.append(image!)
                    completion(uiImages)
                }
                task.resume()
            }
        }
    }

}

