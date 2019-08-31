//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Ajay Choudhary on 22/08/19.
//  Copyright © 2019 Ajay Choudhary. All rights reserved.
//

import Foundation
import MapKit

class Pin {
    var lat: Double
    var long: Double
    
    init(lat: Double, long: Double) {
        self.lat = lat
        self.long = long
    }
}
