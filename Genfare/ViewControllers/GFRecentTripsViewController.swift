//
//  GFRecentTripsViewController.swift
//  Genfare
//
//  Created by omniwzse on 24/08/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit

class GFRecentTripsViewController: GFBaseViewController,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return TripHistoryManager.getRecentTrips().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HISTORYCELL", for: indexPath) as! GFHistoryTableViewCell
        let recentTrip:GFRecentTrip = TripHistoryManager.getRecentTrips()[indexPath.row]
        cell.titleText?.text = recentTrip.destinationShort
        cell.descText?.text = recentTrip.tripSubString
        cell.iconImage?.image = UIImage(named: "Bus button")
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension GFRecentTripsViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if let navController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GFTIMETABLE") as? GFNavigateTimingsViewController {
            if let navigator = navigationController {
                navigator.pushViewController(navController, animated: false)
            }
        }
        setupTripData(index: indexPath.row)
    }
    
    func setupTripData(index:Int) {
        let selectedTrip:GFRecentTrip = TripHistoryManager.getRecentTrips()[index]
        TripDataManager.startingPoint = selectedTrip.startLocation
        TripDataManager.endPoint = selectedTrip.endLocation
    }
}
