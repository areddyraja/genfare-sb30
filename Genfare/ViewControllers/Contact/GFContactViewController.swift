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
    @IBOutlet var twitterImage: UIImageView!
    @IBOutlet var facebookImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        addGestures()
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

    func updateUI(){
        vistTheWebsiteProperty.backgroundColor = UIColor(hexString:"#459EAC")
        callNumberProperty.backgroundColor = UIColor(hexString:"#459EAC")
        commentsProperty.backgroundColor = UIColor(hexString:"#459EAC")
    }
    func addGestures(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(twitterimageTapped(tapGestureRecognizer:)))
        twitterImage.isUserInteractionEnabled = true
        twitterImage.addGestureRecognizer(tapGestureRecognizer)
        
        let fbtapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(facebookimageTapped(fbtapGestureRecognizer:)))
        facebookImage.isUserInteractionEnabled = true
        facebookImage.addGestureRecognizer(fbtapGestureRecognizer)

    }
    
    func createViewModelBinding(){
        vistTheWebsiteProperty.rx.tap.do(onNext:  { [unowned self] in
        }).subscribe(onNext: { [unowned self] in
           self.openURL()
            }).disposed(by: disposeBag)
        
        callNumberProperty.rx.tap.do(onNext:  { [unowned self] in
        }).subscribe(onNext: { [unowned self] in
            self.callNum()
        }).disposed(by: disposeBag)
        commentsProperty.rx.tap.do(onNext:  { [unowned self] in
        }).subscribe(onNext: { [unowned self] in
            self.eMail()
        }).disposed(by: disposeBag)
        
    }
    
    func openURL() {
        if let url = URL(string: "http://www.cota.com"), !url.absoluteString.isEmpty {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
        
        present(alert, animated: true, completion: nil)
    }
    
     func eMail(){
        if let url = URL(string:"mailto:Requests@cota.com"), !url.absoluteString.isEmpty{
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc func twitterimageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        
        if UIApplication.shared.canOpenURL(NSURL(string: "twitter://")! as URL ) {
            if let url = URL(string: "https://twitter.com/cotabus/"), !url.absoluteString.isEmpty {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        }
        
    }
    @objc func facebookimageTapped(fbtapGestureRecognizer: UITapGestureRecognizer)
    {
        
        if UIApplication.shared.canOpenURL(NSURL(string: "fb://") as! URL ) {
            if let url = URL(string: "https://www.facebook.com/cotabus"), !url.absoluteString.isEmpty {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        }
        
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
