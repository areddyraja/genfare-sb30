//
//  GFBarcodeScreenViewModel.swift
//  Genfare
//
//  Created by vishnu on 11/02/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation

class GFBarcodeScreenViewModel:GFBaseViewModel {
    var walletModel:WalletContents!
    func eventNeedUpdate() -> Bool {
        return true
    }
}
