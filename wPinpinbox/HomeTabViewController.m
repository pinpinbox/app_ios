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

#import "SearchTabCollectionViewCell.h"
#import "SearchTabHorizontalCollectionViewCell.h"
#import "SearchTabCollectionReusableView.h"
#import "NSString+MD5.h"
#import  <SystemConfiguration/SCNetworkReachability.h>
#import "QrcordViewController.h"
#import "UIViewController+ErrorAlert.h"

#import "RecommandCollectionViewCell.h"
#import "SwitchButtonView.h"

#import "YAlbumDetailContainerViewController.h"

#import "UserInfo.h"

#define kAdHeight 142
#define kBtnWidth 78
#define kBtnGap 16


@interface HomeTabViewController () <UICollectionViewDataSource, UICollectionViewDelegate, JCCollectionViewWaterfallLayoutDelegate, UICollectionViewDelegateFlowLayout, SFSafariViewControllerDelegate, UIGestureRecognizerDelegate, RMPZoomTransitionAnimating, UIViewControllerTransitioningDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
{
    BOOL isLoading;
    BOOL isReloading;
    NSInteger nextId;
    NSMutableArray *pictures;
    
    // For Ad
    NSArray *adArray;
    NSInteger selectItem;
    //UIPageControl *pageControl;
    
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
    
    CGFloat headerHeight;
    CGFloat topContentOffset;
    
    UILabel *followUserLabel;
    UIView *followUserHorzView;
    UILabel *followAlbumLabel;
    UIView *followAlbumHorzView;
    
    UILabel *recommendationLabel;
    UIView *recommendationHorzView;
    
    NSDictionary *getTheMeAreaDic;
    
    NSMutableArray *followUserData;
    NSMutableArray *followAlbumData;
    
    // For Search
    BOOL isSearchTextFieldSelected;
    
    BOOL isAlbumLoading;
    BOOL isAlbumReloading;
    NSInteger nextAlbumId;
    
    BOOL isUserLoading;
    BOOL isUserReloading;
    NSInteger nextUserId;
    
    NSMutableArray *albumData;
    NSMutableArray *userData;
    
    UILabel *userRecommendationLabel;
    UILabel *albumRecommendationLabel;
    
    UITextField *selectTextField;
    
    UIView *noInfoVertView;
    UIView *noInfoHorzView;
    
    //    BOOL isSearching;
    BOOL isNoInfoVertViewCreate;
    BOOL isNoInfoHorzViewCreate;
    
    CGFloat oldNavBarViewYValue;
    
    BOOL isViewLoading;
    
    BOOL wantToGetNewsLetter;
}
@property (nonatomic, strong) JCCollectionViewWaterfallLayout *jccLayout;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UICollectionView *homeCollectionView;
@property (weak, nonatomic) UICollectionView *bannerCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *categoryCollectionView;
@property (weak, nonatomic) UICollectionView *followUserCollectionView;
@property (weak, nonatomic) UICollectionView *followAlbumCollectionView;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) UIImageView *zoomView;

// For Search
@property (nonatomic, strong) JCCollectionViewWaterfallLayout *jccLayout1;

@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarHeight;
@property (weak, nonatomic) IBOutlet UICollectionView *albumCollectionView;
@property (weak, nonatomic) UICollectionView *userCollectionView;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *scanBtn;
@property (weak, nonatomic) IBOutlet CustomTintButton *categoryBtn;

@property (nonatomic, assign) CGFloat lastContentOffset;
@property (nonatomic) UITableView *recommandListView;

@property (nonatomic, strong) NSMutableArray *hotListArray;
@property (nonatomic, strong) NSMutableArray *justJoinedListArray;

@end

@implementation HomeTabViewController

#pragma mark - Notificaiton Setting for Gif
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(appEnterBackground:) name: UIApplicationDidEnterBackgroundNotification object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(appEnterForeground:) name: UIApplicationWillEnterForegroundNotification object: nil];
}

- (void)removeNotification {
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

- (void)appEnterBackground: (NSNotification *)notif {
    NSLog(@"");
    NSLog(@"HomeTabVC");
    NSLog(@"appEnterBackground");
    [flaImageView stopAnimating];
}

- (void)appEnterForeground: (NSNotification *)notif {
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
    
    NSLog(@"UserId: %@", [wTools getUserID]);
    
    isSearchTextFieldSelected = NO;
    self.albumCollectionView.hidden = YES;
    isViewLoading = YES;
    
    self.searchView.layer.cornerRadius = 8;
    self.searchView.backgroundColor = [UIColor thirdGrey];
    self.scanBtn.layer.cornerRadius = kCornerRadius;
    self.scanBtn.backgroundColor = [UIColor thirdGrey];
    
    oldNavBarViewYValue = self.navBarView.frame.origin.y;
    NSLog(@"self.navBarView.frame.origin.y: %f", self.navBarView.frame.origin.y);
    
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
    [self settingSizeBasedOnDevice];
    
    [self.categoryBtn setImage:[UIImage imageNamed:@"ic200_category_dark"] forState:UIControlStateNormal];
    [self.categoryBtn setTitleColor:[UIColor firstGrey] forState:UIControlStateSelected];
    [self.categoryBtn setTitleColor:[UIColor secondGrey] forState:UIControlStateNormal];
    [self.categoryBtn setTintColor:[UIColor secondGrey]];
    
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"");
    NSLog(@"HomeTabViewController viewWillAppear");
    [super viewWillAppear:animated];
    NSLog(@"status bar height: %f", [UIApplication sharedApplication].statusBarFrame.size.height);
    
    [self removeNotification];
    [self addNotification];
    
    // Central Button
    for (UIView *view in self.tabBarController.view.subviews) {
        UIButton *btn = (UIButton *)[view viewWithTag: 104];
        btn.hidden = NO;
    }
    [wTools sendScreenTrackingWithScreenName:@"首頁"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeNotification];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)settingSizeBasedOnDevice {
    self.navBarHeight.constant = 48;
    topContentOffset = self.navBarView.frame.size.height;
    headerHeight = 1006;//871;
    self.homeCollectionView.contentInset = UIEdgeInsetsMake(topContentOffset, 0, 0, 0);
    
    self.jccLayout = (JCCollectionViewWaterfallLayout *)self.homeCollectionView.collectionViewLayout;
    self.jccLayout1 = (JCCollectionViewWaterfallLayout *)self.albumCollectionView.collectionViewLayout;
    
    self.jccLayout.headerHeight = headerHeight;
    self.jccLayout.footerHeight = 0.0f;
    
    self.jccLayout1.headerHeight = 250;
    
    self.albumCollectionView.contentInset = UIEdgeInsetsMake(48, 0, 0, 0);
    if (self.homeCollectionView.contentOffset.y <= 0.0)
        self.homeCollectionView.contentOffset = CGPointMake(0,-topContentOffset);
}

#pragma mark - Push Notification Setting
- (void)setupPushNotification {
    NSLog(@"\n\nsetupPushNotification");
    //  already registered //
    if (![wTools isRegisterAWSNeeded]) return ;
    
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
                //  if response is TIMEDOUT, retry API
                if ([awsResponse isEqualToString:timeOutErrorCode]) {
                    UIDevice *device = [UIDevice currentDevice];
                    NSString *currentDeviceId = [[device identifierForVendor] UUIDString];
                    NSString *result = [boxAPI setawssns:[wTools getUserID] token:[wTools getUserToken] devicetoken:[wTools getUUID] identifier: currentDeviceId];
                    [wTools processAWSResponse: result];
                } else {
                    [wTools processAWSResponse: awsResponse];
                }
                NSLog(@"awsResponse: %@", awsResponse);
            }
        });
    });
}

#pragma mark - Version Update
- (void)checkVersion {
    NSLog(@"call checkVersion");
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *version = [self getVersion];
        NSLog(@"version: %@", version);
        
        __block typeof(self) wself = self;
        NSString *response = [boxAPI checkUpdateVersion: @"apple" version: version];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"checkVersion Response != nil");
                if (![wself checkTimedOut:response api:@"checkVersion" eventId:@"" text:@""]) {
                    NSLog(@"Get Real Response");
                    NSLog(@"response from checkVersion");
                    NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableLeaves error: nil];
                    //NSLog(@"data: %@", data);
                    
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
                    } else {
                        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
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
    isViewLoading = NO;
    [self initialValueSetup];
    //[self addCategoryBtn];
    [self loadData];
}

- (void)initialValueSetup {
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
    [self.homeCollectionView addSubview: self.refreshControl];
    
    columnCount = 2;
    miniInteriorSpacing = 16;
    
    self.pageControl.hidden = YES;
    
    // For Search
    self.navBarView.backgroundColor = [UIColor barColor];
    
    // Search TextField
    self.searchTextField.textColor = [UIColor blackColor];
    
    UIToolbar *numberToolBar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 0, 320, 40)];
    numberToolBar.barStyle = UIBarStyleDefault;
    numberToolBar.items = [NSArray arrayWithObjects:
                           //[[UIBarButtonItem alloc] initWithTitle: @"取消" style: UIBarButtonItemStylePlain target: self action: @selector(cancelNumberPad)],
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil],
                           [[UIBarButtonItem alloc] initWithTitle: @"完成" style: UIBarButtonItemStyleDone target: self action: @selector(dismissKeyboard)], nil];
    
    self.searchTextField.inputAccessoryView = numberToolBar;
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)toScanCode:(id)sender {
    if (isSearchTextFieldSelected) {
        UIButton *btn = (UIButton *)sender;
        [btn setImage: [UIImage imageNamed: @"ic200_scancamera_dark"] forState: UIControlStateNormal];
        [self dismissKeyboard];
        self.searchTextField.text = @"";
        isSearchTextFieldSelected = NO;
        self.homeCollectionView.hidden = NO;
    } else {
        QrcordViewController *qVC = [[UIStoryboard storyboardWithName: @"QRCodeVC" bundle: nil] instantiateViewControllerWithIdentifier: @"QrcordViewController"];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.myNav pushViewController: qVC animated: YES];
    }
}

#pragma mark - <RMPZoomTransitionAnimating>
- (UIImageView *)transitionSourceImageView {
    NSLog(@"transitionSourceImageView");
    NSLog(@"self.zoomView.image: %@", self.zoomView.image);
    UIImageView *imageView = [[UIImageView alloc] initWithImage: self.zoomView.image];
    imageView.contentMode = self.zoomView.contentMode;
    imageView.clipsToBounds = YES;
    imageView.userInteractionEnabled = NO;
    imageView.frame = [self.zoomView convertRect: self.zoomView.frame toView: self.homeCollectionView.superview];
    return imageView;
}

- (UIColor *)transitionSourceBackgroundColor {
    return self.homeCollectionView.backgroundColor;
}

- (CGRect)transitionDestinationImageViewFrame {
    CGRect frameInSuperView = [self.zoomView convertRect: self.zoomView.frame toView: self.homeCollectionView.superview];
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
        [self.homeCollectionView reloadData];
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
    [wTools ShowMBProgressHUD];
    
    NSMutableDictionary *data = [NSMutableDictionary new];
    NSString *limit = [NSString stringWithFormat: @"%ld,%d", (long)nextId, 16];
    
    NSLog(@"limit: %@", limit);
    
    [data setValue: limit forKey: @"limit"];
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI updatelist: [wTools getUserID]
                                          token: [wTools getUserToken]
                                           data: data
                                           rank: wself->rankType];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"response from updateList");
                //NSLog(@"response: %@", response);
                if ([wself checkTimedOut:response api:@"updatelist" eventId:@"" text:@""]) {
                    [wself.refreshControl endRefreshing];
                    wself->isReloading = NO;
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    NSLog(@"dic: %@", dic);
                    [wself processUpdateListResult:dic];
                }
            } else {
                [wself.refreshControl endRefreshing];
                wself->isReloading = NO;
            }
        });
    });
}

- (void)processUpdateListResult:(NSDictionary *)dic {
    if ([dic[@"result"] intValue] == 1) {
        //NSLog(@"dic: %@", dic[@"data"]);
        
        NSLog(@"Before");
        NSLog(@"nextId: %ld", (long)nextId);
        
        if (nextId == 0) {
            //[pictures removeAllObjects];
            pictures = [NSMutableArray new];
        }
        
        // s for counting how much data is loaded
        int s = 0;
        
        if (![wTools objectExists: dic[@"data"]]) {
            return;
        }
        
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
        [self.homeCollectionView reloadData];
        
        isReloading = NO;
        
        if (isScrollingDown) {
            isScrollingDown = NO;
        } else {
            [self checkAd];
        }
        
        NSLog(@"-------------------------");
        NSLog(@"nextId: %ld", (long)nextId);
        
        // display notification content after login
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app checkInitialLaunchCase];
        
    } else if ([dic[@"result"] intValue] == 0) {
        NSLog(@"失敗：%@",dic[@"message"]);
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

#pragma mark - Web Service - GetAdList
- (void)checkAd {
    NSLog(@"");
    NSLog(@"");
    NSLog(@"checkAd");
    
    @try {
        //        [MBProgressHUD showHUDAddedTo: self.view animated: YES];
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI getAdList: [wTools getUserID]
                                         token: [wTools getUserToken]
                                     adarea_id: @"1"];
        
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
                NSLog(@"checkAd Response");
                //NSLog(@"reponse: %@", response);
                
                if (![wself checkTimedOut:response api:@"getAdList" eventId:@"" text:@""]) {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableLeaves error: nil];
                    [wself processCheckAdResult:dic];
                }
            }
        });
    });
}

- (void)processCheckAdResult:(NSDictionary *)dic {
    if ([dic[@"result"] intValue] == 1) {
        NSLog(@"GetAd Success");
        
        adArray = dic[@"data"];
        
        // Check array data is 0 or more than 0
        NSLog(@"adArray: %@", adArray);
        NSLog(@"adArray.count: %lu", (unsigned long)adArray.count);
        
        if (![wTools objectExists: adArray]) {
            return;
        }
        
        [self.bannerCollectionView reloadData];
        self.pageControl.numberOfPages = adArray.count;
        self.pageControl.hidden = NO;
        
        [self getCategoryList];
    } else if ([dic[@"result"] intValue] == 0) {
        NSLog(@"失敗：%@",dic[@"message"]);
        if ([wTools objectExists: dic[@"message"]]) {
            [self showCustomErrorAlert: dic[@"message"]];
        } else {
            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
        }
    } else {
        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
    }
}

- (void)getCategoryList {
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
    __block typeof(self) wself = self;
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
                if (![wself checkTimedOut:response api:@"retrievecatgeorylist" eventId:@"" text:@""])  {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    [wself processGetCategoryListResult:dic];
                }
            }
        });
    });
}

- (void)processGetCategoryListResult:(NSDictionary *)dic {
    if ([dic[@"result"] intValue] == 1) {
        NSLog(@"dic data: %@", dic[@"data"]);
        if (![wTools objectExists: dic[@"data"]]) {
            return;
        }
        
        categoryArray = [NSMutableArray arrayWithArray: dic[@"data"]];
        
        followUserLabel.hidden = NO;
        followUserHorzView.hidden = NO;
        followAlbumLabel.hidden = NO;
        followAlbumHorzView.hidden = NO;
        
        recommendationLabel.hidden = NO;
        recommendationHorzView.hidden = NO;
        
        //[self.categoryCollectionView reloadData];
        
        [self getTheMeArea];
    } else if ([dic[@"result"] intValue] == 0) {
        NSLog(@"失敗：%@",dic[@"message"]);
        if ([wTools objectExists: dic[@"message"]]) {
            [self showCustomErrorAlert: dic[@"message"]];
        } else {
            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
        }
    } else {
        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
    }
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
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"Standard:%@,%@\n\n USerInfo: %@,%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"token"],[[NSUserDefaults standardUserDefaults] objectForKey:@"id"],[wTools getUserToken] ,[wTools getUserID]);
        NSString *response = [boxAPI getTheMeArea: [wTools getUserToken] userId: [wTools getUserID]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"response from getTheMeArea");
                
                if (![wself checkTimedOut:response api:@"getTheMeArea" eventId:@"" text:@""]) {
                    NSLog(@"Get Real Response");
                    NSLog(@"Get response from getTheMeArea");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    [wself processGetMeAreaResult:dic];
                }
            }
        });
    });
}

- (void)processGetMeAreaResult:(NSDictionary *)dic {
    if ([dic[@"result"] isEqualToString: @"SYSTEM_OK"]) {
        NSLog(@"SYSTEM_OK");
        getTheMeAreaDic = dic;
        
        NSLog(@"dic data albumexplore: %@", dic[@"data"][@"albumexplore"]);
        NSLog(@"data themearea: %@", dic[@"data"][@"themearea"]);
        
        NSLog(@"Before");
        NSLog(@"categoryArray: %@", categoryArray);
        
        NSString *colorHexStr = dic[@"data"][@"themearea"][@"colorhex"];
        NSString *nameStr = dic[@"data"][@"themearea"][@"name"];
        NSString *imageStr = dic[@"data"][@"themearea"][@"image_360x360"];
        
        if (![wTools objectExists: dic[@"data"][@"themearea"]]) {
            return;
        }
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject: [NSNumber numberWithInteger: -1] forKey: @"categoryarea_id"];
        [dic setObject: colorHexStr forKey: @"colorhex"];
        [dic setObject: nameStr forKey: @"name"];
        [dic setObject: imageStr forKey: @"image_360x360"];
        
        NSMutableDictionary *dicData = [[NSMutableDictionary alloc] init];
        [dicData setObject: dic forKey: @"categoryarea"];
        
        NSLog(@"dicData: %@", dicData);
        
        [categoryArray insertObject: dicData atIndex: 0];
        NSLog(@"After");
        NSLog(@"categoryArray: %@", categoryArray);
        
        [self.categoryCollectionView reloadData];
        
        [self showUserRecommendedList];
    } else if ([dic[@"result"] isEqualToString: @"SYSTEM_ERROR"]) {
        NSLog(@"SYSTEM_ERROR");
        NSLog(@"失敗：%@",dic[@"message"]);
        if ([wTools objectExists: dic[@"message"]]) {
            [self showCustomErrorAlert: dic[@"message"]];
        } else {
            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
        }
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

- (void)logOut {
    [wTools logOut];
}
#pragma mark - Get Newly joined user list (116)
- (void)showNewJoinUsersList {
    [wTools ShowMBProgressHUD];
    __block typeof(self) wself = self;
    NSUInteger count = _justJoinedListArray? _justJoinedListArray.count:0;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = @"";
        response = [boxAPI getNewJoinList:[NSString stringWithFormat:@"%lu, 16",(unsigned long)count]
                                    token:[wTools getUserToken]
                                   userId:[wTools getUserID]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            if (response) {
                if (![wself checkTimedOut:response api:@"getNewJoinList" eventId:@"" text:@""]){
                    
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if (![dic[@"result"] isEqualToString:@"SYSTEM_OK"]) {
                        NSLog(@"showHotList result: %@", dic[@"result"]);
                        
                        if (dic[@"message"])
                            [wself showCustomErrorAlert: dic[@"message"]];
                        else
                            [wself showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                        
                        return ;
                    }
                    
                    [wself processNewJoinedList:dic];
                }
            }
            
        });
        
    });
}
- (void)processNewJoinedList:(NSDictionary *)dict {
    
    if ([dict[@"result"] isEqualToString:@"SYSTEM_OK"]){
        NSArray *users = dict[@"data"];
        if (users && users.count ) {
            if (!self.justJoinedListArray)
                self.justJoinedListArray = [NSMutableArray array];
            
            [self.justJoinedListArray addObjectsFromArray:users];
            
            [self.followUserCollectionView reloadData];
            [self showAlbumRecommendedList];
        }
    }
}
#pragma mark - Get hotlist (115)
- (void)showHotList {
    
    [wTools ShowMBProgressHUD];
    __block typeof(self) wself = self;
    NSUInteger count = _hotListArray? _hotListArray.count:0;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = @"";
        
        response = [boxAPI getHotList:[NSString stringWithFormat:@"%lu, 6",(unsigned long)count]
                                token:[wTools getUserToken]
                               userId:[wTools getUserID]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            if (response) {
                if (![wself checkTimedOut:response api:@"getHotList" eventId:@"" text:@""]){
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if (![dic[@"result"] isEqualToString:@"SYSTEM_OK"]) {
                        NSLog(@"showHotList result: %@", dic[@"result"]);
                        
                        if (dic[@"message"])
                            [wself showCustomErrorAlert: dic[@"message"]];
                        else
                            [wself showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                        
                        return ;
                    }
                    
                    [wself processHotList:dic];
                }
            }
        });
    });
}
- (void)processHotList:(NSDictionary *)dict {
    
    if ([dict[@"result"] isEqualToString:@"SYSTEM_OK"]) {
        NSArray *users = dict[@"data"];
        if (users && users.count ) {
            if (!self.hotListArray)
                self.hotListArray = [NSMutableArray array];
            
            [self.hotListArray removeAllObjects];
            NSIndexPath *p = [NSIndexPath indexPathForRow:0 inSection:1];
            RecommandListViewCell *cell = (RecommandListViewCell *)[self.recommandListView cellForRowAtIndexPath:p];
            UICollectionView *c = cell.recommandListView;
            
            NSUInteger count =  self.hotListArray.count;
            NSMutableArray *index = [NSMutableArray array];
            
            [self.hotListArray addObjectsFromArray:users];
            
            if (count <= 0) {
                [self.recommandListView reloadSections:[[NSIndexSet alloc] initWithIndex:1] withRowAnimation:UITableViewRowAnimationMiddle];
                //  get new joined list
                [self showNewJoinUsersList];
            } else {
                for (NSUInteger i = 0;i < users.count; i++ ){
                    [index addObject:[NSIndexPath indexPathForItem:i+count inSection:0]];
                }
                [c insertItemsAtIndexPaths:index];
            }
            
            
            //[self.recommandListView reloadSections:[[NSIndexSet alloc] initWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            
            
        }
    }
}
#pragma mark - Get Recommended User List
- (void)showUserRecommendedList {
    [wTools ShowMBProgressHUD];
    __block typeof(self) wself = self;
    NSUInteger count = followUserData? followUserData.count:0;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = @"";
        NSMutableDictionary *data = [NSMutableDictionary new];
        [data setObject: @"user" forKey: @"type"];
        [data setObject: [NSString stringWithFormat:@"%lu, 6",(unsigned long)count] forKey: @"limit"];
        
        response = [boxAPI getRecommendedList: [wTools getUserID]
                                        token: [wTools getUserToken]
                                         data: data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            if (response != nil) {
                NSLog(@"showUserRecommendedList");
                NSLog(@"response from getRecommendedList");
                if (![wself checkTimedOut:response api:@"showUserRecommendedList" eventId:@"" text:@""]) {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    if (![dic[@"result"] boolValue]) {
                        NSLog(@"showUserRecommendedList result: %@", dic[@"result"]);
                        return ;
                    }
                    [wself processUserRecommandedListResult:dic];
                }
            }
        });
    });
}

- (void)processUserRecommandedListResult:(NSDictionary *)dic {
    
    if ([dic[@"result"] intValue] == 1) {
        
        NSArray *list = dic[@"data"];
        
        if (![wTools objectExists: list]) {
            return;
        }
        if (list && list.count) {
            if (!followUserData)
                followUserData = [[NSMutableArray alloc] init];
            
            [followUserData removeAllObjects];
            
            NSIndexPath *p = [NSIndexPath indexPathForRow:0 inSection:0];
            RecommandListViewCell *cell = (RecommandListViewCell *)[self.recommandListView cellForRowAtIndexPath:p];
            UICollectionView *c = cell.recommandListView;
            
            NSUInteger count =  followUserData.count;
            NSMutableArray *index = [NSMutableArray array];
            
            [followUserData addObjectsFromArray:list];
            
            if (count <= 0) {
                [self.recommandListView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationMiddle];
                [self showHotList];
            } else {
                for (NSUInteger i = 0;i < list.count; i++ ){
                    [index addObject:[NSIndexPath indexPathForItem:i+count inSection:0]];
                }
                [c insertItemsAtIndexPaths:index];
            }
        }
    } else if ([dic[@"result"] intValue] == 0) {
        NSLog(@"失敗：%@",dic[@"message"]);
        [self showCustomErrorAlert: dic[@"message"]];
    } else {
        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
    }
}

- (void)showAlbumRecommendedList {
    [wTools ShowMBProgressHUD];
    
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = @"";
        NSMutableDictionary *data = [NSMutableDictionary new];
        [data setObject: @"album" forKey: @"type"];
        [data setObject: @"0,16" forKey: @"limit"];
        
        response = [boxAPI getRecommendedList: [wTools getUserID]
                                        token: [wTools getUserToken]
                                         data: data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"showAlbumRecommendedList");
                NSLog(@"response from showAlbumRecommendedList");
                
                if (![wself checkTimedOut:response api:@"showAlbumRecommendedList" eventId:@"" text:@""]) {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic =  (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if (![dic[@"result"] boolValue]) {
                        return ;
                    }
                    //判斷目前table和 搜尋結果是否相同
                    if (![data[@"type"] isEqualToString: @"album"]) {
                        return;
                    }
                    [wself processAlbumRecommandedListResult:dic];
                }
            }
        });
    });
}

- (void)processAlbumRecommandedListResult:(NSDictionary *)dic {
    if ([dic[@"result"] intValue] == 1) {
        
        if (![wTools objectExists: dic[@"data"]]) {
            return;
        }
        followAlbumData = [NSMutableArray arrayWithArray: dic[@"data"]];
        
        NSLog(@"followAlbumData.count: %lu", (unsigned long)followAlbumData.count);
        //[self.followAlbumCollectionView reloadData];
        [self.recommandListView reloadData];
        [self checkFirstTimeLogin];
    } else if ([dic[@"result"] intValue] == 0) {
        NSLog(@"失敗：%@",dic[@"message"]);
        if ([wTools objectExists: dic[@"message"]]) {
            [self showCustomErrorAlert: dic[@"message"]];
        } else {
            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
        }
    } else {
        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
    }
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
        [activityButton setTitleColor: [UIColor colorWithRed: 26.0/255.0 green: 196.0/255.0 blue: 199.0/255.0 alpha: 1.0]
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
- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    // Done button pressed
    NSLog(@"show");
    [alertView show];
}

#pragma mark - Check Point Task
- (void)checkFirstTimeLogin {
    NSLog(@"checkFirstTimeLogin");
    // Check whether getting login point or not
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL firsttime_login = [[defaults objectForKey: @"firsttime_login"] boolValue];
    
    //firsttime_login = YES;
    NSLog(@"Check whether getting Login point or not");
    NSLog(@"firstTimeLogin: %d", (int)firsttime_login);
    
    if (firsttime_login) {
        NSLog(@"Get the Login Point Already");
        [self newsLetterCheck];
    } else {
        [self checkPoint];
    }
}

- (void)newsLetterCheck {
    NSLog(@"newsLetterCheck");
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    NSLog(@"newsLetterCheck key: %@", [userPrefs objectForKey: @"newsLetterCheck"]);
    
    if ([[userPrefs objectForKey: @"newsLetterCheck"] isEqual: [NSNull null]]) {
        NSLog(@"newsLetterCheck is null");
    } else {
        if ([[userPrefs objectForKey: @"newsLetterCheck"] isEqualToString: @"NeedToCheck"]) {
            NSLog(@"NeedToCheck");
            [self showCustomNewsLetterCheckAlert: @"願意收到電子報，掌握最新創作及抽獎資訊(預設為接收)"];
        }
    }
}

#pragma mark - Check Point Method
- (void)checkPoint {
    NSLog(@"checkPoint");
    __block typeof(self)wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSString *response = [boxAPI doTask1: [wTools getUserID]
                                       token: [wTools getUserToken]
                                    task_for: @"firsttime_login"
                                    platform: @"apple"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response != nil) {
                NSLog(@"response from doTask1");
                
                if (![wself checkTimedOut:response api:@"doTask1" eventId:@"" text:@""]){
                    NSLog(@"Get Real Response");
                    NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    [wself processCheckPointResult:data];
                }
            }
        });
    });
}

- (void)processCheckPointResult:(NSDictionary *)data {
    NSLog(@"processCheckPointResult");
    NSLog(@"result: %d", [data[@"result"] intValue]);
    
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
        
        [self newsLetterCheck];
    } else if ([data[@"result"] intValue] == 0) {
        NSString *errorMessage = data[@"message"];
        NSLog(@"error messsage: %@", errorMessage);
        [self newsLetterCheck];
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
        //        [MBProgressHUD showHUDAddedTo: self.view animated: YES];
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI geturpoints: [userPrefs objectForKey:@"id"]
                                           token: [userPrefs objectForKey:@"token"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                //                [MBProgressHUD hideHUDForView: self.view animated: YES];
                [wTools HideMBProgressHUD];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                return;
            }
            if (response != nil) {
                NSLog(@"response from geturpoints");
                
                
                if (![wself checkTimedOut:response api:@"geturpoints" eventId:@"" text:@""]) {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"dic result boolValue is 1");
                        NSInteger point = [dic[@"data"] integerValue];
                        //NSLog(@"point: %ld", (long)point);
                        
                        [userPrefs setObject: [NSNumber numberWithInteger: point] forKey: @"pPoint"];
                        [userPrefs synchronize];
                        
                        [self newsLetterCheck];
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗：%@",dic[@"message"]);
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
    
    __block typeof(self) wself = self;
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
                
                if (![wself checkTimedOut:response api:@"getEvent" eventId:eventId text:@""]) {
                    NSLog(@"Get Real Response");
                    NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableLeaves error: nil];
                    NSLog(@"data: %@", data);
                    
                    if ([data[@"result"] intValue] == 1) {
                        NSLog(@"result is 1");
                        NSLog(@"GetEvent Success");
                        if (![wTools objectExists: data[@"data"][@"event"]]) {
                            return;
                        }
                        [self toNewEventPostVC: data
                                       eventId: eventId
                                 eventFinished: NO];
                    } else if ([data[@"result"] intValue] == 2) {
                        NSLog(@"result is 2");
                        NSLog(@"event_templatejoin: %@", data[@"data"][@"event_templatejoin"]);
                        if (![wTools objectExists: data[@"data"][@"event"]]) {
                            return;
                        }
                        
                        [self toNewEventPostVC: data
                                       eventId: eventId
                                 eventFinished: YES];
                    } else if ([data[@"result"] intValue] == 0) {
                        NSLog(@"失敗： %@", data[@"message"]);
                        if ([wTools objectExists: data[@"message"]]) {
                            [self showCustomErrorAlert: data[@"message"]];
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

- (void)toNewEventPostVC:(NSDictionary *)data
                 eventId:(NSString *)eventId
           eventFinished:(BOOL)eventFinished {
    NewEventPostViewController *newEventPostVC = [[UIStoryboard storyboardWithName: @"NewEventPostVC" bundle: nil] instantiateViewControllerWithIdentifier: @"NewEventPostViewController"];
    newEventPostVC.name = data[@"data"][@"event"][@"name"];
    newEventPostVC.eventTitle = data[@"data"][@"event"][@"title"];
    newEventPostVC.imageUrl = data[@"data"][@"event"][@"image"];
    newEventPostVC.urlString = data[@"data"][@"event"][@"url"];
    newEventPostVC.templateArray = data[@"data"][@"event_templatejoin"];
    newEventPostVC.eventId = eventId;
    newEventPostVC.contributionNumber = [data[@"data"][@"event"][@"contribution"] integerValue];
    newEventPostVC.popularityNumber = [data[@"data"][@"event"][@"popularity"] integerValue];
    newEventPostVC.prefixText = data[@"data"][@"event"][@"prefix_text"];
    newEventPostVC.specialUrl = data[@"data"][@"special"][@"url"];
    newEventPostVC.contributeStartTime = data[@"data"][@"event"][@"contribute_starttime"];
    newEventPostVC.contributeEndTime = data[@"data"][@"event"][@"contribute_endtime"];
    newEventPostVC.voteStartTime = data[@"data"][@"event"][@"vote_starttime"];
    newEventPostVC.voteEndtime = data[@"data"][@"event"][@"vote_endtime"];
    newEventPostVC.eventFinished = eventFinished;
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: newEventPostVC animated: YES];
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    if (collectionView.tag == 1) {
        return pictures.count;
    } else if (collectionView.tag == 2) {
        return adArray.count;
    } else if (collectionView.tag == 3) {
        return categoryArray.count-1;
    } else if (collectionView.tag == 4) {
        return self.justJoinedListArray.count;
    } else if (collectionView.tag == 5) {
        
        return followAlbumData.count;
    } else if (collectionView.tag == 6) {
        return albumData.count;
    } else if (collectionView.tag == 71){
        return followUserData.count;
    } else if (collectionView.tag == 72) {
        return self.hotListArray.count;
    } else {
        return userData.count;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"");
    //NSLog(@"viewForSupplementaryElementOfKind");
    
    //NSLog(@"collectionView.tag: %ld", (long)collectionView.tag);
    
    if (collectionView.tag == 1) {
        HomeDataCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind: kind withReuseIdentifier: @"headerId" forIndexPath: indexPath];
        self.pageControl = headerView.pageControl;
        
        self.bannerCollectionView = headerView.homeBannerCollectionView;
        //self.categoryCollectionView = headerView.categoryCollectionView;
        self.followUserCollectionView = headerView.followUserCollectionView;
        self.followAlbumCollectionView = headerView.followAlbumCollectionView;
        
        followUserLabel = headerView.followUserLabel;
        [LabelAttributeStyle changeGapString: followUserLabel content: followUserLabel.text];
        followUserHorzView = headerView.followUserHorzView;
        
        followAlbumLabel = headerView.followAlbumLabel;
        [LabelAttributeStyle changeGapString: followAlbumLabel content: followAlbumLabel.text];
        followAlbumHorzView = headerView.followAlbumHorzView;
        
        recommendationLabel = headerView.recommendationLabel;
        [LabelAttributeStyle changeGapString: recommendationLabel content: recommendationLabel.text];
        
        recommendationHorzView = headerView.recommendationHorzView;
        
        self.recommandListView = headerView.recommandListView;
        
        [self.homeCollectionView.collectionViewLayout invalidateLayout];
        
        return headerView;
    } else if (collectionView.tag == 3) {
        HomeCategoryCollectionHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind: kind withReuseIdentifier: @"CategoryHeader" forIndexPath: indexPath];
        header.backgroundColor = UIColor.clearColor;
        if (categoryArray && categoryArray.count) {
            __block NSDictionary *top = [categoryArray firstObject][@"categoryarea"];
            if (![top[@"image_360x360"] isEqual: [NSNull null]]) {
                NSString *str = top[@"image_360x360"];
                [header.headerImage sd_setImageWithURL: [NSURL URLWithString: str]
                                      placeholderImage: [UIImage imageNamed: @"bg200_no_image.jpg"]];
            }
            __block typeof(self) wself = self;
            
            header.tapBlock = ^{
                
                [wself toCategoryVC: [top[@"categoryarea_id"] stringValue]
                    categoryNameStr: top[@"name"]];
            };
        }
        return header;
    } else {
        NSLog(@"SearchTabCollectionReusableView *headerView");
        SearchTabCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind: kind withReuseIdentifier: @"SearchHeaderId" forIndexPath: indexPath];
        
        self.userCollectionView = headerView.userCollectionView;
        
        userRecommendationLabel = headerView.userRecommendationLabel;
        [LabelAttributeStyle changeGapString: userRecommendationLabel content: userRecommendationLabel.text];
        
        albumRecommendationLabel = headerView.albumRecommendationLabel;
        [LabelAttributeStyle changeGapString: albumRecommendationLabel content: albumRecommendationLabel.text];
        
        [self.albumCollectionView.collectionViewLayout invalidateLayout];
        
        return headerView;
    }
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
                        [self extracted: indexPath];
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
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"");
    //NSLog(@"cellForItemAtIndexPath");
    //NSLog(@"collectionView.tag: %ld", (long)collectionView.tag);
    
    if (collectionView.tag == 1) {
       // NSLog(@"collectionView.tag == 1");
        HomeDataCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"HomeDataCell" forIndexPath: indexPath];
        NSDictionary *data = pictures[indexPath.row];
        
        cell.contentView.subviews[0].backgroundColor = nil;
        
        if ([data[@"album"][@"cover"] isEqual: [NSNull null]]) {
            cell.coverImageView.image = [UIImage imageNamed: @"bg_2_0_0_no_image.jpg"];
        } else {
            [cell.coverImageView sd_setImageWithURL: [NSURL URLWithString: data[@"album"][@"cover"]]];            
            cell.coverImageView.backgroundColor = [UIColor colorFromHexString: data[@"album"][@"cover_hex"]];
            /*
            [cell.coverImageView sd_setImageWithURL: [NSURL URLWithString: data[@"album"][@"cover"]] placeholderImage:[UIImage imageNamed:@"bg200_no_image.jpg"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                if (error) {
                    cell.coverImageView.image = [UIImage imageNamed: @"bg_2_0_0_no_image"] ;
                } else
                    cell.coverImageView.image = image;
            }];
            */
            if ([data[@"album"][@"cover_hex"] isKindOfClass: [NSNull class]]) {
                cell.coverImageView.backgroundColor = [UIColor clearColor];
            } else {
                cell.coverImageView.backgroundColor = [UIColor colorFromHexString: data[@"album"][@"cover_hex"]];
            }
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
        //NSLog(@"collectionView.tag == 2");
        HomeBannerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"HomeBannerCell" forIndexPath: indexPath];
        //NSLog(@"adArray: %@", adArray);
        NSDictionary *adData = adArray[indexPath.row];
        __block typeof(self) wself = self;
        [cell loadCellWithData:adData indexPath:indexPath completionBlock:^(NSIndexPath *indexpath, HomeBannerCollectionViewCell *cell) {
            [wself checkToPresentViewOrNot:indexPath cell:cell];
        }];
        return cell;
    } else if (collectionView.tag == 3) {
        //NSLog(@"collectionView.tag == 3");
        HomeCategoryCollectionViewCell *cell = nil;
        cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"CategoryCell" forIndexPath: indexPath];
        
        if (indexPath.row + 1 < categoryArray.count) {
            
            NSDictionary *dic = categoryArray[indexPath.row+1][@"categoryarea"];
            
            NSLog(@"dic name: %@", dic[@"name"]);
            NSLog(@"dic image_360x360: %@", dic[@"image_360x360"]);
            
            if (![dic[@"image_360x360"] isEqual: [NSNull null]]) {
                [cell.categoryImageView sd_setImageWithURL: [NSURL URLWithString: dic[@"image_360x360"]]
                                          placeholderImage: [UIImage imageNamed: @"bg200_no_image.jpg"]];
            }
            
            if (![dic[@"name"] isEqual:[NSNull null]]) {
                cell.categoryNameLabel.text = dic[@"name"];
                //[LabelAttributeStyle changeGapString: cell.categoryNameLabel content: dic[@"name"]];
            }
        }
        return cell;
    } else if (collectionView.tag == 4) {
        //NSLog(@"collectionView.tag == 4");
        NSDictionary *userDic = self.justJoinedListArray[indexPath.row][@"user"];
        
        SearchTabHorizontalCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"horizontalCell" forIndexPath: indexPath];
        
        if (![userDic isKindOfClass: [NSNull class]]) {
            if ([userDic[@"picture"] isEqual: [NSNull null]]) {
                cell.userPictureImageView.image = [UIImage imageNamed: @"member_back_head.png"];
            } else {
                [cell.userPictureImageView sd_setImageWithURL: [NSURL URLWithString: userDic[@"picture"]]
                                             placeholderImage: [UIImage imageNamed: @"member_back_head.png"]];
            }
            cell.userNameLabel.text = userDic[@"name"];
            [LabelAttributeStyle changeGapString: cell.userNameLabel content: cell.userNameLabel.text];
        } else {
            NSLog(@"userData is nil");
        }
        return cell;
    } else if (collectionView.tag == 5) {
        //NSLog(@"collectionView.tag == 5");
        
        RecommandCollectionViewCell *cell =  [collectionView dequeueReusableCellWithReuseIdentifier: @"RecommandCollectionViewCell" forIndexPath: indexPath];
        cell.albumImageView.backgroundColor = UIColor.purpleColor;
        cell.albumDesc.text = [NSString stringWithFormat:@"%ld -- %ld\n\n=======",(long)indexPath.section, (long)indexPath.row];
        cell.personnelView.backgroundColor = UIColor.yellowColor;
        
        return cell;
    } else if (collectionView.tag == 6) {
        //NSLog(@"collectionView.tag == 6");
        //        NSLog(@"isSearching: %d", isSearching);
        albumRecommendationLabel.text = @"找到的作品";
        [LabelAttributeStyle changeGapString: albumRecommendationLabel content: albumRecommendationLabel.text];
        
        NSLog(@"SearchTabCollectionViewCell *cell");
        SearchTabCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SearchCell" forIndexPath: indexPath];
        cell.contentView.subviews[0].backgroundColor = nil;
        
        NSLog(@"albumData.count: %lu", (unsigned long)albumData.count);
        
        if (albumData.count == 0) {
            noInfoVertView.hidden = NO;
        } else if (albumData.count > 0) {
            noInfoVertView.hidden = YES;
        }
        
        NSDictionary *albumDic = albumData[indexPath.row][@"album"];
        //NSLog(@"albumDic: %@", albumDic);
        
        if ([albumDic[@"cover"] isEqual: [NSNull null]]) {
            cell.coverImageView.image = [UIImage imageNamed: @"bg_2_0_0_no_image"];
        } else {
            //[cell.coverImageView sd_setImageWithURL: [NSURL URLWithString: albumDic[@"cover"]]
            //                       placeholderImage: [UIImage imageNamed: @"bg_2_0_0_no_image"]];
            
            [cell.coverImageView sd_setImageWithURL: [NSURL URLWithString: albumDic[@"cover"]] placeholderImage:[UIImage imageNamed:@"bg200_no_image.jpg"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                if (error) {
                    cell.coverImageView.image = [UIImage imageNamed: @"bg_2_0_0_no_image"] ;
                } else
                    cell.coverImageView.image = image;
                
            }];
        }
        
        // UserForView Info Setting
        BOOL gotAudio = [albumDic[@"usefor"][@"audio"] boolValue];
        BOOL gotVideo = [albumDic[@"usefor"][@"video"] boolValue];
        BOOL gotExchange = [albumDic[@"usefor"][@"exchange"] boolValue];
        BOOL gotSlot = [albumDic[@"usefor"][@"slot"] boolValue];
        
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
            NSLog(@"gotExchange or gotSlot");
            
            cell.userInfoView.hidden = NO;
            [cell.btn3 setImage: [UIImage imageNamed: @"ic200_gift_dark"] forState: UIControlStateNormal];
            
            CGRect rect = cell.userInfoView.frame;
            rect.size.width = 28 * 1;
            cell.userInfoView.frame = rect;
        }
        
        // AlbumNameLabel Setting
        if (![albumDic[@"name"] isEqual: [NSNull null]]) {
            cell.albumNameLabel.text = albumDic[@"name"];
            [LabelAttributeStyle changeGapString: cell.albumNameLabel content: cell.albumNameLabel.text];
        }
        NSLog(@"cell.albumNameLabel.text: %@", cell.albumNameLabel.text);
        NSLog(@"cell.imgBgView.frame: %@", NSStringFromCGRect(cell.imgBgView.frame));
        
        return cell;
    } else if (collectionView.tag == 71 || collectionView.tag == 72){
        
        RecommandCollectionViewCell *c = [collectionView dequeueReusableCellWithReuseIdentifier: @"RecommandCollectionViewCell" forIndexPath:indexPath];
        NSDictionary *data = followUserData[indexPath.row];
        if (collectionView.tag == 72)
            data = self.hotListArray[indexPath.row];
        
        NSDictionary *user = data[@"user"];
        c.albumImageView.image = [UIImage imageNamed: @"bg200_user_default"];
        if ([user[@"cover"] isEqual: [NSNull null]]) {
            c.albumImageView.image = [UIImage imageNamed: @"bg200_user_default"];
        } else {
            [c.albumImageView sd_setImageWithURL: [NSURL URLWithString: user[@"cover"]]
                                placeholderImage: [UIImage imageNamed: @"bg200_user_default"]];
        }
        
        if (user[@"picture"] && ![user[@"picture"] isEqual: [NSNull null]]) {
            [c.personnelView sd_setImageWithURL:[NSURL URLWithString:user[@"picture"]]
                               placeholderImage: [UIImage imageNamed: @"member_back_head"]];
        } else {
            c.personnelView.image = [UIImage imageNamed:@"member_back_head"];
            c.personnelView.backgroundColor = [UIColor secondGrey];
        }
        
        if (user[@"description"] && ![user[@"description"] isEqual: [NSNull null]]) {
            c.albumDesc.text = user[@"description"];
        }
        c.personnelView.layer.cornerRadius = 16;
        c.personnelView.clipsToBounds = YES;
        c.albumImageView.layer.cornerRadius = 8;
        c.albumImageView.clipsToBounds = YES;
        
        return c;
    } else {
        //NSLog(@"collectionView.tag == 7");
        userRecommendationLabel.text = @"找到的創作人";
        [LabelAttributeStyle changeGapString: userRecommendationLabel content: userRecommendationLabel.text];
        
        if (userData.count == 0) {
            noInfoHorzView.hidden = NO;
        } else if (userData.count > 0) {
            noInfoHorzView.hidden = YES;
        }
        NSDictionary *userDic = userData[indexPath.row][@"user"];
        
        SearchTabHorizontalCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"horizontalCell" forIndexPath: indexPath];
        
        cell.contentView.backgroundColor = nil;
        //        cell.userPictureImageView.imageURL = nil;
        
        if (![userDic isKindOfClass: [NSNull class]]) {
            if ([userDic[@"picture"] isEqual: [NSNull null]]) {
                cell.userPictureImageView.image = [UIImage imageNamed: @"member_back_head.png"];
            } else {
                [cell.userPictureImageView sd_setImageWithURL: [NSURL URLWithString: userDic[@"picture"]]
                                             placeholderImage: [UIImage imageNamed: @"member_back_head.png"]];
            }
            cell.userNameLabel.text = userDic[@"name"];
            [LabelAttributeStyle changeGapString: cell.userNameLabel content: cell.userNameLabel.text];
        } else {
            NSLog(@"userData is nil");
        }
        return cell;
    }
}

#pragma mark - UICollectionViewDelegate Methods
- (BOOL)collectionView:(UICollectionView *)collectionView
shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath: indexPath];
    NSLog(@"cell.contentView.subviews: %@", cell.contentView.subviews);
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectItemAtIndexPath");
    if (collectionView.tag == 1) {
        HomeDataCollectionViewCell *cell = (HomeDataCollectionViewCell *)[collectionView cellForItemAtIndexPath: indexPath];
        NSLog(@"cell.contentView.subviews: %@", cell.contentView.subviews);
        
        //cell.contentView.subviews[0].backgroundColor = [UIColor thirdMain];
        NSLog(@"cell.contentView.bounds: %@", NSStringFromCGRect(cell.contentView.bounds));
        NSLog(@"pictures: %@", pictures[indexPath.row]);
        
        NSDictionary *data = pictures[indexPath.row];
        NSString *albumId = [data[@"album"][@"album_id"] stringValue];
        CGRect source = [self.view convertRect:cell.frame fromView:collectionView];
        [self toAlbumDetailVC: albumId source:source sourceImage:cell.coverImageView];
    } else if (collectionView.tag == 2) {
        [self tapDetectedForURL: indexPath.row];
    } else if (collectionView.tag == 3) {
        if (indexPath.row + 1 < categoryArray.count) {
            NSDictionary *data = categoryArray[indexPath.row+1];
            //NSLog(@"data: %@", data);
            NSLog(@"categoryarea: %@", data[@"categoryarea"]);
            NSLog(@"categoryarea_id: %@", [data[@"categoryarea"][@"categoryarea_id"] stringValue]);
            
            NSDictionary *categoryareaDic = data[@"categoryarea"];
            
            [self toCategoryVC: [categoryareaDic[@"categoryarea_id"] stringValue]
               categoryNameStr: categoryareaDic[@"name"]];
        }
    } else if (collectionView.tag == 4) {
        NSDictionary *userDic = self.justJoinedListArray[indexPath.row][@"user"];
        [self toCreatorVC: userDic[@"user_id"]];
    } else if (collectionView.tag == 5) {
        
    } else if (collectionView.tag == 6) {
        NSDictionary *albumDic = albumData[indexPath.row][@"album"];
        SearchTabCollectionViewCell *cell = (SearchTabCollectionViewCell *)[collectionView cellForItemAtIndexPath: indexPath];
        CGRect source = [self.view convertRect:cell.frame fromView:collectionView];
        [self toAlbumDetailVC: [albumDic[@"album_id"] stringValue] source:source sourceImage:cell.coverImageView];
    } else if (collectionView.tag == 71 || collectionView.tag == 72) {
        NSDictionary *userDic = followUserData[indexPath.row][@"user"];
        if (collectionView.tag == 72)
            userDic = self.hotListArray[indexPath.row][@"user"];
        [self toCreatorVC: userDic[@"user_id"]];
    } else {
        NSDictionary *userDic = userData[indexPath.row][@"user"];
        [self toCreatorVC: userDic[@"user_id"]];
    }
}

- (void)toAlbumDetailVC:(NSString *)albumId  source:(CGRect)source sourceImage:(UIImageView *)sourceImage{
    NSLog(@"toAlbumDetailVC");
    if (![wTools objectExists: albumId]) {
        return;
    }
    NSLog(@"After objectExists check");
    YAlbumDetailContainerViewController *aDVC = [[UIStoryboard storyboardWithName: @"AlbumDetailVC" bundle: nil] instantiateViewControllerWithIdentifier: @"YAlbumDetailContainerViewController"];

    aDVC.sourceRect = source;
    aDVC.album_id = albumId;
    aDVC.sourceView = sourceImage;
    aDVC.zoomTransitionController.toDelegate = aDVC;
    aDVC.zoomTransitionController.fromDelegate = aDVC;
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.delegate = aDVC.zoomTransitionController;
    [appDelegate.myNav pushViewController: aDVC animated: YES];
}

- (void)toCreatorVC:(NSString *)userId {
    if (![wTools objectExists: userId]) {
        return;
    }
    CreaterViewController *cVC = [[UIStoryboard storyboardWithName: @"CreaterVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CreaterViewController"];
    cVC.userId = userId;
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: cVC animated: YES];
}

- (void)toCategoryVC:(NSString *)categoryAreaId
     categoryNameStr:(NSString *)categoryNameStr {
    if (![wTools objectExists: categoryAreaId]) {
        return;
    }
    
    CategoryViewController *categoryVC = [[UIStoryboard storyboardWithName: @"CategoryVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CategoryViewController"];
    categoryVC.categoryAreaId = categoryAreaId;
    
    NSLog(@"categoryAreaId: %@", categoryAreaId);
    
    if ([categoryAreaId isEqualToString: @"-1"]) {
        categoryVC.dic = getTheMeAreaDic;
        categoryVC.categoryNameStr = categoryNameStr;
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
didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    //    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath: indexPath];
    //cell.contentView.backgroundColor = nil;
    //cell.contentView.subviews[0].backgroundColor = nil;
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    //    NSLog(@"willDisplayCell");
    //    NSLog(@"indexPath.item: %ld", (long)indexPath.item);
    //    NSLog(@"pictures.count: %lu", (unsigned long)pictures.count);
    
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
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"");
    NSLog(@"sizeForItemAtIndexPath");
    
    if (collectionView.tag == 1) {
        //  Recommanded albums
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
    } else if (collectionView.tag == 2) {
        // ad banners 
        return CGSizeMake(343,237);//bannerWidth, bannerHeight);
    } else if (collectionView.tag == 3) {
        // category
        return CGSizeMake(163.0, 163.0);
    } else if (collectionView.tag == 4) {
        //  follow user collection
        return CGSizeMake(96.0, 121.0);
    } else if (collectionView.tag == 5) {
        
        return CGSizeMake(273, 168);
    } else if (collectionView.tag == 6) {
        //  album collection view , search
        CGFloat itemWidth = roundf((self.view.frame.size.width - (miniInteriorSpacing * (columnCount + 1))) / columnCount);
        NSDictionary *data = albumData[indexPath.row][@"album"];
        
        //NSLog(@"data: %@", data);
        NSLog(@"data name: %@", data[@"name"]);
        
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
        
        if (![data[@"album"][@"name"] isEqual: [NSNull null]]) {
            albumNameStr = data[@"album"][@"name"];
        }
        
        finalSize = CGSizeMake(finalSize.width, finalSize.height + [self calculateHeightForLbl: albumNameStr width: itemWidth - 16] * 2);
        
        NSLog(@"size: %@",NSStringFromCGSize(finalSize));
        
        return finalSize;
    } else if (collectionView.tag == 71 || collectionView.tag == 72) {
        return CGSizeMake(273,168);
    }else {
        return CGSizeMake(96, 130);
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
        return 8.0f;
    } else if (collectionView.tag == 3) {
        return 16.0f;
    } else if (collectionView.tag == 4) {
        return 16.0f;
    } else if (collectionView.tag == 5) {
        return 16.0f;
    } else if (collectionView.tag == 6) {
        return 24.0f;
    } else {
        return 24.0f;
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    UIEdgeInsets itemInset = UIEdgeInsetsMake(0, 16, 0, 16);
    return itemInset;
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (scrollView == self.bannerCollectionView) {
        
        *targetContentOffset = scrollView.contentOffset; // set acceleration to 0.0
        float pageWidth = 343;
        int minSpace = 16;
        int cellToSwipe = (scrollView.contentOffset.x - 16)/(pageWidth + minSpace);
        cellToSwipe = (velocity.x < 0)? cellToSwipe: cellToSwipe+1;

        //cellToSwipe = (scrollView.contentOffset.x)/(pageWidth + minSpace)+0.15;
        // cell width + min spacing for lines
        if (cellToSwipe < 0) {
            cellToSwipe = 0;
            [self.bannerCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:cellToSwipe inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
        } else if (cellToSwipe >= adArray.count) {
            cellToSwipe = (int)adArray.count - 1;
            [self.bannerCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:cellToSwipe inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
        } else {
        
            [self.bannerCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:cellToSwipe inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        }
    
    }
}
#pragma mark - JCCollectionViewWaterfallLayoutDelegate
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
 heightForHeaderInSection:(NSInteger)section {
    if (collectionView.tag == 1) {
        return self.jccLayout.headerHeight;
    } else if (collectionView.tag == 2) {
        return 0;
    } else {
        return self.jccLayout1.headerHeight;
    }
}

#pragma mark - UIScrollViewDelegate Methods
//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat offset = scrollView.contentOffset.x;
    if (offset+self.view.frame.size.width >= scrollView.contentSize.width) {
        if (scrollView.tag == 4) {
            [self showNewJoinUsersList];
        } else if (scrollView.tag == 72) {
            //[self showHotList];
        } else if (scrollView.tag == 71) {
            //[self showUserRecommendedList];
        }
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [selectTextField resignFirstResponder];
    
    if (scrollView.hidden) return;
    //NSLog(@"scrollViewDidScroll");
    
//    if (scrollView == self.bannerCollectionView) {
//        //NSLog(@"scrollView == self.bannerCollectionView");
//        self.pageControl.currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
//    }
    
    if (scrollView == self.homeCollectionView) {
        NSLog(@"scrollView == self.homeCollectionView");
        
        NSLog(@"self.lastContentOffset: %f", self.lastContentOffset);
        NSLog(@"scrollView.contentOffset.y: %f", scrollView.contentOffset.y);
        
        if (!isViewLoading) {
            if (self.lastContentOffset > scrollView.contentOffset.y) {
                NSLog(@"Scroll Up");
                [UIView animateWithDuration: 0.5 animations:^{
                    self.navBarView.hidden = NO;
                    [self.navBarView layoutIfNeeded];
                }];
            } else {
                NSLog(@"Scroll Down");
                [UIView animateWithDuration: 0.5 animations:^{
                    self.navBarView.hidden = YES;
                    [self.navBarView layoutIfNeeded];
                }];
            }
        }
    }
    
    
    
    self.lastContentOffset = scrollView.contentOffset.y;
    if (self.lastContentOffset < 0) {
        self.lastContentOffset = 0;
    }
    

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

- (NSString *)translateToTimeStr: (NSString *)diffTime {
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

- (void)addTestBtn {
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

- (void)startAnimating {
    NSLog(@"startAnimating");
    [flaImageView startAnimating];
}

- (void)stopAnimating {
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

#pragma mark - UITextField Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    selectTextField = textField;
    self.homeCollectionView.hidden = YES;
    [self onSwitchCategoryViewHidden:YES];
    
    isSearchTextFieldSelected = YES;
    [self.scanBtn setImage: [UIImage imageNamed: @"ic200_cancel_dark"]
                  forState: UIControlStateNormal];
    
    //    if ([textField.text isEqualToString: @""]) {
    //        self.albumCollectionView.hidden = YES;
    //    } else {
    //        self.albumCollectionView.hidden = NO;
    //    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    selectTextField = nil;
    self.scanBtn.hidden = NO;
    self.categoryBtn.hidden = NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    NSLog(@"shouldChangeCharactersInRange");
    NSString *resultString = [textField.text stringByReplacingCharactersInRange: range
                                                                     withString: string];
    
    if ([resultString isEqualToString: @""]) {
        NSLog(@"no text");
        noInfoHorzView.hidden = YES;
        noInfoVertView.hidden = YES;
    } else {
        NSLog(@"has text");
    }
    [self callProtocol: resultString];
    
    return YES;
}

#pragma mark - Search Session
- (void)callProtocol: (NSString *)text {
    NSLog(@"callProtocol");
    NSLog(@"text: %@", text);
    self.albumCollectionView.hidden = NO;
    [self filterUserContentForSearchText: text];
    
    //    if ([text isEqualToString: @""]) {
    //        isSearching = NO;
    //        self.albumCollectionView.hidden = YES;
    //    } else {
    //        isSearching = YES;
    //        self.albumCollectionView.hidden = NO;
    
    //[self filterAlbumContentForSearchText: text];
    //    }
    //    NSLog(@"isSearching: %d", isSearching);
}

- (void)processFilterUserContentResult:(NSDictionary *)dic text:(NSString *)text{
    if ([dic[@"result"] intValue] == 1) {
        NSLog(@"dic result boolValue is 1");
        
        if (nextUserId >= 0) {
            isUserLoading = NO;
        } else {
            isUserLoading = YES;
        }
        
        NSLog(@"");
        NSLog(@"");
        
        userData = [NSMutableArray arrayWithArray:dic[@"data"]];
        nextUserId = userData.count;
        
        //                        NSLog(@"userData: %@", userData);
        NSLog(@"userData.count: %lu", (unsigned long)userData.count);
        
        if (userData.count == 0) {
            if (!isNoInfoHorzViewCreate) {
                [self addNoInfoViewOnHorizontalCollectionView: @"沒有符合關鍵字的創作人"];
            }
            noInfoHorzView.hidden = NO;
        } else if (userData.count > 0) {
            noInfoHorzView.hidden = YES;
        }
        [self.userCollectionView reloadData];
        [self filterAlbumContentForSearchText: text];
        
    } else if ([dic[@"result"] intValue] == 0) {
        NSLog(@"失敗：%@",dic[@"message"]);
        if ([wTools objectExists: dic[@"message"]]) {
            [self showCustomErrorAlert: dic[@"message"]];
        } else {
            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
        }
    } else {
        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
    }
}

- (void)filterUserContentForSearchText: (NSString *)text {
    NSLog(@"filterUserContentForSearchText");
    NSLog(@"text: %@", text);
    
    NSString *string = text;
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        wself->isUserLoading = YES;
        
        NSString *response = @"";
        
        NSMutableDictionary *data = [NSMutableDictionary new];
        [data setObject: @"user" forKey: @"searchtype"];
        [data setObject: string forKey: @"searchkey"];
        [data setObject: @"0,32" forKey: @"limit"];
        /*
         response = [self search: [wTools getUserID]
         token: [wTools getUserToken]
         data: data];
         */
        response = [boxAPI search: [wTools getUserID]
                            token: [wTools getUserToken]
                             data: data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response != nil) {
                NSLog(@"filterUserContentForSearchText");
                NSLog(@"response from search");
                
                if (![wself checkTimedOut:response api:@"filterUserContentForSearchText" eventId:@"" text:text]) {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if (![dic[@"result"] boolValue]) {
                        return ;
                    }
                    //判斷回傳是否一樣
                    if (![text isEqualToString:string]) {
                        return;
                    }
                    //判斷目前table和 搜尋結果是否相同
                    if (![data[@"searchtype"] isEqualToString: @"user"]) {
                        return;
                    }
                    [wself processFilterUserContentResult:dic text:text];
                }
            }
        });
    });
}

- (void)processfilterAlbumContentResult:(NSDictionary *)dic {
    if ([dic[@"result"] intValue] == 1) {
        NSLog(@"dic result boolValue is 1");
        
        if (nextAlbumId >= 0) {
            isAlbumLoading = NO;
        } else {
            isAlbumLoading = YES;
        }
        NSLog(@"");
        NSLog(@"");
        
        albumData = [NSMutableArray arrayWithArray:dic[@"data"]];
        nextAlbumId = albumData.count;
        
        if (albumData.count == 0) {
            if (!isNoInfoVertViewCreate) {
                [self addNoInfoViewOnVerticalCollectionView: @"沒有符合關鍵字的作品"];
            }
            noInfoVertView.hidden = NO;
        } else if (albumData.count > 0) {
            noInfoVertView.hidden = YES;
        }
        
        [self.albumCollectionView reloadData];
    } else if ([dic[@"result"] intValue] == 0) {
        NSLog(@"失敗：%@",dic[@"message"]);
        if ([wTools objectExists: dic[@"message"]]) {
            [self showCustomErrorAlert: dic[@"message"]];
        } else {
            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
        }
    } else {
        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
    }
}

- (void)filterAlbumContentForSearchText: (NSString *)text {
    NSLog(@"filterAlbumContentForSearchText");
    NSLog(@"text: %@", text);
    NSString *string = text;
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        wself->isAlbumLoading = YES;
        
        NSString *response = @"";
        
        NSMutableDictionary *data = [NSMutableDictionary new];
        [data setObject: @"album" forKey: @"searchtype"];
        [data setObject: string forKey: @"searchkey"];
        [data setObject: @"0,32" forKey: @"limit"];
        
        response = [boxAPI search: [wTools getUserID]
                            token: [wTools getUserToken]
                             data: data];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response != nil) {
                NSLog(@"filterAlbumContentForSearchText");
                NSLog(@"response from search");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"SearchTableViewController");
                    NSLog(@"filterAlbumContentForSearchText");
                    [wself dismissKeyboard];
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                     protocolName: @"filterAlbumContentForSearchText"
                                          eventId: @""
                                             text: text];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    if (![dic[@"result"] boolValue]) {
                        return ;
                    }
                    //判斷回傳是否一樣
                    if (![text isEqualToString:string]) {
                        return;
                    }
                    //判斷目前table和 搜尋結果是否相同
                    if (![data[@"searchtype"] isEqualToString: @"album"]) {
                        return;
                    }
                    [wself processfilterAlbumContentResult:dic];
                }
            }
        });
    });
}

#pragma mark - Method Only Called Once
- (void)addNoInfoViewOnHorizontalCollectionView:(NSString *)msg {
    NSLog(@"addNoInfoViewOnHorizontalCollectionView");
    
    if (!isNoInfoHorzViewCreate) {
        noInfoHorzView = [[UIView alloc] initWithFrame: CGRectMake(16, 20, self.view.bounds.size.width - 32, 100)];
        noInfoHorzView.backgroundColor = [UIColor secondGrey];
        noInfoHorzView.layer.cornerRadius = 32;
        noInfoHorzView.clipsToBounds = YES;
        noInfoHorzView.hidden = YES;
        
        [self.userCollectionView addSubview: noInfoHorzView];
        [self.userCollectionView bringSubviewToFront: noInfoHorzView];
        
        MyFrameLayout *frameLayout = [self createFrameLayout];
        [noInfoHorzView addSubview: frameLayout];
        
        UILabel *label = [self createLabel: msg];
        [frameLayout addSubview: label];
    }
    isNoInfoHorzViewCreate = YES;
}

- (void)addNoInfoViewOnVerticalCollectionView:(NSString *)msg {
    NSLog(@"addNoInfoViewOnVerticalCollectionView");
    
    if (!isNoInfoVertViewCreate) {
        noInfoVertView = [[UIView alloc] initWithFrame: CGRectMake(16, 260, self.view.bounds.size.width - 32, 100)];
        noInfoVertView.backgroundColor = [UIColor secondGrey];
        noInfoVertView.layer.cornerRadius = 32;
        noInfoVertView.clipsToBounds = YES;
        noInfoVertView.hidden = YES;
        
        [self.albumCollectionView addSubview: noInfoVertView];
        [self.albumCollectionView bringSubviewToFront: noInfoVertView];
        
        MyFrameLayout *frameLayout = [self createFrameLayout];
        [noInfoVertView addSubview: frameLayout];
        
        UILabel *label = [self createLabel: msg];
        [frameLayout addSubview: label];
    }
    isNoInfoVertViewCreate = YES;
}

- (MyFrameLayout *)createFrameLayout {
    MyFrameLayout *frameLayout = [MyFrameLayout new];
    frameLayout.myMargin = 0;
    frameLayout.myCenterXOffset = 0;
    frameLayout.myCenterYOffset = 0;
    frameLayout.padding = UIEdgeInsetsMake(32, 32, 32, 32);
    
    return frameLayout;
}

- (UILabel *)createLabel: (NSString *)title {
    UILabel *label = [UILabel new];
    label.text = title;
    label.font = [UIFont systemFontOfSize: 17];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    
    [label sizeToFit];
    
    label.myCenterXOffset = 0;
    label.myCenterYOffset = 0;
    
    return label;
}

#pragma mark - CustomUpdateAlert
- (void)showCustomUpdateAlert:(NSString *)msg
                       option:(NSString *)option {
    NSLog(@"showCustomUpdateAlert");
    
    CustomIOSAlertView *alertUpdateView = [[CustomIOSAlertView alloc] init];
    //[alertUpdateView setContainerView: [self createVersionUpdateView: msg]];
    [alertUpdateView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
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
                //[[UIApplication sharedApplication] openURL: [NSURL URLWithString: appStoreUrl]];
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString: appStoreUrl] options:@{} completionHandler:nil];
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
                //[[UIApplication sharedApplication] openURL: [NSURL URLWithString: appStoreUrl]];
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString: appStoreUrl] options:@{} completionHandler:nil];
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
- (void)showCustomErrorAlert: (NSString *)msg {
    [UIViewController showCustomErrorAlertWithMessage:msg onButtonTouchUpBlock:^(CustomIOSAlertView * _Nullable customAlertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[customAlertView tag]);
        [customAlertView close];
    }];
}

- (UIView *)createErrorContainerView: (NSString *)msg {
    // TextView Setting
    UITextView *textView = [[UITextView alloc] initWithFrame: CGRectMake(16, 16, 268, 22)];
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
    
    
    CGFloat viewHeight;
    textViewY = kCustomIOSAlertViewDefaultButtonSpacerHeight;
    if ((textViewY + textViewHeight+ kCustomIOSAlertViewDefaultButtonSpacerHeight) > kMinAlertViewContentHeight) {
        if ((textViewY + textViewHeight+kCustomIOSAlertViewDefaultButtonSpacerHeight) > 450) {
            viewHeight = 450;
        } else {
            viewHeight = textViewY + textViewHeight+kCustomIOSAlertViewDefaultButtonSpacerHeight;
        }
    } else {
        viewHeight = kMinAlertViewContentHeight;
        
    }
    CGRect c = textView.frame;
    textView.frame = CGRectMake(c.origin.x, kCustomIOSAlertViewDefaultButtonSpacerHeight, c.size.width, textViewHeight);
    NSLog(@"demoHeight: %f", viewHeight);
    // ImageView Setting
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(300-kAlertContentBackgroundImageSize+kAlertContentBackgroundImageInset, viewHeight-(kAlertContentBackgroundImageSize-kAlertContentBackgroundImageInset), kAlertContentBackgroundImageSize, kAlertContentBackgroundImageSize)];
    [imageView setImage:[UIImage imageNamed:@"icon_2_0_0_dialog_error"]];
    
    
    // ContentView Setting
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, viewHeight)];
    contentView.backgroundColor = [UIColor firstPink];
    
    // Set up corner radius for only upper right and upper left corner
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: contentView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(6, 6.0)];
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
- (BOOL)checkTimedOut: (NSString *)result api:(NSString *)api eventId:(NSString *)eventId text:(NSString *)text{
    
    if ([result isEqualToString:timeOutErrorCode] ) {
        [self showCustomTimeOutAlert:NSLocalizedString(@"Connection-Timeout", @"")
                        protocolName:api
                             eventId:eventId
                                text:text];
        return YES;
    }
    return NO;
}
- (void)showCustomTimeOutAlert: (NSString *)msg
                  protocolName: (NSString *)protocolName
                       eventId: (NSString *)eventId
                          text: (NSString *)text {
    CustomIOSAlertView *alertTimeOutView = [[CustomIOSAlertView alloc] init];
    //[alertTimeOutView setContainerView: [self createTimeOutContainerView: msg]];
    [alertTimeOutView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    
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
            } else if ([protocolName isEqualToString: @"showUserRecommendedList"]) {
                [weakSelf showUserRecommendedList];
            } else if ([protocolName isEqualToString: @"showAlbumRecommendedList"]) {
                [weakSelf showAlbumRecommendedList];
            } else if ([protocolName isEqualToString: @"filterUserContentForSearchText"]) {
                [weakSelf filterUserContentForSearchText: text];
            } else if ([protocolName isEqualToString: @"filterAlbumContentForSearchText"]) {
                [weakSelf filterAlbumContentForSearchText: text];
            } else if ([protocolName isEqualToString: @"updateUser"]) {
                [weakSelf updateUser];
            } else if ([protocolName isEqualToString:@"getHotList"]) {
                [weakSelf showHotList];
            } else if ([protocolName isEqualToString:@"getNewJoinList"]) {
                [weakSelf showNewJoinUsersList];
            }
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

#pragma mark - showCustomNewsLetterCheckAlert
- (void)showCustomNewsLetterCheckAlert:(NSString *)msg {
    CustomIOSAlertView *alertViewForNewsLetterCheck = [[CustomIOSAlertView alloc] init];
    [alertViewForNewsLetterCheck setContentViewWithMsg: msg
                                contentBackgroundColor: [UIColor firstMain]
                                             badgeName: @"icon_2_0_0_dialog_pinpin.png"];
    alertViewForNewsLetterCheck.arrangeStyle = @"Horizontal";
    [alertViewForNewsLetterCheck setButtonTitles: [NSMutableArray arrayWithObjects: @"暫時不要", @"我要訂閱", nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertViewForNewsLetterCheck setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor whiteColor],nil]];
    [alertViewForNewsLetterCheck setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
    [alertViewForNewsLetterCheck setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    
    __block typeof(self) wself = self;
    __weak CustomIOSAlertView *weakAlertViewForNewsLetterCheck = alertViewForNewsLetterCheck;
    [alertViewForNewsLetterCheck setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        [weakAlertViewForNewsLetterCheck close];
        
        if (buttonIndex == 0) {
            NSLog(@"0");
            wself->wantToGetNewsLetter = NO;
            [self updateUser];
        } else {
            NSLog(@"1");
            wself->wantToGetNewsLetter = YES;
            [self updateUser];
        }
    }];
    [alertViewForNewsLetterCheck setUseMotionEffects: YES];
    [alertViewForNewsLetterCheck show];
}

- (void)updateUser {
    NSLog(@"updateUser");
    NSMutableDictionary *dataDic = [NSMutableDictionary new];
    [dataDic setObject: [NSNumber numberWithBool: wantToGetNewsLetter] forKey: @"newsletter"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: dataDic options: 0 error: nil];
    NSString *jsonStr = [[NSString alloc] initWithData: jsonData encoding: NSUTF8StringEncoding];
    
    [wTools ShowMBProgressHUD];
    
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI updateUser: [wTools getUserID]
                                          token: [wTools getUserToken]
                                          param: jsonStr];
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                if (![wself checkTimedOut:response api:@"updateUser" eventId:@"" text:@""]) {
                    
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    NSLog(@"dic: %@", dic);
                    
                    if ([dic[@"result"] isEqualToString: @"SYSTEM_OK"]) {
                        NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
                        [userPrefs setObject: @"NoNeedToCheck" forKey: @"newsLetterCheck"];
                        [userPrefs synchronize];
                        NSLog(@"userPrefs: %@", userPrefs);
                        
                        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                        
                        if (wself->wantToGetNewsLetter) {
                            style.messageColor = [UIColor whiteColor];
                            style.backgroundColor = [UIColor secondMain];
                            
                            [self.view makeToast: @"成功訂閱電子報"
                                        duration: 2.0
                                        position: CSToastPositionBottom
                                           style: style];
                        } else {
                            style.messageColor = [UIColor whiteColor];
                            style.backgroundColor = [UIColor hintGrey];
                            
                            [self.view makeToast: @"已取消訂閱電子報"
                                        duration: 2.0
                                        position: CSToastPositionBottom
                                           style: style];
                        }
                    } else if ([dic[@"result"] isEqualToString: @"SYSTEM_ERROR"]) {
                        NSLog(@"失敗： %@", dic[@"message"]);
                        if ([wTools objectExists: dic[@"message"]]) {
                            [self showCustomErrorAlert: dic[@"message"]];
                        } else {
                            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                        }
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

- (void)dealloc {
    [self removeNotification];
}
- (void)onSwitchCategoryViewHidden:(BOOL)hidden {
    self.categoryCollectionView.hidden = hidden;
    self.categoryBtn.selected = !hidden;
    if (hidden) {
        [self.categoryBtn setTintColor:[UIColor secondGrey]];
    }
    else {
        [self.categoryBtn setTintColor:[UIColor firstGrey]];
    }
    [self.categoryBtn setNeedsLayout];
    [self.categoryBtn setNeedsFocusUpdate];
}
- (IBAction)switchCategoryView:(id)sender {
    
    self.albumCollectionView.hidden = YES;
    BOOL c = self.categoryBtn.selected;
    if (c) {
        self.homeCollectionView.hidden = NO;
        [self onSwitchCategoryViewHidden:YES];
    } else {
        [self onSwitchCategoryViewHidden:NO];
        if (self.navBarView.hidden) {
            self.lastContentOffset = 0;
            [UIView animateWithDuration: 0.5 animations:^{
                self.navBarView.hidden = NO;
                [self.navBarView layoutIfNeeded];
            }];
        }
        if (isSearchTextFieldSelected) {
            [self.scanBtn setImage: [UIImage imageNamed: @"ic200_scancamera_dark"] forState: UIControlStateNormal];
            [self dismissKeyboard];
            self.searchTextField.text = @"";
            isSearchTextFieldSelected = NO;
        }
        self.homeCollectionView.hidden = YES;
        
    }
    
}
#pragma mark - 專區精選
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    RecommandListViewCell *cell = (RecommandListViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ListViewCell"];
    if (!cell)
        cell = [[RecommandListViewCell alloc] init];
    if (indexPath.section == 0)
        cell.recommandListView.tag = 71;
    else
        cell.recommandListView.tag = 72;
    
    cell.recommandListView.dataSource = self;
    cell.recommandListView.delegate = self;
    [cell.recommandListView reloadData];
    
    return cell;
    
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *l = [[UILabel alloc] init];
    UIView *v = [[UIView alloc] init];
    l.textColor = [UIColor hintGrey];
    l.font = [UIFont boldSystemFontOfSize:18];
    if (section == 0)
        l.text = @"推薦";
    else
        l.text = @"熱門";
    l.backgroundColor = UIColor.clearColor;
    [l sizeToFit];
    //CGSize s = l.frame.size;
    v.frame = CGRectMake(0, 0, 60,22);
    [v addSubview:l];
    l.frame = CGRectMake(16,0, 40, 22);
    return v;
}
@end
