//
//  ViewController.swift
//  PizzaLocator
//
//  Created by m3libea on 10/2/16.
//
//

import UIKit
import MapKit
import RealmSwift

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var mapView:MKMapView?
    @IBOutlet var tableView:UITableView?
    var locationManager:CLLocationManager?
    let distanceSpan:Double = 1000
    var lastlocation:CLLocation?
    var venues:[Venue]?
    
    //Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("onVenuesUpdated:"), name: API.notifications.venuesUpdated, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let mapView = self.mapView
        {
            mapView.delegate = self
        }
        
        if let tableView = self.tableView
        {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if locationManager == nil{
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager!.requestAlwaysAuthorization()
            locationManager!.distanceFilter = 100
            locationManager!.startUpdatingLocation()
        }
    }
    
    //Map View methods
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        if let mapView = self.mapView {
            let region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, distanceSpan, distanceSpan)
            mapView.setRegion(region, animated: true)
            refreshVenues(newLocation, getDataFromFoursquare: true)
        }
    }

    func refreshVenues(location: CLLocation?, getDataFromFoursquare:Bool = false) {
        if location != nil{
            lastlocation = location
        }
        
        if let location = lastlocation {
            if getDataFromFoursquare == true {
                PizzaAPI.sharedInstance.getPizzaWithLocation(location)
            }
            
            let (start,stop) = calculateCoordinatesWithRegion(location)

            let predicate = NSPredicate(format: "latitude < %f AND latitude > %f AND longitude > %f AND longitude < %f", start.latitude, stop.latitude, start.longitude, stop.longitude);
            let realm = try! Realm()
            
            venues = realm.objects(Venue).filter(predicate).sort{
                location.distanceFromLocation($0.coordinate) < location.distanceFromLocation($1.coordinate)
            }
            
            for venue in venues! {
                let annotation = PizzaAnnotation(title: venue.name, subtitle: venue.address, coordinate: CLLocationCoordinate2D(latitude: Double(venue.latitude), longitude: Double(venue.longitude)))
                mapView?.addAnnotation(annotation)
            }
            tableView?.reloadData()
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(MKUserLocation){
            return nil
        }
        
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier("annotationIdentifier")
        
        if view == nil{
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotationIdentifier")
        }
        
        view?.canShowCallout = true
        
        return view
    }
    
    func onVenuesUpdated(notification: NSNotification){
        refreshVenues(nil)
    }
    
    func calculateCoordinatesWithRegion(location:CLLocation) -> (CLLocationCoordinate2D, CLLocationCoordinate2D) {
        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, distanceSpan, distanceSpan);
        
        var start:CLLocationCoordinate2D = CLLocationCoordinate2D();
        var stop:CLLocationCoordinate2D = CLLocationCoordinate2D();
        
        start.latitude  = region.center.latitude  + (region.span.latitudeDelta  / 2.0);
        start.longitude = region.center.longitude - (region.span.longitudeDelta / 2.0);
        stop.latitude   = region.center.latitude  - (region.span.latitudeDelta  / 2.0);
        stop.longitude  = region.center.longitude + (region.span.longitudeDelta / 2.0);
        
        return (start, stop);
    }
    
//Table View Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues?.count ?? 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        
        if let venue = venues?[indexPath.row] {
            cell!.textLabel?.text = venue.name
            cell!.detailTextLabel?.text = venue.address
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if let venue = venues?[indexPath.row]{
            mapView?.setCenterCoordinate(CLLocationCoordinate2D(latitude: Double(venue.latitude), longitude: Double(venue.longitude)), animated: true)
        }
    }
    

}

