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

class GFLoginViewController: GFBaseViewController, LoginServiceDelegate {
    
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
                self.spinnerView = UIViewController.displaySpinner(onView: self.view)
                self.loginService = GFLoginService(username: self.emailTxt.text!, password: self.passwordTxt.text!)
                self.loginService?.delegate = self
                self.loginService?.loginUser()
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
    
    //Pragma mark - LoginService Delegate methods

    func didFinishLoginSuccessfully(_ sender: Any) {
        UIViewController.removeSpinner(spinner: self.spinnerView!)
        popupAlert(title: "Success", message: "Login Successful...!!!", actionTitles: ["OK"], actions: [nil])
        
    }
    
    func didLoginNeedSMSAuth(_ sender: Any) {
        //
    }
    
    func didLoginNeedWallet(_ sender: Any) {
        //
    }
    
    func didFailLoginWithError(_ error: Any) {
        UIViewController.removeSpinner(spinner: self.spinnerView!)
        popupAlert(title: "Failed", message: error as! String, actionTitles: ["OK"], actions: [nil])
    }
}
