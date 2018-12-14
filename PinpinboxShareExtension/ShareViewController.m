//
//  ShareViewController.m
//  PinpinboxShareExtension
//
//  Created by Antelis on 2018/12/11.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "ShareViewController.h"
#import "UserInfo.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <UserNotifications/UserNotifications.h>
@interface ShareViewController ()
@property(weak, nonatomic) IBOutlet UILabel *userName;
@property(weak, nonatomic) IBOutlet UITableView *albumList;
@property(weak, nonatomic) IBOutlet UICollectionView *photoList;
@property(weak, nonatomic) IBOutlet UITextView *textArea;
@end

@implementation ShareViewController

- (void)viewDidLoad {
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *profile = (NSDictionary *)[userPrefs objectForKey:@"profile"];

    if (profile) {
        self.userName.text = profile.description;
    } else
        self.userName.text = [UserInfo getUserID];
    NSExtensionContext *cxt = self.extensionContext;
    if (cxt) {
        NSArray *items = cxt.inputItems;
        __block typeof(self) wself = self;
        for (NSExtensionItem *item in items) {
            NSArray *attachments = item.attachments;
            for (NSItemProvider *p in attachments) {
                if ([p hasItemConformingToTypeIdentifier:(__bridge NSString *)kUTTypeURL]) {
                    [p loadItemForTypeIdentifier:(__bridge NSString *)kUTTypeURL options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                        NSURL *u = (NSURL *)item;
                        if (u) {
                            [wself setTextAreaText:[u absoluteString]];
                        }
                            
                    }];
                    
                } else if ([p hasItemConformingToTypeIdentifier:(__bridge NSString *)kUTTypeText]) {
                    [p loadItemForTypeIdentifier:(__bridge NSString *)kUTTypeText options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                        NSURL *u = (NSURL *)item;
                        if (u)
                            [wself setTextAreaText:[u absoluteString]];
                    }];
                } else {
                    
                }
                
            }
        }
    }
}
- (void)setTextAreaText:(NSString *)text {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.textArea.text = text;
    });
}
- (IBAction)postShareItem:(id)sender {
    if (self.extensionContext) {
        
        //__block typeof(self) wself = self;
        [self trySendLocalNotification:@"Post Finished" albumid:@"ALBUMID"];
        
    }
}
- (IBAction)cancelAndFinish:(id)sender {
    
}
- (void)trySendLocalNotification:(NSString *)message albumid:(NSString *)albumid {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    __block typeof(self) wself = self;
    [center requestAuthorizationWithOptions:UNAuthorizationOptionBadge|UNAuthorizationOptionAlert|UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!error) {
            [wself sendLocalNotification:message albumid: albumid];
        }
    }];
}
- (void)sendLocalNotification:(NSString *)message albumid:(NSString *)albumid {
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNMutableNotificationContent *cnt = [[UNMutableNotificationContent alloc] init];
    cnt.title = @"分享至Pinpinbox";
    cnt.subtitle = message;
    cnt.body = [NSString stringWithFormat:@"{\"album_id\":%@}", albumid];
    cnt.sound = UNNotificationSound.defaultSound;
    
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1.0 repeats:false];
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"PinpinboxContentID" content:cnt trigger:trigger];
    NSExtensionContext *cxt = self.extensionContext;
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"addNotificationRequest %@",error);
        }
        
        [cxt completeRequestReturningItems:nil completionHandler:^(BOOL expired) {
            
        }];
    }];
}
/*
 checktoken
 getprofile
 getcalbumlist
 insertphotoofdiy
 insertvideoofdiy
 updatephotoofdiy
 insertalbumofdiy
 retrievealbump
 updatealbumofdiy
 
 */
@end
