//
//  GFChangePasswordViewController.swift
//  Genfare
//
//  Created by omniwyse on 08/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GFChangePasswordViewController: GFBaseViewController {
    let viewModel = AccountSettingViewModel()
    let disposeBag = DisposeBag()
    var  changeAccountService:GFChangeAccountService?

    @IBOutlet var changePasswrdTxt: GFMenuButton!
    @IBOutlet var confirmPasserdTxt: UITextField!
    @IBOutlet var newPasswrdTxt: UITextField!
    @IBOutlet var currentPasswrdTxt: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        createViewModelBinding()
        createCallbacks()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear( _ animated:Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor.formLabelText
        navigationController?.setNavigationBarHidden(false, animated: false);
        navigationController?.navigationBar.barTintColor = UIColor.topNavBarColor
       self.navigationItem.title = "Change Password"
    }
        func createViewModelBinding(){
            
            currentPasswrdTxt.rx.text.orEmpty
                .bind(to: viewModel.passwordViewModel2.data)
                .disposed(by: disposeBag)
            
            newPasswrdTxt.rx.text.orEmpty
                .bind(to: viewModel.passwordViewModel3.data)
                .disposed(by: disposeBag)
            
            confirmPasserdTxt.rx.text.orEmpty
                .bind(to: viewModel.passwordViewModel.data)
                .disposed(by: disposeBag)
            
            changePasswrdTxt.rx.tap.do(onNext:  { [unowned self] in
                self.view.resignFirstResponder()
            }).subscribe(onNext: { [unowned self] in
                if self.viewModel.validateCredentialsForPassword() {
                     if let account:Account = GFDataService.currentAccount(){
                    self.viewModel.changePasswordForUser()
                    }
                }else{
                    self.showErrorMessage(message: self.viewModel.formErrorPasswordString())
                }
            }).disposed(by: disposeBag)
    }
    func createCallbacks(){
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
