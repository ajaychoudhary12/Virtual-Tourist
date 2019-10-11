//
//  Flickr Client.swift
//  Virtual Tourist
//
//  Created by Ajay Choudhary on 22/08/19.
//  Copyright © 2019 Ajay Choudhary. All rights reserved.
//

import UIKit

class FlickrClient {
    static let apiKey = ""
    static var pages = 1
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
                let randNumber = Int.random(in: 1...pages)
                components.queryItems!.append(URLQueryItem(name: Constants.FlickrAPIKeys.Page, value: String(randNumber)))
            }
            return components.url!
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                completion([])
                return
            }
            let range = 14..<data.count - 1
            let newData = data.subdata(in: range)
            do {
                let responseObject = try JSONDecoder().decode(PhotoData.self, from: newData)
                if !newCollection {
                    pages = responseObject.photos.pages
                }
                completion(responseObject.photos.photo)
            } catch {
                print(error)
                completion([])
            }
        }
        task.resume()
    }
    
    class func getImages(photoArray: [Photo], index: Int, completion: @escaping (UIImage?, Int?, Bool, String?) -> Void) {
        let urlString = buildURL(index, photoArray: photoArray)
        if urlString == "" {
            return
        }
        let url = URL(string: urlString)!
        
        if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            completion(imageFromCache, nil, true, nil)
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                    guard let data = data else {
                        completion(nil, index, false, nil)
                        return
                    }
                    let imageToCahce = UIImage(data: data)
                    DispatchQueue.main.async {
                        imageCache.setObject(imageToCahce!, forKey: urlString as AnyObject)
                        completion(imageToCahce, nil, false, urlString)
                    }
                }
                task.resume()
            }
        }
    }
    
    class func buildURL(_ index: Int, photoArray: [Photo]) -> String{
        if photoArray.count > index {
            let id = photoArray[index].id
            let farmId = photoArray[index].farm
            let serverId = photoArray[index].server
            let secret = photoArray[index].secret
            let urlString = "https://farm\(farmId).staticflickr.com/\(serverId)/\(id)_\(secret).jpg"
            return urlString
        } else {
            return ""
        }
    }
    
}

