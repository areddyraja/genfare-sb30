//
//  GFSignupViewController.swift
//  Genfare
//
//  Created by omniwzse on 04/10/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GFSignupViewController: GFBaseViewController, SignUpServiceDelegate {

    let viewModel = SignUpViewModel()
    let disposeBag = DisposeBag()
    var signUpService:GFSignUpService?
    
    @IBOutlet weak var firstNameTxt: GFWhiteButtonTextField!
    @IBOutlet weak var lastNameTxt: GFWhiteButtonTextField!
    @IBOutlet weak var passwordTxt1: GFWhiteButtonTextField!
    @IBOutlet weak var passwordTxt2: GFWhiteButtonTextField!
    @IBOutlet weak var emailTxt: GFWhiteButtonTextField!
    @IBOutlet weak var signUpBtn: GFMenuButton!
    
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
        
        firstNameTxt.rx.text.orEmpty
            .bind(to: viewModel.firstNameViewModel.data)
            .disposed(by: disposeBag)
        
        lastNameTxt.rx.text.orEmpty
            .bind(to: viewModel.lastNameViewModel.data)
            .disposed(by: disposeBag)
        
        passwordTxt1.rx.text.orEmpty
            .bind(to: viewModel.passwordViewModel.data)
            .disposed(by: disposeBag)

        passwordTxt2.rx.text.orEmpty
            .bind(to: viewModel.passwordViewModel2.data)
            .disposed(by: disposeBag)

        emailTxt.rx.text.orEmpty
            .bind(to: viewModel.emailIdViewModel.data)
            .disposed(by: disposeBag)
        
        signUpBtn.rx.tap.do(onNext:  { [unowned self] in
            self.view.resignFirstResponder()
        }).subscribe(onNext: { [unowned self] in
            if self.viewModel.validateCredentials() {
                self.spinnerView = UIViewController.displaySpinner(onView: self.view)
                self.signUpService = GFSignUpService(email: self.emailTxt.text!, password: self.passwordTxt1.text!, firstname: self.firstNameTxt.text!, lastname: self.lastNameTxt.text!)
                self.signUpService?.delegate = self
                self.signUpService?.registerUser()
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
    
    func didRegisterSuccessfully() {
        UIViewController.removeSpinner(spinner: spinnerView!)
        popupAlert(title: "Success", message: "Registration Successful...!!!", actionTitles: ["OK"], actions: [nil])
    }
    
    func didFailRegistration(_ error: Any) {
        UIViewController.removeSpinner(spinner: spinnerView!)
        popupAlert(title: "Error", message: error as! String, actionTitles: ["OK"], actions: [nil])
    }

}
