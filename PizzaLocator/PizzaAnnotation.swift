
//
//  PizzaAnnotation.swift
//  PizzaLocator
//
//  Created by m3libea on 11/2/16.
//
//

import MapKit

class PizzaAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        
        super.init()
    }
}
