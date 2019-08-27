//
//  response.swift
//  Virtual Tourist
//
//  Created by Ajay Choudhary on 23/08/19.
//  Copyright © 2019 Ajay Choudhary. All rights reserved.
//

import Foundation

struct Photo: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let isPublic: Int
    let isFriend: Int
    let isFamily: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case owner
        case secret
        case server
        case farm
        case title
        case isPublic = "ispublic"
        case isFriend = "isfriend"
        case isFamily = "isfamily"
    }
}
