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
                    //self.popupAlert(title: "Success", message: "Login Successful...!!!", actionTitles: ["OK"], actions: [nil])
                    self.dismiss(animated: true, completion: nil)
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

        // Walletcreation
        viewModel.walletNeeded.asObservable()
            .bind{ [unowned self] value in
                if value {
                    if let controller = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: Constants.StoryBoard.CreateWallet) as? GFCreatWalletViewController {
                        self.navigationController?.viewControllers = [controller]
                    }
                }
            }.disposed(by: disposeBag)
        
        // Walletselection
        viewModel.showWalletList.asObservable()
            .bind{ [unowned self] value in
                if let list = value as? Array<Any>, list.count > 0 {
                    NSLog("Need to select Wallet \(value)")
                    if let controller = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: Constants.StoryBoard.SelectWallet) as? GFWalletSelectionViewController {
                        controller.walletList = list
                        self.navigationController?.viewControllers = [controller]
                    }
                }
            }.disposed(by: disposeBag)
        
        // Walletsretrieve
        viewModel.showRetrieveWallet.asObservable()
            .bind{ [unowned self] value in
                if value {
                    self.showRetrieveWalletAlert()
                }
            }.disposed(by: disposeBag)
        
        // Logout User
        viewModel.logoutUser.asObservable()
            .bind{ [unowned self] value in
                if value {
                    self.logoutUser()
                }
            }.disposed(by: disposeBag)
    }
    
    func showRetrieveWalletAlert() {
        let alert = UIAlertController(title: "Retrieve Wallet", message: "Do you want to retreive wallet?", preferredStyle: UIAlertController.Style.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { [unowned self] action in
            
            self.viewModel.walletRetrieved(value: false)

        }))
        alert.addAction(UIAlertAction(title: "Retreive", style: UIAlertAction.Style.destructive, handler: { [unowned self] action in
            
            self.viewModel.walletRetrieved(value: true)
            
        }))
        
        // show the alert
        present(alert, animated: true, completion: nil)
        
    }

}
