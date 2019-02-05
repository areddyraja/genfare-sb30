//
//  GFAccountBasedHomeViewController.swift
//  Genfare
//
//  Created by vishnu on 28/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class GFAccountBasedHomeViewController: GFBaseViewController {

    let viewModel = GFAccountBasedHomeViewModel()
    let disposeBag = DisposeBag()
    var pageMenu:CAPSPageMenu?

    @IBOutlet weak var pageControlHolder: UIView!
    @IBOutlet weak var addFundsBtn: GFMenuButton!
    @IBOutlet weak var acctMgtBtn: GFMenuButton!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var walletTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        updateNavBarUI()
        createCallbacks()
        createViewModelBinding()
        
        attachPassList()
    }
    
    override func viewWillAppear( _ animated:Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .black
        navigationController?.setNavigationBarHidden(false, animated: false);
        navigationController?.navigationBar.barTintColor = UIColor.buttonBGBlue
        viewModel.updateWalletStatus()
        //attachPassList()
    }
    
    func createViewModelBinding(){
        addFundsBtn.rx.tap.do(onNext:  { [unowned self] in
        }).subscribe(onNext: { [unowned self] in
            //show products page
        }).disposed(by: disposeBag)
        
        acctMgtBtn.rx.tap.do(onNext:  { [unowned self] in
        }).subscribe(onNext: { [unowned self] in
            //show account management
        }).disposed(by: disposeBag)
    }
    
    func createCallbacks (){
        // success
        viewModel.isSuccess.asObservable()
            .bind{ [unowned self] value in
                NSLog("Successfull \(value)")
                if value{
                    //self.popupAlert(title: "Success", message: "Login Successful...!!!", actionTitles: ["OK"], actions: [nil])
                }
            }.disposed(by: disposeBag)
        
        // Loading
        viewModel.isLoading.asObservable()
            .bind{[unowned self] value in
                self.attachSpinner(value: value)
            }.disposed(by: disposeBag)
        
        //Update balance
        viewModel.balance.asObservable()
            .bind{ [unowned self] value in
                NSLog(" \(value)")
                self.balanceLabel.text = "$\(value)"
            }.disposed(by: disposeBag)
        
        //Update wallet status
        viewModel.walletState.asObservable()
            .bind{ [unowned self] value in
                NSLog(" \(value)")
                self.addFundsBtn.isEnabled = value
            }.disposed(by: disposeBag)
        
        //Update wallet name
        viewModel.walletName.asObservable()
            .bind{ [unowned self] value in
                NSLog(" \(value)")
                self.walletTitleLabel.text = value
            }.disposed(by: disposeBag)
    }
    
    func attachPassList() {
        var controllerArray : [UIViewController] = []
        
        // Create variables for all view controllers you want to put in the
        // page menu, initialize them, and add each to the controller array.
        // (Can be any UIViewController subclass)
        // Make sure the title property of all view controllers is set
        // Example:
        let myPasses : GFMyPassesTableViewController = (UIStoryboard(name: "Passes", bundle: nil).instantiateViewController(withIdentifier: Constants.StoryBoard.MyPassesList) as? GFMyPassesTableViewController)!
        myPasses.title = "Passes"
        controllerArray.append(myPasses)
        
        let payPasses : GFPayGoPassTableViewController = (UIStoryboard(name: "Passes", bundle: nil).instantiateViewController(withIdentifier: Constants.StoryBoard.PayAsYouGoList) as? GFPayGoPassTableViewController)!
        payPasses.title = "Pay As You Go"
        controllerArray.append(payPasses)
        
        let myActivity : GFActivityTableViewController = (UIStoryboard(name: "Passes", bundle: nil).instantiateViewController(withIdentifier: Constants.StoryBoard.MyHistoryList) as? GFActivityTableViewController)!
        myActivity.title = "Activity"
        controllerArray.append(myActivity)
        
        // Customize page menu to your liking (optional) or use default settings by sending nil for 'options' in the init
        // Example:
        let parameters: [CAPSPageMenuOption] = [
            .menuItemSeparatorWidth(4.3),
            .useMenuLikeSegmentedControl(true),
            .menuItemSeparatorPercentageHeight(0.1)
        ]
        
        // Initialize page menu with controller array, frame, and optional parameters
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x:0.0, y:0.0, width:pageControlHolder.frame.width, height:pageControlHolder.frame.height), pageMenuOptions: parameters)
        
        // Lastly add page menu as subview of base view controller view
        // or use pageMenu controller in you view hierachy as desired
        self.pageControlHolder.addSubview(pageMenu!.view)
    }
    
}