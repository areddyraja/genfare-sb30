//
//  NavigateViewController.swift
//  Genfare
//
//  Created by omniwzse on 14/08/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit
import MapKit

class NavigateViewController: GFBaseViewController, UITextFieldDelegate {

    var startingPoint:String?
    var stationsList:Array<GFStation>?
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var isTyping:Bool = false
    
    @IBOutlet weak var startText: UITextField!
    @IBOutlet weak var destinationText: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var swapButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        destinationText.delegate = self
        startText.delegate = self
        searchCompleter.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateAddressForStart()
        currentTextField = destinationText
        destinationText.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    func updateAddressForStart() {
        let geoCoder = CLGeocoder()
        let location:CLLocation = CLLocation(latitude: (TripDataManager.startingPoint?.coordinates.latitude)!, longitude: (TripDataManager.startingPoint?.coordinates.longitude)!)
        geoCoder.reverseGeocodeLocation(location) { (placeMarks, error) in
            if error == nil {
                let address = MapsUtility.addressFromPlaceMark(placeMark: placeMarks![0])
                TripDataManager.startingPoint?.formattedAddress = address
                DispatchQueue.main.async {
                    self.startText.text = address
                    print(self.startText.text ?? "")
                }
            }else{
                print(error.debugDescription)
            }
        }
    }
    
    func showSuggestions(char:String) {
        let currentStr = (currentTextField?.text)!+char
        
        searchCompleter.queryFragment = currentStr
    }
    
    func loadTimingsController() {
        //push controller
        TripDataManager.startingPointString = startText.text
        TripDataManager.endPointString = destinationText.text
        
        if let navController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GFTIMETABLE") as? GFNavigateTimingsViewController {
            if let navigator = navigationController {
                navigator.pushViewController(navController, animated: false)
            }
        }
    }
    
    //MARK:- UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == startText {
            startText.endEditing(true)
            destinationText.becomeFirstResponder()
        }else{
            destinationText.endEditing(true)
            if destinationText.text != "" {
                loadTimingsController()
            }
        }
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == destinationText {
            currentTextField = destinationText
        }else{
            currentTextField = startText
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(string,range)
        isTyping = true
        showSuggestions(char: string)
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        isTyping = false
        showSuggestions(char: "")
        return true
    }
    
    // MARK: - IB Actions
    @IBAction func homeButtonAction(_ sender: UIButton) {
        currentTextField?.text = Constants.Address.Home
        updateLocationSelection(str: Constants.Address.Home)
    }
    
    @IBAction func schoolButtonAction(_ sender: UIButton) {
        currentTextField?.text = Constants.Address.School
        updateLocationSelection(str: Constants.Address.School)
    }
    
    @IBAction func workButtonAction(_ sender: UIButton) {
        currentTextField?.text = Constants.Address.Work
        updateLocationSelection(str: Constants.Address.Work)
    }
    
    @IBAction func switchDestination(_ sender: UIButton) {
        
        guard (TripDataManager.endPoint?.coordinates) != nil else {
            print("No end point created")
            popupAlert(title: "Alert", message: "Please fill starting point and destination before swapping.", actionTitles: ["OK"], actions: [nil])
            return
        }
        
        guard (TripDataManager.startingPoint?.coordinates) != nil else {
            popupAlert(title: "Alert", message: "Please fill starting point and destination before swapping.", actionTitles: ["OK"], actions: [nil])
            return
        }

        var tempLoc:GFLocation = GFLocation(coordinates: (TripDataManager.endPoint?.coordinates)!)
        tempLoc.formattedAddress = TripDataManager.endPoint?.formattedAddress
        
        TripDataManager.endPoint = TripDataManager.startingPoint
        TripDataManager.startingPoint = tempLoc
        
        startText.text = TripDataManager.startingPoint?.formattedAddress
        destinationText.text = TripDataManager.endPoint?.formattedAddress
    }

    func updateLocationSelection(str:String) {
        var location:GFLocation?
        switch str {
            case Constants.Address.Work:
                location = GFLocation(coordinates: CLLocationCoordinate2D(latitude: 40.143917999999999, longitude: -82.968945000000005))
            case Constants.Address.School:
                location = GFLocation(coordinates: CLLocationCoordinate2D(latitude: 39.830418999999999, longitude: -82.933276000000006))
            case Constants.Address.Home:
                location = GFLocation(coordinates: CLLocationCoordinate2D(latitude: 40.145536800000002, longitude: -82.981750700000006))
            default:
                print("default")
        }
        
        location?.formattedAddress = currentTextField?.text

        if currentTextField == startText {
            TripDataManager.startingPoint = location
        }else{
            TripDataManager.endPoint = location
        }
    }
    
}

extension NavigateViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        guard isTyping == true else {
            
            //LOAD RECENT TRIPS
            if let navController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GFTIMETABLE") as? GFNavigateTimingsViewController {
                if let navigator = navigationController {
                    navigator.pushViewController(navController, animated: false)
                }
            }

            let selectedTrip:GFRecentTrip = TripHistoryManager.getRecentTrips()[indexPath.row]
            TripDataManager.startingPoint = selectedTrip.startLocation
            TripDataManager.endPoint = selectedTrip.endLocation

            return
        }
        
        let completion = searchResults[indexPath.row]
        currentTextField?.text = ("\(completion.title) \(completion.subtitle)")
        
        let searchRequest = MKLocalSearchRequest(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            let coordinate = response?.mapItems[0].placemark.coordinate
            if self.currentTextField == self.startText {
                TripDataManager.startingPoint = GFLocation(coordinates: CLLocationCoordinate2D(latitude: (coordinate?.latitude)!, longitude: (coordinate?.longitude)!))
                TripDataManager.startingPoint?.formattedAddress = self.currentTextField?.text
            }else {
                TripDataManager.endPoint = GFLocation(coordinates: CLLocationCoordinate2D(latitude: (coordinate?.latitude)!, longitude: (coordinate?.longitude)!))
                TripDataManager.endPoint?.formattedAddress = self.currentTextField?.text
            }
            print(String(describing: coordinate))
        }
        
        searchResults = []
        tableView.reloadData()
    }
}

extension NavigateViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //return stationsList?.count ?? 0
        return isTyping ? searchResults.count : TripHistoryManager.getRecentTrips().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        
        if isTyping {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "ROUTECELL", for: indexPath) as! GFStationListTableViewCell
            let searchResult = searchResults[indexPath.row]
            cell1.stationName.text = searchResult.title
            cell1.stationAddress.text = searchResult.subtitle
            cell = cell1
        }else{
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "HISTORYCELL", for: indexPath) as! GFHistoryTableViewCell
            //Assign values to cell
            let recentTrip:GFRecentTrip = TripHistoryManager.getRecentTrips()[indexPath.row]
            cell2.titleText?.text = recentTrip.destinationShort
            cell2.descText?.text = recentTrip.tripSubString
            cell2.iconImage?.image = UIImage(named: "Bus button")

            cell = cell2
        }
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isTyping {
            return 60.0
        }else{
            return 70.0
        }
    }
    
}

extension NavigateViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        tableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        //TODO:Handle search results Error
    }
}



