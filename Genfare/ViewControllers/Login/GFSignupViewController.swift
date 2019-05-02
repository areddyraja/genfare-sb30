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

class GFSignupViewController: GFBaseViewController {

    let viewModel = SignUpViewModel()
    let disposeBag = DisposeBag()
    var signUpService:GFSignUpService?
    
    @IBOutlet weak var firstNameTxt: GFWhiteButtonTextField!
    @IBOutlet weak var lastNameTxt: GFWhiteButtonTextField!
    @IBOutlet weak var passwordTxt1: GFWhiteButtonTextField!
    @IBOutlet weak var passwordTxt2: GFWhiteButtonTextField!
    @IBOutlet weak var emailTxt: GFWhiteButtonTextField!
    @IBOutlet weak var signUpBtn: GFMenuButton!
    @IBOutlet var imgUser: UIImageView!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        createViewModelBinding()
        createCallbacks()
        self.imgUser.image =  UIImage(named: "\(Utilities.tenantId().lowercased())LogoBig")
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyStylesAndColors()
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
                self.viewModel.signupUser()
            }else{
                self.showErrorMessage(message: self.viewModel.formErrorString())
            }
        }).disposed(by: disposeBag)
    }
    
    func createCallbacks (){
        // success
        viewModel.isSuccess.asObservable()
            .bind{ value in
                //Present create wallet controller
                if value {
                    if let controller = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: Constants.StoryBoard.CreateWallet) as? GFCreatWalletViewController {
                        self.navigationController?.viewControllers = [controller]
                    }
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
    func applyStylesAndColors(){
        firstNameTxt.textColor = UIColor(hexString:Utilities.colorHexString(fromId:"BigButtonBGColor" )!)
        lastNameTxt.textColor = UIColor.red
        self.signUpBtn.backgroundColor = UIColor(hexString:Utilities.colorHexString(fromId:"BigButtonBGColor" )!)
    }
}
