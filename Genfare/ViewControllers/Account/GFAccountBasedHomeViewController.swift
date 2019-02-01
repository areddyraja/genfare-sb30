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
    }
    
    override func viewWillAppear( _ animated:Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .black
        navigationController?.setNavigationBarHidden(false, animated: false);
        navigationController?.navigationBar.barTintColor = UIColor.buttonBGBlue
        viewModel.updateWalletStatus()
        attachPassList()
    }
    
    func attachPassList() {
        if let controller = UIStoryboard(name: "Passes", bundle: nil).instantiateViewController(withIdentifier: Constants.StoryBoard.PayAsYouGoList) as? GFPayGoPassTableViewController {
            self.addChildViewController(controller)
            self.pageControlHolder.addSubview(controller.view)
            controller.didMove(toParentViewController: self)
        }
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
                    self.popupAlert(title: "Success", message: "Login Successful...!!!", actionTitles: ["OK"], actions: [nil])
                }
            }.disposed(by: disposeBag)
        
        // Loading
        viewModel.isLoading.asObservable()
            .bind{[unowned self] value in
                NSLog("Loading \(value)")
                if value {
                    self.spinnerView = UIViewController.displaySpinner(onView: self.view)
                }else{
                    if let _ = self.spinnerView {
                        UIViewController.removeSpinner(spinner: self.spinnerView!)
                    }
                }
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
}
