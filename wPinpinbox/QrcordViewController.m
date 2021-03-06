//
//  QrcordViewController.m
//  wPinpinbox
//
//  Created by Angus on 2015/10/23.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "QrcordViewController.h"
#import "AppDelegate.h"
#import "wTools.h"
#import <AVFoundation/AVFoundation.h>
#import "boxAPI.h"

#import "CustomIOSAlertView.h"
#import "MBProgressHUD.h"
#import "UIColor+Extensions.h"

//#import "AlbumDetailViewController.h"
#import "GlobalVars.h"

#import "UIView+Toast.h"
#import <SafariServices/SafariServices.h>
#import "UIViewController+ErrorAlert.h"

#import "ContentCheckingViewController.h"

#import "YAlbumDetailContainerViewController.h"

@interface QrcordViewController () <AVCaptureMetadataOutputObjectsDelegate, UIGestureRecognizerDelegate>
{
    __weak IBOutlet UILabel *lab_left;
    __weak IBOutlet UILabel *lab_rig;
    
//    NSString *albumId;
    NSString *productn;
}
@property (strong, nonatomic) NSString *albumId;
@property (weak, nonatomic) IBOutlet UIView *viewPreview;
@property (weak, nonatomic) IBOutlet UIButton *bbitemStart;
@property (nonatomic) BOOL isReading;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBarViewHeight;

@end

@implementation QrcordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.delegate = self;
    
    _captureSession = nil;
    
    // Set the initial value of the flag to NO.
    _isReading = NO;
    lab_left.text=NSLocalizedString(@"SearchText-keySearch", @"");
    lab_rig.text=NSLocalizedString(@"SearchText-scanSearch", @"");
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"QrcordViewController viewWillAppear");    
    [wTools setStatusBarBackgroundColor: [UIColor clearColor]];
    
    //[self startReading];
    [self checkCamera];
    [_bbitemStart setTitle:@"開始" forState:UIControlStateNormal];
    
    for (UIView *view in self.tabBarController.view.subviews) {
        UIButton *btn = (UIButton *)[view viewWithTag: 104];
        btn.hidden = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"QrcordViewController viewDidAppear");
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.enabled = YES;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.captureSession.running)
        [self.captureSession stopRunning];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"QrcordViewController viewDidDisappear");
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.enabled = NO;
    [wTools setStatusBarBackgroundColor: [UIColor whiteColor]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                self.toolBarViewHeight.constant = kToolBarViewHeight;
                break;
            case 1334:
                printf("iPhone 6/6S/7/8");
                self.toolBarViewHeight.constant = kToolBarViewHeight;
                break;
            case 1920:
                printf("iPhone 6+/6S+/7+/8+");
                self.toolBarViewHeight.constant = kToolBarViewHeight;
                break;
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                self.toolBarViewHeight.constant = kToolBarViewHeight;
                break;
            case 2436:
                printf("iPhone X");
                self.toolBarViewHeight.constant = kToolBarViewHeightForX;
                break;
            default:
                printf("unknown");
                self.toolBarViewHeight.constant = kToolBarViewHeight;
                break;
        }
    }    
}
- (void)checkCamera {
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (authStatus == AVAuthorizationStatusDenied ||
        authStatus == AVAuthorizationStatusRestricted){ //||
        [self showNoAccessAlertAndCancel];
    } else if (authStatus == AVAuthorizationStatusNotDetermined ) {
        __block typeof(self) wself = self;
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    [wself performSelector:@selector(startReading) withObject:nil afterDelay:1.0 ];
                } else {
                    [wself showNoAccessAlertAndCancel];
                }
            });
        }];
    } else {
        [self startReading];
    }
}
- (void)showNoAccessAlertAndCancel {
    
    NSString *titleStr = @"沒有相機存取權";
    NSString *msgStr = @"請打開相機權限設定";
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: titleStr message: msgStr preferredStyle: UIAlertControllerStyleAlert];
    
    [alert addAction: [UIAlertAction actionWithTitle: @"設定" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        
    }]];
    __block typeof(self) wself = self;
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [wself back:nil];
        });
        
    }];
    [alert addAction:cancel];
    [self presentViewController: alert animated: YES completion: nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    //[self.navigationController popViewControllerAnimated:YES];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav popViewControllerAnimated: YES];
}

- (IBAction)menu:(id)sender {
    [wTools myMenu];
}

-(IBAction)SearchViewController:(id)sender{
//    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
//    for (UIViewController *temp in app.myNav.viewControllers) {
//        if ([temp isKindOfClass:[SearchViewController class]]) {
//            [app.myNav popToViewController:temp animated:NO];
//            return;
//        }
//    }
//    SearchViewController*mvc=[[SearchViewController alloc]initWithNibName:@"SearchViewController" bundle:nil];
//
//    [app.myNav pushViewController:mvc animated:NO];
}

- (IBAction)startStopReading:(id)sender{
    if (!_isReading) {
        if ([self startReading]) {
             [_bbitemStart setTitle:@"取消" forState:UIControlStateNormal];
            //[_bbitemStart performSelectorOnMainThread:@selector(setTitle:) withObject:@"取消" waitUntilDone:NO];
            //[_bbitemStart setTitle:@"Stop"];
        } else {
            [self stopReading];
            _bbitemStart.selected=NO;
            [_bbitemStart setTitle:@"開始" forState:UIControlStateNormal];
            //[_bbitemStart setTitle:@"Start!"];
        }
        _isReading = !_isReading;
    }
}

#pragma mark - Private method implementation

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
-(void)stopReading{
    // Stop video capture and make the capture session object nil.
    [_captureSession stopRunning];
    _captureSession = nil;
    
    // Remove the video preview layer from the viewPreview view's layer.
    [_videoPreviewLayer removeFromSuperlayer];
}

-(void)loadBeepSound
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
-(void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
      fromConnection:(AVCaptureConnection *)connection{
    
    NSLog(@"didOutputMetadataObjects");
    
    // Check if the metadataObjects array is not nil and it contains at least one object.
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        NSLog(@"metadataObjects != nil && [metadataObjects count] > 0");
        
        // Get the metadata object.
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        NSLog(@"metadataObj stringValue: %@", [metadataObj stringValue]);
        
        // If the found metadata is equal to the QR code metadata then update the status label's text,
        // stop reading and change the bar button item's title and the flag's value.
        // Everything is done on the main thread.
        //[_lblStatus performSelectorOnMainThread:@selector(setText:) withObject:[metadataObj stringValue] waitUntilDone:NO];
        
        [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:YES];
      
        _isReading = NO;
        
        // If the audio player is not nil, then play the sound effect.
        [self loadBeepSound];
        
        if (_audioPlayer) {
            [_audioPlayer play];
        }
        
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            NSLog(@"metadataObj type isEqualToString AVMetadataObjectTypeQRCode");
            NSLog(@"%@", [metadataObj stringValue]);
            
            NSString *sv = [metadataObj stringValue];
            NSArray *strArray = [sv componentsSeparatedByString:@"?"];
            NSLog(@"strArray: %@", strArray);
            
            if (strArray.count > 1) {
                NSLog(@"strArray.count > 1");
                
                if (!([strArray[1] rangeOfString: @"album_id"].location == NSNotFound)) {
                    NSLog(@"strArray[1] rangeOfString is album_id");
                    strArray = [strArray[1] componentsSeparatedByString:@"album_id="];
                    NSLog(@"strArray: %@", strArray);
                    
                    strArray = [strArray[1] componentsSeparatedByString:@"&"];
                    NSLog(@"strArray: %@", strArray);
                    
                    sv = strArray[0];
                    
                    self.albumId = sv;
                    
                    NSLog(@"album_id: %@", sv);
                    
                    //[self ToRetrievealbumpViewControlleralbumid:sv];
                    [self performSelectorOnMainThread: @selector(ToRetrievealbumpViewControlleralbumid:) withObject: self.albumId waitUntilDone: NO];
                    
                } else if (!([strArray[1] rangeOfString: @"type"].location == NSNotFound)) {
                    
                    NSLog(@"strArray[1] rangeOfString is type");
                    NSLog(@"strArray[1]: %@", strArray[1]);
                    
                    strArray = [strArray[1] componentsSeparatedByString: @"&"];
                    
                    NSLog(@"strArray: %@", strArray);
                    
                    if ([strArray[0] isEqualToString: @"type=album"]) {
                        NSLog(@"type = album");
                        strArray = [strArray[1] componentsSeparatedByString: @"type_id="];
                        
                        NSLog(@"strArray: %@", strArray);
                        sv = strArray[1];
                        
                        NSLog(@"sv: %@", sv);
                        self.albumId = sv;
                        
                        NSLog(@"type_id: %@", sv);
                        
                        // If we call the method below directly, then [wTools showMBProgressHD] will not show
                        // [self insertCooperation];
                        
                        // We should call the method below, so [wTools showMBProgressHD] will show up
                        [self performSelectorOnMainThread: @selector(insertCooperation) withObject: nil waitUntilDone: NO];
                        
//                        [self showCustomErrorAlert: @"共用功能尚未完成"];
                    }
                } else {
                    [self performSelectorOnMainThread: @selector(showError:)
                                           withObject: @"作品不存在"
                                        waitUntilDone: NO];
                }
            } else {
                if ([strArray[0] containsString: @"http"]) {
                    NSLog(@"contains http");
                    NSString *urlString = strArray[0];
                    
                    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: [NSURL URLWithString: urlString] entersReaderIfAvailable: NO];
                    safariVC.preferredBarTintColor = [UIColor whiteColor];
                    [self presentViewController: safariVC animated: YES completion: nil];
                } else {
                    NSLog(@"strArray.count is not bigger than 1");
                    [self performSelectorOnMainThread: @selector(showError:)
                                           withObject: @"作品不存在"
                                        waitUntilDone: NO];
                }
            }
            
            //NSLog(@"QR-%@", sv);
            //[self ToRetrievealbumpViewControlleralbumid:sv];
            return;
        }
        
        NSLog(@"%@",[metadataObj stringValue]);
        productn = [metadataObj stringValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self ToRetrievealbumpViewControllerproductn];
        });
    }
}

- (void)showError:(NSString *)msg {
    NSLog(@"msg: %@", msg);
    [self showCustomErrorAlert: msg];
}

- (void)ToRetrievealbumpViewControlleralbumid:(NSString *)albumId {
    NSLog(@"ToRetrievealbumpViewControlleralbumid");
    
    [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *response = [boxAPI retrievealbump: albumId
                                                uid: [wTools getUserID]
                                              token: [wTools getUserToken]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView: self.view animated: YES];
            
            if (response != nil) {
                //NSLog(@"%@",respone);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"QrcordViewController");
                    NSLog(@"ToRetrievealbumpViewControlleralbumid");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"retrievealbump"
                                         albumId: albumId];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"] intValue] == 1 && [wTools objectExists:dic[@"data"]]) {
                        
                        YAlbumDetailContainerViewController *aDVC = [YAlbumDetailContainerViewController albumDetailVCWithAlbumID:albumId albumInfo:dic[@"data"]];

                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate.myNav pushViewController: aDVC animated: YES];
                        [self stopReading];
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

-(void)ToRetrievealbumpViewControllerproductn {
    [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    __block NSString *pn  = productn;
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI retrievealbumpbypn: pn
                                                   uid: [wTools getUserID]
                                                 token: [wTools getUserToken]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView: wself.view animated: YES];
            if (response != nil) {
                NSLog(@"%@", response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"QrcordViewController");
                    NSLog(@"ToRetrievealbumpViewControllerproductn");
                    
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"retrievealbumpbypn"
                                         albumId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        
                        [wself processAlbumID:[dic[@"data"][@"albumid"] stringValue]];
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗：%@",dic[@"message"]);
                        [wself showCustomErrorAlert: dic[@"message"]];
                    } else {
                        [wself showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            } else {
                [MBProgressHUD hideHUDForView: wself.view animated: YES];
            }
        });
    });
}
- (void) processAlbumID:(NSString *)aid {
    self.albumId = aid;//[NSString stringWithString:aid];
    
    [self ToRetrievealbumpViewControlleralbumid: self.albumId];
}
#pragma mark - Protocol Method Section

- (void)insertCooperation {
    NSLog(@"insertCooperation");
    
    [wTools ShowMBProgressHUD];
    NSLog(@"wTools ShowMBProgressHUD");
    __block typeof(self) wself = self;
    NSMutableDictionary *data = [NSMutableDictionary new];
    
    [data setObject: [wTools getUserID] forKey: @"user_id"];
    [data setObject: @"album" forKey: @"type"];
    [data setObject: self.albumId forKey: @"type_id"];
    
    NSLog(@"albumId: %@", self.albumId);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI addcooperation: [wTools getUserID]
                                              token: [wTools getUserToken]
                                               data: data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            NSLog(@"wTools HideMBProgressHUD");
            
            if (response != nil) {
                NSLog(@"response from addcooperation");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"QrcordViewController");
                    NSLog(@"insertCooperation");
                    
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"addcooperation"
                                         albumId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"result is 1");
                        ContentCheckingViewController *contentCheckingVC = [[UIStoryboard storyboardWithName: @"ContentCheckingVC" bundle: nil] instantiateViewControllerWithIdentifier: @"ContentCheckingViewController"];
                        contentCheckingVC.albumId = wself.albumId;
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate.myNav pushViewController: contentCheckingVC animated: YES];
//                        [wself getcalbumlist];
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗：%@", dic[@"message"]);
                        //[self.navigationController popViewControllerAnimated: YES];
                        
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate.myNav popViewControllerAnimated: YES];
                        
                        [wself showCustomErrorAlert: dic[@"message"]];
                    } else {
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate.myNav popViewControllerAnimated: YES];
                        
                        [wself showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}

- (void)getcalbumlist {
    NSLog(@"getcalbumlist");
    
    [wTools ShowMBProgressHUD];
    NSLog(@"wTools ShowMBProgressHUD");
    __block NSString *aid = self.albumId;
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI getcalbumlist: [wTools getUserID]
                                             token: [wTools getUserToken]
                                              rank: @"cooperation"
                                             limit: @"0,1000"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            NSLog(@"wTools HideMBProgressHUD");
            
            if (response != nil) {
                NSLog(@"response from getcalbumlist");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"QrcordViewController");
                    NSLog(@"getcalbumlist");
                    
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getcalbumlist"
                                         albumId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"result is: %d", [dic[@"result"] boolValue]);
                        
                        for (NSDictionary *d in dic[@"data"]) {
                            NSLog(@"d: %@", d);
                            
                            NSString *albumIdStr = [d[@"album"][@"album_id"] stringValue];
                            
                            if ([albumIdStr isEqualToString: aid]) {
                                if ([d[@"album"][@"zipped"] boolValue]) {
                                    NSLog(@"zipped boolValue is: %d", [d[@"album"][@"zipped"] boolValue]);
                                    ContentCheckingViewController *contentCheckingVC = [[UIStoryboard storyboardWithName: @"ContentCheckingVC" bundle: nil] instantiateViewControllerWithIdentifier: @"ContentCheckingViewController"];
                                    contentCheckingVC.albumId = albumIdStr;                                    
                                    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                                    [appDelegate.myNav pushViewController: contentCheckingVC animated: YES];
                                } else {
                                    NSLog(@"zipped boolValue is: %d", [d[@"album"][@"zipped"] boolValue]);
                                    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                                    [appDelegate.myNav popViewControllerAnimated: YES];
                                    [wself showCustomErrorAlert: @"作品尚未有儲存的動作"];
                                }
                            }
                        }
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗：%@",dic[@"message"]);
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate.myNav popViewControllerAnimated: YES];
                        [wself showCustomErrorAlert: dic[@"message"]];
                    } else {
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate.myNav popViewControllerAnimated: YES];
                        [wself showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}

#pragma mark - Custom Error Alert Method
- (void)showCustomErrorAlert: (NSString *)msg
{
    [wTools setStatusBarBackgroundColor:[UIColor clearColor]];
    CustomIOSAlertView *errorAlertView = [UIViewController getCustomErrorAlert:msg];
    __weak CustomIOSAlertView *weakErrorAlertView = errorAlertView;
    [errorAlertView setOnButtonTouchUpInside:^(CustomIOSAlertView *customAlertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[customAlertView tag]);
        [wTools setStatusBarBackgroundColor:[UIColor whiteColor]];
        [weakErrorAlertView close];
        
        NSLog(@"buttonIndex: %d", buttonIndex);
        
        if (buttonIndex == 0) {
            [self startReading];
        }
    }];
    
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
                       albumId: (NSString *)albumId
{
    CustomIOSAlertView *alertTimeOutView = [[CustomIOSAlertView alloc] init];
    
    [alertTimeOutView setContentViewWithMsg:msg contentBackgroundColor:[UIColor darkMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
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
        
        if (buttonIndex == 0) {
            [weakAlertTimeOutView close];
            [wTools setStatusBarBackgroundColor:[UIColor whiteColor]];
        } else {
            [weakAlertTimeOutView close];
            [wTools setStatusBarBackgroundColor:[UIColor whiteColor]];
            if ([protocolName isEqualToString: @"retrievealbump"]) {
                [weakSelf ToRetrievealbumpViewControlleralbumid: albumId];
            } else if ([protocolName isEqualToString: @"retrievealbumpbypn"]) {
                [weakSelf ToRetrievealbumpViewControllerproductn];
            } else if ([protocolName isEqualToString: @"addcooperation"]) {
                [weakSelf insertCooperation];
            } else if ([protocolName isEqualToString: @"getcalbumlist"]) {
                [weakSelf getcalbumlist];
            }
        }
    }];
    [alertTimeOutView setUseMotionEffects: YES];
    [alertTimeOutView show];
}

@end
