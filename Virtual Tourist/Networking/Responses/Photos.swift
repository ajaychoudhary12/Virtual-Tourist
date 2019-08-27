//
//  Photos.swift
//  Virtual Tourist
//
//  Created by Ajay Choudhary on 24/08/19.
//  Copyright © 2019 Ajay Choudhary. All rights reserved.
//

import Foundation

struct Photos: Codable {
    let page: Int
    let pages: Int
    let perPage: Int
    let total: String
    let photo: [Photo]
    
    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perPage = "perpage"
        case total
        case photo
    }
}
