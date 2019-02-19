//
//  GFPayGoPassTableViewController.swift
//  Genfare
//
//  Created by vishnu on 01/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GFPayGoPassTableViewController: UITableViewController {

    let viewModel = GFPayGoPassViewModel()
    let disposeBag = DisposeBag()
    var spinnerView:UIView?
    var selectedIndex:Int = 0
    var baseClass:UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false
        createCallbacks()
        createViewModelBinding()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.showProducts()
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
                NSLog("Loading \(value)")
                //self.attachSpinner(value: value)
                if value {
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
                    //self.popupAlert(title: "ERROR", message: errorMessage, actionTitles: ["OK"], actions: [nil])
                    print(errorMessage)
                }
            }.disposed(by: disposeBag)
        
        viewModel.barCode.asObservable()
            .bind{[unowned self] value in
                NSLog("Loading \(value)")
                if value {
                    self.showBarcodeScreen()
                }
            }.disposed(by: disposeBag)
    }
    
    func createViewModelBinding(){
        
    }
    
    func showBarcodeScreen() {
        if let controller:GFBarcodeLandingViewController = UIStoryboard(name: "Barcode", bundle: nil).instantiateViewController(withIdentifier: Constants.StoryBoard.BarCodeLanding) as? GFBarcodeLandingViewController {
            //controller.ticket = ticket
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

        if let product:Product = viewModel.model[indexPath.row] as Product {
            cell.titleLabel.text = product.productDescription
            cell.subTitleLabel.text = product.ticketTypeDescription
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        selectedIndex = indexPath.row
        showCofirmAlert()
    }

    func showCofirmAlert() -> Void {
        // create the alert
        let alert = UIAlertController(title: "Activate Pass", message: "Are you sure you want to Activate this pass?", preferredStyle: UIAlertController.Style.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive, handler: { action in
            
            self.viewModel.confirmActivation(index: self.selectedIndex)
            
        }))
        
        present(alert, animated: true, completion: nil)
    }

}
