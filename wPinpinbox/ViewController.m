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
#import "homeViewController.h"
#import "Remind.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "OfflineViewController.h"
#import "NSString+emailValidation.h"
#import "NSString+passwordValidation.h"
#import "VersionUpdate.h"
#import "UIColor+Extensions.h"
#import "UIView+Toast.h"
#import "MBProgressHUD.h"
#import "CustomIOSAlertView.h"
#import "MyTabBarController.h"
#import "FBFriendsFindingViewController.h"
#import "ChooseHobbyViewController.h"
#import "ScanRegisterViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "GlobalVars.h"

#import "FBFriendsListViewController.h"

typedef void (^FBBlock)(void);typedef void (^FBBlock)(void);

//static NSString *pinpinbox = @"https://www.pinpinbox.com/";

@interface ViewController () <UIScrollViewDelegate, UITextFieldDelegate, UIApplicationDelegate, CLLocationManagerDelegate>
{
    UIPageControl *pageControl;
    
    UITextField *selectText;
    
    FBBlock _alertOkHandler;
    
    __weak IBOutlet UIButton *createAccountBtn;
    __weak IBOutlet UIButton *btn_login;
    __weak IBOutlet UIButton *facebooklogin;
    __weak IBOutlet UIButton *btn_reg;
    __weak IBOutlet UIButton *btn_forgetpwd;
    
    NSString *tokenStr;
    NSString *idStr;
    BOOL isCreator;
    
    NSString *businessUserId;
    NSString *timeStamp;
    
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    
    NSTimer *timer;
    
    UIImageView *bg;
}
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
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [locationManager requestWhenInUseAuthorization];
    }
    
    [locationManager startUpdatingLocation];
    
    createAccountBtn.titleLabel.font = [UIFont boldSystemFontOfSize: 18.0];
    [createAccountBtn setTitleColor: [UIColor firstGrey] forState: UIControlStateNormal];
    btn_login.titleLabel.font = [UIFont boldSystemFontOfSize: 18.0];
    [btn_login setTitleColor: [UIColor firstGrey] forState: UIControlStateNormal];
    btn_login.layer.cornerRadius = 16;
    btn_login.layer.masksToBounds = YES;
    [btn_login setTitle:NSLocalizedString(@"LoginText-login", @"") forState:UIControlStateNormal];
    
    facebooklogin.titleLabel.textAlignment = NSTextAlignmentCenter;
    [facebooklogin setTitle:NSLocalizedString(@"LoginText-FBlogin", @"") forState:UIControlStateNormal];
    [btn_reg setTitle:NSLocalizedString(@"LoginText-Reg", @"") forState:UIControlStateNormal];
    [btn_forgetpwd setTitle:NSLocalizedString(@"LoginText-forgetPwd", @"") forState:UIControlStateNormal];
    
    [self redirectionCheck];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"");
    NSLog(@"ViewController viewWillAppear");
    
    [self addKeyboardNotification];
    
    // Check if log out from SettingViewController
    // then viewDidLoad will not be called
    // So, we set up the timeStamp & LocationManager again
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *logOut = [defaults objectForKey: @"logOutFromSetting"];
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
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            [locationManager requestWhenInUseAuthorization];
        }
        
        [locationManager startUpdatingLocation];
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
            [MBProgressHUD showHUDAddedTo: self.view animated:YES];
        } @catch (NSException *exception) {
            // Print exception information
            NSLog( @"NSException caught" );
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
            return;
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
            //BOOL respone = [boxAPI checktoken:token usid:uid];
            NSString *response = [boxAPI checktoken: token usid: uid];
            /*
            NSString *response = [PinPinBoxAPI checkToken: token
                                                     usid: uid];
            */
            dispatch_async(dispatch_get_main_queue(), ^{
                @try {
                    [MBProgressHUD hideHUDForView: self.view  animated:YES];
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
                        
                        [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                        protocolName: @"checkToken"
                                                fbId: @""
                                             jsonStr: @""
                                                name: @""];
                        
                    } else {
                        NSLog(@"Get Real Response");
                        
                        NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                        
                        NSLog(@"dic: %@", dic);
                        
                        if ([dic[@"result"] boolValue]) {
                            NSLog(@"dic result boolValue is 1");
                            //[self toMyTabBarController];
                            //[self getProfile];
                            [self refreshToken];
                        } else {
                            NSLog(@"失敗： %@", dic[@"message"]);
                            NSString *msg = dic[@"message"];
                            
                            if (msg == nil) {
                                msg = NSLocalizedString(@"Host-NotAvailable", @"");
                            }
                            [self showCustomErrorAlert: msg];
                        }
                    }
                } else {
                    NSLog(@"response == nil");
                    
                    if (![boxAPI hostAvailable: pinpinbox]) {
                        //[self showCustomAlertForOptions: @"是否離線瀏覽相本?"];
                        [self showCustomErrorAlert: @"伺服器連線失敗"];
                    } else {
                        [UIView animateWithDuration:2.0 animations:^{
                            bg.alpha=0;
                        } completion:^(BOOL anim){
                            [bg removeFromSuperview];
                        }];
                    }
                }
            });
        });
    } else {
        [self checkBusinessUserId];
        
        [UIView animateWithDuration:2.0 animations:^{
            bg.alpha=0;
        } completion:^(BOOL anim){
            [bg removeFromSuperview];
        }];
    }
}

#pragma mark - checkBusinessUserId
- (void)checkBusinessUserId {
    NSLog(@"checkBusinessUserId");
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    businessUserId = [defaults objectForKey: @"businessUserId"];
    
    if (businessUserId != nil) {
        NSLog(@"businessUserId != nil");
        
        if (![businessUserId isEqualToString: @""]) {
            [timer invalidate];
            [self Facebookbtn: nil];
        }
    }
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
- (IBAction)cameraBtnPress:(id)sender {
    ScanRegisterViewController *scanRegisterVC = [[UIStoryboard storyboardWithName: @"ScanRegisterVC" bundle: nil] instantiateViewControllerWithIdentifier: @"ScanRegisterViewController"];
    [self.navigationController pushViewController: scanRegisterVC animated: YES];
}

- (IBAction)loginbtn:(id)sender {
    NSLog(@"loginbtn");
    
    [self defaultSetupForAudio];
    
    //NSString *msg = @"";
    
    // If Email Field is empty then message got data
    if ([email.text isEqualToString: @""]) {
        NSLog(@"email.text: %@", email.text);
        
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
    if ([pwd.text isEqualToString: @""]) {
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
        [MBProgressHUD showHUDAddedTo: self.view animated:YES];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
        
    NSLog(@"pwd.text: %@", pwd.text);
    
    NSString *emailStr = email.text;
    NSString *pwdStr = pwd.text;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSString *respone = [boxAPI LoginAccount: emailStr Pwd: pwdStr];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [MBProgressHUD hideHUDForView: self.view  animated:YES];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                return;
            }
            
            if (respone != nil) {
                NSLog(@"response from LoginAccount");
                NSLog(@"respone: %@", respone);
                
                if ([respone isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ViewController");
                    NSLog(@"loginbtn");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"loginAccount"
                                            fbId: @""
                                         jsonStr: @""
                                            name: @""];
                } else {
                    NSLog(@"Get Real Response");
                    
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    NSLog(@"dic: %@", dic);
                    
                    if ([dic[@"result"] boolValue]) {
                        NSLog(@"dic result boolValue is 1");

                        tokenStr = dic[@"data"][@"token"];
                        idStr = [dic[@"data"][@"id"] stringValue];

                        [self saveDataAfterLogin: @"emailLogin"];
                        //[self toMyTabBarController];
                        //[self getProfile];
                        [self refreshToken];
                        //[self setupPushNotification];
                    } else {
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

#pragma mark - IBAction - Facebook Button Press

//Facebook
-(IBAction)Facebookbtn:(id)sender {
    NSLog(@"Facebookbtn Pressed");
    
    [self defaultSetupForAudio];
    
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

- (void)fbLoginHandler
{
    NSLog(@"");
    NSLog(@"");
    NSLog(@"fbLoginHandler");
    
    // Try to login with permissions
    [self loginAndRequestPermissionsWithSuccessHandler:^{
        NSLog(@"");
        NSLog(@"loginAndRequestPermissionsWithSuccessHandler");
        
        NSString *fbtoken = [FBSDKAccessToken currentAccessToken].tokenString;
        NSString *fbId = [FBSDKAccessToken currentAccessToken].userID;
        
        NSLog(@"FB ID: %@", fbId);
        NSLog(@"FB Token: %@", fbtoken);
        
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        businessUserId = [defaults objectForKey: @"businessUserId"];
        
        if (businessUserId != nil) {
            NSLog(@"businessUserId != nil");
            
            // If businessUserId is empty string
            if ([businessUserId isEqualToString: @""]) {
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
- (void)getFbDataAndLocation:(NSString *)fbId
{
    NSLog(@"getFbDataAndRegister: fbId: %@", fbId);
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue: @"id, email, birthday, gender, name" forKey: @"fields"];
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters: parameters]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         
         if (!error) {
             NSLog(@"fetched user: %@", result);
             
             [locationManager stopUpdatingLocation];
             
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
             
             if (emailAccount != nil)
                 [paramDic setObject: emailAccount forKey: @"account"];
             
             if (birthday != nil)
                 [paramDic setObject: birthday forKey: @"birthday"];
             
             if (gender != nil)
                 [paramDic setObject: gender forKey: @"gender"];
             
             if (name != nil)
                 [paramDic setObject: name forKey: @"name"];
             
             NSLog(@"currentLocation: %@", currentLocation);
             
             // Get Location Data
             if (currentLocation != nil) {
                 NSString *latStr = [NSString stringWithFormat: @"%.8f", currentLocation.coordinate.latitude];
                 NSString *longStr = [NSString stringWithFormat: @"%.8f", currentLocation.coordinate.longitude];
                 
                 NSString *locationStr = [NSString stringWithFormat: @"%@,%@", latStr, longStr];
                 NSLog(@"locationStr: %@", locationStr);
                 
                 [paramDic setObject: locationStr forKey: @"coordinate"];
             }
             
             NSLog(@"paramDic: %@", paramDic);
             
             NSData *jsonData = [NSJSONSerialization dataWithJSONObject: paramDic options: 0 error: nil];
             NSString *jsonStr = [[NSString alloc] initWithData: jsonData encoding: NSUTF8StringEncoding];
             
             [self buisnessSubUserFastRegister: fbId jsonStr: jsonStr];
         } else {
             NSLog(@"%@",error.localizedDescription);
         }
     }];
}

#pragma mark - Call Server
- (void)buisnessSubUserFastRegister:(NSString *)fbId jsonStr:(NSString *)jsonStr
{
    NSLog(@"buisnessSubUserFastRegister");
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
        NSString *response = [boxAPI buisnessSubUserFastRegister: businessUserId fbId: fbId timeStamp: timeStamp param: jsonStr];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [MBProgressHUD hideHUDForView: self.view animated:YES];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
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
                        NSLog(@"dic: %@", dic);
                        
                        NSLog(@"新用戶");
                        
                        tokenStr = dic[@"data"][@"token"][@"token"];
                        idStr = [dic[@"data"][@"token"][@"user_id"] stringValue];
                        
                        NSLog(@"tokenStr: %@", tokenStr);
                        NSLog(@"idStr: %@", idStr);
                        
                        [self saveDataAfterLogin: @"facebookLogin"];
                        //[self setupPushNotification];
                        [self toFbFindingVCAndResetData];
                        
                    } else if ([dic[@"result"] isEqualToString: @"USER_EXISTS"]) {
                        NSLog(@"USER_EXISTS");
                        NSLog(@"dic: %@", dic);
                        
                        //已有帳號
                        NSLog(@"已有帳號");
                        
                        //isCreator = [dic[@"data"][@"creative"] boolValue];
                        tokenStr = dic[@"data"][@"token"][@"token"];
                        idStr = [dic[@"data"][@"token"][@"user_id"] stringValue];
                        
                        NSLog(@"tokenStr: %@", tokenStr);
                        NSLog(@"idStr: %@", idStr);
                        
                        [self saveDataAfterLogin: @"facebookLogin"];
                        //[self toMyTabBarController];
                        //[self getProfile];
                        [self refreshToken];
                        //[self setupPushNotification];
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
                        NSString *msg = dic[@"message"];
                        
                        if (msg == nil) {
                            msg = NSLocalizedString(@"Host-NotAvailable", @"");
                        }
                        [self showCustomErrorAlert: dic[@"message"]];
                    }
                }
            }
        });
    });
}

-(void)facebookLogin:(NSString *)fbId {
    NSLog(@"\nfacebookLogin");
    
    @try {
        [MBProgressHUD showHUDAddedTo: self.view animated:YES];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSString *response = [boxAPI FacebookLoginAccount: fbId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [MBProgressHUD hideHUDForView: self.view  animated:YES];
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
                    
                    NSLog(@"data: %@", data);
                    
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
                        
                        tokenStr = data[@"data"][@"token"];
                        idStr = [data[@"data"][@"id"] stringValue];
                        
                        [self saveDataAfterLogin: @"facebookLogin"];
                        //[self toMyTabBarController];
                        //[self getProfile];
                        [self refreshToken];
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
                                 
                                 [self.view makeToast: @"註冊去"
                                             duration: 2.0
                                             position: CSToastPositionBottom
                                                style: style];
                             } else {
                                 NSLog(@"%@", error.localizedDescription);
                             }
                         }];
                        
                    } else {
                        //[wTools showAlertTile:@"" Message:data[@"message"] ButtonTitle:@"確定"];
                        [self showCustomErrorAlert: data[@"message"]];
                    }
                }
            }
        });
    });
}

-(void)FBSign:(NSString *)_facebookID name:(NSString *)wname {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject:@""forKey:@"account"];
    [dic setObject:@"facebook" forKey:@"way"];
    [dic setObject:_facebookID forKey:@"way_id"];
    [dic setObject:@"" forKey:@"password"];
    
    [dic setObject:wname forKey:@"name"];
    [dic setObject:@"" forKey:@"smspassword"];
    [dic setObject:@"" forKey:@"cellphone"];
    //  [dic setObject:app.coordinate  forKey:@"coordinate"];
    
    @try {
        [MBProgressHUD showHUDAddedTo: self.view animated:YES];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSString *respone = [boxAPI registration:dic];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [MBProgressHUD hideHUDForView: self.view animated:YES];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                return;
            }
            
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
                    
                    NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    NSLog(@"%@",respone);
                    
                    if ([data[@"result"] boolValue]) {
                        tokenStr = data[@"data"][@"token"];
                        idStr = [data[@"data"][@"id"] stringValue];
                        
                        [self saveDataAfterLogin: @"facebookLogin"];
                        //[self setupPushNotification];
                        [self toFbFindingVCAndResetData];
                    } else {
                        NSLog(@"失敗：%@",data[@"message"]);
                        NSString *msg = dic[@"message"];
                        
                        if (msg == nil) {
                            msg = NSLocalizedString(@"Host-NotAvailable", @"");
                        }
                        [self showCustomErrorAlert: dic[@"message"]];
                    }
                }
            }
        });
    });
}

- (void)loginAndRequestPermissionsWithSuccessHandler:(FBBlock) successHandler
                           declinedOrCanceledHandler:(FBBlock) declinedOrCanceledHandler
                                        errorHandler:(void (^)(NSError *)) errorHandler
{
    NSLog(@"loginAndRequestPermissionsWithSuccessHandler declinedOrCanceledHandler errorHandler");
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    //public_profile
    //publish_actions
    [login
     logInWithReadPermissions: @[@"public_profile", @"user_birthday", @"email"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         
         if (error) {
             if (errorHandler) {
                 errorHandler(error);
             }
             return;
         }
         
         if ([FBSDKAccessToken currentAccessToken] &&
             [[FBSDKAccessToken currentAccessToken].permissions containsObject:@"public_profile"]) {
             
             if (successHandler) {
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
        [userPrefs setObject: tokenStr forKey:@"token"];
        [userPrefs setObject: idStr forKey:@"id"];
        [userPrefs setObject: pwd.text forKey: @"pwd"];
        
        NSLog(@"idStr: %@", idStr);
        NSLog(@"pwd.text: %@", pwd.text);
        
        NSLog(@"userPrefs: %@", userPrefs);
        
        [userPrefs synchronize];
    } else if ([loginType isEqualToString: @"facebookLogin"]) {
        NSLog(@"loginType: %@", loginType);
        
        NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
        [userPrefs setObject: tokenStr forKey: @"token"];
        [userPrefs setObject: idStr forKey: @"id"];
        [userPrefs setObject: @"FB" forKey: @"FB"];
        [userPrefs synchronize];
    }
}

#pragma mark - Web Service - Refresh Token
- (void)refreshToken {
    NSLog(@"\n\nrefreshToken");
    
    @try {
        [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI refreshToken: [userPrefs objectForKey: @"id"]];
        
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
                    
                    NSLog(@"dic: %@", dic);
                    
                    if ([dic[@"result"] isEqualToString: @"SYSTEM_OK"]) {
                        NSLog(@"result SYSTEM_OK");
                        
                        tokenStr = dic[@"data"][@"token"][@"token"];
                        
                        NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
                        [userPrefs setObject: tokenStr forKey: @"token"];
                        
                        [self getProfile];
                    } else if ([dic[@"result"] isEqualToString: @"SYSTEM_ERROR"]) {
                        NSLog(@"失敗：%@",dic[@"message"]);
                        [self showCustomErrorAlert: dic[@"message"]];
                    } else if ([dic[@"result"] isEqualToString: @"TOKEN_ERROR"]) {
                        NSLog(@"TOKEN_ERROR");
                        
                        NSString *msg = dic[@"message"];
                        
                        if (msg == nil) {
                            msg = NSLocalizedString(@"Host-NotAvailable", @"");
                        }
                        [self showCustomErrorAlert: dic[@"message"]];
                    }
                }
            }
        });
    });
}

#pragma mark - Web Service - GetProfile
- (void)getProfile
{
    NSLog(@"");
    NSLog(@"");
    NSLog(@"getProfile");
    
    @try {
        [MBProgressHUD showHUDAddedTo: self.view animated: YES];
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
        //NSString *response = [PinPinBoxAPI getProfile: [userPrefs objectForKey: @"id"] token: [userPrefs objectForKey: @"token"]];
        
        NSString *response = [boxAPI getprofile: [userPrefs objectForKey: @"id"]
                                          token: [userPrefs objectForKey: @"token"]];
        
        //NSString *testSign = [boxAPI testsign];
        
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
                    
                    if ([dic[@"result"] boolValue]) {
                        [self getUrPoints];
                        
                        NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
                        NSMutableDictionary *dataIc = [[NSMutableDictionary alloc] initWithDictionary: dic[@"data"] copyItems: YES];
                        //NSLog(@"dataIc: %@", dataIc);
                        
                        // The method below just to check if there is a null object
                        // set it to empty string value
                        // Get all the keys
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
                        //NSLog(@"dataIc: %@", dataIc);
                        
                        [userPrefs setValue: dataIc forKey: @"profile"];
                        [userPrefs synchronize];
                    } else {
                        NSLog(@"失敗: %@", dic[@"message"]);
                        NSString *msg = dic[@"message"];
                        
                        if (msg == nil) {
                            msg = NSLocalizedString(@"Host-NotAvailable", @"");
                        }
                        [self showCustomErrorAlert: dic[@"message"]];
                    }
                }
            }
        });
    });
}

#pragma mark - Get P Point
- (void)getUrPoints
{
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
        //NSString *response = [PinPinBoxAPI getUrPoints: [userPrefs objectForKey:@"id"]  token: [userPrefs objectForKey:@"token"]];
                
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
                    NSLog(@"dic: %@", dic);
                    
                    if ([dic[@"result"] boolValue]) {
                        NSLog(@"dic result boolValue is 1");
                        NSInteger point = [dic[@"data"] integerValue];
                        //NSLog(@"point: %ld", (long)point);
                        
                        [userPrefs setObject: [NSNumber numberWithInteger: point] forKey: @"pPoint"];
                        [userPrefs synchronize];
                        
                        [self toMyTabBarController];
                    } else {
                        NSLog(@"失敗： %@", dic[@"message"]);
                        NSString *msg = dic[@"message"];
                        
                        if (msg == nil) {
                            msg = NSLocalizedString(@"Host-NotAvailable", @"");
                        }
                        [self showCustomErrorAlert: dic[@"message"]];
                    }
                }
            }
        });
    });
}

#pragma mark - To MyTabBarController
- (void)toMyTabBarController
{
    MyTabBarController *myTabC = [[UIStoryboard storyboardWithName: @"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"MyTabBarController"];
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.myNav pushViewController: myTabC animated: NO];
 
    [UIView animateWithDuration:2.0 animations:^{
        bg.alpha=0;
    } completion:^(BOOL anim){
        [bg removeFromSuperview];
    }];
    
    [self stopLocationAndNotificationFunction];
}

#pragma mark - To FB Finding ViewController
- (void)toFbFindingVCAndResetData
{
    FBFriendsFindingViewController *fbFindingVC = [[UIStoryboard storyboardWithName:@"FBFriendsFindingVC" bundle:nil]instantiateViewControllerWithIdentifier:@"FBFriendsFindingViewController"];
    [self.navigationController pushViewController: fbFindingVC animated:YES];
    
    [self resetBusinessUserId];
    [self stopLocationAndNotificationFunction];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"");
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    //SLog(@"");
    //NSLog(@"didUpdateLocations: %@", locations);
    currentLocation = [locations lastObject];
    //NSLog(@"currentLocation: %@", currentLocation);
}

#pragma mark - stopLocationAndNotificationFunction

- (void)stopLocationAndNotificationFunction
{
    NSLog(@"");
    NSLog(@"stopLocationAndNotificationFunction");
    
    [[NSNotificationCenter defaultCenter] removeObserver: self name: UIApplicationDidBecomeActiveNotification object: nil];
    
    [locationManager stopUpdatingLocation];
    
    [timer invalidate];
    timer = nil;
}

#pragma mark - Reset Variable

- (void)resetBusinessUserId
{
    NSLog(@"");
    NSLog(@"resetBusinessUserId");
    businessUserId = @"";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: businessUserId forKey: @"businessUserId"];
    [defaults synchronize];
}

#pragma mark - UIResponder Methods

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing: YES];
}

#pragma mark - ScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat width = sender.frame.size.width;
    NSInteger currentPage = ((sender.contentOffset.x - width / 2) / width) + 1;
    if (currentPage<4) {
        [pageControl setCurrentPage:currentPage];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)sender{
    CGFloat width = sender.frame.size.width;
    NSInteger currentPage = ((sender.contentOffset.x - width / 2) / width) + 1;
    if (currentPage>3) {
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

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSLog(@"keyboardWasShown");
    
    NSDictionary* info = [aNotification userInfo];
    NSLog(@"info: %@", info);
    
    // in iOS 11, the height of size of UIKeyboardFrameBeginUserInfoKey will be zero in second time
    // when keyboardWasshown method called
    //CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGSize kbSize = [[info objectForKey: UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSLog(@"kbSize: %@", NSStringFromCGSize(kbSize));
    
    //float textfy = [selectText superview].frame.origin.y;
    float textfy = selectText.frame.origin.y;
    NSLog(@"textfy: %f", textfy);
    
    //float textfh = [selectText superview].frame.size.height;
    float textfh = selectText.frame.size.height;
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
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
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
    
    // Try to find next responder
    UIResponder *nextResponder = [textField.superview viewWithTag: nextTag];
    
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
    CustomIOSAlertView *errorAlertView = [[CustomIOSAlertView alloc] init];
    [errorAlertView setContainerView: [self createErrorContainerView: msg]];
    
    [errorAlertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    [errorAlertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    [errorAlertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    errorAlertView.arrangeStyle = @"Horizontal";
    
    /*
     [alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
     [alertView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor firstMain], [UIColor firstPink], [UIColor secondGrey], nil]];
     [alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor darkMain], [UIColor darkPink], [UIColor firstGrey], nil]];
     alertView.arrangeStyle = @"Vertical";
     */
    
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

#pragma mark - Custom AlertView for Yes and No
- (void)showCustomAlertForOptions: (NSString *)msg
{
    NSLog(@"showCustomAlert: Msg: %@", msg);
    
    CustomIOSAlertView *alertViewForOptions = [[CustomIOSAlertView alloc] init];
    [alertViewForOptions setContainerView: [self createContainerViewForOptions: msg]];
    
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertViewForOptions.arrangeStyle = @"Horizontal";
    
    [alertViewForOptions setButtonTitles: [NSMutableArray arrayWithObjects: @"否", @"是", nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertViewForOptions setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor firstMain],nil]];
    [alertViewForOptions setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor whiteColor], nil]];
    [alertViewForOptions setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    
    __weak CustomIOSAlertView *weakAlertViewForOptions = alertViewForOptions;
    [alertViewForOptions setOnButtonTouchUpInside:^(CustomIOSAlertView *alertViewForOptions, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertViewForOptions tag]);
        [weakAlertViewForOptions close];
        
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

- (UIView *)createContainerViewForOptions: (NSString *)msg
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
    [alertUpdateView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertUpdateView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertUpdateView tag]);
        
        [weakAlertUpdateView close];
        
        if ([option isEqualToString: @"mustUpdate"]) {
            if (buttonIndex == 0) {
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString: appStoreUrl]];
            }
        } else if ([option isEqualToString: @"canUpdateLater"]) {
            if (buttonIndex == 0) {
                [self redirectionCheck];
            } else {
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString: appStoreUrl]];
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

#pragma mark - Custom Method for TimeOut
- (void)showCustomTimeOutAlert: (NSString *)msg
                  protocolName: (NSString *)protocolName
                          fbId: (NSString *)fbId
                       jsonStr: (NSString *)jsonStr
                          name: (NSString *)wname
{
    CustomIOSAlertView *alertTimeOutView = [[CustomIOSAlertView alloc] init];
    [alertTimeOutView setContainerView: [self createTimeOutContainerView: msg]];
    
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

- (void)closeApp
{
    // home button press programmatically
    UIApplication *app = [UIApplication sharedApplication];
    [app performSelector: @selector(suspend)];
    
    // wait 2 seconds while app is going background
    [NSThread sleepForTimeInterval: 0.5];
    
    // exit app when app is in background
    exit(0);
}

#pragma mark - StatusBar Setup
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
