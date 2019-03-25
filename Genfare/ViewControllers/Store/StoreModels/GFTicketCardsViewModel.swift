//
//  GFTicketCardsViewModel.swift
//  Genfare
//
//  Created by omniwyse on 18/03/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Foundation
import RxSwift

class GFTicketCardsViewModel{
    
    let disposebag = DisposeBag()
    var model:Array<Any> = []
    
    let isSuccess : Variable<Bool> = Variable(false)
    let isLoading : Variable<Bool> = Variable(false)
    let errorMsg   : Variable<String> = Variable("")
    
    func formErrorString() -> String
    {
        return ""
    }
    
    func fetchListOfCards() {
        isLoading.value = true
        let cardList = GFListOfCardsService()
        cardList.GetlistOfCards { [unowned self] (result, error) in
             self.isLoading.value = false
             if error == nil {
                self.model = self.getList(list: result as! Array)
                self.isSuccess.value = true
            }
            else{
             print("error")

            }
            
        }
    }
    func getList(list:Array<Any>) -> Array<Any>{
        return list
    }

}


