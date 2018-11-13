//
//  AppDelegate.m
//  wPinpinbox
//
//  Created by Angus on 2015/8/6.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import "wTools.h"
#import "boxAPI.h"
#import "TaobanViewController.h"
#import "CustomIOSAlertView.h"
#import "VersionUpdate.h"
#import "TWMessageBarManager.h"
#import "ViewController.h"
#import "MyTabBarController.h"
#import "AlbumDetailViewController.h"
#import "BuyPPointViewController.h"
#import "AlbumCollectionViewController.h"
#import "AlbumCreationViewController.h"
#import "CreaterViewController.h"
#import "HomeTabViewController.h"
#import "CategoryViewController.h"

#import "ContentCheckingViewController.h"

#import "ExchangeInfoEditViewController.h"

#import <SafariServices/SafariServices.h>

#import "UIColor+Extensions.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <Flurry.h>

#import <GoogleAnalytics/GAI.h>
#import <GoogleAnalytics/GAIDictionaryBuilder.h>

#import "GlobalVars.h"
#import "UIViewController+ErrorAlert.h"

#define kPlzOpenLocSys @"請開啟定位:設置 > 隱私 > 位置 > 定位服務。"
#define kTipTitle @"提示"

// define macro
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)


@interface AppDelegate ()
@property (nonatomic, strong) NSURL *launchedURL;
@property (nonatomic) BOOL isInBackground;
@property (nonatomic, assign) CGRect currentStatusBarFrame;
@property (nonatomic, strong) NSMutableDictionary *launchNotification;

//- (id)initWithStyleSheet:(NSObject<TWMessageBarStyleSheet> *)stylesheet;

@end

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

//- (void)initApp {
//    NSLog(@"User ID: %@", [wTools getUserID]);
//    NSLog(@"User Token: %@", [wTools getUserToken]);
//
//    NSString *userId = [wTools getUserID];
//    NSString *userToken = [wTools getUserToken];
//
//    BOOL authenticatedUser = false;
//
//    if ([userId isEqualToString: @""] && [userToken isEqualToString: @""]) {
//        NSLog(@"userId & userToken is equal to empty");
//        authenticatedUser = false;
//    }
//    if (![userId isEqualToString: @""] && ![userToken isEqualToString: @""]) {
//        NSLog(@"userId & userToken is not equal to empty");
//        authenticatedUser = true;
//    }
//
//    NSLog(@"authenticatedUser: %d", authenticatedUser);
//
//    if (authenticatedUser) {
//        NSLog(@"is authenticatedUser");
//        //self.window.rootViewController = [[UIStoryboard storyboardWithName: @"Main" bundle: [NSBundle mainBundle]] instantiateInitialViewController];
//
//        MyTabBarController *myTabC = [[UIStoryboard storyboardWithName: @"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"MyTabBarController"];
//        [self.myNav pushViewController: myTabC animated: YES];
//    } else {
//        NSLog(@"is not authenticatedUser");
//        ViewController *rootController = [[UIStoryboard storyboardWithName: @"Main" bundle: [NSBundle mainBundle]] instantiateViewControllerWithIdentifier: @"ViewController"];
//        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController: rootController];
//        self.window.rootViewController = navigation;
//    }
//}

- (void)checkBadge {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"badgeCount: %d", [[defaults objectForKey: @"badgeCount"] intValue]);
    
    if ([[defaults objectForKey: @"badgeCount"] intValue] > 0) {
        for (UIViewController *vc in self.myNav.viewControllers) {
            NSLog(@"vc: %@", vc);
            if ([vc isKindOfClass: [MyTabBarController class]]) {
                MyTabBarController *myTabBarC = (MyTabBarController *)vc;
                [[myTabBarC.viewControllers objectAtIndex: kNotifTabIndex] tabBarItem].badgeValue = @"N";
            }
        }
    }
}

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"didFinishLaunchingWithOptions");
    NSLog(@"launchOptions: %@", launchOptions);
    
    [Fabric with:@[[Crashlytics class]]];
    [wTools setStatusBarBackgroundColor: [UIColor whiteColor]];    
    
    [Flurry startSession:@"GSPHT8B4KV8F89VHQ6D8"
      withSessionBuilder:[[[FlurrySessionBuilder new]
                           withCrashReporting:YES]
                          withLogLevel:FlurryLogLevelDebug]];        

    if (launchOptions != nil ) {
        NSDictionary *remoteN = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        NSLog(@"remoteN %@",remoteN);
        
        if (remoteN) {
            @try {
                NSMutableDictionary *nr = [NSMutableDictionary dictionaryWithDictionary:remoteN];
                [nr  removeObjectsForKeys:[remoteN allKeysForObject:[NSNull null]]];
                
                if ([nr allKeys].count > 0) {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject: nr forKey: @"launchNotification"];
                    [defaults synchronize];
                }
            } @catch (NSException *exception) {
                NSString *ex = [exception description];
                NSLog(@"\n\n\n didFinishLaunchingWithOptions fail  %@\n\n\n", ex);
            } @finally {
                
            }
        }
    }
//    if (launchOptions != nil ) {
//        NSDictionary *remoteN = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
//        NSLog(@"remoteN %@",remoteN);
//
//        if (remoteN) {
//            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//            [defaults setObject: remoteN forKey: @"launchNotification"];
////            [defaults synchronize];
//        }
//    }
    
#pragma mark  Google Analytics setup
    GAI *gai = [GAI sharedInstance];
    [gai trackerWithTrackingId:@"UA-58524918-1"];
    gai.trackUncaughtExceptions = YES;
    gai.logger.logLevel = kGAILogLevelVerbose;
    
#if(DEBUG)
    gai.dryRun = YES;
#endif
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    
    FlurrySessionBuilder* builder = [[[[[FlurrySessionBuilder new]
                                        withLogLevel:FlurryLogLevelAll]
                                       withCrashReporting:YES]
                                      withSessionContinueSeconds:10]
                                     withAppVersion: version];
    
    [builder withShowErrorInLog: YES];
    
    //[Flurry startSession: w3FlurryAPIKey withSessionBuilder:builder];
    [Flurry startSession: wwwFlurryAPIKey withSessionBuilder: builder];
    
//    VersionUpdate *vu = [[VersionUpdate alloc] initWithFrame: self.window.bounds];
//    [vu checkVersion];
    
    // Collect Log
    /*
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName =[NSString stringWithFormat:@"%@.log",[NSDate date]];
    NSString *logFilePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
    */
    
    //[self initApp];
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment: UIOffsetMake(-60, -60) forBarMetrics: UIBarMetricsDefault];            
    
    // Status Bar Setting
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f) {
        NSLog(@"System Version is >= 7.0f");
        
        /*
        UIView *view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 20)];
        view.backgroundColor = [UIColor colorWithRed: 32.0/255.0 green: 191.0/255.0 blue: 193.0/255.0 alpha: 1.0];
        [self.window.rootViewController.view addSubview: view];
         */
    }
    
    self.isInBackground = NO;
    
    //[[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"en", nil] forKey:@"AppleLanguages"];
    
    // Override point for customization after application launch.
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    
    if ([userPrefs objectForKey:@"id"]) {
        if ([userPrefs isKindOfClass:[NSNumber class]]) {
            [userPrefs setObject:[[userPrefs objectForKey:@"id"] stringValue] forKey:@"id"];
            [userPrefs synchronize];
        }
    }        
    
    /*
    CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
    //判斷3.5吋或4吋螢幕以載入不同storyboard
    if (iOSDeviceScreenSize.height == 480) {
        UIStoryboard *iPhone35Storyboard = [UIStoryboard storyboardWithName:@"Main35" bundle:nil];
        UIViewController *initialViewController = [iPhone35Storyboard instantiateInitialViewController];
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.rootViewController  = initialViewController;
        [self.window makeKeyAndVisible];
    }
     */
    
    NSLog(@"launchOptions: %@", launchOptions);
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsURLKey] != nil) {
        NSURL *url =(NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
        //[self application:application handleOpenURL:url];
        [application openURL:url options:@{} completionHandler:nil];
    }
    
    // Check APNS Information
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isReminded = [[defaults objectForKey: @"isReminded"] boolValue];
    NSLog(@"isReminded: %d", isReminded);
    
    // Check Date for increasing viewing number
    NSDate *oldDate = [defaults objectForKey: @"dateRecord"];
    
    if (oldDate == nil) {
        NSLog(@"");
        NSLog(@"oldDate == nil");
        
        NSLog(@"[NSDate date]: %@", [NSDate date]);
        
        [defaults setObject: [NSDate date] forKey: @"dateRecord"];
        [defaults synchronize];
    } else {
        NSLog(@"");
        NSLog(@"oldDate != nil");
        
        NSDate *currentDate = [NSDate date];
        NSLog(@"currentDate: %@", currentDate);
        
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorianCalendar components: NSCalendarUnitDay
                                                            fromDate: oldDate
                                                              toDate: currentDate
                                                             options: 0];
        NSLog(@"components day: %ld", (long)[components day]);
        
        if ([components day] >= 1) {
            [defaults setObject: currentDate forKey: @"dateRecord"];
            NSArray *array = [defaults objectForKey: @"albumIdArray"];
            NSMutableArray *albumIdArray = [NSMutableArray arrayWithArray: array];
            
            [albumIdArray removeAllObjects];
            NSLog(@"albumIdArray: %@", albumIdArray);
            [defaults setObject: albumIdArray forKey: @"albumIdArray"];
            [defaults synchronize];
        }
    }
    
    //if ([wTools isRegisterAWSNeeded]) {
    #if __IPHONE_10_0
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted)
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
        }];
        UNNotificationAction *a = [UNNotificationAction actionWithIdentifier:UNNotificationDefaultActionIdentifier title:@"pinpinBox" options:UNNotificationActionOptionForeground];
        UNNotificationCategory *c = [UNNotificationCategory categoryWithIdentifier:@"GENERAL" actions:@[a] intentIdentifiers:@[UNNotificationDefaultActionIdentifier] options:UNNotificationCategoryOptionCustomDismissAction];
        [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithObject:c]];
    
    #else
        UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:setting];
    #endif
    //}
    
    NSInteger badgeCount = [[defaults objectForKey: @"badgeCount"] integerValue];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: badgeCount];
    
    NSLog(@"APNSArray: %@", [defaults objectForKey: @"APNSArray"]);
    
    
    
    return YES;
}

- (void)logUser {
    // TODO: Use the current user's information
    // You can call any combination of these three methods
    [CrashlyticsKit setUserIdentifier:@"12345"];
    [CrashlyticsKit setUserEmail:@"user@fabric.io"];
    [CrashlyticsKit setUserName:@"Test User"];
}

#pragma mark - Location Method
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    NSLog(@"didUpdateLocations");
    
    CLLocation *c =[locations objectAtIndex:0];
    NSLog(@"%f,%f",c.coordinate.latitude,c.coordinate.longitude);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [location stopUpdatingLocation ];

    _coordinate=[NSString stringWithFormat:@"%f,%f",c.coordinate.latitude,c.coordinate.longitude];
}

#pragma mark -

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"applicationWillResignActive");
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    self.isInBackground = YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"applicationDidEnterBackground");
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    self.isInBackground = YES;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger badgeCount = [[defaults objectForKey: @"badgeCount"] integerValue];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: badgeCount];
    
    NSLog(@"APNSArray: %@", [defaults objectForKey: @"APNSArray"]);
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"applicationWillEnterForeground");
    

    [self checkBadge];
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    self.isInBackground = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"AppDelegate");
    NSLog(@"applicationDidBecomeActive");
    
    [FBSDKAppEvents activateApp];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    if (self.isInBackground) {
        // The method below can open the app through urlScheme while in the background
        // But this method will disable the function opening the app while not in the background
        //[self checkUrlScheme];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"applicationWillTerminate");
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    self.isInBackground = NO;
    
    BOOL isReminded = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: [NSNumber numberWithBool: isReminded] forKey: @"isReminded"];
    [defaults synchronize];
    
    // Save changes in the application's managed object context before the application terminates
    [self saveContext];
}

- (void)saveContext {
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
#if __IPHONE_10_0
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
#else
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
#endif
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
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DataModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MyStore.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options: @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error]) {
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
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - Backgrounding Methods -
- (void)application:(UIApplication *)application
handleEventsForBackgroundURLSession:(NSString *)identifier
  completionHandler:(void (^)(void))completionHandler
{
    NSLog(@"handleEventsForBackgroundURLSession");
    
    self.backgroundSessionCompletionHandler = completionHandler;
}
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    NSString *source = [options objectForKey:UIApplicationOpenURLOptionsSourceApplicationKey];
    if (source) {
        id annotation = [options objectForKey:UIApplicationOpenURLOptionsAnnotationKey];
        return [self processOpenURL:app url:url sourceApplication:source annotation:annotation];
    }
    
    BOOL returnValue = NO;
    NSString *urlString = [url absoluteString];
    
    if ([urlString hasPrefix: @"pinpinbox://"]) {
        returnValue = YES;
    }
    
    return returnValue;
}
#ifndef __IPHONE_10_0
- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url
{
    NSLog(@"handleOpenURL");
    
    BOOL returnValue = NO;
    NSString *urlString = [url absoluteString];
    
    if ([urlString hasPrefix: @"pinpinbox://"]) {
        returnValue = YES;
    }
    
//    homeViewController *hVC = [[homeViewController alloc] init];
//    hVC.urlString = url.absoluteString;
    
    return returnValue;
}

// When other apps open pinpinbox app, the method below will be called
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    return [self processOpenURL:application url:url sourceApplication:sourceApplication annotation:annotation];
}
#endif
- (BOOL)processOpenURL:(UIApplication *)application
                   url:(NSURL *)url
     sourceApplication:(NSString *)sourceApplication
            annotation:(id)annotation {
    NSLog(@"");
    NSLog(@"");
    NSLog(@"openURL sourceApplication");
    [self handleRouting: url];
    
    NSLog(@"Calling Application Bundle ID: %@", sourceApplication);
    NSLog(@"URL received: %@", url);
    NSLog(@"URL scheme: %@", [url scheme]);
    NSLog(@"URL query: %@", [url query]);
    NSLog(@"URL host: %@", [url host]);
    NSLog(@"URL path: %@", [url path]);
    
    if ([[url path] isEqualToString: @"/profile"]) {
        //[_menu memberbtn: nil];
        for (UIViewController *vc in self.myNav.viewControllers) {
            NSLog(@"vc: %@", vc);
            if ([vc isKindOfClass: [MyTabBarController class]]) {
                MyTabBarController *myTabBarC = (MyTabBarController *)vc;
                [myTabBarC toMeTab];
            }
        }
    }
    
    if ([[url path] isEqualToString: @"/create"]) {
        //[_menu showSetupview: nil];
        //[_menu FastBtn];
        for (UIViewController *vc in self.myNav.viewControllers) {
            NSLog(@"vc: %@", vc);
            if ([vc isKindOfClass: [MyTabBarController class]]) {
                MyTabBarController *myTabBarC = (MyTabBarController *)vc;
                [myTabBarC centerBtnPress];
            }
        }
    }
    
    if ([[url path] isEqualToString: @"/index"]) {
        NSLog(@"url path isEqualToString /index");
        for (UIViewController *vc in self.myNav.viewControllers) {
            NSLog(@"vc: %@", vc);
            if ([vc isKindOfClass: [MyTabBarController class]]) {
                MyTabBarController *myTabBarC = (MyTabBarController *)vc;
                [myTabBarC toHomeTab];
            }
        }
    }
    
    if ([[url path] isEqualToString: @"/album/content"]) {
        NSLog(@"url path isEqualToString /album/content");
        if ([url query] != nil) {
            NSString *query = [url query];
            NSArray *bits = [query componentsSeparatedByString: @"="];
            NSLog(@"bits: %@", bits);
            
            NSString *key = bits[0];
            NSString *value = bits[1];
            NSLog(@"key: %@", key);
            NSLog(@"value: %@", value);
        }
    }
    
    if ([[url path] isEqualToString: @"/diy/content"]) {
        NSLog(@"url path is equal to /diy/content");
        
        if ([url query] != nil) {
            NSString *query = [url query];
            NSArray *queryPairs = [query componentsSeparatedByString: @"&"];
            NSMutableDictionary *pairs = [NSMutableDictionary dictionary];
            
            NSLog(@"queryPairs: %@", queryPairs);
            
            for (NSString *queryPair in queryPairs) {
                NSArray *bits = [queryPair componentsSeparatedByString: @"="];
                
                NSLog(@"bits: %@", bits);
                
                if ([bits count] != 2) {
                    continue;
                }
                
//                NSString *key = [[bits objectAtIndex: 0] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
//                NSString *value = [[bits objectAtIndex: 1] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
                NSString *key = [[bits objectAtIndex:0] stringByRemovingPercentEncoding];
                NSString *value = [[bits objectAtIndex:1] stringByRemovingPercentEncoding];
                
                NSLog(@"key: %@", key);
                NSLog(@"value: %@", value);
                [pairs setObject: value forKey: key];
            }
            
            if (pairs[@"identity"] != nil) {
                NSLog(@"identity is not nil");
                
                if ([pairs[@"identity"] isEqualToString: @"admin"]) {
                    NSLog(@"identity is admin");
                    
                    if (pairs[@"album_id"] != nil) {
                        NSLog(@"album_id is not nil");
                        
                        if (pairs[@"template_id"] != nil) {
                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            [defaults setObject: @"diyContent" forKey: @"urlScheme"];
                            [defaults setObject: pairs[@"template_id"] forKey: @"templateIdScheme"];
                            [defaults setObject: pairs[@"album_id"] forKey: @"albumIdScheme"];
                            
                            BOOL diyContentOn = YES;
                            [defaults setObject: [NSNumber numberWithBool: diyContentOn] forKey: @"diyContentOn"];
                            
                            [defaults synchronize];
                            
                            [self retrieveAlbum: pairs[@"album_id"]];
                            
                            /*
                            FastViewController *fvc=[[UIStoryboard storyboardWithName:@"Fast" bundle:nil] instantiateViewControllerWithIdentifier:@"FastViewController"];
                            fvc.selectrow=[wTools userbook];
                            fvc.albumid = pairs[@"album_id"];
                            fvc.templateid = pairs[@"template_id"];
                            
                            if ([pairs[@"template_id"] isEqualToString:@"0"]) {
                                fvc.booktype = 0;
                                fvc.choice = @"Fast";
                            } else {
                                fvc.booktype = 1000;
                                fvc.choice = @"Template";
                            }
                            
                            [self.myNav pushViewController:fvc animated:YES];
                             */
                        }
                    }
                }
            }
        }
    }
    else if ([[url path] isEqualToString: @"/user/albumcontent"]) {
        NSLog(@"url path isEqualToString user album content");
        
        if ([url query] != nil) {
            NSString *query = [url query];
            NSArray *queryPairs = [query componentsSeparatedByString: @"&"];
            NSMutableDictionary *pairs = [NSMutableDictionary dictionary];
            
            NSLog(@"queryPairs: %@", queryPairs);
            
            for (NSString *queryPair in queryPairs) {
                NSArray *bits = [queryPair componentsSeparatedByString: @"="];
                
                NSLog(@"bits: %@", bits);
                
                if ([bits count] != 2) {
                    continue;
                }
                
//                NSString *key = [[bits objectAtIndex: 0] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
//                NSString *value = [[bits objectAtIndex: 1] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
                NSString *key = [[bits objectAtIndex:0] stringByRemovingPercentEncoding];
                NSString *value = [[bits objectAtIndex:1] stringByRemovingPercentEncoding];
                
                NSLog(@"key: %@", key);
                NSLog(@"value: %@", value);
                [pairs setObject: value forKey: key];
            }
            
            if (pairs[@"album_id"] != nil) {
                NSLog(@"album_id is not nil");
                
                if (pairs[@"template_id"] != nil) {
                    NSLog(@"");
                    NSLog(@"FastViewController");
                    
//                    FastViewController *fvc=[[UIStoryboard storyboardWithName:@"Fast" bundle:nil] instantiateViewControllerWithIdentifier:@"FastViewController"];
//                    fvc.selectrow=[wTools userbook];
//                    fvc.albumid = pairs[@"album_id"];
//                    fvc.templateid = pairs[@"template_id"];
//                    
//                    if ([pairs[@"template_id"] isEqualToString:@"0"]) {
//                        fvc.booktype = 0;
//                        fvc.choice = @"Fast";
//                    } else {
//                        fvc.booktype = 1000;
//                        fvc.choice = @"Template";
//                    }
//                    
//                    [self.myNav pushViewController:fvc animated:YES];
                }
            }
        }
    }
    
    else if ([url query] != nil) {
        NSLog(@"url path is not equal to /diy/content");
        
        NSString *query = [url query];
        NSArray *queryPairs = [query componentsSeparatedByString: @"&"];
        NSMutableDictionary *pairs = [NSMutableDictionary dictionary];
        
        NSLog(@"queryPairs: %@", queryPairs);
        
        for (NSString *queryPair in queryPairs) {
            NSArray *bits = [queryPair componentsSeparatedByString: @"="];
            
            NSLog(@"bits: %@", bits);
            
            if ([bits count] != 2) {
                continue;
            }
            
            //NSString *key = [[bits objectAtIndex: 0] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
            NSString *key = [[bits objectAtIndex:0] stringByRemovingPercentEncoding];
            //NSString *value = [[bits objectAtIndex: 1] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
            NSString *value = [[bits objectAtIndex:1] stringByRemovingPercentEncoding];
            NSLog(@"key: %@", key);
            NSLog(@"value: %@", value);
            [pairs setObject: value forKey: key];
        }
        
        NSLog(@"pairs: %@", pairs);
        
        NSString *businessUserId = [NSString stringWithFormat: @"%d", (int)[pairs[@"businessuser_id"] integerValue]];
        NSLog(@"businessUserId: %@", businessUserId);
        
        if (businessUserId != nil) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//            [defaults setObject: businessUserId forKey: @"businessUserId"];
//            [defaults synchronize];
            
            NSLog(@"id: %@", [defaults objectForKey: @"id"]);
            NSLog(@"token: %@", [defaults objectForKey: @"token"]);
            
            if ([defaults objectForKey:@"id"] && [defaults objectForKey:@"token"]) {
                NSLog(@"id & token exists");
            } else {
                NSLog(@"id & token does not exist");
                
                for (UIViewController *controller in self.myNav.viewControllers) {
                    if ([controller isKindOfClass: [ViewController class]]) {
                        ViewController *vc = (ViewController *)controller;
                        [vc setTimerForUrlScheme: businessUserId];
                    }
                }
            }
        }
        
        NSLog(@"pairs album_id: %@", pairs[@"album_id"]);
        
        if (pairs[@"album_id"] != nil) {
            NSLog(@"album_id is not nil");
            //[wTools ToRetrievealbumpViewControlleralbumid: pairs[@"album_id"]];
            AlbumDetailViewController *aDVC = [[UIStoryboard storyboardWithName: @"AlbumDetailVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumDetailViewController"];
            aDVC.albumId = pairs[@"album_id"];            
            
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate.myNav pushViewController: aDVC animated: NO];
        }
        if (pairs[@"user_id"] != nil) {
            NSLog(@"user_id is not nil");
            //[wTools showCreativeViewuserid: pairs[@"user_id"] isfollow: YES];
            //[wTools showCreativeViewuserid: typeId isfollow: YES];
            CreaterViewController *cVC = [[UIStoryboard storyboardWithName: @"CreaterVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CreaterViewController"];
            cVC.userId = pairs[@"user_id"];
            
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate.myNav pushViewController: cVC animated: YES];
        }
        if (pairs[@"template_id"] != nil) {
            NSLog(@"template_id is not nil");
            
            //UIStoryboard *storyboard = [UIStoryboard storyboardWithName: @"Main" bundle: nil];
            //UINavigationController *navController = [storyboard instantiateInitialViewController];
            /*
            TaobanViewController *tv=[[TaobanViewController alloc]initWithNibName:@"TaobanViewController" bundle:nil];
            tv.temolateid = pairs[@"template_id"];
            
            //[navController pushViewController: tv animated: YES];
            [self.myNav pushViewController: tv animated: YES];
             */
        }
        if (pairs[@"event_id"] != nil) {
            NSLog(@"event_id is not nil");
            HomeTabViewController *hTVC = [[HomeTabViewController alloc] init];
            [hTVC getEventData: pairs[@"event_id"]];
        }
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation
            ];
}
//#endif

#pragma  mark - APNS
#if __IPHONE_10_0
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive) {
        completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound);
    } else {
        completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound);
    }
    
}
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    
    NSDictionary *userinfo = response.notification.request.content.userInfo;
    //  Notification data received //
    if (userinfo) {
        
                [self application:[UIApplication sharedApplication]
     didReceiveRemoteNotification:userinfo
           fetchCompletionHandler:^(UIBackgroundFetchResult result) {}];
    }
    completionHandler();
}
#else
-(void)application:(UIApplication *)application
didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    NSLog(@"didRegisterUserNotificationSettings");
    [application registerForRemoteNotifications];
}
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"didReceiveRemoteNotification");
    [self application: application didReceiveRemoteNotification: userInfo fetchCompletionHandler:^(UIBackgroundFetchResult result) {
    }];
}
#endif
-(void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken");
    NSLog(@"DeviceToken %@", [deviceToken description]);
    
    NSString *deviceId = [[deviceToken description]
                          substringWithRange:NSMakeRange(1, [[deviceToken description] length]-2)];
    deviceId = [deviceId stringByReplacingOccurrencesOfString:@" " withString:@""];
    deviceId = [deviceId stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSLog(@"deviceId: %@", deviceId);
    
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    [userPrefs setObject:deviceId forKey:@"APNSID"];
    [userPrefs synchronize];
    
    NSLog(@"APNSID: %@", [userPrefs objectForKey: @"APNSID"]);
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo0
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:userInfo0];

    NSLog(@"didReceiveRemoteNotification fetchCompletionHandler");
    NSLog(@"接收到訊息: %@", [userInfo description]);

    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *remote = (NSDictionary *)[defaults  objectForKey: @"launchNotification"];
    BOOL launchedByNotification = (remote != nil);
    
    // iOS 10 will handle notifications through other methods
    
    NSLog(@"data: %@", userInfo[@"data"]);
    
    NSDictionary *alertDic = userInfo[@"aps"][@"alert"];
    NSLog(@"alertDic: %@", alertDic);
    
    //application.applicationIconBadgeNumber = 0;
    UIApplicationState state = [application applicationState];

    NSInteger badgeCount = [[defaults objectForKey: @"badgeCount"] integerValue];
    
    // Check Info
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject: [NSDate date] forKey: @"CurrentTime"];
    [dic setObject: @"Got APNS" forKey: @"APNSInfo"];
    [dic setObject: [userInfo description] forKey: @"userInfo"];
    
    [array addObject: dic];
    [defaults setObject: array forKey: @"APNSArray"];
    
    
    NSLog(@"Before");
    NSLog(@"badgeCount: %ld", (long)badgeCount);
    
    badgeCount += 1;
    
    NSLog(@"After");
    NSLog(@"badgeCount: %ld", (long)badgeCount);
    
    [defaults setObject: [NSNumber numberWithInteger: badgeCount] forKey: @"badgeCount"];
    [defaults synchronize];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: badgeCount];
    
    NSString *dataType = userInfo[@"data"][@"type"];
    NSLog(@"dataType: %@", dataType);
    
    // typeId
    NSInteger typeIdInt;
    NSString *typeIdStr;
    
    //    if ([userInfo[@"data"][@"type_id"] isEqual: [NSNull null]]) {
    //        typeId = userInfo[@"data"][@"type_id"];
    //    } else {
    //        typeId = [userInfo[@"data"][@"type_id"] stringValue];
    //    }
    
    if (![userInfo[@"data"][@"type_id"] isEqual: [NSNull null]]) {
        typeIdInt = [userInfo[@"data"][@"type_id"] integerValue];
        typeIdStr = [NSString stringWithFormat: @"%ld", (long)typeIdInt];
    }
    
    NSLog(@"typeIdStr: %@", typeIdStr);
    
    // urlStr
    NSString *urlStr = userInfo[@"data"][@"url"];
    NSLog(@"urlStr: %@", urlStr);
    
    if (urlStr == nil) {
        NSLog(@"urlStr == nil");
    }
    if ([urlStr isEqual: [NSNull null]]) {
        NSLog(@"urlStr isEqual to nsnull");
    }
    
    for (UIViewController *vc in self.myNav.viewControllers) {
        NSLog(@"vc: %@", vc);
        if ([vc isKindOfClass: [MyTabBarController class]]) {
            MyTabBarController *myTabBarC = (MyTabBarController *)vc;
            [[myTabBarC.viewControllers objectAtIndex: kNotifTabIndex] tabBarItem].badgeValue = @"N";
        }
    }
    //if (state == UIApplicationStateBackground || state == UIApplicationStateInactive) {
    if (state == UIApplicationStateInactive || launchedByNotification) {
        NSLog(@"state == UIApplicationStateInactive");
        // user has tapped notification
        
        if ([dataType isEqual: [NSNull null]]) {
            NSLog(@"dataType is Null");
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [self popToMyTabBarVC: appDelegate];
            [self checkVCAndPresentSafariVC: appDelegate urlStr: urlStr];
        } else {
            if ([dataType isEqualToString: @"user"]) {
                NSLog(@"[dataType isEqualToString: user");
                CreaterViewController *cVC = [[UIStoryboard storyboardWithName: @"CreaterVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CreaterViewController"];
                cVC.userId = typeIdStr;
                
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [self popToMyTabBarVC: appDelegate];
                [appDelegate.myNav pushViewController: cVC animated: YES];
            }
            if ([dataType isEqualToString: @"albumqueue"]) {
                NSLog(@"dataType isEqualToString: albumqueue");
                AlbumDetailViewController *aDVC = [[UIStoryboard storyboardWithName: @"AlbumDetailVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumDetailViewController"];
                NSLog(@"typeIdStr: %@", typeIdStr);
                aDVC.albumId = typeIdStr;
                
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [self popToMyTabBarVC: appDelegate];
                [appDelegate.myNav pushViewController: aDVC animated: NO];
            }
            if ([dataType isEqualToString: @"albumqueue@messageboard"]) {
                NSLog(@"dataType isEqualToString: albumqueue@messageboard");
                AlbumDetailViewController *aDVC = [[UIStoryboard storyboardWithName: @"AlbumDetailVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumDetailViewController"];
                aDVC.albumId = typeIdStr;
                aDVC.getMessagePush = YES;
                
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [self popToMyTabBarVC: appDelegate];
                [appDelegate.myNav pushViewController: aDVC animated: NO];
            }
            if ([dataType isEqualToString: @"user@messageboard"]) {
                NSLog(@"dataType isEqualToString: user@messageboard");
                CreaterViewController *cVC = [[UIStoryboard storyboardWithName: @"CreaterVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CreaterViewController"];
                cVC.userId = typeIdStr;
                
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [self popToMyTabBarVC: appDelegate];
                [appDelegate.myNav pushViewController: cVC animated: YES];
            }
            if ([dataType isEqualToString: @"event"]) {
                NSLog(@"dataType isEqualToString: event");
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [self popToMyTabBarVC: appDelegate];
                [self checkVCAndShowEventVC: appDelegate typeId: typeIdStr];
            }
            if ([dataType isEqualToString: @"categoryarea"]) {
                NSLog(@"dataType isEqualToString: categoryArea");
                CategoryViewController *categoryVC = [[UIStoryboard storyboardWithName: @"CategoryVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CategoryViewController"];
                categoryVC.categoryAreaId = typeIdStr;
                
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [self popToMyTabBarVC: appDelegate];
                [appDelegate.myNav pushViewController: categoryVC animated: YES];
            }
        }        
    } else {
        // user opened app from app icon
        NSLog(@"state is foreground and active");
        NSLog(@"alertStr: %@", alertDic);
        NSLog(@"dataType: %@", dataType);
        NSLog(@"typeIdStr: %@", typeIdStr);
        
        if ([alertDic isEqual: [NSNull null]]) {
            NSLog(@"empty alertStr");
        } else {
            if ([dataType isEqual: [NSNull null]]) {
                NSLog(@"dataType is Null");
                [[TWMessageBarManager sharedInstance] showMessageWithTitle: alertDic[@"title"] description: alertDic[@"body"] type: TWMessageBarMessageTypeInfo duration: kMessageBarDuration callback:^{
                    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    [self popToMyTabBarVC: appDelegate];
                    [self checkVCAndPresentSafariVC: appDelegate urlStr: urlStr];
                }];
            } else if ([dataType isEqualToString: @"user"]) {
                NSLog(@"dataType isEqualToString user");
                [[TWMessageBarManager sharedInstance] showMessageWithTitle: alertDic[@"title"] description: alertDic[@"body"] type: TWMessageBarMessageTypeInfo duration: kMessageBarDuration statusBarStyle: UIStatusBarStyleDefault callback:^{
                    CreaterViewController *cVC = [[UIStoryboard storyboardWithName: @"CreaterVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CreaterViewController"];
                    cVC.userId = typeIdStr;
                    
                    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    [self popToMyTabBarVC: appDelegate];
                    [appDelegate.myNav pushViewController: cVC animated: YES];
                }];
            } else if ([dataType isEqualToString: @"albumqueue"]) {
                NSLog(@"dataType isEqualToString albumqueue");
                NSLog(@"typeIdStr: %@", typeIdStr);
                
                [[TWMessageBarManager sharedInstance] showMessageWithTitle: alertDic[@"title"] description: alertDic[@"body"] type: TWMessageBarMessageTypeInfo duration: kMessageBarDuration statusBarStyle: UIStatusBarStyleDefault callback:^{
                    AlbumDetailViewController *aDVC = [[UIStoryboard storyboardWithName: @"AlbumDetailVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumDetailViewController"];
                    aDVC.albumId = typeIdStr;
                    
                    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    [self popToMyTabBarVC: appDelegate];
                    [appDelegate.myNav pushViewController: aDVC animated: NO];
                }];
            } else if ([dataType isEqualToString: @"albumqueue@messageboard"]) {
                [[TWMessageBarManager sharedInstance] showMessageWithTitle: alertDic[@"title"] description: alertDic[@"body"] type: TWMessageBarMessageTypeInfo duration: kMessageBarDuration statusBarStyle: UIStatusBarStyleDefault callback:^{
                    AlbumDetailViewController *aDVC = [[UIStoryboard storyboardWithName: @"AlbumDetailVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumDetailViewController"];
                    aDVC.albumId = typeIdStr;
                    aDVC.getMessagePush = YES;
                    
                    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    [self popToMyTabBarVC: appDelegate];
                    [appDelegate.myNav pushViewController: aDVC animated: NO];
                }];
            } else if ([dataType isEqualToString: @"user@messageboard"]) {
                [[TWMessageBarManager sharedInstance] showMessageWithTitle: alertDic[@"title"] description: alertDic[@"body"] type: TWMessageBarMessageTypeInfo duration: kMessageBarDuration statusBarStyle: UIStatusBarStyleDefault callback:^{
                    CreaterViewController *cVC = [[UIStoryboard storyboardWithName: @"CreaterVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CreaterViewController"];
                    cVC.userId = typeIdStr;
                    
                    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    [self popToMyTabBarVC: appDelegate];
                    [appDelegate.myNav pushViewController: cVC animated: YES];
                }];
            } else if ([dataType isEqualToString: @"event"]) {
                [[TWMessageBarManager sharedInstance] showMessageWithTitle: alertDic[@"title"] description: alertDic[@"body"] type: TWMessageBarMessageTypeInfo duration: kMessageBarDuration statusBarStyle: UIStatusBarStyleDefault callback:^{
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [self popToMyTabBarVC: appDelegate];
                    [self checkVCAndShowEventVC: appDelegate typeId: typeIdStr];
                }];
            } else if ([dataType isEqualToString: @"categoryarea"]) {
                [[TWMessageBarManager sharedInstance] showMessageWithTitle: alertDic[@"title"] description: alertDic[@"body"] type: TWMessageBarMessageTypeInfo duration: kMessageBarDuration statusBarStyle: UIStatusBarStyleDefault callback:^{
                    CategoryViewController *categoryVC = [[UIStoryboard storyboardWithName: @"CategoryVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CategoryViewController"];
                    categoryVC.categoryAreaId = typeIdStr;
                    
                    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    [self popToMyTabBarVC: appDelegate];
                    [appDelegate.myNav pushViewController: categoryVC animated: YES];
                }];
            }
        }
    }
}

- (void)checkVCAndShowEventVC:(AppDelegate *)appDelegate typeId:(NSString *)typeId {
    for (UIViewController *vc in appDelegate.myNav.viewControllers) {
        if ([vc isKindOfClass: [MyTabBarController class]]) {
            MyTabBarController *myTabBarC = (MyTabBarController *)vc;
            NSLog(@"myTabBarC.viewControllers: %@", myTabBarC.viewControllers);
            UINavigationController *navController = myTabBarC.viewControllers[0];
            NSLog(@"navController.viewControllers: %@", navController.viewControllers);
            for (UIViewController *vc in navController.viewControllers) {
                if ([vc isKindOfClass: [HomeTabViewController class]]) {
                    HomeTabViewController *hTVC = (HomeTabViewController *)vc;
                    [hTVC getEventData: typeId];
                }
            }
        }
    }
}

- (void)checkVCAndPresentSafariVC:(AppDelegate *)appDelegate
                           urlStr:(NSString *)urlStr {
    NSLog(@"checkVCAndPresentSafariVC");
    for (UIViewController *vc in appDelegate.myNav.viewControllers) {
        NSLog(@"vc: %@", vc);
        
        if ([vc isKindOfClass: [MyTabBarController class]]) {
            NSLog(@"vc is kind of MyTabBarController class");
            MyTabBarController *myTabBarC = (MyTabBarController *)vc;
            [myTabBarC presentSafariVC: urlStr];
        }
    }
}

- (void)popToMyTabBarVC:(AppDelegate *)appDelegate {
    NSLog(@"Before popToViewController");
    NSLog(@"appDelegate.myNav.viewControllers: %@", appDelegate.myNav.viewControllers);
    
    NSArray *array = [appDelegate.myNav viewControllers];
    
    // For Recording the myTabarVC is in which order of array
    NSInteger myTabarVCInt = 0;
    
    for (int i = 0; i < array.count; i++) {
        UIViewController *vc = array[i];
        
        if ([vc isKindOfClass: [MyTabBarController class]]) {
            NSLog(@"vc is kind of MyTabBarController");
            myTabarVCInt = i;
            NSLog(@"myTabarVCInt: %ld", (long)myTabarVCInt);
        }
    }
    [appDelegate.myNav popToViewController: array[myTabarVCInt] animated: NO];
    
    NSLog(@"After popToViewController");
    NSLog(@"appDelegate.myNav.viewControllers: %@", appDelegate.myNav.viewControllers);
}


- (void)application:(UIApplication *)application
willChangeStatusBarFrame:(CGRect)newStatusBarFrame
{
    NSLog(@"willChangeStatusBarFrame");
    self.currentStatusBarFrame = newStatusBarFrame;
    [[NSNotificationCenter defaultCenter] postNotificationName: @"Status Bar Frame Change" object: self userInfo: @{@"current status bar frame": [NSValue valueWithCGRect:newStatusBarFrame]}];
}

- (void)checkUrlScheme {
    NSLog(@"checkUrlScheme");
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    BOOL diyContentOn = [[userPrefs objectForKey: @"diyContentOn"] boolValue];
    
    if ([[userPrefs objectForKey: @"urlScheme"] isEqualToString: @"diyContent"]) {
        if (diyContentOn) {
            [self retrieveAlbum: [userPrefs objectForKey: @"albumIdScheme"]];
            /*
            FastViewController *fVC = [[UIStoryboard storyboardWithName:@"Fast" bundle:nil] instantiateViewControllerWithIdentifier:@"FastViewController"];
            fVC.selectrow = [wTools userbook];
            fVC.albumid = [userPrefs objectForKey: @"albumIdScheme"];
            fVC.templateid = [userPrefs objectForKey: @"templateIdScheme"];
            
            if ([[userPrefs objectForKey: @"templateIdScheme"] isEqualToString:@"0"]) {
                fVC.booktype = 0;
                fVC.choice = @"Fast";
            } else {
                fVC.booktype = 1000;
                fVC.choice = @"Template";
            }
            
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
            [app.myNav pushViewController: fVC animated:YES];
             */
        }
        diyContentOn = NO;
        [userPrefs setObject: [NSNumber numberWithBool: diyContentOn] forKey: @"diyContentOn"];
    }
}
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler
//- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray * __nullable restorableObjects))restorationHandler
{
    NSLog(@"continueUserActivity");
    
    if ([userActivity.activityType isEqualToString: NSUserActivityTypeBrowsingWeb]) {
        //NSString *myUrl = [userActivity.webpageURL absoluteString];
        [self handleRouting: userActivity.webpageURL];
    }
    
    return YES;
}

- (void)handleRouting: (NSURL *)url
{
    NSLog(@"handleRouting");
    NSLog(@"url: %@", url);
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application
  supportedInterfaceOrientationsForWindow:(UIWindow *)window {
//    NSLog(@"");
//    NSLog(@"supportedInterfaceOrientationsForWindow");
//    
//    NSLog(@"self.myNav.viewControllers: %@", self.myNav.viewControllers);
    for (id controller in self.myNav.viewControllers) {
        if ([controller isKindOfClass: [AlbumCreationViewController class]]) {
            return UIInterfaceOrientationMaskPortrait;
        }
        if ([controller isKindOfClass: [AlbumCollectionViewController class]]) {
        }
        if ([controller isKindOfClass: [ContentCheckingViewController class]]) {
            ContentCheckingViewController *contentCheckingVC = (ContentCheckingViewController *)controller;            
            for (UIViewController *vc in contentCheckingVC.navigationController.viewControllers) {
                if ([vc isKindOfClass: [BuyPPointViewController class]]) {
                    return UIInterfaceOrientationMaskPortrait;
                } else {}
                if ([vc isKindOfClass: [ExchangeInfoEditViewController class]]) {
                    return UIInterfaceOrientationMaskPortrait;
                }
            }            
            if (contentCheckingVC.isPresented) {
                return UIInterfaceOrientationMaskAll;
            } else {
                return UIInterfaceOrientationMaskPortrait;
            }
        }
    }
    
    /*
    for (MyTabBarController *myTabBarC in self.myNav.viewControllers) {
        if ([myTabBarC isKindOfClass: [MyTabBarController class]]) {
            for (id controller in myTabBarC.viewControllers) {
                if ([controller isKindOfClass: [UINavigationController class]]) {
                    UINavigationController *navController = (UINavigationController *)controller;
                    for (UINavigationController *navC in navController.viewControllers) {
                        if ([navC isKindOfClass: [AlbumDetailViewController class]]) {
                            for (UIViewController *vc in navC.navigationController.viewControllers) {
                                if ([vc isKindOfClass: [TestReadBookViewController class]]) {
                                    TestReadBookViewController *testReadBookVC = (TestReadBookViewController *)vc;
                                    
                                    if (testReadBookVC.isPresented) {
                                        if (testReadBookVC.isAddingBuyPointVC) {
                                            // When adding BuyPointVC, orientation should be portrait
                                            return UIInterfaceOrientationMaskPortrait;
                                        } else {
                                            //return UIInterfaceOrientationMaskAll;
                                        }                                        
                                    } else {
                                        return UIInterfaceOrientationMaskPortrait;
                                    }
                                }
                                if ([vc isKindOfClass: [ContentCheckingViewController class]]) {
                                    ContentCheckingViewController *contentCheckingVC = (ContentCheckingViewController *)vc;
                                    NSLog(@"contentCheckingVC.isPresented: %d", contentCheckingVC.isPresented);
                                    if (contentCheckingVC.isPresented) {
                                        return UIInterfaceOrientationMaskAll;
                                    } else {
                                        return UIInterfaceOrientationMaskPortrait;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
     */
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Calling API
- (void)retrieveAlbum: (NSString *)albumId {
    NSLog(@"albumId: %@", albumId);
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI retrievealbump: albumId uid: [wTools getUserID] token: [wTools getUserToken]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"response: %@", response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"AppDelegate");
                    NSLog(@"retrieveAlbum");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"retrievealbump"
                                         albumId: albumId];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"result bool value is YES");
                        
                        
                        NSLog(@"dic data photo: %@", dic[@"data"][@"photo"]);
                        NSLog(@"dic data user name: %@", dic[@"data"][@"user"][@"name"]);
                        ContentCheckingViewController *contentCheckingVC = [[UIStoryboard storyboardWithName: @"ContentCheckingVC" bundle: nil] instantiateViewControllerWithIdentifier: @"ContentCheckingViewController"];
                        contentCheckingVC.albumId = albumId;
                        contentCheckingVC.isLikes = [dic[@"data"][@"album"][@"is_likes"] boolValue];                                                
                        [self.myNav pushViewController: contentCheckingVC animated: YES];
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗：%@",dic[@"message"]);
                        [self showCustomErrorAlert: dic[@"message"]];
                    } else {
                        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}

#pragma mark - Custom Method for TimeOut
- (void)showCustomTimeOutAlert: (NSString *)msg
                  protocolName: (NSString *)protocolName
                       albumId: (NSString *)albumId
{
    CustomIOSAlertView *alertTimeOutView = [[CustomIOSAlertView alloc] init];
    alertTimeOutView.parentView = self.window;
    [alertTimeOutView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    //[alertTimeOutView setContainerView: [self createTimeOutContainerView: msg]];
    
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertTimeOutView.arrangeStyle = @"Horizontal";
    
    alertTimeOutView.parentView = self.window;
    [alertTimeOutView setButtonTitles: [NSMutableArray arrayWithObjects: NSLocalizedString(@"TimeOut-CancelBtnTitle", @""), NSLocalizedString(@"TimeOut-OKBtnTitle", @""), nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertTimeOutView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor clearColor], [UIColor clearColor],nil]];
    [alertTimeOutView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
    [alertTimeOutView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    
    __weak typeof(self) weakSelf = self;
    __weak CustomIOSAlertView *weakAlertTimeOutView = alertTimeOutView;
    [alertTimeOutView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertTimeOutView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertTimeOutView tag]);
        
        if (buttonIndex == 0) {
            [weakAlertTimeOutView close];
        } else {
            [weakAlertTimeOutView close];
            
            if ([protocolName isEqualToString: @"retrievealbump"]) {
                [weakSelf retrieveAlbum: albumId];
            }
        }
    }];
    [alertTimeOutView setUseMotionEffects: YES];
    [alertTimeOutView show];
}

- (UIView *)createTimeOutContainerView: (NSString *)msg
{
    // TextView Setting
    UITextView *textView = [[UITextView alloc] initWithFrame: CGRectMake(10, 30, 280, 20)];
    textView.text = msg;
    textView.backgroundColor = [UIColor clearColor];
    textView.textColor = [UIColor whiteColor];
    textView.font = [UIFont systemFontOfSize: 16];
    textView.editable = NO;
    
    // Adjust textView frame size for the content
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits: CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    
    NSLog(@"newSize.height: %f", newSize.height);
    
    // Set the maximum value for newSize.height less than 400, otherwise, users can see the content by scrolling
    if (newSize.height > 300) {
        newSize.height = 300;
    }
    
    // Adjust textView frame size when the content height reach its maximum
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    textView.frame = newFrame;
    
    CGFloat textViewY = textView.frame.origin.y;
    NSLog(@"textViewY: %f", textViewY);
    
    CGFloat textViewHeight = textView.frame.size.height;
    NSLog(@"textViewHeight: %f", textViewHeight);
    NSLog(@"textViewY + textViewHeight: %f", textViewY + textViewHeight);
    
    
    // ImageView Setting
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(200, -8, 128, 128)];
    [imageView setImage:[UIImage imageNamed:@"icon_2_0_0_dialog_pinpin.png"]];
    
    CGFloat viewHeight;
    
    if ((textViewY + textViewHeight) > 96) {
        if ((textViewY + textViewHeight) > 450) {
            viewHeight = 450;
        } else {
            viewHeight = textViewY + textViewHeight;
        }
    } else {
        viewHeight = 96;
    }
    NSLog(@"demoHeight: %f", viewHeight);
    
    
    // ContentView Setting
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, viewHeight)];
    //contentView.backgroundColor = [UIColor firstPink];
    contentView.backgroundColor = [UIColor firstMain];
    
    // Set up corner radius for only upper right and upper left corner
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: contentView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(13.0, 13.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.window.bounds;
    maskLayer.path  = maskPath.CGPath;
    contentView.layer.mask = maskLayer;
    
    // Add imageView and textView
    [contentView addSubview: imageView];
    [contentView addSubview: textView];
    
    NSLog(@"");
    NSLog(@"contentView: %@", NSStringFromCGRect(contentView.frame));
    NSLog(@"");
    
    return contentView;
}

#pragma mark - Custom Error Alert Method
- (void)showCustomErrorAlert: (NSString *)msg {
    
    [UIViewController showCustomErrorAlertWithMessage:msg onButtonTouchUpBlock:^(CustomIOSAlertView *customAlertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[customAlertView tag]);
        [customAlertView close];
    }];
    
}
//  handling app launched by remote notification
- (void)checkInitialLaunchCase {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *remote = (NSDictionary *)[defaults  objectForKey: @"launchNotification"];
    
    
    NSLog(@"checkInitialLaunchCase  %@",remote);
    if (remote != nil && remote.allKeys.count) {
        [self application:[UIApplication sharedApplication] didReceiveRemoteNotification:remote fetchCompletionHandler:^(UIBackgroundFetchResult result) {}];
        [defaults removeObjectForKey:@"launchNotification"];
        [defaults synchronize];
    }
}
/*
- (UIView *)createErrorContainerView: (NSString *)msg
{
    // TextView Setting
    UITextView *textView = [[UITextView alloc] initWithFrame: CGRectMake(10, 30, 280, 20)];
    //textView.text = @"帳號已經存在，請使用另一個";
    textView.text = msg;
    textView.backgroundColor = [UIColor clearColor];
    textView.textColor = [UIColor whiteColor];
    textView.font = [UIFont systemFontOfSize: 16];
    textView.editable = NO;
    
    // Adjust textView frame size for the content
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits: CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    
    NSLog(@"newSize.height: %f", newSize.height);
    
    // Set the maximum value for newSize.height less than 400, otherwise, users can see the content by scrolling
    if (newSize.height > 300) {
        newSize.height = 300;
    }
    
    // Adjust textView frame size when the content height reach its maximum
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    textView.frame = newFrame;
    
    CGFloat textViewY = textView.frame.origin.y;
    NSLog(@"textViewY: %f", textViewY);
    
    CGFloat textViewHeight = textView.frame.size.height;
    NSLog(@"textViewHeight: %f", textViewHeight);
    NSLog(@"textViewY + textViewHeight: %f", textViewY + textViewHeight);
    
    
    // ImageView Setting
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(200, -8, 128, 128)];
    [imageView setImage:[UIImage imageNamed:@"icon_2_0_0_dialog_error"]];
    
    CGFloat viewHeight;
    
    if ((textViewY + textViewHeight) > 96) {
        if ((textViewY + textViewHeight) > 450) {
            viewHeight = 450;
        } else {
            viewHeight = textViewY + textViewHeight;
        }
    } else {
        viewHeight = 96;
    }
    NSLog(@"demoHeight: %f", viewHeight);
    
    
    // ContentView Setting
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, viewHeight)];
    contentView.backgroundColor = [UIColor firstPink];
    
    // Set up corner radius for only upper right and upper left corner
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: contentView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(13.0, 13.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.window.bounds;
    maskLayer.path  = maskPath.CGPath;
    contentView.layer.mask = maskLayer;
    
    // Add imageView and textView
    [contentView addSubview: imageView];
    [contentView addSubview: textView];
    
    NSLog(@"");
    NSLog(@"contentView: %@", NSStringFromCGRect(contentView.frame));
    NSLog(@"");
    
    return contentView;
}
*/
@end
