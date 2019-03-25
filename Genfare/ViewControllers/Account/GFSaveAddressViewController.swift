//
//  GFSaveAddressViewController.swift
//  Genfare
//
//  Created by omniwyse on 12/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class GFSaveAddressViewController: GFBaseViewController,MKLocalSearchCompleterDelegate,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate{
    @IBOutlet var navigationBtn: UIImageView!
    
    @IBOutlet var currentLbl: UILabel!
    @IBOutlet var bgview: UIView!
    @IBOutlet var addressTableview: UITableView!
    
     var locationManager:CLLocationManager!
    var addressFor:String = ""
    var selectedplacemark:CLPlacemark!
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
     var selectedresponse:MKLocalSearch.Response?
    @IBOutlet var addressInputField: UITextField!
    @IBOutlet var currentLocationField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
         self.addressInputField.delegate = self;
        barButtonIteams()
     currentLocationField.addTarget(self, action: #selector(getCurrentLocation), for: UIControlEvents.touchDown)
        self.searchCompleter.delegate = self
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor.formLabelText
        navigationController?.setNavigationBarHidden(false, animated: false);
        navigationController?.navigationBar.barTintColor = UIColor.buttonBGBlue
            }
    func showSuggessions(_ letter: String?) {
        let query = "\(String(describing: addressInputField.text!))\(letter!)"
        searchCompleter.queryFragment = query
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        showSuggessions(string)
        return true
    }
    
    func barButtonIteams(){
        var cancelBarBtn = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelClicked)
        )
        self.navigationItem.leftBarButtonItem = cancelBarBtn
       
    var saveBarBtn = UIBarButtonItem(
            title: "save",
            style: .plain,
            target: self,
            action: #selector(saveClicked)
        )
        var addressTitle = addressFor.uppercased() + "ADDRESS"
        self.navigationItem.title = addressTitle
        self.navigationItem.rightBarButtonItem  = saveBarBtn
         self.navigationController?.navigationBar.tintColor = UIColor.white
    }
   
    
    @objc func getCurrentLocation(textField: UITextField) {
       determineCurrentLocation()
    }
    @objc func cancelClicked(sender: UIBarButtonItem) {
          navigationController?.popViewController(animated: true)
    }
    @objc func saveClicked(sender: UIBarButtonItem) {
        if(addressInputField.text == nil){
       popupAlert(title: "Alert", message: "Please select an address from the list", actionTitles: ["OK"], actions: [nil])
        }
        else{
        if(selectedplacemark != nil){
            savecompleteAddress(response: selectedplacemark)
        }else{
            print("no")
        }
        }
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        addressTableview.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let searchResult = searchResults[indexPath.row]
        let cell = addressTableview.dequeueReusableCell(withIdentifier: "GFAddressTableViewCell", for: indexPath) as! GFAddressTableViewCell
        cell.titleLabel.text = searchResult.title
        cell.descriptionLabel.text = searchResult.subtitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let completion = searchResults[indexPath.row]
        
        let searchRequest = MKLocalSearchRequest(completion: completion)
        self.addressInputField.text = completion.title   + completion.subtitle
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
             let placemark = response?.mapItems[0].placemark
            self.selectedplacemark = placemark!
            self.selectedresponse = response
        }
    }
    
    func savecompleteAddress(response:CLPlacemark){
        do{
        let placemark = response
       
        let name = placemark.name
        let sub = placemark.subThoroughfare
        let thoroughfare = placemark.thoroughfare
        let iso = placemark.isoCountryCode
        
        let managedContext = GFDataService.context
        let storedContents = NSEntityDescription.entity(forEntityName: "StoredAddress", in: managedContext)
        var storeObj:StoredAddress
        let fetchRequest:NSFetchRequest = StoredAddress.fetchRequest()
            if(addressFor as? String == "home" ){
        fetchRequest.predicate = NSPredicate(format: "type == %@",("home"))
            }
            else if(addressFor as? String == "work"){
                fetchRequest.predicate = NSPredicate(format: "type == %@",("work"))
            }
            else if(addressFor as? String == "school"){
                fetchRequest.predicate = NSPredicate(format: "type == %@",("school"))
            }
        let fetchResults = try managedContext.fetch(fetchRequest) as! Array<StoredAddress>
        if fetchResults.count <= 0 {
             storeObj = NSManagedObject(entity: storedContents!, insertInto: managedContext) as! StoredAddress
        }else{
            storeObj = fetchResults.first!
        }
        
        storeObj.name = name
        storeObj.subThoroughfare = sub
        storeObj.thoroughfare = thoroughfare
        storeObj.isoCountryCode = iso
        storeObj.type = addressFor as! String
        }
        catch{
            print("saving failed ")
        }

        GFDataService.saveContext()
        navigationController?.popViewController(animated: true)
    }
    func determineCurrentLocation()
    {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
           
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
            if (error != nil){
                print("error in reverseGeocode")
            }
            let placemark = placemarks! as [CLPlacemark]
            if placemark.count>0{
                let placemark = placemarks![0]
                self.selectedplacemark = placemark
                self.currentLocationField.isUserInteractionEnabled = false
                let name = placemark.name
               let thoroughfare = placemark.thoroughfare
                self.addressInputField.text = name! + thoroughfare!
                
               
            }
        }
        
       
    }
    
}

