//
//  GFNavigateTimingsViewController.swift
//  Genfare
//
//  Created by omniwzse on 29/08/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit

class GFNavigateTimingsViewController: GFBaseViewController {

    @IBOutlet weak var destinationText: UITextField!
    @IBOutlet weak var startText: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var fastestBtn: GFMenuButton!
    @IBOutlet weak var cheapestBtn: GFMenuButton!
    @IBOutlet weak var transfersBtn: GFMenuButton!
    @IBOutlet weak var minWalkBtn: GFMenuButton!
    @IBOutlet weak var swapButton: UIButton!
    
    
    @IBOutlet weak var costTxtButton: GFMenuButton!
    @IBOutlet weak var arrivalTxtButton: GFMenuButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self

        TripDataManager.getRoutsForLocations { (success) in
            print("Got locations successfully")
            DispatchQueue.main.async {
                self.loadingIndicator.isHidden = true
            }
            if success {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.updateArrivalAndCost()
                }
            }else{
                DispatchQueue.main.async {
                    self.popupAlert(title: "Alert", message: "Unable to fetch routes for this location, Please try again later", actionTitles: ["OK"], actions: [{ Void in
                        self.navigationController?.popViewController(animated: true)
                        }])
                }
            }
        }
        filterResults(fastestBtn)
    }

    override func viewWillAppear(_ animated: Bool) {
        resetInputText()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func resetInputText() {
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        startText.text = TripDataManager.startingPoint?.formattedAddress
        destinationText.text = TripDataManager.endPoint?.formattedAddress
    }
    
    func updateArrivalAndCost() {
        guard (TripDataManager.routesList?.count)! > 0 else {
            print("no Items in array")
            return
        }
        
        let route:GFRoute = (TripDataManager.routesList?.first)!
        costTxtButton.setTitle(String(format:"$%.2f",(route.fare!/100)), for: .normal)
        arrivalTxtButton.setTitle(route.arrivalTimeString(), for: .normal)
    }
    
    @IBAction func switchDestination(_ sender: UIButton) {
        sender.isEnabled = false
        let tempLoc:GFLocation = GFLocation(coordinates: (TripDataManager.endPoint?.coordinates)!)
        tempLoc.formattedAddress = TripDataManager.endPoint?.formattedAddress
        
        TripDataManager.endPoint = TripDataManager.startingPoint
        TripDataManager.startingPoint = tempLoc
        
        resetInputText()
        
        startText.text = TripDataManager.startingPoint?.formattedAddress
        destinationText.text = TripDataManager.endPoint?.formattedAddress

        TripDataManager.getRoutsForLocations { (success) in
            print("Got locations successfully")
            DispatchQueue.main.async {
                self.loadingIndicator.isHidden = true
                self.swapButton.isEnabled = true
            }
            
            if success {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.updateArrivalAndCost()
                }
            }else{
                DispatchQueue.main.async {
                    self.popupAlert(title: "Alert", message: "Unable to fetch routes for this location, Please try again later", actionTitles: ["OK"], actions: [{ Void in
                        self.navigationController?.popViewController(animated: true)
                        }])
                }
            }
        }
        
        tableView.reloadData()
    }
    
    @IBAction func filterResults(_ sender: GFMenuButton) {
        fastestBtn.backgroundColor = UIColor.buttonBGBlue
        fastestBtn.setTitleColor(UIColor.white, for: .normal)
        cheapestBtn.backgroundColor = UIColor.buttonBGBlue
        cheapestBtn.setTitleColor(UIColor.white, for: .normal)
        transfersBtn.backgroundColor = UIColor.buttonBGBlue
        transfersBtn.setTitleColor(UIColor.white, for: .normal)
        minWalkBtn.backgroundColor = UIColor.buttonBGBlue
        minWalkBtn.setTitleColor(UIColor.white, for: .normal)

        switch sender {
            case fastestBtn:
                print("fastest")
                TripDataManager.routesList = TripDataManager.routesList?.sorted(by: {Double($0.duration!) < Double($1.duration!) })
            case cheapestBtn:
                print("cheapest")
                TripDataManager.routesList = TripDataManager.routesList?.sorted(by: {Double($0.fare!) < Double($1.fare!) })
            case transfersBtn:
                print("min transfers")
                TripDataManager.routesList = TripDataManager.routesList?.sorted(by: {$0.transfers < $1.transfers })
            case minWalkBtn:
                print("min walk")
                TripDataManager.routesList = TripDataManager.routesList?.sorted(by: {Double($0.walkDistance!) < Double($1.walkDistance!) })
            default:
                print("default")
        }
        
        tableView.reloadData()
        updateArrivalAndCost()

        sender.backgroundColor = UIColor.white
        sender.setTitleColor(UIColor.black, for: .normal)
    }
}

extension GFNavigateTimingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        TripDataManager.selectedRoute = TripDataManager.routesList?[indexPath.row]
        loadMapView()
        //tableView.isHidden = true
    }
    
    func loadMapView() {
        if let navController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GFROUTEMAP") as? GFNavigateRouteViewController {
            if let navigator = navigationController {
                navigator.pushViewController(navController, animated: false)
            }
        }
    }
}

extension GFNavigateTimingsViewController: UITableViewDataSource {
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return TripDataManager.routesList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let route:GFRoute = TripDataManager.routesList![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ROUTECELL", for: indexPath) as! GFRouteOptionTableViewCell
        cell.routeNumLabel.text = "Bus \(route.startBusNumber())"
        cell.routeNumLabel.sizeToFit()
        cell.travelTimeLabel.text = "Travel Time: \(Int(route.duration!/60)) min"
        if (Int(route.departsIn())! < 10) {
            cell.depInTime.text = "0"+route.departsIn()
            cell.depInTime.textColor = UIColor.red
            cell.depUnits.textColor = UIColor.red
        }else{
            cell.depInTime.text = route.departsIn()
            cell.depInTime.textColor = UIColor.black
            cell.depUnits.textColor = UIColor.black
        }
        cell.reset()
        cell.attachRouteItems(route: route)
        return cell
    }
}
