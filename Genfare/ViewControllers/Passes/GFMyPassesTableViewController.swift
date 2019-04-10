//
//  GFMyPassesTableViewController.swift
//  Genfare
//
//  Created by vishnu on 04/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GFMyPassesTableViewController: UITableViewController {

    let viewModel = GFMyPassesViewModel()
    let disposeBag = DisposeBag()
    var spinnerView:UIView?
    var baseClass:UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = false
        createCallbacks()
        createViewModelBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let pagemenu = self.parent as? CAPSPageMenu{
            print(pagemenu.didTapMenuItemToScroll)
        }
        viewModel.showProducts()
        refreshWalletContents()
    }
    
    func refreshWalletContents() {
        viewModel.fetchWalletContents()
    }
    
    func createCallbacks (){
        // success
        viewModel.isSuccess.asObservable()
            .bind{ [unowned self] value in
                NSLog("Successfull \(value)")
                if value{
                    self.tableView.reloadData()
                }
            }.disposed(by: disposeBag)
        
        // Loading
        viewModel.isLoading.asObservable()
            .bind{[unowned self] value in
                self.spinnerView?.removeFromSuperview()
                if value && (self.view.frame.origin.y != 0.0) {
                    self.spinnerView = UIViewController.displaySpinner(onView: self.view)
                }else{
                    if let _ = self.spinnerView {
                        UIViewController.removeSpinner(spinner: self.spinnerView!)
                    }
                }
            }.disposed(by: disposeBag)
        
        // errors
        viewModel.errorMsg.asObservable()
            .bind {[unowned self] errorMessage in
                // Show error
                if errorMessage != ""{
                    print(errorMessage)
                }
            }.disposed(by: disposeBag)
    }
    
    func createViewModelBinding(){
        
    }
    
    func showBarCodeScreen(ticket:WalletContents) {
        if let controller:GFBarcodeLandingViewController = UIStoryboard(name: "Barcode", bundle: nil).instantiateViewController(withIdentifier: Constants.StoryBoard.BarCodeLanding) as? GFBarcodeLandingViewController {
            controller.ticket = ticket
            baseClass!.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return viewModel.model.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PAYGOCELL", for: indexPath) as! PayAsYouGoCell
        
        cell.activeBtn.isHidden = true
        cell.inactiveBtn.isHidden = true
        cell.activeRideBtn.isHidden = true

        if let wc:WalletContents = viewModel.model[indexPath.row] as WalletContents {
            cell.titleLabel.text = wc.descriptation
            //cell.subTitleLabel.text = wc.type
            
            if wc.status == Constants.Ticket.InActive {
                cell.inactiveBtn.isHidden = false
            }else{
                cell.activeBtn.isHidden = false
            }
            
            if let expDate = wc.expirationDate, wc.type == Constants.Ticket.PeriodPass {
                cell.subTitleLabel.text = "Expires \(Utilities.convertDate(dateStr: expDate, fromFormat: Constants.Ticket.ExpDateFormat, toFormat: Constants.Ticket.DisplayDateFormat))"
            }else{
                cell.subTitleLabel.text = ""
            }
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        //Handle selection
        let ticket = viewModel.model[indexPath.row] as WalletContents
        if ticket.allowInteraction == 1 {
            showBarCodeScreen(ticket: ticket)
        }else{
            print("Can not activate ticket")
        }
        tableView.reloadData()
    }

}
