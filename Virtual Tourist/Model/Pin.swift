//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Ajay Choudhary on 22/08/19.
//  Copyright © 2019 Ajay Choudhary. All rights reserved.
//

import Foundation
import MapKit

class Pin: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var name: String!
    var title: String?
    
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
}
