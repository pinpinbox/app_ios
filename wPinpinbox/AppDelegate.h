//
//  AppDelegate.h
//  wPinpinbox
//
//  Created by Angus on 2015/8/6.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
#import "ViewController.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate>
{
    CLLocationManager *location;
}

@property (weak, nonatomic) ViewController *myViewController;

@property (strong, nonatomic) UIWindow *window;
@property (weak, nonatomic) UINavigationController *myNav;
@property (strong, nonatomic) NSString *coordinate;
@property (copy) void (^backgroundSessionCompletionHandler)(void);

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)checkInitialLaunchCase;
@end
