//
//  GFAccountInfoViewController.swift
//  Genfare
//
//  Created by vishnu on 06/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GFAccountInfoViewController: GFBaseViewController {

    let viewModel = GFAccountInfoViewModel()
    let disposeBag = DisposeBag()

    @IBOutlet weak var transferBtn: GFMenuButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        createViewModelBinding()
        createCallbacks()
    }
    
    override func viewWillAppear( _ animated:Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .gray
        navigationController?.setNavigationBarHidden(false, animated: false);
        navigationController?.navigationBar.barTintColor = UIColor.buttonBGBlue

        // Do any additional setup after loading the view.
    }
    
    func createViewModelBinding(){
        
        transferBtn.rx.tap.do(onNext:  { [unowned self] in
            print(self)
        }).subscribe(onNext: { [unowned self] in
            self.viewModel.transferCard()
        }).disposed(by: disposeBag)
    }

    func createCallbacks (){
        // success
        viewModel.isSuccess.asObservable()
            .bind{ [unowned self] value in
                NSLog("Successfull \(value)")
                if value{
                    self.popupAlert(title: "Success", message: "Card Released", actionTitles: ["OK"], actions: [nil])
                    //self.dismiss(animated: true, completion: nil)
                }
            }.disposed(by: disposeBag)
        
        // Loading
        viewModel.isLoading.asObservable()
            .bind{[unowned self] value in
                if value {
                    self.attachSpinner(value: value)
                }
            }.disposed(by: disposeBag)
        
        // errors
        viewModel.errorMsg.asObservable()
            .bind {[unowned self] errorMessage in
                // Show error
                self.showErrorMessage(message: errorMessage)
            }.disposed(by: disposeBag)
        
        // Logout
        viewModel.logoutUser.asObservable()
            .bind{[unowned self] value in
                if value {
                    self.logoutUser()
                }
            }.disposed(by: disposeBag)
    }
}

//extension GFAccountInfoViewController : UITableViewDelegate {
//
//}
//
//extension GFAccountInfoViewController : UITableViewDataSource {
//
//}
