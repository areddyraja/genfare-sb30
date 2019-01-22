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
                self.viewModel.loginUser{result,error in
                    if(error != nil){
                        self.popupAlert(title: "Failed", message: error as! String, actionTitles: ["OK"], actions: [nil])
                    }else{
                        self.popupAlert(title: "Success", message: "Login Successful...!!!", actionTitles: ["OK"], actions: [nil])
                    }
                }
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
