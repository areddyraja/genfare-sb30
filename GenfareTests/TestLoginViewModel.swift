//
//  TestLoginViewModel.swift
//  GenfareTests
//
//  Created by vishnu on 12/03/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import Quick
import Nimble


@testable import Pods_Genfare

class LoginViewModelSpec: QuickSpec {
    var successValue = true
    override func spec() {
        
        
        describe("TestViewController") {
            var subject: GFSignupViewController!
            beforeEach {
//                subject = UIStoryboard(name: "Main", bundle:
//                    nil).instantiateViewController(withIdentifier:
//                        "GFSignupViewController") as! GFSignupViewController
//                _ = subject.view
            }
            context("when the view loaded") {
                it("should have the right label with the correct text") {
                    let signUpService:GFSignUpService = GFSignUpService(email:"sdfghdefrghyjxcvb",
                                                                        password: "12345678",
                                                                        firstname: "tt",
                                                                        lastname:"ttt")
            
                    signUpService.registerUser(completionHandler: {(success, error) in
                        self.successValue = success
                       
                    })
                    expect(self.successValue).toNot(equal(true))
                }
            }
        }
        
//
//        describe("the 'Documentation' directory") {
//            it("has everything you need to get started") {
//
//            }
//
//            context("if it doesn't have what you're looking for") {
//                it("needs to be updated") {
//
//                }
//            }
//        }
    }
}
