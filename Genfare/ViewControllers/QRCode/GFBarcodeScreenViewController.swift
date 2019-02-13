//
//  GFBarcodeScreenViewController.swift
//  Genfare
//
//  Created by vishnu on 11/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import QRCode

class GFBarcodeScreenViewController: GFBaseViewController {

    let viewModel = GFBarcodeScreenViewModel()
    let disposeBag = DisposeBag()
    
    var ticket:WalletContents!
    var baseClass:UIViewController?

    @IBOutlet weak var passTitleLabel: UILabel!
    @IBOutlet weak var expiresLabel: UILabel!
    
    @IBOutlet weak var activateBtn: GFMenuButton!
    @IBOutlet weak var qrCodeHolder: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        createViewModelBinding()
        createCallbacks()
        updateUI(activated: false)
    }
    
    override func viewWillAppear( _ animated:Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false);
        navigationController?.navigationBar.barTintColor = UIColor.buttonBGBlue
        view.backgroundColor = .white

        // Do any additional setup after loading the view.
    }

    func createViewModelBinding(){
        activateBtn.rx.tap.do(onNext:  { [unowned self] in
        }).subscribe(onNext: { [unowned self] in
            self.updateBarCode()
        }).disposed(by: disposeBag)
    }
    
    func createCallbacks (){
        // success
        viewModel.isSuccess.asObservable()
            .bind{ [unowned self] value in
                NSLog("Successfull \(value)")
                if value{
                    self.popupAlert(title: "Success", message: "Successful...!!!", actionTitles: ["OK"], actions: [nil])
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
    
    func updateUI(activated:Bool) {
        passTitleLabel.text = ticket.descriptation
        if activated {
            activateBtn.isHidden = true
            if let expDate = ticket.expirationDate, ticket.type == Constants.Ticket.PeriodPass {
                expiresLabel.text = "Expires \(Utilities.convertDate(dateStr: expDate, fromFormat: Constants.Ticket.ExpDateFormat, toFormat: Constants.Ticket.DisplayDateFormat))"
            }
        }else{
            expiresLabel.text = ""
        }
    }
    
    func updateBarCode() {
        viewModel.walletModel = ticket
        var qrCode = QRCode(viewModel.barcodeString())
        qrCode?.size = qrCodeHolder.frame.size
        qrCodeHolder.image = qrCode?.image
        activateBtn.isHidden = true
        updateUI(activated: true)
    }

}
