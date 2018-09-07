//
//  FastViewController.m
//  wPinpinbox
//
//  Created by Angus on 2015/10/29.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "FastViewController.h"
#import "O_drag.h"
#import "PhotosViewController.h"
#import <AdobeCreativeSDKFoundation/AdobeCreativeSDKFoundation.h>
#import "wTools.h"
#import "boxAPI.h"
#import "AsyncImageView.h"
#import "BookdetViewController.h"
#import "CooperationViewController.h"

#import "TaobanViewController.h"
#import "TemplateViewController.h"

#import "ReorderViewController.h"
#import "PreviewPageSetupViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "ChooseVideoViewController.h"
#import "TYMProgressBarView.h"

#import "CustomIOSAlertView.h"
#import "ProgressView.h"

#import "AppDelegate.h"

#import <Photos/Photos.h>
#import "BookdetViewController.h"
#import "MKDropdownMenu.h"
#import "UIImage+Extras.h"
#import "MBProgressHUD.h"
#import "UIView+Toast.h"

#import "UIColor+Extensions.h"
#import "UIViewController+ErrorAlert.h"

#define kWidthForUpload 720
#define kHeightForUpload 960

//#define kCellHeightForReorder 150
//#define kViewHeightForReorder 504
#define kCellHeightForReorder 150
#define kViewHeightForReorder 568

//#define kCellHeightForPreview 170
//#define kViewHeightForPreview 504
#define kCellHeightForPreview 170
#define kViewHeightForPreview 568

@interface FastViewController () <UICollectionViewDataSource, UICollectionViewDelegate, PhotosViewDelegate,AdobeUXImageEditorViewControllerDelegate, UIGestureRecognizerDelegate, AVAudioRecorderDelegate, ChooseVideoViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, MKDropdownMenuDelegate, MKDropdownMenuDataSource, ReorderViewControllerDelegate, PreviewPageSetupViewControllerDelegate>
{
    __weak IBOutlet UICollectionView *mycollection;
    __weak IBOutlet UIButton *adobeEidt;
    __weak IBOutlet UIButton *recordPausePlayBtn;
    __weak IBOutlet UIButton *conbtn;
    
    __weak IBOutlet UIView *textBgView;
    __weak IBOutlet UIButton *addTextBtn;
    __weak IBOutlet UIButton *deleteTextBtn;
    
    __weak IBOutlet UIView *audioBgView;
    __weak IBOutlet UIButton *deleteAudioBtn;
    __weak IBOutlet UIButton *deleteImageBtn;
    
    __weak IBOutlet UIButton *choiceBtn;
    __weak IBOutlet UILabel *choiceLabel;
    
    NSMutableArray *ImageDataArr;
    NSInteger selectItem;
    
    UIImageView *Oimageview;
    O_drag *oview;
    
    UIImage *selectimage;
    
    NSInteger *nextItem;
    NSString *identity;
    
    BOOL isEditing;
    
    AVAudioRecorder *recorder;
    //AVAudioPlayer *player;
    AVPlayer *avPlayer;
    
    BOOL isRecorded;
    NSData *audioData;
    NSURL *outputFileURL;
    
    NSString *audio_url;
    
    float contentSize;
    NSMutableData *downloadData;
    TYMProgressBarView *loadView;
    NSString *responseStr;
    
    CustomIOSAlertView *alertView;
    NSString *videoMode;
    
    //NSURLSessionTask *task;
    
    UITextView *textV;
    NSString *textForDescription;
    BOOL addingText;
    
    BOOL photoGranted;
    BOOL audioGranted;
    
    // For Observing NSOperationQueue
    NSString *responseImageStr;
    
    MBProgressHUD *hud;
    
    ReorderViewController *reorderVC;
    PreviewPageSetupViewController *previewPageVC;
    
    NSString *modalVC;
}

@property (weak, nonatomic) IBOutlet UIView *ShowView;
@property (weak, nonatomic) IBOutlet UICollectionView *dataCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *titlelabel;
@property (weak, nonatomic) IBOutlet UIView *choiceOptionView;
//@property (weak, nonatomic) ProgressView *progressView;

@property (weak, nonatomic) IBOutlet MKDropdownMenu *dropMenu;
@property (strong, nonatomic) NSArray <NSString *> *types;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@property (strong, nonatomic) NSOperationQueue *queue;

@property (strong, nonatomic) UIViewController *dimVC;
@property (strong, nonatomic) UIViewController *modal;

@end

@implementation FastViewController

-(void)reloaddatat:(NSMutableArray *)data{
    NSLog(@"reloaddatat");
    ImageDataArr=[data mutableCopy];
    NSLog(@"ImageDataArr: %@", ImageDataArr);
}

-(void)reloadItem:(NSInteger )item{
    NSLog(@"reloadItem");
    selectItem=item;
    NSLog(@"selectItem: %ld", (long)selectItem);
}

#pragma mark -
#pragma mark View Related Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"FastViewController");
    NSLog(@"viewDidLoad");
    
    // Set the titleView text color for white
    //self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};

    //@{NSFontAttributeName: [UIFont systemFontOfSize:14 weight:UIFontWeightLight], NSForegroundColorAttributeName: [UIColor whiteColor]}

    // Set the title text & color
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18 weight:UIFontWeightLight], NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    [self dropdownMenuSetUp];
    
    [wTools HideMBProgressHUD];

            
    if (self.shareCollection) {
        [self.nextBtn setTitle: @"完成" forState: UIControlStateNormal];
        [self.nextBtn addTarget: self action: @selector(back:) forControlEvents: UIControlEventTouchUpInside];
    } else {
        [self.nextBtn setTitle: @"下一步" forState: UIControlStateNormal];
        [self.nextBtn addTarget: self action: @selector(save:) forControlEvents: UIControlEventTouchUpInside];
    }
    
    
    isEditing = NO;
    NSLog(@"isEditing: %d", isEditing);
    _choiceOptionView.hidden = NO;
    
    isRecorded = NO;
    
    [[_ShowView layer] setMasksToBounds:YES];
    
    if (_imagedata==nil) {
        ImageDataArr=[NSMutableArray new];
        
        audioBgView.hidden = YES;
        deleteAudioBtn.hidden = YES;
        
        textBgView.hidden = YES;
        deleteTextBtn.hidden = YES;
    }

    // Choice Section
    if ([_choice isEqualToString: @"Template"]) {
        NSLog(@"Choice is Template");
        
        [choiceBtn setImage: [UIImage imageNamed: @"icon_select_template_bluegreen_200x200"] forState: UIControlStateNormal];
        choiceLabel.text = @"選 擇 樣 板";
        _titlelabel.text = @"版 型 建 立";
        
    } else if ([_choice isEqualToString: @"Fast"]) {
        NSLog(@"Choice is Fast");
        
        [choiceBtn setImage: [UIImage imageNamed: @"icon_select_photo_bluegreen_120x120"] forState: UIControlStateNormal];
        choiceLabel.text = @"選 擇 相 片";
        //_titlelabel.text = @"快 速 建 立";
        _titlelabel.text = @"建 立 作 品";
    }
    
    //  NSString* const CreativeSDKClientId = @"5d7ab289e4a74aa8bba84475395f552c";
    //  NSString* const CreativeSDKClientSecret = @"a5b4e46a-96df-4cfa-a18e-5c99c4e8cf91";
    NSString* const CreativeSDKClientId = @"9acbf5b342a8419584a67069e305fa39";
    NSString* const CreativeSDKClientSecret = @"b4d92522-49ac-4a69-9ffe-eac1f494c6fc";
    [[AdobeUXAuthManager sharedManager] setAuthenticationParametersWithClientID:CreativeSDKClientId clientSecret:CreativeSDKClientSecret enableSignUp:true];
    
    //The authManager caches our login, so check on startup
    BOOL loggedIn = [AdobeUXAuthManager sharedManager].authenticated;
    
    if(loggedIn) {
        [[AdobeUXAuthManager sharedManager] logout:nil onError:nil];
        AdobeAuthUserProfile *up = [AdobeUXAuthManager sharedManager].userProfile;
        NSLog(@"User Profile: %@", up);
    }
    
    [self reload:nil];
    [self audioSetUp];
    [self photoSetup];
    
    // Do any additional setup after loading the view from its nib.
    
    /*
    // attach long press gesture to collectionView
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget: self action: @selector(handleLongPress:)];
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    [mycollection addGestureRecognizer: lpgr];
     */
    
    self.dimVC = [[UIViewController alloc] init];
    self.dimVC.view.frame = [[UIScreen mainScreen] bounds];
    self.dimVC.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent: 0.6f];
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleTapGesture:)];
    //[self.ShowView addGestureRecognizer: tapGR];
    [self.dimVC.view addGestureRecognizer: tapGR];
    
    modalVC = @"";
    
    NSLog(@"self.dimVC.view: %@", NSStringFromCGRect(self.dimVC.view.frame));
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
    
    for (id controller in self.navigationController.viewControllers) {
        NSLog(@"controller: %@", controller);
    }
    
    /*
    // Check from which viewController pushes
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL fromPageCollection = [[defaults objectForKey: @"fromPageCollection"] boolValue];
    NSLog(@"fromPageCollection: %d", fromPageCollection);
    
    if (fromPageCollection) {
        self.navigationController.navigationBarHidden = YES;
    } else {
        self.navigationController.navigationBarHidden = NO;
    }
    */
    
    //self.progressView.hidden = NO;
    
    NSLog(@"isEditing: %d", isEditing);
    
    // Choice Section
    if ([_choice isEqualToString: @"Template"]) {
        NSLog(@"Choice is Template");
        
        [choiceBtn setImage: [UIImage imageNamed: @"icon_select_template_bluegreen_200x200"] forState: UIControlStateNormal];
        choiceLabel.text = @"選 擇 樣 板";
        _titlelabel.text = @"版 型 建 立";
        
    } else if ([_choice isEqualToString: @"Fast"]) {
        NSLog(@"Choice is Fast");
        
        [choiceBtn setImage: [UIImage imageNamed: @"icon_select_photo_bluegreen_120x120"] forState: UIControlStateNormal];
        choiceLabel.text = @"選 擇 相 片";
        //_titlelabel.text = @"快 速 建 立";
        _titlelabel.text = @"建 立 作 品";
    }
    
    CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
    //判斷3.5吋或4吋螢幕以載入不同storyboard
    if (iOSDeviceScreenSize.height == 480)
    {
        CGPoint con=_ShowView.center;
        float s=0.8f;
        _ShowView.frame=CGRectMake(_ShowView.frame.origin.x, _ShowView.frame.origin.y, 258*s, 387*s);
        _ShowView.center=CGPointMake(con.x, _ShowView.center.y-5);
    }
    
    if (_booktype!=1000) {
        //_titlelabel.text=NSLocalizedString(@"CreateAlbumText-quickBuild", @"");
                
        //conbtn.hidden=NO;
    }else{
        //_titlelabel.text=NSLocalizedString(@"CreateAlbumText-createAlbum", @"");
        //conbtn.hidden=YES;
    }
    
    [self myshowimage];    
    [_dataCollectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    
    NSLog(@"viewWillDisappear");
    
    //self.navigationController.navigationBarHidden = NO;

    if ([self.navigationController.viewControllers indexOfObject: self] == NSNotFound) {
        [self back: nil];
    }
    
    [self.dropMenu closeAllComponentsAnimated: YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)handleTapGesture: (UITapGestureRecognizer *)gestureRecognizer
{
    NSLog(@"FastViewController");
    NSLog(@"handleTapGesture");

    //[self showReorderVC];
    //[self dismissModalView];
    
    if ([modalVC isEqualToString: @"ReorderVC"]) {
        [reorderVC callBackButtonFunction];
    } else if ([modalVC isEqualToString: @"PreviewPageSetupVC"]) {
        [previewPageVC callBackButtonFunction];
    }
}

#pragma mark -

- (void)dropdownMenuSetUp
{
    NSLog(@"dropdownMenuSetUp");
    
    //[view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"a.png"]]];
    self.dropMenu.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"icon_creation_options_white"]];
    
    self.types = @[@"作 品 排 序", @"選擇預覽頁"];
    
    self.dropMenu.frame = CGRectMake(0, 0, 45, 33);
    self.dropMenu.dataSource = self;
    self.dropMenu.delegate = self;
    
    // Make background light instead of dark when presenting the dropdown
    self.dropMenu.backgroundDimmingOpacity = 0;
    
    // Set custom disclosure indicator image
    UIImage *indicator = [UIImage imageNamed:@"Empty.png"];
    self.dropMenu.disclosureIndicatorImage = indicator;
    
    // Add an arrow between the menu header and the dropdown
    UIImageView *spacer = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    
    // Prevent the arrow image from stretching
    spacer.contentMode = UIViewContentModeCenter;
    
    self.dropMenu.spacerView = spacer;
    
    // Offset the arrow to align with the disclosure indicator
    self.dropMenu.spacerViewOffset = UIOffsetMake(self.dropMenu.bounds.size.width/2 - indicator.size.width/2 - 8, 1);
    
    // Hide top row separator to blend with the arrow
    self.dropMenu.dropdownShowsTopRowSeparator = NO;
    
    self.dropMenu.dropdownBouncesScroll = NO;
    
    self.dropMenu.rowSeparatorColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    self.dropMenu.rowTextAlignment = NSTextAlignmentCenter;
    
    // Round all corners (by default only bottom corners are rounded)
    self.dropMenu.dropdownRoundedCorners = UIRectCornerAllCorners;
    
    // Let the dropdown take the whole width of the screen with 105pt insets
    // Make it wider
    self.dropMenu.useFullScreenWidth = YES;
    self.dropMenu.fullScreenInsetLeft = 95;
    self.dropMenu.fullScreenInsetRight = 95;
    
    [[self.dropMenu layer] setMasksToBounds: YES];
    [[self.dropMenu layer] setCornerRadius: self.dropMenu.bounds.size.height / 2];
}

#pragma mark - Text Description Methods
- (IBAction)addText:(id)sender
{
    [self showTextEditing];
}

- (IBAction)deleteText:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"" message: @"確定刪除本頁敘述？" preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction *okBtn = [UIAlertAction actionWithTitle: @"確定" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self callUpdatePhotoOfDiy: @""];
    }];
    
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleDefault handler: nil];
    [alert addAction: cancelBtn];
    [alert addAction: okBtn];
    [self presentViewController: alert animated: YES completion: nil];
}

#pragma mark - Custom AlertView For Text
- (void)showTextEditing
{
    NSLog(@"showTextEditing");
    
    UIImage *imgForText1 = [UIImage imageNamed: @"icon_cancel_pink500_120x120"];
    UIImage *imgForText2 = [UIImage imageNamed: @"icon_comfirm_teal500_120x120"];
    
    CustomIOSAlertView *alertViewForText = [[CustomIOSAlertView alloc] init];
    [alertViewForText setContainerView: [self createViewForText]];
    alertViewForText.useImages = YES;
    [alertViewForText setButtonImages: [NSMutableArray arrayWithObjects: imgForText1, imgForText2, nil]];
    
    [alertViewForText setOnButtonTouchUpInside:^(CustomIOSAlertView *alertViewForText, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertViewForText tag]);
        [alertViewForText close];
        
        if (buttonIndex == 0) {
            NSLog(@"0");
        } else if (buttonIndex == 1) {
            NSLog(@"1");
            [self setUpTextAdding];
        }
    }];
    
    [alertViewForText setUseMotionEffects: true];
    [alertViewForText show];
}

- (UIView *)createViewForText
{
    NSLog(@"createViewForText");
    
    // Parent View
    UIView *buttonView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 250, 220)];
    UIColor *btnVColor = buttonView.backgroundColor;
    
    textV = [[UITextView alloc] init];
    textV.font = [UIFont fontWithName: @"TrebuchetMS" size: 15.0f];
    textV.textColor = [UIColor whiteColor];
    textV.backgroundColor = btnVColor;
    textV.frame = CGRectMake(5, 10, buttonView.bounds.size.width - 10, buttonView.bounds.size.height - 40);
    textV.editable = YES;
    textV.returnKeyType = UIReturnKeyDone;
    
    NSLog(@"textForDescription: %@", textForDescription);
    
    if ([textForDescription isEqualToString: @""]) {
        textV.text = @"給這頁作品加點介紹吧！";
    } else {
        textV.text = textForDescription;
    }
    
    textV.textColor = [UIColor lightGrayColor];
    textV.delegate = self;
    
    [buttonView addSubview: textV];
    
    return buttonView;
}

- (void)setUpTextAdding
{
    NSLog(@"setUpTextAdding");
    
    NSMutableDictionary *settingsDic = [NSMutableDictionary new];
    [settingsDic setObject: textV.text forKey: @"description"];
    NSLog(@"textV.text: %@", textV.text);
    
    if ([textV.text isEqualToString: @"給這頁作品加點介紹吧！"]) {
        textForDescription = @"";
    } else {
        textForDescription = textV.text;
    }
    
    [self callUpdatePhotoOfDiy: textForDescription];
}

#pragma mark -

- (void)callUpdatePhotoOfDiy: (NSString *)jsonStr {
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = @"";
        NSString *pid = [ImageDataArr [selectItem][@"photo_id"] stringValue];
        response = [boxAPI updatephotoofdiy: [wTools getUserID] token: [wTools getUserToken] album_id: _albumid photo_id: pid image: nil setting: jsonStr];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"UpdatePhotoOfDiy: %@", response);
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                if ([dic[@"result"] intValue] == 1) {
                    ImageDataArr = [NSMutableArray arrayWithArray:dic[@"data"][@"photo"]];
                    textForDescription = ImageDataArr[selectItem][@"description"];
                    
                    if ([textForDescription isEqualToString: @""]) {
                        textBgView.hidden = YES;
                        deleteTextBtn.hidden = YES;
                    } else if ([textForDescription isEqualToString: @"給這頁作品加點介紹吧！"]) {
                        textBgView.hidden = YES;
                        deleteTextBtn.hidden = YES;
                    } else {
                        textBgView.hidden = NO;
                        deleteTextBtn.hidden = NO;
                    }
                    
                } else if ([dic[@"result"] boolValue] == 0) {
                    NSLog(@"callUpdatePhotoOfDiy return result is 0");
                    [self showPermission];
                } else {
                    [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                }
            }
        });
    });
}

#pragma mark - TextView Delegate Methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    //textV.text = @"";
    textV.text = textForDescription;
    textV.textColor = [UIColor blackColor];
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textV.text.length == 0) {
        textV.textColor = [UIColor lightGrayColor];
        textV.text = @"給這頁作品加點介紹吧！";
        [textV resignFirstResponder];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString: @"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark Audio Related Methods
- (void)audioSetUp
{
    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects: [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], @"MyAudioMemo.m4a", nil];
    outputFileURL = [NSURL fileURLWithPathComponents: pathComponents];
    
    NSLog(@"outputFileURL: %@", outputFileURL);
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue: [NSNumber numberWithInt: kAudioFormatMPEG4AAC] forKey: AVFormatIDKey];
    [recordSetting setValue: [NSNumber numberWithFloat: 44100.0] forKey: AVSampleRateKey];
    [recordSetting setValue: [NSNumber numberWithInt: 2] forKey: AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL: outputFileURL
                                           settings: recordSetting
                                              error: NULL];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
}

- (IBAction)recordPausePlayTapped:(id)sender
{
    [self checkAudio];
    
    if (audioGranted) {
        
        if (!isRecorded) {
            NSLog(@"is not recorded yet");
            
            if (!recorder.recording) {
                AVAudioSession *session = [AVAudioSession sharedInstance];
                [session setActive: YES error: nil];
                
                // Start recording
                [recorder record];
                [recordPausePlayBtn setImage: [UIImage imageNamed: @"icon_stop_recording_pink_120x120"] forState: UIControlStateNormal];
                
            } else {
                AVAudioSession *session = [AVAudioSession sharedInstance];
                [session setActive: NO error: nil];
                
                // Stop recording
                NSLog(@"Stop Recording");
                [recorder stop];                                
            }
            
        } else if (isRecorded) {
            
            NSLog(@"is recorded already");
            [self playTapped];
        }
    } else {
        [self showNoAccessAlertAndCancel: @"audio"];
    }
}

- (void)playTapped
{
    NSLog(@"playTapped");
    
    if (![audio_url isKindOfClass: [NSNull class]]) {
        if (![audio_url isEqualToString: @""]) {
            NSLog(@"audio_url is not empty");
            NSLog(@"play stream audio");
            
            NSURL *url = [NSURL URLWithString: audio_url];
            
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL: url];
            [[NSNotificationCenter defaultCenter] addObserver: self
                                                     selector: @selector(itemDidFinishPlaying:)
                                                         name: AVPlayerItemDidPlayToEndTimeNotification
                                                       object: playerItem];
            avPlayer = [[AVPlayer alloc] initWithPlayerItem: playerItem];
            [avPlayer play];
        }
    }
}

- (void)itemDidFinishPlaying: (NSNotification *)notification
{
    NSLog(@"itemDidFinishPlaying");
}

- (IBAction)deleteAudio:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"" message: @"確定刪除本頁錄音檔" preferredStyle: UIAlertControllerStyleAlert];
    //UIAlertAction *okBtn = [UIAlertAction actionWithTitle: @"確定" style: UIAlertActionStyleDefault handler: nil];
    UIAlertAction *okBtn = [UIAlertAction actionWithTitle: @"確定" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self deleteAudioOfDiy];
        
    }];
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleDefault handler: nil];
    [alert addAction: cancelBtn];
    [alert addAction: okBtn];
    [self presentViewController: alert animated: YES completion: nil];
    
    isRecorded = NO;
}

#pragma mark -
#pragma mark AVAudioRecorder Delegate Methods
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSLog(@"did finish recording");
    
    [self updateAudio];
}

#pragma mark -
#pragma API Methods

- (void)updateAudio
{
    NSLog(@"updateAudio");
    [wTools ShowMBProgressHUD];
    
    NSLog(@"selectItem: %ld", (long)selectItem);
    
    NSString *pid = [ImageDataArr [selectItem][@"photo_id"] stringValue];
    NSLog(@"pid: %@", pid);
    
    audioData = [[NSData alloc] initWithContentsOfURL: outputFileURL];
    //NSLog(@"audioData: %@", audioData);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI updateAudioOfDiy: [wTools getUserID] token: [wTools getUserToken] album_id: _albumid photo_id: pid file: audioData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"%@", response);
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                if ([dic[@"result"] intValue] == 1) {
                    NSLog(@"updateAudio Success");
                    NSLog(@"%@", dic[@"data"]);
                    
                    // Update audio_url for just finish recording
                    audio_url = dic[@"data"][@"photo"][selectItem][@"audio_url"];
                    NSLog(@"audio_url: %@", audio_url);
                    
                    // Update ImageDataArr
                    ImageDataArr=[NSMutableArray arrayWithArray:dic[@"data"][@"photo"]];
                    
                    //[mycollection reloadData];
                    [_dataCollectionView reloadData];
                    
                    // Is Recorded
                    [recordPausePlayBtn setImage: [UIImage imageNamed: @"icon_play_recording_bluegreen_120x120"] forState: UIControlStateNormal];
                    
                    audioBgView.hidden = NO;
                    deleteAudioBtn.hidden = NO;
                    
                    isRecorded = YES;
                    
                } else if ([dic[@"result"] boolValue] == 0) {
                    NSLog(@"message: %@", dic[@"message"]);
                    
                    // Can not Record
                    [recordPausePlayBtn setImage: [UIImage imageNamed: @"icon_mic_bluegreen_120x120"] forState: UIControlStateNormal];
                    audioBgView.hidden = YES;
                    deleteAudioBtn.hidden = YES;
                    
                    isRecorded = NO;
                    
                    [self showPermission];
                } else {
                    [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                }
            }
        });
    });
}

- (void)deleteAudioOfDiy
{
    [wTools ShowMBProgressHUD];
    
    NSLog(@"selectItem: %ld", (long)selectItem);
    
    NSString *pid = [ImageDataArr [selectItem][@"photo_id"] stringValue];
    NSLog(@"pid: %@", pid);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSString *response = [boxAPI deleteAudioOfDiy: [wTools getUserID] token: [wTools getUserToken] album_id: _albumid photo_id: pid];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"%@", response);
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                if ([dic[@"result"] intValue] == 1) {
                    NSLog(@"deleteAudio Success");
                    NSLog(@"%@", dic[@"data"]);
                    
                    // Update audio_url for just finish recording
                    audio_url = dic[@"data"][@"photo"][selectItem][@"audio_url"];
                    NSLog(@"audio_url: %@", audio_url);
                    
                    // Update ImageDataArr
                    ImageDataArr=[NSMutableArray arrayWithArray:dic[@"data"][@"photo"]];
                    
                    //[mycollection reloadData];
                    [_dataCollectionView reloadData];
                    
                    [avPlayer pause];
                    
                    audioBgView.hidden = YES;
                    deleteAudioBtn.hidden = YES;
                    [recordPausePlayBtn setImage: [UIImage imageNamed: @"icon_mic_bluegreen_120x120"] forState: UIControlStateNormal];
                } else if ([dic[@"result"] boolValue] == 0) {
                    NSLog(@"message: %@", dic[@"message"]);
                    [self showPermission];
                } else {
                    [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                }
            }
        });
    });
}

/*
#pragma mark -
#pragma mark AVAudioPlayer Delegate Methods
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"finish playing");
}
*/

#pragma mark - Check Photo Access Permission

- (void)photoSetup {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        NSLog(@"requestAuthorization");
        if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
            NSLog(@"authorized");
            
            photoGranted = YES;
        } else {
            NSLog(@"Not Authorized");
            
            photoGranted = NO;
            [self showNoAccessAlertAndCancel: @"photo"];
        }
    }];
}

- (void)checkPhoto {
    NSLog(@"checkPhoto");
    
    /*
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        NSLog(@"requestAuthorization");
        if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
            NSLog(@"authorized");
            
            photoGranted = YES;
        } else {
            NSLog(@"Not Authorized");
            
            photoGranted = NO;
            [self showNoAccessAlertAndCancel: @"photo"];
        }
    }];
     */
    
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        NSLog(@"authorized");
        
        photoGranted = YES;
    } else {
        NSLog(@"Not Authorized");
        
        photoGranted = NO;
        [self showNoAccessAlertAndCancel: @"photo"];
    }
}

#pragma mark - Check Audio Access Permission
- (void)checkAudio {
    NSLog(@"checkAudio");
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType: AVMediaTypeAudio];
    
    NSLog(@"authStatus: %ld", (long)authStatus);
    
    if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        //[wTools showAlertTile:NSLocalizedString(@"PicText-tipAccessPrivacy", @"") Message:@"" ButtonTitle:nil];
        [self showNoAccessAlertAndCancel: @"audio"];
        audioGranted = NO;
        /*
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: NSLocalizedString(@"PicText-tipAccessPrivacy", @"") message: @"" preferredStyle: UIAlertControllerStyleAlert];
        [alert addAction: [UIAlertAction actionWithTitle: @"設定" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: UIApplicationOpenSettingsURLString]];
        }]];
        
        [self presentViewController: alert animated: YES completion: nil];
         */
    } else {
        audioGranted = YES;
    }
    
    /*
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            NSLog(@"granted");
            audioGranted = YES;
        } else {
            NSLog(@"denited");
            audioGranted = NO;
            [self showNoAccessAlertAndCancel: @"audio"];
        }
    }];
     */
}

#pragma mark -

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
    
    [alert addAction: [UIAlertAction actionWithTitle: @"設定" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: UIApplicationOpenSettingsURLString]];
    }]];
    
    [self presentViewController: alert animated: YES completion: nil];
}

#pragma mark -
#pragma mark IBAction Methods

- (IBAction)chooseTemplateOrFast:(id)sender {
    NSLog(@"chooseTemplateOrFast");
    
    isEditing = YES;
    _choiceOptionView.hidden = YES;
    
    if ([_choice isEqualToString: @"Template"]) {
        //[choiceBtn setImage: [UIImage imageNamed: @"icon_select_template_bluegreen_200x200"] forState: UIControlStateNormal];
        
        NSLog(@"choice is template");
        
        NSLog(@"ImageDataArr.count: %lu", (unsigned long)ImageDataArr.count);
        NSLog(@"selectrow: %ld", (long)_selectrow);
        
        [self checkPhoto];
        
        NSLog(@"photoGranted: %d", photoGranted);
        
        if (photoGranted) {
            NSLog(@"photo access is granted");
            
            if (ImageDataArr.count < _selectrow) {
                NSLog(@"ImageDataArr.count < _selectrow");
                /*
                TemplateViewController *tVC = [[UIStoryboard storyboardWithName:@"Fast" bundle:nil]instantiateViewControllerWithIdentifier:@"TemplateViewController"];
                tVC.albumid = _albumid;
                tVC.event_id = _event_id;
                tVC.postMode = _postMode;
                tVC.choice = _choice;
                
                [self.navigationController pushViewController: tVC animated: YES];
                */
                
                [self performSegueWithIdentifier: @"showTemplateViewController" sender: sender];
            } else if (ImageDataArr.count == _selectrow) {
                NSLog(@"Reach the limit");
                
                [self showCell];
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"" message: @"選取已達上限" preferredStyle: UIAlertControllerStyleAlert];
                UIAlertAction *okBtn = [UIAlertAction actionWithTitle: @"確定" style: UIAlertActionStyleDefault handler: nil];
                [alert addAction: okBtn];
                [self presentViewController: alert animated: YES completion: nil];
            }
        } else {
            [self showNoAccessAlertAndCancel: @"photo"];
        }
        
    } else if ([_choice isEqualToString: @"Fast"]) {
        NSLog(@"choice is fast");
        NSLog(@"ImageDataArr.count: %lu", (unsigned long)ImageDataArr.count);
        NSLog(@"selectrow: %ld", (long)_selectrow);
        
        [self checkPhoto];
        
        NSLog(@"photoGranted: %d", photoGranted);
        
        if (ImageDataArr.count < _selectrow) {
            
            if (photoGranted) {
                /*
                PhotosViewController *pvc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"PhotosViewController2"];
                pvc.selectrow = [wTools userbook];
                NSLog(@"pvc.selectrow: %ld", (long)pvc.selectrow);
                pvc.phototype = @"1";
                pvc.delegate = self;
                pvc.choice = _choice;
                NSLog(@"choice: %@", _choice);
                
                pvc.selectedImgAmount = ImageDataArr.count;
                
                //[self.navigationController pushViewController: pvc animated:YES];
                //AppDelegate *app = (AppDelegate *)[]
                 */
                [self performSegueWithIdentifier: @"showPhotoViewController" sender: sender];
            } else {
                [self showNoAccessAlertAndCancel: @"photo"];
            }
        } else if (ImageDataArr.count == _selectrow) {
            NSLog(@"Reach the limit");
            
            [self showCell];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"" message: @"選取已達上限" preferredStyle: UIAlertControllerStyleAlert];
            UIAlertAction *okBtn = [UIAlertAction actionWithTitle: @"確定" style: UIAlertActionStyleDefault handler: nil];
            [alert addAction: okBtn];
            [self presentViewController: alert animated: YES completion: nil];
        }
    }
}

- (IBAction)chooseVideo:(id)sender
{
    /*
    ChooseVideoViewController *chooseVideoVC = [[UIStoryboard storyboardWithName: @"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"ChooseVideoViewController"];
    chooseVideoVC.selectRow = 1;
    chooseVideoVC.delegate = self;
    [self.navigationController pushViewController: chooseVideoVC animated: YES];
     */
    
    if (ImageDataArr.count < _selectrow) {
        //[self checkCamera];
        [self showVideoMode];
        
    } else if (ImageDataArr.count == _selectrow) {
        NSLog(@"Reach the limit");
        
        [self showCell];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"" message: @"選取已達上限" preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *okBtn = [UIAlertAction actionWithTitle: @"確定" style: UIAlertActionStyleDefault handler: nil];
        [alert addAction: okBtn];
        [self presentViewController: alert animated: YES completion: nil];
    }
}

- (void)checkCamera {
    //判断是否拥有权限
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
     
    if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        //[wTools showAlertTile:NSLocalizedString(@"PicText-tipAccessPrivacy", @"") Message:@"" ButtonTitle:nil];
        /*
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: NSLocalizedString(@"PicText-tipAccessPrivacy", @"") message: @"" preferredStyle: UIAlertControllerStyleAlert];
        [alert addAction: [UIAlertAction actionWithTitle: @"設定" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: UIApplicationOpenSettingsURLString]];
        }]];
        
        [self presentViewController: alert animated: YES completion: nil];
         */
        
        [self showNoAccessAlertAndCancel: @"camera"];
    }
}

-(IBAction)reload:(id)sender {
    NSLog(@"reload");
    
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone=[boxAPI getalbumofdiy:[wTools getUserID] token:[wTools getUserToken] album_id:_albumid];
        
        NSMutableDictionary *data=[NSMutableDictionary new];
        [data setObject:_albumid forKey:@"type_id"];
        [data setObject:[wTools getUserID] forKey:@"user_id"];
        [data setObject:@"album" forKey:@"type"];
        
        NSString *coopid=[boxAPI getcooperation:[wTools getUserID] token:[wTools getUserToken] data:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [wTools HideMBProgressHUD];
            
            if (respone!=nil) {
                NSLog(@"response: %@",respone);
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                NSDictionary *identdic=(NSDictionary *)[NSJSONSerialization JSONObjectWithData:[coopid dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                if ([dic[@"result"] intValue] == 1) {
                    NSLog(@"call getalbumofdiy success");
                    NSLog(@"%@", dic[@"data"][@"photo"]);
                    
                    identity=identdic[@"data"];
                    
                    ImageDataArr=[NSMutableArray arrayWithArray:dic[@"data"][@"photo"]];
                    NSLog(@"ImageDataArr: %@", ImageDataArr);
                    
                    if (ImageDataArr.count == 0) {
                        adobeEidt.hidden = YES;
                        recordPausePlayBtn.hidden = YES;
                        deleteImageBtn.hidden = YES;
                    } else {
                        adobeEidt.hidden = NO;
                        recordPausePlayBtn.hidden = NO;
                        deleteImageBtn.hidden = NO;
                        
                        _choiceOptionView.hidden = YES;
                        isEditing = YES;
                    }
                    
                    NSLog(@"ImageDataArr.count: %lu", (unsigned long)ImageDataArr.count);
                    
                    [self myshowimage];
                    //[mycollection reloadData];
                    [_dataCollectionView reloadData];
                } else if ([dic[@"result"] intValue] == 0) {
                    NSLog(@"失敗：%@",dic[@"message"]);
                    [self showCustomErrorAlert: dic[@"message"]];
                } else {
                    [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                }
            }
        });
    });
}

//儲存相本
-(IBAction)save:(id)sender{
    
    NSLog(@"快速建立相本 儲存");
    
    /*
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"" message: @"確定發佈作品" preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction *okBtn = [UIAlertAction actionWithTitle: @"確定" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if ([identity isEqualToString:@"editor"] || [identity isEqualToString: @"approver"]) {
            [self updateAlbumOfDiy];
            [self.navigationController popViewControllerAnimated:YES];
            
            NSLog(@"identity is not admin");
            return;
        }
        NSLog(@"excute the line below");
        [self updateAlbumOfDiy];
    }];
    
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleDefault handler: nil];
    [alert addAction: cancelBtn];
    [alert addAction: okBtn];
    [self presentViewController: alert animated: YES completion: nil];
     */
    
    if (ImageDataArr.count == 0) {
        NSString *msg = @"你的作品還沒有內容唷!";
        
        [self showAlertView: msg];
    } else {
        if ([identity isEqualToString:@"editor"] || [identity isEqualToString: @"approver"]) {
            [self updateAlbumOfDiy];
            [self.navigationController popViewControllerAnimated:YES];
            
            NSLog(@"identity is not admin");
            return;
        }
        NSLog(@"excute the line below");
        [self updateAlbumOfDiy];
    }        
}

#pragma mark - Custom AlertView
- (void)showAlertView: (NSString *)msg
{
    CustomIOSAlertView *alertV = [[CustomIOSAlertView alloc] init];
    [alertV setContainerView: [self createView: msg]];
    [alertV setButtonTitles: [NSMutableArray arrayWithObject: @"確     認"]];
    [alertV setUseMotionEffects: true];
    
    [alertV show];
}

- (UIView *)createView: (NSString *)msg
{
    UIView *view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 250, 220)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(50, 0, 150, 150)];
    imageView.image = [UIImage imageNamed: @"dialog_error_dark.png"];
    [view addSubview: imageView];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame: CGRectMake(20, 150, 210, 50)];
    messageLabel.text = msg;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.numberOfLines = 0;
    //messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    messageLabel.adjustsFontSizeToFitWidth = YES;
    
    [view addSubview: messageLabel];
    
    return view;
}

#pragma mark -

- (void)updateAlbumOfDiy
{
    NSLog(@"updateAlbumOfDiy");
    
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone=[boxAPI updatealbumofdiy:[wTools getUserID] token:[wTools getUserToken] album_id:_albumid];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [wTools HideMBProgressHUD];
            
            if (respone!=nil) {
                NSLog(@"%@",respone);
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                if ([dic[@"result"] intValue] == 1) {
                    if ([self checkPermissionForEditing]) {
                        NSArray *arr = self.navigationController.viewControllers;
                        
                        if ([arr [arr.count - 2] isKindOfClass: [BookdetViewController class]]) {
                            NSLog(@"[arr [arr.count - 2] isKindOfClass: [BookdetViewController class]]");
                            [self.navigationController popViewControllerAnimated:YES];
                        } else {
                            NSLog(@"postMode: %d", _postMode);
                            NSLog(@"[wTools editphotoinfo: _albumid templateid: _templateid eventId: _event_id postMode: _postMode]");
                            
                            [self performSegueWithIdentifier: @"showBookdetViewController" sender: self];
                        }
                    }
                } else if ([dic[@"result"] intValue] == 0) {
                    NSLog(@"失敗：%@",dic[@"message"]);
                    [self showCustomErrorAlert: dic[@"message"]];
                } else {
                    [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                }
            }
        });
    });
}

- (IBAction)back:(id)sender {
    NSLog(@"back button pressed");
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"" message: @"確定退出編輯器" preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction *okBtn = [UIAlertAction actionWithTitle: @"確定" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSArray *vcarr = self.navigationController.viewControllers;
        
        for (int i = 0; i<vcarr.count; i++) {
            UIViewController *vc=vcarr[i];
            if ([vc isKindOfClass:[TaobanViewController class]]) {
                [self.navigationController popToViewController:vc animated:YES];
                return;
            }
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleDefault handler: nil];
    [alert addAction: cancelBtn];
    [alert addAction: okBtn];
    [self presentViewController: alert animated: YES completion: nil];
}

- (IBAction)deleteFile:(id)sender
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        //NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:ImageDataArr[selectItem][@"video_url"]]];
        
        NSString *videoStr = ImageDataArr[selectItem][@"video_url"];
        NSLog(@"videoStr: %@", videoStr);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([videoStr isKindOfClass: [NSNull class]]) {
                [self deleteImage];
            } else {
                [self deleteVideo];
            }
        });
    });
}

#pragma mark -
#pragma mark Delete File Section

//刪除
- (void)deleteImage {
    NSLog(@"deleteImage");
    
    Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
    [rv addtitletext:NSLocalizedString(@"CreateAlbumText-tipConfirmDel", @"")];
    [rv addSelectBtntext:NSLocalizedString(@"GeneralText-yes", @"") btn2:NSLocalizedString(@"GeneralText-no", @"") ];
    
    rv.btn1select=^(BOOL select){
        
        if (select) {
            NSString *pid=[ImageDataArr[selectItem][@"photo_id"] stringValue];
            
            [wTools ShowMBProgressHUD];
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                
                NSString *respone=[boxAPI deletephotoofdiy:[wTools getUserID] token:[wTools getUserToken] album_id:_albumid photo_id:pid];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [wTools HideMBProgressHUD];
                    if (respone!=nil) {
                        NSLog(@"%@",respone);
                        NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                        if ([dic[@"result"] intValue] == 1) {
                            NSLog(@"deletePhoto Success");
                            ImageDataArr=[NSMutableArray arrayWithArray:dic[@"data"][@"photo"]];
                            [self myshowimage];
                            //[mycollection reloadData];
                            [_dataCollectionView reloadData];
                        } else if ([dic[@"result"] intValue] == 0) {
                            [self showPermission];
                        } else {
                            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                        }
                    }
                });
            });
        }
    };
    [rv showView:self.view];
}

- (void)deleteVideo {
    NSLog(@"deleteVideo");
    
    Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
    [rv addtitletext:NSLocalizedString(@"CreateAlbumText-tipConfirmDelVideo", @"")];
    [rv addSelectBtntext:NSLocalizedString(@"GeneralText-yes", @"") btn2:NSLocalizedString(@"GeneralText-no", @"") ];
    
    rv.btn1select=^(BOOL select){
        
        if (select) {
            NSString *pid=[ImageDataArr[selectItem][@"photo_id"] stringValue];
            
            [wTools ShowMBProgressHUD];
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                
                NSString *response = [boxAPI deleteVideoOfDiy:[wTools getUserID] token: [wTools getUserToken] album_id: _albumid photo_id: pid];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [wTools HideMBProgressHUD];
                    
                    if (response != nil) {
                        NSLog(@"%@",response);
                        NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                        
                        if ([dic[@"result"] intValue] == 1) {
                            NSLog(@"deleteVideo Success");
                            ImageDataArr=[NSMutableArray arrayWithArray:dic[@"data"][@"photo"]];
                            [self myshowimage];
                            //[mycollection reloadData];
                            [_dataCollectionView reloadData];
                        } else if ([dic[@"result"] intValue] == 0) {
                            NSLog(@"失敗：%@",dic[@"message"]);
                            [self showCustomErrorAlert: dic[@"message"]];
                        } else {
                            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                        }
                    }
                });
            });
        }
    };
    [rv showView:self.view];
}

#pragma mark -
#pragma mark Custom AlertView for Video

- (void)showVideoMode
{
    NSLog(@"showVideoMode");
    
    alertView = [[CustomIOSAlertView alloc] init];
    [alertView setContainerView: [self createView]];
    [alertView setButtonTitles: [NSMutableArray arrayWithObject: @"取     消"]];
    [alertView setUseMotionEffects: true];
    [alertView show];
}

- (UIView *)createView
{
    // Parent View
    UIView *buttonView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 250, 220)];
    
    // Topic Label View
    UILabel *topicLabel = [[UILabel alloc] initWithFrame: CGRectMake(25, 10, 200, 10)];
    topicLabel.text = @"模 式 選 擇";
    topicLabel.textAlignment = NSTextAlignmentCenter;
    
    // Time Limit Label View
    UILabel *timeLimitLabel = [[UILabel alloc] initWithFrame: CGRectMake(25, 35, 200, 10)];
    timeLimitLabel.text = @"(限時 30 秒)";
    timeLimitLabel.textAlignment = NSTextAlignmentCenter;
    timeLimitLabel.textColor = [UIColor redColor];
    
    // 1st UIButton View
    UIButton *buttonRecord = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [buttonRecord addTarget: self action: @selector(recordVideo) forControlEvents: UIControlEventTouchUpInside];
    [buttonRecord setTitle: @"錄 影" forState: UIControlStateNormal];
    buttonRecord.frame = CGRectMake(25, 65, 200, 50);
    [buttonRecord setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    buttonRecord.backgroundColor = [UIColor colorWithRed: 32.0/255.0 green: 191.0/255.0 blue: 193.0/255.0 alpha: 1.0];
    buttonRecord.layer.cornerRadius = 10;
    buttonRecord.clipsToBounds = YES;
    
    // 2nd UIButton View
    UIButton *buttonVideo = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [buttonVideo addTarget: self action: @selector(chooseExistingVideo) forControlEvents: UIControlEventTouchUpInside];
    [buttonVideo setTitle: @"選擇現有影片" forState: UIControlStateNormal];
    buttonVideo.frame = CGRectMake(25, 150, 200, 50);
    [buttonVideo setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    buttonVideo.backgroundColor = [UIColor colorWithRed: 32.0/255.0 green: 191.0/255.0 blue: 193.0/255.0 alpha: 1.0];
    buttonVideo.layer.cornerRadius = 10;
    buttonVideo.clipsToBounds = YES;
    
    [buttonView addSubview: topicLabel];
    [buttonView addSubview: timeLimitLabel];
    [buttonView addSubview: buttonRecord];
    [buttonView addSubview: buttonVideo];
    
    return buttonView;
}

- (void)recordVideo
{
    NSLog(@"recordVideo");

    videoMode = @"RecordVideo";
    
    [alertView close];
    _choiceOptionView.hidden = YES;
    
    [self checkCamera];
    
    //NSString *mediaType = AVMediaTypeVideo;
    
    /*
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType: mediaType];
    
    if (authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied) {
        [wTools showAlertTile: NSLocalizedString(@"PicText-tipAccessPrivacy", @"") Message: @"" ButtonTitle: nil];
    }
    */
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *videoPicker = [[UIImagePickerController alloc] init];
        videoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        videoPicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *)kUTTypeMovie, nil];
        videoPicker.delegate = self;
        videoPicker.videoMaximumDuration = 30;
        videoPicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
        [self presentViewController: videoPicker animated: YES completion: nil];
    }
}

- (void)chooseExistingVideo
{
    NSLog(@"chooseExistingVideo");
    
    videoMode = @"ExistingVideo";
    
    [alertView close];
    _choiceOptionView.hidden = YES;
    
    /*
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType: mediaType];
    
    if (authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied) {
        [wTools showAlertTile: NSLocalizedString(@"PicText-tipAccessPrivacy", @"") Message: @"" ButtonTitle: nil];
    }
     */
    
    // Check Photo Album Permission is granted or not
    [self checkPhoto];
    
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        UIImagePickerController *videoPicker = [[UIImagePickerController alloc] init];
        videoPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        videoPicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *)kUTTypeMovie, nil];
        videoPicker.delegate = self;
        videoPicker.videoMaximumDuration = 30;
        videoPicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
        [self presentViewController: videoPicker animated: YES completion: nil];
    }
}

#pragma mark -
#pragma mark UIImagePickerController Delegate Method
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSLog(@"didFinishPickingMediaWithInfo");
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    [self dismissViewControllerAnimated: NO completion: nil];
    
    // Handle a movie capture
    if (CFStringCompare((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        NSString *moviePath = [[info objectForKey: UIImagePickerControllerMediaURL] path];
        
        NSLog(@"moviePath: %@", moviePath);
        
        if ([videoMode isEqualToString: @"RecordVideo"]) {
            NSLog(@"videoMode isEqualToString RecordVideo");
            
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(moviePath)) {
                UISaveVideoAtPathToSavedPhotosAlbum(moviePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
            }
            
        } else if ([videoMode isEqualToString: @"ExistingVideo"]) {
            NSLog(@"videoMode isEqualToString ExistingVideo");
            
            // 3 - Play the video
            NSURL *videoURL = [info objectForKey: UIImagePickerControllerMediaURL];
            AVURLAsset *sourceAsset = [AVURLAsset URLAssetWithURL: videoURL options: nil];
            CMTime duration = sourceAsset.duration;
            float seconds = CMTimeGetSeconds(duration);
            NSLog(@"duration: %.2f", seconds);
            
            if (seconds >= 31) {
                NSLog(@"Longer than 30 seconds");
                UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"無法傳送影片" message: @"影片超過30秒上限，請重新選擇" preferredStyle: UIAlertControllerStyleAlert];
                UIAlertAction *defaultAction = [UIAlertAction actionWithTitle: @"OK"
                                                                        style: UIAlertActionStyleDefault
                                                                      handler: nil];
                [alert addAction: defaultAction];
                [self presentViewController: alert animated: YES completion: nil];
            } else {
                NSLog(@"Smaller than 30 seconds");
                [self convertVideoToMP4: videoURL];
                
                //NSData *data = [NSData dataWithContentsOfURL: videoURL];
                //[self callInsertVideoOfDiy: data];
                //[self createTask: data];
            }
            
            /*
            AVPlayer *player = [AVPlayer playerWithURL: videoURL];
            AVPlayerViewController *playerViewController = [AVPlayerViewController new];
            playerViewController.player = player;
            [self presentViewController: playerViewController animated: YES completion: nil];
             */
        }
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSLog(@"didFinishSavingWithError");
    
    NSLog(@"videoPath: %@", videoPath);
    NSURL *videoURL = [NSURL fileURLWithPath: videoPath];
    AVURLAsset *sourceAsset = [AVURLAsset URLAssetWithURL: videoURL options: nil];
    CMTime duration = sourceAsset.duration;
    float seconds = CMTimeGetSeconds(duration);
    NSLog(@"duration: %.2f", seconds);
    
    if (seconds >= 31) {
        NSLog(@"Longer than 30 seconds");
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"無法傳送影片" message: @"影片超過30秒上限，請重新錄影" preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle: @"OK"
                                                                style: UIAlertActionStyleDefault
                                                              handler: nil];
        [alert addAction: defaultAction];
        [self presentViewController: alert animated: YES completion: nil];
    } else {
        NSLog(@"Smaller than 30 seconds");
        
        NSData *data = [NSData dataWithContentsOfURL: videoURL];
        [self callInsertVideoOfDiy: data];
    }
    
    if (error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"錯誤"
                                                                       message: @"影片儲存失敗"
                                                                preferredStyle: UIAlertControllerStyleAlert];
        
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle: @"OK"
                                                                style: UIAlertActionStyleDefault
                                                              handler: nil];
        [alert addAction: defaultAction];
        [self presentViewController: alert animated: YES completion: nil];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"成功"
                                                                       message: @"影片儲存到相簿"
                                                                preferredStyle: UIAlertControllerStyleAlert];
        
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle: @"OK"
                                                                style: UIAlertActionStyleDefault
                                                              handler: nil];
        [alert addAction: defaultAction];
        [self presentViewController: alert animated: YES completion: nil];
    }
}

// For responding to the user tapping Cancel.
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //[self dismissModalViewControllerAnimated: YES];
    [self dismissViewControllerAnimated: YES completion: nil];
}

#pragma mark ----------- mp4ConversionMethod ------------
-(void)convertVideoToMP4:(NSURL*)videoURL
{
    NSLog(@"convertVideoToMP4");
    
    // Create the asset url with the video file
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL: videoURL options: nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset: avAsset];
    
    // Check if video is supported for conversion or not
    if ([compatiblePresets containsObject: AVAssetExportPreset640x480]) {
        // Create Export Session
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset: avAsset
                                                                               presetName: AVAssetExportPreset640x480];
        // Creating temp path to save the converted video
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
        NSString *myDocumentPath = [documentsDirectory stringByAppendingPathComponent: @"temp.mp4"];
        
        NSURL *url = [[NSURL alloc] initFileURLWithPath: myDocumentPath];
        
        // Check if the file already exists then remove the previous file
        if ([[NSFileManager defaultManager] fileExistsAtPath: myDocumentPath]) {
            [[NSFileManager defaultManager] removeItemAtPath: myDocumentPath
                                                       error: nil];
        }
        
        exportSession.outputURL = url;
        
        //set the output file format if you want to make it in other file format (ex .3gp)
        exportSession.outputFileType = AVFileTypeMPEG4;
        exportSession.shouldOptimizeForNetworkUse = YES;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"錯誤"
                                                                        message: [[exportSession error] localizedDescription]
                                                                       delegate: nil
                                                              cancelButtonTitle: @"確定"
                                                              otherButtonTitles: nil];
                        [alert show];
                    });
                    break;
                }
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                case AVAssetExportSessionStatusCompleted:
                {
                    // Video conversion finished
                    NSLog(@"Successful!");
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        NSString *mp4Path = [NSHomeDirectory() stringByAppendingFormat: @"/Documents/%@.mp4", @"temp"];
                        NSLog(@"mp4Path: %@", mp4Path);
                        
                        NSURL *videoURL = [NSURL fileURLWithPath: mp4Path];
                        NSData *data = [NSData dataWithContentsOfURL: videoURL];
                        [self callInsertVideoOfDiy: data];
                        
                        /*
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"影像檔案轉檔成功"
                                                                        message: mp4Path
                                                                       delegate: nil
                                                              cancelButtonTitle: @"確認"
                                                              otherButtonTitles: nil];
                        [alert show];
                         */
                    });
                }
                    break;
                default:
                    break;
            }
        }];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"錯誤"
                                                        message: @"影像檔案不支援"
                                                       delegate: nil
                                              cancelButtonTitle: @"確認"
                                              otherButtonTitles: nil];
        [alert show];
    }
}

#pragma mark - Calling Protocol callInsertVideoOfDiy
- (void)callInsertVideoOfDiy: (NSData *)data;
{
    NSLog(@"callInsertVideoOfDiy");
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *response = @"";
        response = [boxAPI insertVideoOfDiy: [wTools getUserID] token: [wTools getUserToken] album_id: _albumid file: data];                
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                if ([dic[@"result"] intValue] == 1) {
                    NSLog(@"insertvideoofdiy Success");
                    
                    ImageDataArr = [NSMutableArray arrayWithArray: dic[@"data"][@"photo"]];
                    NSLog(@"ImageDataArr.count: %lu", (unsigned long)ImageDataArr.count);
                    
                    selectItem = ImageDataArr.count - 1;
                    NSLog(@"selectItem: %ld", (long)selectItem);
                    
                    [self myshowimage];
                    NSLog(@"[_dataCollectionView reloadData]");
                    [_dataCollectionView reloadData];
                    
                    isEditing = YES;
                    _choiceOptionView.hidden = YES;
                } else if ([dic[@"result"] intValue] == 0) {
                    NSLog(@"insertvideoofdiy Failed");
                    NSLog(@"message: %@", dic[@"message"]);
                    
                    if (dic[@"message"] == nil) {
                        NSLog(@"dic message is nil");
                        NSLog(@"response from insertvideoofdiy: %@", response);
                        
                        if (![response isKindOfClass: [NSNull class]]) {
                            if (![response isEqualToString: @""]) {
                                UIAlertController *alert = [UIAlertController alertControllerWithTitle: response message: @"目前網路不穩定，請確認網路品質再繼續使用pinpinbox唷!" preferredStyle: UIAlertControllerStyleAlert];
                                UIAlertAction *okBtn = [UIAlertAction actionWithTitle: @"確定" style: UIAlertActionStyleDefault handler: nil];
                                [alert addAction: okBtn];
                                [self presentViewController: alert animated: YES completion: nil];
                            }
                        }
                    }
                } else {
                    [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                }
            }
        });
    });
}
  
#pragma mark -
#pragma mark Long Press Gesture

- (void)handleLongPress: (UILongPressGestureRecognizer *)gestureRecognizer
{
    NSLog(@"handleLongPress");
    
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    CGPoint p = [gestureRecognizer locationInView: _dataCollectionView];
    
    NSIndexPath *indexPath = [_dataCollectionView indexPathForItemAtPoint: p];
    
    if (indexPath == nil) {
        NSLog(@"couldn't find index path");
    } else {
        NSLog(@"find index path");
        // get the cell at indexPath (the one you long pressed)
        //UICollectionViewCell *cell = [mycollection cellForItemAtIndexPath: indexPath];
        /*
        ReorderViewController *reorderVC = [[UIStoryboard storyboardWithName: @"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"ReorderViewController"];
        //[self.navigationController pushViewController: reorderVC animated: YES];
        
        reorderVC.imageArray = ImageDataArr;
        //NSLog(@"reorderCV.imageArray: %@", reorderCV.imageArray);
        
        [self presentViewController: reorderVC animated: YES completion: nil];
         */
    }
}

#pragma mark -

//新增照片
-(void)addimagedata{
    
    NSLog(@"addimagedata");
    
    //新增照片
    if (ImageDataArr.count>=_selectrow) {
        NSLog(@"selectRow: %ld", (long)_selectrow);
        
        Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
        [rv addtitletext:NSLocalizedString(@"CreateAlbumText-tipLimit", @"")];
        [rv addBackTouch];
        [rv showView:self.view];
       
        return;
    }
    
    if (_booktype!=1000) {
        NSLog(@"bookType: %ld", (long)_booktype);
        
        PhotosViewController *pvc=[[UIStoryboard storyboardWithName:@"PhotosVC" bundle:nil]instantiateViewControllerWithIdentifier:@"PhotosViewController2"];
        pvc.selectrow=_selectrow-ImageDataArr.count;
        pvc.phototype=@"1";
        pvc.delegate=self;
        [self.navigationController pushViewController:pvc animated:YES];
    } else {
        NSLog(@"bookType: %ld", (long)_booktype);
        
        //套版頁面
        TemplateViewController *tvc=[[UIStoryboard storyboardWithName:@"Fast" bundle:nil]instantiateViewControllerWithIdentifier:@"TemplateViewController"];
        tvc.albumid=_albumid;
        [self.navigationController pushViewController:tvc animated:YES];
    }
}

- (void)showCell
{
    NSLog(@"showCell");
    
    // Let the Cell show up
    for (UICollectionViewCell *cell in [_dataCollectionView visibleCells]) {
        NSIndexPath *indexPath = [_dataCollectionView indexPathForCell: cell];
        
        if (indexPath.item != 0) {
            NSLog(@"indexPath.item != 0");
            NSLog(@"indexPath: %@", indexPath);
            NSLog(@"indexPath.item: %ld", (long)indexPath.item);
            
            UICollectionViewCell *otherCell = [_dataCollectionView cellForItemAtIndexPath: indexPath];
            otherCell.alpha = 1;
        }
    }
}

//顯示圖像
-(void)myshowimage {
    
    NSLog(@"myshowimage");
    NSLog(@"selectItem: %ld", (long)selectItem);
    NSLog(@"isEditing: %d", isEditing);
    
    for (UIView *v in [_ShowView subviews]) {
        NSLog(@"v: %@", v);
        [v removeFromSuperview];
    }
    
    if (ImageDataArr.count == 0) {
        NSLog(@"ImageDataArr.count: %lu", (unsigned long)ImageDataArr.count);
        
        adobeEidt.hidden = YES;
        recordPausePlayBtn.hidden = YES;
        audioBgView.hidden = YES;
        deleteAudioBtn.hidden = YES;
        
        textBgView.hidden = YES;
        addTextBtn.hidden = YES;
        deleteTextBtn.hidden = YES;
        
        deleteImageBtn.hidden = YES;
        
        /*
        _choiceOptionView.hidden = NO;
        isEditing = NO;
        NSLog(@"isEditing: %d", isEditing);
         */
        
        return;
        
    } else if (ImageDataArr.count != 0) {
        NSLog(@"ImageDataArr.count: %lu", (unsigned long)ImageDataArr.count);
        
        adobeEidt.hidden = NO;
        
        addTextBtn.hidden = NO;
        
        recordPausePlayBtn.hidden = NO;
        [recordPausePlayBtn setImage: [UIImage imageNamed: @"icon_mic_bluegreen_120x120"] forState: UIControlStateNormal];
        audioBgView.hidden = YES;
        deleteAudioBtn.hidden = YES;
        
        deleteImageBtn.hidden = NO;
        
        /*
        _choiceOptionView.hidden = YES;
        isEditing = YES;
        NSLog(@"isEditing: %d", isEditing);
         */
    }
    
    // For Array Counting
    if (selectItem >= ImageDataArr.count) {
        NSLog(@"Array Counting");
        selectItem = ImageDataArr.count - 1;
        NSLog(@"selectItem: %ld", (long)selectItem);
    }
    
    NSLog(@"selectItem: %ld", (long)selectItem);
    
    [self showCell];
    
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSData *data= [NSData dataWithContentsOfURL:[NSURL URLWithString:ImageDataArr[selectItem][@"image_url"]]];
        NSLog(@"global queue");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"get main queue");
            
            UIImage *image = [UIImage imageWithData: data];
            UIImageView *imgv = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, _ShowView.bounds.size.width, _ShowView.bounds.size.height)];
            imgv.image = image;
            imgv.contentMode = UIViewContentModeScaleAspectFit;
            selectimage = image;
            [_ShowView addSubview: imgv];
            
            NSString *videoStr = ImageDataArr[selectItem][@"video_url"];
            NSLog(@"videoStr: %@", videoStr);
            
            UIButton *videoBtn;
            
            if (![videoStr isKindOfClass: [NSNull class]]) {
                NSLog(@"videoStr is not null");
                
                videoBtn = [UIButton buttonWithType: UIButtonTypeCustom];
                [videoBtn addTarget: self action: @selector(playVideo) forControlEvents: UIControlEventTouchUpInside];
                videoBtn.frame = CGRectMake(0, 0, 100, 100);
                
                [videoBtn setImage: [UIImage imageNamed: @"icon_videoplay_white_310x310"] forState: UIControlStateNormal];
                [videoBtn setImage: [UIImage imageNamed: @"icon_videoplay_grey800_310x310"] forState: UIControlStateHighlighted];
                videoBtn.center = CGPointMake(imgv.bounds.size.width / 2, imgv.bounds.size.height / 2);
                [_ShowView addSubview: videoBtn];
                
                adobeEidt.hidden = YES;
                
                recordPausePlayBtn.hidden = YES;
                audioBgView.hidden = YES;
                deleteAudioBtn.hidden = YES;
                
            } else if ([videoStr isKindOfClass: [NSNull class]]) {
                NSLog(@"videoStr is null");
                [videoBtn removeFromSuperview];
                adobeEidt.hidden = NO;
                
                recordPausePlayBtn.hidden = NO;
                audioBgView.hidden = NO;
                deleteAudioBtn.hidden = NO;
            }
            
            [wTools HideMBProgressHUD];
            
            audio_url = ImageDataArr[selectItem][@"audio_url"];
            NSLog(@"audio_url: %@", audio_url);
            
            if (![audio_url isKindOfClass: [NSNull class]]) {
                if (![audio_url isEqualToString: @""]) {
                    NSLog(@"audio_url is not empty");
                    NSLog(@"audio_url: %@", audio_url);
                    
                    [recordPausePlayBtn setImage: [UIImage imageNamed: @"icon_play_recording_bluegreen_120x120"] forState: UIControlStateNormal];
                    audioBgView.hidden = NO;
                    deleteAudioBtn.hidden = NO;
                    isRecorded = YES;
                }
            } else {
                NSLog(@"audio_url is empty");
                audioBgView.hidden = YES;
                deleteAudioBtn.hidden = YES;
                [recordPausePlayBtn setImage: [UIImage imageNamed: @"icon_mic_bluegreen_120x120"] forState: UIControlStateNormal];
                isRecorded = NO;
            }
            
            textForDescription = ImageDataArr[selectItem][@"description"];
            NSLog(@"textForDescription: %@", textForDescription);
            
            if (![textForDescription isEqualToString: @""]) {
                textBgView.hidden = NO;
                deleteTextBtn.hidden = NO;
            } else if ([textForDescription isEqualToString: @"給這頁作品加點介紹吧！"]) {
                textBgView.hidden = YES;
                deleteTextBtn.hidden = YES;
            } else {
                textBgView.hidden = YES;
                deleteTextBtn.hidden = YES;
            }
            
            [wTools HideMBProgressHUD];
            
            /*
            NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow: selectItem + 1 inSection: 0];
            
            UICollectionViewCell *cell = [self.dataCollectionView cellForItemAtIndexPath: selectedIndexPath];
            cell.layer.borderWidth = 1;
            cell.layer.borderColor = [[UIColor colorWithRed: 233.0/255.0 green: 30.0/255.0 blue: 99.0/255.0 alpha: 1.0] CGColor];
             */
            //[_dataCollectionView reloadData];
        });
    });
    
    //[mycollection reloadData];
    //[_dataCollectionView reloadData];
}

- (void)playVideo
{
    NSLog(@"playVideo");
    NSLog(@"selectItem: %ld", (long)selectItem);
    NSLog(@"video_url: %@", ImageDataArr[selectItem][@"video_url"]);
    
    NSString *urlString = ImageDataArr[selectItem][@"video_url"];
    NSLog(@"urlString: %@", urlString);
    
    NSURL *videoURL = [NSURL URLWithString: urlString];
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL: videoURL];
    AVPlayer *player = [AVPlayer playerWithPlayerItem: playerItem];
    AVPlayerViewController *playerViewController = [AVPlayerViewController new];
    playerViewController.player = player;
    
    [self presentViewController: playerViewController animated: YES completion: nil];
}

/*
 O_drag *v=[[O_drag alloc]initWithFrame:CGRectMake(x, y, w, h)];
 v.tag=100+i;
 [v setImage:[UIImage imageNamed:[NSString stringWithFormat:@"test%i.jpg",i]]];
 [bgview addSubview:v];

 */
//新增相片
//delegate

#pragma mark -
#pragma mark PhotosViewDelegate Methods
- (void)imageCropViewController:(PhotosViewController *)controller ImageArr:(NSArray *)Images compression:(CGFloat)compressionQuality {

    NSLog(@"imageCropViewController");
    
    //上傳照片
    //[wTools ShowMBProgressHUD];
    hud = [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    //hud.labelText = [NSString stringWithFormat: @"等待上傳中"];
    //NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    __block int photoFinished = 0;
    
    self.queue = [[NSOperationQueue alloc] init];
    self.queue.maxConcurrentOperationCount = 5;
    [self.queue addObserver: self forKeyPath: @"operations" options: 0 context: NULL];
    
    NSBlockOperation *operation;
    
    __block NSString *respone = @"";
    
    for (int i = 0; i < Images.count; i++) {
        operation = [NSBlockOperation blockOperationWithBlock:^{
            NSLog(@"i = %d, thread = %@", i, [NSThread currentThread]);
            NSLog(@"Image: %d", i);
            
            //UIImage *image = [Images objectAtIndex: i];
            
            UIImage *imageForResize = [Images objectAtIndex: i];
            NSLog(@"Before Resize");
            NSLog(@"width: %f, height: %f", imageForResize.size.width, imageForResize.size.height);
            
            UIImage *image = [imageForResize imageByScalingAndCroppingForSize: CGSizeMake(kWidthForUpload, kHeightForUpload)];
            NSLog(@"After Resize");
            NSLog(@"width: %f, height: %f", image.size.width, image.size.height);
            
            NSLog(@"boxAPI insertPhotoOfDiy");
            respone = [boxAPI insertphotoofdiy: [wTools getUserID] token: [wTools getUserToken] album_id: _albumid image: image compression: compressionQuality];
            
            responseImageStr = respone;
        }];
        
        [operation setCompletionBlock:^{
            NSLog(@"Operation 1-%d Completed", i);
            photoFinished++;
            //hud.labelText = [NSString stringWithFormat: @"%d 張照片上傳完成", photoFinished];
        }];
        [self.queue addOperation: operation];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    NSLog(@"observeValueForKeyPath");
    
    if (object == self.queue && [keyPath isEqualToString: @"operations"]) {
        NSLog(@"self.queue.operations.count: %lu", (unsigned long)self.queue.operations.count);
        
        if (self.queue.operations.count == 0) {
            NSLog(@"queue has completed");
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                //[wTools HideMBProgressHUD];
                //[hud hide: YES];
                
                if (responseImageStr != nil) {
                    NSLog(@"response is not nil");
                    
                    NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[responseImageStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"]boolValue]) {
                        
                        ImageDataArr = [NSMutableArray arrayWithArray:dic[@"data"][@"photo"]];
                        NSLog(@"ImageDataArr.count: %lu", (unsigned long)ImageDataArr.count);
                        
                        selectItem = ImageDataArr.count - 1;
                        
                        [self myshowimage];
                        //[mycollection reloadData];
                        [_dataCollectionView reloadData];
                        
                    } else{
                        
                    }
                }
            }];
        }
    } else {
        [super observeValueForKeyPath: keyPath ofObject: object change: change context: context];
    }
}

/*
#pragma mark -
#pragma mark ChooseVideoView Delegate Methods
- (void)videoCropViewController:(ChooseVideoViewController *)controller videoArray:(NSArray *)videos
{
    NSLog(@"videoCropViewController");
    
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSLog(@"dispatch_async(dispatch_get_global_queue");
        
        NSString *responseStr = @"";
        
        NSMutableURLRequest *request;
        
        for (int i = 0; i < videos.count; i++) {
            NSData *data = [videos objectAtIndex: i];
            request = [boxAPI insertvideoofdiy: [wTools getUserID] token: [wTools getUserToken] album_id: _albumid file: data];
        }
 
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        contentSize = [httpResponse expectedContentLength];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            loadView.progress = (float)[responseData length] / (float)contentSize;
            NSLog(@"str: %@", str);
            
            [wTools HideMBProgressHUD];
            
            if (str != nil) {
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [str dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                if ([dic[@"result"] boolValue]) {
                    NSLog(@"insertvideoofdiy Success");
                    
                    ImageDataArr = [NSMutableArray arrayWithArray: dic[@"data"][@"photo"]];
                    selectItem = ImageDataArr.count - 1;
                    //[self myshowimage];
                    //[mycollection reloadData];
                }
            }
        });
    });
}
 */

#pragma mark -
#pragma mark UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    return ImageDataArr.count + 1;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionReusableView *reusableview = nil;
    
    //photocell
    UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"photocell" forIndexPath:indexPath];
    reusableview=footerview;
    //        return myCell;
    
    return reusableview;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cellForItemAtIndexPath");
    
    if (indexPath.item == 0) {
        UICollectionViewCell *Cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FastAdd" forIndexPath:indexPath];
        
        UILabel *lab = (UILabel *)[Cell viewWithTag:1111];
        lab.text = [NSString stringWithFormat:@"%lu/%ld",(unsigned long)ImageDataArr.count,(long)_selectrow];
        
        return Cell;
    }
    
    UICollectionViewCell *myCell = [collectionView
                                       dequeueReusableCellWithReuseIdentifier:@"FastV"
                                       forIndexPath:indexPath];
    
    AsyncImageView *imagev = (AsyncImageView *)[myCell viewWithTag:2222];
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: imagev];
    imagev.imageURL = [NSURL URLWithString: ImageDataArr[indexPath.item-1][@"image_url_thumbnail"]];
    [[imagev layer] setMasksToBounds:YES];
    
    //imagev.layer.borderWidth = 10;
    //imagev.layer.borderColor = [[UIColor colorWithRed: 233.0/255.0 green: 30.0/255.0 blue: 99.0/255.0 alpha: 1.0] CGColor];
    
    UIImageView *audioImageView = (UIImageView *)[myCell viewWithTag: 3333];
    
    if (![ImageDataArr[indexPath.item-1][@"audio_url"] isKindOfClass: [NSNull class]]) {
        audioImageView.image = [UIImage imageNamed: @"icon_play_recording_bluegreen_120x120"];
    } else {
        audioImageView.image = [UIImage imageNamed: @""];
    }
    
    UIImageView *videoImageView = (UIImageView *)[myCell viewWithTag: 4444];
    
    if (![ImageDataArr[indexPath.item-1][@"video_url"] isKindOfClass: [NSNull class]]) {
        videoImageView.image = [UIImage imageNamed: @"icon_videoplay_white_310x310"];
        adobeEidt.hidden = YES;
    } else if ([ImageDataArr[indexPath.item-1][@"video_url"] isKindOfClass: [NSNull class]]) {
        videoImageView.image = [UIImage imageNamed: @""];
        adobeEidt.hidden = NO;
    }
    
    UILabel *lab=(UILabel *)[myCell viewWithTag:1111];
    
    if (indexPath.item - 1 == 0) {
        lab.text=NSLocalizedString(@"GeneralText-homePage", @"");
        NSLog(@"indexPath.item - 1 == 0");
        NSLog(@"lab.text: %@", lab.text);
    } else {
        lab.text= [NSString stringWithFormat: @"%li", indexPath.item - 1];
        NSLog(@"else");
        NSLog(@"lab.text: %@", lab.text);
    }
    
    // Set up the Selected Cell
    if (indexPath.item == selectItem + 1) {
        myCell.layer.borderWidth = 3;
        myCell.layer.borderColor = [[UIColor colorWithRed: 233.0/255.0 green: 30.0/255.0 blue: 99.0/255.0 alpha: 1.0] CGColor];
    } else {
        myCell.layer.borderWidth = 0;
        myCell.layer.borderColor = [UIColor clearColor].CGColor;
    }
    
    return myCell;
}

#pragma mark -
#pragma mark UICollectionViewFlowLayoutDelegate
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
    /*
    NSLog(@"didHighlightItemAtIndexPath");
    
    NSLog(@"Click indexPath.item: %ld", (long)indexPath.item);
    
    NSLog(@"isEditing: %d", isEditing);
    
    if (indexPath.item == 0) {
        NSLog(@"indexPath.item == 0");
        
        if (isEditing) {
            NSLog(@"isEditing");
            isEditing = NO;
            _choiceOptionView.hidden = NO;
            
            for (UICollectionViewCell *cell in [_dataCollectionView visibleCells]) {
                NSIndexPath *indexPath = [_dataCollectionView indexPathForCell: cell];
                
                if (indexPath.item != 0) {
                    NSLog(@"indexPath.item != 0");
                    NSLog(@"indexPath: %@", indexPath);
                    NSLog(@"indexPath.item: %ld", (long)indexPath.item);
                    
                    UICollectionViewCell *otherCell = [collectionView cellForItemAtIndexPath: indexPath];
                    //otherCell.contentView.hidden = YES;
                    otherCell.userInteractionEnabled = NO;
                    otherCell.alpha = 0;
                    NSLog(@"otherCell.alpha = 0");
                }
            }
        } else {
            NSLog(@"isNotEditing");
            isEditing = YES;
            _choiceOptionView.hidden = YES;
            
            for (UICollectionViewCell *cell in [_dataCollectionView visibleCells]) {
                NSIndexPath *indexPath = [_dataCollectionView indexPathForCell: cell];
                
                if (indexPath.item != 0) {
                    NSLog(@"indexPath.item != 0");
                    NSLog(@"indexPath: %@", indexPath);
                    NSLog(@"indexPath.item: %ld", (long)indexPath.item);
                    
                    UICollectionViewCell *otherCell = [collectionView cellForItemAtIndexPath: indexPath];
                    otherCell.userInteractionEnabled = YES;
                    otherCell.alpha = 1;
                    NSLog(@"otherCell.alpha = 1");
                }
            }
        }
     
        //[self addimagedata];
    } else {
        [self myshowimage];
        [collectionView reloadData];
    }
    
    if (indexPath.item == 0) {
        NSLog(@"indexPath.item: %ld", (long)indexPath.item);
    } else {
        selectItem = indexPath.item - 1;
    }
    
    NSLog(@"selectItem: %ld", (long)selectItem);
    
    NSLog(@"Click");
     */
    
    NSLog(@"didHighlightItemAtIndexPath");
    NSLog(@"isEditing: %d", isEditing);
    
    if (indexPath.item == 0) {
        NSLog(@"indexPath.item: %ld", (long)indexPath.item);
        
        if (isEditing) {
            NSLog(@"is Editing");
            NSLog(@"choiceOptionView shows up");
            
            isEditing = NO;
            _choiceOptionView.hidden = NO;
            
            
            for (UICollectionViewCell *cell in [_dataCollectionView visibleCells]) {
                NSIndexPath *indexPath = [_dataCollectionView indexPathForCell: cell];
                
                if (indexPath.item != 0) {
                    NSLog(@"indexPath.item != 0");
                    NSLog(@"indexPath: %@", indexPath);
                    NSLog(@"indexPath.item: %ld", (long)indexPath.item);
                    
                    UICollectionViewCell *otherCell = [collectionView cellForItemAtIndexPath: indexPath];
                    otherCell.alpha = 0;
                }
            }
            
        } else if (!isEditing) {
            NSLog(@"is Not Editing");
            NSLog(@"choiceOptionView does not show up");
            
            isEditing = YES;
            _choiceOptionView.hidden = YES;
            
            for (UICollectionViewCell *cell in [_dataCollectionView visibleCells]) {
                NSIndexPath *indexPath = [_dataCollectionView indexPathForCell: cell];
                
                if (indexPath.item != 0) {
                    NSLog(@"indexPath.item != 0");
                    NSLog(@"indexPath: %@", indexPath);
                    NSLog(@"indexPath.item: %ld", (long)indexPath.item);
                    
                    UICollectionViewCell *otherCell = [collectionView cellForItemAtIndexPath: indexPath];
                    otherCell.alpha = 1;
                }
            }            
        }
        
        //[self addimagedata];
        
        return;
    }
    
    NSLog(@"indexPath.item: %ld", (long)indexPath.item);
    selectItem = indexPath.item - 1;
    NSLog(@"selectItem: %ld", (long)selectItem);
    
    [self myshowimage];
    
    [collectionView reloadData];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(54, 94);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

#pragma mark -

//image
//產生對應位置的圖片
-(UIImage *)imageByCroppingtodrag:(O_drag *)dragview{
    
    
    //1336*2004
    //裁切後依據原始畫質大小
    UIImage *bgimag=[dragview finishCropping];
    UIGraphicsBeginImageContext(CGSizeMake(1336, 2004));
    [[UIColor whiteColor] setFill];
    [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 1336, 2004)] fill];
    CGRect frame=dragview.imageView.frame;
    
    float x=frame.origin.x;
    float y=frame.origin.y;
    float w=frame.size.width;
    float h=frame.size.height;
    float s=2004/dragview.bounds.size.height;
    
    if (x>0) {
        if (x+w>oview.bounds.size.width) {
            w=oview.bounds.size.width-x;
        }
    }
    
    if(y>0){
        
    } if (y+h>oview.bounds.size.height) {
        h=oview.bounds.size.height-y;
    }

    if (x<0) {
        
        w=w+x;
        x=0;
    }
    if (y<0) {
        h=h+y;
        y=0;
    }
    
    if (w>oview.bounds.size.width) {
        w=oview.bounds.size.width;
    }
    
    if (h>oview.bounds.size.height) {
        h=oview.bounds.size.height;
    }
    
    [bgimag drawInRect:CGRectMake(x*s,y*s, w*s, h*s)];
    
    // 現在のグラフィックスコンテキストの画像を取得する
    bgimag = UIGraphicsGetImageFromCurrentImageContext();
    
    // 現在のグラフィックスコンテキストへの編集を終了
    // (スタックの先頭から削除する)
    UIGraphicsEndImageContext();
    
    return bgimag;
}

-(IBAction)AdobeEdit:(id)sender{
    
//    if (Oimageview.frame.origin.x!=0 || Oimageview.frame.origin.y!=0){
//        
//        Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
//        [rv addtitletext:@"你已對相片做更改，是否儲存照片並切換圖像"];
//        [rv addSelectBtntext:@"是" btn2:@"否"];
//        rv.btn1select=^(BOOL select){
//            
//            if (select) {
//                UIImage *img=[self imageByCroppingtodrag:oview];
//                
//                 NSString *pid=[ImageDataArr[selectItem][@"photo_id"] stringValue];
//                
//                
//                //上傳照片
//                [wTools ShowMBProgressHUD];
//                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
//                    
//                    NSString *respone=@"";
//                    
//                    
//                    respone=[boxAPI updatephotoofdiy:[wTools getUserID] token:[wTools getUserToken] album_id:_albumid photo_id:pid image:img];
//                    
//                    
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        
//                        if (respone!=nil) {
//                            NSLog(@"%@",respone);
//                            NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
//                            if ([dic[@"result"]boolValue]) {
//                                ImageDataArr=[NSMutableArray arrayWithArray:dic[@"data"]];
//                                [self myshowimage];
//                                [self AdobeSDK];
//                            }else{
//                                
//                                
//                            }
//                            
//                        }
//                        [wTools HideMBProgressHUD];
//                    });
//                    
//                });
//                
//                
//                
//                
//                
//                
//               
//                
//                
//            }else{
//                
//                [self myshowimage];
//                 [self AdobeSDK];
//            }
//            
//            
//        };
//        [rv showView:self.view];
//        
//        
//        return;
//    }
    
    [self AdobeSDK];
}

-(void)AdobeSDK {
    
    NSLog(@"AdobeSDK");
    
    [self displayEditorForImahe:selectimage];
    return;
    
    NSLog(@"Check Login");
    
    //Are we logged in?
    BOOL loggedIn = [AdobeUXAuthManager sharedManager].authenticated;
   
    if(!loggedIn) {
        
        [[AdobeUXAuthManager sharedManager] login:self
                                        onSuccess: ^(AdobeAuthUserProfile * userProfile) {
                                            NSLog(@"success for login");
                                            
                                            [self displayEditorForImahe:oview.image];
                                        }
                                          onError: ^(NSError * error) {
                                              NSLog(@"Error in Login: %@", error);
                                          }];
    } else {
        
        [self displayEditorForImahe:oview.image];
    }

}

-(void)displayEditorForImahe:(UIImage *)imageToEdit{
    NSLog(@"displayEditorForImahe");
    
    AdobeUXImageEditorViewController *editorController = [[AdobeUXImageEditorViewController alloc] initWithImage:imageToEdit];
    [editorController setDelegate:self];
    [self presentViewController:editorController animated:YES completion:nil];
}

- (void)photoEditor:(AdobeUXImageEditorViewController *)editor finishedWithImage:(UIImage *)image
{
    // Handle the result image here
    //[ImageDataArr replaceObjectAtIndex:selectItem withObject:image];
//    [self myshowimage];
//    [mycollection reloadData];
    
    NSLog(@"finishedWithImage");
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //更新照片
    NSString *pid=[ImageDataArr[selectItem][@"photo_id"] stringValue];
    
    //上傳照片
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone=@"";
        
        respone = [boxAPI updatephotoofdiy: [wTools getUserID] token: [wTools getUserToken] album_id: _albumid photo_id: pid image: image setting: textForDescription];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [wTools HideMBProgressHUD];
            
            if (respone!=nil) {
                NSLog(@"Adobe PhotoEditor Response: %@",respone);
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                if ([dic[@"result"] intValue] == 1) {
                    ImageDataArr=[NSMutableArray arrayWithArray:dic[@"data"][@"photo"]];
                    [self myshowimage];
                    [_dataCollectionView reloadData];
                } else if ([dic[@"result"] boolValue] == 0) {
                    [self showPermission];
                } else {
                    [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                }
            }            
        });
    });
}

- (void)photoEditorCanceled:(AdobeUXImageEditorViewController *)editor
{
    NSLog(@"photoEditorCanceled");
    // Handle cancellation here
    [self dismissViewControllerAnimated:YES completion:nil];
}

//共用
-(IBAction)coppertation:(id)sender{
    if ([identity isEqualToString:@"viewer"] || [identity isEqualToString: @"editor"]) {
        Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
        [rv addtitletext:NSLocalizedString(@"CreateAlbumText-tipPermissions", @"")];
        [rv addBackTouch];
        [rv showView:self.view];
        return;
    }
    
    //CooperationViewController *copv=[[CooperationViewController alloc]initWithNibName:@"CooperationViewController" bundle:nil];
    CooperationViewController *copv = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"CooperationViewController"];
    copv.albumid=_albumid;
    copv.identity=identity;
    [self.navigationController pushViewController:copv animated:YES];
}

- (BOOL)checkPermissionForEditing {
    if ([identity isEqualToString:@"editor"] || [identity isEqualToString: @"approver"]) {        
        return NO;
    } else {
        return YES;
    }
}

- (void)showPermission {
    if ([identity isEqualToString:@"editor"] || [identity isEqualToString: @"approver"]) {
        Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
        [rv addtitletext:NSLocalizedString(@"CreateAlbumText-canNotEditOthers", @"")];
        [rv addBackTouch];
        [rv showView:self.view];
    }
}

- (void)performSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString: @"showTemplateViewController"]) {
        TemplateViewController *tVC = [[UIStoryboard storyboardWithName:@"Home" bundle:nil]instantiateViewControllerWithIdentifier:@"TemplateViewController"];
        tVC.albumid = _albumid;
        tVC.event_id = _event_id;
        tVC.postMode = _postMode;
        tVC.choice = _choice;
        [self.navigationController pushViewController: tVC animated: YES];
    }
    if ([identifier isEqualToString: @"showPhotoViewController"]) {
        NSLog(@"identifier isEqualToString showPhotoViewController");
        PhotosViewController *pvc = [[UIStoryboard storyboardWithName:@"Home" bundle:nil]instantiateViewControllerWithIdentifier:@"PhotosViewController2"];
        pvc.selectrow = [wTools userbook];
        NSLog(@"pvc.selectrow: %ld", (long)pvc.selectrow);
        pvc.phototype = @"1";
        pvc.delegate = self;
        pvc.choice = _choice;
        NSLog(@"choice: %@", _choice);
        
        pvc.selectedImgAmount = ImageDataArr.count;
        [self.navigationController pushViewController: pvc animated: YES];
    }
    if ([identifier isEqualToString: @"showBookdetViewController"]) {
        BookdetViewController *bVC = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"BookdetViewController"];
        bVC.album_id = _albumid;
        bVC.templateid = _templateid;
        bVC.postMode = _postMode;
        bVC.eventId = _event_id;
        NSLog(@"self.fromEventPostVC: %d", self.fromEventPostVC);
        bVC.fromEventPostVC = _fromEventPostVC;
        NSLog(@"bVC.fromEventPostVC: %d", bVC.fromEventPostVC);
        
        bVC.navigationItem.title = @"資 訊 編 輯";
        bVC.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18 weight:UIFontWeightLight], NSForegroundColorAttributeName: [UIColor whiteColor]};
        [self.navigationController pushViewController: bVC animated: YES];
    }
}

/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
*/

#pragma mark - MKDropdownMenuDataSource
- (NSInteger)numberOfComponentsInDropdownMenu:(MKDropdownMenu *)dropdownMenu
{
    return 1;
}

- (NSInteger)dropdownMenu:(MKDropdownMenu *)dropdownMenu numberOfRowsInComponent:(NSInteger)component
{
    return 2;
}

#pragma mark - MKDropdownMenuDelegate
- (CGFloat)dropdownMenu:(MKDropdownMenu *)dropdownMenu rowHeightForComponent:(NSInteger)component
{
    return 50;
}

- (NSAttributedString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu attributedTitleForComponent:(NSInteger)component
{
    return [[NSAttributedString alloc] initWithString: @""
                                           attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18 weight:UIFontWeightThin],
                                                        NSForegroundColorAttributeName: [UIColor whiteColor]}];
}

- (NSAttributedString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSMutableAttributedString *string =
    [[NSMutableAttributedString alloc] initWithString: self.types[row]
                                           attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18 weight:UIFontWeightLight],
                                                        NSForegroundColorAttributeName: [UIColor whiteColor]}];
    return string;
}

- (UIColor *)dropdownMenu:(MKDropdownMenu *)dropdownMenu backgroundColorForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [UIColor colorWithRed: 32.0/255.0 green: 191.0/255.0 blue: 193.0/255.0 alpha: 1.0];;
}

- (void)dropdownMenu:(MKDropdownMenu *)dropdownMenu didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"dropdownMenu didSelectRow");

    NSLog(@"self.types: %@", self.types[row]);
    
    NSString *menuStr = self.types[row];
    
    if ([menuStr isEqualToString: @"作 品 排 序"]) {
        NSLog(@"Call Reorder Function");
        
        if (ImageDataArr.count == 0) {
            CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
            style.messageColor = [UIColor whiteColor];
            style.backgroundColor = [UIColor colorWithRed: 233.0/255.0
                                                    green: 30.0/255.0
                                                     blue: 99.0/255.0
                                                    alpha: 1.0];
            [self.view makeToast: @"作品數量多餘1項才可編排順序"
                        duration: 2.0
                        position: CSToastPositionBottom
                           style: style];
        } else {
            [self showReorderVC];
            /*
            reorderVC = [[UIStoryboard storyboardWithName: @"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"ReorderViewController"];
            reorderVC.imageArray = ImageDataArr;
            reorderVC.albumId = self.albumid;
            reorderVC.delegate = self;
            
            [self presentViewController: reorderVC animated: YES completion: nil];
             */
        }
    } else if ([menuStr isEqualToString: @"選擇預覽頁"]) {
        NSLog(@"Call Preview Image Setup");
        
        if (ImageDataArr.count == 0) {
            CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
            style.messageColor = [UIColor whiteColor];
            style.backgroundColor = [UIColor colorWithRed: 233.0/255.0
                                                    green: 30.0/255.0
                                                     blue: 99.0/255.0
                                                    alpha: 1.0];
            [self.view makeToast: @"作品內沒有內容"
                        duration: 2.0
                        position: CSToastPositionBottom
                           style: style];
        } else {
            [self showPreviewPageSetupVC];
        }
    }
    
    [self.dropMenu closeAllComponentsAnimated:YES];
}

#pragma mark - Methods for DropDownMenu Select
- (void)showReorderVC
{
    modalVC = @"ReorderVC";
    
    if (self.childViewControllers.count == 0) {
        NSLog(@"self.childViewControllers.count == 0");
        
        reorderVC = [[UIStoryboard storyboardWithName: @"ReorderVC" bundle: nil] instantiateViewControllerWithIdentifier: @"ReorderViewController"];
        reorderVC.imageArray = ImageDataArr;
        reorderVC.albumId = self.albumid;
        reorderVC.delegate = self;
        
        NSLog(@"ImageDataArr.count: %lu", (unsigned long)ImageDataArr.count);
        NSLog(@"ImageDataArr.count / 4: %lu", ImageDataArr.count / 4);
        NSLog(@"ImageDataArr.count remainder divided by 4 : %lu", ImageDataArr.count % 4);
        
        NSLog(@"1 / 4: %d", 1 / 4);
        
        NSUInteger numOfRows = 0;
        
        if (ImageDataArr.count / 4 == 0) {
            numOfRows = 1;
        } else if (ImageDataArr.count / 4 >= 1) {
            if (ImageDataArr.count % 4 == 0) {
                numOfRows = ImageDataArr.count / 4;
            } else if (ImageDataArr.count % 4 > 0) {
                numOfRows = ImageDataArr.count / 4;
                numOfRows += 1;
            }
        }
        
        NSLog(@"numOfRows: %lu", (unsigned long)numOfRows);
        
        [self.tabBarController.view addSubview: self.dimVC.view];
        
        self.modal = reorderVC;
        //[self addChildViewController: self.modal];
        [self.dimVC addChildViewController: self.modal];
        
        self.modal.view.backgroundColor = [UIColor whiteColor];
        self.modal.view.frame = CGRectMake(0, kViewHeightForReorder, 320, kCellHeightForReorder);
        //[self.view addSubview: self.modal.view];
        [self.dimVC.view addSubview: self.modal.view];
        
        NSLog(@"self.view.bounds: %@", NSStringFromCGRect(self.view.bounds));
        
        NSLog(@"Screen Bounds: %@", NSStringFromCGRect([[UIScreen mainScreen] bounds]));
        
        [UIView animateWithDuration: 0.3 animations:^{
            NSUInteger yAxis;
            
            if (numOfRows * kCellHeightForReorder > kViewHeightForReorder) {
                yAxis = 40;
            } else {
                yAxis = kViewHeightForReorder - numOfRows * kCellHeightForReorder;
            }
            
            NSUInteger kRowHeight = numOfRows * kCellHeightForReorder;
            
            /*
            if (kRowHeight >= kViewHeight) {
                //kRowHeight = kViewHeight;
            }
            */
            NSLog(@"yAxis: %lu", (unsigned long)yAxis);
            NSLog(@"kRowHeight: %lu", (unsigned long)kRowHeight);
            
            self.modal.view.frame = CGRectMake(0, yAxis, 320, kRowHeight);
            //self.modal.view.frame = CGRectMake(0, numOfRows * kRowHeight, 320, numOfRows * kRowHeight);
            NSLog(@"self.modal.view.frame: %@", NSStringFromCGRect(self.modal.view.frame));
        } completion:^(BOOL finished) {
            //[self.modal didMoveToParentViewController: self];
            [self.modal didMoveToParentViewController: self.dimVC];
        }];
    }
    /*
    else {
        NSLog(@"self.childViewControllers.count != 0");
        [UIView animateWithDuration: 0.3 animations:^{
            self.modal.view.frame = CGRectMake(0, kViewHeightForReorder, 320, kCellHeightForReorder);
        } completion:^(BOOL finished) {
            [self.modal.view removeFromSuperview];
            [self.modal removeFromParentViewController];
        }];
    }
     */
}

/*
- (void)dismissModalView
{
    [UIView animateWithDuration: 0.3 animations:^{
        self.modal.view.frame = CGRectMake(0, kViewHeightForReorder, 320, kCellHeightForReorder);
    } completion:^(BOOL finished) {
        [self.modal.view removeFromSuperview];
        [self.modal removeFromParentViewController];
    }];
}
*/

- (void)showPreviewPageSetupVC
{
    modalVC = @"PreviewPageSetupVC";
    
    if (self.childViewControllers.count == 0) {
        NSLog(@"self.childViewControllers.count == 0");
        
        previewPageVC = [[UIStoryboard storyboardWithName: @"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"PreviewPageSetupViewController"];
        previewPageVC.imageArray = ImageDataArr;
        previewPageVC.albumId = self.albumid;
        previewPageVC.delegate = self;
        
        NSLog(@"ImageDataArr.count: %lu", (unsigned long)ImageDataArr.count);
        NSLog(@"ImageDataArr.count / 4: %lu", ImageDataArr.count / 4);
        NSLog(@"ImageDataArr.count remainder divided by 4 : %lu", ImageDataArr.count % 4);
        
        NSLog(@"1 / 4: %d", 1 / 4);
        
        NSUInteger numOfRows = 0;
        
        if (ImageDataArr.count / 4 == 0) {
            numOfRows = 1;
        } else if (ImageDataArr.count / 4 >= 1) {
            if (ImageDataArr.count % 4 == 0) {
                numOfRows = ImageDataArr.count / 4;
            } else if (ImageDataArr.count % 4 > 0) {
                numOfRows = ImageDataArr.count / 4;
                numOfRows += 1;
            }
        }
        
        NSLog(@"numOfRows: %lu", (unsigned long)numOfRows);
        
        //[self.view addSubview: self.dimVC.view];
        [self.tabBarController.view addSubview: self.dimVC.view];
        
        self.modal = previewPageVC;
        //[self addChildViewController: self.modal];
        [self.dimVC addChildViewController: self.modal];
        
        self.modal.view.backgroundColor = [UIColor whiteColor];
        self.modal.view.frame = CGRectMake(0, kViewHeightForPreview, 320, kCellHeightForPreview);
        //[self.view addSubview: self.modal.view];
        [self.dimVC.view addSubview: self.modal.view];
        
        NSLog(@"self.view.bounds: %@", NSStringFromCGRect(self.view.bounds));
        
        NSLog(@"Screen Bounds: %@", NSStringFromCGRect([[UIScreen mainScreen] bounds]));
        
        [UIView animateWithDuration: 0.3 animations:^{
            NSUInteger yAxis;
            
            if (numOfRows * kCellHeightForPreview > kViewHeightForPreview) {
                yAxis = 40;
            } else {
                yAxis = kViewHeightForPreview - numOfRows * kCellHeightForPreview;
            }
            
            NSUInteger kRowHeight = numOfRows * kCellHeightForPreview;
            
            /*
             if (kRowHeight >= kViewHeight) {
             //kRowHeight = kViewHeight;
             }
             */
            NSLog(@"yAxis: %lu", (unsigned long)yAxis);
            NSLog(@"kRowHeight: %lu", (unsigned long)kRowHeight);
            
            self.modal.view.frame = CGRectMake(0, yAxis, 320, kRowHeight);
            //self.modal.view.frame = CGRectMake(0, numOfRows * kRowHeight, 320, numOfRows * kRowHeight);
            NSLog(@"self.modal.view.frame: %@", NSStringFromCGRect(self.modal.view.frame));
        } completion:^(BOOL finished) {
            //[self.modal didMoveToParentViewController: self];
            [self.modal didMoveToParentViewController: self.dimVC];
        }];
    }
}

#pragma mark - ReorderViewControllerDelegate Method
- (void)reorderViewControllerDisappear:(ReorderViewController *)controller imageArray:(NSMutableArray *)ImageArray
{
    ImageDataArr = ImageArray;
    [self.dimVC.view removeFromSuperview];
}

- (void)reorderViewControllerDisappearAfterCalling:(ReorderViewController *)controller
{
    NSLog(@"reorderViewControllerDisappear");
    
    //NSLog(@"ImageArray: %@", ImageArray);
    
    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
    style.messageColor = [UIColor whiteColor];
    style.backgroundColor = [UIColor colorWithRed: 0.0/255.0
                                            green: 150.0/255.0
                                             blue: 136.0/255.0
                                            alpha: 1.0];
    [self.view makeToast: @"修改成功"
                duration: 2.0
                position: CSToastPositionBottom
                   style: style];
    
    [self myshowimage];
    [self.dataCollectionView reloadData];
}

#pragma mark - PreviewPageSetupViewControllerDelegate Method
- (void)previewPageSetupViewControllerDisappear:(PreviewPageSetupViewController *)controller
{
    [self.dimVC.view removeFromSuperview];
}

- (void)previewPageSetupViewControllerDisappearAfterCalling:(PreviewPageSetupViewController *)controller modifySuccess:(BOOL)modifySuccess imageArray:(NSMutableArray *)ImageArray
{
    ImageDataArr = ImageArray;
    
    if (modifySuccess) {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor colorWithRed: 0.0/255.0
                                                green: 150.0/255.0
                                                 blue: 136.0/255.0
                                                alpha: 1.0];
        [self.view makeToast: @"修改成功"
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
    }
}

#pragma mark - Custom Error Alert Method
- (void)showCustomErrorAlert: (NSString *)msg {
    [UIViewController showCustomErrorAlertWithMessage:msg onButtonTouchUpBlock:^(CustomIOSAlertView *customAlertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[customAlertView tag]);
        [customAlertView close];
    }];
    
}
/*
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
*/
@end
