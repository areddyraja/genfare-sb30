//
//  GFSampleViewController.swift
//  Genfare
//
//  Created by omniwzse on 30/08/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON

class GFSampleViewController: GFBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        //TripDataManager.getStopsInBetween()
        //print("Result : - \(TripDataManager.getStopsInBetween())")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func showList(_ sender: UIButton) {
        let gfStation:GFStation = TripDataManager.stationsList![2]
        
        print(gfStation.name)
        
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
