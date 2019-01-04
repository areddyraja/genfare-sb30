//
//  GFNavigateRouteViewController.swift
//  Genfare
//
//  Created by omniwzse on 29/08/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit
import MapKit

class GFNavigateRouteViewController: GFBaseViewController {

    @IBOutlet weak var routeNumberLabel: UILabel!
    @IBOutlet weak var transitType: UIImageView!
    
    @IBOutlet weak var routeLegs: GFRouteLegsScrollView!
    @IBOutlet weak var travelTimeLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var departsInLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var bannerView: GFCustomTableViewCellShadowView!
    
    var bannerStartY:CGFloat = 0.0
    var walkPoly:MKPolyline?
    var busPoly:MKPolyline?
    var startPoint:CLLocation?
    var endPoint:CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mapView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateRouteBannerView()
        self.routeLegs.showsHorizontalScrollIndicator = false

        DispatchQueue.main.asyncAfter(deadline: (.now() + .milliseconds(200))) {
            self.routeLegs.showsHorizontalScrollIndicator = true
            self.routeLegs.flashScrollIndicators()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        bannerStartY = bannerView.frame.origin.y
        animateBanner()
    }
    
    @IBAction func gotoPasses(_ sender: Any) {
//        if let navController = UIStoryboard(name: "Store", bundle: nil).instantiateViewController(withIdentifier: "GFPASSLIST") as? GFPassListViewController {
//            if let navigator = navigationController {
//                navigator.pushViewController(navController, animated: false)
//            }
//        }
        if TripHistoryManager.saveTripToRecents(route: TripDataManager.selectedRoute!) {
            print("trip saved")
        }else {
            print("trip already existing")
        }
        print(TripDataManager.selectedRoute?.recentTripString() ?? "")
        
        navigateToPasses()
    
    }
    
    func updateRouteBannerView() {
        routeLegs.reset()
        
        let route:GFRoute = TripDataManager.selectedRoute!
        routeNumberLabel.text = "Bus \(route.startBusNumber().stringUpTo(count: Constants.Values.MAX_CHAR_NUMBER_FOR_BUS))"
        routeNumberLabel.sizeToFit()
        
        travelTimeLabel.text = "Travel Time: \(Int(route.duration/60)) min"

        if (route.departsIn() < 10) {
            departsInLabel.textColor = UIColor.red
            minLabel.textColor = UIColor.red
        }else{
            departsInLabel.text = route.departsInStr()
            departsInLabel.textColor = UIColor.black
            minLabel.textColor = UIColor.black
        }
        
        if (departsInLabel.text?.count)! > 2 {
            minLabel.isHidden = true
        }else{
            minLabel.isHidden = false
        }
            
        departsInLabel.text = route.departsInStr()

        routeLegs.attachRouteItems(route: route)
    }
    
    func animateBanner() {
        bannerView.frame = CGRect(x: bannerView.frame.origin.x, y: bannerStartY+50, width: bannerView.frame.size.width, height: bannerView.frame.size.height)
        bannerView.alpha = 0
        
        UIView.animate(withDuration: 0.3,delay:0,
                       options:UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        self.bannerView.frame = CGRect(x: self.bannerView.frame.origin.x, y: self.bannerStartY, width: self.bannerView.frame.size.width, height: self.bannerView.frame.size.height)
                        self.bannerView.alpha = 1
        }, completion:{ (finished) -> Void in
            //print("Animation Completed")
            self.setupRegionForPolyline()
        })
    }
    
    func setupRegionForPolyline() {
        
        addPolyLines()
        addAnnotations()
        
        let zoom = startPoint?.distance(from: endPoint!)
        
        //Establish the center point for the map
        let centerLocation = CLLocationCoordinate2D(latitude: ((startPoint?.coordinate.latitude)!+(endPoint?.coordinate.latitude)!)*0.5, longitude: ((startPoint?.coordinate.longitude)!+(endPoint?.coordinate.longitude)!)*0.5)
        
        //Create a region and fit the map to it.
        let region = MKCoordinateRegionMakeWithDistance(centerLocation, zoom!, zoom!)
        mapView.setRegion(region, animated: true)
        
        //Second logic to center map with polylines
        //mapView.setVisibleMapRect((busPoly?.boundingMapRect)!, edgePadding: UIEdgeInsetsMake(150.0, 50.0, 50.0, 100.0), animated: true)
    }
    
    func addAnnotations() {
        let startAnn = MKPointAnnotation()
        startAnn.coordinate = (startPoint?.coordinate)!
        mapView.addAnnotation(startAnn)
        let endAnn = MKPointAnnotation()
        endAnn.coordinate = (endPoint?.coordinate)!
        mapView.addAnnotation(endAnn)
    }
    
    func addPolyLines() {
        let currentRoute:GFRoute = TripDataManager.selectedRoute!
        
        for i in 0...((currentRoute.legsList?.count)!-1) {
            let leg:GFRouteLeg = currentRoute.legsList![i]
            let locations = leg.polyPoints()
            if i == 0 {
                startPoint = locations.first
            }
            if i == ((currentRoute.legsList?.count)!-1) {
                endPoint = locations.last
            }
            
            if leg.mode == Constants.TransitMode.Walk {
                addPolyLineForWalk(locations: locations)
            }else{
                addPolyLineForBus(locations: locations)
            }
        }
    }
    
    func addPolyLineForWalk(locations:[CLLocation?]) {
        var coordinates = locations.map({ (location:CLLocation!) -> CLLocationCoordinate2D in
            return location.coordinate
        })
        
        let polyline = MKPolyline(coordinates: &coordinates, count: locations.count)
        walkPoly = polyline
        self.mapView.add(polyline)
    }
    
    func addPolyLineForBus(locations:[CLLocation?]) {
        var coordinates = locations.map({ (location:CLLocation!) -> CLLocationCoordinate2D in
            return location.coordinate
        })
        
        let polyline = MKPolyline(coordinates: &coordinates, count: locations.count)
        busPoly = polyline
        self.mapView.add(polyline)
    }
}

extension GFNavigateRouteViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if (overlay is MKPolyline) {
            if overlay as? MKPolyline == walkPoly {
                let pr = MKPolylineRenderer(overlay: overlay)
                pr.strokeColor = UIColor.buttonBGBlue
                pr.lineWidth = 5
                pr.lineDashPattern = [2,10]
                return pr
            }else{
                let pr = MKPolylineRenderer(overlay: overlay)
                pr.strokeColor = UIColor.red
                pr.lineWidth = 5
                return pr
            }
        }
        
        return MKPolylineRenderer()
    }
}
