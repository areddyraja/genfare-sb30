//
//  GFLaunchViewController.swift
//  Genfare
//
//  Created by vishnu on 09/01/19.
//  Copyright © 2019 Genfare. All rights reserved.
//

import UIKit

class GFLaunchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let launchScreenViewModel = LaunchScreenViewModel()
        print(launchScreenViewModel)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
