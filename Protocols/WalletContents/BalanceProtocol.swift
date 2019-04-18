//
//  BalanceProtocol.swift
//  Genfare
//
//  Created by OmniTech on 17/04/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit

protocol BalanceProtocol {
    var walletcontents:WalletContents{set get}
    func updateBalance(walletcontents:WalletContents)
}
extension BalanceProtocol{
    func updateBalance(walletcontents:WalletContents){
        //Need to update user balance.
    }
}
