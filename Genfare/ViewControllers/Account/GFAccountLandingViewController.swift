//
//  GFAccountLandingViewController.swift
//  Genfare
//
//  Created by vishnu on 01/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GFAccountLandingViewController: GFBaseViewController {

    let viewModel = GFAccountLandingViewModel()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        updateNavBarUI()
        createCallbacks()
        createViewModelBinding()

    }
    
    override func viewWillAppear( _ animated:Bool){
        super.viewWillAppear(animated)
        viewModel.checkWalletStatus()
    }

    func createViewModelBinding(){
    
    }
    
    func createCallbacks (){
        // success
        viewModel.isSuccess.asObservable()
            .bind{ [unowned self] value in
                NSLog("Successfull \(value)")
                if value, let controller = UIStoryboard(name: "AccountHome", bundle: nil).instantiateViewController(withIdentifier: Constants.StoryBoard.AccountBased) as? GFAccountBasedHomeViewController {
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }.disposed(by: disposeBag)
        
        // Loading
        viewModel.isLoading.asObservable()
            .bind{[unowned self] value in
                NSLog("Loading \(value)")
                if value {
                    if let spinner = self.spinnerView {
                        spinner.removeFromSuperview()
                        self.spinnerView = UIViewController.displaySpinner(onView: self.view)
                    }
                }else{
                    if let _ = self.spinnerView {
                        UIViewController.removeSpinner(spinner: self.spinnerView!)
                    }
                }
            }.disposed(by: disposeBag)
        
        // Show Account based
        viewModel.accountBased.asObservable()
            .bind{ [unowned self] value in
                if value {
                    //show account based
                }
            }.disposed(by: disposeBag)
        
        // Show Card based
        viewModel.cardBased.asObservable()
            .bind{ [unowned self] value in
                if value {
                    //show card based
                }
            }.disposed(by: disposeBag)

    }
}
