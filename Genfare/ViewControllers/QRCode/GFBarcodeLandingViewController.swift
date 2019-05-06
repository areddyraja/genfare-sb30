//
//  GFBarcodeLandingViewController.swift
//  Genfare
//
//  Created by vishnu on 11/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit

class GFBarcodeLandingViewController: GFBaseViewController,CAPSPageMenuDelegate {

    var ticket:WalletContents!
    var pageMenu:CAPSPageMenu!
    var baseClass:UIViewController?

    @IBOutlet weak var pageHolder: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        attachContentView()
    }
    
    override func viewWillAppear( _ animated:Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false);
        navigationController?.navigationBar.barTintColor = UIColor.topNavBarColor
        
        // Do any additional setup after loading the view.
    }
    
    func attachContentView() {
        var controllerArray : [UIViewController] = []
        
        // Create variables for all view controllers you want to put in the
        // page menu, initialize them, and add each to the controller array.
        // (Can be any UIViewController subclass)
        // Make sure the title property of all view controllers is set
        // Example:
        let barCode : GFBarcodeScreenViewController = (UIStoryboard(name: "Barcode", bundle: nil).instantiateViewController(withIdentifier: Constants.StoryBoard.BarCode) as? GFBarcodeScreenViewController)!
        barCode.title = "Barcode"
        barCode.baseClass = self
        barCode.ticket = ticket
        controllerArray.append(barCode)
        
        let qrInfo : GFBarcodeInfoViewController = (UIStoryboard(name: "Barcode", bundle: nil).instantiateViewController(withIdentifier: Constants.StoryBoard.BarCodeInfo) as? GFBarcodeInfoViewController)!
        qrInfo.title = "Information"
        qrInfo.baseClass = self
        qrInfo.ticket = ticket
        controllerArray.append(qrInfo)
        
        // Customize page menu to your liking (optional) or use default settings by sending nil for 'options' in the init
        // Example:
        let parameters: [CAPSPageMenuOption] = [
            .menuItemSeparatorWidth(2.0),
            .useMenuLikeSegmentedControl(true),
            .selectionIndicatorColor(UIColor.buttonBGBlue),
            .scrollMenuBackgroundColor(.white),
            .selectedMenuItemLabelColor(.black),
            .unselectedMenuItemLabelColor(.gray),
            .menuHeight(50.0)
        ]
        
        // Initialize page menu with controller array, frame, and optional parameters
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x:0.0, y:0.0, width:view.frame.width, height:view.frame.height), pageMenuOptions: parameters)
        pageMenu.delegate = self
        
        // Lastly add page menu as subview of base view controller view
        // or use pageMenu controller in you view hierachy as desired
        self.pageHolder.addSubview(pageMenu!.view)
    }

}
