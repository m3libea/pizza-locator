//
//  Venue.swift
//  PizzaLocator
//
//  Created by m3libea on 11/2/16.
//
//

import MapKit
import RealmSwift

class Venue: Object {
    dynamic var id:String = ""
    dynamic var name:String = ""
    
    dynamic var latitude:Float = 0
    dynamic var longitude:Float = 0
    
    dynamic var address:String = ""
    
    var coordinate:CLLocation {
        return CLLocation(latitude: Double(latitude), longitude: Double(longitude))
    }
    
    override static func primaryKey() -> String?{
        return "id";
    }
}