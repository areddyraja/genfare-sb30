//
//  GFPurchaseWebViewController.swift
//  Genfare
//
//  Created by omniwyse on 06/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit

class GFPurchaseWebViewController: UIViewController,UIWebViewDelegate {

    @IBOutlet var paymentWebview: UIWebView!
    var weburl:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.paymentWebview.loadRequest(URLRequest.init(url: URL(string:weburl)!))
        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
     //   appDelegate.showloader()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
     //   appDelegate.hideloader()
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
