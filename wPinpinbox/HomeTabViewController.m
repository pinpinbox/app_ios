//
//  HomeTabViewController.m
//  wPinpinbox
//
//  Created by David on 4/22/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "HomeTabViewController.h"
#import "HomeDataCollectionViewCell.h"
#import "HomeBannerCollectionViewCell.h"
#import "HomeDataCollectionReusableView.h"
#import "HomeCategoryCollectionViewCell.h"

#import "CategoryViewController.h"

#import "AppDelegate.h"

#import <QuartzCore/QuartzCore.h>

#import "MBProgressHUD.h"
#import "boxAPI.h"
#import "wTools.h"
#import "AsyncImageView.h"

#import "AlbumDetailViewController.h"

#import "JCCollectionViewWaterfallLayout.h"
#import "MyLayout.h"
#import "UIColor+Extensions.h"

#import <SafariServices/SafariServices.h>
//#import "EventPostViewController.h"
#import "CreaterViewController.h"
#import "ViewController.h"
#import "CustomIOSAlertView.h"
#import "OldCustomAlertView.h"
#import "UIColor+HexString.h"
#import "UIView+Toast.h"
#import "NewEventPostViewController.h"
#import "FLAnimatedImage.h"
#import "GlobalVars.h"
#import <Crashlytics/Crashlytics.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <RMPZoomTransitionAnimator/RMPZoomTransitionAnimator.h>
#import "ActivityDetailViewController.h"
#import "MyTabBarController.h"

//#import "ActivityWebViewController.h"
#import <Flurry.h>

#import "LabelAttributeStyle.h"

#import "OpenUDID.h"

//#import "ChooseHobbyViewController.h"
#import "FBFriendsFindingViewController.h"

#import "BuyPPointViewController.h"

#define kAdHeight 142
#define kBtnWidth 78
#define kBtnGap 16

@interface HomeTabViewController () <UICollectionViewDataSource, UICollectionViewDelegate, JCCollectionViewWaterfallLayoutDelegate, UICollectionViewDelegateFlowLayout, SFSafariViewControllerDelegate, UIGestureRecognizerDelegate, RMPZoomTransitionAnimating, UIViewControllerTransitioningDelegate>
{
    BOOL isLoading;
    BOOL isReloading;
    NSInteger nextId;
    NSMutableArray *pictures;
    
    // For Ad
    NSArray *adArray;
    NSInteger selectItem;
    UIPageControl *pageControl;
    
    // For Showing Message of Getting Point
    NSString *missionTopicStr;
    NSString *rewardType;
    NSString *rewardValue;
    NSString *eventUrl;
    
    NSString *restriction;
    NSString *restrictionValue;
    NSUInteger numberOfCompleted;
    
    OldCustomAlertView *alertView;
    
    NSString *rankType;
    
    UIView *newView;
    UIView *followView;
    UIView *categoryView;
    
    UILabel *newSymbolLabel;
    UILabel *followSymbolLabel;
    
    CAGradientLayer *newGradient;
    CAGradientLayer *followGradient;
    CAGradientLayer *categoryGradient;
    
    FLAnimatedImageView *flaImageView;
    
    BOOL isScrollingDown;
    
    NSInteger columnCount;
    NSInteger miniInteriorSpacing;
    
    NSMutableArray *categoryArray;
    NSMutableArray *getTheMeAreaArray;
    
    UILabel *exploreLabel;
    UIView *exploreHorzView;
    UILabel *recommendationLabel;
    UIView *recommendationHorzView;
    
    NSDictionary *getTheMeAreaDic;
}
@property (nonatomic, strong) JCCollectionViewWaterfallLayout *jccLayout;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) UICollectionView *collectionView2;
@property (weak, nonatomic) UICollectionView *collectionView3;
@property (weak, nonatomic) UIPageControl *pageControl;
@property (weak, nonatomic) UIImageView *zoomView;

@end

@implementation HomeTabViewController

#pragma mark - Notificaiton Setting for Gif
- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(appEnterBackground:) name: UIApplicationDidEnterBackgroundNotification object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(appEnterForeground:) name: UIApplicationWillEnterForegroundNotification object: nil];
}

- (void)removeNotification
{
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver: self name: UIApplicationDidEnterBackgroundNotification object: nil];
        [[NSNotificationCenter defaultCenter] removeObserver: self name: UIApplicationWillEnterForegroundNotification object: nil];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
}

- (void)appEnterBackground: (NSNotification *)notif
{
    NSLog(@"");
    NSLog(@"HomeTabVC");
    NSLog(@"appEnterBackground");
    [flaImageView stopAnimating];
}

- (void)appEnterForeground: (NSNotification *)notif
{
    NSLog(@"");
    NSLog(@"HomeTabVC");
    NSLog(@"appEnterForeground");
    [flaImageView startAnimating];
}

#pragma mark - View Related Methods

// Crash Test
- (IBAction)crashButtonTapped:(id)sender {
    [[Crashlytics sharedInstance] crash];
}

- (void)viewDidLoad {
    NSLog(@"");
    NSLog(@"HomeTabViewController viewDidLoad");
    // Do any additional setup after loading the view.
    for (NSString *family in [UIFont familyNames]) {
        NSLog(@"family: %@", family);
        
        for (NSString *name in [UIFont fontNamesForFamilyName: family]) {
            NSLog(@"name: %@", name);
        }
    }
    
    NSLog(@"getUserID: %@", [wTools getUserID]);
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    CGSize screenSize = CGSizeMake(screenBounds.size.width * screenScale, screenBounds.size.height * screenScale);
    NSLog(@"screenSize: %@", NSStringFromCGSize(screenSize));
    
    // Get user data for flurry
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *idStr = [defaults objectForKey: @"id"];
    NSString *nickNameStr = [defaults objectForKey: @"profile"][@"nickname"];
    NSString *flurryUserID = [NSString stringWithFormat: @"%@, %@", idStr, nickNameStr];
    [Flurry setUserID: flurryUserID];
    
    [self setupPushNotification];
    
    [self checkVersion];
    //[self getProfile];
    //[self addCategoryBtn];
    //[self flowLayoutSetup];
    //[self getPointStore];
    //[self checkFirstTimeLogin];
    //[self addTestBtn];
    //[self testInterest];
}

//- (void)testInterest {
//    UIButton *testBtn = [UIButton buttonWithType: UIButtonTypeCustom];
//    [testBtn addTarget: self action: @selector(toChooseHobbyVC) forControlEvents: UIControlEventTouchUpInside];
//    testBtn.frame = CGRectMake(self.view.bounds.origin.x + 260, self.view.bounds.origin.y + 300, 50, 50);
//    [testBtn setTitle: @"friendsFinding" forState: UIControlStateNormal];
//    [self.view addSubview: testBtn];
//}
//
//- (void)toChooseHobbyVC {
//    FBFriendsFindingViewController *fbFindingVC = [[UIStoryboard storyboardWithName:@"FBFriendsFindingVC" bundle:nil]instantiateViewControllerWithIdentifier:@"FBFriendsFindingViewController"];
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [appDelegate.myNav pushViewController: fbFindingVC animated: YES];
////    ChooseHobbyViewController *chooseHobbyVC = [[UIStoryboard storyboardWithName: @"ChooseHobbyVC" bundle: nil] instantiateViewControllerWithIdentifier: @"ChooseHobbyViewController"];
////    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
////    [appDelegate.myNav pushViewController: chooseHobbyVC animated: YES];
//}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"");
    NSLog(@"HomeTabViewController viewWillAppear");
    
    [super viewWillAppear:animated];
    
    NSLog(@"status bar height: %f", [UIApplication sharedApplication].statusBarFrame.size.height);
    
    [self removeNotification];
    [self addNotification];
    
    self.jccLayout = (JCCollectionViewWaterfallLayout *)self.collectionView.collectionViewLayout;
    
    CGFloat headerHeight = 0;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                headerHeight = 420.0f;
                break;
            case 1334:
                printf("iPhone 6/6S/7/8");
                headerHeight = 450.0f;
                break;
            case 1920:
                printf("iPhone 6+/6S+/7+/8+");
                headerHeight = 450.0f;
                break;
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                headerHeight = 450.0f;
                break;
            case 2436:
                printf("iPhone X");
                headerHeight = 430.0f;
                break;
            default:
                printf("unknown");
                headerHeight = 450.0f;
                break;
        }
    }
    
    self.jccLayout.headerHeight = headerHeight;
    self.jccLayout.footerHeight = 0.0f;
    
    // Central Button
    for (UIView *view in self.tabBarController.view.subviews) {
        UIButton *btn = (UIButton *)[view viewWithTag: 104];
        btn.hidden = NO;
    }    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self removeNotification];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Push Notification Setting
- (void)setupPushNotification {
    NSLog(@"\n\nsetupPushNotification");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSString *awsResponse;
        
        NSLog(@"wTools getUUID: %@", [wTools getUUID]);
        
        if ([wTools getUUID]) {
            NSLog(@"\n\nwTools getUUID exists");
            NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
            
            NSLog(@"getUserID: %@", [userPrefs objectForKey: @"id"]);
            NSLog(@"getUserToken: %@", [userPrefs objectForKey: @"token"]);
            NSLog(@"getUUID: %@", [wTools getUUID]);
            NSLog(@"identifier: %@", [OpenUDID value]);
            
            UIDevice *device = [UIDevice currentDevice];
            NSString *currentDeviceId = [[device identifierForVendor] UUIDString];
            NSLog(@"currentDeviceId: %@", currentDeviceId);
            
            //awsResponse = [boxAPI setawssns:[wTools getUserID] token:[wTools getUserToken] devicetoken:[wTools getUUID] identifier:[OpenUDID value]];
            awsResponse = [boxAPI setawssns:[wTools getUserID] token:[wTools getUserToken] devicetoken:[wTools getUUID] identifier: currentDeviceId];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (awsResponse != nil) {
                NSLog(@"awsResponse: %@", awsResponse);
            }
        });
    });
}

#pragma mark - Version Update
- (void)checkVersion {
    NSLog(@"call checkVersion");
    //[wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *version = [self getVersion];
        NSLog(@"version: %@", version);
        
        NSString *response = [boxAPI checkUpdateVersion: @"apple" version: version];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"checkVersion Response != nil");
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"checkVersion");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"checkVersion"
                                         eventId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSLog(@"response from checkVersion");
                    
                    NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableLeaves error: nil];
                    NSLog(@"data: %@", data);
                    
                    if ([data[@"result"] intValue] == 0) {
                        NSLog(@"error");
                        [self closeApp];
                    } else if ([data[@"result"] intValue] == 1) {
                        NSLog(@"needs to update");
                        //[self showUpdateAlert];
                        NSString *alertMsg = [NSString stringWithFormat: NSLocalizedString(@"Version-Update", @"")];
                        [self showCustomUpdateAlert: alertMsg option: @"mustUpdate"];
                    } else if ([data[@"result"] intValue] == 2) {
                        NSLog(@"don't need to update immediately");
                        BOOL needsUpdate = [self needsUpdate];
                        NSLog(@"needsUpdate: %d", needsUpdate);
                        
                        if ([self needsUpdate]) {
                            NSString *alertMsg = [NSString stringWithFormat: NSLocalizedString(@"Version-Update", @"")];
                            [self showCustomUpdateAlert: alertMsg option: @"canUpdateLater"];
                        } else {
                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            [defaults setObject: [NSNumber numberWithBool: NO] forKey: @"hasNewVersion"];
                            [defaults synchronize];
                            [self initApp];
                        }
                    }
                }
            }
        });
    });
}

- (NSString *)getVersion {
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    //NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    //NSString *versionBuild = [NSString stringWithFormat: @"%@%@", version, build];;
    
    return version;
}

- (BOOL)needsUpdate {
    NSLog(@"needsUpdate");
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appID = infoDictionary[@"CFBundleIdentifier"];
    NSLog(@"appID: %@", appID);
    
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: @"https://itunes.apple.com/tw/lookup?bundleId=%@", appID]];
    NSLog(@"url: %@", url);
    
    NSData *data = [NSData dataWithContentsOfURL: url];
    NSDictionary *lookup = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];
    
    NSLog(@"lookup: %@", lookup);
    
    if ([lookup[@"resultCount"] integerValue] == 1) {
        NSString *appStoreVersion = lookup[@"results"][0][@"version"];
        NSLog(@"appStoreVersion: %@", appStoreVersion);
        
        NSString *currentVersion = infoDictionary[@"CFBundleShortVersionString"];
        NSLog(@"currentVersion: %@", currentVersion);
        
        if ([appStoreVersion compare: currentVersion options: NSNumericSearch] == NSOrderedDescending) {
            NSLog(@"\n\nNeed to update. AppStore Version %@ is greater than %@", appStoreVersion, currentVersion);
            return YES;
        }
    }
    return NO;
}

- (void)initApp {
    [self initialValueSetup];
    //[self addCategoryBtn];
    [self loadData];
}

- (void)initialValueSetup
{
    NSLog(@"initialValueSetup");
    isScrollingDown = NO;
    
    nextId = 0;
    isLoading = NO;
    isReloading = NO;
    
    pictures = [NSMutableArray new];
    
    rankType = @"latest";
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget: self
                            action: @selector(refresh)
                  forControlEvents: UIControlEventValueChanged];
    [self.collectionView addSubview: self.refreshControl];
    
    columnCount = 2;
    miniInteriorSpacing = 16;
    
    self.pageControl.hidden = YES;
}

#pragma mark - <RMPZoomTransitionAnimating>
- (UIImageView *)transitionSourceImageView {
    NSLog(@"transitionSourceImageView");
    NSLog(@"self.zoomView.image: %@", self.zoomView.image);
    UIImageView *imageView = [[UIImageView alloc] initWithImage: self.zoomView.image];
    imageView.contentMode = self.zoomView.contentMode;
    imageView.clipsToBounds = YES;
    imageView.userInteractionEnabled = NO;
    imageView.frame = [self.zoomView convertRect: self.zoomView.frame toView: self.collectionView.superview];
    return imageView;
}

- (UIColor *)transitionSourceBackgroundColor {
    return self.collectionView.backgroundColor;
}

- (CGRect)transitionDestinationImageViewFrame {
    CGRect frameInSuperView = [self.zoomView convertRect: self.zoomView.frame toView: self.collectionView.superview];
    return frameInSuperView;
}

#pragma mark - <UIViewControllerTransitioningDelegate>

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    id <RMPZoomTransitionAnimating, RMPZoomTransitionDelegate> sourceTransition = (id<RMPZoomTransitionAnimating, RMPZoomTransitionDelegate>)source;
    id <RMPZoomTransitionAnimating, RMPZoomTransitionDelegate> destinationTransition = (id<RMPZoomTransitionAnimating, RMPZoomTransitionDelegate>)presented;
    if ([sourceTransition conformsToProtocol:@protocol(RMPZoomTransitionAnimating)] &&
        [destinationTransition conformsToProtocol:@protocol(RMPZoomTransitionAnimating)]) {
        RMPZoomTransitionAnimator *animator = [[RMPZoomTransitionAnimator alloc] init];
        animator.goingForward = YES;
        animator.sourceTransition = sourceTransition;
        animator.destinationTransition = destinationTransition;
        return animator;
    }
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    id <RMPZoomTransitionAnimating, RMPZoomTransitionDelegate> sourceTransition = (id<RMPZoomTransitionAnimating, RMPZoomTransitionDelegate>)dismissed;
    id <RMPZoomTransitionAnimating, RMPZoomTransitionDelegate> destinationTransition = (id<RMPZoomTransitionAnimating, RMPZoomTransitionDelegate>)self;
    if ([sourceTransition conformsToProtocol:@protocol(RMPZoomTransitionAnimating)] &&
        [destinationTransition conformsToProtocol:@protocol(RMPZoomTransitionAnimating)]) {
        RMPZoomTransitionAnimator *animator = [[RMPZoomTransitionAnimator alloc] init];
        animator.goingForward = NO;
        animator.sourceTransition = sourceTransition;
        animator.destinationTransition = destinationTransition;
        return animator;
    }
    return nil;
}

#pragma mark -

- (void)refresh {
    NSLog(@"");
    NSLog(@"refresh");
    NSLog(@"isReloading: %d", isReloading);
    
    if (!isReloading) {
        nextId = 0;
        isLoading = NO;
        isReloading = YES;
        
        // Reset data before loading new data
        pictures = nil;
        [self.collectionView reloadData];
        
        [self loadData];
    }
}

- (void)loadData {
    NSLog(@"");
    NSLog(@"loadData");
    NSLog(@"nextId: %ld", (long)nextId);
    NSLog(@"isLoading: %d", isLoading);
    
    // If isLoading is NO then run the following code
    if (!isLoading) {
        isLoading = YES;
        [self updateList];
    }
}

- (void)updateList {
    NSLog(@"");
    NSLog(@"updateList");
    
    @try {
        [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught");
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    NSMutableDictionary *data = [NSMutableDictionary new];
    NSString *limit = [NSString stringWithFormat: @"%ld,%d", (long)nextId, 16];
    
    NSLog(@"limit: %@", limit);
    
    [data setValue: limit forKey: @"limit"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI updatelist: [wTools getUserID]
                                          token: [wTools getUserToken]
                                           data: data
                                           rank: rankType];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [MBProgressHUD hideHUDForView: self.view animated: YES];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason);
                return;
            }
            
            if (response != nil) {
                NSLog(@"response from updateList");
                //NSLog(@"response: %@", response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"HomeTabViewController");
                    NSLog(@"updateList");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"updatelist"
                                         eventId: @""];
                    [self.refreshControl endRefreshing];
                    isReloading = NO;
                    
                } else {
                    NSLog(@"Get Real Response");
                    
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    NSLog(@"dic: %@", dic);
                    
                    if ([dic[@"result"] boolValue]) {
                        //NSLog(@"dic: %@", dic[@"data"]);
                        
                        NSLog(@"Before");
                        NSLog(@"nextId: %ld", (long)nextId);
                        
                        if (nextId == 0) {
                            //[pictures removeAllObjects];
                            pictures = [NSMutableArray new];
                        }
                        
                        // s for counting how much data is loaded
                        int s = 0;
                        
                        for (NSMutableDictionary *picture in [dic objectForKey: @"data"]) {
                            s++;
                            [pictures addObject: picture];
                        }
                        
                        // If data keeps loading then the nextId is accumulating
                        nextId = nextId + s;

                        NSLog(@"After");
                        NSLog(@"nextId: %ld", (long)nextId);
                        NSLog(@"s: %d", s);
                        
                        // If nextId is bigger than 0, that means there are some data loaded already.
                        if (nextId >= 0) {
                            isLoading = NO;
                        }
                        
                        // If s is 0, that means dic data is empty.
                        if (s == 0) {
                            isLoading = YES;
                        }
                        
                        [self.refreshControl endRefreshing];                        
                        [self.collectionView reloadData];
                        
                        isReloading = NO;
                        
                        if (isScrollingDown) {
                            isScrollingDown = NO;
                        } else {
                            [self checkAd];
                        }
                        
                        NSLog(@"-------------------------");
                        NSLog(@"nextId: %ld", (long)nextId);
                    } else {
                        [self.refreshControl endRefreshing];
                        NSLog(@"失敗： %@", dic[@"message"]);
                        NSString *msg = dic[@"message"];
                        
                        if (msg == nil) {
                            msg = NSLocalizedString(@"Host-NotAvailable", @"");
                        }
                        [self showCustomErrorAlert: msg];
                        
                        isReloading = NO;
                    }
                }
            } else {
                [self.refreshControl endRefreshing];
                isReloading = NO;
            }
        });
    });
}

#pragma mark - Web Service - GetAdList
- (void)checkAd {
    NSLog(@"");
    NSLog(@"");
    NSLog(@"checkAd");
    
    @try {
        [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI getAdList: [wTools getUserID]
                                         token: [wTools getUserToken]
                                     adarea_id: @"1"];
        
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
                NSLog(@"checkAd Response");
                //NSLog(@"reponse: %@", response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"HomeTabViewController");
                    NSLog(@"checkAd");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getAdList"
                                         eventId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    
                    NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableLeaves error: nil];
                    
                    if ([data[@"result"] boolValue]) {
                        NSLog(@"GetAd Success");
                        adArray = data[@"data"];
                        
                        // Check array data is 0 or more than 0
                        NSLog(@"adArray: %@", adArray);
                        NSLog(@"adArray.count: %lu", (unsigned long)adArray.count);
                        
                        [self.collectionView2 reloadData];
                        self.pageControl.numberOfPages = adArray.count;
                        self.pageControl.hidden = NO;
                        
                        [self getCategoryList];
                        
                        //[self checkFirstTimeLogin];
                    } else {
                        NSLog(@"失敗： %@", data[@"message"]);
                        NSString *msg = data[@"message"];
                        
                        if (msg == nil) {
                            msg = NSLocalizedString(@"Host-NotAvailable", @"");
                        }
                        [self showCustomErrorAlert: msg];
                    }
                }
            }
        });
    });
}

- (void)getCategoryList
{
    NSLog(@"getCategoryList");
    
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI retrievecatgeorylist: [wTools getUserID] token: [wTools getUserToken]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [wTools HideMBProgressHUD];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                return;
            }
            
            if (response != nil) {
                NSLog(@"response from retrievecatgeorylist");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"HomeTabVC");
                    NSLog(@"getCategoryList");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"retrievecatgeorylist"
                                         eventId: @""];
                     
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] boolValue]) {
                        NSLog(@"dic: %@", dic);
                        NSLog(@"dic data: %@", dic[@"data"]);
                        categoryArray = [NSMutableArray arrayWithArray: dic[@"data"]];
                        
                        exploreLabel.hidden = NO;
                        exploreHorzView.hidden = NO;
                        recommendationLabel.hidden = NO;
                        recommendationHorzView.hidden = NO;
                        
                        //[self.collectionView3 reloadData];
                        
                        [self getTheMeArea];
                    } else {
                        NSLog(@"失敗： %@", dic[@"message"]);
                        NSString *msg = dic[@"message"];
                        
                        if (msg == nil) {
                            msg = NSLocalizedString(@"Host-NotAvailable", @"");
                        }
                        [self showCustomErrorAlert: msg];
                    }
                }
            }
        });
    });
}

- (void)getTheMeArea {
    NSLog(@"\ngetTheMeArea");
    
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI getTheMeArea: [wTools getUserToken] userId: [wTools getUserID]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [wTools HideMBProgressHUD];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                return;
            }
            
            if (response != nil) {
                NSLog(@"response from getTheMeArea");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"HomeTabVC");
                    NSLog(@"getTheMeArea");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getTheMeArea"
                                         eventId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSLog(@"Get response from getTheMeArea");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] isEqualToString: @"SYSTEM_OK"]) {
                        NSLog(@"SYSTEM_OK");
                        NSLog(@"dic: %@", dic);
                        getTheMeAreaDic = dic;
                        
                        NSLog(@"dic data albumexplore: %@", dic[@"data"][@"albumexplore"]);
                        NSLog(@"data themearea: %@", dic[@"data"][@"themearea"]);
                        
                        NSLog(@"Before");
                        NSLog(@"categoryArray: %@", categoryArray);
                        
                        NSString *colorHexStr = dic[@"data"][@"themearea"][@"colorhex"];
                        NSString *nameStr = dic[@"data"][@"themearea"][@"name"];
                        
                        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                        [dic setObject: [NSNumber numberWithInteger: -1] forKey: @"categoryarea_id"];
                        [dic setObject: colorHexStr forKey: @"colorhex"];
                        [dic setObject: nameStr forKey: @"name"];
                        
                        NSLog(@"dic: %@", dic);
                        
                        NSMutableDictionary *dicData = [[NSMutableDictionary alloc] init];
                        [dicData setObject: dic forKey: @"categoryarea"];
                        
                        NSLog(@"dicData: %@", dicData);
                        
                        [categoryArray insertObject: dicData atIndex: 0];
                        NSLog(@"After");
                        NSLog(@"categoryArray: %@", categoryArray);
                        
                        [self.collectionView3 reloadData];
                        
                        [self checkFirstTimeLogin];
                    } else if ([dic[@"result"] isEqualToString: @"SYSTEM_ERROR"]) {
                        NSLog(@"SYSTEM_ERROR");
                        NSLog(@"失敗：%@",dic[@"message"]);
                        NSString *msg = dic[@"message"];
                        
                        if (msg == nil) {
                            msg = NSLocalizedString(@"Host-NotAvailable", @"");
                        }
                        [self showCustomErrorAlert: dic[@"message"]];
                    } else if ([dic[@"result"] isEqualToString: @"TOKEN_ERROR"]) {
                        NSLog(@"TOKEN_ERROR");
                        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                        style.messageColor = [UIColor whiteColor];
                        style.backgroundColor = [UIColor thirdPink];
                        
                        [self.view makeToast: @"用戶驗證異常請重新登入"
                                    duration: 2.0
                                    position: CSToastPositionBottom
                                       style: style];
                        
                        [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                         target: self
                                                       selector: @selector(logOut)
                                                       userInfo: nil
                                                        repeats: NO];
                    }
                }
            }
        });
    });
}

- (void)logOut {
    [wTools logOut];
}

#pragma mark - Custom AlertView for Getting Point
- (void)showAlertView
{
    // Custom AlertView shows up when getting the point
    alertView = [[OldCustomAlertView alloc] init];
    [alertView setContainerView: [self createPointView]];
    [alertView setButtonTitles: [NSMutableArray arrayWithObject: @"確     認"]];
    [alertView setUseMotionEffects: true];
    
    [alertView show];
}

- (UIView *)createPointView
{
    NSLog(@"createPointView");
    
    UIView *pointView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 250, 250)];
    
    // Mission Topic Label
    UILabel *missionTopicLabel = [[UILabel alloc] initWithFrame: CGRectMake(10, 15, 200, 10)];
    //missionTopicLabel.text = @"收藏相本得點";
    missionTopicLabel.text = missionTopicStr;
    
    //NSLog(@"Topic Label Text: %@", missionTopicStr);
    [pointView addSubview: missionTopicLabel];
    
    if ([restriction isEqualToString: @"personal"]) {
        UILabel *restrictionLabel = [[UILabel alloc] initWithFrame: CGRectMake(10, 45, 200, 10)];
        restrictionLabel.textColor = [UIColor firstGrey];
        restrictionLabel.text = [NSString stringWithFormat: @"次數：%lu / %@", (unsigned long)numberOfCompleted, restrictionValue];
        //NSLog(@"restrictionLabel.text: %@", restrictionLabel.text);
        
        [pointView addSubview: restrictionLabel];
    }
    
    // Gift Image
    UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(50, 90, 100, 100)];
    imageView.image = [UIImage imageNamed: @"icon_present"];
    [pointView addSubview: imageView];
    
    // Message Label
    UILabel *messageLabel = [[UILabel alloc] initWithFrame: CGRectMake(10, 200, 200, 10)];
    
    NSString *congratulate = @"恭喜您獲得 ";
    //NSString *number = @"1 ";
    
    //NSLog(@"Reward Value: %@", rewardValue);
    NSString *end = @"P!";
    
    /*
     if ([rewardType isEqualToString: @"point"]) {
     congratulate = @"恭喜您獲得 ";
     number = @"5 ";
     // number = rewardValue;
     end = @"P!";
     }
     */
    
    messageLabel.text = [NSString stringWithFormat: @"%@%@%@", congratulate, rewardValue, end];
    [pointView addSubview: messageLabel];
    
    if ([eventUrl isEqual: [NSNull null]] || eventUrl == nil) {
        NSLog(@"eventUrl is equal to null or eventUrl is nil");
    } else {
        // Activity Button
        UIButton *activityButton = [UIButton buttonWithType: UIButtonTypeCustom];
        [activityButton addTarget: self action: @selector(showTheActivityPage) forControlEvents: UIControlEventTouchUpInside];
        activityButton.frame = CGRectMake(150, 220, 100, 10);
        [activityButton setTitle: @"活動連結" forState: UIControlStateNormal];
        [activityButton setTitleColor: [UIColor colorWithRed: 26.0/255.0 green: 196.0/255.0 blue: 199.0/255.0 alpha: 1.0]
                             forState: UIControlStateNormal];
        [pointView addSubview: activityButton];
    }
    
    return pointView;
}

- (void)showTheActivityPage
{
    NSLog(@"showTheActivityPage");
    
    //NSString *activityLink = @"http://www.apple.com";
    NSString *activityLink = eventUrl;
    //NSLog(@"activityLink: %@", activityLink);
    
    NSURL *url = [NSURL URLWithString: activityLink];
    
    // Close for present safari view controller, otherwise alertView will hide the background
    [alertView close];
    
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: url entersReaderIfAvailable: NO];
    safariVC.delegate = self;
    safariVC.preferredBarTintColor = [UIColor whiteColor];
    [self presentViewController: safariVC animated: YES completion: nil];
}

#pragma mark - SFSafariViewController delegate methods
- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller
{
    // Done button pressed
    
    NSLog(@"show");
    [alertView show];
}

#pragma mark - Check Point Task
- (void)checkFirstTimeLogin
{
    // Check whether getting login point or not
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL firsttime_login = [[defaults objectForKey: @"firsttime_login"] boolValue];
    
    //firsttime_login = YES;
    NSLog(@"Check whether getting Login point or not");
    NSLog(@"firstTimeLogin: %d", (int)firsttime_login);
    
    if (firsttime_login) {
        NSLog(@"Get the Login Point Already");
    } else {
        [self checkPoint];
    }
}

#pragma mark - Check Point Method
- (void)checkPoint {
    NSLog(@"checkPoint");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSString *response = [boxAPI doTask1: [wTools getUserID]
                                       token: [wTools getUserToken]
                                    task_for: @"firsttime_login"
                                    platform: @"apple"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response != nil) {
                NSLog(@"response from doTask1");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"HomeTabViewController");
                    NSLog(@"checkPoint");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"doTask1"
                                         eventId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    
                    NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([data[@"result"] intValue] == 1) {
                        
                        missionTopicStr = data[@"data"][@"task"][@"name"];
                        //NSLog(@"name: %@", missionTopicStr);
                        
                        rewardType = data[@"data"][@"task"][@"reward"];
                        //NSLog(@"reward type: %@", rewardType);
                        
                        rewardValue = data[@"data"][@"task"][@"reward_value"];
                        //NSLog(@"reward value: %@", rewardValue);
                        
                        eventUrl = data[@"data"][@"event"][@"url"];
                        //NSLog(@"event: %@", eventUrl);
                        
                        restriction = data[@"data"][@"task"][@"restriction"];
                        //NSLog(@"restriction: %@", restriction);
                        
                        restrictionValue = data[@"data"][@"task"][@"restriction_value"];
                        //NSLog(@"restrictionValue: %@", restrictionValue);
                        
                        numberOfCompleted = [data[@"data"][@"task"][@"numberofcompleted"] unsignedIntegerValue];
                        //NSLog(@"numberOfCompleted: %lu", (unsigned long)numberOfCompleted);
                        
                        [self showAlertView];
                        [self getUrPoints];
                    } else if ([data[@"result"] intValue] == 2) {
                        NSLog(@"message: %@", data[@"message"]);
                        
                        // Save setting for login successfully
                        BOOL firsttime_login = YES;
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setObject: [NSNumber numberWithBool: firsttime_login] forKey: @"firsttime_login"];
                        [defaults synchronize];
                    }
                }
            }
        });
    });
}

#pragma mark - Get P Point
- (void)getUrPoints {
    NSLog(@"");
    NSLog(@"getUrPoints");
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    
    @try {
        [MBProgressHUD showHUDAddedTo: self.view animated: YES];
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
                [MBProgressHUD hideHUDForView: self.view animated: YES];
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
                    NSLog(@"HomeTabViewController");
                    NSLog(@"getUrPoints");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"geturpoints"
                                         eventId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    NSLog(@"dic: %@", dic);
                    
                    if ([dic[@"result"] boolValue]) {
                        NSLog(@"dic result boolValue is 1");
                        NSInteger point = [dic[@"data"] integerValue];
                        //NSLog(@"point: %ld", (long)point);
                        
                        [userPrefs setObject: [NSNumber numberWithInteger: point] forKey: @"pPoint"];
                        [userPrefs synchronize];
                    } else {
                        NSLog(@"失敗： %@", dic[@"message"]);
                        NSString *msg = dic[@"message"];
                        
                        if (msg == nil) {
                            msg = NSLocalizedString(@"Host-NotAvailable", @"");
                        }
                        [self showCustomErrorAlert: msg];
                    }
                }
            }
        });
    });
}

- (void)checkZoomView:(NSString *)eventId
             imageUrl:(NSString *)imageUrl {
    NSLog(@"checkZoomView");
    NSLog(@"eventId: %@", eventId);
    NSLog(@"imageUrl: %@", imageUrl);
    
    if (![eventId isEqual: [NSNull null]]) {
        if (![eventId isEqualToString: @""]) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *imageUrlStr = [defaults objectForKey: @"imageUrl"];
            NSLog(@"imageUrlStr: %@", imageUrlStr);
            
            if (![imageUrlStr isEqual: [NSNull null]]) {
                if (![imageUrlStr isEqualToString: @""]) {
                    if (![imageUrlStr isEqualToString: imageUrl]) {
                        [defaults setValue: imageUrl forKey: @"imageUrl"];
                        [defaults synchronize];
                        
                        [self presentZoom];
                    }
                }
            }
        }
    }
}

- (void)presentZoom {
    NSLog(@"presentZoom");
    
    //ActivityDetailViewController *activityDetailVC = [[UIStoryboard storyboardWithName: @"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"ActivityDetailViewController"];
    ActivityDetailViewController *activityDetailVC = [[UIStoryboard storyboardWithName: @"ActivityDetailVC" bundle: nil] instantiateViewControllerWithIdentifier: @"ActivityDetailViewController"];
    activityDetailVC.transitioningDelegate = self;
    self.providesPresentationContextTransitionStyle = YES;
    activityDetailVC.definesPresentationContext = YES;
    activityDetailVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    
    /*
     // The 3 lines below is to set the background transparent
     activityDetailVC.providesPresentationContextTransitionStyle = YES;
     activityDetailVC.definesPresentationContext = YES;
     activityDetailVC.view.backgroundColor = [UIColor clearColor];
     activityDetailVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
     */
    
    [self presentViewController: activityDetailVC animated: YES completion: nil];
}


#pragma mark - Get Event Methods
- (void)getEventData: (NSString *)eventId {
    NSLog(@"");
    NSLog(@"getEventData");
    NSLog(@"eventId: %@", eventId);
    
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSString *response = [boxAPI getEvent: [wTools getUserID]
                                        token: [wTools getUserToken]
                                     event_id: eventId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [wTools HideMBProgressHUD];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                return;
            }
                        
            if (response != nil) {
                NSLog(@"getEvent Response");
                //NSLog(@"response: %@", response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"HomeTabViewController");
                    NSLog(@"getEventData eventId");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getEvent"
                                         eventId: eventId];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableLeaves error: nil];
                    
                    NSLog(@"data: %@", data);                
                    
                    if ([data[@"result"] intValue] == 1) {
                        NSLog(@"result is 1");
                        NSLog(@"GetEvent Success");
                        
                        NewEventPostViewController *newEventPostVC = [[UIStoryboard storyboardWithName: @"NewEventPostVC" bundle: nil] instantiateViewControllerWithIdentifier: @"NewEventPostViewController"];
                        newEventPostVC.name = data[@"data"][@"event"][@"name"];
                        newEventPostVC.title = data[@"data"][@"event"][@"title"];
                        newEventPostVC.imageUrl = data[@"data"][@"event"][@"image"];
                        newEventPostVC.urlString = data[@"data"][@"event"][@"url"];
                        newEventPostVC.templateArray =  data[@"data"][@"event_templatejoin"];
                        newEventPostVC.eventId = eventId;
                        newEventPostVC.contributionNumber = [data[@"data"][@"event"][@"contribution"] integerValue];
                        newEventPostVC.popularityNumber = [data[@"data"][@"event"][@"popularity"] integerValue];
                        newEventPostVC.prefixText = data[@"data"][@"event"][@"prefix_text"];
                        newEventPostVC.specialUrl = data[@"data"][@"special"][@"url"];
                        newEventPostVC.eventFinished = NO;
                        
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate.myNav pushViewController: newEventPostVC animated: YES];
                        
                    } else if ([data[@"result"] intValue] == 2) {
                        NSLog(@"result is 2");
                        
                        NSLog(@"event_templatejoin: %@", data[@"data"][@"event_templatejoin"]);
                        
                        NewEventPostViewController *newEventPostVC = [[UIStoryboard storyboardWithName: @"NewEventPostVC" bundle: nil] instantiateViewControllerWithIdentifier: @"NewEventPostViewController"];
                        newEventPostVC.name = data[@"data"][@"event"][@"name"];
                        newEventPostVC.title = data[@"data"][@"event"][@"title"];
                        newEventPostVC.imageUrl = data[@"data"][@"event"][@"image"];
                        newEventPostVC.urlString = data[@"data"][@"event"][@"url"];
                        newEventPostVC.templateArray = data[@"data"][@"event_templatejoin"];
                        newEventPostVC.eventId = eventId;
                        newEventPostVC.contributionNumber = [data[@"data"][@"event"][@"contribution"] integerValue];
                        newEventPostVC.popularityNumber = [data[@"data"][@"event"][@"popularity"] integerValue];
                        newEventPostVC.prefixText = data[@"data"][@"event"][@"prefix_text"];
                        newEventPostVC.specialUrl = data[@"data"][@"special"][@"url"];
                        newEventPostVC.eventFinished = YES;
                        
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate.myNav pushViewController: newEventPostVC animated: YES];
                    } else if ([data[@"result"] intValue] == 0) {
                        NSLog(@"失敗： %@", data[@"message"]);
                        NSString *msg = data[@"message"];
                        
                        if (msg == nil) {
                            msg = NSLocalizedString(@"Host-NotAvailable", @"");
                        }
                        [self showCustomErrorAlert: msg];
                    }
                }
            }
        });
    });
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    if (collectionView.tag == 1) {
        return pictures.count;
    } else if (collectionView.tag == 2) {
        return adArray.count;
    } else {
        return categoryArray.count;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"");
    NSLog(@"viewForSupplementaryElementOfKind");
    
    HomeDataCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind: kind withReuseIdentifier: @"headerId" forIndexPath: indexPath];

//    NSLog(@"headerView.homeBannerCollectionView.bounds.size.width: %f", headerView.homeBannerCollectionView.bounds.size.width);
//    NSLog(@"headerView.homeBannerCollectionView.bounds.size.height: %f", headerView.homeBannerCollectionView.bounds.size.height);
//    
//    headerView.homeBannerCollectionViewHeight.constant = headerView.homeBannerCollectionView.bounds.size.height * (380 / 992);
//    NSLog(@"headerView.homeBannerCollectionViewHeight: %f", headerView.homeBannerCollectionViewHeight.constant);
//    NSLog(@"headerView.homeBannerCollectionView.bounds.size.height: %f", headerView.homeBannerCollectionView.bounds.size.height);
    
    self.pageControl = headerView.pageControl;
    
    self.collectionView2 = headerView.homeBannerCollectionView;
    self.collectionView3 = headerView.categoryCollectionView;
    
    exploreLabel = headerView.exploreLabel;
    [LabelAttributeStyle changeGapString: exploreLabel content: exploreLabel.text];
    
    exploreHorzView = headerView.exploreHorzView;
    
    recommendationLabel = headerView.recommendationLabel;
    [LabelAttributeStyle changeGapString: recommendationLabel content: recommendationLabel.text];
    
    recommendationHorzView = headerView.recommendationHorzView;
    
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    return headerView;
}

- (void)checkToPresentViewOrNot:(NSIndexPath *)indexPath
                           cell:(HomeBannerCollectionViewCell *)cell {
    if (indexPath.row == 0) {
        NSString *event = adArray[indexPath.row][@"event"];
        if (![event isEqual: [NSNull null]]) {
            NSString *eventId = [adArray[indexPath.row][@"event"][@"event_id"] stringValue];
            if (![eventId isEqual: [NSNull null]]) {
                if (![eventId isEqualToString: @""]) {
                    
                    NSLog(@"cell.bannerImageView.image: %@", cell.bannerImageView.image);
                    double delayInSeconds = 0.5;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        self.zoomView = cell.bannerImageView;
                        [self extracted:indexPath];
                    });
                }
            }
        }
    }
}

// Present the ZoomView for Ad
- (void)extracted:(NSIndexPath * _Nonnull)indexPath {
    [self checkZoomView: [adArray[indexPath.row][@"event"][@"event_id"] stringValue]
               imageUrl: adArray[indexPath.row][@"ad"][@"image"]];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"");
    NSLog(@"cellForItemAtIndexPath");
    
    if (collectionView.tag == 1) {
        HomeDataCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"HomeDataCell" forIndexPath: indexPath];
        NSDictionary *data = pictures[indexPath.row];
        
        cell.contentView.subviews[0].backgroundColor = nil;
        
        if ([data[@"album"][@"cover"] isEqual: [NSNull null]]) {
            cell.coverImageView.image = [UIImage imageNamed: @"bg200_no_image.jpg"];
        } else {
            [cell.coverImageView sd_setImageWithURL: [NSURL URLWithString: data[@"album"][@"cover"]] placeholderImage: [UIImage imageNamed:@"placeholder.png"]];
            cell.coverImageView.backgroundColor = [UIColor colorFromHexString: data[@"album"][@"cover_hex"]];
        }
        
        // UserForView Info Setting
        BOOL gotAudio = [data[@"album"][@"usefor"][@"audio"] boolValue];
        BOOL gotVideo = [data[@"album"][@"usefor"][@"video"] boolValue];
        BOOL gotExchange = [data[@"album"][@"usefor"][@"exchange"] boolValue];
        BOOL gotSlot = [data[@"album"][@"usefor"][@"slot"] boolValue];
        
        [cell.btn1 setImage: nil forState: UIControlStateNormal];
        [cell.btn2 setImage: nil forState: UIControlStateNormal];
        [cell.btn3 setImage: nil forState: UIControlStateNormal];
        
        cell.userInfoView.hidden = YES;
        
        if (gotAudio) {
            cell.userInfoView.hidden = NO;
            [cell.btn3 setImage: [UIImage imageNamed: @"ic200_audio_play_dark"] forState: UIControlStateNormal];
            CGRect rect = cell.userInfoView.frame;
            rect.size.width = 28 * 1;
            cell.userInfoView.frame = rect;
            
            if (gotVideo) {
                [cell.btn3 setImage: [UIImage imageNamed: @"ic200_video_dark"] forState: UIControlStateNormal];
                [cell.btn2 setImage: [UIImage imageNamed: @"ic200_audio_play_dark"] forState: UIControlStateNormal];
                CGRect rect = cell.userInfoView.frame;
                rect.size.width = 28 * 2;
                cell.userInfoView.frame = rect;
                
                if (gotExchange || gotSlot) {
                    [cell.btn1 setImage: [UIImage imageNamed: @"ic200_audio_play_dark"] forState: UIControlStateNormal];
                    [cell.btn2 setImage: [UIImage imageNamed: @"ic200_video_dark"] forState: UIControlStateNormal];
                    [cell.btn3 setImage: [UIImage imageNamed: @"ic200_gift_dark"] forState: UIControlStateNormal];
                    
                    CGRect rect = cell.userInfoView.frame;
                    rect.size.width = 28 * 3;
                    cell.userInfoView.frame = rect;
                }
            }
        } else if (gotVideo) {
            cell.userInfoView.hidden = NO;
            [cell.btn3 setImage: [UIImage imageNamed: @"ic200_video_dark"] forState: UIControlStateNormal];
            CGRect rect = cell.userInfoView.frame;
            rect.size.width = 28 * 1;
            cell.userInfoView.frame = rect;
            
            if (gotExchange || gotSlot) {
                [cell.btn3 setImage: [UIImage imageNamed: @"ic200_gift_dark"] forState: UIControlStateNormal];
                [cell.btn2 setImage: [UIImage imageNamed: @"ic200_video_dark"] forState: UIControlStateNormal];
                CGRect rect = cell.userInfoView.frame;
                rect.size.width = 28 * 2;
                cell.userInfoView.frame = rect;
            }
        } else if (gotExchange || gotSlot) {
            cell.userInfoView.hidden = NO;
            [cell.btn3 setImage: [UIImage imageNamed: @"ic200_gift_dark"] forState: UIControlStateNormal];
            CGRect rect = cell.userInfoView.frame;
            rect.size.width = 28 * 1;
            cell.userInfoView.frame = rect;
        }
        
        // AlbumNameLabel Setting
        if (![data[@"album"][@"name"] isEqual: [NSNull null]]) {
            cell.albumNameLabel.text = data[@"album"][@"name"];
            [LabelAttributeStyle changeGapString: cell.albumNameLabel content: data[@"album"][@"name"]];
        }
        
        return cell;
    } else if (collectionView.tag == 2) {
        HomeBannerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"HomeBannerCell" forIndexPath: indexPath];
        NSLog(@"adArray: %@", adArray);
        
        NSDictionary *adData = adArray[indexPath.row];
        
        cell.bannerImageView.image = nil;
        
        if ([adData[@"ad"][@"image"] isEqual: [NSNull null]]) {
            cell.bannerImageView.image = [UIImage imageNamed: @"bg200_no_image.jpg"];
        } else {
            NSString *urlString = adData[@"ad"][@"image"];
            
            if ([[urlString pathExtension] isEqualToString: @"gif"]) {
                NSLog(@"file is gif");
                
                NSURL *urlImage = [NSURL URLWithString: urlString];
                __block NSData *data;
                
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_async(queue, ^{
                    NSLog(@"data = [NSData dataWithContentsOfURL: urlImage]");
                    data = [NSData dataWithContentsOfURL: urlImage];
                    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData: data];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"dispatch_get_main_queue");
                        NSLog(@"cell.bannerImageView.animatedImage = image");
                        cell.bannerImageView.animatedImage = image;
                        NSLog(@"cell.bannerImageView.animatedImage: %@", cell.bannerImageView.animatedImage);
                        
                        [self checkToPresentViewOrNot: indexPath
                                                 cell: cell];
                    });
                });
            } else {
                NSLog(@"adData ad image: %@", [NSURL URLWithString: adData[@"ad"][@"image"]]);
                /*
                NSURL *urlImage = [NSURL URLWithString: adData[@"ad"][@"image"]];
                NSData *data = [NSData dataWithContentsOfURL: urlImage];
                cell.bannerImageView.image = [UIImage imageWithData: data];
                [self checkToPresentViewOrNot: indexPath
                                         cell: cell];
                */
                
                //[cell.bannerImageView sd_setImageWithURL: [NSURL URLWithString: adData[@"ad"][@"image"]]];
                
                [cell.bannerImageView sd_setImageWithURL: [NSURL URLWithString: adData[@"ad"][@"image"]] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    [self checkToPresentViewOrNot: indexPath
                                             cell: cell];
                }];
            }
        }
        
        return cell;
    } else {
        HomeCategoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"CategoryCell" forIndexPath: indexPath];
        NSDictionary *dic = categoryArray[indexPath.row][@"categoryarea"];
        
        if (![dic[@"name"] isEqual:[NSNull null]]) {
            cell.categoryNameLabel.text = dic[@"name"];
            [LabelAttributeStyle changeGapString: cell.categoryNameLabel content: dic[@"name"]];
        }
        
        if (![dic[@"colorhex"] isEqual: [NSNull null]]) {
            NSLog(@"colorhex: %@", dic[@"colorhex"]);
            cell.categoryBgView.backgroundColor = [UIColor colorFromHexString: dic[@"colorhex"]];
        }
        
        return cell;
    }
}

#pragma mark - UICollectionViewDelegate Methods

- (BOOL)collectionView:(UICollectionView *)collectionView
shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath: indexPath];
    NSLog(@"cell.contentView.subviews: %@", cell.contentView.subviews);
    
    //cell.contentView.subviews[0].backgroundColor = [UIColor thirdMain];
    
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectItemAtIndexPath");
    
    if (collectionView.tag == 1) {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath: indexPath];
        NSLog(@"cell.contentView.subviews: %@", cell.contentView.subviews);
        
        //cell.contentView.subviews[0].backgroundColor = [UIColor thirdMain];
        NSLog(@"cell.contentView.bounds: %@", NSStringFromCGRect(cell.contentView.bounds));
        
        NSDictionary *data = pictures[indexPath.row];
        NSString *albumId = [data[@"album"][@"album_id"] stringValue];
        
        NSNumber *coverWidth = data[@"album"][@"cover_width"];
        NSNumber *coverHeight = data[@"album"][@"cover_height"];
        
        NSInteger tempWidth = [coverWidth integerValue];
        NSInteger tempHeight = [coverHeight integerValue];
        
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        NSLog(@"screenWidth: %f", screenWidth);
        CGFloat headerImageHeight = 0;
        
        if (tempWidth > tempHeight) {
            headerImageHeight = (2 * screenWidth) / 3;
        } else if (tempWidth < tempHeight) {
            headerImageHeight = (4 * screenWidth) / 3;
        } else if (tempWidth == tempHeight) {
            headerImageHeight = screenWidth;
        }
        NSLog(@"headerImageHeight: %f", headerImageHeight);
        
        //[self ToRetrievealbumpViewControlleralbumid: albumId];
        
        AlbumDetailViewController *aDVC = [[UIStoryboard storyboardWithName: @"AlbumDetailVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumDetailViewController"];
        //aDVC.data = [dic[@"data"] mutableCopy];
        aDVC.albumId = albumId;
        //    aDVC.headerImageHeight = headerImageHeight;
        
//        CATransition *transition = [CATransition animation];
//        transition.duration = 0.5;
//        transition.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
//        transition.type = kCATransitionFade;
//        transition.subtype = kCATransitionFromTop;
//        [self.navigationController.view.layer addAnimation: transition forKey: kCATransition];
        //[self.navigationController pushViewController: aDVC animated: NO];
        
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.myNav pushViewController: aDVC animated: NO];
        //[appDelegate.myNav pushViewController: testVC animated: YES];
    } else if (collectionView.tag == 2) {
        [self tapDetectedForURL: indexPath.row];
    } else {
        NSDictionary *data = categoryArray[indexPath.row];
        NSLog(@"data: %@", data);
        NSLog(@"categoryarea: %@", data[@"categoryarea"]);
        NSLog(@"categoryarea_id: %@", [data[@"categoryarea"][@"categoryarea_id"] stringValue]);
//        NSLog(@"categoryName: %@", data[@"categoryarea"][@"name"]);
        
        [self toCategoryVC: [data[@"categoryarea"][@"categoryarea_id"] stringValue]];
    }
}

- (void)toCategoryVC:(NSString *)categoryAreaId {
    CategoryViewController *categoryVC = [[UIStoryboard storyboardWithName: @"CategoryVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CategoryViewController"];
    categoryVC.categoryAreaId = categoryAreaId;
    NSLog(@"categoryAreaId: %@", categoryAreaId);
    
    if ([categoryAreaId isEqualToString: @"-1"]) {
        categoryVC.dic = getTheMeAreaDic;
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: categoryVC animated: YES];
}

- (void)tapDetectedForURL:(NSInteger)page {
    NSLog(@"tapDetectedForURL");
    NSLog(@"page: %ld", (long)page);
    
    NSLog(@"adArray[page]: %@", adArray[page]);
    
    NSString *album = adArray[page][@"album"];
    NSString *event = adArray[page][@"event"];
    NSString *template = adArray[page][@"template"];
    NSString *user = adArray[page][@"user"];
    NSString *urlString = adArray[page][@"ad"][@"url"];
    
    NSLog(@"urlString: %@", urlString);
    
    if (album != (NSString *)[NSNull null]) {
        NSString *albumIdString = [adArray[page][@"album"][@"album_id"] stringValue];
        
        if (![albumIdString isEqualToString: @""]) {
            AlbumDetailViewController *aDVC = [[UIStoryboard storyboardWithName: @"AlbumDetailVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumDetailViewController"];
            aDVC.albumId = albumIdString;
            
            CATransition *transition = [CATransition animation];
            transition.duration = 0.5;
            transition.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionFade;
            transition.subtype = kCATransitionFromTop;
            [self.navigationController.view.layer addAnimation: transition forKey: kCATransition];
            
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate.myNav pushViewController: aDVC animated: NO];
        }
    } else if (event != (NSString *)[NSNull null]) {
        NSString *eventIdString = [adArray[page][@"event"][@"event_id"] stringValue];
        
        if (![eventIdString isEqualToString: @""]) {
            [self getEventData: eventIdString];
        }
    } else if (template != (NSString *)[NSNull null]) {
        NSString *templateIdString = [adArray[page][@"template"][@"template_id"] stringValue];
        
        if (![templateIdString isEqualToString: @""]) {
            /*
             TaobanViewController *tv=[[TaobanViewController alloc]initWithNibName:@"TaobanViewController" bundle:nil];
             tv.temolateid = templateIdString;
             AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
             [app.myNav pushViewController:tv animated:YES];
             */
        }
    } else if (user != (NSString *)[NSNull null]) {
        NSString *userIdString = [adArray[page][@"user"][@"user_id"] stringValue];
        
        if (![userIdString isEqualToString: @""]) {
            CreaterViewController *cVC = [[UIStoryboard storyboardWithName: @"CreaterVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CreaterViewController"];
            cVC.userId = userIdString;
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate.myNav pushViewController: cVC animated: YES];
        }
    } else if (urlString != (NSString *)[NSNull null]) {
        if (![urlString isEqualToString: @""]) {
            NSURL *url = [NSURL URLWithString: urlString];
            NSLog(@"scheme: %@", [url scheme]);
            NSLog(@"host: %@", [url host]);
            NSLog(@"port: %@", [url port]);
            NSLog(@"path: %@", [url path]);
            NSLog(@"path components: %@", [url pathComponents]);
            NSLog(@"parameterString: %@", [url parameterString]);
            NSLog(@"query: %@", [url query]);
            NSLog(@"fragment: %@", [url fragment]);
            
            if ([[url path] isEqualToString: @"/index/album/explore"]) {
                if ([url query] != nil) {
                    NSString *query = [url query];
                    NSArray *bits = [query componentsSeparatedByString: @"="];
                    NSLog(@"bits: %@", bits);
                    NSString *key = bits[0];
                    NSString *value = bits[1];
                    NSLog(@"key: %@", key);
                    NSLog(@"value: %@", value);
                    
                    if ([key isEqualToString: @"categoryarea_id"]) {
                        NSLog(@"has categoryarea_id");
                        
                        CategoryViewController *categoryVC = [[UIStoryboard storyboardWithName: @"CategoryVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CategoryViewController"];
                        categoryVC.categoryAreaId = value;
                        NSLog(@"categoryVC.categoryAreaId: %@", categoryVC.categoryAreaId);
                        //categoryVC.categoryName = @"Test";
                        
                        if ([value isEqualToString: @"-1"]) {
                            categoryVC.dic = getTheMeAreaDic;
                        }
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate.myNav pushViewController: categoryVC animated: YES];
                    } else {
                        SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: [NSURL URLWithString: urlString] entersReaderIfAvailable: NO];
                        safariVC.preferredBarTintColor = [UIColor whiteColor];
                        [self presentViewController: safariVC animated: YES completion: nil];                                                
                    }
                }
            } else if ([[url path] isEqualToString: @"/index/user/point"]) {
                BuyPPointViewController *bPPVC = [[UIStoryboard storyboardWithName: @"BuyPointVC" bundle: nil] instantiateViewControllerWithIdentifier: @"BuyPPointViewController"];
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [appDelegate.myNav pushViewController: bPPVC animated: YES];
            } else {
                SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: [NSURL URLWithString: urlString] entersReaderIfAvailable: NO];
                safariVC.preferredBarTintColor = [UIColor whiteColor];
                [self presentViewController: safariVC animated: YES completion: nil];
                
                /*
                ActivityWebViewController *activityWebVC = [[UIStoryboard storyboardWithName: @"ActivityWebVC" bundle: nil] instantiateViewControllerWithIdentifier: @"ActivityWebViewController"];
                activityWebVC.eventURL = urlString;
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate.myNav pushViewController: activityWebVC animated: YES];
                 */
            }
        } else if ([urlString isEqualToString: @""]) {
            CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
            style.messageColor = [UIColor whiteColor];
            style.backgroundColor = [UIColor hintGrey];
            
            [self.view makeToast: @"無頁面跳轉"
                        duration: 2.0
                        position: CSToastPositionBottom
                           style: style];
            return;
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView
didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath: indexPath];
    //cell.contentView.backgroundColor = nil;
    //cell.contentView.subviews[0].backgroundColor = nil;
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"willDisplayCell");
    NSLog(@"indexPath.item: %ld", (long)indexPath.item);
    NSLog(@"pictures.count: %lu", (unsigned long)pictures.count);
    
    if (collectionView.tag == 1) {
        if (indexPath.item == (pictures.count - 1)) {
            [self loadData];
            isScrollingDown = YES;
        }
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"");
    NSLog(@"sizeForItemAtIndexPath");
    
    NSDictionary *data = pictures[indexPath.row];
    NSLog(@"album name: %@", data[@"album"][@"name"]);
    
    if (collectionView.tag == 1) {
        CGFloat itemWidth = roundf((self.view.frame.size.width - (miniInteriorSpacing * (columnCount + 1))) / columnCount);
        
        NSDictionary *data = pictures[indexPath.row];
        
        // Check Width & Height return value is nil or not
        NSNumber *coverWidth = data[@"album"][@"cover_width"];
        NSNumber *coverHeight = data[@"album"][@"cover_height"];
        NSLog(@"coverHeight: %@", coverHeight);
        
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
        
        NSLog(@"widthForCoverImg: %f", widthForCoverImg);
        NSLog(@"heightForCoverImg: %f", heightForCoverImg);
        
        if (heightForCoverImg < (36 * scale)) {
            heightForCoverImg = 36 * scale;
        }
        
        NSLog(@"heightForCoverImg: %f", heightForCoverImg);
        
        CGSize finalSize = CGSizeMake(widthForCoverImg, heightForCoverImg);
        finalSize = CGSizeMake(itemWidth, floorf(finalSize.height * itemWidth / finalSize.width));
        NSString *albumNameStr;
        
        if (![data[@"album"][@"name"] isEqual: [NSNull null]]) {
            albumNameStr = data[@"album"][@"name"];
        }
        
        finalSize = CGSizeMake(finalSize.width, finalSize.height + [self calculateHeightForLbl: albumNameStr width: itemWidth - 16]);
        
        NSLog(@"size :%@",NSStringFromCGSize(finalSize));
        
        return finalSize;
    } else if (collectionView.tag == 2){
        CGFloat bannerWidth = [UIScreen mainScreen].bounds.size.width;
        NSLog(@"bannerWidth: %f", bannerWidth);
        CGFloat bannerHeight = bannerWidth * 540 / 960;
        NSLog(@"bannerHeight: %f", bannerHeight);
        return CGSizeMake(bannerWidth, bannerHeight);
    } else {
        return CGSizeMake(112.0, 48.0);
    }
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
// Vertical Cell Spacing (If CollectionView is Horizontal)
// Horizontal Cell Spacing (If CollectionView is Vertical)
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    NSLog(@"minimumInteritemSpacingForSectionAtIndex");
    
    return 16.0f;
}

// Horizontal Cell Spacing (If CollectionView is Horizontal)
// Vertical Cell Spacing (If CollectionView is Vertical)
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    NSLog(@"minimumLineSpacingForSectionAtIndex");
    
    if (collectionView.tag == 1) {
        return 16.0f;
    } else if (collectionView.tag == 2) {
        return 0.0f;
    } else {
        return 16.0f;
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets itemInset = UIEdgeInsetsMake(0, 16, 0, 16);
    
    if (collectionView.tag == 2) {
        itemInset = UIEdgeInsetsMake(0, 0, 0, 0);
        return itemInset;
    } else {
        itemInset = UIEdgeInsetsMake(0, 16, 0, 16);
        return itemInset;
    }
}

#pragma mark - JCCollectionViewWaterfallLayoutDelegate
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
 heightForHeaderInSection:(NSInteger)section
{
    return self.jccLayout.headerHeight;
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //NSLog(@"scrollViewDidScroll");
    
    if (scrollView == self.collectionView2) {
        //NSLog(@"scrollView == self.collectionView2");
        self.pageControl.currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
    }
//    if ([scrollView isKindOfClass: [MyScrollView class]]) {
//        NSLog(@"scrollView isKindOfClass MyScrollView");
//        pageControl.currentPage = mySV.contentOffset.x / mySV.frame.size.width;
//    }
    if (isLoading) {
        //NSLog(@"isLoading: %d", isLoading);
        return;
    }
    
    /*
    if (scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height * 2) {
        [self loadData];
    }
     */
}

#pragma mark -

- (NSString *)translateToTimeStr: (NSString *)diffTime
{
    NSArray *timeArray = [diffTime componentsSeparatedByString: @","];
//    NSLog(@"timeArray: %@", timeArray);
    
    NSString *timeDiffStr;
    
    NSInteger year = [timeArray[0] integerValue];
    NSInteger month = [timeArray[1] integerValue];
    NSInteger day = [timeArray[2] integerValue];
    NSInteger hour = [timeArray[3] integerValue];
    NSInteger min = [timeArray[4] integerValue];
    
    if (year > 0) {
        timeDiffStr = [NSString stringWithFormat: @"%ld 年前", (long)year];
    } else if (year == 0) {
        if (month > 0) {
            timeDiffStr = [NSString stringWithFormat: @"%ld 月前", (long)month];
        } else if (month == 0) {
            if (day > 0) {
                timeDiffStr = [NSString stringWithFormat: @"%ld 天前", (long)day];
            } else if (day == 0) {
                if (hour > 0) {
                    timeDiffStr = [NSString stringWithFormat: @"%ld 小時前", (long)hour];
                } else if (hour == 0) {
                    if (min > 0) {
                        timeDiffStr = [NSString stringWithFormat: @"%ld 分前", (long)min];
                    } else if (min == 0) {
                        timeDiffStr = [NSString stringWithFormat: @"剛剛"];
                    }
                }
            }
        }
    }
//    NSLog(@"timeDiffStr: %@", timeDiffStr);
    
    return timeDiffStr;
}

- (void)addTestBtn
{
    UIButton *testBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    [testBtn addTarget: self action: @selector(startAnimating) forControlEvents: UIControlEventTouchUpInside];
    testBtn.frame = CGRectMake(self.view.bounds.origin.x + 260, self.view.bounds.origin.y + 300, 50, 50);
    
    [testBtn setTitle: @"停止GIF" forState: UIControlStateNormal];
    
    [testBtn setImage: [UIImage imageNamed: @"icon_teal500_circle_plus"] forState: UIControlStateNormal];
    [testBtn setImage: [UIImage imageNamed: @"icon_teal500_circle_plus_press"]
             forState: UIControlStateSelected | UIControlStateHighlighted];
    
    UIButton *testBtn1 = [UIButton buttonWithType: UIButtonTypeCustom];
    [testBtn1 addTarget: self action: @selector(stopAnimating) forControlEvents: UIControlEventTouchUpInside];
    testBtn1.frame = CGRectMake(self.view.bounds.origin.x + 260, self.view.bounds.origin.y + 400, 50, 50);
    
    [testBtn1 setTitle: @"停止GIF" forState: UIControlStateNormal];
    
    [testBtn1 setImage: [UIImage imageNamed: @"icon_teal500_circle_plus"] forState: UIControlStateNormal];
    [testBtn1 setImage: [UIImage imageNamed: @"icon_teal500_circle_plus_press"]
             forState: UIControlStateSelected | UIControlStateHighlighted];
    
    [self.view addSubview: testBtn];
    [self.view addSubview: testBtn1];
}

- (void)startAnimating
{
    NSLog(@"startAnimating");
    [flaImageView startAnimating];
}

- (void)stopAnimating
{
    NSLog(@"stopAnimating");
    [flaImageView stopAnimating];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - CustomUpdateAlert
- (void)showCustomUpdateAlert:(NSString *)msg
                       option:(NSString *)option {
    NSLog(@"showCustomUpdateAlert");
    
    CustomIOSAlertView *alertUpdateView = [[CustomIOSAlertView alloc] init];
    [alertUpdateView setContainerView: [self createVersionUpdateView: msg]];
    
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertUpdateView.arrangeStyle = @"Vertical";
    //alertUpdateView.parentView = self.view;
    
    if ([option isEqualToString: @"mustUpdate"]) {
        [alertUpdateView setButtonTitles: [NSMutableArray arrayWithObject: @"前往App Store"]];
        [alertUpdateView setButtonColors: [NSMutableArray arrayWithObject: [UIColor clearColor]]];
        [alertUpdateView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor firstGrey]]];
        [alertUpdateView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor darkMain]]];
    } else if ([option isEqualToString: @"canUpdateLater"]) {
        [alertUpdateView setButtonTitles: [NSMutableArray arrayWithObjects: @"下次再說", @"前往App Store", nil]];
        [alertUpdateView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor clearColor], [UIColor clearColor],nil]];
        [alertUpdateView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
        [alertUpdateView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    }
    
    __weak CustomIOSAlertView *weakAlertUpdateView = alertUpdateView;
    [alertUpdateView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertUpdateView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertUpdateView tag]);
        
        if ([option isEqualToString: @"mustUpdate"]) {
            if (buttonIndex == 0) {
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString: appStoreUrl]];
                //[weakAlertUpdateView close];
            }
        } else if ([option isEqualToString: @"canUpdateLater"]) {
            if (buttonIndex == 0) {
                [weakAlertUpdateView close];
                [self initApp];
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject: [NSNumber numberWithBool: YES] forKey: @"hasNewVersion"];
                [defaults synchronize];
            } else {
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString: appStoreUrl]];
                //[weakAlertUpdateView close];
            }
        }
    }];
    [alertUpdateView setUseMotionEffects: YES];
    [alertUpdateView show];
}

- (UIView *)createVersionUpdateView:(NSString *)msg {
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

#pragma mark - Custom Error Alert Method
- (void)showCustomErrorAlert: (NSString *)msg
{
    CustomIOSAlertView *errorAlertView = [[CustomIOSAlertView alloc] init];
    [errorAlertView setContainerView: [self createErrorContainerView: msg]];
    
    [errorAlertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    [errorAlertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    [errorAlertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    errorAlertView.arrangeStyle = @"Horizontal";
    
    __weak CustomIOSAlertView *weakErrorAlertView = errorAlertView;
    [errorAlertView setOnButtonTouchUpInside:^(CustomIOSAlertView *customAlertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[customAlertView tag]);
        [weakErrorAlertView close];
    }];
    [errorAlertView setUseMotionEffects: YES];
    [errorAlertView show];
}

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

#pragma mark - Custom Method for TimeOut
- (void)showCustomTimeOutAlert: (NSString *)msg
                  protocolName: (NSString *)protocolName
                       eventId: (NSString *)eventId
{
    CustomIOSAlertView *alertTimeOutView = [[CustomIOSAlertView alloc] init];
    [alertTimeOutView setContainerView: [self createTimeOutContainerView: msg]];
    
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertTimeOutView.arrangeStyle = @"Horizontal";
    
    alertTimeOutView.parentView = self.view;
    [alertTimeOutView setButtonTitles: [NSMutableArray arrayWithObjects: NSLocalizedString(@"TimeOut-CancelBtnTitle", @""), NSLocalizedString(@"TimeOut-OKBtnTitle", @""), nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertTimeOutView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstMain],nil]];
    [alertTimeOutView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor whiteColor], nil]];
    [alertTimeOutView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    
    __weak typeof(self) weakSelf = self;
    __weak CustomIOSAlertView *weakAlertTimeOutView = alertTimeOutView;
    [alertTimeOutView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertTimeOutView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertTimeOutView tag]);
        
        [weakAlertTimeOutView close];
        
        if (buttonIndex == 0) {
            
        } else {
            if ([protocolName isEqualToString: @"updatelist"]) {
                [weakSelf updateList];
            } else if ([protocolName isEqualToString: @"getAdList"]) {
                [weakSelf checkAd];
            } else if ([protocolName isEqualToString: @"geturpoints"]) {
                [weakSelf getUrPoints];
            } else if ([protocolName isEqualToString: @"doTask1"]) {
                [weakSelf checkPoint];
            } else if ([protocolName isEqualToString: @"getEvent"]) {
                [weakSelf getEventData: eventId];
            } else if ([protocolName isEqualToString: @"checkVersion"]) {
                [weakSelf checkVersion];
            } else if ([protocolName isEqualToString: @"retrievecatgeorylist"]) {
                [weakSelf getCategoryList];
            } else if ([protocolName isEqualToString: @"getTheMeArea"]) {
                [weakSelf getTheMeArea];
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

- (void)closeApp {
    NSLog(@"closeApp");
    // home button press programmatically
    UIApplication *app = [UIApplication sharedApplication];
    [app performSelector: @selector(suspend)];
    
    // wait 2 seconds while app is going background
    [NSThread sleepForTimeInterval: 0.5];
    
    // exit app when app is in background
    exit(0);
}

- (void)dealloc
{
    [self removeNotification];
}

@end
