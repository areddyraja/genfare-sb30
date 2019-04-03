//
//  GFContactViewController.swift
//  Genfare
//
//  Created by omniwyse on 29/03/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GFContactViewController: GFBaseViewController {
    
    let viewModel = ContactViewModel()
    let disposeBag = DisposeBag()
    
    @IBOutlet var vistTheWebsiteProperty: GFMenuButton!
    @IBOutlet var commentsProperty: GFMenuButton!
    @IBOutlet var callNumberProperty: GFMenuButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.updateUI()
        createViewModelBinding()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor.formLabelText
        self.navigationItem.title = "Contact"
        navigationController?.setNavigationBarHidden(false, animated: false);
        navigationController?.navigationBar.barTintColor = UIColor.buttonBGBlue
    }
    @IBAction func facebookBtnClkd(_ sender: Any) {
        
        if UIApplication.shared.canOpenURL(NSURL(string: "fb://") as! URL ) {
            if let url = URL(string: "https://www.facebook.com/cotabus"), !url.absoluteString.isEmpty {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        }
    }
    
    @IBAction func twitterButtonClicked(_ sender: UIButton) {
        if UIApplication.shared.canOpenURL(NSURL(string: "twitter://")! as URL ) {
            if let url = URL(string: "https://twitter.com/cotabus/"), !url.absoluteString.isEmpty {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        }
    }
    
    func callNum() {
        let alert = UIAlertController(title: "Call COTA?", message: "Call (518) 482-8822", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive, handler: { action in
            if let url = URL(string:"tel:6142281776"), !url.absoluteString.isEmpty {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                
            }
        }))
        
    }
    
    func createViewModelBinding(){
        vistTheWebsiteProperty.rx.tap.do(onNext:  { [unowned self] in
        }).subscribe(onNext: { [unowned self] in
           self.viewModel.openURL()
            }).disposed(by: disposeBag)
        
        callNumberProperty.rx.tap.do(onNext:  { [unowned self] in
        }).subscribe(onNext: { [unowned self] in
            self.callNum()
        }).disposed(by: disposeBag)
        commentsProperty.rx.tap.do(onNext:  { [unowned self] in
        }).subscribe(onNext: { [unowned self] in
            self.viewModel.eMail()
        }).disposed(by: disposeBag)
        
    }
    
    
    
  
    @IBAction func goToTerms(_ sender: Any) {
        let navController = UIStoryboard(name: "Contact", bundle: nil).instantiateViewController(withIdentifier: "GFTermsViewController") as? GFTermsViewController
        navigationController?.pushViewController(navController!, animated: true)
    }
    
    @IBAction func goToPrivacy(_ sender: Any) {
        let navController = UIStoryboard(name: "Contact", bundle: nil).instantiateViewController(withIdentifier: "GFPrivacyAndPolicyViewController") as? GFPrivacyAndPolicyViewController
        navigationController?.pushViewController(navController!, animated: true)
    }

}
