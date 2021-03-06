//
//  ViewController.m
//  wPinpinbox
//
//  Created by Angus on 2015/8/6.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "ChooseHobbyViewController.h"
#import "wTools.h"
#import "boxAPI.h"

#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "OfflineViewController.h"
#import "NSString+emailValidation.h"
#import "NSString+passwordValidation.h"
#import "VersionUpdate.h"
#import "UIColor+Extensions.h"
#import "UIView+Toast.h"
//#import "MBProgressHUD.h"
#import "CustomIOSAlertView.h"
#import "MyTabBarController.h"
#import "FBFriendsFindingViewController.h"
#import "ChooseHobbyViewController.h"
#import "ScanRegisterViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "GlobalVars.h"

#import "FBFriendsListViewController.h"
#import "AboutPinpinBoxViewController.h"
#import "UIColor+HexString.h"
#import "UIViewController+ErrorAlert.h"
#import <SafariServices/SafariServices.h>
#import "UserInfo.h"
#import "LabelAttributeStyle.h"

typedef void (^FBBlock)(void);typedef void (^FBBlock)(void);

//static NSString *pinpinbox = @"https://www.pinpinbox.com/";

@interface ViewController () <UIScrollViewDelegate, UITextFieldDelegate, UIApplicationDelegate, CLLocationManagerDelegate> {
    UIPageControl *pageControl;
    UITextField *selectText;
    FBBlock _alertOkHandler;
    BOOL isCreator;
    NSString *businessUserId;
    NSString *timeStamp;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    NSTimer *timer;
    UIImageView *bg;
}
@property (weak, nonatomic) IBOutlet UIButton *termsAndConditionsBtn;

@property (weak, nonatomic) IBOutlet UIButton *createAccountBtn;
@property (weak, nonatomic) IBOutlet UIButton *facebookLoginBtn;
@property (weak, nonatomic) IBOutlet UIButton *scanBtn;

@property (weak, nonatomic) IBOutlet UIView *horizontalLineView1;
@property (weak, nonatomic) IBOutlet UILabel *middleTextLabel;
@property (weak, nonatomic) IBOutlet UIView *horizontalLineView2;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIView *emailTextBgView;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UIView *pwdTextBgView;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *aboutBtn;

@property (nonatomic) NSString *tokenStr;
@property (nonatomic) NSString *idStr;
@end

@implementation ViewController
- (IBAction)vcTest:(id)sender {
}

#pragma mark - View Related Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"");
    NSLog(@"ViewController viewDidLoad");
    self.navigationController.navigationBar.hidden = YES;
    
    // Getting TimeStamp Info
    timeStamp = [NSString stringWithFormat: @"%f", [[NSDate date] timeIntervalSince1970] * 1000];
    NSLog(@"timeStamp: %@", timeStamp);
    
    // Getting Location Info
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([CLLocationManager locationServicesEnabled] && [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [locationManager requestWhenInUseAuthorization];
    }
    self.horizontalLineView1.backgroundColor = [UIColor secondGrey];
    self.middleTextLabel.textColor = [UIColor secondGrey];
    self.horizontalLineView2.backgroundColor = [UIColor secondGrey];
    
    [self faceBookLoginBtnSetup];
    [self createAccountBtnSetup];
    
    [self.termsAndConditionsBtn setTitle: NSLocalizedString(@"RegText-tipAgreementTitle", @"")
                                forState: UIControlStateNormal];
    [self scanBtnSetup];
    [self emailTextFieldAndViewSetup];
    [self pwdTextFieldAndViewSetup];
    [self loginBtnSetup];
    [self aboutBtnSetup];
    [self redirectionCheck];
}

- (void)faceBookLoginBtnSetup {
    self.facebookLoginBtn.layer.cornerRadius = kCornerRadius;
    self.facebookLoginBtn.backgroundColor = [UIColor colorFromHexString: @"3b5998"];
    self.facebookLoginBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
//    [self.facebookLoginBtn setTitle:NSLocalizedString(@"LoginText-FBlogin", @"") forState:UIControlStateNormal];
    self.facebookLoginBtn.titleLabel.font = [UIFont boldSystemFontOfSize: 18.0];
    [self.facebookLoginBtn setTitle: @"Facebook" forState: UIControlStateNormal];
    [self.facebookLoginBtn setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [LabelAttributeStyle changeGapStringAndLineSpacingCenterAlignment: self.facebookLoginBtn.titleLabel content: self.facebookLoginBtn.titleLabel.text];
}

- (void)createAccountBtnSetup {
    self.createAccountBtn.layer.cornerRadius = kCornerRadius;
    self.createAccountBtn.backgroundColor = [UIColor thirdGrey];
    self.createAccountBtn.titleLabel.font = [UIFont boldSystemFontOfSize: 18.0];
    [self.createAccountBtn setTitleColor: [UIColor firstGrey] forState: UIControlStateNormal];
    [LabelAttributeStyle changeGapStringAndLineSpacingCenterAlignment: self.createAccountBtn.titleLabel content: self.createAccountBtn.titleLabel.text];
}

- (void)scanBtnSetup {
    self.scanBtn.layer.cornerRadius = kCornerRadius;
    self.scanBtn.backgroundColor = [UIColor thirdGrey];
    self.scanBtn.titleLabel.font = [UIFont boldSystemFontOfSize: 18.0];
    [self.scanBtn setTitleColor: [UIColor firstGrey] forState: UIControlStateNormal];
    [LabelAttributeStyle changeGapStringAndLineSpacingCenterAlignment: self.scanBtn.titleLabel content: self.scanBtn.titleLabel.text];
}

- (void)emailTextFieldAndViewSetup {
    self.emailTextField.textColor = [UIColor firstGrey];
    self.emailTextBgView.layer.cornerRadius = kCornerRadius;
    self.emailTextBgView.layer.masksToBounds = YES;
    self.emailTextBgView.backgroundColor = [UIColor thirdGrey];
}

- (void)pwdTextFieldAndViewSetup {
    self.pwdTextField.textColor = [UIColor firstGrey];
    self.pwdTextBgView.layer.cornerRadius = kCornerRadius;
    self.pwdTextBgView.layer.masksToBounds = YES;
    self.pwdTextBgView.backgroundColor = [UIColor thirdGrey];
}

- (void)loginBtnSetup {
    self.loginBtn.titleLabel.font = [UIFont boldSystemFontOfSize: 18.0];
    self.loginBtn.layer.cornerRadius = kCornerRadius;
    self.loginBtn.layer.masksToBounds = YES;
    [self.loginBtn setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    self.loginBtn.backgroundColor = [UIColor firstMain];
    [self.loginBtn setTitle: NSLocalizedString(@"LoginText-login", @"") forState: UIControlStateNormal];
    [LabelAttributeStyle changeGapStringAndLineSpacingCenterAlignment: self.loginBtn.titleLabel content: self.loginBtn.titleLabel.text];
}

- (void)aboutBtnSetup {
    self.aboutBtn.titleLabel.font = [UIFont boldSystemFontOfSize: 18.0];
    self.aboutBtn.layer.cornerRadius = kCornerRadius;
    self.aboutBtn.layer.masksToBounds = YES;
    [self.aboutBtn setTitleColor: [UIColor secondGrey] forState: UIControlStateNormal];
    self.aboutBtn.backgroundColor = [UIColor clearColor];
    [LabelAttributeStyle changeGapStringAndLineSpacingCenterAlignment: self.aboutBtn.titleLabel content: self.aboutBtn.titleLabel.text];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [wTools setStatusBarBackgroundColor: [UIColor whiteColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"");
    NSLog(@"ViewController viewWillAppear");
    [wTools setStatusBarBackgroundColor: [UIColor clearColor]];
    [self addKeyboardNotification];
    
    // Check if log out from SettingViewController
    // then viewDidLoad will not be called
    // So, we set up the timeStamp & LocationManager again
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *logOut;
    
    if ([wTools objectExists: [defaults objectForKey: @"logOutFromSetting"]]) {
        logOut = [defaults objectForKey: @"logOutFromSetting"];
    }
    BOOL logOutFromSetting = [logOut boolValue];
    NSLog(@"logOutFromSetting: %d", logOutFromSetting);
    
    if (logOutFromSetting) {
        logOutFromSetting = NO;
        [defaults setObject: [NSNumber numberWithBool: logOutFromSetting] forKey: @"logOutFromSetting"];
        [defaults synchronize];
        
        // Getting TimeStamp Info
        timeStamp = [NSString stringWithFormat: @"%f", [[NSDate date] timeIntervalSince1970] * 1000];
        NSLog(@"timeStamp: %@", timeStamp);
        
        // Getting Location Info
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        if ([CLLocationManager locationServicesEnabled] && [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            [locationManager requestWhenInUseAuthorization];
        }
    }
}
    
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status ==kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        [locationManager startUpdatingLocation];
    } else if (status == kCLAuthorizationStatusNotDetermined) {
        [locationManager requestWhenInUseAuthorization];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"");
    NSLog(@"viewWillDisappear");
    [self removeKeyboardNotification];
    [self stopLocationAndNotificationFunction];
}

#pragma mark - Methods for scanning QRCode from other application such as line
- (void)setTimerForUrlScheme: (NSString *)BUID {
    NSLog(@"");
    NSLog(@"");
    NSLog(@"setTimerForUrlScheme");
    NSLog(@"BUID: %@", BUID);
    businessUserId = BUID;
    NSLog(@"businessUserId: %@", businessUserId);
    
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector: @selector(checkBusinessUserId) userInfo: nil repeats: YES];
}

#pragma mark - redirectionCheck
-(void)redirectionCheck {
    NSLog(@"redirectionCheck");
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    app.myNav = self.navigationController;
    
    // Set up launch image when app just launches
    UIImage *image;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                image = [UIImage imageNamed: @"BlankImage4"];
                break;
            case 1334:
                printf("iPhone 6/6S/7/8");
                image = [UIImage imageNamed: @"BlankImage4.7"];
                break;
            case 1920:
                printf("iPhone 6+/6S+/7+/8+");
                image = [UIImage imageNamed: @"BlankImage5.5"];
                break;
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                image = [UIImage imageNamed: @"BlankImage5.5"];
                break;
            case 2436:
                printf("iPhone X");
                image = [UIImage imageNamed: @"BlankImage5.8"];
                break;
            default:
                printf("unknown");
                break;
        }
    }
    bg = [[UIImageView alloc] initWithImage: image];
    bg.backgroundColor = [UIColor whiteColor];
    bg.contentMode = UIViewContentModeScaleAspectFit;
    bg.frame = self.view.bounds;
    bg.accessibilityIdentifier = @"launchImage";
    [self.view addSubview:bg];
    [self checkToken];
}

- (void)checkToken {
    NSLog(@"\n\ncheckToken");
    // Get ID & Token data from device
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    NSLog(@"id: %@", [userPrefs objectForKey: @"id"]);
    NSLog(@"token: %@", [userPrefs objectForKey: @"token"]);
    
    // Check ID & Token
    if ([userPrefs objectForKey:@"id"] && [userPrefs objectForKey:@"token"]) {
        if ([[userPrefs objectForKey:@"id"] isKindOfClass: [NSNumber class]]) {
            [userPrefs setObject: [[userPrefs objectForKey:@"id"] stringValue] forKey:@"id"];
            [userPrefs synchronize];
        }
        NSString *uid = [userPrefs objectForKey:@"id"];
        NSString *token = [userPrefs objectForKey:@"token"];
        
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
        __block typeof(bg) wbg = bg;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
            //BOOL respone = [boxAPI checktoken:token usid:uid];
            NSString *response = [boxAPI checktoken: token usid: uid];
            /*
            NSString *response = [PinPinBoxAPI checkToken: token
                                                     usid: uid];
            */
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
                    NSLog(@"response from checktoken");
                    NSLog(@"response: %@", response);
                    
                    if ([response isEqualToString: timeOutErrorCode]) {
                        NSLog(@"Time Out Message Return");
                        NSLog(@"ViewController");
                        NSLog(@"checkToken");
                        
                        [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                        protocolName: @"checkToken"
                                                fbId: @""
                                             jsonStr: @""
                                                name: @""];
                        
                    } else {
                        NSLog(@"Get Real Response");
                        NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                        NSLog(@"result intValue: %d", [dic[@"result"] intValue]);
                        
                        if ([dic[@"result"] intValue] == 1) {
                            NSLog(@"dic result boolValue is 1");
                            //[self toMyTabBarController];
                            //[self getProfile];
                            [wself refreshToken];
                        } else if ([dic[@"result"] intValue] == 0) {
                            NSLog(@"失敗： %@", dic[@"message"]);
                            if ([wTools objectExists: dic[@"message"]]) {
                                [wself showCustomErrorAlert: dic[@"message"]];
                                [wTools logOut];
                            } else {
                                [wself showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                            }
                        } else {
                            [wself showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                        }
                    }
                } else {
                    NSLog(@"response == nil");
                    if (![boxAPI hostAvailable: pinpinbox]) {
                        //[self showCustomAlertForOptions: @"是否離線瀏覽相本?"];
                        [wself showCustomErrorAlert: @"伺服器連線失敗"];
                    } else {
                        [UIView animateWithDuration:2.0 animations:^{
                            wbg.alpha=0;
                        } completion:^(BOOL anim){
                            [wbg removeFromSuperview];
                        }];
                    }
                }
            });
        });
    } else {
        [self checkBusinessUserId];
        __block typeof(bg) wbg = bg;
        [UIView animateWithDuration:2.0 animations:^{
            wbg.alpha=0;
        } completion:^(BOOL anim){
            [wbg removeFromSuperview];
        }];
    }
}

#pragma mark - checkBusinessUserId
- (void)checkBusinessUserId {
    NSLog(@"checkBusinessUserId");
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    businessUserId = [defaults objectForKey: @"businessUserId"];
    
    if ([wTools objectExists: businessUserId]) {
        if (![businessUserId isEqualToString: @""]) {
            [timer invalidate];
            [self Facebookbtn: nil];
        }
    }
//    if (businessUserId != nil) {
//        NSLog(@"businessUserId != nil");
//        if (![businessUserId isEqualToString: @""]) {
//            [timer invalidate];
//            [self Facebookbtn: nil];
//        }
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - defaultSetupForAudio
- (void)defaultSetupForAudio {
    // Audio Playing Automatically default value sets to YES
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: [NSNumber numberWithBool: YES] forKey: @"isAudioPlayedAutomatically"];
    [defaults synchronize];
}

#pragma mark - IBAction - Login Related
- (IBAction)termsAndConditionsBtnPressed:(id)sender {
    NSString *termStr = @"https://www.pinpinbox.com/index/index/terms";
    NSURL *url = [NSURL URLWithString: termStr];
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: url entersReaderIfAvailable: NO];
    safariVC.preferredBarTintColor = [UIColor whiteColor];
    [self presentViewController: safariVC animated: YES completion: nil];
}

- (IBAction)toAboutVC:(id)sender {
    AboutPinpinBoxViewController *aboutVC = [[UIStoryboard storyboardWithName: @"AboutPinpinBoxVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AboutPinpinBoxViewController"];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: aboutVC animated: YES];
}

- (IBAction)cameraBtnPress:(id)sender {
    ScanRegisterViewController *scanRegisterVC = [[UIStoryboard storyboardWithName: @"ScanRegisterVC" bundle: nil] instantiateViewControllerWithIdentifier: @"ScanRegisterViewController"];
    [self.navigationController pushViewController: scanRegisterVC animated: YES];
}

- (IBAction)loginbtn:(id)sender {
    NSLog(@"loginbtn");
    [self defaultSetupForAudio];
    
    // If Email Field is empty then message got data
    if ([self.emailTextField.text isEqualToString: @""]) {
        NSLog(@"self.emailTextField.text: %@", self.emailTextField.text);
        
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor thirdPink];
        
        [self.view makeToast: NSLocalizedString(@"LoginText-tipEmail", @"")
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
        return;
    }
    
    // If Password Field is empty then message got data
    if ([self.pwdTextField.text isEqualToString: @""]) {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor thirdPink];
        
        [self.view makeToast: NSLocalizedString(@"LoginText-tipPwd", @"")
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
        return;
    }
    [self loginAccount];
}

- (void)loginAccount {
    NSLog(@"loginAccount");
    @try {
        [DGHUDView start];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog(@"NSException caught");
        NSLog(@"Name: %@", exception.name);
        NSLog(@"Reason: %@", exception.reason);
        return;
    }
    NSLog(@"self.pwdTextField.text: %@", self.pwdTextField.text);
    
    NSString *emailStr = self.emailTextField.text;
    NSString *pwdStr = self.pwdTextField.text;
    __block typeof(self) wself = self;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSString *respone = [boxAPI LoginAccount: emailStr Pwd: pwdStr];
        __strong typeof(wself) sself = wself;
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [DGHUDView stop];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog(@"NSException caught");
                NSLog(@"Name: %@", exception.name);
                NSLog(@"Reason: %@", exception.reason);
                return;
            }
            if (respone != nil) {
                NSLog(@"response from LoginAccount");
                NSLog(@"respone: %@", respone);
                
                if ([respone isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ViewController");
                    NSLog(@"loginbtn");
                    
                    [sself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"loginAccount"
                                            fbId: @""
                                         jsonStr: @""
                                            name: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    NSLog(@"result intValue: %d", [dic[@"result"] intValue]);
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"dic result boolValue is 1");
                        if ([wTools objectExists: dic[@"data"][@"token"]]) {
                            sself.tokenStr = dic[@"data"][@"token"];
                        }
                        if ([wTools objectExists: dic[@"data"][@"id"]]) {
                            sself.idStr = [dic[@"data"][@"id"] stringValue];
                        }
                        [sself saveDataAfterLogin: @"emailLogin"];
                        //[self toMyTabBarController];
                        //[self getProfile];
                        [sself refreshToken];
                        //[self setupPushNotification];
                                                
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗： %@", dic[@"message"]);
                        if ([wTools objectExists: dic[@"message"]]) {
                            [sself showCustomErrorAlert: dic[@"message"]];
                        } else {
                            [sself showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                        }
                    } else {
                        [sself showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}

#pragma mark - IBAction - Facebook Button Press
//Facebook
-(IBAction)Facebookbtn:(id)sender {
    NSLog(@"Facebookbtn Pressed");
    [self defaultSetupForAudio];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: @"fbLogin" forKey: @"fbBtnPressed"];
    [defaults synchronize];
    
    if ([FBSDKAccessToken currentAccessToken]) {
        NSLog(@"FBSDKAccessToken currentAccessToken");
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logOut];
        [self fbLoginHandler];
    } else {
        NSLog(@"login with permissions");
        [self fbLoginHandler];
    }
}

- (void)fbLoginHandler {
    NSLog(@"");
    NSLog(@"");
    NSLog(@"fbLoginHandler");
    
    // Try to login with permissions
    __block typeof(self) wself = self;
    [self loginAndRequestPermissionsWithSuccessHandler:^{
        NSLog(@"");
        NSLog(@"loginAndRequestPermissionsWithSuccessHandler");
        
        NSString *fbtoken = [FBSDKAccessToken currentAccessToken].tokenString;
        NSString *fbId = [FBSDKAccessToken currentAccessToken].userID;
        
        NSLog(@"FB ID: %@", fbId);
        NSLog(@"FB Token: %@", fbtoken);
        
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        businessUserId = [defaults objectForKey: @"businessUserId"];
        
        if (wself->businessUserId != nil) {
            NSLog(@"businessUserId != nil");
            
            // If businessUserId is empty string
            if ([wself->businessUserId isEqualToString: @""]) {
                [self facebookLogin: fbId];
            } else {
                // If businessUserId is not empty
                // then it must be called from other App by scanning QRCode
                [self getFbDataAndLocation: fbId];
            }
        } else {
            NSLog(@"businessUserId == nil");
            [self facebookLogin: fbId];
        }
    }
                             declinedOrCanceledHandler:^{
                                 NSLog(@"");
                                 NSLog(@"declinedOrCanceledHandler");
                                 
                                 // If the user declined permissions tell them why we need permissions
                                 // and ask for permissions again if they want to grant permissions.
                                 
                                 [self resetBusinessUserId];
                                 [self stopLocationAndNotificationFunction];
                                 
                                 [self alertDeclinedPublishActionsWithCompletion:^{
                                     NSLog(@"");
                                     NSLog(@"alertDeclinedPublishActionsWithCompletion");
                                     NSLog(@"Before calling loginAndRequestPermissionsWithSuccessHandler");
                                     [self loginAndRequestPermissionsWithSuccessHandler:nil
                                                              declinedOrCanceledHandler:nil
                                                                           errorHandler:^(NSError * error) {
                                                                               NSLog(@"Error: %@", error.description);
                                                                           }];
                                 }];
                             }
                                          errorHandler:^(NSError * error) {
                                              NSLog(@"Error: %@", error.description);
                                          }];
}

// Get FB Personal Data & Location
- (void)getFbDataAndLocation:(NSString *)fbId {
    NSLog(@"getFbDataAndRegister: fbId: %@", fbId);
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue: @"id, email, birthday, gender, name" forKey: @"fields"];
    __block typeof(self) wself = self;
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters: parameters]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             NSLog(@"fetched user: %@", result);
             [wself->locationManager stopUpdatingLocation];
             
             // Get FB Personal Data
             NSString *emailAccount = result[@"email"];
             NSLog(@"emailAccount: %@", emailAccount);
             
             NSString *birthday = result[@"birthday"];
             NSLog(@"birthday: %@", birthday);
             
             NSString *gender = result[@"gender"];
             NSLog(@"gender: %@", gender);
             
             NSString *name = result[@"name"];
             NSLog(@"name: %@", name);
             
             // Making Param JSON String
             NSMutableDictionary *paramDic = [NSMutableDictionary new];
             
             if ([wTools objectExists: emailAccount]) {
                 [paramDic setObject: emailAccount forKey: @"account"];
             }
             if ([wTools objectExists: birthday]) {
                 [paramDic setObject: birthday forKey: @"birthday"];
             }
             if ([wTools objectExists: gender]) {
                 [paramDic setObject: gender forKey: @"gender"];
             }
             if ([wTools objectExists: name]) {
                 [paramDic setObject: name forKey: @"name"];
             }
             NSLog(@"currentLocation: %@", wself->currentLocation);
             
             // Get Location Data
             if ([wTools objectExists: wself->currentLocation]) {
                 NSString *latStr = [NSString stringWithFormat: @"%.8f", wself->currentLocation.coordinate.latitude];
                 NSString *longStr = [NSString stringWithFormat: @"%.8f", wself->currentLocation.coordinate.longitude];
                 NSString *locationStr = [NSString stringWithFormat: @"%@,%@", latStr, longStr];
                 NSLog(@"locationStr: %@", locationStr);
                 [paramDic setObject: locationStr forKey: @"coordinate"];
             }
             
//             if (wself->currentLocation != nil) {
//                 NSString *latStr = [NSString stringWithFormat: @"%.8f", wself->currentLocation.coordinate.latitude];
//                 NSString *longStr = [NSString stringWithFormat: @"%.8f", wself->currentLocation.coordinate.longitude];
//
//                 NSString *locationStr = [NSString stringWithFormat: @"%@,%@", latStr, longStr];
//                 NSLog(@"locationStr: %@", locationStr);
//
//                 [paramDic setObject: locationStr forKey: @"coordinate"];
//             }
             NSLog(@"paramDic: %@", paramDic);
             
             NSData *jsonData = [NSJSONSerialization dataWithJSONObject: paramDic options: 0 error: nil];
             NSString *jsonStr = [[NSString alloc] initWithData: jsonData encoding: NSUTF8StringEncoding];
             [wself buisnessSubUserFastRegister: fbId jsonStr: jsonStr];
         } else {
             NSLog(@"%@",error.localizedDescription);
         }
     }];
}

#pragma mark - Call Server
- (void)buisnessSubUserFastRegister:(NSString *)fbId
                            jsonStr:(NSString *)jsonStr {
    NSLog(@"buisnessSubUserFastRegister");
    @try {
        [DGHUDView start];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog(@"NSException caught");
        NSLog(@"Name: %@", exception.name);
        NSLog(@"Reason: %@", exception.reason);
        return;
    }
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI buisnessSubUserFastRegister: wself->businessUserId fbId: fbId timeStamp: wself->timeStamp param: jsonStr];
        __strong typeof(wself) sself = wself;
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [DGHUDView stop];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog(@"NSException caught");
                NSLog(@"Name: %@", exception.name);
                NSLog(@"Reason: %@", exception.reason);
                return;
            }
            if (response != nil) {
                NSLog(@"response from buisnessSubUserFastRegister: %@", response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ViewController");
                    NSLog(@"buisnessSubUserFastRegister fbId jonStr");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"buisnessSubUserFastRegister"
                                            fbId: fbId
                                         jsonStr: jsonStr
                                            name: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"] isEqualToString: @"SYSTEM_OK"]) {
                        NSLog(@"SYSTEM_OK");
                        NSLog(@"新用戶");
                        if ([wTools objectExists: dic[@"data"][@"token"][@"token"]]) {
                            sself.tokenStr = dic[@"data"][@"token"][@"token"];
                        }
                        if ([wTools objectExists: dic[@"data"][@"token"][@"user_id"]]) {
                            sself.idStr = [dic[@"data"][@"token"][@"user_id"] stringValue];
                        }
                        NSLog(@"tokenStr: %@", sself.tokenStr);
                        NSLog(@"idStr: %@", sself.idStr);
                        
                        [sself saveDataAfterLogin: @"facebookLogin"];
                        //[self setupPushNotification];
                        [sself toFbFindingVCAndResetData];
                    } else if ([dic[@"result"] isEqualToString: @"USER_EXISTS"]) {
                        NSLog(@"USER_EXISTS");
                        //已有帳號
                        NSLog(@"已有帳號");
                        //isCreator = [dic[@"data"][@"creative"] boolValue];
                        
                        if ([wTools objectExists: dic[@"data"][@"token"][@"token"]]) {
                            sself.tokenStr = dic[@"data"][@"token"][@"token"];
                        }
                        if ([wTools objectExists: dic[@"data"][@"token"][@"user_id"]]) {
                            sself.idStr = [dic[@"data"][@"token"][@"user_id"] stringValue];
                        }
                        NSLog(@"tokenStr: %@", sself.tokenStr);
                        NSLog(@"idStr: %@", sself.idStr);
                        
                        [sself saveDataAfterLogin: @"facebookLogin"];
                        //[self toMyTabBarController];
                        //[self getProfile];
                        [sself refreshToken];
                        //[self setupPushNotification];
                    } else if ([dic[@"result"] isEqualToString: @"SYSTEM_ERROR"]) {
                        NSLog(@"SYSTEM_ERROR");
                        NSLog(@"失敗： %@", dic[@"message"]);
                        if ([wTools objectExists: dic[@"message"]]) {
                            [sself showCustomErrorAlert: dic[@"message"]];
                        } else {
                            [sself showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                        }
                    } else if ([dic[@"result"] isEqualToString: @"TOKEN_ERROR"]) {
                        NSLog(@"TOKEN_ERROR");
                        NSLog(@"失敗： %@", dic[@"message"]);
                        if ([wTools objectExists: dic[@"message"]]) {
                            [sself showCustomErrorAlert: dic[@"message"]];
                        } else {
                            [sself showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                        }
                    }
                }
            }
        });
    });
}

- (void)facebookLogin:(NSString *)fbId {
    NSLog(@"facebookLogin fbId: %@", fbId);
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
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSString *response = [boxAPI FacebookLoginAccount: fbId];
        __strong typeof(wself) sself = wself;
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
                NSLog(@"get response from FacebookLoginAccount");
                //NSLog(@"respone: %@", respone);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ViewController");
                    NSLog(@"getProfile");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"FacebookLoginAccount"
                                            fbId: fbId
                                         jsonStr: @""
                                            name: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([data[@"result"]intValue] == 1) {
                        //已有帳號
                        NSLog(@"已有帳號");
                        
                        // Show Message to Tester
                        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                        style.messageColor = [UIColor whiteColor];
                        style.backgroundColor = [UIColor thirdPink];
                        
                        [self.view makeToast: @"已有帳號"
                                    duration: 2.0
                                    position: CSToastPositionBottom
                                       style: style];
                        
                        if ([wTools objectExists: data[@"data"][@"token"]]) {
                            sself.tokenStr = data[@"data"][@"token"];
                        }
                        if ([wTools objectExists: data[@"data"][@"id"]]) {
                            sself.idStr = [data[@"data"][@"id"] stringValue];
                        }
                        [sself saveDataAfterLogin: @"facebookLogin"];
                        //[self toMyTabBarController];
                        //[self getProfile];
                        [sself refreshToken];
                        //[self setupPushNotification];
                    } else if([data[@"result"] intValue] == 2) {
                        NSLog(@"");
                        NSLog(@"data result intValue == 2");
                        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
                        [parameters setValue: @"id, email, birthday, gender, name" forKey: @"fields"];
                        
                        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters: parameters]
                         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                             
                             if (!error) {
                                 NSString *userName = [result valueForKey:@"name"];
                                 [self FBSign: fbId name: userName];
                                 NSLog(@"註冊去");
                                 
                                 // Show Message to Tester
                                 CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                                 style.messageColor = [UIColor whiteColor];
                                 style.backgroundColor = [UIColor thirdPink];
                                 
                                 [sself.view makeToast: @"註冊去"
                                              duration: 2.0
                                              position: CSToastPositionBottom
                                                 style: style];
                             } else {
                                 NSLog(@"%@", error.localizedDescription);
                             }
                         }];
                    } else {
                        NSLog(@"失敗： %@", data[@"message"]);
                        if ([wTools objectExists: data[@"message"]]) {
                            [sself showCustomErrorAlert: data[@"message"]];
                        } else {
                            [sself showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                        }
                    }
                }
            }
        });
    });
}

-(void)FBSign:(NSString *)_facebookID
         name:(NSString *)wname {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject:@"" forKey:@"account"];
    [dic setObject:@"facebook" forKey:@"way"];
    
    if ([wTools objectExists: _facebookID]) {
        [dic setObject:_facebookID forKey:@"way_id"];
    }
    [dic setObject:@"" forKey:@"password"];
    
    if ([wTools objectExists: wname]) {
        [dic setObject:wname forKey:@"name"];
    }
    [dic setObject:@"" forKey:@"smspassword"];
    [dic setObject:@"" forKey:@"cellphone"];
    //  [dic setObject:app.coordinate  forKey:@"coordinate"];
    
    [DGHUDView start];
    
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSString *respone = [boxAPI registration:dic];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [DGHUDView stop];
            
            if (respone != nil) {
                NSLog(@"response from registration");
                
                if ([respone isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ViewController");
                    NSLog(@"FBSign facebookID fbId");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"FBSign"
                                            fbId: _facebookID
                                         jsonStr: @""
                                            name: wname];
                } else {
                    NSLog(@"Get Real Response");
                    
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    NSLog(@"%@",respone);
                    
                    if ([dic[@"result"] intValue] == 1) {
                        if ([wTools objectExists: dic[@"data"][@"token"]]) {
                            wself.tokenStr = dic[@"data"][@"token"];
                        }
                        if ([wTools objectExists: dic[@"data"][@"id"]]) {
                            wself.idStr = [dic[@"data"][@"id"] stringValue];
                        }
                        NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
                        [userPrefs setObject: @"NeedToCheck" forKey: @"newsLetterCheck"];
                        [userPrefs synchronize];
                        
                        [wself saveDataAfterLogin: @"facebookLogin"];
                        //[self setupPushNotification];
                        [wself toFbFindingVCAndResetData];
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗： %@", dic[@"message"]);
                        if ([wTools objectExists: dic[@"message"]]) {
                            [wself showCustomErrorAlert: dic[@"message"]];
                        } else {
                            [wself showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                        }
                    } else {
                        [wself showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}

- (void)loginAndRequestPermissionsWithSuccessHandler:(FBBlock)successHandler
                           declinedOrCanceledHandler:(FBBlock)declinedOrCanceledHandler
                                        errorHandler:(void (^)(NSError *))errorHandler {
    NSLog(@"loginAndRequestPermissionsWithSuccessHandler declinedOrCanceledHandler errorHandler");
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    //public_profile
    //publish_actions
    
    NSLog(@"FBSDKLoginManager alloc init");
    
    [login
     logInWithReadPermissions: @[@"public_profile", @"user_birthday", @"email"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         NSLog(@"logInWithReadPermissions");
         
         if (error) {
             if (errorHandler) {
                 errorHandler(error);
             }
             return;
         }
         if ([FBSDKAccessToken currentAccessToken] &&
             [[FBSDKAccessToken currentAccessToken].permissions containsObject:@"public_profile"]) {
             
             if (successHandler) {
                 NSLog(@"successHandler is YES");
                 successHandler();
             }
             return;
         }
         if (declinedOrCanceledHandler) {
             declinedOrCanceledHandler();
         }
     }];
}

- (void)alertDeclinedPublishActionsWithCompletion:(FBBlock)completion {
    NSLog(@"");
    NSLog(@"alertDeclinedPublishActionsWithCompletion");
    NSLog(@"nothing below");
    
    /*
     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Publish Permissions"
     message:@"Publish permissions are needed to share game content automatically. Do you want to enable publish permissions?"
     delegate:self
     cancelButtonTitle:@"No"
     otherButtonTitles:@"Ok", nil];
     _alertOkHandler = [completion copy];
     [alertView show];
     */
}

#pragma mark - Saving Data to Device
- (void)saveDataAfterLogin: (NSString *)loginType {
    NSLog(@"\nsaveDataAfterLogin");
    if ([loginType isEqualToString: @"emailLogin"]) {
        NSLog(@"loginType: %@", loginType);
        NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
        if ([wTools objectExists: _tokenStr]) {
            [userPrefs setObject: _tokenStr forKey:@"token"];
        }
        if ([wTools objectExists: _idStr]) {
            [userPrefs setObject: _idStr forKey:@"id"];
        }
        if ([wTools objectExists: self.pwdTextField.text]) {
            [userPrefs setObject: self.pwdTextField.text forKey: @"pwd"];
        }
        NSLog(@"idStr: %@", _idStr);
        NSLog(@"self.pwdTextField.text: %@", self.pwdTextField.text);
        NSLog(@"userPrefs: %@", userPrefs);
        
        [userPrefs synchronize];
    } else if ([loginType isEqualToString: @"facebookLogin"]) {
        NSLog(@"loginType: %@", loginType);
        NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
        if ([wTools objectExists: _tokenStr]) {
            [userPrefs setObject: _tokenStr forKey: @"token"];
        }
        if ([wTools objectExists: _idStr]) {
            [userPrefs setObject: _idStr forKey: @"id"];
        }
        [userPrefs setObject: @"FB" forKey: @"FB"];
        [userPrefs synchronize];
    }
    // for share extension //
    if ([wTools objectExists:_tokenStr] && [wTools objectExists:_idStr])
        [UserInfo setUserInfo:_idStr token:_tokenStr];
    
}

#pragma mark - Web Service - Refresh Token
- (void)refreshToken {
    NSLog(@"\n\nrefreshToken");
    @try {
        [DGHUDView start];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI refreshToken: [userPrefs objectForKey: @"id"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [DGHUDView stop];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog(@"NSException caught");
                NSLog(@"Name: %@", exception.name);
                NSLog(@"Reason: %@", exception.reason);
                return;
            }
            if (response != nil) {
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ViewController");
                    NSLog(@"refreshToken");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"refreshToken"
                                            fbId: @""
                                         jsonStr: @""
                                            name: @""];
                    
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    if ([dic[@"result"] isEqualToString: @"SYSTEM_OK"]) {
                        NSLog(@"result SYSTEM_OK");
                        if ([wTools objectExists: dic[@"data"][@"token"][@"token"]]) {
                            wself.tokenStr = dic[@"data"][@"token"][@"token"];
                        }
                        NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
                        [userPrefs setObject: wself.tokenStr forKey: @"token"];
                        // for share extension //
                        [UserInfo setUserInfo:wself.idStr token:wself.tokenStr];
                        [wself getProfile];
                        
                    } else if ([dic[@"result"] isEqualToString: @"SYSTEM_ERROR"]) {
                        NSLog(@"失敗： %@", dic[@"message"]);
                        if ([wTools objectExists: dic[@"message"]]) {
                            [wself showCustomErrorAlert: dic[@"message"]];
                        } else {
                            [wself showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                        }
                    } else if ([dic[@"result"] isEqualToString: @"TOKEN_ERROR"]) {
                        NSLog(@"TOKEN_ERROR");
                        NSLog(@"失敗： %@", dic[@"message"]);
                        if ([wTools objectExists: dic[@"message"]]) {
                            [wself showCustomErrorAlert: dic[@"message"]];
                        } else {
                            [wself showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                        }
                    }
                }
            }
        });
    });
}

#pragma mark - Web Service - GetProfile
- (void)getProfile {
    NSLog(@"");
    NSLog(@"");
    NSLog(@"getProfile");
    
    @try {
        [DGHUDView start];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"userPrefs id: %@", [userPrefs objectForKey: @"id"]);
        NSString *response = [boxAPI getprofile: [userPrefs objectForKey: @"id"]
                                          token: [userPrefs objectForKey: @"token"]];
        
        //NSString *testSign = [boxAPI testsign];
        
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
            //NSLog(@"testSign: %@", testSign);
            
            if (response != nil) {
                NSLog(@"Getting response from getprofile");
                //NSLog(@"response: %@", response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ViewController");
                    NSLog(@"getProfile");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getprofile"
                                            fbId: @""
                                         jsonStr: @""
                                            name: @""];
                } else {
                    NSLog(@"Get Real Response");
                    
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        [self getUrPoints];
                        
                        NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
                        NSMutableDictionary *dataIc = [[NSMutableDictionary alloc] initWithDictionary: dic[@"data"] copyItems: YES];
                        //NSLog(@"dataIc: %@", dataIc);
                        
                        // The method below just to check if there is a null object
                        // set it to empty string value
                        // Get all the keys
                        if ([wTools objectExists: [dataIc allKeys]]) {
                            for (NSString *key in [dataIc allKeys]) {
                                //NSLog(@"key: %@", key);
                                
                                // Get the object related to the key
                                id objective = [dataIc objectForKey: key];
                                //NSLog(@"objective: %@", objective);
                                
                                // if the object is null, then set empty string value to it
                                if ([objective isKindOfClass: [NSNull class]]) {
                                    [dataIc setObject: @"" forKey: key];
                                }
                            }
                            [userPrefs setValue: dataIc forKey: @"profile"];
                            [userPrefs synchronize];
                        }
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗： %@", dic[@"message"]);
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
                    NSLog(@"ViewController");
                    NSLog(@"getUrPoints");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"geturpoints"
                                            fbId: @""
                                         jsonStr: @""
                                            name: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"dic result boolValue is 1");
                        
                        if ([wTools objectExists: dic[@"data"]]) {
                            NSInteger point = [dic[@"data"] integerValue];
                            [userPrefs setObject: [NSNumber numberWithInteger: point] forKey: @"pPoint"];
                            [userPrefs synchronize];
                            //NSLog(@"point: %ld", (long)point);
                        }
                        [self toMyTabBarController];
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗： %@", dic[@"message"]);
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

#pragma mark - To MyTabBarController
- (void)toMyTabBarController {
    MyTabBarController *myTabC = [[UIStoryboard storyboardWithName: @"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"MyTabBarController"];
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.myNav pushViewController: myTabC animated: NO];
    __block typeof(bg) wbg = bg;
    [UIView animateWithDuration:2.0 animations:^{
        wbg.alpha=0;
    } completion:^(BOOL anim){
        [wbg removeFromSuperview];
    }];
    [self stopLocationAndNotificationFunction];
}

#pragma mark - To FB Finding ViewController
- (void)toFbFindingVCAndResetData {
    FBFriendsFindingViewController *fbFindingVC = [[UIStoryboard storyboardWithName:@"FBFriendsFindingVC" bundle:nil]instantiateViewControllerWithIdentifier:@"FBFriendsFindingViewController"];
    [self.navigationController pushViewController: fbFindingVC animated:YES];
    [self resetBusinessUserId];
    [self stopLocationAndNotificationFunction];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSLog(@"");
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    //SLog(@"");
    //NSLog(@"didUpdateLocations: %@", locations);
    currentLocation = [locations lastObject];
    //NSLog(@"currentLocation: %@", currentLocation);
}

#pragma mark - stopLocationAndNotificationFunction
- (void)stopLocationAndNotificationFunction {
    NSLog(@"");
    NSLog(@"stopLocationAndNotificationFunction");
    [[NSNotificationCenter defaultCenter] removeObserver: self name: UIApplicationDidBecomeActiveNotification object: nil];
    [locationManager stopUpdatingLocation];
    [timer invalidate];
    timer = nil;
}

#pragma mark - Reset Variable
- (void)resetBusinessUserId {
    NSLog(@"");
    NSLog(@"resetBusinessUserId");
    businessUserId = @"";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: businessUserId forKey: @"businessUserId"];
    [defaults synchronize];
}

#pragma mark - UIResponder Methods
- (void)touchesBegan:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event {
    [self.view endEditing: YES];
}

#pragma mark - ScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat width = sender.frame.size.width;
    NSInteger currentPage = ((sender.contentOffset.x - width / 2) / width) + 1;
    if (currentPage < 4) {
        [pageControl setCurrentPage:currentPage];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)sender{
    CGFloat width = sender.frame.size.width;
    NSInteger currentPage = ((sender.contentOffset.x - width / 2) / width) + 1;
    if (currentPage > 3) {
        sender.hidden=YES;
        [pageControl removeFromSuperview];
    }
}

#pragma mark - Notifications for Keyboard
- (void)addKeyboardNotification {
    NSLog(@"");
    NSLog(@"addKeyboardNotification");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)removeKeyboardNotification {
    NSLog(@"");
    NSLog(@"removeKeyboardNotification");
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardDidShowNotification
                                                  object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardWillHideNotification
                                                  object: nil];
}

#pragma mark -
- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSLog(@"keyboardWasShown");
    NSDictionary* info = [aNotification userInfo];
    NSLog(@"info: %@", info);
    
    // in iOS 11, the height of size of UIKeyboardFrameBeginUserInfoKey will be zero in second time
    // when keyboardWasshown method called
    //CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGSize kbSize = [[info objectForKey: UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSLog(@"kbSize: %@", NSStringFromCGSize(kbSize));
    
    //float textfy = [selectText superview].frame.origin.y;
    float textfy = selectText.superview.frame.origin.y;
    NSLog(@"textfy: %f", textfy);
    
    //float textfh = [selectText superview].frame.size.height;
    float textfh = selectText.superview.frame.size.height;
    NSLog(@"textfh: %f", textfh);
    
    float h = self.view.frame.size.height;
    NSLog(@"h: %f", h);
    
    float kh = kbSize.height;
    NSLog(@"kh: %f", kh);
    
    NSLog(@"");
    NSLog(@"textfh: %f", textfh);
    NSLog(@"textfy: %f", textfy);
    NSLog(@"h: %f", h);
    NSLog(@"kh: %f", kh);
    NSLog(@"");
    
    float height = (textfh + textfy) - (h - kh);
    NSLog(@"height: %f", height);
    
    if (height > 0) {
        NSLog(@"height > 0");
        NSLog(@"height: %f", height);
        
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, -height, self.view.frame.size.width, self.view.frame.size.height);
            NSLog(@"self.view.frame: %@", NSStringFromCGRect(self.view.frame));
        }];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    NSLog(@"keyboardWillBeHidden");
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        NSLog(@"self.view.frame: %@", NSStringFromCGRect(self.view.frame));
    }];
}

#pragma mark - UITextField Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"textFieldDidBeginEditing");
    selectText = textField;
    
    if (selectText.tag == 1) {
        selectText.returnKeyType = UIReturnKeyNext;
    }
    if (selectText.tag == 2) {
        selectText.returnKeyType = UIReturnKeyDone;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"textFieldDidEndEditing");
    selectText = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textFieldShouldReturn");
    
    NSInteger nextTag = textField.tag + 1;
    NSLog(@"nextTag: %ld", (long)nextTag);
    
    // Try to find next responder
    UIResponder *nextResponder = [textField.superview.superview viewWithTag: nextTag];
    NSLog(@"nextResponder: %@", nextResponder);
    
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard
        [textField resignFirstResponder];
    }
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Custom Error Alert Method
- (void)showCustomErrorAlert: (NSString *)msg {
    [UIViewController showCustomErrorAlertWithMessage:msg onButtonTouchUpBlock:^(CustomIOSAlertView *customAlertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[customAlertView tag]);
        [customAlertView close];
    }];
}

#pragma mark - Custom AlertView for Yes and No
- (void)showCustomAlertForOptions: (NSString *)msg {
    NSLog(@"showCustomAlert: Msg: %@", msg);
    
    CustomIOSAlertView *alertViewForOptions = [[CustomIOSAlertView alloc] init];
    //[alertViewForOptions setContainerView: [self createContainerViewForOptions: msg]];
    [alertViewForOptions setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertViewForOptions.arrangeStyle = @"Horizontal";
    
    [alertViewForOptions setButtonTitles: [NSMutableArray arrayWithObjects: @"否", @"是", nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertViewForOptions setButtonColors: [NSMutableArray arrayWithObjects: [UIColor clearColor], [UIColor clearColor],nil]];
    [alertViewForOptions setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
    [alertViewForOptions setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    [wTools setStatusBarBackgroundColor:[UIColor clearColor]];
    __weak CustomIOSAlertView *weakAlertViewForOptions = alertViewForOptions;
    [alertViewForOptions setOnButtonTouchUpInside:^(CustomIOSAlertView *alertViewForOptions, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertViewForOptions tag]);
        [weakAlertViewForOptions close];
        [wTools setStatusBarBackgroundColor:[UIColor whiteColor]];
        if (buttonIndex == 0) {
            exit(0);
        } else {
            OfflineViewController *hv= [[UIStoryboard storyboardWithName:@"Calbumlist" bundle:nil]instantiateViewControllerWithIdentifier:@"OfflineViewController"];
            [self.navigationController pushViewController:hv animated:YES];
        }
    }];
    [alertViewForOptions setUseMotionEffects: YES];
    [alertViewForOptions show];
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
    alertUpdateView.parentView = self.view;
    
    if ([option isEqualToString: @"mustupdate"]) {
        [alertUpdateView setButtonTitles: [NSMutableArray arrayWithObject: @"前往App Store"]];
        [alertUpdateView setButtonColors: [NSMutableArray arrayWithObject: [UIColor clearColor]]];
        [alertUpdateView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor whiteColor]]];
        [alertUpdateView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor darkMain]]];
    } else if ([option isEqualToString: @"canUpdateLater"]) {
        [alertUpdateView setButtonTitles: [NSMutableArray arrayWithObjects: @"下次再說", @"前往App Store", nil]];
        [alertUpdateView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor clearColor], [UIColor clearColor],nil]];
        [alertUpdateView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
        [alertUpdateView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    }
    __weak CustomIOSAlertView *weakAlertUpdateView = alertUpdateView;
    [wTools setStatusBarBackgroundColor:[UIColor clearColor]];
    [alertUpdateView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertUpdateView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertUpdateView tag]);
        [weakAlertUpdateView close];
        [wTools setStatusBarBackgroundColor:[UIColor whiteColor]];
        if ([option isEqualToString: @"mustUpdate"]) {
            if (buttonIndex == 0) {
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString: appStoreUrl] options:@{} completionHandler:nil];
            }
        } else if ([option isEqualToString: @"canUpdateLater"]) {
            if (buttonIndex == 0) {
                [self redirectionCheck];
            } else {
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString: appStoreUrl] options:@{} completionHandler:nil];
            }
        }
    }];
    [alertUpdateView setUseMotionEffects: YES];
    [alertUpdateView show];
}

#pragma mark - Custom Method for TimeOut
- (void)showCustomTimeOutAlert: (NSString *)msg
                  protocolName: (NSString *)protocolName
                          fbId: (NSString *)fbId
                       jsonStr: (NSString *)jsonStr
                          name: (NSString *)wname {
    CustomIOSAlertView *alertTimeOutView = [[CustomIOSAlertView alloc] init];
    //[alertTimeOutView setContainerView: [self createTimeOutContainerView: msg]];
    [alertTimeOutView setContentViewWithMsg:msg contentBackgroundColor:[UIColor darkMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertTimeOutView.arrangeStyle = @"Horizontal";
    
    alertTimeOutView.parentView = self.view;
    
    NSLog(@"protocolName: %@", protocolName);
    
    if ([protocolName isEqualToString: @"checkToken"] || [protocolName isEqualToString: @"getprofile"] || [protocolName isEqualToString: @"geturpoints"]) {
        NSLog(@"protocolName isEqualToString checkToken");
        [alertTimeOutView setButtonTitles: [NSMutableArray arrayWithObjects: NSLocalizedString(@"TimeOut-CloseBtnTitle", @""), NSLocalizedString(@"TimeOut-OKBtnTitle", @""), nil]];
    } else {
        [alertTimeOutView setButtonTitles: [NSMutableArray arrayWithObjects: NSLocalizedString(@"TimeOut-CancelBtnTitle", @""), NSLocalizedString(@"TimeOut-OKBtnTitle", @""), nil]];
    }
    
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
            NSLog(@"protocolName: %@", protocolName);
            if ([protocolName isEqualToString: @"checkToken"] || [protocolName isEqualToString: @"getprofile"] || [protocolName isEqualToString: @"geturpoints"]) {
                NSLog(@"protocolName isEqualToString checkToken");
                [self closeApp];
            }
        } else {            
            if ([protocolName isEqualToString: @"checkToken"]) {
                [weakSelf checkToken];
            } else if ([protocolName isEqualToString: @"loginAccount"]) {
                [weakSelf loginAccount];
            } else if ([protocolName isEqualToString: @"buisnessSubUserFastRegister"]) {
                [weakSelf buisnessSubUserFastRegister: fbId jsonStr: jsonStr];
            } else if ([protocolName isEqualToString: @"FacebookLoginAccount"]) {
                [weakSelf facebookLogin: fbId];
            } else if ([protocolName isEqualToString: @"FBSign"]) {
                [weakSelf FBSign: fbId name: wname];
            } else if ([protocolName isEqualToString: @"getprofile"]) {
                [weakSelf getProfile];
            } else if ([protocolName isEqualToString: @"geturpoints"]) {
                [weakSelf getUrPoints];
            } else if ([protocolName isEqualToString: @"refreshToken"]) {
                [weakSelf refreshToken];
            }
        }
    }];
    [alertTimeOutView setUseMotionEffects: YES];
    [alertTimeOutView show];
}


- (void)closeApp {
    // home button press programmatically
    UIApplication *app = [UIApplication sharedApplication];
    [app performSelector: @selector(suspend)];
    
    // wait 2 seconds while app is going background
    [NSThread sleepForTimeInterval: 0.5];
    
    // exit app when app is in background
    exit(0);
}

#pragma mark - StatusBar Setup
- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
