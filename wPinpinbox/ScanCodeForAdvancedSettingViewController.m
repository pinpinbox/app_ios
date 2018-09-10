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
    [self startReading];
}

- (IBAction)backBtnPress:(id)sender {
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
        
        if ([[metadataObj type] isEqualToString: AVMetadataObjectTypeQRCode]) {
            NSLog(@"metadataObj type isEqualToString AVMetadataObjectTypeQRCode");
            NSLog(@"%@", [metadataObj stringValue]);
            
            NSString *sv = [metadataObj stringValue];
            NSArray *strArray = [sv componentsSeparatedByString: @"?"];
            NSLog(@"strArray: %@", strArray);
            
            if (!([strArray[1] rangeOfString: @"businessuser_id"].location == NSNotFound)) {
                NSLog(@"strArray[1] rangeOfString is businessuser_id");
                strArray = [strArray[1] componentsSeparatedByString: @"businessuser_id="];
                NSLog(@"strArray: %@", strArray);
                 
            }
        }
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
