//
//  GenfConstants.swift
//  Genfare
//
//  Created by omniwzse on 22/08/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import Foundation

struct Constants {
    
    struct APIKeys {
        static let GoogleMaps = "AIzaSyD20t9-cmgZ_zgDgJO3R4y-tehsscNnHkA"
    }
    
    struct NotificationKey {
        static let Welcome = "kWelcomeNotif"
        static let HomeScreen = "kHomeScreenNavNotification"
        static let PlanTrip = "kPlanTripScreenNavNotification"
        static let PassPurchase = "kPassPurchaseScreenNavNotification"
        static let Settings = "kSettingsScreenNavNotification"
        static let Login = "kLoginScreenNavNotification"
    }
    
    struct SideMenuAction {
        static let HomeScreen = "kHomeScreenNavigation"
        static let PlanTrip = "kPlanTripScreenNavigation"
        static let PassPurchase = "kPassPurchaseScreenNavigation"
        static let Settings = "kSettingsScreenNavigation"
        static let Login = "kLoginScreenNavigation"
        static let Alerts = "kAlertsScreenNavigation"
        static let ContactUs = "kContactusScreenNavigation"
    }

    struct Path {
        static let KeychainService = "com.genfare.mobile.service.keychain"
    }
    
    struct Address {
        static let Home = "1500 Polaris Pkwy, Columbus, OH 43240"
        static let Work = "SmartPhone Software 1900 Polaris Pkwy, Columbus, OH 43240"
        static let School = "2560 London Groveport Rd, Groveport, OH 43125"
    }
    
    struct TransitMode {
        static let Walk = "WALK"
        static let Bus = "BUS"
        static let WalkBus = "WALK,BUS"
        static let Uber = "UBER"
        static let WalkTrain = "WALK,TRAIN"
    }
    
    struct NetService {
        static let METHOD_GET = 0
        static let METHOD_GET_JSON = 1
        static let METHOD_POST = 2
        static let METHOD_PATCH = 3
        static let METHOD_PUT = 4
        static let METHOD_DELETE = 5
        static let METHOD_SIMPLE = 6
        static let METHOD_SIMPLE_JSON = 7
        static let METHOD_SIMPLE_POST = 8
        static let METHOD_SIMPLE_POST_SECURE = 9
        
        static let SERVICE_DATE_FORMAT = "yyyy-MM-dd"
        static let SERVICE_TIME_FORMAT = "HH:mm:00"
    }
    
    struct LocalStorage {
        static let RecentTrips = "UserRecentTrips"
        static let accessToken = "common_key_access_token"
    }
    
    struct KeyChain {
        static let UserName = "GF_USER_NAME"
        static let Password = "GF_USER_PASSWORD"
        static let SecretKey = "GF_SECRET_AUTH_KEY"
    }
    
    struct StoryBoard {
        static let CardBased = "GFCARDBASEDCONTROLLER"
        static let AccountBased = "GFACCOUNTBASEDCONTROLLER"
        static let CreateWallet = "CREATEWALLET"
        static let Login = "GFNAVIGATETOLOGIN"
        static let SignUp = "GFREGISTRATION"
        static let ForgotPassword = "GFFORGOTPASSWORD"
    }
}

//AIzaSyD20t9-cmgZ_zgDgJO3R4y-tehsscNnHkA

