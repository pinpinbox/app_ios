//
//  ShareViewController.m
//  PinpinboxShareExtension
//
//  Created by Antelis on 2018/12/11.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "ShareViewController.h"
#import "UserInfo.h"
#import "UserAPI.h"

#import "UIColor+Extensions.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <UserNotifications/UserNotifications.h>


@interface ShareViewController ()<UITableViewDelegate, UITableViewDataSource>
@property(weak, nonatomic) IBOutlet UILabel *userName;
@property(weak, nonatomic) IBOutlet UITableView *albumList;
@property(weak, nonatomic) IBOutlet UICollectionView *photoList;
@property(weak, nonatomic) IBOutlet UITextView *textArea;
@property(weak, nonatomic) IBOutlet UIView *notLoginCover;
@property(weak, nonatomic) IBOutlet UITextView *coverNotice;
@property(nonatomic) NSMutableArray *albumlist;
@end

@interface AlbumCellView : UITableViewCell
@property(weak, nonatomic) IBOutlet UIImageView *album;
@property(weak, nonatomic) IBOutlet UILabel *albumName;
@property(weak, nonatomic) IBOutlet UILabel *albumOwner;
@property(weak, nonatomic) IBOutlet UILabel *albumDate;
@property(weak, nonatomic) IBOutlet UIImageView *albumStatus;
@end
#pragma mark - Cell for album list
@implementation AlbumCellView
- (void)loadAlbum:(NSDictionary *)data {
    NSDictionary *album = data[@"album"];
    if (![album isKindOfClass:[NSNull class]]) {
        self.albumName.text = album[@"name"];
        self.albumDate.text = album[@"insertdate"];
        NSString *act = album[@"act"];
        
        if ([act isEqualToString: @"open"]) {
            UIImage *i = [UIImage imageNamed:@"ic200_act_open_white.png"];
            self.albumStatus.image = [i imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            
        } else {
            UIImage *i = [UIImage imageNamed:@"ic200_act_close_white.png"];
            self.albumStatus.image = [i imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        self.albumStatus.tintColor = [UIColor firstPink];
        
        if (album[@"cover"] && ![album[@"cover"] isKindOfClass:[NSNull class]]) {
            NSString *c = album[@"cover"];
            //__block typeof(self) wself = self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *dt = [NSData dataWithContentsOfURL:[NSURL URLWithString:c]];
                if (dt) {
                    UIImage *cover = [UIImage imageWithData:dt];
                    if (cover) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            self.album.image = cover;
                        });
                    }
                }
            });
        }
    }
}
@end

#pragma mark - share extension VC
@implementation ShareViewController

- (void)viewDidLoad {
    
    self.albumlist = [NSMutableArray array];
    
    if ([UserInfo getUserID].length < 1 ) {
        self.notLoginCover.hidden = NO;
        return;
    } else {
        [UserAPI userProfileWithCompletionBlock:^(NSDictionary *result, NSError *error) {
            if (result) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.userName.text = result[@"nickname"];
                    [self loadAlbumList];
                    
                });
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showErrorMessage:@"無法取得用戶資料，請稍後再試"];
                });
            }
            
        }];
    }
}
- (void)displayExtensionContext {
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
                } else if ([p hasItemConformingToTypeIdentifier:(__bridge NSString *)kUTTypeMPEG4]) {
                    [p loadItemForTypeIdentifier:(__bridge NSString *)kUTTypeMPEG4 options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                        NSURL *u = (NSURL *)item;
                        if (u) {
                            NSLog(@"file url : %@",u);
                        }
                    }];
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
- (void)showErrorMessage:(NSString *)message {
    self.coverNotice.text = message;
    self.notLoginCover.hidden = NO;
}
#pragma mark -
- (IBAction)cancelAndFinish:(id)sender {
    
    NSExtensionContext *cxt = self.extensionContext;
    
    [cxt completeRequestReturningItems:nil completionHandler:nil];
    
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
    
    if ([UserInfo getUserID].length < 1 ) {
        NSExtensionContext *cxt = self.extensionContext;
        [cxt completeRequestReturningItems:nil completionHandler:nil];
        return;
    }
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNMutableNotificationContent *cnt = [[UNMutableNotificationContent alloc] init];
    cnt.title = @"分享至Pinpinbox";
    cnt.subtitle = message;
    cnt.body = [NSString stringWithFormat:@"{\"album_id\":%@}", albumid];
    cnt.sound = UNNotificationSound.defaultSound;
    // add album data in cnt.userinfo
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
#pragma mark -
- (void)loadAlbumList {
    [UserAPI loadAlbumListWithCompletionBlock:self.albumlist.count completionBlock:^(NSDictionary * _Nonnull result, NSError * _Nonnull error) {
        
        if (result) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *list = [result objectForKey:@"data"];
                [self.albumlist addObjectsFromArray:list];
                [self.albumList reloadData];
                [self displayExtensionContext];
                
            });
        }
    }];
    
}
#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AlbumCellView *cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumCell"];
    if (!cell)
        cell = [[AlbumCellView alloc] init];
    [cell loadAlbum:[self.albumlist objectAtIndex:indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albumlist.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 112;
}
/*
 checktoken
 *getprofile*
 *getcalbumlist
 *insertphotoofdiy
 *insertvideoofdiy
 *updatephotoofdiy
 *insertalbumofdiy
 retrievealbump
 *updatealbumofdiy
 
 */

@end
