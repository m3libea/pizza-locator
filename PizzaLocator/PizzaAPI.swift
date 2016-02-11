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
    
    func getPizzaWithLocation(location: CLLocation) {
        if let session = self.session
        {
            var parameters = location.parameters()
            parameters += [Parameter.categoryId:"4bf58dd8d48988d1ca941735"]
            parameters += [Parameter.radius: "2000"]
            parameters += [Parameter.limit: "50"]
            
            let searchTask = session.venues.search(parameters) { (result) -> Void in
                
                if let response = result.response
                {
                    if let venues = response["venues"] as? [[String: AnyObject]] {
                        autoreleasepool
                        {
                            let realm = try! Realm()
                            realm.beginWrite()
                            
                            for venue:[String:AnyObject] in venues {
                                let venueObject:Venue = Venue()
                                
                                if let id = venue["id"] as? String
                                {
                                    venueObject.id = id
                                }
                                
                                if let id = venue["name"] as? String
                                {
                                    venueObject.name = name
                                }
                                if let id = venue["location"] as? String
                                {
                                    if let longitude = location["lng"] as? Float
                                    {
                                        venueObject.longitude = longitude
                                    }
                                    
                                    if let latitude = location["lat"] as? Float
                                    {
                                        venueObject.latitude = latitude
                                    }
                                    
                                    if let formatteAddress = location["formatteAddress"] as? Float
                                    {
                                        venueObject.address = formatteAddress.joinWithSeparator(" ")
                                    }
                                }
                                
                                realm.add(venueObject, update: true)
                            }
                            
                            do{
                                try realm.commitWrite()
                                print("Storing Venues")
                            }
                            catch (let e){
                                print("Realm not working: \(e)")
                            }
                        }
                        
                        NSNotificationCenter.defaultCenter().postNotificationName(API.notifications.venuesUpdated, object: nil, userInfo: nil)
                    }
                    
                }
                
            }
            searchTask.start()
        }
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