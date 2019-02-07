//
//  GFPurchaseWebViewController.swift
//  Genfare
//
//  Created by omniwyse on 06/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit
import WebKit

class GFPurchaseWebViewController: GFBaseViewController,WKNavigationDelegate{
    
    var weburl:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let paymentWebview = WKWebView()
        paymentWebview.frame  = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.view.addSubview(paymentWebview)
        
        
        let token:String = KeychainWrapper.standard.string(forKey: Constants.KeyChain.SecretKey)!
        let url =  self.weburl
        var request = URLRequest(url: URL.init(string: url!)!)
        request.setValue(String(format: "bearer %@", token), forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(Utilities.appCurrentVersion(), forHTTPHeaderField: "app_version")
        request.setValue("iOS", forHTTPHeaderField: "app_os")
        request.setValue(Utilities.deviceId(), forHTTPHeaderField: "DeviceId")
        paymentWebview.load(request)
        //        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //        paymentWebview.delegate = self
        // Do any additional setup after loading the view.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: WKWebview Delegate Methods
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void){
        
        let request = navigationAction.request
        let urlString = request.url?.absoluteString
        guard let finalWeburl = weburl else{
            return
        }
        if (finalWeburl != urlString && !(urlString?.contains("checkout"))!) && !(urlString?.contains("coocoo://"))!{
            
        }
        if (urlString?.hasPrefix("coocoo://"))!{
            
        }else if((urlString?.contains("finished"))!){
            //Need to
        }else if((urlString?.contains("Thank"))!){
            navigationController?.popToRootViewController(animated: true)
            
        }
        
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!){
        
        let urlString = webView.url?.absoluteString
        if (urlString?.contains("purchase/proxy_form"))!{
            //Do progress dialog
            self.attachSpinner(value: true)
            
        }
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error){
        self.attachSpinner(value: false)
    }
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!){
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
        self.attachSpinner(value: false)
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
