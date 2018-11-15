//
//  ScanCodeForAdvancedSettingViewController.m
//  wPinpinbox
//
//  Created by David on 2017/10/23.
//  Copyright © 2017年 Angus. All rights reserved.
//

#import "ScanCodeForAdvancedSettingViewController.h"
#import "AppDelegate.h"
#import "wTools.h"
#import <AVFoundation/AVFoundation.h>
#import "GlobalVars.h"

@interface ScanCodeForAdvancedSettingViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewPreview;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@end

@implementation ScanCodeForAdvancedSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self checkCamera];
}
- (void)checkCamera {
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (authStatus == AVAuthorizationStatusDenied ||
        authStatus == AVAuthorizationStatusRestricted ) {
        [self showNoAccessAlertAndCancel: @"camera"];
    } else if (authStatus == AVAuthorizationStatusNotDetermined ) {
        __block typeof(self) wself = self;
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    [wself startReading];
                } else {
                    [wself showNoAccessAlertAndCancel: @"camera"];
                }
            });
            
        }];
    } else {
        [self startReading];
    }
}
- (void)showNoAccessAlertAndCancel: (NSString *)option {
    NSString *titleStr;
    NSString *msgStr;
    
    if ([option isEqualToString: @"photo"]) {
        titleStr = @"沒有照片存取權";
        msgStr = @"請打開照片權限設定";
    } else if ([option isEqualToString: @"audio"]) {
        titleStr = @"沒有麥克風存取權";
        msgStr = @"請打開麥克風權限設定";
    } else if ([option isEqualToString: @"camera"]) {
        titleStr = @"沒有相機存取權";
        msgStr = @"請打開相機權限設定";
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: titleStr message: msgStr preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction *a = [UIAlertAction actionWithTitle: @"設定" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        
    }];
    __block typeof(self) wself = self;
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [wself dismissViewControllerAnimated:YES completion:nil];
        });
        
    }];
    [alert addAction:a];
    [alert addAction:cancel];
    
    [self presentViewController: alert animated: YES completion: nil];
}
- (IBAction)backBtnPress:(id)sender {
    //AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //[appDelegate.myNav popViewControllerAnimated: YES];
    [self dismissViewControllerAnimated:YES completion:nil];
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
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
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
        
        NSLog(@"metadataObj type: %@", [metadataObj type]);

        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
        } else if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeAztecCode]) {
        } else if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeFace]) {
        } else if ([[metadataObj type] isEqualToString:AVMetadataObjectTypePDF417Code]) {
        } else if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeDataMatrixCode]) {
        } else if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeInterleaved2of5Code]) {
        } else {
            NSLog(@"metadataObj type isEqualToString AVMetadataObjectTypeQRCode");
            NSLog(@"%@", [metadataObj stringValue]);
            
            NSString *sv = [metadataObj stringValue];
            if (sv && ![sv isEqualToString:@""] ) {
                __weak typeof(self) wself = self;
                NSArray *t1 = @[sv];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [wself dismissViewControllerAnimated:YES completion:^{
                        if (wself.finishedBlock)
                            wself.finishedBlock(t1);
                    }];
                });

                return;
            }
        }
        __weak typeof(self) wself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [wself dismissViewControllerAnimated:YES completion:^{
                if (wself.finishedBlock)
                    wself.finishedBlock(nil);
            }];
        });
    }
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
