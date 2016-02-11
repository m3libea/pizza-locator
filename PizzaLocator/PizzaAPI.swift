//
//  PizzaAPI.swift
//  PizzaLocator
//
//  Created by m3libea on 11/2/16.
//
//

import QuadratTouch
import MapKit
import RealmSwift

struct API {
    struct notifications {
        static let venuesUpdated = "Venues Updated"
    }
}

class PizzaAPI {
    static let sharedInstance = PizzaAPI()
    var session:Session?
    
    init()
    {
        let client = Client(clientID: "3XPR2CTGDIEXQ3UGG1GDG0QYTCBOHF2CO2FB41VOGYG5P14K", clientSecret: "B5FV13FT5RG0JHT00JZQWEQS5FTGLDPPDOCQB2D3YVAICDPP", redirectURL: "")
        
        let configuration = Configuration(client:client)
        Session.setupSharedSessionWithConfiguration(configuration)
        
        self.session = Session.sharedSession()
    }
}

extension CLLocation
{
    func parameters() -> Parameters
    {
        let ll = "\(self.coordinate.latitude), \(self.coordinate.longitude)"
        let llAcc = "\(self.horizontalAccuracy)"
        let alt = "\(self.altitude)"
        let altAcc = "\(self.verticalAccuracy)"
        let parameters = [
            Parameter.ll:ll,
            Parameter.llAcc:llAcc,
            Parameter.alt:alt,
            Parameter.altAcc:altAcc
        ]
        return parameters
    }
}