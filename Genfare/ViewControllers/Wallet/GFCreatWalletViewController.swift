//
//  GFCreatWalletViewController.swift
//  Genfare
//
//  Created by vishnu on 24/01/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GFCreatWalletViewController: GFBaseViewController {

    let viewModel = CreateWalletViewModel()
    let disposeBag = DisposeBag()

    var createWalletService:GFWalletsService?

    @IBOutlet weak var walletNameTxt: UITextField!
    @IBOutlet weak var createBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        createViewModelBinding()
        createCallbacks()
    }
    
    func createViewModelBinding(){
        walletNameTxt.rx.text.orEmpty
            .bind(to: viewModel.walletNameViewModel.data)
            .disposed(by: disposeBag)
        
        createBtn.rx.tap.do(onNext:  { [unowned self] in
            self.walletNameTxt.resignFirstResponder()
        }).subscribe(onNext: { [unowned self] in
            if self.viewModel.validateCredentials() {
                self.spinnerView = UIViewController.displaySpinner(onView: self.view)
                self.createWalletService = GFWalletsService()
                self.createWalletService?.createWallet(nickname: self.walletNameTxt.text!, completionHandler: { (success, error) in
                    if (success!){
                        print("Wallet created successfully")
                    }else{
                        print("Error creating wallet")
                    }
                    UIViewController.removeSpinner(spinner: self.spinnerView!)
                })
            }else{
                self.popupAlert(title: "Error", message: self.viewModel.formErrorString(), actionTitles: ["OK"], actions: [nil])
            }
        }).disposed(by: disposeBag)
    }
    
    func createCallbacks (){
        // success
        viewModel.isSuccess.asObservable()
            .bind{ value in
                NSLog("Successfull")
            }.disposed(by: disposeBag)
        
        // errors
        viewModel.errorMsg.asObservable()
            .bind { errorMessage in
                // Show error
                NSLog("Failure")
            }.disposed(by: disposeBag)
        
    }
    
}
