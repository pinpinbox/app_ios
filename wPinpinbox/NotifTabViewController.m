//
//  NotifTabViewController.m
//  wPinpinbox
//
//  Created by David on 2017/10/21.
//  Copyright © 2017年 Angus. All rights reserved.
//

#import "NotifTabViewController.h"
#import "boxAPI.h"
#import "wTools.h"
#import "MBProgressHUD.h"
#import "NotifTabTableViewCell.h"
#import "AsyncImageView.h"
#import "UIColor+Extensions.h"
#import "CreaterViewController.h"
#import "CustomIOSAlertView.h"
#import "MyLinearLayout.h"
#import "AlbumDetailViewController.h"
#import "GlobalVars.h"
#import "AppDelegate.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MyTabBarController.h"
#import "LabelAttributeStyle.h"
#import <SafariServices/SafariServices.h>
#import "CategoryViewController.h"
#import "HomeTabViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "UIViewController+ErrorAlert.h"
#import "AlbumCreationViewController.h"
#import "AlbumCollectionViewController.h"
#import "UserInfo.h"

#import "YAlbumDetailContainerViewController.h"

#import "MyLayout.h"

@interface NotifTabViewController () <UITableViewDataSource, UITableViewDelegate, SFSafariViewControllerDelegate, AlbumCreationViewControllerDelegate> {
    NSMutableArray *notificationData;
    BOOL isLoading;
    BOOL isReloading;
    NSInteger nextId;
    UIView *view;
    
    UIView *noInfoView;
    BOOL isNoInfoViewCreate;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation NotifTabViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame: CGRectZero];
    [self initialValueSetup];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [wTools setStatusBarBackgroundColor: [UIColor whiteColor]];
}
- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"");
    NSLog(@"NotifTabTableViewController viewWillAppear");
    [super viewWillAppear:animated];
    
    
    for (UIView *v in self.tabBarController.view.subviews) {
        UIButton *btn = (UIButton *)[v viewWithTag: 104];
        btn.hidden = NO;
    }
    // Set Badge to 0 in the storage
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"badgeCount: %d", [[defaults objectForKey: @"badgeCount"] intValue]);
    
    if ([[defaults objectForKey: @"badgeCount"] intValue] > 0) {
        [self refresh];
    } else {
        [self loadData];
    }
    [defaults setObject: [NSNumber numberWithInteger: 0] forKey: @"badgeCount"];
    [defaults synchronize];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Set Badge to 0 for tabBarItem
    for (UIViewController *vc in appDelegate.myNav.viewControllers) {
        NSLog(@"vc: %@", vc);
        if ([vc isKindOfClass: [MyTabBarController class]]) {
            MyTabBarController *myTabBarC = (MyTabBarController *)vc;
            [[myTabBarC.viewControllers objectAtIndex: kNotifTabIndex] tabBarItem].badgeValue = nil;
        }
    }
    [wTools sendScreenTrackingWithScreenName:@"通知"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleNewVersionLabelTap {
//    NSLog(@"handleNewVersionLabelTap");
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: appStoreUrl] options:@{} completionHandler:nil];
}

#pragma mark -
- (void)initialValueSetup {
    nextId = 0;
    isLoading = NO;
    isReloading = NO;
    notificationData = [NSMutableArray new];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget: self
                            action: @selector(refresh)
                  forControlEvents: UIControlEventValueChanged];
    [self.tableView addSubview: self.refreshControl];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorColor = [UIColor thirdGrey];
    
    noInfoView.hidden = YES;
    isNoInfoViewCreate = NO;
    self.tableView.hidden = YES;
}

#pragma mark -
- (void)refresh {
    NSLog(@"refresh");
    
    if (!isReloading) {
        isReloading = YES;
        nextId = 0;
        isLoading = NO;
        
        [self loadData];
    }
}

#pragma mark - Web Service
- (void)loadData {
    NSLog(@"loadData");
    
    if (!isLoading) {
        if (nextId == 0) {
            
        }
        isLoading = YES;
        [self getPushQueue];
    }
}

- (void)getPushQueue {
    @try {
        [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    __block typeof(self) wself = self;
    NSString *limit = [NSString stringWithFormat: @"%ld,%d", (long)nextId, 10];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = @"";
        
        response = [boxAPI getPushQueue: [wTools getUserID]
                                  token: [wTools getUserToken]
                                  limit: limit];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [MBProgressHUD hideHUDForView: self.view animated: YES];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                return;
            }
            if (response != nil) {
                NSLog(@"response from getPushQueue");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"NotifTabTableViewController");
                    NSLog(@"getPushQueue");
                    
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getPushQueue"
                                         albumId: @""];
                    [wself.refreshControl endRefreshing];
                    wself->isReloading = NO;
                    
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    NSLog(@"response from getPushQueue");
                    [wself processPushQueue:dic];
                }
            } else {
                [wself.refreshControl endRefreshing];
                wself->isReloading = NO;
            }
        });
    });
}

- (void)processPushQueue:(NSDictionary *)dic {
    if ([dic[@"result"] intValue] == 1) {
        if (nextId == 0)
            [notificationData removeAllObjects];
        
        // s for counting how much data is loaded
        int s = 0;
        
        if ([wTools objectExists: dic[@"data"]]) {
            for (NSMutableDictionary *notifData in [dic objectForKey: @"data"]) {
                s++;
                [notificationData addObject: notifData];
            }
        }
        // If data keeps loading then the nextId is accumulating
        nextId = nextId + s;
        NSLog(@"nextId is: %ld", (long)nextId);
        
        // If nextId is bigger than 0, that means there are some data loaded already.
        if (nextId >= 0)
            isLoading = NO;
        
        // If s is 0, that means dic data is empty.
        if (s == 0) {
            isLoading = YES;
        }
        
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
        
        if (notificationData.count == 0) {
            if (!isNoInfoViewCreate) {
                [self addNoInfoViewOnCollectionView: @"目前沒有收到任何人通知"];
            }
            noInfoView.hidden = NO;
            self.tableView.hidden = YES;
        } else if (notificationData.count > 0) {
            noInfoView.hidden = YES;
            self.tableView.hidden = NO;
        }
        
        isReloading = NO;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSLog(@"badgeCount: %d", [[defaults objectForKey: @"badgeCount"] intValue]);
        
        [defaults setObject: [NSNumber numberWithInteger: 0] forKey: @"badgeCount"];
        [defaults synchronize];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        // Set Badge to 0 for tabBarItem
        for (UIViewController *vc in appDelegate.myNav.viewControllers) {
            NSLog(@"vc: %@", vc);
            if ([vc isKindOfClass: [MyTabBarController class]]) {
                MyTabBarController *myTabBarC = (MyTabBarController *)vc;
                [[myTabBarC.viewControllers objectAtIndex: kNotifTabIndex] tabBarItem].badgeValue = nil;
            }
        }
    } else if ([dic[@"result"] intValue] == 0) {
//        NSLog(@"失敗： %@", dic[@"message"]);
//        NSString *msg = dic[@"message"];
//        [self showCustomErrorAlert: msg];
        NSLog(@"失敗： %@", dic[@"message"]);
        if ([wTools objectExists: dic[@"message"]]) {
            [self showCustomErrorAlert: dic[@"message"]];
        } else {
            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
        }
        [self.refreshControl endRefreshing];
        isReloading = NO;
    } else {
        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
        [self.refreshControl endRefreshing];
        isReloading = NO;
    }
}

- (void)addNoInfoViewOnCollectionView:(NSString *)msg {
    NSLog(@"addNoInfoViewOnCollectionView");
    if (!isNoInfoViewCreate) {
        noInfoView = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Vert];
        noInfoView.myTopMargin = 300;
        noInfoView.myLeftMargin = noInfoView.myRightMargin = 32;
        noInfoView.backgroundColor = [UIColor thirdGrey];
        noInfoView.layer.cornerRadius = 16;
        noInfoView.clipsToBounds = YES;
        [self.view addSubview: noInfoView];
        
        MyFrameLayout *frameLayout = [self createFrameLayout];
        [noInfoView addSubview: frameLayout];
        
        UILabel *label = [self createLabel: msg];
        [frameLayout addSubview: label];
    }
    isNoInfoViewCreate = YES;
}

- (MyFrameLayout *)createFrameLayout {
    MyFrameLayout *frameLayout = [MyFrameLayout new];
    frameLayout.wrapContentHeight = YES;
    frameLayout.myMargin = 0;
    frameLayout.myCenterXOffset = 0;
    frameLayout.myCenterYOffset = 0;
    frameLayout.padding = UIEdgeInsetsMake(32, 32, 32, 32);
    return frameLayout;
}

- (UILabel *)createLabel: (NSString *)title {
    UILabel *label = [UILabel new];
    label.wrapContentHeight = YES;
    label.myLeftMargin = label.myRightMargin = 8;
    label.numberOfLines = 0;
    label.text = title;
    [LabelAttributeStyle changeGapString: label content: label.text];
    label.font = [UIFont systemFontOfSize: 17];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor firstGrey];
    [label sizeToFit];
    //    label.myCenterXOffset = 0;
    //    label.myCenterYOffset = 0;
    return label;
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return notificationData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForRowAtIndexPath");
//    NSLog(@"notificationData: %@", notificationData);
    
    // Configure the cell...
    NotifTabTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Cell" forIndexPath: indexPath];
    
    NSDictionary *dic = [notificationData[indexPath.row] copy];
    NSString *imageUrl = dic[@"pushqueue"][@"image_url"];
    NSLog(@"imageUrl: %@", imageUrl);
    NSString *message = dic[@"pushqueue"][@"message"];
    NSLog(@"message: %@", message);
    NSString *insertTime = [self hourCalculation: dic[@"pushqueue"][@"inserttime"]];
    NSString *target2type = dic[@"pushqueue"][@"target2type"];
    NSLog(@"target2type: %@", target2type);
    
//    cell.headshotImaveView.showActivityIndicator = NO;
    cell.headshotImaveView.backgroundColor = [UIColor thirdGrey];
    cell.messageLabel.text = message;
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: cell.messageLabel content: cell.messageLabel.text];
//    [LabelAttributeStyle changeGapString: cell.messageLabel content: message];
    cell.insertTimeLabel.text = insertTime;
    [LabelAttributeStyle changeGapString: cell.insertTimeLabel content: insertTime];
    
    if (![target2type isKindOfClass: [NSNull class]]) {
        if (![target2type isEqualToString: @""]) {
            if ([target2type isEqualToString: @"albumqueue"]) {
                cell.targetTypeLabel.text = @"作品通知";
                [LabelAttributeStyle changeGapString: cell.targetTypeLabel content: cell.targetTypeLabel.text];
                cell.targetTypeImageView.image = [UIImage imageNamed: @"ic200_create_album_small_white"];
                cell.targetTypeImageView.backgroundColor = [UIColor notifyAlbumBackground];
                
                if ([imageUrl isEqual: [NSNull null]] || [imageUrl isEqualToString: @""]) {
                    cell.headshotImaveView.image = [UIImage imageNamed: @"bg200_no_image.jpg"];
                } else {
                    [cell.headshotImaveView sd_setImageWithURL: [NSURL URLWithString: imageUrl]];
                    [cell.headshotImaveView sd_setImageWithURL: [NSURL URLWithString: imageUrl]
                                              placeholderImage: [UIImage imageNamed: @"bg200_no_image.jpg"]];
                }
            } else if ([target2type isEqualToString: @"albumqueue@messageboard"]) {
                cell.targetTypeLabel.text = @"創作人互動";
                [LabelAttributeStyle changeGapString: cell.targetTypeLabel content: cell.targetTypeLabel.text];
                cell.targetTypeImageView.image = [UIImage imageNamed: @"ic200_userinteractive_small_white"];
                cell.targetTypeImageView.backgroundColor = [UIColor notifyCooperationBackground];
                cell.headshotImaveView.layer.cornerRadius = kCornerRadius;
                
                if ([imageUrl isEqual: [NSNull null]] || [imageUrl isEqualToString: @""]) {
                    cell.headshotImaveView.image = [UIImage imageNamed: @"bg200_user_default"];
                } else {
                    [cell.headshotImaveView sd_setImageWithURL: [NSURL URLWithString: imageUrl]
                                              placeholderImage: [UIImage imageNamed: @"bg200_user_default"]];
                }
            } else if ([target2type isEqualToString: @"user@messageboard"]) {
                cell.targetTypeLabel.text = @"創作人互動";
                [LabelAttributeStyle changeGapString: cell.targetTypeLabel content: cell.targetTypeLabel.text];
                cell.targetTypeImageView.image = [UIImage imageNamed: @"ic200_userinteractive_small_white"];
                cell.targetTypeImageView.backgroundColor = [UIColor notifyCooperationBackground];
                cell.headshotImaveView.layer.cornerRadius = cell.headshotImaveView.bounds.size.width / 2;
                cell.headshotImaveView.layer.borderColor = [UIColor thirdGrey].CGColor;
                cell.headshotImaveView.layer.borderWidth = 0.5;
                cell.headshotImaveView.image = [UIImage imageNamed: @"PinPinBoxLogo"];
            } else if ([target2type isEqualToString: @"user"]) {
                cell.targetTypeLabel.text = @"創作人互動";
                [LabelAttributeStyle changeGapString: cell.targetTypeLabel content: cell.targetTypeLabel.text];
                //cell.targetTypeImageView.image = [UIImage imageNamed: @"ic200_userinteractive_white"];
                cell.targetTypeImageView.image = [UIImage imageNamed: @"ic200_userinteractive_small_white"];
                cell.targetTypeImageView.backgroundColor = [UIColor notifyCooperationBackground];
                
                cell.headshotImaveView.layer.cornerRadius = cell.headshotImaveView.bounds.size.width / 2;
                cell.headshotImaveView.layer.borderColor = [UIColor thirdGrey].CGColor;
                cell.headshotImaveView.layer.borderWidth = 0.5;
                
                if ([imageUrl isEqual: [NSNull null]] || [imageUrl isEqualToString: @""]) {
                    cell.headshotImaveView.image = [UIImage imageNamed: @"bg200_user_default"];
                } else {
                    [cell.headshotImaveView sd_setImageWithURL: [NSURL URLWithString: imageUrl]
                                              placeholderImage: [UIImage imageNamed: @"bg200_user_default"]];
                }
            } else if ([target2type isEqualToString: @"albumcooperation"]) {
                cell.targetTypeLabel.text = @"共用邀請";
                [LabelAttributeStyle changeGapString: cell.targetTypeLabel content: cell.targetTypeLabel.text];
                cell.targetTypeImageView.image = [UIImage imageNamed: @"ic200_cooperation_small_white"];
                cell.targetTypeImageView.backgroundColor = [UIColor notifyCooperationBackground];
                
                if ([imageUrl isEqual: [NSNull null]] || [imageUrl isEqualToString: @""]) {
                    cell.headshotImaveView.image = [UIImage imageNamed: @"bg200_user_default"];
                } else {
                    [cell.headshotImaveView sd_setImageWithURL: [NSURL URLWithString: imageUrl]
                                              placeholderImage: [UIImage imageNamed: @"bg200_user_default"]];
                }
            } else if ([target2type isEqualToString: @"event"]) {
                cell.targetTypeLabel.text = @"系統發布";
                [LabelAttributeStyle changeGapString: cell.targetTypeLabel content: cell.targetTypeLabel.text];
                cell.targetTypeImageView.image = [UIImage imageNamed: @"PinPinBoxLogo"];
                cell.headshotImaveView.image = [UIImage imageNamed: @"PinPinBoxLogo"];
            } else if ([target2type isEqualToString: @"categoryarea"]) {
                cell.targetTypeLabel.text = @"系統發布";
                [LabelAttributeStyle changeGapString: cell.targetTypeLabel content: cell.targetTypeLabel.text];
                cell.targetTypeImageView.image = [UIImage imageNamed: @"PinPinBoxLogo"];
                cell.headshotImaveView.image = [UIImage imageNamed: @"PinPinBoxLogo"];
            }
        } else {
            cell.targetTypeLabel.text = @"系統發布";
            [LabelAttributeStyle changeGapString: cell.targetTypeLabel content: cell.targetTypeLabel.text];
            cell.targetTypeImageView.image = [UIImage imageNamed: @"PinPinBoxLogo"];
            cell.headshotImaveView.image = [UIImage imageNamed: @"PinPinBoxLogo"];
        }
    } else {
        cell.targetTypeLabel.text = @"系統發布";
        [LabelAttributeStyle changeGapString: cell.targetTypeLabel content: cell.targetTypeLabel.text];
        cell.targetTypeImageView.image = [UIImage imageNamed: @"PinPinBoxLogo"];
        cell.headshotImaveView.image = [UIImage imageNamed: @"PinPinBoxLogo"];
    }    
    return cell;
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath");
    NSLog(@"notificationData: %@", notificationData);
    NSDictionary *pushDic = notificationData[indexPath.row][@"pushqueue"];
    NSString *type = pushDic[@"target2type"];
    NSLog(@"type: %@", type);
    NSString *type_id;    
    
    // Check target2type_id whether is null or not
    if ([pushDic[@"target2type_id"] isEqual: [NSNull null]]) {
        NSLog(@"pushqueue target2type_id is null");
    } else {
        type_id = [NSString stringWithFormat: @"%d", [pushDic[@"target2type_id"] intValue]];
        NSLog(@"type_id: %@", type_id);
    }
    
    // Check type
    if ([type isEqual: [NSNull null]]) {
        NSLog(@"type is equal null");
        if (![pushDic[@"url"] isEqual: [NSNull null]]) {
            SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: [NSURL URLWithString: pushDic[@"url"]]  entersReaderIfAvailable: NO];
            safariVC.delegate = self;
            safariVC.preferredBarTintColor = [UIColor whiteColor];
            [self presentViewController: safariVC animated: YES completion: nil];
        }
    } else {              
        if ([type isEqualToString: @"user"]) {
            CreaterViewController *cVC = [[UIStoryboard storyboardWithName: @"CreaterVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CreaterViewController"];
            cVC.userId = type_id;
            //[self.navigationController pushViewController: cVC animated: YES];
            
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate.myNav pushViewController: cVC animated: YES];
        }
        if ([type isEqualToString: @"albumqueue"]) {
            NotifTabTableViewCell *cell = (NotifTabTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            
            CGRect source = [self.view convertRect:cell.headshotImaveView.frame fromView:cell];
            //[self ToRetrievealbumpViewControlleralbumid: type_id source:source sourceImage:cell.headshotImaveView];
            YAlbumDetailContainerViewController *aDVC = [YAlbumDetailContainerViewController albumDetailVCWithAlbumID:type_id sourceRect:source sourceImageView:cell.headshotImaveView noParam:YES];
            
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            
            [appDelegate.myNav pushViewController: aDVC animated: YES];
            
        }
        if ([type isEqualToString: @"albumqueue@messageboard"]) {
            NSLog(@"type: %@", type);
            NotifTabTableViewCell *cell = (NotifTabTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            CGRect source = [self.view convertRect:cell.headshotImaveView.frame fromView:cell];
            YAlbumDetailContainerViewController *aDVC = [YAlbumDetailContainerViewController albumDetailVCWithAlbumID:type_id sourceRect:source sourceImageView:cell.headshotImaveView noParam:YES];
            aDVC.getMessagePush = YES;
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            
            [appDelegate.myNav pushViewController: aDVC animated: YES];
        }
        if ([type isEqualToString: @"albumcooperation"]) {
            NSLog(@"type isEqualToString albumcooperation");
            
            if ([notificationData[indexPath.row][@"cooperation"] isKindOfClass: [NSNull class]]) {
                NSLog(@"cooperation is kind of NSNull class");
                NSLog(@"作品已經被移除或是已取消跟作品的共用關係");
                NSString *msg = @"作品已經被移除或是已取消跟作品的共用關係";
                [self showCustomAlert: msg messageType: @"error"];
            } else {
                NSLog(@"cooperation exits");
                
                if ([notificationData[indexPath.row][@"cooperation"][@"identity"] isEqualToString: @"viewer"]) {
                    NSLog(@"identity is viewer");
                    NSLog(@"目前權限為瀏覽者，即將前往我的收藏(想做內容編輯可以通知作者更改一下你的權限唷)");
                    NSString *msg = @"你在當前作品的權限為瀏覽者無法編輯內容，要前往共用管理嗎?";
                    [self showCustomAlert: msg];
//                    NSString *msg = @"目前權限為瀏覽者，即將前往我的收藏(想做內容編輯可以通知作者更改一下你的權限唷)";
//                    [self showCustomAlert: msg messageType: @"confirmation"];
                } else {
                    NSLog(@"identity is not viewer");
                    AlbumCreationViewController *acVC = [[UIStoryboard storyboardWithName: @"AlbumCreationVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumCreationViewController"];
                    if ([notificationData[indexPath.row][@"cooperation"][@"identity"] isEqual: [NSNull null]]) {
                        acVC.userIdentity = @"";
                    } else {
                        acVC.userIdentity = notificationData[indexPath.row][@"cooperation"][@"identity"];
                    }
                    NSLog(@"acVC.userIdentity: %@", acVC.userIdentity);
                    acVC.albumid = type_id;
                    NSString *templateId = [notificationData[indexPath.row][@"template"][@"template_id"] stringValue];
                    acVC.templateid = [NSString stringWithFormat: @"%@", templateId];
                    
//                    acVC.shareCollection = shareCollection;
                    acVC.postMode = NO;
                    acVC.fromVC = @"NotifTabVC";
                    acVC.delegate = self;
                    acVC.isNew = NO;
                    
                    if ([templateId isEqualToString:@"0"]) {
                        acVC.booktype = 0;
                        acVC.choice = @"Fast";
                    } else {
                        acVC.booktype = 1000;
                        acVC.choice = @"Template";
                    }
//                    acVC.view.tag = index;
                    //[self.navigationController pushViewController: acVC animated: YES];
                    
                    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    [appDelegate.myNav pushViewController: acVC animated: YES];
                    
                    /*
                    FastViewController *fVC = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"FastViewController"];
                    fVC.selectrow = [wTools userbook];
                    fVC.albumid = type_id;
                    
                    NSString *templateId = [notificationData[indexPath.row][@"template"][@"template_id"] stringValue];
                    
                    fVC.templateid = [NSString stringWithFormat: @"%@", templateId];
                    
                    if ([templateId isEqualToString: @"0"]) {
                        fVC.booktype = 0;
                        fVC.choice = @"Fast";
                    } else {
                        fVC.booktype = 1000;
                        fVC.choice = @"Template";
                    }
                     */
                }
            }
        }
        if ([type isEqualToString: @"event"]) {
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [self checkVCAndShowEventVC: appDelegate typeId: type_id];
        }
        if ([type isEqualToString: @"categoryarea"]) {
            CategoryViewController *categoryVC = [[UIStoryboard storyboardWithName: @"CategoryVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CategoryViewController"];
            categoryVC.categoryAreaId = type_id;
            
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate.myNav pushViewController: categoryVC animated: YES];
        }
    }
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section {
    //UIView *headerView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, tableView.bounds.size.width, 90)];

    MyLinearLayout *headerVertLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Vert];
    headerVertLayout.wrapContentHeight = YES;
    headerVertLayout.myLeftMargin = headerVertLayout.myRightMargin = 0;
    headerVertLayout.myTopMargin = 32;
    headerVertLayout.myBottomMargin = 0;
    headerVertLayout.heightDime.max(80);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasNewVersion = [[defaults objectForKey: @"hasNewVersion"] boolValue];
    NSLog(@"hasNewVersion: %d", hasNewVersion);
    
    if (hasNewVersion) {
        NSLog(@"hasNewVersion is YES");
        NSLog(@"Setup updateLabel");
        UILabel *updateLabel = [UILabel new];
        updateLabel.myLeftMargin = 16;
        updateLabel.myTopMargin = 0;
        updateLabel.myBottomMargin = 8;
        updateLabel.text = @"有新版本囉，立即前往AppStore!";
        [LabelAttributeStyle changeGapString: updateLabel content: @"有新版本囉，立即前往AppStore!"];
        updateLabel.textColor = [UIColor firstPink];
        updateLabel.font = [UIFont systemFontOfSize: 18];
        updateLabel.userInteractionEnabled = YES;
        [updateLabel sizeToFit];
        UITapGestureRecognizer *newVersionLabelTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleNewVersionLabelTap)];
        [updateLabel addGestureRecognizer: newVersionLabelTap];
        [headerVertLayout addSubview: updateLabel];
        headerVertLayout.heightDime.max(100);
    }
    
    //UILabel *sectionHeaderTitle = [[UILabel alloc] initWithFrame: CGRectMake(16, 32, 108, 58)];
    UILabel *sectionHeaderTitle = [UILabel new];
    sectionHeaderTitle.myLeftMargin = 16;
    sectionHeaderTitle.myTopMargin = 32;
    sectionHeaderTitle.myBottomMargin = 0;
    sectionHeaderTitle.text = @"通知中心";
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: sectionHeaderTitle content: sectionHeaderTitle.text];
//    [LabelAttributeStyle changeGapString: sectionHeaderTitle content: @"通知中心"];
    sectionHeaderTitle.font = [UIFont boldSystemFontOfSize: 48];
    sectionHeaderTitle.textColor = [UIColor firstGrey];
    sectionHeaderTitle.backgroundColor = [UIColor clearColor];
    [sectionHeaderTitle sizeToFit];
    [headerVertLayout addSubview: sectionHeaderTitle];
    [headerVertLayout sizeToFit];
    self.tableView.tableHeaderView = headerVertLayout;
    
    return headerVertLayout;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {
    CGFloat height;
    
    if (notificationData.count == 0) {
        height = 0;
    } else {
        height = 32;
    }
    return height;
}

#pragma mark - Helper Methods
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

// Time Calculation Function
- (NSString *)hourCalculation: (NSString *)postDate {
    NSLog(@"hourCalculation");
    NSLog(@"postDate: %@", postDate);
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate *expDate = [dateFormat dateFromString: postDate];
    NSLog(@"expDate: %@", expDate);
    
    NSTimeZone *currentTimeZone = [NSTimeZone localTimeZone];
    NSTimeZone *utcTimeZone = [NSTimeZone timeZoneWithAbbreviation: @"UTC"];
    
    NSInteger currentGMTOffset = [currentTimeZone secondsFromGMTForDate: expDate];
    NSInteger gmtOffset = [utcTimeZone secondsFromGMTForDate: expDate];
    NSTimeInterval gmtInterval = currentGMTOffset - gmtOffset;
    
    NSDate *destinationDate = [[NSDate alloc] initWithTimeInterval: gmtInterval sinceDate: expDate];
    NSLog(@"destinationDate: %@", destinationDate);
    NSDate *currentDate = [[NSDate alloc] initWithTimeInterval: gmtInterval sinceDate: [NSDate date]];
    
    //NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation: @"GMT"];
    //[dateFormat setTimeZone: gmt];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components: (NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond) fromDate: destinationDate toDate: currentDate options: 0];
    NSString *time;
    
    NSLog(@"NSDate date: %@", [NSDate date]);
    NSLog(@"components: %@", components);
    
    if (components.year != 0) {
        if (components.year == 1) {
            time = [NSString stringWithFormat: @"%ld 年", (long)components.year];
        } else {
            time = [NSString stringWithFormat: @"%ld 年", (long)components.year];
        }
    } else if (components.month != 0) {
        if (components.month == 1) {
            time = [NSString stringWithFormat: @"%ld 月", (long)components.month];
        } else {
            time = [NSString stringWithFormat: @"%ld 月", (long)components.month];
        }
    } else if (components.weekday != 0) {
        if (components.weekday == 1) {
            time = [NSString stringWithFormat: @"%ld 週", (long)components.weekday];
        } else {
            time = [NSString stringWithFormat: @"%ld 週", (long)components.weekday];
        }
    } else if (components.day != 0) {
        if (components.day == 1) {
            time = [NSString stringWithFormat: @"%ld 天", (long)components.day];
        } else {
            time = [NSString stringWithFormat: @"%ld 天", (long)components.day];
        }
    } else if (components.hour != 0) {
        if (components.hour == 1) {
            time = [NSString stringWithFormat: @"%ld 小時", (long)components.hour];
        } else {
            time = [NSString stringWithFormat: @"%ld 小時", (long)components.hour];
        }
    } else if (components.minute != 0) {
        if (components.minute == 1) {
            time = [NSString stringWithFormat: @"%ld 分鐘", (long)components.minute];
        } else {
            time = [NSString stringWithFormat: @"%ld 分鐘", (long)components.minute];
        }
    } else if (components.second >= 0) {
        if (components.second == 0) {
            time = [NSString stringWithFormat: @"1 秒"];
        } else {
            time = [NSString stringWithFormat: @"%ld 秒", (long)components.second];
        }
    }
    NSLog(@"time: %@", time);
    return [NSString stringWithFormat: @"%@前", time];
}

#pragma mark - Call Protocol


- (void)showCustomAlert:(NSString *)msg
            messageType:(NSString *)messageType {
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    [alertView setContainerView: [self createContainerView: msg]];
    
    [alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    
    if ([messageType isEqualToString: @"error"]) {
        [alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor firstPink]]];
        [alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor darkPink]]];
    } else if ([messageType isEqualToString: @"confirmation"]) {
        [alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
        [alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor firstGrey]]];
    }
    
    alertView.arrangeStyle = @"Horizontal";
    
    /*
     [alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
     [alertView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor firstMain], [UIColor firstPink], [UIColor secondGrey], nil]];
     [alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor darkMain], [UIColor darkPink], [UIColor firstGrey], nil]];
     alertView.arrangeStyle = @"Vertical";
     */
    
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        [alertView close];
    }];
    [alertView setUseMotionEffects: YES];
    [alertView show];
}

- (UIView *)createContainerView:(NSString *)msg {
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
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: contentView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(6.0, 6.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.bounds;
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

#pragma mark - Custom AlertView for Yes and No
- (void)showCustomAlert: (NSString *)msg {
    NSLog(@"showCustomAlert: Msg: %@", msg);
    CustomIOSAlertView *alertBackView = [[CustomIOSAlertView alloc] init];
    //[alertBackView setContainerView: [self createContainerView: msg]];
    [alertBackView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertBackView.arrangeStyle = @"Horizontal";
    
    [alertBackView setButtonTitles: [NSMutableArray arrayWithObjects: @"稍後再說", @"前往共用管理", nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertBackView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor whiteColor],nil]];
    [alertBackView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
    [alertBackView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    
    __weak CustomIOSAlertView *weakAlertBackView = alertBackView;
    //__weak typeof(self) weakSelf = self;
    [alertBackView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertBackView, int buttonIndex) {
        //__strong typeof(weakSelf) stSelf = weakSelf;
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertBackView tag]);
        [weakAlertBackView close];
        
        if (buttonIndex == 0) {
            
        } else {
            AlbumCollectionViewController *albumCollectionVC = [[UIStoryboard storyboardWithName: @"AlbumCollectionVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumCollectionViewController"];
            albumCollectionVC.fromVC = @"NotifTabViewController";
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate.myNav pushViewController: albumCollectionVC animated: YES];
        }
    }];
    [alertBackView setUseMotionEffects: YES];
    [alertBackView show];
}

#pragma mark - Custom Method for TimeOut
- (void)showCustomTimeOutAlert: (NSString *)msg
                  protocolName: (NSString *)protocolName
                       albumId: (NSString *)albumId {
    CustomIOSAlertView *alertTimeOutView = [[CustomIOSAlertView alloc] init];
    //[alertTimeOutView setContainerView: [self createTimeOutContainerView: msg]];
    [alertTimeOutView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertTimeOutView.arrangeStyle = @"Horizontal";
    
    alertTimeOutView.parentView = self.tableView.superview;
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
        
        [weakAlertTimeOutView close];
        
        if (buttonIndex == 0) {            
        } else {
            if ([protocolName isEqualToString: @"getPushQueue"]) {
                [weakSelf getPushQueue];
            }
//            else if ([protocolName isEqualToString: @"retrievealbump"]) {
//                [weakSelf ToRetrievealbumpViewControlleralbumid: albumId];
//            }
        }
    }];
    [alertTimeOutView setUseMotionEffects: YES];
    [alertTimeOutView show];
}

- (UIView *)createTimeOutContainerView: (NSString *)msg {
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
    maskLayer.frame = self.view.bounds;
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

@end
