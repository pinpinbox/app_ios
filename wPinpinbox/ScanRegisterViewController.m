//
//  ScanRegisterViewController.m
//  wPinpinbox
//
//  Created by David Lee on 2017/9/29.
//  Copyright © 2017年 Angus. All rights reserved.
//

#import "ScanRegisterViewController.h"
#import "AppDelegate.h"
#import "wTools.h"
#import "boxAPI.h"
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"

#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import "OpenUDID.h"

#import "UIColor+Extensions.h"
#import "UIView+Toast.h"
#import "CustomIOSAlertView.h"
#import "MyTabBarController.h"

#import "FBFriendsFindingViewController.h"
#import "ChooseHobbyViewController.h"

#import <CoreLocation/CoreLocation.h>

#import "GlobalVars.h"

typedef void (^FBBlock)(void);typedef void (^FBBlock)(void);

@interface ScanRegisterViewController () <AVCaptureMetadataOutputObjectsDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate>
{
    NSString *businessUserId;
    NSString *timeStamp;
    
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    
    NSString *tokenStr;
    NSString *idStr;
}
@property (weak, nonatomic) IBOutlet UIView *viewPreview;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarHeight;
@end

@implementation ScanRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.delegate = self;
    
    self.navBarView.backgroundColor = [UIColor clearColor];
    
    timeStamp = [NSString stringWithFormat: @"%f", [[NSDate date] timeIntervalSince1970] * 1000];
    NSLog(@"timeStamp: %@", timeStamp);
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [locationManager requestWhenInUseAuthorization];
    }
    
    [locationManager startUpdatingLocation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startReading];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.enabled = YES;
    
    [wTools setStatusBarBackgroundColor: [UIColor clearColor]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [wTools setStatusBarBackgroundColor: [UIColor whiteColor]];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    NSLog(@"viewDidLayoutSubviews");
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                break;
            case 1334:
                printf("iPhone 6/6S/7/8");
                break;
            case 1920:
                printf("iPhone 6+/6S+/7+/8+");
                break;
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                break;
            case 2436:
                printf("iPhone X");
                self.navBarHeight.constant = 60;
                break;
            default:
                printf("unknown");
                break;
        }
    }
}

- (IBAction)backBtnPress:(id)sender {
    [locationManager stopUpdatingLocation];
    //[self.navigationController popViewControllerAnimated: YES];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav popViewControllerAnimated: YES];
}

- (BOOL)startReading {
    NSError *error;
    
    // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
    // as the media type parameter.
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Get an instance of the AVCaptureDeviceInput class using the previous device object.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        // If any error occurs, simply log the description of it and don't continue any more.
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    // Initialize the captureSession object.
    _captureSession = [[AVCaptureSession alloc] init];
    // Set the input device on the capture session.
    [_captureSession addInput:input];
    
    
    // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    // Create a new serial dispatch queue.
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes: @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                                                     AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                                                     AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode]];
    
    // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
    [_viewPreview.layer addSublayer:_videoPreviewLayer];
    
    
    // Start video capture.
    [_captureSession startRunning];
    
    return YES;
}

- (void)stopReading {
    // Stop video capture and make the capture session object nil.
    [_captureSession stopRunning];
    _captureSession = nil;
    
    // Remove the video preview layer from the viewPreview view's layer.
    [_videoPreviewLayer removeFromSuperlayer];
}

- (void)loadBeepSound
{
    // Get the path to the beep.mp3 file and convert it to a NSURL object.
    NSString *beepFilePath = [[NSBundle mainBundle] pathForResource: @"beep"
                                                             ofType: @"mp3"];
    NSURL *beepURL = [NSURL URLWithString: beepFilePath];
    NSError *error;
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: beepURL
                                                          error: &error];
    if (error) {
        NSLog(@"Could not play beep file.");
        NSLog(@"%@", [error localizedDescription]);
    } else {
        [_audioPlayer prepareToPlay];
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate method implementation
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    NSLog(@"didOutputMetadataObjects");
    
    // Check if the metadataObjects array is not nil and it contains at least one object.
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        NSLog(@"metadataObjects != nil && [metadataObjects count] > 0");
        
        // Get the metadata Objects.
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex: 0];
        NSLog(@"metadataObj stringValue: %@", [metadataObj stringValue]);
        
        [self performSelectorOnMainThread: @selector(stopReading) withObject: nil waitUntilDone: NO];
        
        // If the audio player is not nil, then play the sound effect.
        [self loadBeepSound];
        
        if (_audioPlayer) {
            [_audioPlayer play];
        }
        
        if ([[metadataObj type] isEqualToString: AVMetadataObjectTypeQRCode]) {
            NSLog(@"metadataObj type isEqualToString AVMetadataObjectTypeQRCode");
            NSLog(@"%@", [metadataObj stringValue]);
            
            NSString *sv = [metadataObj stringValue];
            NSArray *strArray = [sv componentsSeparatedByString: @"?"];
            NSLog(@"strArray: %@", strArray);
            
            if (strArray.count > 1) {
                if (!([strArray[1] rangeOfString: @"businessuser_id"].location == NSNotFound)) {
                    NSLog(@"strArray[1] rangeOfString is businessuser_id");
                    strArray = [strArray[1] componentsSeparatedByString: @"businessuser_id="];
                    NSLog(@"strArray: %@", strArray);
                    
                    businessUserId = strArray[1];
                    [self Facebookbtn: nil];
                } else {
                    [self performSelectorOnMainThread: @selector(showError:)
                                           withObject: @"本次掃描無效"
                                        waitUntilDone: NO];
                }
            } else {
                [self performSelectorOnMainThread: @selector(showError:)
                                       withObject: @"本次掃描無效"
                                    waitUntilDone: NO];
            }
        }
    }
}

- (void)showError:(NSString *)msg {
    NSLog(@"msg: %@", msg);
    [self showCustomErrorAlert: msg];
}

//Facebook
-(IBAction)Facebookbtn:(id)sender{
    NSLog(@"Facebookbtn Pressed");
    
    if ([FBSDKAccessToken currentAccessToken]) {
        NSLog(@"FBSDKAccessToken currentAccessToken Exists");
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
    // Try to login with permissions
    [self loginAndRequestPermissionsWithSuccessHandler:^{
        NSLog(@"loginAndRequestPermissionsWithSuccessHandler");
        
        NSString *fbtoken = [FBSDKAccessToken currentAccessToken].tokenString;
        NSString *fbid = [FBSDKAccessToken currentAccessToken].userID;
        
        NSLog(@"FB ID: %@", fbid);
        NSLog(@"FB Token: %@", fbtoken);
        
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
                 
                 if (emailAccount != nil) {
                     [paramDic setObject: emailAccount forKey: @"account"];
                 }
                 if (birthday != nil) {
                     [paramDic setObject: birthday forKey: @"birthday"];
                 }
                 if (gender != nil) {
                     [paramDic setObject: gender forKey: @"gender"];
                 }
                 if (name != nil) {
                     [paramDic setObject: name forKey: @"name"];
                 }
                 
                 NSLog(@"currentLocation: %@", currentLocation);
                 
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
                 
                 [self buisnessSubUserFastRegister: fbid jsonStr: jsonStr];
             } else {
                 NSLog(@"%@",error.localizedDescription);
             }
         }];
        
        //[self facebookLogin:fbid];
    }
                             declinedOrCanceledHandler:^{
                                 NSLog(@"declinedOrCanceledHandler");
                                 
                                 // If the user declined permissions tell them why we need permissions
                                 // and ask for permissions again if they want to grant permissions.
                                 
                                 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                 [defaults setObject: @"" forKey: @"businessUserId"];
                                 [defaults synchronize];
                                 
                                 [self alertDeclinedPublishActionsWithCompletion:^{
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
                [MBProgressHUD hideHUDForView: self.view  animated:YES];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                return;
            }
                        
            if (response != nil) {
                NSLog(@"response from buisnessSubUserFastRegister");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ScanRegisterViewController");
                    NSLog(@"buisnessSubUserFastRegister");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"buisnessSubUserFastRegister"
                                            fbId: fbId
                                         jsonStr: jsonStr];
                } else {
                    NSLog(@"Get Real Response");
                    
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"] isEqualToString: @"SYSTEM_OK"]) {
                        NSLog(@"SYSTEM_OK");
                        NSLog(@"dic: %@", dic);
                        
                        NSLog(@"新用戶");
                        
                        tokenStr = dic[@"data"][@"token"][@"token"];
                        idStr = [dic[@"data"][@"token"][@"user_id"] stringValue];
                        
                        tokenStr = dic[@"data"][@"token"][@"token"];
                        idStr = [dic[@"data"][@"token"][@"user_id"] stringValue];
                        
                        NSLog(@"tokenStr: %@", tokenStr);
                        NSLog(@"idStr: %@", idStr);
                        
                        [self saveDataAfterLogin];
                        [self setupPushNotification];
                        
                        FBFriendsFindingViewController *fbFindingVC = [[UIStoryboard storyboardWithName:@"FBFriendsFindingVC" bundle:nil]instantiateViewControllerWithIdentifier:@"FBFriendsFindingViewController"];
                        //[self.navigationController pushViewController: fbFindingVC animated:YES];
                        
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate.myNav pushViewController: fbFindingVC animated: YES];
                        
                        /*
                         ChooseHobbyViewController *chooseHobbyVC = [[UIStoryboard storyboardWithName: @"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"ChooseHobbyViewController"];
                         [self.navigationController pushViewController: chooseHobbyVC animated: YES];
                         */
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
                        
                        [self saveDataAfterLogin];
                        //[self toMyTabBarController];
                        //[self getProfile];
                        [self refreshToken];
                        [self setupPushNotification];
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
         
         NSLog(@"result: %@", result);
         
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

#pragma mark - Push Notification Setting
- (void)setupPushNotification
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *awsResponse;
        
        if ([wTools getUUID]) {
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

#pragma mark - Web Service - Refresh Token
- (void)refreshToken {
    NSLog(@"");
    NSLog(@"refreshToken");
    
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
                    NSLog(@"AlbumSettingViewController");
                    NSLog(@"refreshToken");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"refreshToken"
                                            fbId: @""
                                         jsonStr: @""];
                    
                } else {
                    NSLog(@"Get Real Response");
                    
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    NSLog(@"dic: %@", dic);
                    
                    if ([dic[@"result"] isEqualToString: @"SYSTEM_OK"]) {
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
        NSString *response = [boxAPI getprofile: [userPrefs objectForKey: @"id"] token: [userPrefs objectForKey: @"token"]];
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
                    NSLog(@"ScanRegisterViewController");
                    NSLog(@"getProfile");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getprofile"
                                            fbId: @""
                                         jsonStr: @""];
                } else {
                    NSLog(@"Get Real Response");
                    
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] boolValue]) {
                        NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
                        NSMutableDictionary *dataIc = [[NSMutableDictionary alloc] initWithDictionary: dic[@"data"] copyItems: YES];
                        //NSLog(@"dataIc: %@", dataIc);
                        
                        for (NSString *key in [dataIc allKeys]) {
                            //NSLog(@"key: %@", key);
                            
                            id objective = [dataIc objectForKey: key];
                            //NSLog(@"objective: %@", objective);
                            
                            if ([objective isKindOfClass: [NSNull class]]) {
                                [dataIc setObject: @"" forKey: key];
                            }
                        }
                        //NSLog(@"dataIc: %@", dataIc);
                        
                        [userPrefs setValue: dataIc forKey: @"profile"];
                        [userPrefs synchronize];
                        
                        [self getUrPoints];
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
                    NSLog(@"ScanRegisterViewController");
                    NSLog(@"getUrPoints");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"geturpoints"
                                            fbId: @""
                                         jsonStr: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    NSLog(@"dic: %@", dic);
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"dic result boolValue is 1");
                        NSInteger point = [dic[@"data"] integerValue];
                        //NSLog(@"point: %ld", (long)point);
                        
                        [userPrefs setObject: [NSNumber numberWithInteger: point] forKey: @"pPoint"];
                        [userPrefs synchronize];
                        
                        [self toMyTabBarController];
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗：%@",dic[@"message"]);
                        [self showCustomErrorAlert: dic[@"message"]];
                    } else {
                        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
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
}

#pragma mark - Saving Data to Device
- (void)saveDataAfterLogin
{
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    [userPrefs setObject: tokenStr forKey:@"token"];
    [userPrefs setObject: idStr forKey:@"id"];
    [userPrefs setObject: @"FB" forKey:@"FB"];
    [userPrefs synchronize];
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
        
        if (buttonIndex == 0) {
            [self startReading];
        }
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
                          fbId: (NSString *)fbId
                       jsonStr: (NSString *)jsonStr
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
            if ([protocolName isEqualToString: @"buisnessSubUserFastRegister"]) {
                [weakSelf buisnessSubUserFastRegister: fbId jsonStr: jsonStr];
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

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    NSLog(@"didUpdateLocations: %@", locations);
    currentLocation = [locations lastObject];
    NSLog(@"currentLocation: %@", currentLocation);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
