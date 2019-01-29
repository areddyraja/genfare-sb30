//
//  HomeViewController.swift
//  Genfare
//
//  Created by omniwzse on 14/08/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class HomeViewController: GFBaseViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var whereToGoText: UITextField!
    @IBOutlet weak var locationPin: UIImageView!
    
    var locationManager = CLLocationManager()
    var locationLat:String?
    var locationLong:String?
    var userCurrentLocation:CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        whereToGoText.delegate = self
        mapView.delegate = self
        //addMenuObservers()
        //TripDataManager.initService()
        //TripDataManager.getStopsInBetween()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        TripDataManager.resetTrip()
        //Show user currentlocation
        determineCurrentLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateStartingPoint()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func determineCurrentLocation()
    {
        mapView.showsUserLocation = true
        
        if CLLocationManager.locationServicesEnabled() == true {
            
            if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .notDetermined {
                
                locationManager.requestWhenInUseAuthorization()
            }
            
            locationManager.desiredAccuracy = 1.0
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            
        } else {
            print("Please turn on location services or GPS")
        }
    }
    
    func requestCurrentLocation()
    {
        mapView.showsUserLocation = true
        
        if CLLocationManager.locationServicesEnabled() == true {
            
            locationManager.requestLocation()
            
        } else {
            print("Please turn on location services or GPS")
        }
    }
    
    func updateStartingPoint() {
        TripDataManager.startingPoint = GFLocation(coordinates: CLLocationCoordinate2D(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude))
        TripDataManager.startingPoint?.name = "start"
    }
    
    //MARK:- IBActions
    
    @IBAction func gotoCurrentLocation(_ sender: UIButton) {
        requestCurrentLocation()
        locationPin.alpha = 0
    }
    
    //MARK:- UITextField Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        //Check for reachability
        if Reachability.isConnectedToNetwork() != true {
            popupAlert(title: "Alert", message: "Seems like there is no internet connection, please check back later", actionTitles: ["OK"], actions: [nil])
            return false
        }

        //push controller
        if let navController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GFNAVIGATEHOME") as? NavigateViewController {
            if let navigator = navigationController {
                navigator.pushViewController(navController, animated: false)
            }
        }
        return false
    }

    //MARK:- CLLocationManager Delegates
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
//        print("Address - \(MapsUtility.getAddressForLatLng(latitude: "\(locations[0].coordinate.latitude)", longitude: "\(locations[0].coordinate.longitude)"))")
        locationLat = "\(locations[0].coordinate.latitude)"
        locationLong = "\(locations[0].coordinate.longitude)"
        userCurrentLocation = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        self.mapView.setRegion(region, animated: true)
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        guard userCurrentLocation?.latitude != nil else {
            print("User location is nil")
            return
        }
        
        locationPin.alpha = 1
        animationScaleEffect(view: locationPin, animationTime: 0.1)
        
        let currentLoc = CLLocation(latitude: (userCurrentLocation?.latitude)!, longitude: (userCurrentLocation?.longitude)!)
        let selectedLoc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
        updateStartingPoint()
        
        print(currentLoc.distance(from: selectedLoc))
        
        let zoomWidth = mapView.visibleMapRect.size.width
        let zoomFactor = Int(log2(zoomWidth)) - 9
        let pinDistance = (20 * zoomFactor)

        if currentLoc.distance(from: selectedLoc) < CLLocationDistance(pinDistance)
        {
            locationPin.isHidden = true
        }else{
            locationPin.isHidden = false
        }

        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        print("Region will change.....!!!")
        locationPin.alpha = 0.5
    }
    
    func animationScaleEffect(view:UIView,animationTime:Float)
    {
        UIView.animate(withDuration: TimeInterval(animationTime), animations: {
            
            view.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            
        },completion:{completion in
            UIView.animate(withDuration: TimeInterval(animationTime), animations: { () -> Void in
                
                view.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        })
        
    }
    
}
