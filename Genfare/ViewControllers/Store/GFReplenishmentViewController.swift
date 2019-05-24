//
//  GFReplenishmentViewController.swift
//  Genfare
//
//  Created by omniwyse on 08/05/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class GFReplenishmentViewController: UIViewController {
    let viewModel = GFReplenishmentViewModel()
    let disposeBag = DisposeBag()
    
    

 
    @IBOutlet weak var qrImgView: UIImageView!
    @IBOutlet weak var closeBtn: GFMenuButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Replenishment Barcode"
        self.setNavBarColor(navColor: UIColor.white)
        qrImgView.backgroundColor = UIColor.lightGray

        // Do any additional setup after loading the view.
        viewModel.setupIntialValues()
    
    }
    
    func setNavBarColor(navColor:UIColor){
        self.navigationController?.navigationBar.tintColor = navColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: navColor]
    }
    @IBAction func closeBtnClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
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
