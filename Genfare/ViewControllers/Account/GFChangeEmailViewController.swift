//
//  GFChangeEmailViewController.swift
//  Genfare
//
//  Created by omniwyse on 08/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GFChangeEmailViewController: GFBaseViewController {
    
    var viewModel = AccountSettingViewModel()
    let disposeBag = DisposeBag()
    var  changeAccountService:GFChangeAccountService?

    @IBOutlet var emailTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet var changeEmailPressed:GFMenuButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    createViewModelBinding()
        createCallbacks()
        // Do any additional setup after loading the view.
    }
    
    func createViewModelBinding(){
        
        emailTxt.rx.text.orEmpty
            .bind(to: viewModel.emailIdViewModel.data)
            .disposed(by: disposeBag)
        
        passwordTxt.rx.text.orEmpty
            .bind(to: viewModel.passwordViewModel.data)
            .disposed(by: disposeBag)
        
        changeEmailPressed.rx.tap.do(onNext:  { [unowned self] in
            self.view.resignFirstResponder()
        }).subscribe(onNext: { [unowned self] in
            if self.viewModel.validateCredentials() {
                if let account:Account = GFDataService.currentAccount(){
                self.viewModel.changeUser()
                }
            }else{
                self.showErrorMessage(message: self.viewModel.formErrorString())
            }
        }).disposed(by: disposeBag)
    }
        
        func createCallbacks (){
            // success
            viewModel.isSuccess.asObservable()
                .bind{ value in
                   
                    if value {
                     print("sucess")
                    }
                }.disposed(by: disposeBag)
            
            // Loading
            viewModel.isLoading.asObservable()
                .bind{[unowned self] value in
                    self.attachSpinner(value: value)
                }.disposed(by: disposeBag)
            
            // errors
            viewModel.errorMsg.asObservable()
                .bind {[unowned self] errorMessage in
                    // Show error
                    self.showErrorMessage(message: errorMessage)
                }.disposed(by: disposeBag)
            
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


