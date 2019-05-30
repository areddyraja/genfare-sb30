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

class GFBarcodeScreenViewController: GFBaseViewController ,WalletContentsProtocol{
    
    let viewModel = GFBarcodeScreenViewModel()
    let disposeBag = DisposeBag()
    
    var countdownTimer: Timer!
    var remainingActiveTime:Int!
    var ticket:WalletContents!
    var baseClass:UIViewController?
     let date = NSDate()

    @IBOutlet var countDownLabel: UILabel!
    @IBOutlet weak var passTitleLabel: UILabel!
    @IBOutlet weak var expiresLabel: UILabel!
    
    @IBOutlet var tokenImg: UIImageView!
    @IBOutlet weak var activateBtn: GFMenuButton!
    @IBOutlet weak var qrCodeHolder: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        createViewModelBinding()
        createCallbacks()
//        viewModel.walletModel = ticket
//        updateUI(activated: viewModel.isActive())
        updateUI(activated: self.isActive(walletcontents:ticket))
        self.tokenImg.alpha = 0.5
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    @objc func appMovedToForeground() {
        if self.isActive(walletcontents:ticket) {
            countdownTimer.invalidate()
            updateBarCode()
        }
    }
    override func viewWillAppear( _ animated:Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false);
        navigationController?.navigationBar.barTintColor = UIColor.topNavBarColor
        view.backgroundColor = .white

        if self.isActive(walletcontents:ticket) {
            
            if(countdownTimer != nil){
                countdownTimer.invalidate()
            }
            updateBarCode()
        }
        // Do any additional setup after loading the view.
    }

    func createViewModelBinding(){
        if self.ticket.type != Constants.Ticket.PayAsYouGo {
            activateBtn.rx.tap.do(onNext:  { [unowned self] in
            }).subscribe(onNext: { [unowned self] in
                if NetworkManager.Reachability  {
                    GFWalletEventService.activateTicket(ticket: self.ticket)
                    self.viewBinding()

                }else{
            let maxAllowedUnSyncedOfflineActivations = UserDefaults.standard.integer(forKey: "maxAllowedUnSyncedOfflineActivations")
                 if(Utilities.eventRecordCount() < maxAllowedUnSyncedOfflineActivations ?? 3){
                GFWalletEventService.activateTicket(ticket: self.ticket)
                self.viewBinding()
                 }
                 else{
                    let alert = UIAlertController(title: "Activation", message:(String(format:Utilities.stringResourceForId(resourceId: "maxActivationAlertMessage")!)) , preferredStyle: UIAlertController.Style.alert)
                    
                    // add the actions (buttons)
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { [unowned self] action in
                    }))
                    
                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                    
                }
                }
                
            }).disposed(by: disposeBag)
        }else{
            var time = self.ticket.ticketActivationExpiryDate?.intValue
           
            let timestamp = Int64(date.timeIntervalSince1970)
           let barcodeWalletTime = time! - Int(timestamp)
            let barcodeTime = GFFetchProductsService.barcodeTimerFor(pid: ticket.ticketIdentifier!)
            if(barcodeWalletTime == Int(barcodeTime)){
                    viewBinding()
            }
        }
       
    }
    
    func viewBinding(){
        
        if self.viewModel.eventNeedUpdate() {
            GFWalletEventService.updateActivityFor(product: GFFetchProductsService.getProductFor(id: self.ticket.ticketIdentifier!)!,
                                                   wallet: self.ticket,
                                                   activity: "activation")
            let model : GFAccountLandingViewModel = GFAccountLandingViewModel()
            model.fireEvent()
        }
        
        self.updateBarCode()
        self.updateUI(activated: true)
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
        var qrCode = QRCode(self.barcodestring(walletcontents:ticket))
        qrCode?.size = qrCodeHolder.frame.size
        qrCodeHolder.image = qrCode?.image
        activateBtn.isHidden = true
        startTimer()
    }
    
    func startTimer() {
        let time = self.ticket.ticketActivationExpiryDate?.intValue
        let date = NSDate()
        let timestamp = Int64(date.timeIntervalSince1970)
        remainingActiveTime = time! - Int(timestamp)
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        UIView.transition(with:self.countDownLabel,
                          duration: 5.0,
                          options: [.autoreverse,.repeat],
                          animations: {
                            self.countDownLabel.transform = CGAffineTransform(translationX: (-1 * (self.view.frame.size.width / 2) + 20), y:0)
                            self.countDownLabel.transform = CGAffineTransform(translationX: ((self.view.frame.size.width / 2) - 20), y:0)
                            
        }, completion: nil)
        UIView.transition(with:self.tokenImg,
                          duration: 5.0,
                          options: [.autoreverse,.repeat],
                          animations: {
                            self.tokenImg.transform = CGAffineTransform(translationX: (-1 * (self.view.frame.size.width / 2) + 20), y:0)
                            self.tokenImg.transform = CGAffineTransform(translationX: ((self.view.frame.size.width / 2) - 20), y:0)
                            
        }, completion: nil)
        self.tokenImg.isHidden = false

        
    }
    
    @objc func updateTime() {
        countDownLabel.text = "\(timeFormatted(remainingActiveTime))"
        if remainingActiveTime != 0 && remainingActiveTime > 0 {
            remainingActiveTime -= 1
        } else {
            
            endTimer()
        }
    }
    func endTimer() {
        countdownTimer.invalidate()
         baseClass!.navigationController?.popViewController(animated: true)
        
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        let hours: Int = totalSeconds / 3600
        if (hours > 0){
            return String(format: "%02lld:%02d:%02d",hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
