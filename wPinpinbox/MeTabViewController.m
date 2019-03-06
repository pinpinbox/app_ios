//
//  MeTabViewController.m
//  wPinpinbox
//
//  Created by David on 4/23/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "MeTabViewController.h"
#import "InfoEditViewController.h"
#import "boxAPI.h"
#import "wTools.h"
//#import "MBProgressHUD.h"
#import "UIColor+Extensions.h"

#import "JCCollectionViewWaterfallLayout.h"

#import "MeCollectionViewCell.h"
#import "MeCollectionReusableView.h"

#import "AsyncImageView.h"
#import "UIView+Toast.h"
#import "LabelAttributeStyle.h"

#import <SafariServices/SafariServices.h>

#import "FollowListsViewController.h"
#import "RecentBrowsingViewController.h"
#import "BuyPPointViewController.h"

#import "CustomIOSAlertView.h"
#import "OldCustomAlertView.h"
#import <SafariServices/SafariServices.h>
//#import "AlbumDetailViewController.h"
#import "AlbumCollectionViewController.h"
#import "AppDelegate.h"

#import "SettingViewController.h"
#import "GlobalVars.h"
#import "DDAUIActionSheetViewController.h"
#import "PointCalculationViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import "ExchangeListViewController.h"
#import "FollowFromListViewController.h"
#import "SponsorListViewController.h"

#import "MessageboardViewController.h"
#import "UIColor+HexString.h"

#import "CropImageViewController.h"
#import "UIViewController+ErrorAlert.h"

#import "YAlbumDetailContainerViewController.h"

#define kStatusHeight 20;
#define kTopGapToHeashot 44
#define kHeadhotHeight 96
#define kGapToCreativeNameHeight 32
#define kGapToAlbumLabelHeight 32
#define kAlbumLabelHeight 36

//static NSString *userIdSharingLink = @"http://www.pinpinbox.com/index/creative/content/?user_id=%@%@";
static NSString *autoPlayStr = @"&autoplay=1";

@interface MeTabViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, JCCollectionViewWaterfallLayoutDelegate, UIGestureRecognizerDelegate, SFSafariViewControllerDelegate, InfoEditViewControllerDelegate, DDAUIActionSheetViewControllerDelegate, MessageboardViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    NSMutableArray *pictures;
    BOOL isLoading;
    NSInteger  nextId;
    BOOL isReloading;
    
    //NSDictionary *userDic;
    NSDictionary *followDic;
    NSDictionary *sponsorDic;
    
    CGFloat createNameLabelHeight;
    CGFloat nameLabelHeight;
    CGFloat userNameLabelHeight;

    CGFloat descriptionLabelHeight;
    
    NSInteger socialLinkInt;
    
    NSDictionary *myData;
    
    // For Showing Message of Getting Point
    NSString *missionTopicStr;
    NSString *rewardType;
    NSString *rewardValue;
    NSString *eventUrl;
    
    NSString *restriction;
    NSString *restrictionValue;
    NSUInteger numberOfCompleted;
    
    OldCustomAlertView *alertView;
    
    NSString *profilePicUrlString;
    
    NSInteger columnCount;
    NSInteger miniInteriorSpacing;
    
    CGFloat coverImageHeight;
    CGFloat creativeNameLabelHeight;
    CGFloat linkBgViewHeight;
    
    UIView *noInfoView;
    BOOL isNoInfoViewCreate;
}
@property (strong, nonatomic) NSDictionary *userDic;

//@property (weak, nonatomic) IBOutlet UIView *navBarView;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarHeight;

@property (nonatomic, strong) JCCollectionViewWaterfallLayout *jccLayout;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic) DDAUIActionSheetViewController *customActionSheet;
@property (nonatomic) MessageboardViewController *customMessageActionSheet;
@property (nonatomic) UIVisualEffectView *effectView;

@property (nonatomic) NSString *userId;

@property (nonatomic) NSInteger sum;
@property (nonatomic) NSInteger sumOfSettlement;
@property (nonatomic) NSInteger sumOfUnsettlement;
@property (nonatomic) NSString *identity;

@property (nonatomic) IBOutlet NSLayoutConstraint *collectionViewTopConstraint;
@property (nonatomic) IBOutlet UIView *navMenu;
@end

@implementation MeTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"MeTabViewController viewDidLoad");
    // Do any additional setup after loading the view.
    [self initialValueSetup];
    //[self loadData];        
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"");
    NSLog(@"MeTabViewController viewWillAppear");
    [super viewWillAppear:animated];
    [wTools setStatusBarBackgroundColor: [UIColor whiteColor]];
    [self.navigationController.navigationBar setShadowImage: [UIImage imageNamed:@"navigationbarshadow"]];
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"11.0" options:NSNumericSearch] == NSOrderedAscending){
        self.collectionViewTopConstraint.constant = 0;
    }
    // ADD buttons to navigation bar at right
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:self.navMenu];
    [self.navigationItem setRightBarButtonItem:item];
    
    for (UIView *view in self.tabBarController.view.subviews) {
        UIButton *btn = (UIButton *)[view viewWithTag: 104];
        btn.hidden = NO;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isAlbumDeleted = [[defaults objectForKey: @"deleteAlbum"] boolValue];
    BOOL isAlbumCreated = [[defaults objectForKey: @"createAlbum"] boolValue];
    BOOL isAlbumModified = [[defaults objectForKey: @"modifyAlbum"] boolValue];
    BOOL isAlbumPrivacyStatusChange = [[defaults objectForKey: @"privacyStatusChange"] boolValue];
    BOOL isSetUserCover = [[defaults objectForKey: @"setUserCover"] boolValue];
    NSLog(@"isAlbumDeleted: %d", isAlbumDeleted);
    NSLog(@"isAlbumCreated: %d", isAlbumCreated);
    NSLog(@"isAlbumModified: %d", isAlbumModified);
    NSLog(@"isAlbumPrivacyStatusChange: %d", isAlbumPrivacyStatusChange);
    NSLog(@"isSetUserCover: %d", isSetUserCover);
    
    if (isAlbumDeleted || isAlbumCreated || isAlbumModified || isAlbumPrivacyStatusChange || isSetUserCover) {
        [self refresh];
    } else {
        [self loadData];
    }
    if (isAlbumDeleted) {
        isAlbumDeleted = NO;
        
        NSLog(@"isAlbumDeleted: %d", isAlbumDeleted);
        [defaults setObject: [NSNumber numberWithBool: isAlbumDeleted] forKey: @"deleteAlbum"];
        [defaults synchronize];
    }
    if (isAlbumCreated) {
        isAlbumCreated = NO;
        
        NSLog(@"isAlbumCreated: %d", isAlbumCreated);
        [defaults setObject: [NSNumber numberWithBool: isAlbumCreated] forKey: @"createAlbum"];
        [defaults synchronize];
    }
    if (isAlbumModified) {
        isAlbumModified = NO;
        
        NSLog(@"isAlbumModified: %d", isAlbumModified);
        [defaults setObject: [NSNumber numberWithBool: isAlbumModified] forKey: @"modifyAlbum"];
        [defaults synchronize];
    }
    if (isAlbumPrivacyStatusChange) {
        isAlbumPrivacyStatusChange = NO;
        
        NSLog(@"isAlbumPrivacyStatusChange: %d", isAlbumPrivacyStatusChange);
        [defaults setObject: [NSNumber numberWithBool: isAlbumPrivacyStatusChange] forKey: @"privacyStatusChange"];
        [defaults synchronize];
    }
    //[self.collectionView reloadData];
    [wTools sendScreenTrackingWithScreenName:@"個人專區"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)initialValueSetup {
    NSLog(@"initialValueSetup");        
    
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
//            case 1136:
//                printf("iPhone 5 or 5S or 5C");
//                self.navBarHeight.constant = 48;
//    //            self.collectionView.contentInset = UIEdgeInsetsMake(48, 0, 0, 0);
//                break;
//            case 1334:
//                printf("iPhone 6/6S/7/8");
//                self.navBarHeight.constant = 48;
//    //            self.collectionView.contentInset = UIEdgeInsetsMake(48, 0, 0, 0);
//                break;
//            case 1920:
//                printf("iPhone 6+/6S+/7+/8+");
//                self.navBarHeight.constant = 48;
//   //             self.collectionView.contentInset = UIEdgeInsetsMake(48, 0, 0, 0);
//                break;
//            case 2208:
//                printf("iPhone 6+/6S+/7+/8+");
//                self.navBarHeight.constant = 48;
//   //             self.collectionView.contentInset = UIEdgeInsetsMake(48, 0, 0, 0);
//                break;
//            case 2436:
//                printf("iPhone X");
//                self.navBarHeight.constant = navBarHeightConstant;
//   //             self.collectionView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
//                break;
//            default:
//                printf("unknown");
//                self.navBarHeight.constant = 48;
//   //             self.collectionView.contentInset = UIEdgeInsetsMake(48, 0, 0, 0);
//                break;
//        }
//    }
    
    self.customActionSheet = [[DDAUIActionSheetViewController alloc] init];
    self.customActionSheet.delegate = self;
    self.customActionSheet.topicStr = @"要前往哪裡？";
    
    
    nextId = 0;
    isLoading = NO;
    isReloading = NO;
    
    pictures = [NSMutableArray new];
    self.userDic = [NSDictionary new];
    followDic = [NSDictionary new];
    sponsorDic = [NSDictionary new];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget: self
                            action: @selector(refresh)
                  forControlEvents: UIControlEventValueChanged];
    [self.collectionView addSubview: self.refreshControl];
    
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    //self.navBarView.backgroundColor = [UIColor barColor];
    
    columnCount = 2;
    miniInteriorSpacing = 16;
    
    self.customMessageActionSheet = [[MessageboardViewController alloc] init];
    self.customMessageActionSheet.delegate = self;
    
    noInfoView.hidden = YES;
    isNoInfoViewCreate = NO;
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
    // If isLoading is NO then run the following code
    if (!isLoading) {
        if (nextId == 0) {
            NSLog(@"nextId: %ld", (long)nextId);
        }
        isLoading = YES;
        [self getCreatorInfo];
    }
}

- (void)getCreatorInfo {
    NSLog(@"getCreatorInfo");
    @try {
        [DGHUDView start];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    NSMutableDictionary *data = [NSMutableDictionary new];
    NSString *limit = [NSString stringWithFormat:@"%ld,%d", (long)nextId, 16];
    [data setValue: limit forKey: @"limit"];
    [data setObject: [wTools getUserID] forKey: @"authorid"];
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSString *response = [boxAPI getcreative:[wTools getUserID]
                                           token:[wTools getUserToken]
                                            data:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [DGHUDView stop];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                return;
            }            
            if (response != nil) {
                NSLog(@"response from getCreative is not nil");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"MeTabViewController");
                    NSLog(@"getCreatorInfo");
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getcreative"
                                         albumId: @""];
//                    [self.refreshControl endRefreshing];
                    wself->isReloading = NO;
                } else {
                    NSLog(@"Get Real Response");
                    NSLog(@"response from getCreative");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    [wself processCreatorInfo:dic];
                }
            } else {
//                [self.refreshControl endRefreshing];
                wself->isReloading = NO;
            }
            [wself.refreshControl endRefreshing];
            wself->isReloading = NO;
        });
    });
}

- (void)processCreatorInfo:(NSDictionary *)dic {
    if ([dic[@"result"] intValue] == 1) {
        self.identity = dic[@"data"][@"split"][@"identity"];
        self.sum = [dic[@"data"][@"split"][@"sum"] integerValue];
        self.sumOfSettlement = [dic[@"data"][@"split"][@"sumofsettlement"] integerValue];
        self.sumOfUnsettlement = [dic[@"data"][@"split"][@"sumofunsettlement"] integerValue];
        self.userDic = dic[@"data"][@"user"];
        
        if (nextId == 0) {
            pictures = [NSMutableArray new];
        }
        int s = 0;
        
//        if (![wTools objectExists: dic[@"data"][@"album"]]) {
//            return;
//        }
        
        for (NSMutableDictionary *picture in [dic objectForKey:@"data"][@"album"]) {
            s++;
            [pictures addObject: picture];
        }
        NSLog(@"pictures.count: %lu", (unsigned long)pictures.count);
        nextId = nextId + s;
        NSLog(@"dic data follow: %@", dic[@"data"][@"follow"]);
        followDic = dic[@"data"][@"follow"];
        sponsorDic = dic[@"data"][@"userstatistics"];
        [self.collectionView reloadData];
        
        NSLog(@"nextId: %ld", (long)nextId);
        NSLog(@"s: %d", s);
        
        if (nextId >= 0)
            isLoading = NO;
        
        if (s == 0) {
            isLoading = YES;
        }
        NSLog(@"After getting data");
        NSLog(@"\n\nisLoading: %d", isLoading);
        
        [self layoutSetup];
        
        if (pictures.count == 0) {
            if (!isNoInfoViewCreate) {
                [self addNoInfoViewOnCollectionView: @"沒有作品展示"];
            }
            noInfoView.hidden = NO;
        } else if (pictures.count > 0) {
            noInfoView.hidden = YES;
        }
        
        [self getProfile];
        
        isReloading = NO;
    } else if ([dic[@"result"] intValue] == 0) {
        if ([wTools objectExists: dic[@"message"]]) {
            [self showCustomErrorAlert: dic[@"message"]];
        } else {
            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
        }
        isReloading = NO;
    } else {
        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
        isReloading = NO;
    }
}

- (void)addNoInfoViewOnCollectionView:(NSString *)msg {
    NSLog(@"addNoInfoViewOnCollectionView");
    if (!isNoInfoViewCreate) {
        noInfoView = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Vert];
        noInfoView.myTopMargin = 528;
        noInfoView.myLeftMargin = noInfoView.myRightMargin = 64;
        noInfoView.backgroundColor = [UIColor thirdGrey];
        noInfoView.layer.cornerRadius = 16;
        noInfoView.clipsToBounds = YES;
        [self.collectionView addSubview: noInfoView];
        
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
    [LabelAttributeStyle changeGapStringAndLineSpacingCenterAlignment: label content: label.text];
    label.font = [UIFont systemFontOfSize: 17];
        label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor firstGrey];
    [label sizeToFit];
    return label;
}

- (void)getProfile {
    NSLog(@"getProfile");
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    @try {
        [DGHUDView start];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI getprofile: [userPrefs objectForKey: @"id"] token: [userPrefs objectForKey: @"token"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [DGHUDView stop];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                return;
            }
            if (response != nil) {
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"MeTabViewController");
                    NSLog(@"getProfile");
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getprofile"
                                         albumId: @""];
                    [wself.refreshControl endRefreshing];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    NSLog(@"responseFromGetProfile != nil");
                    [wself processProfile:dic];
                }
            } else {
                [wself.refreshControl endRefreshing];
            }
        });
    });
}

- (void)processProfile:(NSDictionary *)dic {
    if ([dic[@"result"] intValue] == 1) {
        NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *dataIc = [[NSMutableDictionary alloc] initWithDictionary: dic[@"data"] copyItems: YES];
        
        if (![wTools objectExists: [dataIc allKeys]]) {
            return;
        }
        
        for (NSString *key in [dataIc allKeys]) {
            id objective = [dataIc objectForKey: key];
            
            if ([objective isKindOfClass: [NSNull class]]) {
                [dataIc setObject: @"" forKey: key];
            }
        }
        [userPrefs setValue: dataIc forKey: @"profile"];
        [userPrefs synchronize];
        
        myData = [dataIc mutableCopy];
    } else if ([dic[@"result"] intValue] == 0) {
        NSLog(@"失敗：%@",dic[@"message"]);
        if ([wTools objectExists: dic[@"message"]]) {
            [self showCustomErrorAlert: dic[@"message"]];
        } else {
            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
        }
        [self.refreshControl endRefreshing];
    } else {
        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
        [self.refreshControl endRefreshing];
    }
}

#pragma mark - JCCLayout Setup
- (void)layoutSetup {
    NSLog(@"layoutSetup");
    // ScrollView contentInset Top is navigationBar Height 64
    self.jccLayout = (JCCollectionViewWaterfallLayout *)self.collectionView.collectionViewLayout;
    NSLog(@"self.jccLayout.headerHeight: %f", self.jccLayout.headerHeight);
    
    // Social Link
    NSLog(@"socialLink: %@", self.userDic[@"sociallink"]);
    
    socialLinkInt = 0;
    
    if (![self.userDic[@"sociallink"] isKindOfClass: [NSNull class]]) {
        if ([wTools objectExists: self.userDic[@"sociallink"][@"facebook"]]) {
            if (![self.userDic[@"sociallink"][@"facebook"] isEqualToString: @""])
                socialLinkInt++;
        }
        if ([wTools objectExists: self.userDic[@"sociallink"][@"google"]]) {
            if (![self.userDic[@"sociallink"][@"google"] isEqualToString: @""])
                socialLinkInt++;
        }
        if ([wTools objectExists: self.userDic[@"sociallink"][@"instagram"]]) {
            if (![self.userDic[@"sociallink"][@"instagram"] isEqualToString: @""])
                socialLinkInt++;
        }
        if ([wTools objectExists: self.userDic[@"sociallink"][@"linkedin"]]) {
            if (![self.userDic[@"sociallink"][@"linkedin"] isEqualToString: @""])
                socialLinkInt++;
        }
        if ([wTools objectExists: self.userDic[@"sociallink"][@"pinterest"]]) {
            if (![self.userDic[@"sociallink"][@"pinterest"] isEqualToString: @""])
                socialLinkInt++;
        }
        if ([wTools objectExists: self.userDic[@"sociallink"][@"twitter"]]) {
            if (![self.userDic[@"sociallink"][@"twitter"] isEqualToString: @""])
                socialLinkInt++;
        }
        if ([wTools objectExists: self.userDic[@"sociallink"][@"web"]]) {
            if (![self.userDic[@"sociallink"][@"web"] isEqualToString: @""])
                socialLinkInt++;
        }
        if ([wTools objectExists: self.userDic[@"sociallink"][@"youtube"]]) {
            if (![self.userDic[@"sociallink"][@"youtube"] isEqualToString: @""])
                socialLinkInt++;
        }                
    }
    NSLog(@"socialLinkInt: %ld", (long)socialLinkInt);
    self.jccLayout.headerHeight = 300;
}

#pragma mark - Point Task
- (void)checkFirstTimeEditing {
    NSLog(@"checkFirstTimeEditing");
    // Check whether getting edit profile point or not
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *editProfile = [defaults objectForKey: @"editProfile"];
    NSLog(@"editProfile: %@", editProfile);
    
    if ([editProfile isEqualToString: @"FirstTimeModified"]) {
        NSLog(@"Get the First Time Eidt Profile Point Already");
        NSLog(@"show alert point view");
        [self checkPoint];
        // Save data for first edit profile
        editProfile = @"ModifiedAlready";
        [defaults setObject: editProfile
                     forKey: @"editProfile"];
        [defaults synchronize];
    }
}

- (void)checkPoint {
    NSLog(@"checkPoint");
    
    @try {
        [DGHUDView start];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSString *response = [boxAPI doTask1: [wTools getUserID] token: [wTools getUserToken] task_for: @"firsttime_edit_profile" platform: @"apple"];
        NSLog(@"User ID: %@", [wTools getUserID]);
        NSLog(@"Token: %@", [wTools getUserToken]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [DGHUDView stop];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                return;
            }
            if (response != nil) {
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"MeTabViewController");
                    NSLog(@"checkPoint");
                    
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"doTask1"
                                         albumId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    [wself processCheckPoint:data];
                }
            }
        });
    });
}

#pragma mark - Check Point Method
- (void)processCheckPoint:(NSDictionary *) data{
    if ([data[@"result"] intValue] == 1) {
        if ([wTools objectExists: data[@"data"][@"task"][@"name"]]) {
            missionTopicStr = data[@"data"][@"task"][@"name"];
            NSLog(@"name: %@", missionTopicStr);
        }
        if ([wTools objectExists: data[@"data"][@"task"][@"reward"]]) {
            rewardType = data[@"data"][@"task"][@"reward"];
            NSLog(@"reward type: %@", rewardType);
        }
        if ([wTools objectExists: data[@"data"][@"task"][@"reward_value"]]) {
            rewardValue = data[@"data"][@"task"][@"reward_value"];
            NSLog(@"reward value: %@", rewardValue);
        }
        if ([wTools objectExists: data[@"data"][@"event"][@"url"]]) {
            eventUrl = data[@"data"][@"event"][@"url"];
            NSLog(@"event: %@", eventUrl);
        }
        if ([wTools objectExists: data[@"data"][@"task"][@"restriction"]]) {
            restriction = data[@"data"][@"task"][@"restriction"];
            NSLog(@"restriction: %@", restriction);
        }
        if ([wTools objectExists: data[@"data"][@"task"][@"restriction_value"]]) {
            restrictionValue = data[@"data"][@"task"][@"restriction_value"];
            NSLog(@"restrictionValue: %@", restrictionValue);
        }
        if ([wTools objectExists: data[@"data"][@"task"][@"numberofcompleted"]]) {
            numberOfCompleted = [data[@"data"][@"task"][@"numberofcompleted"] unsignedIntegerValue];
            NSLog(@"numberOfCompleted: %lu", (unsigned long)numberOfCompleted);
        }
        [self showAlertView];
        [self getUrPoints];
    } else if ([data[@"result"] intValue] == 2) {
        NSLog(@"message: %@", data[@"message"]);
        // Save data for first edit profile
        BOOL firsttime_edit_profile = YES;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject: [NSNumber numberWithBool: firsttime_edit_profile]
                     forKey: @"firsttime_edit_profile"];
        [defaults synchronize];
    } else if ([data[@"result"] intValue] == 0) {
        if ([wTools objectExists: data[@"message"]]) {
            [self showCustomErrorAlert: data[@"message"]];
        } else {
            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
        }
    } else {
        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
    }
}

#pragma mark - Get P Point
- (void)getUrPoints {
    NSLog(@"");
    NSLog(@"getUrPoints");
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    @try {
        [DGHUDView start];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI geturpoints: [userPrefs objectForKey:@"id"]
                                           token: [userPrefs objectForKey:@"token"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [DGHUDView stop];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                return;
            }
            if (response != nil) {
                NSLog(@"response from geturpoints");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"MeTabViewController");
                    NSLog(@"getUrPoints");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"geturpoints"
                                         albumId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"dic result boolValue is 1");
                        if ([wTools objectExists: dic[@"data"]]) {
                            NSInteger point = [dic[@"data"] integerValue];
                            //NSLog(@"point: %ld", (long)point);
                            [userPrefs setObject: [NSNumber numberWithInteger: point] forKey: @"pPoint"];
                            [userPrefs synchronize];
                        }
                    } else if ([dic[@"result"] intValue] == 0) {
                        if ([wTools objectExists: dic[@"message"]]) {
                            [self showCustomErrorAlert: dic[@"message"]];
                        } else {
                            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                        }
                    } else {
                        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}

#pragma mark - Custom AlertView for Getting Point
- (void)showAlertView {
    // Custom AlertView shows up when getting the point
    alertView = [[OldCustomAlertView alloc] init];
    [alertView setContainerView: [self createPointView]];
    [alertView setButtonTitles: [NSMutableArray arrayWithObject: @"確     認"]];
    [alertView setUseMotionEffects: true];
    [alertView show];
}

- (UIView *)createPointView {
    NSLog(@"createPointView");
    UIView *pointView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 250, 250)];
    // Mission Topic Label
    UILabel *missionTopicLabel = [[UILabel alloc] initWithFrame: CGRectMake(10, 15, 200, 10)];
    //missionTopicLabel.text = @"收藏相本得點";
    
    if ([wTools objectExists: missionTopicStr]) {
        missionTopicLabel.text = missionTopicStr;
    }
    
    NSLog(@"Topic Label Text: %@", missionTopicStr);
    [pointView addSubview: missionTopicLabel];
    
    if ([wTools objectExists: restriction]) {
        if ([restriction isEqualToString: @"personal"]) {
            UILabel *restrictionLabel = [[UILabel alloc] initWithFrame: CGRectMake(10, 45, 200, 10)];
            restrictionLabel.textColor = [UIColor firstGrey];
            restrictionLabel.text = [NSString stringWithFormat: @"次數：%lu / %@", (unsigned long)numberOfCompleted, restrictionValue];
            NSLog(@"restrictionLabel.text: %@", restrictionLabel.text);
            [pointView addSubview: restrictionLabel];
        }
    }
    
    // Gift Image
    UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(50, 90, 100, 100)];
    imageView.image = [UIImage imageNamed: @"icon_present"];
    [pointView addSubview: imageView];
    
    // Message Label
    UILabel *messageLabel = [[UILabel alloc] initWithFrame: CGRectMake(10, 200, 200, 10)];
    
    NSString *congratulate = @"恭喜您獲得 ";
    //NSString *number = @"1 ";
    
    NSLog(@"Reward Value: %@", rewardValue);
    NSString *end = @"P!";
    
    /*
     if ([rewardType isEqualToString: @"point"]) {
     congratulate = @"恭喜您獲得 ";
     number = @"5 ";
     // number = rewardValue;
     end = @"P!";
     }
     */
    
    if ([wTools objectExists: rewardValue]) {
        messageLabel.text = [NSString stringWithFormat: @"%@%@%@", congratulate, rewardValue, end];
    }
    [pointView addSubview: messageLabel];
    
    if ([eventUrl isEqual: [NSNull null]] || eventUrl == nil) {
        NSLog(@"eventUrl is equal to null or eventUrl is nil");
    } else {
        // Activity Button
        UIButton *activityButton = [UIButton buttonWithType: UIButtonTypeCustom];
        [activityButton addTarget: self action: @selector(showTheActivityPage) forControlEvents: UIControlEventTouchUpInside];
        activityButton.frame = CGRectMake(150, 220, 100, 10);
        [activityButton setTitle: @"活動連結" forState: UIControlStateNormal];
        [activityButton setTitleColor: [UIColor colorWithRed: 26.0/255.0
                                                       green: 196.0/255.0
                                                        blue: 199.0/255.0
                                                       alpha: 1.0]
                             forState: UIControlStateNormal];
        [pointView addSubview: activityButton];
    }
    return pointView;
}

- (void)showTheActivityPage {
    NSLog(@"showTheActivityPage");
    //NSString *activityLink = @"http://www.apple.com";
    if (![wTools objectExists: eventUrl]) {
        return;
    }
    NSString *activityLink = eventUrl;
    NSURL *url = [NSURL URLWithString: activityLink];
    // Close for present safari view controller, otherwise alertView will hide the background
    [alertView close];
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: url entersReaderIfAvailable: NO];
    safariVC.delegate = self;
    safariVC.preferredBarTintColor = [UIColor whiteColor];
    [self presentViewController: safariVC animated: YES completion: nil];
}

#pragma mark - SFSafariViewController delegate methods
- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    // Done button pressed
    NSLog(@"show");
    [alertView show];
}

#pragma mark - Helper Method
- (CGFloat)coverImageHeightCalculation {
    CGFloat height = (self.collectionView.frame.size.width * 450) / 960;
    return height;
}

- (CGFloat)headerHeightCalculation {
    CGFloat headerHeight = 0;
    headerHeight += coverImageHeight + 32 + 96;
    
//    if (![self.userDic[@"creative_name"] isEqual: [NSNull null]]) {
//        NSLog(@"creative_name: %@", self.userDic[@"creative_name"]);
//        headerHeight += creativeNameLabelHeight + 32;
//    }
    
    if (![self.userDic[@"name"] isEqual: [NSNull null]]) {
        if (![self.userDic[@"name"] isEqualToString: @""]) {
            headerHeight += userNameLabelHeight + 16 + 32;
        }
    }
    
    if (![self.userDic[@"sociallink"] isEqual: [NSNull null]]) {
        if (socialLinkInt != 0) {
            NSLog(@"socialLinkInt: %ld", (long)socialLinkInt);
            headerHeight += 61.5;
        }
    }
    // linkBgView
//    headerHeight += 32;
    
    if (![self.userDic[@"sociallink"] isEqual: [NSNull null]]) {
        if (socialLinkInt != 0) {
            NSLog(@"socialLinkInt: %ld", (long)socialLinkInt);
            headerHeight += 32;
        } else if (socialLinkInt == 0) {
            NSLog(@"socialLinkInt: %ld", (long)socialLinkInt);
        }
    } else {
        NSLog(@"self.userDic socialLink: %@", self.userDic[@"sociallink"]);
    }
    
    // 32: Gap between horziontal line and 作品集
    // 26.5: Height of 作品集 Label
    // 16: Gap between 作品集 and the bottom of HeaderView
    
//    headerHeight += 1 + 32 + 26.5 + 16;
    headerHeight += 1 + 26.5 + 16;
    
    // Add 20 for banner doesn't look to be compressed
//    headerHeight += 20;
    return headerHeight;
}

- (NSString *)numberConversion: (NSInteger)number {
    NSLog(@"number: %ld", (long)number);
    NSString *numberStr;
    
    if (number >= 1000000) {
        number = number / 1000000;
        numberStr = [NSString stringWithFormat: @"%ldM", (long)number];
    } else if (number >= 1000) {
        number = number / 1000;
        numberStr = [NSString stringWithFormat: @"%ldK", (long)number];
    } else {
        numberStr = [NSString stringWithFormat: @"%ld", (long)number];
    }
    NSLog(@"numberStr: %@", numberStr);
    return numberStr;
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSLog(@"numberOfSectionsInCollectionView");
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    NSLog(@"numberOfItemsInSection");
    NSLog(@"pictures.count: %lu", (unsigned long)pictures.count);
    return pictures.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"viewForSupplementaryElementOfKind");
    NSLog(@"self.userDic: %@", self.userDic);
    MeCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind: kind withReuseIdentifier: @"headerId" forIndexPath: indexPath];
    [LabelAttributeStyle changeGapStringAndLineSpacingCenterAlignment: headerView.viewedLabel content: headerView.viewedLabel.text];
    [LabelAttributeStyle changeGapStringAndLineSpacingCenterAlignment: headerView.likeLabel content: headerView.likeLabel.text];
    [LabelAttributeStyle changeGapStringAndLineSpacingCenterAlignment: headerView.sponsoredLabel content: headerView.sponsoredLabel.text];
    
    headerView.customBlock = ^(BOOL selected, NSInteger tag) {
        if (tag == 102) {
            NSLog(@"tag == 102");
            NSLog(@"To FollowFromListViewController");
            FollowFromListViewController *followFromListVC = [[UIStoryboard storyboardWithName: @"FollowFromListVC" bundle: nil] instantiateViewControllerWithIdentifier: @"FollowFromListViewController"];
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate.myNav pushViewController: followFromListVC animated: YES];
        }
        if (tag == 103) {
            NSLog(@"tag == 103");
            NSLog(@"To SponsorListViewController");
            SponsorListViewController *sponsorListVC = [[UIStoryboard storyboardWithName: @"SponsorListVC" bundle: nil] instantiateViewControllerWithIdentifier: @"SponsorListViewController"];            
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate.myNav pushViewController: sponsorListVC animated: YES];
        }
    };
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: headerView.albumCollectionLabel content: headerView.albumCollectionLabel.text];
    
    // Cover Image
    if ([self.userDic[@"cover"] isEqual: [NSNull null]]) {
        NSLog(@"cover is null");
        headerView.coverImageView.image = [UIImage imageNamed: @"bg200_user_default"];
    } else {
        NSLog(@"cocer is not null");
//        [headerView.coverImageView sd_setImageWithURL: [NSURL URLWithString: self.userDic[@"cover"]]];
        [headerView.coverImageView sd_setImageWithURL: [NSURL URLWithString: self.userDic[@"cover"]]
                                     placeholderImage: [UIImage imageNamed: @"bg200_user_default"]];
    }
//    headerView.coverImageHeightConstraint.constant = [self coverImageHeightCalculation];
//    coverImageHeight = headerView.coverImageHeightConstraint.constant;
    headerView.coverImageBgVHeightConstraint.constant = [self coverImageHeightCalculation];
    coverImageHeight = headerView.coverImageBgVHeightConstraint.constant;
    
    if (headerView.gradientView.layer.sublayers.count > 0) {
        for (CALayer *layer in headerView.gradientView.layer.sublayers) {
            [layer removeFromSuperlayer];
        }
    }
    // Graident Effect for Gradient View
    CAGradientLayer *gradientLayer;
    gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, coverImageHeight);
    gradientLayer.colors = @[(id)[UIColor colorFromHexString: @"#32000000"].CGColor, (id)[UIColor colorFromHexString: @"#000000"].CGColor];
    [headerView.gradientView.layer insertSublayer: gradientLayer atIndex: 0];
    headerView.gradientView.alpha = 0.5;
    
    NSLog(@"headerView.gradientView.layer.sublayers: %@", headerView.gradientView.layer.sublayers);
    
    // User Picture ImageView
    headerView.userPictureImageView.backgroundColor = [UIColor thirdGrey];
    NSString *profilePic = [wTools stringisnull: self.userDic[@"picture"]];
    NSLog(@"profilePic: %@", profilePic);
    NSLog(@"profilePicUrlString: %@", profilePicUrlString);
    
    if (profilePicUrlString != nil) {
        NSLog(@"profilePicUrlString is not null");
        if (![profilePicUrlString isEqualToString: @""]) {
            if (![profilePicUrlString isEqualToString: profilePic]) {
                profilePic = profilePicUrlString;
            }
        }
    }
    
    if (profilePic != nil) {
        NSLog(@"profilePic is not NSNull class");
        if (![profilePic isEqualToString: @""]) {
            [headerView.userPictureImageView sd_setImageWithURL: [NSURL URLWithString: profilePic]];
        } else {
            headerView.userPictureImageView.image = [UIImage imageNamed: @"member_back_head.png"];
        }
    }
    // User Name Label
    if (![self.userDic[@"name"] isEqual: [NSNull null]]) {
        headerView.userNameLabel.text = self.userDic[@"name"];
        NSLog(@"headerView.userNameLabel.text: %@", headerView.userNameLabel.text);
        [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: headerView.userNameLabel content: headerView.userNameLabel.text];
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        style.lineBreakMode = NSLineBreakByWordWrapping;
        style.alignment = NSTextAlignmentLeft;
        NSAttributedString *string = [[NSAttributedString alloc] initWithString: headerView.userNameLabel.text attributes: @{NSFontAttributeName:[UIFont boldSystemFontOfSize: 42.0], NSParagraphStyleAttributeName:style}];
        CGSize userNameLabelSize = [string boundingRectWithSize: CGSizeMake([UIScreen mainScreen].bounds.size.width - 32 * 2, MAXFLOAT) options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context: nil].size;
        NSLog(@"userNameLabelSize.height: %f", userNameLabelSize.height);
        
        // + 10 in order to show real headerView.userNameLabelHeight
        headerView.userNameLabelHeight.constant = userNameLabelSize.height + 10;
        userNameLabelHeight = userNameLabelSize.height + 10;
    }
    // Creative Name Label
    if (![self.userDic[@"creative_name"] isEqual: [NSNull null]]) {
        headerView.creativeNameLabel.text = self.userDic[@"creative_name"];
        [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: headerView.creativeNameLabel content: headerView.creativeNameLabel.text];
        if ([self.userDic[@"creative_name"] isEqualToString: @""]) {
            headerView.gradientView.hidden = YES;
        } else {
            headerView.gradientView.hidden = NO;
        }
    } else {
        headerView.gradientView.hidden = YES;
    }
    
    // Number Section
    if (![self.userDic[@"viewed"] isEqual: [NSNull null]]) {
        headerView.viewedNumberLabel.text = [self numberConversion: [self.userDic[@"viewed"] integerValue]];
        [LabelAttributeStyle changeGapStringAndLineSpacingCenterAlignment: headerView.viewedNumberLabel content: headerView.viewedNumberLabel.text];
    }
    if (![followDic[@"count_from"] isEqual: [NSNull null]]) {
        headerView.likeNumberLabel.text = [self numberConversion: [followDic[@"count_from"] integerValue]];
        [LabelAttributeStyle changeGapStringAndLineSpacingCenterAlignment: headerView.likeNumberLabel content: headerView.likeNumberLabel.text];
    }
    if (![sponsorDic[@"besponsored"] isEqual: [NSNull null]]) {
        headerView.sponsoredNumberLabel.text = [self numberConversion: [sponsorDic[@"besponsored"] integerValue]];
        [LabelAttributeStyle changeGapStringAndLineSpacingCenterAlignment: headerView.sponsoredNumberLabel content: headerView.sponsoredNumberLabel.text];
    }
    
    // Link Section
    NSString *linkLabelStr;
    NSLog(@"check socialLinkInt: %ld", (long)socialLinkInt);
    
    if (![self.userDic[@"sociallink"] isEqual: [NSNull null]]) {
        if (socialLinkInt != 0) {
            // linkBgView has to set up first, otherwise the subViews element can't show up
            // because there is no container
            headerView.linkLabel.hidden = NO;
            headerView.linkBgView.hidden = NO;
            headerView.linkBgViewHeight.constant = 61.5;
            headerView.linkBgViewBottomConstraint.constant = 32;
            
            NSLog(@"socialLinkInt: %ld", (long)socialLinkInt);
            
            linkLabelStr = [NSString stringWithFormat: @"連結"];
            headerView.linkLabel.text = linkLabelStr;
            [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: headerView.linkLabel content: headerView.linkLabel.text];
            
            if ([wTools objectExists: self.userDic[@"sociallink"][@"facebook"]]) {
                if ([self.userDic[@"sociallink"][@"facebook"] isEqualToString: @""]) {
                    headerView.fbBtn.hidden = YES;
                } else {
                    headerView.fbBtn.hidden = NO;
                }
            }
            if ([wTools objectExists: self.userDic[@"sociallink"][@"google"]]) {
                if ([self.userDic[@"sociallink"][@"google"] isEqualToString: @""]) {
                    headerView.googlePlusBtn.hidden = YES;
                } else {
                    headerView.googlePlusBtn.hidden = NO;
                }
            }
            if ([wTools objectExists: self.userDic[@"sociallink"][@"instagram"]]) {
                if ([self.userDic[@"sociallink"][@"instagram"] isEqualToString: @""]) {
                    headerView.igBtn.hidden = YES;
                } else {
                    headerView.igBtn.hidden = NO;
                }
            }
            if ([wTools objectExists: self.userDic[@"sociallink"][@"linkedin"]]) {
                if ([self.userDic[@"sociallink"][@"linkedin"] isEqualToString: @""]) {
                    headerView.linkedInBtn.hidden = YES;
                } else {
                    headerView.linkedInBtn.hidden = NO;
                }
            }
            if ([wTools objectExists: self.userDic[@"sociallink"][@"pinterest"]]) {
                if ([self.userDic[@"sociallink"][@"pinterest"] isEqualToString: @""]) {
                    headerView.pinterestBtn.hidden = YES;
                } else {
                    headerView.pinterestBtn.hidden = NO;
                }
            }
            if ([wTools objectExists: self.userDic[@"sociallink"][@"twitter"]]) {
                if ([self.userDic[@"sociallink"][@"twitter"] isEqualToString: @""]) {
                    headerView.twitterBtn.hidden = YES;
                } else {
                    headerView.twitterBtn.hidden = NO;
                }
            }
            if ([wTools objectExists: self.userDic[@"sociallink"][@"web"]]) {
                if ([self.userDic[@"sociallink"][@"web"] isEqualToString: @""]) {
                    headerView.webBtn.hidden = YES;
                } else {
                    headerView.webBtn.hidden = NO;
                }
            }
            if ([wTools objectExists: self.userDic[@"sociallink"][@"youtube"]]) {
                if ([self.userDic[@"sociallink"][@"youtube"] isEqualToString: @""]) {
                    headerView.youtubeBtn.hidden = YES;
                } else {
                    headerView.youtubeBtn.hidden = NO;
                }
            }
        } else if (socialLinkInt == 0) {
            NSLog(@"socialLinkInt: %ld", (long)socialLinkInt);
            headerView.linkLabel.hidden = YES;
            headerView.linkBgView.hidden = YES;
            headerView.linkBgViewHeight.constant = 0;
            headerView.linkBgViewBottomConstraint.constant = 0;
        }
    } else {
        NSLog(@"self.userDic socialLink: %@", self.userDic[@"sociallink"]);
        headerView.linkLabel.hidden = YES;
        headerView.linkBgView.hidden = YES;
        headerView.linkBgViewHeight.constant = 0;
        headerView.linkBgViewBottomConstraint.constant = 0;
    }
    linkBgViewHeight = headerView.linkBgView.frame.size.height;
    NSLog(@"linkBgViewHeight: %f", linkBgViewHeight);
    NSLog(@"headerView.linkBgView.frame: %@", NSStringFromCGRect(headerView.linkBgView.frame));
    
    if ([wTools objectExists: self.userDic]) {
        NSLog(@"self.userDic object exists");
        self.jccLayout.headerHeight = [self headerHeightCalculation];
        NSLog(@"self.jccLayout.headerHeight: %f", self.jccLayout.headerHeight);
    }
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    return headerView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForItemAtIndexPath");
    MeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"MyInfo" forIndexPath: indexPath];
    cell.contentView.subviews[0].backgroundColor = nil;
    NSDictionary *data = pictures[indexPath.row];
    NSLog(@"data: %@", data);
    if ([data[@"cover"] isEqual: [NSNull null]]) {
        cell.coverImageView.image = [UIImage imageNamed: @"bg_2_0_0_no_image"];
    } else {
        //[cell.coverImageView sd_setImageWithURL: [NSURL URLWithString: data[@"cover"]] placeholderImage:[UIImage imageNamed: @"bg_2_0_0_no_image"]];
        [cell.coverImageView sd_setImageWithURL: [NSURL URLWithString: data[@"cover"]]];
        /*
        [cell.coverImageView sd_setImageWithURL:[NSURL URLWithString: data[@"cover"]] placeholderImage:[UIImage imageNamed:@"bg_2_0_0_no_image"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (error) {
                cell.coverImageView.image = [UIImage imageNamed: @"bg_2_0_0_no_image"] ;
            } else
                cell.coverImageView.image = image;
        }];
         */
        
    }
    // UserForView Info Setting
    BOOL gotAudio = [data[@"usefor"][@"audio"] boolValue];
    BOOL gotVideo = [data[@"usefor"][@"video"] boolValue];
    BOOL gotExchange = [data[@"usefor"][@"exchange"] boolValue];
    BOOL gotSlot = [data[@"usefor"][@"slot"] boolValue];
    
    [cell.btn1 setImage: nil forState: UIControlStateNormal];
    [cell.btn2 setImage: nil forState: UIControlStateNormal];
    [cell.btn3 setImage: nil forState: UIControlStateNormal];
    
    cell.userInfoView.hidden = YES;
    
    if (gotAudio) {
        cell.userInfoView.hidden = NO;
        [cell.btn3 setImage: [UIImage imageNamed: @"ic200_audio_play_dark"] forState: UIControlStateNormal];
        
        CGRect rect = cell.userInfoView.frame;
        rect.size.width = kIconForInfoViewWidth * 1 + 6;
        cell.userInfoView.frame = rect;
        
        if (gotVideo) {
            [cell.btn3 setImage: [UIImage imageNamed: @"ic200_video_dark"] forState: UIControlStateNormal];
            [cell.btn2 setImage: [UIImage imageNamed: @"ic200_audio_play_dark"] forState: UIControlStateNormal];
            
            CGRect rect = cell.userInfoView.frame;
            rect.size.width = kIconForInfoViewWidth * 2 + 12;
            cell.userInfoView.frame = rect;
            
            if (gotExchange || gotSlot) {
                [cell.btn1 setImage: [UIImage imageNamed: @"ic200_audio_play_dark"] forState: UIControlStateNormal];
                [cell.btn2 setImage: [UIImage imageNamed: @"ic200_video_dark"] forState: UIControlStateNormal];
                [cell.btn3 setImage: [UIImage imageNamed: @"ic200_gift_dark"] forState: UIControlStateNormal];
                
                CGRect rect = cell.userInfoView.frame;
                rect.size.width = kIconForInfoViewWidth * 3 + 18;
                cell.userInfoView.frame = rect;
            }
        }
    } else if (gotVideo) {
        NSLog(@"gotVideo");
        cell.userInfoView.hidden = NO;
        [cell.btn3 setImage: [UIImage imageNamed: @"ic200_video_dark"] forState: UIControlStateNormal];
        
        CGRect rect = cell.userInfoView.frame;
        rect.size.width = kIconForInfoViewWidth * 1 + 6;
        cell.userInfoView.frame = rect;
        
        if (gotExchange || gotSlot) {
            NSLog(@"gotVideo");
            NSLog(@"gotExchange or gotSlot");
            [cell.btn3 setImage: [UIImage imageNamed: @"ic200_gift_dark"] forState: UIControlStateNormal];
            [cell.btn2 setImage: [UIImage imageNamed: @"ic200_video_dark"] forState: UIControlStateNormal];
            
            CGRect rect = cell.userInfoView.frame;
            rect.size.width = kIconForInfoViewWidth * 2 + 12;
            cell.userInfoView.frame = rect;
        }
    } else if (gotExchange || gotSlot) {
        NSLog(@"gotExchange or gotSlot");
        cell.userInfoView.hidden = NO;
        [cell.btn3 setImage: [UIImage imageNamed: @"ic200_gift_dark"] forState: UIControlStateNormal];
        
        CGRect rect = cell.userInfoView.frame;
        rect.size.width = kIconForInfoViewWidth * 1 + 6;
        cell.userInfoView.frame = rect;
    }
    
    // AlbumNameLabel Setting
    if (![data[@"name"] isEqual: [NSNull null]]) {
        cell.albumNameLabel.text = data[@"name"];
        [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: cell.albumNameLabel content: cell.albumNameLabel.text];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate Methods

- (BOOL)collectionView:(UICollectionView *)collectionView
shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath: indexPath];
    NSLog(@"cell.contentView.subviews: %@", cell.contentView.subviews);
//    cell.contentView.subviews[0].backgroundColor = [UIColor thirdMain];
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MeCollectionViewCell *cell = (MeCollectionViewCell *) [collectionView cellForItemAtIndexPath: indexPath];
    
    NSString *albumId = [pictures[indexPath.row][@"album_id"] stringValue];
    CGRect source = [collectionView convertRect:cell.coverImageView.frame fromView:cell];
    source = [self.view convertRect:source fromView:collectionView];
    
    YAlbumDetailContainerViewController *aDVC = [YAlbumDetailContainerViewController albumDetailVCWithAlbumID:albumId sourceRect:source sourceImageView:cell.coverImageView noParam:YES];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: aDVC animated: YES];
    //[self ToRetrievealbumpViewControlleralbumid: albumId];
}

- (void)collectionView:(UICollectionView *)collectionView
didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
//    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath: indexPath];
    //cell.contentView.backgroundColor = nil;
    //cell.contentView.subviews[0].backgroundColor = nil;
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"");
//    NSLog(@"sizeForItemAtIndexPath");
    CGFloat itemWidth = roundf((self.view.frame.size.width - (miniInteriorSpacing * (columnCount + 1))) / columnCount);
    NSDictionary *data = pictures[indexPath.row];
    // Check Width & Height return value is nil or not
    NSNumber *coverWidth = data[@"cover_width"];
    NSNumber *coverHeight = data[@"cover_height"];
    NSInteger resultWidth;
    NSInteger resultHeight;
    
    if ([coverWidth isEqual: [NSNull null]]) {
        resultWidth = (self.view.bounds.size.width - 48) / 2;
    } else {
        resultWidth = [coverWidth integerValue];
    }
    if ([coverHeight isEqual: [NSNull null]]) {
        resultHeight = resultWidth;
    } else {
        resultHeight = [coverHeight integerValue];
    }
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat widthForCoverImg = (self.view.bounds.size.width - 48) / 2;
    CGFloat heightForCoverImg = (resultHeight * widthForCoverImg) / resultWidth;
    
    if (heightForCoverImg < (36 * scale)) {
        heightForCoverImg = 36 * scale;
    }
    CGSize finalSize = CGSizeMake(widthForCoverImg, heightForCoverImg);
    finalSize = CGSizeMake(itemWidth, floorf(finalSize.height * itemWidth / finalSize.width));
    NSString *albumNameStr;
    
    if (![data[@"name"] isEqual: [NSNull null]]) {
        albumNameStr = data[@"name"];
    }
    finalSize = CGSizeMake(finalSize.width, finalSize.height + [self calculateHeightForLbl: albumNameStr width: itemWidth - 16]);
    //NSLog(@"size :%@",NSStringFromCGSize(finalSize));
    return finalSize;
}

- (float)calculateHeightForLbl:(NSString *)text
                         width:(float)width {
    CGSize constraint = CGSizeMake(width,20000.0f);
    CGSize size;
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [text boundingRectWithSize:constraint
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}
                                            context:context].size;
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    return size.height + 16;
}

// Horizontal Cell Spacing
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    NSLog(@"minimumInteritemSpacingForSectionAtIndex");
    return 16.0f;
}

// Vertical Cell Spacing
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    NSLog(@"minimumLineSpacingForSectionAtIndex");
    return 24.0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    UIEdgeInsets itemInset = UIEdgeInsetsMake(0, 16, 0, 16);
    return itemInset;
}

#pragma mark - JCCollectionViewWaterfallLayoutDelegate
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
 heightForHeaderInSection:(NSInteger)section {
    NSLog(@"heightForHeaderInSection");
    NSLog(@"self.jccLayout.headerHeight: %f", self.jccLayout.headerHeight);
    return self.jccLayout.headerHeight;
}

#pragma mark - UIScrollViewDelegate Methods
- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"willDisplayCell");
//    NSLog(@"indexPath.item: %ld", (long)indexPath.item);
//    NSLog(@"pictures.count: %lu", (unsigned long)pictures.count);
    
    if (indexPath.item == (pictures.count - 1)) {
        //[self loadData];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"scrollViewDidScroll");
    
    if (!isLoading) {
        CGFloat bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        
        if (bottomEdge > scrollView.contentSize.height) {
            NSLog(@"We are at the bottom");
            [self loadData];
        }
    }
    
//    if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.frame.size.height) {
//        NSLog(@"reached the bottom");
//        [self loadData];
//    }
    
//    CGFloat height = scrollView.frame.size.height;
//    NSLog(@"height: %f", height);
//
//    CGFloat contentYoffset = scrollView.contentOffset.y;
//    NSLog(@"contentYoffset: %f", contentYoffset);
//
//    CGFloat distanceFromBottom = scrollView.contentSize.height - contentYoffset;
//    NSLog(@"distanceFromBottom: %f", distanceFromBottom);
//
//    if (distanceFromBottom < height) {
//        NSLog(@"you reached end");
//    }
    
    // getting the scroll offset
//    NSLog(@"bottomEdge: %f", bottomEdge);
//    NSLog(@"scrollView.contentSize.height: %f", scrollView.contentSize.height);
//
//    NSLog(@"isLoading: %d", isLoading);
}

- (IBAction)changeBannerBtnPressed:(id)sender {
    NSLog(@"changeBannerBtnPressed");
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.sourceType = sourceType;
    imagePicker.delegate = self;
    [self presentViewController: imagePicker animated: YES completion: nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *toCropImage = info[UIImagePickerControllerOriginalImage];
    [self cropImage: toCropImage];
    [picker dismissViewControllerAnimated: YES completion: nil];
}

- (void)cropImage: (UIImage *)image {
    CropImageViewController *cropImageViewController = [[CropImageViewController alloc] initWithNibName: @"CropImageViewController" bundle: nil];
    cropImageViewController.image = image;
    cropImageViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController: cropImageViewController animated: YES];
}

#pragma mark - IBAction Methods
- (IBAction)messageBtnPressed:(id)sender {
    [wTools setStatusBarBackgroundColor: [UIColor clearColor]];
    self.customMessageActionSheet.topicStr = @"留言板";
    self.customMessageActionSheet.type = @"user";
    self.customMessageActionSheet.typeId = [wTools getUserID];
    self.customMessageActionSheet.userName = @"";
    
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleDark];
    [UIView animateWithDuration: kAnimateActionSheet animations:^{
        self.effectView = [[UIVisualEffectView alloc] initWithEffect: blurEffect];
    }];
    
    self.effectView.frame = self.view.frame;
    self.effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.effectView.myLeftMargin = self.effectView.myRightMargin = 0;
    self.effectView.myTopMargin = self.effectView.myBottomMargin = 0;
    self.effectView.alpha = 0.9;
    
    // Call customMessageActionSheet methods first
    [self.customMessageActionSheet initialValueSetup];
    [self.customMessageActionSheet getMessage];
}

#pragma mark - MessageBoardViewControllerDelegate Methods
- (void)gotMessageData {
    NSLog(@"gotMessageData");
    // CustomActionSheet Setting
    // Below method will call viewDidLoad
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window addSubview: self.effectView];
    [appDelegate.window addSubview: self.customMessageActionSheet.view];
}

- (IBAction)myPageBtnPressed:(id)sender {
    if ([wTools objectExists: [wTools getUserID]]) {
        NSString *pageStr = [NSString stringWithFormat: @"index/creative/content/?user_id=%@&appview=true", [wTools getUserID]];
        NSString *urlString = [NSString stringWithFormat: @"%@%@", pinpinbox, pageStr];
        NSURL *url = [NSURL URLWithString: urlString];
        SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: url entersReaderIfAvailable: NO];
        safariVC.preferredBarTintColor = [UIColor whiteColor];
        [self presentViewController: safariVC animated: YES completion: nil];
    }
}

- (IBAction)pointCalculationBtnPressed:(id)sender {
    PointCalculationViewController *pointCVC = [[UIStoryboard storyboardWithName: @"PointCalculationVC" bundle: nil] instantiateViewControllerWithIdentifier: @"PointCalculationViewController"];
    pointCVC.sum = self.sum;
    pointCVC.sumOfSettlement = self.sumOfSettlement;
    pointCVC.sumOfUnsettlement = self.sumOfUnsettlement;
    pointCVC.identity = self.identity;
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: pointCVC animated: YES];
}

- (IBAction)shareBtnPress:(id)sender {
    NSLog(@"shareBtnPress");
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:[NSArray arrayWithObjects: [NSString stringWithFormat: userIdSharingLink, [wTools getUserID], autoPlayStr], nil] applicationActivities:nil];
    [self presentViewController: activityVC animated: YES completion: nil];
}

- (IBAction)linkBtnPress:(UIButton *)sender {
    NSLog(@"linkBtnPress");
    NSLog(@"sender.tag: %ld", (long)sender.tag);
    NSString *socialLink;
    
    if (sender.tag == 1)
        socialLink = self.userDic[@"sociallink"][@"facebook"];
    if (sender.tag == 2)
        socialLink = self.userDic[@"sociallink"][@"google"];
    if (sender.tag == 3)
        socialLink = self.userDic[@"sociallink"][@"instagram"];
    if (sender.tag == 4)
        socialLink = self.userDic[@"sociallink"][@"linkedin"];
    if (sender.tag == 5)
        socialLink = self.userDic[@"sociallink"][@"pinterest"];
    if (sender.tag == 6)
        socialLink = self.userDic[@"sociallink"][@"twitter"];
    if (sender.tag == 7)
        socialLink = self.userDic[@"sociallink"][@"web"];
    if (sender.tag == 8)
        socialLink = self.userDic[@"sociallink"][@"youtube"];
    
    NSLog(@"socialLink: %@", socialLink);
    
    if (![socialLink isEqual: [NSNull null]]) {
        if (![socialLink isEqualToString: @""]) {            
            if ([socialLink containsString: @"http://"] || [socialLink containsString: @"https://"]) {
                NSURL *url = [NSURL URLWithString: socialLink];
                SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: url entersReaderIfAvailable: NO];
                safariVC.preferredBarTintColor = [UIColor whiteColor];
                [self presentViewController: safariVC animated: YES completion: nil];
            } else {
                NSLog(@"socialLink: %@", socialLink);
                CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                style.messageColor = [UIColor whiteColor];
                style.backgroundColor = [UIColor thirdPink];
                
                [self.view makeToast: NSLocalizedString(@"ProfileText-validateSocialLink", @"")
                            duration: 2.0
                            position: CSToastPositionBottom
                               style: style];
            }
        } else {
            NSLog(@"socialLink is equalTostring empty");
        }
    } else {
        NSLog(@"socialLink is null");
    }
}

- (IBAction)showActionSheet:(id)sender {
    NSLog(@"showActionSheet");
    [wTools setStatusBarBackgroundColor: [UIColor clearColor]];
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleDark];
    [UIView animateWithDuration: kAnimateActionSheet animations:^{
        self.effectView = [[UIVisualEffectView alloc] initWithEffect: blurEffect];
    }];
    self.effectView.frame = self.view.frame;
    self.effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.effectView.myLeftMargin = self.effectView.myRightMargin = 0;
    self.effectView.myTopMargin = self.effectView.myBottomMargin = 0;
    self.effectView.alpha = 0.8;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window addSubview: self.effectView];
    [appDelegate.window addSubview: self.customActionSheet.view];
    
//    [self.view addSubview: self.effectView];
//    [self.view addSubview: self.customActionSheet.view];
    [self.customActionSheet viewWillAppear: NO];
    
//    [self.customActionSheet addSelectItem: @"ic200_chart_dark" title: @"積分統計" btnStr: @"" tagInt: 1 identifierStr: @"pointCalculation"];
    
    [self.customActionSheet addSelectItem: @"ic200_edit_dark" title: @"編輯資訊" btnStr: @"" tagInt: 1 identifierStr: @"infoEdit"];
    [self.customActionSheet addSelectItem: @"ic200_manage_dark" title: @"作品管理" btnStr: @"" tagInt: 2 identifierStr: @"albumManagement"];
    [self.customActionSheet addSelectItem: @"ic200_myattention_dark" title: @"關注清單" btnStr: @"" tagInt: 3 identifierStr: @"followList"];
    [self.customActionSheet addSelectItem: @"ic200_recent_dark" title: @"最近瀏覽" btnStr: @"" tagInt: 4 identifierStr: @"recentBrowsing"];
    [self.customActionSheet addSelectItem: @"ic200_buypoint_dark" title: @"購買P點" btnStr: @"" tagInt: 5 identifierStr: @"buyPPoint"];
    [self.customActionSheet addSelectItem: @"ic200_gift_dark" title: @"兌換清單" btnStr: @"" tagInt: 6 identifierStr: @"exchangeList"];
    [self.customActionSheet addSelectItem: @"ic200_setting_dark" title: @"設定" btnStr: @"" tagInt: 71 identifierStr: @"setting"];
    
    [self.customActionSheet addSafeArea];
    __weak typeof(self) weakSelf = self;
        
    self.customActionSheet.customViewBlock = ^(NSInteger tagId, BOOL isTouchDown, NSString *identifierStr) {
        NSLog(@"self.customActionSheet.customViewBlock");
        NSLog(@"tagId: %ld", (long)tagId);
        NSLog(@"isTouchDown: %d", isTouchDown);
        NSLog(@"identifierStr: %@", identifierStr);
        
        if ([identifierStr isEqualToString: @"infoEdit"]) {
            InfoEditViewController *infoEditVC = [[UIStoryboard storyboardWithName: @"InfoEditVC" bundle: [NSBundle mainBundle]] instantiateViewControllerWithIdentifier: @"InfoEditViewController"];
            infoEditVC.delegate = weakSelf;
            infoEditVC.userDic = weakSelf.userDic;
            
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate.myNav pushViewController: infoEditVC animated: YES];
        } else if ([identifierStr isEqualToString: @"albumManagement"]) {
            NSLog(@"albumManagementButtonPress");
            AlbumCollectionViewController *albumCollectionVC = [[UIStoryboard storyboardWithName: @"AlbumCollectionVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumCollectionViewController"];
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [app.myNav pushViewController: albumCollectionVC animated: YES];
        } else if ([identifierStr isEqualToString: @"followList"]) {
            FollowListsViewController *followListVC = [[UIStoryboard storyboardWithName: @"FollowListsVC" bundle: nil] instantiateViewControllerWithIdentifier: @"FollowListsViewController"];
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate.myNav pushViewController: followListVC animated: YES];
        } else if ([identifierStr isEqualToString: @"recentBrowsing"]) {
            //RecentBrowsingViewController *rbVC = [[UIStoryboard storyboardWithName: @"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"RecentBrowsingViewController"];
            RecentBrowsingViewController *rbVC = [[UIStoryboard storyboardWithName: @"RecentBrowsingVC" bundle: nil] instantiateViewControllerWithIdentifier: @"RecentBrowsingViewController"];
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate.myNav pushViewController: rbVC animated: YES];
        } else if ([identifierStr isEqualToString: @"buyPPoint"]) {
            BuyPPointViewController *buyPPVC = [[UIStoryboard storyboardWithName: @"BuyPointVC" bundle: nil] instantiateViewControllerWithIdentifier: @"BuyPPointViewController"];
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate.myNav pushViewController: buyPPVC animated: YES];
        } else if ([identifierStr isEqualToString: @"exchangeList"]) {
            ExchangeListViewController *exchangeListVC = [[UIStoryboard storyboardWithName: @"ExchangeListVC" bundle: nil] instantiateViewControllerWithIdentifier: @"ExchangeListViewController"];
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate.myNav pushViewController: exchangeListVC animated: YES];
        } else if ([identifierStr isEqualToString: @"setting"]) {
            //SettingViewController *settingVC = [[UIStoryboard storyboardWithName: @"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"SettingViewController"];
            SettingViewController *settingVC = [[UIStoryboard storyboardWithName: @"SettingVC" bundle: nil] instantiateViewControllerWithIdentifier: @"SettingViewController"];
            //[self.navigationController pushViewController: settingVC animated: YES];
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate.myNav pushViewController: settingVC animated: YES];
        }
    };
}

#pragma mark - DDAUIActionSheetViewController Method
- (void)actionSheetViewDidSlideOut:(DDAUIActionSheetViewController *)controller {
    NSLog(@"actionSheetViewDidSlideOut");
    [wTools setStatusBarBackgroundColor: [UIColor whiteColor]];
    [self.effectView removeFromSuperview];
    self.effectView = nil;        
}

//#pragma mark - Status Background Color Setting
//- (void)setStatusBarBackgroundColor:(UIColor *)color {
//    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey: @"statusBarWindow"] valueForKey: @"statusBar"];
//
//    if ([statusBar respondsToSelector: @selector(setBackgroundColor:)]) {
//        statusBar.backgroundColor = color;
//    }
//}

#pragma mark - Call Protocol
#pragma mark - Custom Error Alert Method
- (void)showCustomErrorAlert: (NSString *)msg {
    [wTools setStatusBarBackgroundColor:[UIColor clearColor]];
    [UIViewController showCustomErrorAlertWithMessage:msg onButtonTouchUpBlock:^(CustomIOSAlertView *customAlertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[customAlertView tag]);
        [wTools setStatusBarBackgroundColor:[UIColor whiteColor]];
        [customAlertView close];
    }];
}

#pragma mark - Custom Method for TimeOut
- (void)showCustomTimeOutAlert: (NSString *)msg
                  protocolName: (NSString *)protocolName
                       albumId: (NSString *)albumId {
    CustomIOSAlertView *alertTimeOutView = [[CustomIOSAlertView alloc] init];
    alertTimeOutView.parentView = self.view;
    //[alertTimeOutView setContainerView: [self createTimeOutContainerView: msg]];
    [alertTimeOutView setContentViewWithMsg:msg contentBackgroundColor:[UIColor darkMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertTimeOutView.arrangeStyle = @"Horizontal";
    
    alertTimeOutView.parentView = self.view;
    [alertTimeOutView setButtonTitles: [NSMutableArray arrayWithObjects: NSLocalizedString(@"TimeOut-CancelBtnTitle", @""), NSLocalizedString(@"TimeOut-OKBtnTitle", @""), nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertTimeOutView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor clearColor], [UIColor clearColor],nil]];
    [alertTimeOutView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
    [alertTimeOutView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    
    __weak typeof(self) weakSelf = self;
    __weak CustomIOSAlertView *weakAlertTimeOutView = alertTimeOutView;
    [wTools setStatusBarBackgroundColor:[UIColor clearColor]];
    [alertTimeOutView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertTimeOutView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertTimeOutView tag]);
        [weakAlertTimeOutView close];
        [wTools setStatusBarBackgroundColor:[UIColor whiteColor]];
        if (buttonIndex == 0) {            
        } else {
            if ([protocolName isEqualToString: @"getcreative"]) {
                [weakSelf getCreatorInfo];
            } else if ([protocolName isEqualToString: @"getprofile"]) {
                [weakSelf getProfile];
            } else if ([protocolName isEqualToString: @"geturpoints"]) {
                [weakSelf getUrPoints];
            } else if ([protocolName isEqualToString: @"doTask1"]) {
                [weakSelf checkPoint];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)infoEditViewControllerSaveBtnPressed:(InfoEditViewController *)controller {
    NSLog(@"infoEditViewControllerSaveBtnPressed");
    [self refresh];
    [self checkFirstTimeEditing];
}

- (void)profilePictureUpdate:(NSString *)urlString {
    NSLog(@"profilePictureUpdate");
    NSLog(@"urlString: %@", urlString);
    profilePicUrlString = urlString;
}

@end
