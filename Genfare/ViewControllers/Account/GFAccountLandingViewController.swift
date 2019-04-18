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
            }.disposed(by: disposeBag)
        
        // Loading
        viewModel.isLoading.asObservable()
            .bind{[unowned self] value in
                NSLog("Loading \(value)")
                self.attachSpinner(value: value)
            }.disposed(by: disposeBag)
        
        // errors
        viewModel.errorMsg.asObservable()
            .bind {[unowned self] errorMessage in
                // Show error
                if errorMessage != "" {
                    self.showErrorMessage(message: errorMessage)
                }
            }.disposed(by: disposeBag)
        
        // Show Account based
        viewModel.accountBased.asObservable()
            .bind{ [unowned self] value in
                if value, let controller = UIStoryboard(name: "AccountHome", bundle: nil).instantiateViewController(withIdentifier: Constants.StoryBoard.AccountBased) as? GFAccountBasedHomeViewController {
                    self.navigationController?.pushViewController(controller, animated: false)
                }
            }.disposed(by: disposeBag)
        
        // Show Card based
        viewModel.cardBased.asObservable()
            .bind{ [unowned self] value in
                if value, let controller = UIStoryboard(name: "AccountHome", bundle: nil).instantiateViewController(withIdentifier: Constants.StoryBoard.CardBased) as? GFCardBasedHomeViewController {
                    self.navigationController?.pushViewController(controller, animated: false)
                }
            }.disposed(by: disposeBag)
    }
}
