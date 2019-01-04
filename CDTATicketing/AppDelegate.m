//
//  AppDelegate.m
//  CDTATicketing
//
//  Created by CooCooTech on 6/17/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "AppDelegate.h"
#import  "CooCooBase.h"
#import <GoogleMaps/GoogleMaps.h>
#import "HomeViewController.h"
#import "SplashScreenViewController.h"
#import "CDTAUtilities.h"
#import "Event.h"
#import "GetWalletContentUsage.h"
#import "GetWalletContentUsagePayAsYouGo.h"
#import "Singleton.h"
#import "iRide-Swift.h"

@class GFHomeScreenViewController;

@implementation AppDelegate
{

    Event *event;
    NSDateFormatter *df;
}
@synthesize navigationController;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel   = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:@"_UIConstraintBasedLayoutLogUnsatisfiable"];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:-1] forKey:@"CAPPED_THRESHOLD"];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:-1]  forKey:@"BONUS_THRESHOLD"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [CrashlyticsKit setDelegate:self];
    [Fabric with:@[[Crashlytics class]]];
    
    [[Fabric sharedSDK] setDebug: YES];
    
    [Utilities clearKeychainOnTheFirstRun];
    
    [self logUser];
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isReachable:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // Override point for customization after application launch.
    [self.window setBackgroundColor:[UIColor whiteColor]];
    [self.window makeKeyAndVisible];
    
    [self customizeAppearance];
    [NSTimer scheduledTimerWithTimeInterval:300.0
                                     target:[NSBlockOperation blockOperationWithBlock:^{ [self isReachable:nil]; }]
                                   selector:@selector(main)
                                   userInfo:nil
                                    repeats:YES
     ];
    
    
    NSString *access_token=[[NSUserDefaults standardUserDefaults] objectForKey:COMMON_KEY_ACCESS_TOKEN];
    if(access_token.length==0){
        [[NSUserDefaults standardUserDefaults] setObject:[CDTAUtilities schedulesKey] forKey:COMMON_KEY_ACCESS_TOKEN];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
    [GMSServices provideAPIKey:[Utilities stringInfoForId:@"google_api_key"]];
    
    // [GMSServices provideAPIKey:@"{AIzaSyB_fgdJUbz25b0ys9W9mDj8HBhR17QvQYA}"];
    
    
    [[Singleton sharedManager] setManagedContext:self.managedObjectContext];

    
    SplashScreenViewController *splashView = [[SplashScreenViewController alloc] initWithNibName:@"SplashScreenViewController" bundle:[NSBundle mainBundle]];
    [splashView setManagedObjectContext:self.managedObjectContext];



//    HomeViewController *homeView = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:[NSBundle mainBundle]];
//    [homeView setManagedObjectContext:self.managedObjectContext];
//
//    self.navigationController = [[UINavigationController alloc] initWithRootViewController:homeView];

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GFMapsHomeViewController *controller = [sb instantiateViewControllerWithIdentifier:@"GFNAVIGATEMENUHOME"];
    controller.managedObjectContext = self.managedObjectContext;

    self.navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    [splashView setNavController:self.navigationController];
    
    [self.window setRootViewController:splashView];

    return YES;
}

-(void)openMailComposerWithData:(CLSReport *)crashReport
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        NSArray *receipients = [[NSArray alloc]initWithObjects:@"shravankumar.damera@spx.com",nil];
        [controller setToRecipients:receipients];
        [controller setSubject:@"crash"];
        [controller setMessageBody:crashReport.customKeys isHTML:NO];
        if (controller) {
            [self.window.rootViewController presentViewController:controller animated:YES completion: ^{
            }];
        }
    }
    else {
        NSLog(@"Device cannot email crash report");
    }
}

- (BOOL)isReachable:(id)sender
{
    Reachability *reachability = [Reachability reachabilityWithHostName:@"google.com"];
    if ([reachability currentReachabilityStatus] != NotReachable) {
        
        NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:Event_Model];
        NSError *error = nil;
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"clickedTime" ascending:YES];
        [request setSortDescriptors:[[NSArray alloc] initWithObjects:sortDescriptor, nil]];
        NSArray *fetchedObjects1 = [self.managedObjectContext executeFetchRequest:request error:&error];
        NSLog(@"%@",fetchedObjects1);
        NSMutableArray *EventsTemp = [[NSMutableArray alloc] init];
        for (Event *event in fetchedObjects1) {
            
            [EventsTemp addObject:event];
        }
        if(EventsTemp>0){
            NSMutableDictionary *dict =[[NSMutableDictionary alloc]init];
            
            
            for (Event *tevent in EventsTemp) {
                if([tevent.identifier isEqualToString:@"no"]&&[tevent.type isEqualToString:@"passes"]){
                    NSMutableArray *productsListArray = [[NSMutableArray alloc]init];
                    
                    [dict setObject:tevent.clickedTime forKey:@"chargeDate"];
                    NSString *identifier =  tevent.walletContentUsageIdentifier;
                    [productsListArray addObject:dict];
                    
                    GetWalletContentUsage *GetWalletContentusage  = [[GetWalletContentUsage alloc] initWithListener:self managedObjectContext:self.managedObjectContext withArray:productsListArray walletContentUsageIdentifier:identifier];
                    [GetWalletContentusage execute];
                    
                }
                
                else if([tevent.identifier isEqualToString:@"no"]&&[tevent.type isEqualToString:@"payasyougo"]){
                    NSMutableArray *productsListArray = [[NSMutableArray alloc]init];
                    [dict setObject: tevent.amountRemaining forKey:@"amountRemaining"];
                    [dict setObject:tevent.clickedTime forKey:@"chargeDate"];
                    [dict setObject:tevent.fare forKey:@"amountCharged"];
                    [dict setObject:tevent.ticketid?tevent.ticketid:@"" forKey:@"ticketIdentifier"];
                    [productsListArray addObject:dict];
                    NSString *identifier =  tevent.walletContentUsageIdentifier;
                    
                    GetWalletContentUsagePayAsYouGo *getWalletContentUsagePayAsYouGo  = [[GetWalletContentUsagePayAsYouGo alloc] initWithListener:self managedObjectContext:self.managedObjectContext withArray:productsListArray walletContentUsageIdentifier:identifier];
                    [getWalletContentUsagePayAsYouGo execute];
                    
                    
                }
            }
            
        }
        else
        {
            
            NSLog(@"helo");
            
        }
    }
    return YES;
}
- (void)threadSuccessWithClass:(id)service response:(id)response{
    if([service isMemberOfClass:[GetWalletContentUsage class]]) {
        
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSManagedObjectContext *context = [self managedObjectContext];
        
        [request setEntity:[NSEntityDescription entityForName:Event_Model inManagedObjectContext:context]];
        NSError *error = nil;
        NSArray *results = [context executeFetchRequest:request error:&error];
        //                if(results.count>0)
        //                {
        //                    Event *passes = results.firstObject;
        //                     [self.managedObjectContext deleteObject:passes];
        //                }
        for (Event *tempEvent in results) {
            [self.managedObjectContext deleteObject:tempEvent];
        }
        
        [self.managedObjectContext save:nil];
    }
    else if ([service isMemberOfClass:[GetWalletContentUsagePayAsYouGo class]]) {
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSManagedObjectContext *context = [self managedObjectContext];
        
        [request setEntity:[NSEntityDescription entityForName:Event_Model inManagedObjectContext:context]];
        NSError *error = nil;
        NSArray *results = [context executeFetchRequest:request error:&error];
    
        for (Event *tempEvent in results) {
            [self.managedObjectContext deleteObject:tempEvent];
        }
        
        [self.managedObjectContext save:nil];
        
        
    }
}
- (void)threadErrorWithClass:(id)service response:(id)response
{
    
    
}
- (void) logUser {
    // TODO: Use the current user's information
    // You can call any combination of these three methods
    [CrashlyticsKit setUserIdentifier:@"12345"];
    [CrashlyticsKit setUserEmail:@"shravankumar.damera@spx.com"];
    [CrashlyticsKit setUserName:@"Shravan"];
}


- (void)customizeAppearance
{
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
            UIImage *navBgImg=[[UIImage imageNamed:[NSString stringWithFormat:@"%@NavBarBG",[[Utilities tenantId] lowercaseString]]]
                               resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0) resizingMode:UIImageResizingModeStretch];
            [[UINavigationBar appearance] setBackgroundImage:navBgImg forBarMetrics:UIBarMetricsDefault];
            [[UINavigationBar appearanceWhenContainedIn:[HelpSliderView class], nil] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
            [[UINavigationBar appearanceWhenContainedIn:[HelpSliderView class], nil] setBarTintColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:@"redBrownColor"]]];
            [[UINavigationBar appearanceWhenContainedIn:[HelpSliderView class], nil] setTranslucent:NO];
        } else {
            [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:@"actionbar_bg"]]];
        }
        
//        UIColor *linkColor = [UIColor colorWithHexString:[Utilities colorHexStringFromId:@"navBGColor"]];
//        UIColor *linkColor = [UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities linkTextColor]]];
        UIColor *linkColor = [UIColor colorWithHexString:[Utilities colorHexStringFromId:[Utilities linkTextColor]]];

        //        UIColor *linkColor = [UIColor colorWithRed:154.0/255.0
        //                                             green:198.0/255.0
        //                                              blue:214.0/255.0
        //                                             alpha:1.0];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              [UIColor whiteColor],
                                                              NSForegroundColorAttributeName,
                                                              nil]];
        
        //        [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
        //                                                              linkColor,
        //                                                              NSForegroundColorAttributeName,
        //                                                              nil]
        //                                                    forState:UIControlStateNormal];
        
        [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:linkColor}
                                                       forState:UIControlStateNormal];
        [[UISegmentedControl appearance] setTintColor:linkColor];
        
        [[UIStepper appearance] setTintColor:linkColor];
        
        [[BorderedButton appearance] setTitleColor:linkColor forState:UIControlStateNormal];
    } else {
        [[UINavigationBar appearance] setTintColor:[UIColor colorWithHexString:[Utilities colorHexStringFromId:@"actionbar_bg"]]];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    if(!hexString)
        return nil;
    
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSMutableArray *allManagedObjectModels = [[NSMutableArray alloc] init];
    
    NSURL *projectModelURL = [[NSBundle mainBundle] URLForResource:@"CDTATicketing" withExtension:@"momd"];
    NSManagedObjectModel *projectManagedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:projectModelURL];
    
    [allManagedObjectModels addObject:projectManagedObjectModel];
    
    NSURL *libraryModelUrl = [[NSBundle mainBundle] URLForResource:@"CooCooBaseResources"
                                                     withExtension:@"momd"];
    NSManagedObjectModel *libraryManagedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:libraryModelUrl];
    
    [allManagedObjectModels addObject:libraryManagedObjectModel];
    
    _managedObjectModel = [NSManagedObjectModel modelByMergingModels:allManagedObjectModels];
    
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CDTATicketing.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //abort();
        
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        NSLog(@"Deleted old database");
        
        /*
         * If CoreData information needs to be deleted, StoredData should be deleted as well
         */
        [StoredData removeUserData];
        [StoredData removeTicketsQueue];
        
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            NSLog(@"2nd unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
