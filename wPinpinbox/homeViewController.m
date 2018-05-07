//
//  homeViewController.m
//  wPinpinbox
//
//  Created by Angus on 2015/8/7.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "homeViewController.h"
#import "AppDelegate.h"
#import "wTools.h"
#import "boxAPI.h"
#import "HomeTableViewCell.h"
#import "AsyncImageView.h"
#import "RecommendViewController.h"

#import "CustomIOSAlertView.h"
#import <SafariServices/SafariServices.h>
#import "MyScrollView.h"
#import "TaobanViewController.h"
#import "EventPostViewController.h"

#import "FastViewController.h"

#import <CoreLocation/CoreLocation.h>

#import "VersionUpdate.h"

#import "MKDropdownMenu.h"
#import "Utilities.h"
#import "CreationTableViewCell.h"
#import "SetupViewController.h"

#import "RetrievealbumpViewController.h"

#import "CreativeViewController.h"

#define kAdHeight 70

@interface homeViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, SFSafariViewControllerDelegate, MyScrollViewDataSource1, UIGestureRecognizerDelegate, MKDropdownMenuDataSource, MKDropdownMenuDelegate>
{
    BOOL isLoading;
    BOOL isreload;
    NSMutableArray *pictures;
    NSInteger nextId;
    
    // For Showing Message of Getting Point
    NSString *missionTopicStr;
    NSString *rewardType;
    NSString *rewardValue;
    NSString *eventUrl;
    
    CustomIOSAlertView *alertView;
    
    // For Ad
    NSArray *adArray;
    NSInteger selectItem;
    MyScrollView *mySV;
    
    // For Temporary Ad
    NSArray *bannerAlbumId;
    NSArray *bannerImage;
    
    //CLLocationManager *location;
    
    NSDictionary *dicForSegue;
    NSString *albumIdForSegue;
    
    NSString *profilePic;
}

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *coordinate;

@property (strong, nonatomic) NSArray<NSString *> *types;
@property (strong, nonatomic) MKDropdownMenu *navBarMenu;
//@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (strong, nonatomic) NSString *navTitle;
@property (strong, nonatomic) NSString *typeData;
@property (strong, nonatomic) NSString *tempAlbumId;
@end

@implementation homeViewController

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"viewDidAppear");
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    /*
    VersionUpdate *vu = [[VersionUpdate alloc] initWithFrame: self.view.bounds];
    [vu checkVersion];
     */
    
    //[self FastBtn: nil];
    //[wTools HideMBProgressHUD];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"viewDidDisappear");
    
    [super viewDidDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"homeViewController");
    NSLog(@"viewWillAppear");
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed: 32.0/255.0 green: 191.0/255.0 blue: 193.0/255.0 alpha: 1.0];
    
    NSNumber *value = [NSNumber numberWithInt: UIInterfaceOrientationMaskPortrait];
    [[UIDevice currentDevice] setValue: value forKey: @"orientation"];
    
    [self checkUrlScheme];
    
    /*
    // Check whether locationCheck is done at least once or not
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL locationCheck = [[defaults objectForKey: @"locationCheck"] boolValue];
    
    if (!locationCheck) {
        [self checkLocation];
    }
     */

    //[self checkVersion];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"homeViewController");
    NSLog(@"viewDidLoad");
    
    self.typeData = @"latest";
    [self dropdownMenuSetUp];
    
    [button_attMore setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@.png",@"button_attMore_",[wTools localstring]]] forState:UIControlStateNormal];
    [button_attMore setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@.png",@"button_attMore_click_",[wTools localstring]]] forState:UIControlStateHighlighted];
    
    nextId = 0;
    isLoading = NO;
    isreload = NO;
    
    pictures = [NSMutableArray new];
    
    
    _refreshControl=[[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
    
    [self getprofile];
    
    
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
    
    [self checkAd];
    
    UIButton *fastVCBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    [fastVCBtn addTarget: self action: @selector(FastBtn:) forControlEvents: UIControlEventTouchUpInside];
    fastVCBtn.frame = CGRectMake(self.view.bounds.origin.x + 260, self.view.bounds.origin.y + 400, 50, 50);    
    [fastVCBtn setImage: [UIImage imageNamed: @"icon_teal500_circle_plus"] forState: UIControlStateNormal];
    [fastVCBtn setImage: [UIImage imageNamed: @"icon_teal500_circle_plus_press"]
               forState: UIControlStateSelected | UIControlStateHighlighted];
    
    [self.view addSubview: fastVCBtn];
    
    //[self presentTemporaryAdView];
    //bannerImage = [[NSArray alloc] initWithObjects: @"laking-Android＆IOS-2.jpg", @"160810_鄭家純APP抽寫真_720x96.jpg", nil];
    //bannerAlbumId = [[NSArray alloc] initWithObjects: @"2669", @"2067", nil];
    //[self presentAdView];
}

- (void)dropdownMenuSetUp {
    //self.typeData = @"latest";
    self.navTitle = @"全  部";
    self.types = @[@"全  部" ,@"熱  門", @"贊  助", @"關  注"];
    
    self.navBarMenu = [[MKDropdownMenu alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];
    self.navBarMenu.dataSource = self;
    self.navBarMenu.delegate = self;
    
    // Make background light instead of dark when presenting the dropdown
    self.navBarMenu.backgroundDimmingOpacity = -0.67;
    
    // Set custom disclosure indicator image
    UIImage *indicator = [UIImage imageNamed:@"indicator"];
    self.navBarMenu.disclosureIndicatorImage = indicator;
    
    // Add an arrow between the menu header and the dropdown
    UIImageView *spacer = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"triangle"]];
    
    // Prevent the arrow image from stretching
    spacer.contentMode = UIViewContentModeCenter;
    
    self.navBarMenu.spacerView = spacer;
    
    // Offset the arrow to align with the disclosure indicator
    self.navBarMenu.spacerViewOffset = UIOffsetMake(self.navBarMenu.bounds.size.width/2 - indicator.size.width/2 - 8, 1);
    
    // Hide top row separator to blend with the arrow
    self.navBarMenu.dropdownShowsTopRowSeparator = NO;
    
    self.navBarMenu.dropdownBouncesScroll = NO;
    
    self.navBarMenu.rowSeparatorColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    self.navBarMenu.rowTextAlignment = NSTextAlignmentCenter;
    
    // Round all corners (by default only bottom corners are rounded)
    self.navBarMenu.dropdownRoundedCorners = UIRectCornerAllCorners;
    
    // Let the dropdown take the whole width of the screen with 10pt insets
    /*
    self.navBarMenu.useFullScreenWidth = YES;
    self.navBarMenu.fullScreenInsetLeft = 10;
    self.navBarMenu.fullScreenInsetRight = 10;
    */
    
    self.navBarMenu.tintColor = [UIColor whiteColor];
    
    // Add the dropdown menu to navigation bar
    //self.navItem.titleView = self.navBarMenu;
    self.navigationItem.titleView = self.navBarMenu;
}

/*
#pragma mark - Location Service Check
- (void)checkLocation {
    location=[[CLLocationManager alloc]init];
    location.delegate = self;
    [location requestWhenInUseAuthorization];
    _coordinate=@"";
    
    //檢查定位狀態
    if(![CLLocationManager locationServicesEnabled] && !(location.location.coordinate.longitude > 0))
    {
        NSLog(@"locationServices is not Enabled && location coordinate longitude is not bigger than 0");
        //[self showAlertViewForLocation];
    }
    else if(([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied))
    {
        NSLog(@"status is denied");
        //[wTools showAlertTile:kTipTitle Message:kPlzOpenLocSys ButtonTitle:@"好"];
        //[self showAlertViewForLocation];
    }
    else
    {
        NSLog(@"network activity indicator is visible");
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [location startUpdatingLocation];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL locationCheck = YES;
    [defaults setObject: [NSNumber numberWithBool: locationCheck]
                 forKey: @"locationCheck"];
    [defaults synchronize];
}
*/

#pragma mark - Custom AlertView for Location Permission
- (void)showAlertViewForLocation
{
    CustomIOSAlertView *alertViewForLocation = [[CustomIOSAlertView alloc] init];
    [alertViewForLocation setContainerView: [self createView]];
    [alertViewForLocation setButtonTitles: [NSMutableArray arrayWithObject: @"好"]];
    [alertViewForLocation setOnButtonTouchUpInside:^(CustomIOSAlertView *alertViewForLocation, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertViewForLocation tag]);
        [alertViewForLocation close];
        
        if (buttonIndex == 0) {
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: UIApplicationOpenSettingsURLString]];
        }
    }];
    [alertViewForLocation setUseMotionEffects: true];
    [alertViewForLocation show];
}

- (UIView *)createView
{
    UIView *view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.view.bounds.size.width - 100, self.view.bounds.size.height - 400)];
    
    // Mission Topic Label
    UILabel *titlelabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height)];
    titlelabel.text = @"沒有定位存取權";
    titlelabel.textAlignment = NSTextAlignmentCenter;
    titlelabel.center = CGPointMake(view.bounds.size.width / 2, view.bounds.size.height / 2 - 15);
    
    [view addSubview: titlelabel];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height)];
    messageLabel.text = @"請開啟定位";
    messageLabel.font = [UIFont preferredFontForTextStyle: UIFontTextStyleSubheadline];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.center = CGPointMake(view.bounds.size.width / 2, view.bounds.size.height / 2 + 20);
    
    [view addSubview: messageLabel];
    
    return view;
}


#pragma mark - Get Profile

- (void)getprofile
{
    NSLog(@"getprofile");
    
    [wTools ShowMBProgressHUD];
    
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSLog(@"userPrefs id: %@", [userPrefs objectForKey: @"id"]);
        
        NSString *respone=[boxAPI getprofile:[userPrefs objectForKey:@"id"] token:[userPrefs objectForKey:@"token"]];
        
        NSString *testsign=[boxAPI testsign];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [wTools HideMBProgressHUD];
            
            NSLog(@"testsign:%@", testsign);
            
            if (respone!=nil) {
                NSLog(@"response: %@", respone);
                
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                if ([dic[@"result"]boolValue]) {
                    
                    //儲存會員資料
                    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
                    NSMutableDictionary *dataic=[[NSMutableDictionary alloc]initWithDictionary:dic[@"data"] copyItems:YES];
                    
                    NSLog(@"dataic: %@", dataic);
                    
                    for (NSString *kye in [dataic allKeys] ) {
                        NSLog(@"kye: %@", kye);
                        
                        id objective =[dataic objectForKey:kye];
                        NSLog(@"objective: %@", objective);
            
                        if ([objective isKindOfClass:[NSNull class]]) {
                            [dataic setObject:@"" forKey:kye];
                        }
                    }
                    
                    NSLog(@"dataic: %@", dataic);
                    
                    [userPrefs setValue:dataic forKey:@"profile"];
                    [userPrefs synchronize];
                    
                    profilePic = dic[@"data"][@"profilepic"];
                    NSLog(@"profilePic: %@", profilePic);
                    
                    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                    
                    [app.menu reloadpic:dic[@"data"][@"profilepic"]];
                    
                    
                    nextId = 0;
                    isLoading = NO;
                    isreload = NO;
                    [pictures removeAllObjects];
                    
                    [self loadData:nil];
                    
                }else{
                    NSLog(@"失敗：%@",dic[@"message"]);
                }
            }
        });
    });
}

#pragma mark - Check URL Scheme

- (void)checkUrlScheme
{
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    
    BOOL diyContentOn = [[userPrefs objectForKey: @"diyContentOn"] boolValue];
    
    if ([[userPrefs objectForKey: @"urlScheme"] isEqualToString: @"diyContent"]) {
        
        if (diyContentOn) {
            FastViewController *fvc=[[UIStoryboard storyboardWithName:@"Fast" bundle:nil] instantiateViewControllerWithIdentifier:@"FastViewController"];
            fvc.selectrow=[wTools userbook];
            fvc.albumid = [userPrefs objectForKey: @"albumIdScheme"];
            fvc.templateid = [userPrefs objectForKey: @"templateIdScheme"];
            
            if ([[userPrefs objectForKey: @"templateIdScheme"] isEqualToString:@"0"]) {
                fvc.booktype = 0;
                fvc.choice = @"Fast";
            } else {
                fvc.booktype = 1000;
                fvc.choice = @"Template";
            }
            
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
            [app.myNav pushViewController: fvc animated:YES];
        }
        diyContentOn = NO;
        [userPrefs setObject: [NSNumber numberWithBool: diyContentOn] forKey: @"diyContentOn"];
    }
}

/*
- (void)presentTemporaryAdView
{
    NSLog(@"presentTemporaryAdView");
    
    CGRect btFrame = button_attMore.frame;
    NSLog(@"btFrame y axis: %f", btFrame.origin.y);
    
    btFrame.origin.y += kAdHeight;
    button_attMore.frame = btFrame;
    
    CGRect tableFrame = _tableView.frame;
    NSLog(@"tableFrame y axis: %f", tableFrame.origin.y);
    
    tableFrame.origin.y += kAdHeight;
    _tableView.frame = tableFrame;
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(tapDetected)];
    singleTap.numberOfTapsRequired = 1;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed: @"ili_photo.jpg"];
    imageView.frame = CGRectMake(0, kAdHeight + 10, self.view.bounds.size.width, kAdHeight);
    imageView.userInteractionEnabled = YES;
    [imageView addGestureRecognizer: singleTap];
    
    [self.view addSubview: imageView];
}

- (void)tapDetected {
    NSLog(@"single tap on imageView");
    [wTools ToRetrievealbumpViewControlleralbumid: @"2067"];
}
*/

#pragma mark -
#pragma mark Ad Scroll View Methods
- (void)checkAd
{
    NSLog(@"checkAd");
    
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI getAdList: [wTools getUserID] token: [wTools getUserToken] adarea_id: @"1"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"checkAd Response");
                NSLog(@"reponse: %@", response);
                NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableLeaves error: nil];
                
                if ([data[@"result"] intValue] == 1) {
                    NSLog(@"GetAd Success");
                    adArray = data[@"data"];
                    
                    // Check array data is 0 or more than 0
                    NSLog(@"adArray: %@", adArray);
                    
                    if (adArray.count != 0) {
                        [self presentAdBanner];
                    }
                    
                } else if ([data[@"result"] intValue] == 0)
                    NSLog(@"error message: %@", data[@"message"]);
            }
        });
    });
}

- (void)presentAdBanner
{
    NSLog(@"presentAdBanner");
    
    /*
    CGRect btFrame = button_attMore.frame;
    NSLog(@"btFrame y axis: %f", btFrame.origin.y);
    
    btFrame.origin.y += kAdHeight - 15;
    button_attMore.frame = btFrame;
    */
    CGRect tableFrame = _tableView.frame;
    NSLog(@"tableFrame y axis: %f", tableFrame.origin.y);
    
    tableFrame.origin.y += 42;
    _tableView.frame = tableFrame;
    
    // Ad ScrollView Setting
    mySV = [[MyScrollView alloc] initWithFrame: CGRectMake(0, -14, self.view.bounds.size.width, kAdHeight)];
    mySV.dataSourceDelegate = self;
    mySV.pagingEnabled = YES;
    [mySV initWithDelegate: self atPage: 0];
    [self.view addSubview: mySV];
    
    /*
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollEnabled = YES;
    scrollView.pagingEnabled = YES;
    scrollView.userInteractionEnabled = YES;
    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, 40);
    
    [self.view addSubview: scrollView];
     */
}

#pragma mark - MyScrollViewDataScource
- (UIView *)ScrollView:(MyScrollView *)scrollView atPage:(int)pageId
{
    NSLog(@"scrollView");
    NSLog(@"pageId: %d", pageId);
    
    UIView *v = [[UIView alloc] initWithFrame: CGRectMake(scrollView.bounds.size.width * pageId, 0, scrollView.bounds.size.width, kAdHeight)];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(tapDetectedForURL)];
    singleTap.numberOfTapsRequired = 1;
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame: v.bounds];
    NSURL *urlImage = [NSURL URLWithString: adArray[pageId][@"ad"][@"image"]];
    NSData *data = [NSData dataWithContentsOfURL: urlImage];
    imageView.image = [UIImage imageWithData: data];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.userInteractionEnabled = YES;
    [imageView addGestureRecognizer: singleTap];
    
    [v addSubview: imageView];
    
    
    /*
    UIImageView *imageView = [[UIImageView alloc] initWithFrame: v.bounds];
    imageView.image = [UIImage imageNamed: [bannerImage objectAtIndex: pageId]];
    
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.userInteractionEnabled = YES;
    [imageView addGestureRecognizer: singleTap];
    
    [v addSubview: imageView];
    */
    
    return v;
}

- (CGSize)ContentSizeInScrollView:(MyScrollView *)scrollView
{
    return CGSizeMake(scrollView.bounds.size.width * adArray.count, scrollView.bounds.size.height);
    //return CGSizeMake(scrollView.bounds.size.width * bannerImage.count, scrollView.bounds.size.height);
}

- (int)TotalPageInScrollView:(MyScrollView *)scrollView
{
    return adArray.count;
    //return bannerImage.count;
}

#pragma mark -

- (void)tapDetectedForURL
{
    NSLog(@"tapDetectedForURL");
    
    int page = mySV.contentOffset.x / mySV.frame.size.width;
    NSLog(@"page: %d", page);
    
    NSString *album = adArray[page][@"album"];
    NSLog(@"album: %@", album);
    
    NSString *event = adArray[page][@"event"];
    NSLog(@"event: %@", event);
    
    NSString *template = adArray[page][@"template"];
    NSLog(@"template: %@", template);
    
    NSString *user = adArray[page][@"user"];
    NSLog(@"user: %@", user);
    
    NSString *urlString = adArray[page][@"ad"][@"url"];
    NSLog(@"urlString: %@", urlString);
    
    if (album != (NSString *)[NSNull null]) {
        NSString *albumIdString = [adArray[page][@"album"][@"album_id"] stringValue];
        NSLog(@"albumIdString: %@", albumIdString);
        
        if (![albumIdString isEqualToString: @""]) {
            //[wTools ToRetrievealbumpViewControlleralbumid: albumIdString];
            [self ToRetrievealbumpViewControlleralbumid: albumIdForSegue];
        }
    } else if (event != (NSString *)[NSNull null]) {
        NSString *eventIdString = [adArray[page][@"event"][@"event_id"] stringValue];
        NSLog(@"eventIdString: %@", eventIdString);
        
        if (![eventIdString isEqualToString: @""]) {
            [self getEventData: eventIdString];
        }
    } else if (template != (NSString *)[NSNull null]) {
        NSString *templateIdString = [adArray[page][@"template"][@"template_id"] stringValue];
        NSLog(@"templateIdString: %@", templateIdString);
        
        if (![templateIdString isEqualToString: @""]) {
            TaobanViewController *tv=[[TaobanViewController alloc]initWithNibName:@"TaobanViewController" bundle:nil];
            tv.temolateid = templateIdString;
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
            //[app.myNav pushViewController:tv animated:YES];
        }
    } else if (user != (NSString *)[NSNull null]) {
        NSString *userIdString = [adArray[page][@"user"][@"user_id"] stringValue];
        NSLog(@"userIdString: %@", userIdString);
        
        if (![userIdString isEqualToString: @""]) {
            //[wTools showCreativeViewuserid: userIdString isfollow: YES];
        }
    } else if (![urlString isEqualToString: @""]) {
        NSLog(@"urlString is not equalToString");
        NSURL *urlForAd = [NSURL URLWithString: urlString];
        SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: urlForAd entersReaderIfAvailable: NO];
        safariVC.delegate = self;
        safariVC.preferredBarTintColor = [UIColor whiteColor];
        [self presentViewController: safariVC animated: YES completion: nil];
    }
    
    //NSLog(@"[bannerAlbumId objectAtIndex: page]: %@", [bannerAlbumId objectAtIndex: page]);
    //[wTools ToRetrievealbumpViewControlleralbumid: [bannerAlbumId objectAtIndex: page]];
}

#pragma mark -
#pragma Get Event Methods

- (void)getEventData: (NSString *)eventId
{
    NSLog(@"getEventData");
    
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI getEvent: [wTools getUserID] token: [wTools getUserToken] event_id: eventId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"checkEvent Response");
                NSLog(@"response: %@", response);
                NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableLeaves error: nil];
                
                if ([data[@"result"] intValue] == 1) {
                    NSLog(@"GetEvent Success");
                    
                    NSLog(@"data result: %@", data[@"result"]);
                    NSLog(@"image: %@", data[@"data"][@"event"][@"image"]);
                    NSLog(@"url: %@", data[@"data"][@"event"][@"url"]);
                    NSLog(@"templatejoin: %@", data[@"data"][@"event_templatejoin"]);
                    
                    //EventPostViewController *eventPostVC = [[EventPostViewController alloc] initWithNibName: @"EventPostViewController" bundle: nil];
                    EventPostViewController *eventPostVC = [[UIStoryboard storyboardWithName: @"Home" bundle:nil] instantiateViewControllerWithIdentifier: @"EventPostViewController"];
                    eventPostVC.imageName = data[@"data"][@"event"][@"image"];
                    eventPostVC.urlString = data[@"data"][@"event"][@"url"];
                    eventPostVC.templateArray = data[@"data"][@"event_templatejoin"];
                    eventPostVC.eventId = eventId;
                    //eventPostVC.templateId = data[@"data"][@"event_templatejoin"];
                    
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    BOOL fromHomeVC = YES;
                    [defaults setObject: [NSNumber numberWithBool: fromHomeVC]
                                 forKey: @"fromHomeVC"];
                    [defaults synchronize];
                    
                    [self.navigationController pushViewController: eventPostVC animated: YES];
                    
                } else if ([data[@"result"] intValue] == 0) {
                    NSLog(@"error message: %@", data[@"message"]);
                } else if ([data[@"result"] intValue] == 2) {
                    //EventPostViewController *eventPostVC = [[EventPostViewController alloc] initWithNibName: @"EventPostViewController" bundle: nil];
                    EventPostViewController *eventPostVC = [[UIStoryboard storyboardWithName: @"Home" bundle:nil] instantiateViewControllerWithIdentifier: @"EventPostViewController"];
                    eventPostVC.imageName = data[@"data"][@"event"][@"image"];
                    eventPostVC.urlString = data[@"data"][@"event"][@"url"];
                    eventPostVC.eventFinished = YES;
                    
                    [self.navigationController pushViewController: eventPostVC animated: YES];
                }
            }
        });
    });
}

- (void)getEventDataForURLScheme: (NSString *)eventId
{
    NSLog(@"getEventData");
    
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI getEvent: [wTools getUserID] token: [wTools getUserToken] event_id: eventId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"checkEvent Response");
                NSLog(@"response: %@", response);
                NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableLeaves error: nil];
                
                if ([data[@"result"] intValue] == 1) {
                    NSLog(@"GetEvent Success");
                    
                    NSLog(@"data result: %@", data[@"result"]);
                    NSLog(@"image: %@", data[@"data"][@"event"][@"image"]);
                    NSLog(@"url: %@", data[@"data"][@"event"][@"url"]);
                    NSLog(@"templatejoin: %@", data[@"data"][@"event_templatejoin"]);
                    
                    //EventPostViewController *eventPostVC = [[EventPostViewController alloc] initWithNibName: @"EventPostViewController" bundle: nil];
                    EventPostViewController *eventPostVC = [[UIStoryboard storyboardWithName: @"Home" bundle:nil] instantiateViewControllerWithIdentifier: @"EventPostViewController"];
                    eventPostVC.imageName = data[@"data"][@"event"][@"image"];
                    eventPostVC.urlString = data[@"data"][@"event"][@"url"];
                    eventPostVC.templateArray = data[@"data"][@"event_templatejoin"];
                    eventPostVC.eventId = eventId;
                    //eventPostVC.templateId = data[@"data"][@"event_templatejoin"];
                    
                    //[self.navigationController pushViewController: eventPostVC animated: YES];
                    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                    [app.myNav pushViewController: eventPostVC animated:NO];
                    
                } else if ([data[@"result"] intValue] == 0)
                    NSLog(@"error message: %@", data[@"message"]);
            }
        });
    });
}

#pragma mark - Check Point Method

- (void)checkPoint
{
    NSLog(@"checkPoint");
    
    //[wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *response = [boxAPI doTask1: [wTools getUserID] token: [wTools getUserToken] task_for: @"firsttime_login" platform: @"apple"];
        
        NSLog(@"User ID: %@", [wTools getUserID]);
        NSLog(@"Token: %@", [wTools getUserToken]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //[wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"%@", response);
                NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                if ([data[@"result"] intValue] == 1) {
                    
                    missionTopicStr = data[@"data"][@"task"][@"name"];
                    NSLog(@"name: %@", missionTopicStr);
                    
                    rewardType = data[@"data"][@"task"][@"reward"];
                    NSLog(@"reward type: %@", rewardType);
                    
                    rewardValue = data[@"data"][@"task"][@"reward_value"];
                    NSLog(@"reward value: %@", rewardValue);
                    
                    eventUrl = data[@"data"][@"event"][@"url"];
                    NSLog(@"event: %@", eventUrl);
                    
                    [self showAlertView];
                    
                } else if ([data[@"result"] intValue] == 2) {
                    NSLog(@"message: %@", data[@"message"]);
                    
                    // Save setting for login successfully
                    BOOL firsttime_login = YES;
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject: [NSNumber numberWithBool: firsttime_login] forKey: @"firsttime_login"];
                    [defaults synchronize];
                }
            }
        });
    });
}

#pragma mark - Custom AlertView for Getting Point
- (void)showAlertView
{
    // Custom AlertView shows up when getting the point
    alertView = [[CustomIOSAlertView alloc] init];
    [alertView setContainerView: [self createPointView]];
    [alertView setButtonTitles: [NSMutableArray arrayWithObject: @"確     認"]];
    [alertView setUseMotionEffects: true];
    
    [alertView show];
}

- (UIView *)createPointView
{
    UIView *pointView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 250, 250)];
    
    // Mission Topic Label
    UILabel *missionTopicLabel = [[UILabel alloc] initWithFrame: CGRectMake(5, 15, 200, 10)];
    //missionTopicLabel.text = @"登入得點";
    missionTopicLabel.text = missionTopicStr;
    [pointView addSubview: missionTopicLabel];
    
    // Gift Image
    UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(50, 40, 150, 150)];
    imageView.image = [UIImage imageNamed: @"icon_present"];
    [pointView addSubview: imageView];
    
    // Message Label
    UILabel *messageLabel = [[UILabel alloc] initWithFrame: CGRectMake(5, 200, 200, 10)];
    
    NSString *congratulate = @"恭喜您獲得 ";
    //NSString *number = rewardValue;
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
    NSLog(@"activityLink: %@", activityLink);
    
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

#pragma mark -

-(void)refresh
{
    if (!isreload) {
        [wTools ShowMBProgressHUD];
        isreload=YES;
        nextId = 0;
        isLoading = NO;
        
        [self loadData:nil];
    }
    
    //你下拉更新之後要做的事.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)recommended:(id)sender {
    RecommendViewController *rv=[[RecommendViewController alloc]initWithNibName:@"RecommendViewController" bundle:nil];
    //RecommendViewController *rv = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"RecommendViewController"];
    rv.working=YES;
    [self.navigationController pushViewController:rv animated:YES];
}

- (IBAction)showMenu:(id)sender {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [app.menu showMenu];
}

#pragma mark - Table View Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    
    /*
    if (indexPath.row == 0) {
        height = 140.0;
    } else {
        height = 260;
    }
    */
    
    height = 260;
    NSLog(@"height: %f", height);
    
    return height;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    NSUInteger totalCount = pictures.count + 1;
    NSLog(@"pictures.count: %lu", (unsigned long)pictures.count
          );
    NSLog(@"totalCount: %lu", (unsigned long)totalCount);
    
    return pictures.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // NSString *identifier = [NSString stringWithFormat:@"HomeTableViewCell_%@", [[[pictures objectAtIndex:indexPath.row] objectForKey:@"album"]objectForKey:@"album_id" ]];
    
    NSLog(@"cellForRowAtIndexPath");
    NSLog(@"indexPath.row: %ld", (long)indexPath.row);
    
    HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (pictures.count < indexPath.section) {
        return cell;
    }
    
    //NSDictionary *dic = [pictures [indexPath.section] mutableCopy];
    NSDictionary *dic = [pictures [indexPath.row] mutableCopy];
    
    if (dic) {
        NSLog(@"dic: %@", dic);
        
        NSDictionary *album=dic[@"album"];
        NSDictionary *user=dic[@"user"];
        NSDictionary *follow=dic[@"follow"];
        NSDictionary *notice=dic[@"notice"];
        
        NSDictionary *albumStatistics = dic[@"albumstatistics"];
        
        NSLog(@"indexPath.row: %ld", (long)indexPath.row);
        
        // Set action method on call button
        UIButton *button = (UIButton *)[self.view viewWithTag: 40];
        [button setUserInteractionEnabled: YES];
        [button addTarget: self action: @selector(checkButtonTapped:) forControlEvents: UIControlEventTouchUpInside];
        
        NSLog(@"album: %@", album);
        NSLog(@"album name: %@", album[@"name"]);
        
        cell.picture.image=[UIImage imageNamed:@"user_photo.png"];
        cell.picture.imageURL = nil;
        
        [[cell.picture layer] setMasksToBounds:YES];
        [[cell.picture layer] setCornerRadius:cell.picture.bounds.size.height/2];
        
        NSString *picture=user[@"picture"];
        
        if (![picture isKindOfClass:[NSNull class]]) {
            if (![picture isEqualToString:@""]) {
                [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: cell.picture];
                cell.picture.imageURL=[NSURL URLWithString:user[@"picture"]];
            }
        } else {
            NSLog(@"picture is null");
            [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: cell.picture];
            cell.picture.image = [UIImage imageNamed: @"member_back_head.png"];
        }
        
        /*
         cell.followlab.text=@"";
         
         if (![follow[@"count_from"] isKindOfClass:[NSNull class]]) {
         cell.followlab.text=[follow[@"count_from"] stringValue];
         }
         */
        
        
        NSLog(@"albumStatistics: %@", albumStatistics);
        
        cell.viewedLabel.text = @"";
        
        if (![albumStatistics[@"viewed"] isKindOfClass: [NSNull class]]) {
            cell.viewedLabel.text = [albumStatistics[@"viewed"] stringValue];
        }
        
        cell.countLabel.text = @"";
        
        if (![albumStatistics[@"count"] isKindOfClass: [NSNull class]]) {
            cell.countLabel.text = [albumStatistics[@"count"] stringValue];
        }
        
        
        cell.name.text=user[@"name"];
        cell.user_id=[user[@"user_id"] stringValue];
        
        cell.customBlock = ^(BOOL select, NSString *userId) {
            NSLog(@"select: %d", select);
            NSLog(@"userId: %@", userId);
            
            CreativeViewController *cVC = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"CreativeViewController"];
            cVC.userid = userId;
            [self.navigationController pushViewController: cVC animated: NO];
        };
        
        cell.difftime.text=[self figgtime:notice[@"difftime"]];
        
        cell.album_id=[album[@"album_id"] stringValue];
        cell.album_name.text=album[@"name"];
        
        cell.coverimageview.imageURL=nil;
        cell.coverimageview.image=[UIImage imageNamed:@"pin_frame.png"];
        
        if (![album[@"cover"] isKindOfClass: [NSNull class]]) {
            if (![album[@"cover"] isEqualToString:@""]) {
                [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: cell.coverimageview];
                cell.coverimageview.imageURL=[NSURL URLWithString:album[@"cover"]];
            }
        }
        
        // Reset
        cell.previewimage1.imageURL = nil;
        cell.previewimage2.imageURL = nil;
        cell.previewImage3.imageURL = nil;
        cell.previewimage1.image = [UIImage imageNamed:@"pin_frame.png"];
        cell.previewimage2.image = [UIImage imageNamed:@"pin_frame.png"];
        cell.previewImage3.image = [UIImage imageNamed: @"pin_frame.png"];
        
        cell.p1.imageURL = nil;
        cell.twoP1.imageURL = nil;
        cell.twoP2.imageURL = nil;
        cell.p1.image = [UIImage imageNamed:@"pin_frame.png"];
        cell.twoP1.image = [UIImage imageNamed:@"pin_frame.png"];
        cell.twoP2.image = [UIImage imageNamed: @"pin_frame.png"];
        
        cell.v1ForCover.alpha = 1;
        cell.v1ForOnlyP1.alpha = 1;
        cell.v2ForP1P2.alpha = 1;
        
        NSLog(@"preview: %@", album[@"preview"]);
        NSArray *albumPreview = album[@"preview"];
        NSLog(@"albumPreview: %lu", (unsigned long)albumPreview.count);
        
        if ([album[@"preview"] count] > 0) {
            NSLog(@"album preview is more than 0");
            
            cell.v1ForCover.alpha = 0;
            
            //[[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: cell.previewimage1];
            //cell.previewimage1.imageURL=[NSURL URLWithString:album[@"preview"][0]];
            
            [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: cell.p1];
            cell.p1.imageURL = [NSURL URLWithString:album[@"preview"][0]];
            
            if ([album[@"preview"] count] > 1) {
                NSLog(@"album preview is more than 1");
                
                [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: cell.previewimage2];
                //cell.previewimage2.imageURL=[NSURL URLWithString:album[@"preview"][1]];
                
                cell.v1ForOnlyP1.alpha = 0;
                
                [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: cell.twoP1];
                [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: cell.twoP2];
                cell.twoP1.imageURL = [NSURL URLWithString:album[@"preview"][0]];
                cell.twoP2.imageURL = [NSURL URLWithString:album[@"preview"][1]];
                
                if ([album[@"preview"] count] > 2) {
                    NSLog(@"album preview is more than 2");
                    
                    cell.v2ForP1P2.alpha = 0;
                    
                    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: cell.previewimage1];
                    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: cell.previewimage2];
                    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: cell.previewImage3];
                    
                    cell.previewimage1.imageURL = [NSURL URLWithString: album[@"preview"][0]];
                    cell.previewimage2.imageURL = [NSURL URLWithString: album[@"preview"][1]];
                    cell.previewImage3.imageURL = [NSURL URLWithString: album[@"preview"][2]];
                }
            }
            
        } else {
            NSLog(@"preview.count is 0");
            NSLog(@"album preview: %lu", (unsigned long)albumPreview.count);
            
            if ([album[@"cover"] isEqual: [NSNull null]]) {
                cell.coverimageview.imageURL = [NSURL URLWithString: @"https://ppb.sharemomo.com/static_file/pinpinbox/zh_TW/images/origin.jpg"];
            } else {
                cell.coverimageview.imageURL=[NSURL URLWithString:album[@"cover"]];
            }
        }
        
        cell.locatLab.text=album[@"location"];
        
        if ([album[@"location"] isEqualToString: @""]) {
            cell.locationImage.hidden = YES;
        } else {
            cell.locationImage.hidden = NO;
        }
    }
    return cell;
    
    /*
    if (indexPath.row == 0) {
        NSLog(@"indexPath.row == 0");
     
        CreationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"CreationCell" forIndexPath: indexPath];
     
        NSDictionary *dic = [pictures [indexPath.row] mutableCopy];
     
        if (dic) {
            NSLog(@"dic: %@", dic);
     
            NSDictionary *user=dic[@"user"];
     
            cell.picture.image=[UIImage imageNamed:@"user_photo.png"];
            cell.picture.imageURL = nil;
     
            [[cell.picture layer] setMasksToBounds:YES];
            [[cell.picture layer] setCornerRadius:cell.picture.bounds.size.height/2];
     
            //NSString *picture=user[@"picture"];
            
            if (![profilePic isKindOfClass:[NSNull class]]) {
                if (![profilePic isEqualToString:@""]) {
                    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: cell.picture];
                    //cell.picture.imageURL = [NSURL URLWithString:user[@"picture"]];
                    cell.picture.imageURL = [NSURL URLWithString: profilePic];
                }
            } else {
                NSLog(@"picture is null");
                [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: cell.picture];
                cell.picture.image = [UIImage imageNamed: @"member_back_head.png"];
            }
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    } else {
        NSLog(@"indexPath.row != 0");
        
        
    }
    
    // Configure the cell...
    
    //return nil;
     */
}

#pragma mark - Button Method for CustomCell
- (void)checkButtonTapped: (UIButton *)sender
{
    NSLog(@"checkButtonTapped");
    
    // Get point of the button pressed
    CGPoint buttonPosition = [sender convertPoint: CGPointZero toView: self.tableView];
    
    // Get indexPath for the cell where the button is pressed
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: buttonPosition];
    
    NSLog(@"indexPath.row: %ld", (long)indexPath.row);
    
    NSDictionary *dic = [pictures [indexPath.row] mutableCopy];
    NSDictionary *album = dic[@"album"];
    albumIdForSegue = [album[@"album_id"] stringValue];
    
    NSLog(@"albumId: %@", albumIdForSegue);
    NSLog(@"album name: %@", album[@"name"]);
    
    [self ToRetrievealbumpViewControlleralbumid: albumIdForSegue];
}

#pragma mark - Call Protocol
- (void)ToRetrievealbumpViewControlleralbumid:(NSString *)albumid {
    
    NSLog(@"ToRetrievealbumpViewControlleralbumid");
    
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone=[boxAPI retrievealbump:albumid uid:[wTools getUserID] token:[wTools getUserToken]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [wTools HideMBProgressHUD];
            
            if (respone!=nil)
            {
                NSLog(@"check response");
                NSLog(@"respone: %@", respone);
                
                //NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [respone dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                
                if ([dic[@"result"]boolValue])
                {
                    NSLog(@"result bool value is YES");
                    NSLog(@"dic: %@", dic);
                    
                    NSLog(@"dic data photo: %@", dic[@"data"][@"photo"]);
                    
                    NSLog(@"dic data user name: %@", dic[@"data"][@"user"][@"name"]);
                    
                    dicForSegue = dic;
                    
                    //[self performSegueWithIdentifier: @"showRetrievealbumpViewController" sender: self];
                    
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    BOOL fromHomeVC = YES;
                    [defaults setObject: [NSNumber numberWithBool: fromHomeVC]
                                 forKey: @"fromHomeVC"];
                    [defaults synchronize];
                    
                    //RetrievealbumpViewController *rev = [[RetrievealbumpViewController alloc] initWithNibName:@"RetrievealbumpViewController" bundle:nil];
                    RetrievealbumpViewController *rev = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"RetrievealbumpViewController"];
                    rev.data=[dic[@"data"] mutableCopy];
                    
                    NSLog(@"rev.data: %@", rev.data);
                    
                    rev.albumid=albumid;
                    //[app.myNav pushViewController:rev animated:YES];
                    [self.navigationController pushViewController: rev animated: YES];
                    
                }
                else
                {
                    NSLog(@"失敗：%@",dic[@"message"]);
                    Remind *rv=[[Remind alloc]initWithFrame:app.menu.view.bounds];
                    [rv addtitletext:dic[@"message"]];
                    [rv addBackTouch];
                    [rv showView:app.menu.view];
                }
            }
        });
    });
}


#pragma mark -

//處理時間字串
-(NSString *)figgtime:(NSString *)str{
    
    NSArray *strArray=[str componentsSeparatedByString:@","];
    
    //計算日期
    NSDate *now=[NSDate date];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:-[strArray[0] intValue]];
    [dateComponents setMonth:-[strArray[1] intValue]];
    [dateComponents setDay:-[strArray[2] intValue]];
    [dateComponents setHour:-[strArray[3] intValue]];
    [dateComponents setMinute:-[strArray[4] intValue]];
    
    NSDate *thirtyDaysLatter = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:now options:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/M/d"];
    NSLog(@"Begin of this month=%@",[dateFormatter stringFromDate:thirtyDaysLatter]);
    
    if ([strArray[2] intValue]>6) {
        return [dateFormatter stringFromDate:thirtyDaysLatter];
    }
    
    for (int i=0; i<strArray.count; i++) {
        NSString *s=strArray[i];
        if (![s isEqualToString:@"0"]) {
            
            switch (i) {
                case 0:
                    return [NSString stringWithFormat:@"%@年前",s];
                    break;
                case 1:
                    return [NSString stringWithFormat:@"%@月前",s];
                    break;
                case 2:
                    return [NSString stringWithFormat:@"%@%@",s,NSLocalizedString(@"HomeText-daysAgo", @"")];
                    break;
                case 3:
                    return [NSString stringWithFormat:@"%@%@",s,NSLocalizedString(@"HomeText-hoursAgo", @"")];
                    break;
                case 4:
                    return [NSString stringWithFormat:@"%@%@",s,NSLocalizedString(@"HomeText-minsAgo", @"")];
                    break;
                default:
                    break;
            }
            
            break;
        }
    }
    
    return @"";
}


- (void)loadData:(UIAlertView *)alert{
    
    NSLog(@"loadData");
    
    if (!isLoading) {
        
        if (nextId==0) {
            
        }
        isLoading = YES;
        NSMutableDictionary *data = [NSMutableDictionary new];
        
        NSString *limit=[NSString stringWithFormat:@"%ld,%ld",(long)nextId, nextId + 10];
        
        [data setValue:limit forKey:@"limit"];
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            
            //NSString *respone=[boxAPI updatelist:[wTools getUserID] token:[wTools getUserToken] data:data];
            
            NSLog(@"rank: %@", self.typeData);
            NSString *response = [boxAPI updatelist: [wTools getUserID] token: [wTools getUserToken] data: data rank: self.typeData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [wTools HideMBProgressHUD];
                
                if (response != nil) {
                    NSLog(@"%@", response);
                    NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"]boolValue]) {
                        
                        if (nextId == 0) {
                            [pictures removeAllObjects];
                        }
                        
                        // s for counting how much data is loaded
                        int s = 0;
                        
                        for (NSMutableDictionary *picture in [dic objectForKey:@"data"]) {
                            s++;
                            [pictures addObject: picture];
                        }
                        
                        // If data keeps loading then the nextId is accumulating
                        nextId = nextId + s;
                        
                        // If nextId is bigger than 0, that means there are some data loaded already.
                        if (nextId >= 0)
                            isLoading = NO;
                        
                        // If s is 0, that means dic data is empty.
                        if (s == 0) {
                            isLoading = YES;
                        }
                        
                        [_refreshControl endRefreshing];
                        [self.tableView reloadData];
                        
                        isreload = NO;
                        
                    } else {
                        [_refreshControl endRefreshing];
                        NSLog(@"失敗：%@",dic[@"message"]);
                    }
                    
                } else {
                    [_refreshControl endRefreshing];
                }
            });
        });
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    NSLog(@"Did scroll");
    NSLog(@"isLoading?");
    
    if (isLoading)
        return;
    
    if ((scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height * 2)) {
        NSLog(@"loadData");
        [self loadData:nil];
    }
    
    
}

#pragma mark - MKDropdownMenuDataSource
- (NSInteger)numberOfComponentsInDropdownMenu:(MKDropdownMenu *)dropdownMenu {
    return 1;
}

- (NSInteger)dropdownMenu:(MKDropdownMenu *)dropdownMenu numberOfRowsInComponent:(NSInteger)component {
    return 4;
}

#pragma mark - MKDropdownMenuDelegate
- (CGFloat)dropdownMenu:(MKDropdownMenu *)dropdownMenu rowHeightForComponent:(NSInteger)component {
    return 40;
}

- (NSAttributedString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu attributedTitleForComponent:(NSInteger)component {
    return [[NSAttributedString alloc] initWithString:self.navTitle
                                           attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18 weight:UIFontWeightThin],
                                                        NSForegroundColorAttributeName: [UIColor whiteColor]}];
}

- (NSAttributedString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSMutableAttributedString *string =
    [[NSMutableAttributedString alloc] initWithString: self.types[row]
                                           attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14 weight:UIFontWeightLight],
                                                        NSForegroundColorAttributeName: [UIColor whiteColor]}];
    return string;
}

- (UIColor *)dropdownMenu:(MKDropdownMenu *)dropdownMenu backgroundColorForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [UIColor colorWithRed: 32.0/255.0 green: 191.0/255.0 blue: 193.0/255.0 alpha: 1.0];;
}

- (void)dropdownMenu:(MKDropdownMenu *)dropdownMenu didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"dropdownMenu didSelectRow");
    
    self.navTitle = self.types[row];
    //[self.navItem setTitle: self.types[row]];
    self.navigationItem.title = self.types[row];
    
    self.typeData = self.types[row];
    
    //@"最  新" ,@"熱  門", @"贊  助", @"關  注"
    if ([self.typeData isEqualToString: @"最  新"]) {
        self.typeData = @"latest";
    } else if ([self.typeData isEqualToString: @"熱  門"]) {
        self.typeData = @"hot";
    } else if ([self.typeData isEqualToString: @"贊  助"]) {
        self.typeData = @"sponsored";
    } else if ([self.typeData isEqualToString: @"關  注"]) {
        self.typeData = @"follow";
    }
    
    NSLog(@"self.typeData: %@", self.typeData);
    
    delay(0.1, ^{
        [dropdownMenu closeAllComponentsAnimated:YES];
        [dropdownMenu reloadAllComponents];
    });
    
    [self refresh];
}

#pragma mark -
- (void)FastBtnPressed
{
    [self FastBtn: nil];
}

- (IBAction)FastBtn:(id)sender {
    // Data Storing for FastViewController popToHomeViewController Directly
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL fromHomeVC = YES;
    [defaults setObject: [NSNumber numberWithBool: fromHomeVC]
                 forKey: @"fromHomeVC"];
    [defaults synchronize];
    
    NSLog(@"FastBtn");
    
    //判斷是否有編輯中相本
    
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone=[boxAPI checkalbumofdiy:[wTools getUserID] token:[wTools getUserToken]];
        [wTools HideMBProgressHUD];
        
        if (respone!=nil) {
            NSLog(@"%@",respone);
            NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            
            if ([dic[@"result"]boolValue]) {
                [boxAPI updatealbumofdiy:[wTools getUserID] token:[wTools getUserToken] album_id:[dic[@"data"][@"album"][@"album_id"] stringValue]];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            [self addNewFastMod];
        });
    });     
}

//快速套版
-(void)addNewFastMod {
    
    NSLog(@"addNewFastMod");
    
    //新增相本id
    //[wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone=[boxAPI insertalbumofdiy:[wTools getUserID] token:[wTools getUserToken] template_id:@"0"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [wTools HideMBProgressHUD];
            
            if (respone!=nil) {
                NSLog(@"%@",respone);
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                if ([dic[@"result"]boolValue]) {
                    NSLog(@"get result value from insertalbumofdiy");
                    //[self performSegueWithIdentifier: @"showFastViewController" sender: self];
                    //NSString *tempalbum_id = [dic[@"data"] stringValue];
                    
                    self.tempAlbumId = [dic[@"data"] stringValue];
                    
                    FastViewController *fVC = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"FastViewController"];
                    fVC.selectrow = [wTools userbook];
                    fVC.albumid = self.tempAlbumId;
                    fVC.templateid = @"0";
                    fVC.choice = @"Fast";
                    
                    //AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    //[app.myNav pushViewController: fVC animated:YES];
                    
                    [self.navigationController pushViewController: fVC animated: YES];
                } else {
                    
                }
            }
        });
    });
}

- (IBAction)showSetup:(id)sender {
    // Data Storing for FastViewController popToHomeViewController Directly
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL fromHomeVC = YES;
    [defaults setObject: [NSNumber numberWithBool: fromHomeVC]
                 forKey: @"fromHomeVC"];
    [defaults synchronize];
    
    [self performSegueWithIdentifier: @"showSetupViewController" sender: self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"prepareForSegue");
    
    if ([segue.identifier isEqualToString: @"showFastViewController"]) {
        
        BOOL fromPageCollection = NO;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject: [NSNumber numberWithBool: fromPageCollection]
                     forKey: @"fromPageCollection"];
        [defaults synchronize];
        
        FastViewController *fVC = segue.destinationViewController;
        fVC.selectrow = [wTools userbook];
        fVC.albumid = self.tempAlbumId;
        fVC.templateid = @"0";
        fVC.choice = @"Fast";
    }
    if ([segue.identifier isEqualToString: @"showSetupViewController"]) {
        BOOL fromPageCollection = NO;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject: [NSNumber numberWithBool: fromPageCollection]
                     forKey: @"fromPageCollection"];
        [defaults synchronize];
        
        SetupViewController *sVC = segue.destinationViewController;        
    }
    /*
    if ([segue.identifier isEqualToString: @"showRetrievealbumpViewController"]) {
        NSLog(@"show retrieveAlbum");
        
        RetrievealbumpViewController *rev = segue.destinationViewController;
        rev.data = [dicForSegue[@"data"] mutableCopy];
        
        NSLog(@"rev.data: %@", rev.data);
        
        rev.albumid = albumIdForSegue;
        
        rev.navigationController.navigationBar.barTintColor = [UIColor redColor];
    } 
     */
}

@end
