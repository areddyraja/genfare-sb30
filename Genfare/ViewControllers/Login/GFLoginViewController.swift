//
//  GFLoginViewController.swift
//  Genfare
//
//  Created by omniwzse on 29/08/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GFLoginViewController: GFBaseViewController {
    
    let viewModel = LoginViewModel()
    let disposeBag = DisposeBag()
    var loginService:GFLoginService?
    
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var forgotPasswordBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        createViewModelBinding()
        createCallbacks()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func createViewModelBinding(){
        emailTxt.rx.text.orEmpty
            .bind(to: viewModel.emailIdViewModel.data)
            .disposed(by: disposeBag)
        
        passwordTxt.rx.text.orEmpty
            .bind(to: viewModel.passwordViewModel.data)
            .disposed(by: disposeBag)
        
        signInBtn.rx.tap.do(onNext:  { [unowned self] in
            self.emailTxt.resignFirstResponder()
            self.passwordTxt.resignFirstResponder()
        }).subscribe(onNext: { [unowned self] in
            if self.viewModel.validateCredentials() {
                self.viewModel.loginUser()
            }else{
                self.popupAlert(title: "Error", message: self.viewModel.formErrorString(), actionTitles: ["OK"], actions: [nil])
            }
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
        
        // errors
        viewModel.errorMsg.asObservable()
            .bind {[unowned self] errorMessage in
                // Show error
                if errorMessage != ""{
                    self.popupAlert(title: "ERROR", message: errorMessage, actionTitles: ["OK"], actions: [nil])
                }
            }.disposed(by: disposeBag)

        // Walletcreation
        viewModel.walletNeeded.asObservable()
            .bind{ [unowned self] value in
                NSLog("Need Wallet \(value)")
            }.disposed(by: disposeBag)
        
        // Walletselection
        viewModel.showWalletList.asObservable()
            .bind{ [unowned self] value in
                if let list = value as? Array<Any>, list.count > 0 {
                    NSLog("Need Wallet \(value)")
                    if let controller = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: Constants.StoryBoard.SelectWallet) as? GFWalletSelectionViewController {
                        controller.walletList = list
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            }.disposed(by: disposeBag)
    }
}
