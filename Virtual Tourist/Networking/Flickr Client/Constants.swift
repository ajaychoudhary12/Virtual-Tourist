//
//  Constants.swift
//  Virtual Tourist
//
//  Created by Ajay Choudhary on 23/08/19.
//  Copyright © 2019 Ajay Choudhary. All rights reserved.
//

import Foundation

struct Constants {
    
    struct FlickrURLParams {
        static let scheme = "https"
        static let host = "api.flickr.com"
        static let path = "/services/rest"
    }
    
    struct FlickrAPIKeys {
        static let SearchMethod = "method"
        static let APIKey = "api_key"
        static let ResponseFormat = "format"
        static let SafeSearch = "safe_search"
        static let Text = "text"
        static let Lat = "lat"
        static let Lon = "lon"
        static let PerPage = "per_page"
        static let Page = "page"
    }
    
    struct FlickrAPIValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "6018ce76bba90c3eff10d2f95093f634"
        static let ResponseFormat = "json"
        static let SafeSearch = "1"
        static let PerPage = "20"
    }
}
