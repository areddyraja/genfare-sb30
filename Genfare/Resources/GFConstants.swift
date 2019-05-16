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
        static let Logout = "kLogoutNavNotification"
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
    struct Plist {
        static let STRINGS_PLIST = "Strings"
        static let COLORS_PLIST  = "Colors"
        static let TYPE_PLIST = "plist"
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
    struct Wallet{
        static let WALLET_STATUS_UNKNOWN = 1
        static let WALLET_STATUS_ACTIVE = 2
        static let WALLET_STATUS_LOST = 3
        static let WALLET_STATUS_STOLEN = 4
        static let WALLET_STATUS_DAMAGED = 5
        static let WALLET_STATUS_DEFECTIVE = 6
        static let WALLET_STATUS_EXPIRED = 7
        static let WALLET_STATUS_DISABLED = 8
        static let WALLET_STATUS_SUSPENDED = 9
        static let WALLET_STATUS_DEACTIVATED = 10
        static let WALLET_STATUS_PENDING_DEACTIVATION = 11
        static let WALLET_STATUS_PENDING_SUSPENSION = 12
        static let WALLET_STATUS_PENDING_ACTIVATION = 13
        static let WALLET_STATUS_INACTIVE = 14
        static let WALLET_STATUS_UNAVAILABLE = 15
        static let WALLET_STATUS_RESERVERD = 16
        static let WALLET_STATUS_BAD_LISTED = 17
        static let WALLET_STATUS_QUARANTINED = 18
        static let WALLET_FARECODE_STATUS_EXPIRED = 19
    }
    
    struct LocalStorage {
        static let RecentTrips = "UserRecentTrips"
        static let AccessToken = "common_key_access_token"
        static let AccountBalance = "user_account_balance"
    }
    
    struct KeyChain {
        static let UserName = "GF_USER_NAME"
        static let Password = "GF_USER_PASSWORD"
        static let SecretKey = "GF_SECRET_AUTH_KEY"
    }
    
    struct StoryBoard {
        static let CardBased = "GFCARDBASEDCONTROLLER"
        static let AccountBased = "GFACCOUNTBASEDCONTROLLER"
        static let Login = "GFNAVIGATETOLOGIN"
        static let SignUp = "GFREGISTRATION"
        static let ForgotPassword = "GFFORGOTPASSWORD"
        static let Settings = "GFNAVIGATEMENUSETTINGS"
        static let SelectWallet = "GFSELECTWALLET"
        static let CreateWallet = "CREATEWALLET"
        static let PayAsYouGoList = "PAYASYOUGOPASSES"
        static let MyPassesList = "MYPASSESLIST"
        static let MyHistoryList = "PASSACTIVITYLIST"
        static let PurchaseProducts = "GFPurchaseTicketListViewController"
        static let BarCode = "GFBARCODESCREEN"
        static let BarCodeInfo = "GFBARCODEINFO"
        static let BarCodeLanding = "GFBARCODELANDING"
        static let Contact = "GFContactViewController"
        static let AlertView = "GFCustomAlertViewController"
        static let ReplenishmentView  = "GFReplenishmentViewController"
    }
    
    struct Ticket {
        static let InActive = "pending_activation"
        static let Active = "active"
        static let ActiveRide = "active_ride"
        static let PeriodPass = "period_pass"
        static let ExpDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        static let DisplayDateFormat = "MM/dd/yy hh:mm aa"
    }
    
    struct WVCommands {
        static let NativeCommand = "coocoo://"
        static let TokenCommand = "setauthtoken"
        static let AlertCommand = "alert"
        static let TicketsCommand = "ticketshome"
        static let ForgotPasswordCommand = "forgotpassword"
        static let AlertTitle = "title"
        static let AlertMessage = "message"
        static let TokenTitle = "token"
        static let TokenEmail = "emailaddress"
    }
    
    struct Message {
        static let NoNetwork = "Notwork Not Available"
    }
}

//AIzaSyD20t9-cmgZ_zgDgJO3R4y-tehsscNnHkA

