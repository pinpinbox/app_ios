//
//  AlbumCreationViewController.m
//  wPinpinbox
//
//  Created by David on 4/23/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "AlbumCreationViewController.h"
#import "AlbumCollectionViewController.h"
#import "O_drag.h"
#import "PhotosViewController.h"
#import "wTools.h"
#import "boxAPI.h"
#import "AsyncImageView.h"
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
#import "OldCustomAlertView.h"
#import <SafariServices/SafariServices.h>
#import "ProgressView.h"
#import "AppDelegate.h"
#import <Photos/Photos.h>
#import "UIImage+Extras.h"
#import "MBProgressHUD.h"
#import "UIView+Toast.h"
#import "UIColor+Extensions.h"
#import "MyLinearLayout.h"
#import "SetupMusicViewController.h"
#import "AlbumSettingViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "BFPaperButton.h"
#import <CoreMotion/CoreMotion.h>
#import "GlobalVars.h"
#import "DDAUIActionSheetViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AlbumDetailViewController.h"

#import "UIViewController+ErrorAlert.h"

#import "NewCooperationViewController.h"

#define kWidthForUpload 720
#define kHeightForUpload 960

//#define kCellHeightForReorder 150
//#define kViewHeightForReorder 504
#define kCellHeightForReorder 150
#define kViewHeightForReorder 568

//#define kCellHeightForPreview 170
//#define kViewHeightForPreview 504
#define kCellHeightForPreview 130
#define kViewHeightForPreview 568

static void *AVPlayerDemoPlaybackViewControllerRateObservationContext = &AVPlayerDemoPlaybackViewControllerRateObservationContext;
static void *AVPlayerDemoPlaybackViewControllerStatusObservationContext = &AVPlayerDemoPlaybackViewControllerStatusObservationContext;
static void *AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext = &AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext;

@interface AlbumCreationViewController () <UICollectionViewDataSource, UICollectionViewDelegate, PhotosViewDelegate, UIGestureRecognizerDelegate, AVAudioRecorderDelegate, ChooseVideoViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, ReorderViewControllerDelegate, PreviewPageSetupViewControllerDelegate, SetupMusicViewControllerDelegate, SFSafariViewControllerDelegate, TemplateViewControllerDelegate, DDAUIActionSheetViewControllerDelegate>
{
    __weak IBOutlet UIButton *refreshBtn;
    __weak IBOutlet UIButton *conbtn;
    __weak IBOutlet UIButton *settingBtn;
    __weak IBOutlet UIButton *nextBtn;
    
    //    __weak IBOutlet UIButton *adobeEidt;
    __weak IBOutlet BFPaperButton *recordPausePlayBtn;
    
    __weak IBOutlet UIView *textBgView;
    __weak IBOutlet UIButton *addTextBtn;
    __weak IBOutlet UIButton *deleteTextBtn;
    
    __weak IBOutlet UIView *audioBgView;
    __weak IBOutlet UIButton *deleteAudioBtn;
    __weak IBOutlet UIButton *deleteImageBtn;
    
    NSMutableArray *ImageDataArr;
    NSInteger selectItem;
    
    UIImageView *Oimageview;
    O_drag *oview;
    
    UIImage *selectimage;
    
    NSInteger *nextItem;
    NSString *identity;
    
    AVAudioRecorder *recorder;
    //AVAudioPlayer *player;
    //AVPlayer *avPlayer;
    
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
    
    NSTimer *rippleTimer;
    
    BOOL isRecordingAudio;
    BOOL isPlayingAudio;
    
    BOOL isViewDidLoad;
    
    NSInteger viewHeightForPreview;
}

@property (strong, nonatomic) AVPlayer *avPlayer;
@property (strong, nonatomic) AVPlayerItem *avPlayerItem;
@property (assign, nonatomic) BOOL isReadyToPlay;

@property (strong, nonatomic) NSString *audioMode;;

@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarHeight;
@property (weak, nonatomic) IBOutlet UIView *ShowView;

@property (weak, nonatomic) IBOutlet UICollectionView *dataCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *titlelabel;

//@property (weak, nonatomic) ProgressView *progressView;

@property (strong, nonatomic) NSArray <NSString *> *types;
//@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@property (strong, nonatomic) NSOperationQueue *queue;

@property (strong, nonatomic) UIViewController *dimVC;
@property (strong, nonatomic) UIViewController *modal;

@property (nonatomic) DDAUIActionSheetViewController *customAddActionSheet;
@property (nonatomic) DDAUIActionSheetViewController *customVideoActionSheet;
@property (nonatomic) DDAUIActionSheetViewController *customSettingActionSheet;
@property (nonatomic) UIVisualEffectView *effectView;

@end

@implementation AlbumCreationViewController
#pragma mark - View Related Methods
-(void)reloaddatat:(NSMutableArray *)data{
    NSLog(@"reloaddatat");
    ImageDataArr = [data mutableCopy];
    NSLog(@"ImageDataArr: %@", ImageDataArr);
}

-(void)reloadItem:(NSInteger )item{
    NSLog(@"reloadItem");
    selectItem = item;
    NSLog(@"selectItem: %ld", (long)selectItem);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"");
    NSLog(@"AlbumCreationViewController viewDidLoad");
    
    NSLog(@"self.choice: %@", self.choice);
    NSLog(@"self.postMode: %d", self.postMode);
    NSLog(@"self.templateid: %@", self.templateid);
    NSLog(@"self.selectrow: %ld", (long)self.selectrow);
    NSLog(@"self.prefixText: %@", self.prefixText);
    NSLog(@"self.specialUrl: %@", self.specialUrl);
    
    [wTools sendScreenTrackingWithScreenName:@"編輯器"];
    viewHeightForPreview = [UIScreen mainScreen].bounds.size.height;
    
    textBgView.backgroundColor = [UIColor whiteColor];
    textBgView.layer.cornerRadius = 16;
    
    audioBgView.backgroundColor = [UIColor whiteColor];
    audioBgView.layer.cornerRadius = 16;
    
    self.modal.view.backgroundColor = [UIColor whiteColor];
    
    //isKbShowing = NO;
    
    self.dataCollectionView.showsHorizontalScrollIndicator = NO;
    
    // Notification for dismissing keyboard
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleEnteredBackground) name: UIApplicationDidEnterBackgroundNotification object: nil];
    
    isRecordingAudio = NO;
    isPlayingAudio = NO;
    isRecorded = NO;
    
//    conbtn.hidden = YES;
//    refreshBtn.hidden = YES;
    
    nextBtn.layer.cornerRadius = kCornerRadius;
    //    adobeEidt.layer.cornerRadius = adobeEidt.bounds.size.width / 2;
    //    adobeEidt.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    
    addTextBtn.layer.cornerRadius = addTextBtn.bounds.size.width / 2;
    addTextBtn.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    
    recordPausePlayBtn.layer.cornerRadius = recordPausePlayBtn.bounds.size.width / 2;
    recordPausePlayBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    recordPausePlayBtn.myWidth = 35;
    recordPausePlayBtn.myHeight = 35;
    
    recordPausePlayBtn.isRaised = NO;
    recordPausePlayBtn.rippleFromTapLocation = NO;
    recordPausePlayBtn.rippleBeyondBounds = YES;
    recordPausePlayBtn.tapCircleDiameter = MAX(recordPausePlayBtn.frame.size.width, recordPausePlayBtn.frame.size.height) * 1.3;
    
    deleteImageBtn.layer.cornerRadius = deleteImageBtn.bounds.size.width / 2;
    deleteImageBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    
    NSLog(@"self.shareCollection: %d", self.shareCollection);
    
    if (self.shareCollection) {
        [nextBtn setTitle: @"完成" forState: UIControlStateNormal];
        //[self.nextBtn addTarget: self action: @selector(back:) forControlEvents: UIControlEventTouchUpInside];
        [nextBtn addTarget: self action: @selector(backBtnPress:) forControlEvents: UIControlEventTouchUpInside];
    } else {
        [nextBtn setTitle: @"下一步" forState: UIControlStateNormal];
        [nextBtn addTarget: self action: @selector(save:) forControlEvents: UIControlEventTouchUpInside];
    }
    
    if ([self.userIdentity isEqualToString:@"editor"] || [self.userIdentity isEqualToString: @"approver"]) {
        [nextBtn setTitle: @"完成" forState: UIControlStateNormal];
    } else {
        [nextBtn setTitle: @"下一步" forState: UIControlStateNormal];
    }
    
    //[[_ShowView layer] setMasksToBounds:YES];
    
    if (_imagedata==nil) {
        ImageDataArr=[NSMutableArray new];
        
        audioBgView.hidden = YES;
        deleteAudioBtn.hidden = YES;
        
        textBgView.hidden = YES;
        deleteTextBtn.hidden = YES;
    }
    
    //    NSString* const CreativeSDKClientId = @"9acbf5b342a8419584a67069e305fa39";
    //    NSString* const CreativeSDKClientSecret = @"b4d92522-49ac-4a69-9ffe-eac1f494c6fc";
    //    [[AdobeUXAuthManager sharedManager] setAuthenticationParametersWithClientID:CreativeSDKClientId clientSecret:CreativeSDKClientSecret enableSignUp:true];
    //
    //    //The authManager caches our login, so check on startup
    //    BOOL loggedIn = [AdobeUXAuthManager sharedManager].authenticated;
    //
    //    if(loggedIn) {
    //        [[AdobeUXAuthManager sharedManager] logout:nil onError:nil];
    //        AdobeAuthUserProfile *up = [AdobeUXAuthManager sharedManager].userProfile;
    //        NSLog(@"User Profile: %@", up);
    //    }
    
    [self audioSetUp];
    [self photoSetup];
    
    // For Reorder & PreviewPage Setting Methods
    self.dimVC = [[UIViewController alloc] init];
    self.dimVC.view.frame = [[UIScreen mainScreen] bounds];
    self.dimVC.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent: 0.6f];
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleTapGesture:)];
    //[self.ShowView addGestureRecognizer: tapGR];
    [self.dimVC.view addGestureRecognizer: tapGR];
    
    modalVC = @"";
    
    NSLog(@"self.dimVC.view: %@", NSStringFromCGRect(self.dimVC.view.frame));
    
    // For checking whether should present actionSheet options or not
    isViewDidLoad = YES;
    
    
    // CustomActionSheet
    self.customAddActionSheet = [[DDAUIActionSheetViewController alloc] init];
    self.customAddActionSheet.delegate = self;
    self.customAddActionSheet.topicStr = @"為作品新增相片/影片";
    
    self.customVideoActionSheet = [[DDAUIActionSheetViewController alloc] init];
    self.customVideoActionSheet.delegate = self;
    self.customVideoActionSheet.topicStr = @"請選擇影片模式(限時30秒)";
    
    self.customSettingActionSheet = [[DDAUIActionSheetViewController alloc] init];
    self.customSettingActionSheet.delegate = self;
    self.customSettingActionSheet.topicStr = @"作品設定";
    
    // Add Long Press Gesture to collecitonView
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget: self action: @selector(handleLongPress:)];
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    [self.dataCollectionView addGestureRecognizer: lpgr];
    
    [self reload:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"");
    NSLog(@"AlbumCreationViewController");
    NSLog(@"viewWillAppear");
    
    [self enableButton];
    [self.dataCollectionView reloadData];
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
                self.navBarHeight.constant = navBarHeightConstant;
                break;
            default:
                printf("unknown");
                break;
        }
    }
}

#pragma mark - handleEnteredBackground
- (void)handleEnteredBackground
{
    NSLog(@"handleEnteredBackground");
    [textV resignFirstResponder];
}

#pragma mark - handleTapGesture
- (void)handleTapGesture: (UITapGestureRecognizer *)gestureRecognizer
{
    NSLog(@"handleTapGesture");
    
    if ([modalVC isEqualToString: @"ReorderVC"]) {
        [reorderVC callBackButtonFunction];
    } else if ([modalVC isEqualToString: @"PreviewPageSetupVC"]) {
        [previewPageVC callBackButtonFunction];
    }
}

#pragma mark - IBAction Methods
- (IBAction)settingBtnPress:(id)sender {
    if (![self.userIdentity isEqualToString: @"admin"]) {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor thirdPink];

        [self.view makeToast: @"權限不足"
                    duration: 1.0
                    position: CSToastPositionBottom
                       style: style];
        return;
    }
    
    [wTools setStatusBarBackgroundColor: [UIColor clearColor]];
    
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleDark];
    
    [UIView animateWithDuration: kAnimateActionSheet animations:^{
        self.effectView = [[UIVisualEffectView alloc] initWithEffect: blurEffect];
    }];
    
    self.effectView.frame = self.view.frame;
    self.effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.effectView.myLeftMargin = self.effectView.myRightMargin = 0;
    self.effectView.myTopMargin = self.effectView.myBottomMargin = 0;
    self.effectView.alpha = 0.8;
    
    [self.view addSubview: self.effectView];
    
    // CustomActionSheet Setting
    [self.view addSubview: self.customSettingActionSheet.view];
    [self.customSettingActionSheet viewWillAppear: NO];
    
    [self.customSettingActionSheet addSelectItem: @"" title: @"排序作品" btnStr: @"" tagInt: 1 identifierStr: @"reorder"];
    [self.customSettingActionSheet addSelectItem: @"" title: @"選擇預覽頁" btnStr: @"" tagInt: 2 identifierStr: @"choosePreview"];
    [self.customSettingActionSheet addSelectItem: @"" title: @"設定音樂" btnStr: @"" tagInt: 3 identifierStr: @"setupMusic"];
    
    __weak typeof(self) weakSelf = self;
    self.customSettingActionSheet.customViewBlock = ^(NSInteger tagId, BOOL isTouchDown, NSString *identifierStr) {
        NSLog(@"self.customSettingActionSheet.customViewBlock");
        NSLog(@"tagId: %ld", (long)tagId);
        NSLog(@"isTouchDown: %d", isTouchDown);
        NSLog(@"identifierStr: %@", identifierStr);
        __strong typeof(weakSelf) stSelf = weakSelf;
        if ([identifierStr isEqualToString: @"reorder"]) {
            if (stSelf->ImageDataArr.count > 0) {
                [stSelf showReorderVC];
            } else if (stSelf->ImageDataArr.count == 0) {
                CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                style.messageColor = [UIColor whiteColor];
                style.backgroundColor = [UIColor thirdPink];
                
                [weakSelf.view makeToast: @"作品數量多於1項才可編排順序"
                                duration: 2.0
                                position: CSToastPositionBottom
                                   style: style];
            }
        } else if ([identifierStr isEqualToString: @"choosePreview"]) {
            if (stSelf->ImageDataArr.count > 0) {
                [stSelf showPreviewPageSetupVC];
            } else if (stSelf->ImageDataArr.count == 0) {
                CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                style.messageColor = [UIColor whiteColor];
                style.backgroundColor = [UIColor thirdPink];
                
                [weakSelf.view makeToast: @"作品內沒有內容"
                                duration: 2.0
                                position: CSToastPositionBottom
                                   style: style];
            }
        } else if ([identifierStr isEqualToString: @"setupMusic"]) {
            SetupMusicViewController *setupMusicVC = [[UIStoryboard storyboardWithName: @"SetupMusicVC" bundle: nil] instantiateViewControllerWithIdentifier: @"SetupMusicViewController"];
            setupMusicVC.delegate = weakSelf;
            
            NSLog(@"");
            NSLog(@"Calling SetupMusicVC");
            NSLog(@"audioMode: %@", weakSelf.audioMode);
            setupMusicVC.audioMode = weakSelf.audioMode;
            setupMusicVC.albumId = weakSelf.albumid;
            [weakSelf presentViewController: setupMusicVC animated: YES completion: nil];
        }
    };
}

- (IBAction)backBtnPress:(id)sender {
    CGSize iOSDeviceScreenSize = [UIScreen mainScreen].bounds.size;
    NSLog(@"iOSDeviceScreenSize: %@", NSStringFromCGSize(iOSDeviceScreenSize));
    
    // Check if the device screen is 3.5"
    if (iOSDeviceScreenSize.height == 480) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"" message: @"確定退出編輯器?" preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *okBtn = [UIAlertAction actionWithTitle: @"確定" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self removeObserAndNotificationAndRipple];
            
            //AlbumCollectionViewController *albumCollectionVC = [[UIStoryboard storyboardWithName: @"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumCollectionViewController"];
            AlbumCollectionViewController *albumCollectionVC = [[UIStoryboard storyboardWithName: @"AlbumCollectionVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumCollectionViewController"];
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate.myNav pushViewController: albumCollectionVC animated: YES];
        }];
        UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction: okBtn];
        [alert addAction: cancelBtn];
        
        [self presentViewController: alert animated: YES completion: nil];
    } else {
        [self showCustomAlert: @"確定退出編輯器?"];
    }
}

#pragma mark - Text Description Methods
- (IBAction)addText:(id)sender {
    NSLog(@"selectItem: %ld", (long)selectItem);
    NSString *userIdStr = ImageDataArr[selectItem][@"user_id"];
    
    if (![userIdStr isEqual: [NSNull null]]) {
        NSLog(@"userId is not null");
        if (![self.userIdentity isEqual: [NSNull null]]) {
            NSLog(@"self.userIdentity is not null");
            if ([self.userIdentity isEqualToString: @"admin"] || [userIdStr integerValue] == [[wTools getUserID] integerValue]) {
                [self showTextEditing];
            } else {
                CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                style.messageColor = [UIColor whiteColor];
                style.backgroundColor = [UIColor thirdPink];
                
                [self.view makeToast: @"只能操作你上傳的項目"
                            duration: 1.0
                            position: CSToastPositionBottom
                               style: style];
                return;
            }
        }
    }
}

- (IBAction)deleteText:(id)sender {
    NSString *userIdStr = ImageDataArr[selectItem][@"user_id"];
    
    if (![userIdStr isEqual: [NSNull null]]) {
        NSLog(@"userId is not null");
        if (![self.userIdentity isEqual: [NSNull null]]) {
            NSLog(@"self.userIdentity is not null");
            if ([self.userIdentity isEqualToString: @"admin"] || [userIdStr integerValue] == [[wTools getUserID] integerValue]) {
                [self showCustomAlertForText: @"確定刪除本頁敘述"];
            } else {
                CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                style.messageColor = [UIColor whiteColor];
                style.backgroundColor = [UIColor thirdPink];
                
                [self.view makeToast: @"只能操作你上傳的項目"
                            duration: 1.0
                            position: CSToastPositionBottom
                               style: style];
                return;
            }
        }
    }
}

- (void)addTextDescriptionView {
    MyLinearLayout *vertLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Vert];
    vertLayout.myLeftMargin = vertLayout.myRightMargin = 0;
    vertLayout.myBottomMargin = 0;
    vertLayout.padding = UIEdgeInsetsMake(8, 8, 8, 8);
    vertLayout.backgroundColor = [UIColor blackColor];
    vertLayout.alpha = 0.8;
    
    UILabel *label = [UILabel new];
    label.wrapContentWidth = YES;
    label.wrapContentHeight = YES;
    label.text = textForDescription;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize: 12];
    label.numberOfLines = 6;
    label.myTopMargin = label.myBottomMargin = 0;
    label.myLeftMargin = label.myRightMargin = 0;
    
    [vertLayout addSubview: label];
    
    [_ShowView addSubview: vertLayout];
}

- (void)removeTextDescriptionView {
    NSLog(@"Check Subviews of ShowView");
    for (UIView *v in _ShowView.subviews) {
        NSLog(@"v: %@", v);
        
        if ([v isKindOfClass: [MyLinearLayout class]]) {
            NSLog(@"v isKindOfClass: %@", v);
            
            [v removeFromSuperview];
        }
    }
}

- (void)setUpTextAdding {
    NSLog(@"setUpTextAdding");
    
    NSMutableDictionary *settingsDic = [NSMutableDictionary new];
    [settingsDic setObject: textV.text forKey: @"description"];
    NSLog(@"textV.text: %@", textV.text);
    
    textForDescription = textV.text;
    
    @try {
        [self callUpdatePhotoOfDiyWithoutPhoto: textForDescription];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
}

- (void)callUpdatePhotoOfDiyWithoutPhoto: (NSString *)textStr {
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    __block AlbumCreationViewController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSString *response = @"";
        __strong typeof(weakSelf) stSelf = weakSelf;
        NSString *pid = [stSelf->ImageDataArr [stSelf->selectItem][@"photo_id"] stringValue];
        
        response = [boxAPI updatephotoofdiy: [wTools getUserID]
                                      token: [wTools getUserToken]
                                   album_id: stSelf.albumid
                                   photo_id: pid
                                      image: nil
                                    setting: textStr];
        
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
                NSLog(@"UpdatePhotoOfDiy");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"AlbumCollectionViewController");
                    NSLog(@"callUpdatePhotoOfDiyWithoutPhoto");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"callUpdatePhotoOfDiyWithoutPhoto"
                                         textStr: textStr
                                            data: nil
                                           image: nil
                                         jsonStr: @""
                                       audioMode: @""
                                          option: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        stSelf->ImageDataArr = [NSMutableArray arrayWithArray:dic[@"data"][@"photo"]];
                        stSelf->textForDescription = stSelf->ImageDataArr[stSelf->selectItem][@"description"];
                        
                        if ([stSelf->textForDescription isEqualToString: @""]) {
                            stSelf->textBgView.hidden = YES;
                            stSelf->deleteTextBtn.hidden = YES;
                            
                            [self removeTextDescriptionView];
                        } else {
                            stSelf->textBgView.hidden = NO;
                            stSelf->deleteTextBtn.hidden = NO;
                            
                            [stSelf removeTextDescriptionView];
                            [stSelf addTextDescriptionView];
                        }
                    } else if ([dic[@"result"] boolValue] == 0) {
                        NSLog(@"callUpdatePhotoOfDiyWithoutPhoto return result is 0");
                        [stSelf showPermission];
                    } else {
                        [stSelf showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}

#pragma mark - TextView Delegate Methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    NSLog(@"textViewShouldBeginEditing");
    NSLog(@"textView.text: %@", textView.text);
    NSLog(@"textForDescription: %@", textForDescription);
    
    if (![textView.text isEqualToString: @""]) {
        // Check when if there are some texts in the textView haven't been saved
        // display the text
        textV.text = textView.text;
    } else {
        // If there is a data from server then display it
        textV.text = textForDescription;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"textViewDidChange");
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSLog(@"textViewDidEndEditing");
    NSLog(@"textView: %@", textView);
}

- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    NSLog(@"shouldChangeTextInRange");
    NSLog(@"range.length: %lu", (unsigned long)range.length);
    
    if (range.length == 0) {
        if ([text isEqualToString: @"\n"]) {
            NSLog(@"textView.text: %@", textView.text);
            textView.text = [NSString stringWithFormat: @"%@\n", textView.text];
            return NO;
        }
    }
    return YES;
}

#pragma mark - Audio Related Methods
- (void)audioSetUp {
    NSLog(@"");
    NSLog(@"audioSetUp");
    
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
    
    self.isReadyToPlay = NO;
}

- (IBAction)recordPausePlayTapped:(id)sender {
    NSLog(@"");
    NSLog(@"recordPausePlayTapped");
    
    NSLog(@"selectItem: %ld", (long)selectItem);
    NSString *userIdStr = ImageDataArr[selectItem][@"user_id"];
    
    // If user doesn't have permission, they still can play audio, but can't modfity it.
    if (![audio_url isKindOfClass: [NSNull class]]) {
        if (![audio_url isEqualToString: @""]) {
            NSLog(@"audio_url is not empty");
            NSLog(@"play stream audio");
            [self checkAudioStatus];
        } else {
            if (![userIdStr isEqual: [NSNull null]]) {
                NSLog(@"userId is not null");
                if (![self.userIdentity isEqual: [NSNull null]]) {
                    NSLog(@"self.userIdentity is not null");
                    if ([self.userIdentity isEqualToString: @"admin"] || [userIdStr integerValue] == [[wTools getUserID] integerValue]) {
                        [self checkAudioStatus];
                    } else {
                        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                        style.messageColor = [UIColor whiteColor];
                        style.backgroundColor = [UIColor thirdPink];
                        
                        [self.view makeToast: @"只能操作你上傳的項目"
                                    duration: 1.0
                                    position: CSToastPositionBottom
                                       style: style];
                        return;
                    }
                }
            }
        }
    } else {
        if (![userIdStr isEqual: [NSNull null]]) {
            NSLog(@"userId is not null");
            if (![self.userIdentity isEqual: [NSNull null]]) {
                NSLog(@"self.userIdentity is not null");
                if ([self.userIdentity isEqualToString: @"admin"] || [userIdStr integerValue] == [[wTools getUserID] integerValue]) {
                    [self checkAudioStatus];
                } else {
                    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                    style.messageColor = [UIColor whiteColor];
                    style.backgroundColor = [UIColor thirdPink];
                    
                    [self.view makeToast: @"只能操作你上傳的項目"
                                duration: 1.0
                                position: CSToastPositionBottom
                                   style: style];
                    return;
                }
            }
        }
    }
}

- (void)checkAudioStatus {
    [self disableRecordAndPlayBtn];
    
    NSLog(@"self.audioMode: %@", self.audioMode);
    
    if ([self.audioMode isEqualToString: @"singular"]) {
        NSLog(@"self.audioMode isEqualToString singular");
        
        NSString *msg = @"當 前 播 放 模 式 為 作 品 單 一 的 背 景 音 樂 ， 確 定 要 切 換 成 每 頁 的 錄 音 嗎 ？ (此動作會移除背景音樂唷)";
        [self showCustomAudioModeCheckAlert: msg];
    } else if ([self.audioMode isEqualToString: @"plural"] || [self.audioMode isEqualToString: @"none"]) {
        NSLog(@"self.audioMode isEqualToString plural or none");
        [self recordingAudio];
    }
}

- (void)disableRecordAndPlayBtn {
    NSLog(@"disableRecordAndPlayBtn");
    recordPausePlayBtn.userInteractionEnabled = NO;
}

- (void)enableRecordAndPlayBtn {
    NSLog(@"enableRecordAndPlayBtn");
    __block AlbumCreationViewController *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"enableRecordAndPlayBtn in get_main_queue");
        __strong typeof(weakSelf) stSelf = weakSelf;
        stSelf->recordPausePlayBtn.userInteractionEnabled = YES;
    });
}

- (void)recordingAudio {
    NSLog(@"");
    NSLog(@"recordingAudio");
    
    NSLog(@"");
    [self checkAudio];
    
    NSLog(@"");
    [self disableButton];
    
    NSLog(@"");
    NSLog(@"recorder.recording: %d", recorder.recording);
    
    // Setup audio session again to avoid recorder.recording state always return FALSE
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
    
    if (audioGranted) {
        if (!isRecorded) {
            NSLog(@"");
            NSLog(@"");
            NSLog(@"is not recorded yet");
            
            if (!recorder.recording) {
                [session setActive: YES error: nil];
                
                // Start recording
                NSLog(@"");
                NSLog(@"Start recording");
                [recorder record];
                [recordPausePlayBtn setImage: [UIImage imageNamed: @"ic200_recording_white.png"] forState: UIControlStateNormal];
                isRecordingAudio = YES;
                recordPausePlayBtn.tapCircleColor = [UIColor secondPink];
                
                [self activateRipple];
            } else {
                [session setActive: NO error: nil];
                
                // Stop recording
                NSLog(@"");
                NSLog(@"Stop Recording");
                [recorder stop];
                //isRecordingAudio = NO;
                recordPausePlayBtn.tapCircleColor = [UIColor clearColor];
                
                if ([self.audioMode isEqualToString: @"none"]) {
                    [self changeAudioMode: @"plural"];
                }
            }
        } else if (isRecorded) {
            NSLog(@"");
            NSLog(@"");
            NSLog(@"is recorded already");
            [self playTapped];
            recordPausePlayBtn.tapCircleColor = [UIColor secondMain];
        }
    } else {
        [self enableRecordAndPlayBtn];
        [self showNoAccessAlertAndCancel: @"audio"];
    }
}

- (void)playTapped {
    NSLog(@"");
    NSLog(@"");
    NSLog(@"playTapped");
    
    if ((self.avPlayer.rate != 0) && self.avPlayer.error == nil) {
        NSLog(@"");
        NSLog(@"Is Playing Music");
        [self.avPlayer pause];
        [self.avPlayer seekToTime: kCMTimeZero];
        
        isPlayingAudio = NO;
        
        [self stopRipple];
        
        return;
    }
    
    if (![audio_url isKindOfClass: [NSNull class]]) {
        if (![audio_url isEqualToString: @""]) {
            NSLog(@"audio_url is not empty");
            NSLog(@"play stream audio");
            
            [self avPlayerSetUp: audio_url];
        }
    }
}

// Check Audio Access Permission
- (void)checkAudio {
    NSLog(@"checkAudio");
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType: AVMediaTypeAudio];
    NSLog(@"authStatus: %ld", (long)authStatus);
    
    if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        //[wTools showAlertTile:NSLocalizedString(@"PicText-tipAccessPrivacy", @"") Message:@"" ButtonTitle:nil];
        [self showNoAccessAlertAndCancel: @"audio"];
        audioGranted = NO;
    } else {
        audioGranted = YES;
    }
}

// Error Handling - Preparing Assets for Playback Failed

/* --------------------------------------------------------------
 **  Called when an asset fails to prepare for playback for any of
 **  the following reasons:
 **
 **  1) values of asset keys did not load successfully,
 **  2) the asset keys did load successfully, but the asset is not
 **     playable
 **  3) the item did not become ready to play.
 ** ----------------------------------------------------------- */

-(void)assetFailedToPrepareForPlayback:(NSError *)error
{
    NSLog(@"");
    NSLog(@"assetFailedToPrepareForPlayback");
}

// AVPlayer Section
- (void)avPlayerSetUp: (NSString *)audioDataStr
{
    NSLog(@"avPlayerSetUp");
    
    //註冊audioInterrupted
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(audioInterrupted:) name: AVAudioSessionInterruptionNotification object: nil];
    
    //self.avPlayer = [[AVPlayer alloc] initWithURL: audioUrl];
    //avPlayer = player;
    
    // 1. Set Up URL Audio Source
    NSURL *audioUrl = [NSURL URLWithString: audioDataStr];
    
    // 2. PlayItem Setup
    //self.playerItem = [AVPlayerItem playerItemWithURL: audioUrl];
    // Setting AVAsset & AVPlayerItem this way can avoid crash
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL: audioUrl options: nil];
    //AVAsset *asset = [AVURLAsset URLAssetWithURL: audioUrl options: nil];
    //AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset: asset];
    
    NSArray *requestedKeys = @[@"playable"];
    
    // Tells the asset to load the values of any of the specified keys that are not already loaded.
    [asset loadValuesAsynchronouslyForKeys: requestedKeys completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            // IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem.
            [self prepareToPlayAsset:asset withKeys:requestedKeys];
        });
    }];
}

// Audio Interrupted
-(void)audioInterrupted:(NSNotification *)notification{
    NSLog(@"");
    NSLog(@"audioInterrupted");
    NSUInteger type=[notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
    NSUInteger option=[notification.userInfo[AVAudioSessionInterruptionOptionKey]intValue];
    
    if (type == AVAudioSessionInterruptionTypeBegan) {
        NSLog(@"中斷音樂");
    }else if (type==AVAudioSessionInterruptionTypeBegan){
        if (option == AVAudioSessionInterruptionTypeEnded) {
            NSLog(@"中斷恢復");
            
            if (self.isReadyToPlay) {
                [NSThread sleepForTimeInterval: 0.1];
                [self.avPlayer play];
            }
        }
    }
}

// Prepare to play asset, URL
/*
 Invoked at the completion of the loading of the values for all keys on the asset that we require.
 Checks whether loading was successfull and whether the asset is playable.
 If so, sets up an AVPlayerItem and an AVPlayer to play the asset.
 */
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys
{
    NSLog(@"");
    NSLog(@"prepareToPlayAsset");
    
    /* Make sure that the value of each key has loaded successfully. */
    for (NSString *thisKey in requestedKeys)
    {
        //NSLog(@"");
        //NSLog(@"thisKey: %@", thisKey);
        
        NSError *error = nil;
        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
        //NSLog(@"keyStatus: %ld", (long)keyStatus);
        
        if (keyStatus == AVKeyValueStatusFailed)
        {
            NSLog(@"keyStatus == AVKeyValueStatusFailed");
            [self assetFailedToPrepareForPlayback:error];
            return;
        }
        /* If you are also implementing -[AVAsset cancelLoading], add your code here to bail out properly in the case of cancellation. */
    }
    
    // Use the AVAsset playable property to detect whether the asset can be played.
    if (!asset.playable)
    {
        NSLog(@"");
        NSLog(@"asset.playable: %d", asset.playable);
        
        /* Generate an error describing the failure. */
        NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
        NSString *localizedFailureReason = NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   localizedDescription, NSLocalizedDescriptionKey,
                                   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
                                   nil];
        NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
        
        // Display the error to the user.
        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
        
        return;
    }
    
    if (self.avPlayerItem) {
        NSLog(@"self.avPlayerItem Existed");
        NSLog(@"self.avPlayerItem removeObserver: self forKeyPath: status");
        @try {
            [self.avPlayerItem removeObserver: self
                                   forKeyPath: @"status"];
            
            NSLog(@"NSNotificationCenter removeObserver");
            [[NSNotificationCenter defaultCenter] removeObserver: self
                                                            name: AVPlayerItemDidPlayToEndTimeNotification
                                                          object: self.avPlayerItem];
        } @catch (NSException *exception) {
            // Print exception information
            NSLog( @"NSException caught" );
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
            return;
        }
        
    }
    
    
    //NSLog(@"self.avPlayerItem = [AVPlayerItem playerItemWithAsset: asset]");
    self.avPlayerItem = [AVPlayerItem playerItemWithAsset: asset];
    
    //NSLog(@"self.avPlayerItem addObserver: self forKeyPath: status");
    [self.avPlayerItem addObserver: self
                        forKeyPath: @"status"
                           options: NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                           context: AVPlayerDemoPlaybackViewControllerStatusObservationContext];
    
    if (self.avPlayer != nil) {
        //[self.avPlayer removeObserver: self forKeyPath: @"status"];
        NSLog(@"self.avPlayer != nil");
    }
    
    // To avoid the syncScrubbing keep calling, so pause avPlayer
    NSLog(@"self.avPlayer pause");
    [self.avPlayer pause];
    
    NSLog(@"self.avPlayer = [AVPlayer playerWithPlayerItem: self.avPlayerItem]");
    self.avPlayer = [AVPlayer playerWithPlayerItem: self.avPlayerItem];
    
    self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    [self addNotification];
}

- (void)addNotification {
    NSLog(@"");
    NSLog(@"addNotification");
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(playerItemDidReachEnd:)
                                                 name: AVPlayerItemDidPlayToEndTimeNotification
                                               object: self.avPlayerItem];
}

- (void)removeNotification {
    NSLog(@"");
    NSLog(@"removeNotification");
    
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver: self name: UIApplicationDidEnterBackgroundNotification object: nil];
        [[NSNotificationCenter defaultCenter] removeObserver: self name: AVAudioSessionInterruptionNotification object: nil];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    NSLog(@"");
    NSLog(@"playerItemDidReachEnd");
    [self stopRipple];
    isPlayingAudio = NO;
}

- (void)removeObserAndNotificationAndRipple {
    NSLog(@"");
    NSLog(@"removeObserAndNotificationAndRipple");
    [self stopRipple];
    
    if (self.avPlayer != nil) {
        NSLog(@"self.avPlayer != nil");
        NSLog(@"remove observer");
        
        //[self.avPlayer removeObserver: self forKeyPath: @"status"];
        //[self.avPlayer removeObserver: self forKeyPath: @"rate"];
        //[self.avPlayer.currentItem removeObserver: self forKeyPath: @"status"];
        
        [self.avPlayer pause];
        
        @try {
            NSLog(@"NSNotificationCenter removeObserver");
            [[NSNotificationCenter defaultCenter] removeObserver: self name: AVPlayerItemDidPlayToEndTimeNotification object: self.avPlayerItem];
        } @catch (NSException *exception) {
            // Print exception information
            NSLog( @"NSException caught" );
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
            return;
        }
        
        self.avPlayer = nil;
    }
    if (self.avPlayerItem) {
        NSLog(@"self.avPlayerItem Existed");
        NSLog(@"self.avPlayerItem removeObserver: self forKeyPath: status");
        [self.avPlayerItem removeObserver: self
                               forKeyPath: @"status"];
        
        self.avPlayerItem = nil;
    }
    
    @try {
        [self removeNotification];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
}

// Ripple Effect Setting
- (void)activateRipple {
    NSLog(@"");
    NSLog(@"activateRipple");
    
    [self disableButton];
    [self enableRecordAndPlayBtn];
    
    [rippleTimer invalidate];
    rippleTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector: @selector(startRipple) userInfo: nil repeats: YES];
}

- (void)startRipple {
    NSLog(@"");
    NSLog(@"startRipple");
    [recordPausePlayBtn fadeInBackgroundAndRippleTapCircle];
    double delayInSeconds = 0.2;
    __weak typeof(self) weakSelf = self;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) stSelf = weakSelf;
        [stSelf->recordPausePlayBtn burstTapCircle];
    });
}

- (void)stopRipple {
    NSLog(@"stopRipple");
    [self enableButton];
    [rippleTimer invalidate];
    [self enableRecordAndPlayBtn];
}

- (IBAction)deleteAudio:(id)sender {
    NSString *userIdStr = ImageDataArr[selectItem][@"user_id"];

    if (![userIdStr isEqual: [NSNull null]]) {
        NSLog(@"userId is not null");
        if (![self.userIdentity isEqual: [NSNull null]]) {
            NSLog(@"self.userIdentity is not null");
            if ([self.userIdentity isEqualToString: @"admin"] || [userIdStr integerValue] == [[wTools getUserID] integerValue]) {
                [self showCustomAlertForAudio: @"確定刪除本頁錄音檔"];
            } else {
                CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                style.messageColor = [UIColor whiteColor];
                style.backgroundColor = [UIColor thirdPink];
                
                [self.view makeToast: @"只能操作你上傳的項目"
                            duration: 1.0
                            position: CSToastPositionBottom
                               style: style];
                return;
            }
        }
    }
}

// AVAudioRecorder Delegate Methods
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    NSLog(@"did finish recording");
    NSLog(@"outputFileURL: %@", outputFileURL);
    [self updateAudio];
}

// Audio API Methods
- (void)updateAudio {
    NSLog(@"updateAudio");
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    
    NSLog(@"selectItem: %ld", (long)selectItem);
    
    NSString *pid = [ImageDataArr [selectItem][@"photo_id"] stringValue];
    NSLog(@"pid: %@", pid);
    
    audioData = [[NSData alloc] initWithContentsOfURL: outputFileURL];
    //NSLog(@"audioData: %@", audioData);
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        __strong typeof(weakSelf) stSelf = weakSelf;
        NSString *response = [boxAPI updateAudioOfDiy: [wTools getUserID]
                                                token: [wTools getUserToken]
                                             album_id: stSelf.albumid
                                             photo_id: pid
                                                 file: stSelf->audioData];
        
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
            [self stopRipple];
            
            if (response != nil) {
                NSLog(@"response from updateAudioOfDiy");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"AlbumCollectionViewController");
                    NSLog(@"deleteAudioOfDiy");
                    
                    [stSelf showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                      protocolName: @"updateAudioOfDiy"
                                           textStr: @""
                                              data: nil
                                             image: nil
                                           jsonStr: @""
                                         audioMode: @""
                                            option: @""];
                } else {
                    NSLog(@"Get Real Response");
                    [stSelf enableRecordAndPlayBtn];
                    stSelf->isRecordingAudio = NO;
                    
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"updateAudio Success");
                        //NSLog(@"%@", dic[@"data"]);
                        
                        // Update audio_url for just finish recording
                        stSelf->audio_url = dic[@"data"][@"photo"][stSelf->selectItem][@"audio_url"];
                        NSLog(@"audio_url: %@", stSelf->audio_url);
                        
                        // Update ImageDataArr
                        stSelf->ImageDataArr=[NSMutableArray arrayWithArray:dic[@"data"][@"photo"]];
                        
                        //[mycollection reloadData];
                        [stSelf.dataCollectionView reloadData];
                        
                        // Is Recorded
                        [stSelf->recordPausePlayBtn setImage: [UIImage imageNamed: @"ic200_audio_play_white"] forState: UIControlStateNormal];
                        
                        stSelf->audioBgView.hidden = NO;
                        stSelf->deleteAudioBtn.hidden = NO;
                        
                        stSelf->isRecorded = YES;
                        
                    } else if ([dic[@"result"] boolValue] == 0) {
                        NSLog(@"message: %@", dic[@"message"]);
                        
                        // Can not Record
                        [stSelf->recordPausePlayBtn setImage: [UIImage imageNamed: @"ic200_micro_white"] forState: UIControlStateNormal];
                        stSelf->audioBgView.hidden = YES;
                        stSelf->deleteAudioBtn.hidden = YES;
                        
                        stSelf->isRecorded = NO;
                        
                        [stSelf showPermission];
                    } else {
                        [stSelf showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}

- (void)deleteAudioOfDiy {
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    NSLog(@"selectItem: %ld", (long)selectItem);
    
    NSString *pid = [ImageDataArr [selectItem][@"photo_id"] stringValue];
    NSLog(@"pid: %@", pid);
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        __strong typeof(weakSelf) stSelf = weakSelf;
        NSString *response = [boxAPI deleteAudioOfDiy: [wTools getUserID]
                                                token: [wTools getUserToken]
                                             album_id: stSelf.albumid
                                             photo_id: pid];
        
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
                NSLog(@"response from deleteAudioOfDiy");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"AlbumCollectionViewController");
                    NSLog(@"deleteAudioOfDiy");
                    
                    [stSelf showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                      protocolName: @"deleteAudioOfDiy"
                                           textStr: @""
                                              data: nil
                                             image: nil
                                           jsonStr: @""
                                         audioMode: @""
                                            option: @""];
                } else {
                    NSLog(@"Get Real Response");
                    
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"deleteAudio Success");
                        //NSLog(@"%@", dic[@"data"]);
                        
                        // Update audio_url for just finish recording
                        stSelf->audio_url = dic[@"data"][@"photo"][stSelf->selectItem][@"audio_url"];
                        NSLog(@"audio_url: %@", stSelf->audio_url);
                        
                        // Update ImageDataArr
                        stSelf->ImageDataArr=[NSMutableArray arrayWithArray:dic[@"data"][@"photo"]];
                        
                        //[mycollection reloadData];
                        [stSelf.dataCollectionView reloadData];
                        
                        stSelf->isRecorded = NO;
                        
                        //[avPlayer pause];
                        [stSelf.avPlayer pause];
                        stSelf->isPlayingAudio = NO;
                        
                        stSelf->audioBgView.hidden = YES;
                        stSelf->deleteAudioBtn.hidden = YES;
                        [stSelf->recordPausePlayBtn setImage: [UIImage imageNamed: @"ic200_micro_white"] forState: UIControlStateNormal];
                    } else if ([dic[@"result"] boolValue] == 0) {
                        NSLog(@"message: %@", dic[@"message"]);
                        [stSelf showPermission];
                    } else {
                        [stSelf showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}

#pragma mark - Check Photo Access Permission
- (void)photoSetup {
    __weak typeof(self) weakSelf = self;
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        __strong typeof(weakSelf) stSelf = weakSelf;
        NSLog(@"requestAuthorization");
        if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
            NSLog(@"authorized");
            
            stSelf->photoGranted = YES;
        } else {
            NSLog(@"Not Authorized");
            
            stSelf->photoGranted = NO;
            [stSelf showNoAccessAlertAndCancel: @"photo"];
        }
    }];
}

- (void)checkPhoto {
    NSLog(@"checkPhoto");
    
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        NSLog(@"authorized");
        
        photoGranted = YES;
    } else {
        NSLog(@"Not Authorized");
        
        photoGranted = NO;
        [self showNoAccessAlertAndCancel: @"photo"];
    }
}

#pragma mark - Showing Message for No Access Permission of Photo/Mic/Camera
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
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        
    }]];
    
    [self presentViewController: alert animated: YES completion: nil];
}

- (void)checkCamera {
    //判断是否拥有权限
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        [self showNoAccessAlertAndCancel: @"camera"];
    }
}

-(IBAction)reload:(id)sender {
    NSLog(@"reload");
    
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        
        __strong typeof(weakSelf) stSelf = weakSelf;
        NSString *response = [boxAPI getalbumofdiy: [wTools getUserID]
                                             token: [wTools getUserToken]
                                          album_id: stSelf.albumid];
        
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
                NSLog(@"response from getalbumofdiy: %@", response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"AlbumCollectionViewController");
                    NSLog(@"reload");
                    
                    [stSelf showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                      protocolName: @"getalbumofdiy"
                                           textStr: @""
                                              data: nil
                                             image: nil
                                           jsonStr: @""
                                         audioMode: @""
                                            option: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"call getalbumofdiy success");
                        NSLog(@"dic: %@", dic);
                        
                        stSelf.selectrow = [dic[@"data"][@"usergrade"][@"photo_limit_of_album"] intValue];
                        NSLog(@"self.selectrow: %ld", (long)stSelf.selectrow);
                        
                        stSelf.audioMode = dic[@"data"][@"album"][@"audio_mode"];
                        NSLog(@"audioMode: %@", stSelf.audioMode);
                        
                        stSelf->ImageDataArr = [NSMutableArray arrayWithArray:dic[@"data"][@"photo"]];
                        NSLog(@"ImageDataArr.count: %lu", (unsigned long)stSelf->ImageDataArr.count);
                        
                        
                        if (stSelf->ImageDataArr.count == 0) {
                            
                            stSelf->recordPausePlayBtn.hidden = YES;
                            stSelf->audioBgView.hidden = YES;
                            stSelf->deleteAudioBtn.hidden = YES;
                            
                            stSelf->textBgView.hidden = YES;
                            stSelf->addTextBtn.hidden = YES;
                            stSelf->deleteTextBtn.hidden = YES;
                            
                            stSelf->deleteImageBtn.hidden = YES;
                            
                            [stSelf.dataCollectionView reloadData];
                            
                            // Check whether is in template mode or not
                            if ([stSelf.templateid intValue] != 0) {
                                TemplateViewController *tVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"TemplateViewController"];
                                tVC.albumid = stSelf.albumid;
                                tVC.event_id = stSelf.event_id;
                                tVC.postMode = stSelf.postMode;
                                tVC.choice = stSelf.choice;
                                tVC.templateid = stSelf.templateid;
                                tVC.delegate = stSelf;
                                //[self.navigationController pushViewController: tVC animated: YES];
                                
                                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                                [appDelegate.myNav pushViewController: tVC animated: YES];
                            } else {
                                NSLog(@"isViewDidLoad: %d",stSelf->isViewDidLoad);
                                
                                if ([self.templateid intValue] == 0) {
                                    // check if there is no image
                                    if (stSelf->isViewDidLoad) {
                                        // And it's first time to go to AlbumCreationVC
                                        // will call actionSheet
                                        [stSelf showPhotoAndVideoActionSheet];
                                        stSelf->isViewDidLoad = NO;
                                    }
                                }
                            }
                        } else {
                            [self myshowimage];
                        }
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗：%@",dic[@"message"]);
                        [stSelf showCustomErrorAlert: dic[@"message"]];
                    } else {
                        [stSelf showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}

- (void)getCooperation
{
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    
    NSMutableDictionary *data=[NSMutableDictionary new];
    [data setObject: _albumid forKey: @"type_id"];
    [data setObject: [wTools getUserID] forKey: @"user_id"];
    [data setObject: @"album" forKey: @"type"];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(weakSelf) stSelf = weakSelf;
        NSString *response = [boxAPI getcooperation: [wTools getUserID]
                                              token: [wTools getUserToken]
                                               data: data];
        
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
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"AlbumCollectionViewController");
                    NSLog(@"getCooperation");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getcooperation"
                                         textStr: @""
                                            data: nil
                                           image: nil
                                         jsonStr: @""
                                       audioMode: @""
                                          option: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    NSLog(@"dic: %@", dic);
                    
                    if ([dic[@"result"] boolValue]) {
                        NSLog(@"dic result boolValue is 1");
                        stSelf->identity = dic[@"data"];
                    } else {
                        NSLog(@"失敗： %@", dic[@"message"]);
                        NSString *msg = dic[@"message"];
                        
                        if (msg == nil) {
                            msg = NSLocalizedString(@"Host-NotAvailable", @"");
                        }
                        [stSelf showCustomErrorAlert: msg];
                    }
                }
            }
        });
    });
}

//儲存相本
-(IBAction)save:(id)sender {
    NSLog(@"快速建立相本 儲存");
    
    if (ImageDataArr.count == 0) {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor thirdPink];
        [self.view makeToast: @"你的作品還沒有內容唷!"
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
    } else {        
        if ([self.userIdentity isEqualToString:@"editor"] || [self.userIdentity isEqualToString: @"approver"]) {
            [self removeObserAndNotificationAndRipple];
//            [self updateAlbumOfDiy: @"cooperation"];
            [self showCustomAlert: @"確定退出編輯器?"];
        } else {
            NSLog(@"excute the line below");
            // When pressing save button, the audio should be stopped
            [self setupWhenViewWillDisappear];
            [self updateAlbumOfDiy: @"save"];
        }
    }
}

#pragma mark - Calling API for Updating Album
- (void)updateAlbumOfDiy: (NSString *)option {
    NSLog(@"updateAlbumOfDiy");
    
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        __strong typeof(weakSelf) stSelf = weakSelf;
        NSString *response = [boxAPI updatealbumofdiy: [wTools getUserID]
                                                token: [wTools getUserToken]
                                             album_id: stSelf.albumid];
        
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
                NSLog(@"response from updatealbumofdiy");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"AlbumCollectionViewController");
                    NSLog(@"updateAlbumOfDiy");
                    
                    [stSelf showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                      protocolName: @"updatealbumofdiy"
                                           textStr: @""
                                              data: nil
                                             image: nil
                                           jsonStr: @""
                                         audioMode: @""
                                            option: option];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    NSLog(@"dic: %@", dic);
                    
                    if ([dic[@"result"] intValue] == 1) {
                        if ([option isEqualToString: @"save"]) {
                            AlbumSettingViewController *aSVC = [[UIStoryboard storyboardWithName: @"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumSettingViewController"];
                            aSVC.albumId = stSelf.albumid;
                            aSVC.postMode = stSelf.postMode;
                            aSVC.eventId = stSelf.event_id;
                            aSVC.fromVC = @"AlbumCreationVC";
                            aSVC.hasImage = YES;
                            aSVC.isNew = YES;
                            aSVC.prefixText = stSelf.prefixText;
                            aSVC.specialUrl = stSelf.specialUrl;
                            
                            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                            [appDelegate.myNav pushViewController: aSVC animated: NO];
                        } else if ([option isEqualToString: @"back"]) {
                            if ([stSelf.fromVC isEqualToString: @"AlbumDetailVC"]) {
                                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                                
                                for (UIViewController *vc in appDelegate.myNav.viewControllers) {
                                    if ([vc isKindOfClass: [AlbumDetailViewController class]]) {
                                        if ([stSelf.delegate respondsToSelector: @selector(albumCreationViewControllerBackBtnPressed:)]) {
                                            [stSelf.delegate albumCreationViewControllerBackBtnPressed: stSelf];
                                        }
                                        [appDelegate.myNav popToViewController: vc animated: YES];
                                        break;
                                    }
                                }
                            } else if ([stSelf.fromVC isEqualToString: @"AlbumCollectionVC"]) {
                                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                                for (UIViewController *vc in appDelegate.myNav.viewControllers) {
                                    if ([vc isKindOfClass: [AlbumCollectionViewController class]]) {
                                        if ([stSelf.delegate respondsToSelector: @selector(albumCreationViewControllerBackBtnPressed:)]) {
                                            [stSelf.delegate albumCreationViewControllerBackBtnPressed: stSelf];
                                        }
                                        [appDelegate.myNav popToViewController: vc animated: YES];
                                        break;
                                    }
                                }
                                
                            } else {
                                AlbumCollectionViewController *albumCollectionVC = [[UIStoryboard storyboardWithName: @"AlbumCollectionVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumCollectionViewController"];
                                albumCollectionVC.postMode = stSelf.postMode;
                                
                                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                                [appDelegate.myNav pushViewController: albumCollectionVC animated: YES];
                            }
                        }
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗：%@",dic[@"message"]);
                        [stSelf showCustomErrorAlert: dic[@"message"]];
                    } else {
                        [stSelf showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}

- (IBAction)deleteFile:(id)sender {
    NSString *userIdStr = ImageDataArr[selectItem][@"user_id"];
    
    NSLog(@"userIdStr: %@", userIdStr);
    NSLog(@"getUserId: %@", [wTools getUserID]);
    NSLog(@"self.userIdentity: %@", self.userIdentity);
    
    if (![userIdStr isEqual: [NSNull null]]) {
        NSLog(@"userId is not null");
        if (![self.userIdentity isEqual: [NSNull null]]) {
            NSLog(@"self.userIdentity is not null");
            if ([self.userIdentity isEqualToString: @"admin"] || [userIdStr integerValue] == [[wTools getUserID] integerValue]) {
                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
                    //NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:ImageDataArr[selectItem][@"video_url"]]];
                    __strong typeof(weakSelf) stSelf = weakSelf;
                    NSString *videoStr = stSelf->ImageDataArr[stSelf->selectItem][@"video_url"];
                    NSLog(@"videoStr: %@", videoStr);
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([videoStr isKindOfClass: [NSNull class]]) {
                            [stSelf deleteImage];
                        } else {
                            [stSelf deleteVideo];
                        }
                    });
                });
            } else {
                CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                style.messageColor = [UIColor whiteColor];
                style.backgroundColor = [UIColor thirdPink];
                
                [self.view makeToast: @"只能操作你上傳的項目"
                            duration: 1.0
                            position: CSToastPositionBottom
                               style: style];
                return;
            }
        }
    }
}

#pragma mark - Delete File Section
//刪除
- (void)deleteImage {
    NSLog(@"deleteImage");
    [self showCustomAlertForDeletingImageOrVideo: @"確定刪除此項目"
                                            type: @"Image"];
}

- (void)deleteVideo {
    NSLog(@"deleteVideo");
    [self showCustomAlertForDeletingImageOrVideo: @"確定刪除此項目"
                                            type: @"Video"];
}

- (void)deletePhotoOfDiy {
    NSLog(@"deletePhotoOfDiy");
    NSString *pid = [ImageDataArr[selectItem][@"photo_id"] stringValue];
    
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        __strong typeof(weakSelf) stSelf = weakSelf;
        NSString *response = [boxAPI deletephotoofdiy: [wTools getUserID]
                                                token: [wTools getUserToken]
                                             album_id: stSelf.albumid
                                             photo_id: pid];
        
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
                NSLog(@"response from deletephotoofdiy");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"AlbumCollectionViewController");
                    NSLog(@"deletePhotoOfDiy");
                    
                    [stSelf showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                      protocolName: @"deletephotoofdiy"
                                           textStr: @""
                                              data: nil
                                             image: nil
                                           jsonStr: @""
                                         audioMode: @""
                                            option: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"deletePhoto Success");
                        stSelf->ImageDataArr = [NSMutableArray arrayWithArray:dic[@"data"][@"photo"]];
                        [self myshowimage];
                        //[mycollection reloadData];
                        //[self.dataCollectionView reloadData];
                        
                    } else if ([dic[@"result"] intValue] == 0) {
                        [stSelf showPermission];
                    } else {
                        [stSelf showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}

- (void)deleteVideoOfDiy
{
    NSString *pid=[ImageDataArr[selectItem][@"photo_id"] stringValue];
    
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        
        __strong typeof(weakSelf) stSelf = weakSelf;
        NSString *response = [boxAPI deleteVideoOfDiy: [wTools getUserID]
                                                token: [wTools getUserToken]
                                             album_id: stSelf.albumid
                                             photo_id: pid];
        
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
                NSLog(@"response from deleteVideoOfDiy");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"AlbumCollectionViewController");
                    NSLog(@"deleteVideoOfDiy");
                    
                    [stSelf showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                      protocolName: @"deleteVideoOfDiy"
                                           textStr: @""
                                              data: nil
                                             image: nil
                                           jsonStr: @""
                                         audioMode: @""
                                            option: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"deleteVideo Success");
                        stSelf->ImageDataArr=[NSMutableArray arrayWithArray:dic[@"data"][@"photo"]];
                        [stSelf myshowimage];
                        //[mycollection reloadData];
                        //[self.dataCollectionView reloadData];
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗：%@",dic[@"message"]);
                        [stSelf showCustomErrorAlert: dic[@"message"]];
                    } else {
                        [stSelf showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}

#pragma mark - Video Related Methods
- (void)recordVideo
{
    NSLog(@"recordVideo");
    videoMode = @"RecordVideo";
    [alertView close];
    [self checkCamera];
    
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *videoPicker = [[UIImagePickerController alloc] init];
        videoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        videoPicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *)kUTTypeMovie, nil];
        videoPicker.allowsEditing = YES;
        videoPicker.delegate = self;
        videoPicker.videoMaximumDuration = 30.0f;
        videoPicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
        [self presentViewController: videoPicker animated: YES completion: nil];
    }
}

- (void)chooseExistingVideo
{
    NSLog(@"chooseExistingVideo");
    videoMode = @"ExistingVideo";
    [alertView close];
    
    // Check Photo Album Permission is granted or not
    [self checkPhoto];
    
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        UIImagePickerController *videoPicker = [[UIImagePickerController alloc] init];
        videoPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        videoPicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *)kUTTypeMovie, nil];
        videoPicker.allowsEditing = YES;
        videoPicker.delegate = self;
        videoPicker.videoMaximumDuration = 30.0f;
        videoPicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
        [self presentViewController: videoPicker animated: YES completion: nil];
    }
}

#pragma mark - UIImagePickerController Delegate Method
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
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
            
            if (seconds >= 32) {
                NSLog(@"Longer than 31 seconds");
                UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"無法傳送影片" message: @"影片超過30秒上限，請重新選擇" preferredStyle: UIAlertControllerStyleAlert];
                UIAlertAction *defaultAction = [UIAlertAction actionWithTitle: @"OK"
                                                                        style: UIAlertActionStyleDefault
                                                                      handler: nil];
                [alert addAction: defaultAction];
                [self presentViewController: alert animated: YES completion: nil];
            } else {
                NSLog(@"Smaller than 31 seconds");
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

- (void)video:(NSString *)videoPath
didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo
{
    NSLog(@"didFinishSavingWithError");
    
    NSLog(@"videoPath: %@", videoPath);
    NSURL *videoURL = [NSURL fileURLWithPath: videoPath];
    AVURLAsset *sourceAsset = [AVURLAsset URLAssetWithURL: videoURL options: nil];
    CMTime duration = sourceAsset.duration;
    float seconds = CMTimeGetSeconds(duration);
    NSLog(@"duration: %.2f", seconds);
    
    if (seconds >= 120) {
        NSLog(@"Longer than 120 seconds");
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
        /*
         UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"成功"
         message: @"影片儲存到相簿"
         preferredStyle: UIAlertControllerStyleAlert];
         
         UIAlertAction *defaultAction = [UIAlertAction actionWithTitle: @"OK"
         style: UIAlertActionStyleDefault
         handler: nil];
         [alert addAction: defaultAction];
         [self presentViewController: alert animated: YES completion: nil];
         */
    }
}

// For responding to the user tapping Cancel.
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //[self dismissModalViewControllerAnimated: YES];
    [self dismissViewControllerAnimated: YES completion: nil];
}

#pragma mark - mp4ConversionMethod
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
        __weak typeof(self) weakSelf = self;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            __strong typeof(weakSelf) stSelf = weakSelf;
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"錯誤" message: [[exportSession error] localizedDescription] preferredStyle: UIAlertControllerStyleAlert];
                        UIAlertAction *okBtn = [UIAlertAction actionWithTitle: @"確認" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        }];
                        [alert addAction: okBtn];
                        [stSelf presentViewController: alert animated: YES completion: nil];
                        /*
                         UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"錯誤"
                         message: [[exportSession error] localizedDescription]
                         delegate: nil
                         cancelButtonTitle: @"確定"
                         otherButtonTitles: nil];
                         [alert show];
                         */
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
                        [stSelf callInsertVideoOfDiy: data];
                        
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
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"錯誤" message: @"影像檔案不支援" preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *okBtn = [UIAlertAction actionWithTitle: @"確認" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction: okBtn];
        [self presentViewController: alert animated: YES completion: nil];
        /*
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"錯誤"
         message: @"影像檔案不支援"
         delegate: nil
         cancelButtonTitle: @"確認"
         otherButtonTitles: nil];
         [alert show];
         */
    }
}

#pragma mark - Calling Protocol callInsertVideoOfDiy
- (void)callInsertVideoOfDiy: (NSData *)data;
{
    NSLog(@"callInsertVideoOfDiy");
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        __strong typeof(weakSelf) stSelf = weakSelf;
        NSString *response = @"";
        response = [boxAPI insertVideoOfDiy: [wTools getUserID]
                                      token: [wTools getUserToken]
                                   album_id: stSelf.albumid
                                       file: data];
        
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
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"AlbumCollectionViewController");
                    NSLog(@"callInsertVideoOfDiy");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"insertVideoOfDiy"
                                         textStr: @""
                                            data: data
                                           image: nil
                                         jsonStr: @""
                                       audioMode: @""
                                          option: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"insertvideoofdiy Success");
                        
                        stSelf->ImageDataArr = [NSMutableArray arrayWithArray: dic[@"data"][@"photo"]];
                        NSLog(@"ImageDataArr.count: %lu", (unsigned long)stSelf->ImageDataArr.count);
                        
                        stSelf->selectItem = stSelf->ImageDataArr.count - 1;
                        NSLog(@"selectItem: %ld", (long)stSelf->selectItem);
                        
                        [stSelf myshowimage];
                        NSLog(@"[_dataCollectionView reloadData]");
                        //[self.dataCollectionView reloadData];
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"insertvideoofdiy Failed");
                        NSLog(@"message: %@", dic[@"message"]);
                        
                        if (dic[@"message"] == nil) {
                            NSLog(@"dic message is nil");
                            NSLog(@"response from insertvideoofdiy: %@", response);
                            
                            if (![response isKindOfClass: [NSNull class]]) {
                                if (![response isEqualToString: @""]) {
                                    //                                    UIAlertController *alert = [UIAlertController alertControllerWithTitle: response message: @"目前網路不穩定，請確認網路品質再繼續使用pinpinbox唷!" preferredStyle: UIAlertControllerStyleAlert];
                                    //                                    UIAlertAction *okBtn = [UIAlertAction actionWithTitle: @"確定" style: UIAlertActionStyleDefault handler: nil];
                                    //                                    [alert addAction: okBtn];
                                    //                                    [stSelf presentViewController: alert animated: YES completion: nil];
                                    [stSelf showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                                      protocolName: @"insertVideoOfDiy"
                                                           textStr: @""
                                                              data: data
                                                             image: nil
                                                           jsonStr: @""
                                                         audioMode: @""
                                                            option: @""];
                                }
                            }
                        } else {
                            [stSelf showCustomErrorAlert: dic[@"message"]];
                        }
                    } else {
                        [stSelf showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}

#pragma mark - Long Press Gesture

- (void)handleLongPress: (UILongPressGestureRecognizer *)gestureRecognizer
{
    NSLog(@"handleLongPress");
    
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    CGPoint p = [gestureRecognizer locationInView: _dataCollectionView];
    NSIndexPath *indexPath = [_dataCollectionView indexPathForItemAtPoint: p];
    
    NSLog(@"indexPath.row: %ld", (long)indexPath.row);
    
    if (indexPath == nil) {
        NSLog(@"couldn't find index path");
    } else {
        NSLog(@"find index path");
        
        if (indexPath.row == 0) {
            NSLog(@"Plus Button");
        } else {
            [self showReorderVC];
        }
    }
}

#pragma mark - Add Image Data
//新增照片
-(void)addimagedata {
    NSLog(@"addimagedata");
    
    //新增照片
    if (ImageDataArr.count >= _selectrow) {
        NSLog(@"selectRow: %ld", (long)_selectrow);
        [self showCustomErrorAlert: NSLocalizedString(@"CreateAlbumText-tipLimit", @"")];
        return;
    }
    NSLog(@"self.templateid: %@", self.templateid);
    
    if ([self.templateid intValue] == 0) {
        NSLog(@"[self.templateid intValue] == 0");
        PhotosViewController *pVC = [[UIStoryboard storyboardWithName: @"PhotosVC" bundle: nil] instantiateViewControllerWithIdentifier: @"PhotosViewController2"];
        pVC.selectrow = self.selectrow - ImageDataArr.count;
        NSLog(@"pVC.selectrow: %ld", (long)pVC.selectrow);
        pVC.phototype = @"1";
        pVC.delegate = self;
        pVC.choice = self.choice;
        NSLog(@"pVC.choice: %@", pVC.choice);
        pVC.fromVC = @"AlbumCreationViewController";
        pVC.albumId = self.albumid;
        NSLog(@"self.albumid: %@", self.albumid);
        //[self.navigationController pushViewController: pVC animated: YES];
        
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.myNav pushViewController: pVC animated: YES];
    } else {
        NSLog(@"[self.templateid intValue] != 0");
        TemplateViewController *tVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"TemplateViewController"];
        tVC.albumid = _albumid;
        tVC.event_id = _event_id;
        tVC.postMode = _postMode;
        tVC.choice = _choice;
        //[self.navigationController pushViewController: tVC animated: YES];
        
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.myNav pushViewController: tVC animated: YES];
    }
}

#pragma mark - myShowImage
//顯示圖像
-(void)myshowimage {
    NSLog(@"-----------");
    NSLog(@"myshowimage");
    NSLog(@"selectItem: %ld", (long)selectItem);
    NSLog(@"ImageDataArr: %@", ImageDataArr);
    
    for (UIView *v in [_ShowView subviews]) {
        NSLog(@"v: %@", v);
        [v removeFromSuperview];
    }
    if (ImageDataArr.count == 0) {
        NSLog(@"ImageDataArr.count: %lu", (unsigned long)ImageDataArr.count);
        
        //        adobeEidt.hidden = YES;
        recordPausePlayBtn.hidden = YES;
        audioBgView.hidden = YES;
        deleteAudioBtn.hidden = YES;
        
        textBgView.hidden = YES;
        addTextBtn.hidden = YES;
        deleteTextBtn.hidden = YES;
        
        deleteImageBtn.hidden = YES;
        
        [self.dataCollectionView reloadData];
        
        return;
        
    } else if (ImageDataArr.count != 0) {
        NSLog(@"ImageDataArr.count: %lu", (unsigned long)ImageDataArr.count);
        
        //        adobeEidt.hidden = NO;
        addTextBtn.hidden = NO;
        
        recordPausePlayBtn.hidden = NO;
        audioBgView.hidden = YES;
        deleteAudioBtn.hidden = YES;
        
        deleteImageBtn.hidden = NO;
    }
    
    // For Array Counting
    if (selectItem >= ImageDataArr.count) {
        NSLog(@"Array Counting");
        selectItem = ImageDataArr.count - 1;
        NSLog(@"selectItem: %ld", (long)selectItem);
    }
    
    NSLog(@"selectItem: %ld", (long)selectItem);
    
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        // If ImageDataArr is empty
        // then the code below will not be executed
        __strong typeof(weakSelf) stSelf = weakSelf;
        NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:stSelf->ImageDataArr[stSelf->selectItem][@"image_url"]]];
        NSLog(@"image_url: %@", stSelf->ImageDataArr[stSelf->selectItem][@"image_url"]);
        
        NSLog(@"global queue");
        
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
            
            NSLog(@"get main queue");
            
            UIImage *image = [UIImage imageWithData: data];
            NSLog(@"image: %@", image);
            NSLog(@"_ShowView: %@", stSelf.ShowView);
            UIImageView *imgv = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, stSelf.ShowView.bounds.size.width, stSelf.ShowView.bounds.size.height)];
            imgv.image = image;
            imgv.contentMode = UIViewContentModeScaleAspectFit;
            
            stSelf->selectimage = image;
            [stSelf.ShowView addSubview: imgv];
            
            NSString *videoStr = stSelf->ImageDataArr[stSelf->selectItem][@"video_url"];
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
                [stSelf.ShowView addSubview: videoBtn];
                
                
                stSelf->recordPausePlayBtn.hidden = YES;
                stSelf->audioBgView.hidden = YES;
                stSelf->deleteAudioBtn.hidden = YES;
                
            } else if ([videoStr isKindOfClass: [NSNull class]]) {
                NSLog(@"videoStr is null");
                [videoBtn removeFromSuperview];
                
                stSelf->recordPausePlayBtn.hidden = NO;
                stSelf->audioBgView.hidden = NO;
                stSelf->deleteAudioBtn.hidden = NO;
            }
            
            stSelf->audio_url = stSelf->ImageDataArr[stSelf->selectItem][@"audio_url"];
            NSLog(@"audio_url: %@", stSelf->audio_url);
            
            if (![stSelf->audio_url isKindOfClass: [NSNull class]]) {
                if (![stSelf->audio_url isEqualToString: @""]) {
                    NSLog(@"audio_url is not empty");
                    NSLog(@"audio_url: %@", stSelf->audio_url);
                    
                    [stSelf->recordPausePlayBtn setImage: [UIImage imageNamed: @"ic200_audio_play_white"] forState: UIControlStateNormal];
                    stSelf->audioBgView.hidden = NO;
                    stSelf->deleteAudioBtn.hidden = NO;
                    stSelf->isRecorded = YES;
                }
            } else {
                NSLog(@"audio_url is empty");
                stSelf->audioBgView.hidden = YES;
                stSelf->deleteAudioBtn.hidden = YES;
                [stSelf->recordPausePlayBtn setImage: [UIImage imageNamed: @"ic200_micro_white"] forState: UIControlStateNormal];
                stSelf->isRecorded = NO;
            }
            
            stSelf->textForDescription = stSelf->ImageDataArr[stSelf->selectItem][@"description"];
            NSLog(@"textForDescription: %@", stSelf->textForDescription);
            
            if (![stSelf->textForDescription isEqualToString: @""]) {
                stSelf->textBgView.hidden = NO;
                stSelf->deleteTextBtn.hidden = NO;
                
                [stSelf addTextDescriptionView];
            } else {
                stSelf->textBgView.hidden = YES;
                stSelf->deleteTextBtn.hidden = YES;
                
                [stSelf removeTextDescriptionView];
            }
            
            [stSelf.dataCollectionView reloadData];
        });
    });
}

#pragma mark - playVideo
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

#pragma mark - PhotosViewDelegate Methods
- (void)afterSendingImages:(PhotosViewController *)controller
{
    NSLog(@"");
    NSLog(@"");
    NSLog(@"afterSendingImages");
    
    [self reload:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    NSLog(@"----------------------");
    NSLog(@"observeValueForKeyPath");
    NSLog(@"object: %@", object);
    
    if (context == AVPlayerDemoPlaybackViewControllerStatusObservationContext) {
        NSLog(@"");
        NSLog(@"context == AVPlayerDemoPlaybackViewControllerStatusObservationContext");
        
        switch (self.avPlayer.status) {
            case AVPlayerStatusUnknown:
            {
                NSLog(@"----------------------");
                NSLog(@"AVPlayerStatusUnknown");
                self.isReadyToPlay = NO;
            }
                break;
                
            case AVPlayerStatusReadyToPlay:
            {
                NSLog(@"----------------------");
                NSLog(@"AVPlayerStatusReadyToPlay");
                self.isReadyToPlay = YES;
                
                if (self.avPlayer != nil) {
                    NSLog(@"----------------------");
                    NSLog(@"avPlayer is initialized");
                    
                    if (self.isReadyToPlay) {
                        NSLog(@"----------------------");
                        NSLog(@"self.isReadyToPlay is set to YES");
                        
                        [self.avPlayer play];
                        //[self.avPlayer playImmediatelyAtRate: 1.0];
                        
                        isPlayingAudio = YES;
                        NSLog(@"----------------------");
                        NSLog(@"self.avPlayer play");
                        
                        [self activateRipple];
                    } else {
                        NSLog(@"----------------------");
                        NSLog(@"self.isReadyToPlay is set to NO");
                        
                        isPlayingAudio = NO;
                        [self enableButton];
                    }
                }
            }
                break;
                
            case AVPlayerStatusFailed:
            {
                NSLog(@"");
                NSLog(@"");
                NSLog(@"AVPlayerStatusFailed");
                self.isReadyToPlay = NO;
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback: playerItem.error];
            }
                break;
            default:
                break;
        }
    } else {
        [super observeValueForKeyPath: keyPath ofObject: object change: change context: context];
    }
}

- (void)enableButton {
    refreshBtn.userInteractionEnabled = YES;
    conbtn.userInteractionEnabled = YES;
    settingBtn.userInteractionEnabled = YES;
    nextBtn.userInteractionEnabled = YES;
    
    //    adobeEidt.userInteractionEnabled = YES;
    
    addTextBtn.userInteractionEnabled = YES;
    deleteTextBtn.userInteractionEnabled = YES;
    
    deleteAudioBtn.userInteractionEnabled = YES;
    deleteImageBtn.userInteractionEnabled = YES;
}

- (void)disableButton {
    NSLog(@"disableButton");
    refreshBtn.userInteractionEnabled = NO;
    conbtn.userInteractionEnabled = NO;
    settingBtn.userInteractionEnabled = NO;
    nextBtn.userInteractionEnabled = NO;
    
    //    adobeEidt.userInteractionEnabled = NO;
    
    addTextBtn.userInteractionEnabled = NO;
    deleteTextBtn.userInteractionEnabled = NO;
    
    deleteAudioBtn.userInteractionEnabled = NO;
    deleteImageBtn.userInteractionEnabled = NO;
}

#pragma mark - UICollectionViewDataSource
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
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"");
    NSLog(@"");
    NSLog(@"cellForItemAtIndexPath");
    
    NSLog(@"indexPath.item: %ld", (long)indexPath.item);
    
    if (indexPath.item == 0) {
        NSLog(@"indexPath.item: %ld", (long)indexPath.item);
        UICollectionViewCell *Cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FastAdd" forIndexPath:indexPath];
        
        UIImageView *imgView = (UIImageView *)[Cell viewWithTag: 100];
        imgView.layer.cornerRadius = kCornerRadius;
        
        UILabel *lab = (UILabel *)[Cell viewWithTag: 1111];
        NSLog(@"ImageDataArr.count: %lu", (unsigned long)ImageDataArr.count);
        NSLog(@"_selectrow: %ld", (long)_selectrow);
        
        NSLog(@"set up UILabel Text");
        lab.text = [NSString stringWithFormat: @"%lu/%ld", (unsigned long)ImageDataArr.count, (long)_selectrow];
        NSLog(@"lab.text: %@", lab.text);
        NSLog(@"after setting up UILabel Text");
        
        return Cell;
    }
    
    NSLog(@"");
    NSLog(@"");
    NSLog(@"UICollectionViewCell *myCell Setup for FastV");
    
    NSLog(@"indexPath.item: %ld", (long)indexPath.item);
    
    UICollectionViewCell *myCell = [collectionView
                                    dequeueReusableCellWithReuseIdentifier:@"FastV"
                                    forIndexPath:indexPath];
    
    //AsyncImageView *imagev = (AsyncImageView *)[myCell viewWithTag:2222];
    UIImageView *imagev = (UIImageView *)[myCell viewWithTag: 2222];
    // Reset Image for not showing the old image
    imagev.image = nil;
    [[imagev layer] setMasksToBounds:YES];
    
    //[[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: imagev];
    
    if ([ImageDataArr[indexPath.item - 1][@"image_url_thumbnail"] isEqual: [NSNull null]]) {
        NSLog(@"image_url_thumbnail is NSNull Class");
        imagev.imageURL = nil;
        imagev.image = [UIImage imageNamed: @"bg200_no_image.jpg"];
    } else {
        NSLog(@"image_url_thumbnail is not NSNull Class");
        //imagev.imageURL = [NSURL URLWithString: ImageDataArr[indexPath.item-1][@"image_url_thumbnail"]];
        [imagev sd_setImageWithURL: [NSURL URLWithString: ImageDataArr[indexPath.item-1][@"image_url_thumbnail"]]];
    }
    
    UIButton *audioButton = (UIButton *)[myCell viewWithTag: 3333];
    
    if (![ImageDataArr[indexPath.item - 1][@"audio_url"] isEqual: [NSNull null]]) {
        audioButton.hidden = NO;
        [audioButton setImage: [UIImage imageNamed: @"ic200_audio_play_white"] forState: UIControlStateNormal];
        audioButton.backgroundColor = [UIColor firstMain];
        audioButton.layer.cornerRadius = audioButton.bounds.size.width / 2;
    } else {
        audioButton.hidden = YES;
        [audioButton setImage: [UIImage imageNamed: @""] forState: UIControlStateNormal];
    }
    
    UIButton *videoButton = (UIButton *)[myCell viewWithTag: 4444];
    
    if (![ImageDataArr[indexPath.item - 1][@"video_url"] isEqual: [NSNull null]]) {
        NSLog(@"video_url is not null");
        videoButton.hidden = NO;
        [videoButton setImage: [UIImage imageNamed: @"ic200_video_white_1"] forState: UIControlStateNormal];
        videoButton.backgroundColor = [UIColor firstMain];
        videoButton.layer.cornerRadius = videoButton.bounds.size.width / 2;
    } else {
        NSLog(@"video_url is null");
        videoButton.hidden = YES;
        [videoButton setImage: [UIImage imageNamed: @""] forState: UIControlStateNormal];
    }
    
    UILabel *lab = (UILabel *)[myCell viewWithTag:1111];
    
    if (indexPath.item - 1 == 0) {
        lab.text = NSLocalizedString(@"GeneralText-homePage", @"");
        NSLog(@"indexPath.item - 1 == 0");
        NSLog(@"lab.text: %@", lab.text);
    } else {
        lab.text= [NSString stringWithFormat: @"%li", (long)indexPath.item - 1];
        NSLog(@"else");
        NSLog(@"lab.text: %@", lab.text);
    }
    NSString *userIdStr = ImageDataArr[indexPath.item - 1][@"user_id"];
    
    UIImageView *privateImageView = (UIImageView *)[myCell viewWithTag: 6666];
    UIView *alphaView = (UIView *)[myCell viewWithTag: 5555];
    alphaView.alpha = 0.8;
    
    if (![userIdStr isEqual: [NSNull null]]) {
        NSLog(@"userId is not null");
        if (![self.userIdentity isEqual: [NSNull null]]) {
            if ([self.userIdentity isEqualToString: @"admin"] || [userIdStr integerValue] == [[wTools getUserID] integerValue]) {
                privateImageView.hidden = YES;
                alphaView.hidden = YES;
            } else if ([userIdStr integerValue] != [[wTools getUserID] integerValue]) {
                NSLog(@"userId != getUserId");
                privateImageView.hidden = NO;
                alphaView.hidden = NO;
            }
        }
    }
    
    // Set up the Selected Cell
    if (indexPath.item == selectItem + 1) {
        myCell.layer.borderWidth = 3;
        myCell.layer.borderColor = [[UIColor colorWithRed: 233.0/255.0 green: 30.0/255.0 blue: 99.0/255.0 alpha: 1.0] CGColor];
    } else {
        myCell.layer.borderWidth = 0;
        myCell.layer.borderColor = [UIColor clearColor].CGColor;
    }
    
    NSLog(@"");
    NSLog(@"");
    
    return myCell;
}

#pragma mark - UICollectionViewFlowLayoutDelegate
- (void)collectionView:(UICollectionView *)collectionView
didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didHighlightItemAtIndexPath");
    
    if (isRecordingAudio) {
        if ([CSToastManager isQueueEnabled]) {
            NSLog(@"CSToastManager isQueueEnabled: %d", [CSToastManager isQueueEnabled]);
        } else {
            NSLog(@"CSToastManager isQueueEnabled: %d", [CSToastManager isQueueEnabled]);
        }
        
        
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor secondGrey];
        [self.view makeToast: @"錄音中"
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
        
        [CSToastManager setTapToDismissEnabled: YES];
        
        return;
    }
    if (isPlayingAudio) {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor secondGrey];
        [self.view makeToast: @"播放中"
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
        return;
    }
    
    
    if (indexPath.item == 0) {
        NSLog(@"indexPath.item: %ld", (long)indexPath.item);
        
        if (ImageDataArr.count >= self.selectrow) {
            CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
            style.messageColor = [UIColor whiteColor];
            style.backgroundColor = [UIColor thirdPink];
            [self.view makeToast: @"已達最大上限"
                        duration: 2.0
                        position: CSToastPositionBottom
                           style: style];
        } else {
            NSLog(@"self.templateid: %@", self.templateid);
            NSLog(@"[self.templateid intValue]: %d", [self.templateid intValue]);
            
            if ([self.templateid intValue] == 0) {
                [self showPhotoAndVideoActionSheet];
            } else {
                NSLog(@"[self.templateid intValue] != 0");
                NSLog(@"self.choice: %@", self.choice);
                
                TemplateViewController *tVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"TemplateViewController"];
                tVC.albumid = _albumid;
                tVC.event_id = _event_id;
                tVC.postMode = _postMode;
                tVC.choice = _choice;
                tVC.templateid = self.templateid;
                //[self.navigationController pushViewController: tVC animated: YES];
                
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [appDelegate.myNav pushViewController: tVC animated: YES];
            }
        }
        //[self addimagedata];
        
        return;
    }
    
    NSLog(@"indexPath.item: %ld", (long)indexPath.item);
    selectItem = indexPath.item - 1;
    NSLog(@"selectItem: %ld", (long)selectItem);
    
    [self myshowimage];
    //[collectionView reloadData];
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

- (void)showPhotoAndVideoActionSheet {
    NSLog(@"showPhotoAndVideoActionSheet");
    [wTools setStatusBarBackgroundColor: [UIColor clearColor]];
    
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleDark];
    
    [UIView animateWithDuration: kAnimateActionSheet animations:^{
        self.effectView = [[UIVisualEffectView alloc] initWithEffect: blurEffect];
    }];
    
    self.effectView.frame = self.view.frame;
    self.effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.effectView.myLeftMargin = self.effectView.myRightMargin = 0;
    self.effectView.myTopMargin = self.effectView.myBottomMargin = 0;
    self.effectView.alpha = 0.8;
    
    [self.view addSubview: self.effectView];
    
    // CustomActionSheet Setting
    [self.view addSubview: self.customAddActionSheet.view];
    [self.customAddActionSheet viewWillAppear: NO];
    
    [self.customAddActionSheet addSelectItem: @"ic200_camera_dark" title: @"相片" btnStr: @"" tagInt: 1 identifierStr: @"photo"];
    [self.customAddActionSheet addSelectItem: @"ic200_videomake_dark" title: @"影片" btnStr: @"" tagInt: 2 identifierStr: @"video"];
    
    __weak typeof(self) weakSelf = self;
    self.customAddActionSheet.customViewBlock = ^(NSInteger tagId, BOOL isTouchDown, NSString *identifierStr) {
        NSLog(@"");
        NSLog(@"self.customAddActionSheet.customViewBlock");
        NSLog(@"tagId: %ld", (long)tagId);
        NSLog(@"isTouchDown: %d", isTouchDown);
        NSLog(@"identifierStr: %@", identifierStr);
        
        if ([identifierStr isEqualToString: @"photo"]) {
            [weakSelf addimagedata];
        } else if ([identifierStr isEqualToString: @"video"]) {
            [weakSelf showVideoMode];
        }
    };
}

- (void)showVideoMode {
    [wTools setStatusBarBackgroundColor: [UIColor clearColor]];
    
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleDark];
    
    [UIView animateWithDuration: kAnimateActionSheet animations:^{
        self.effectView = [[UIVisualEffectView alloc] initWithEffect: blurEffect];
    }];
    
    self.effectView.frame = self.view.frame;
    self.effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.effectView.myLeftMargin = self.effectView.myRightMargin = 0;
    self.effectView.myTopMargin = self.effectView.myBottomMargin = 0;
    self.effectView.alpha = 0.8;
    
    [self.view addSubview: self.effectView];
    
    [self.view addSubview: self.customVideoActionSheet.view];
    [self.customVideoActionSheet viewWillAppear: NO];
    
    [self.customVideoActionSheet addSelectItem: @"" title: @"錄影" btnStr: @"" tagInt: 1 identifierStr: @"recordingVideo"];
    [self.customVideoActionSheet addSelectItem: @"" title: @"選擇現有影片" btnStr: @"" tagInt: 2 identifierStr: @"chooseExistingVideo"];
    
    __weak typeof(self) weakSelf = self;
    self.customVideoActionSheet.customViewBlock = ^(NSInteger tagId, BOOL isTouchDown, NSString *identifierStr) {
        NSLog(@"customVideoActionSheet.customViewBlock");
        NSLog(@"tagId: %ld", (long)tagId);
        NSLog(@"isTouchDown: %d", isTouchDown);
        NSLog(@"identifierStr: %@", identifierStr);
        
        if ([identifierStr isEqualToString: @"recordingVideo"]) {
            [weakSelf recordVideo];
        } else if ([identifierStr isEqualToString: @"chooseExistingVideo"]) {
            [weakSelf chooseExistingVideo];
        }
    };
}

#pragma mark - DDAUIActionSheetViewController Method
- (void)actionSheetViewDidSlideOut:(DDAUIActionSheetViewController *)controller
{
    NSLog(@"actionSheetViewDidSlideOut");
    [wTools setStatusBarBackgroundColor: [UIColor whiteColor]];
    [self.effectView removeFromSuperview];
    self.effectView = nil;
}

#pragma mark -
//image
//產生對應位置的圖片
-(UIImage *)imageByCroppingtodrag:(O_drag *)dragview{
    NSLog(@"imageByCroppingtodrag");
    
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

#pragma mark - Adobe SDK Delegate Methods
//-(IBAction)AdobeEdit:(id)sender{
//    [self AdobeSDK];
//}

-(void)AdobeSDK {
    NSLog(@"AdobeSDK");
    [self displayEditorForImahe:selectimage];
    return;
}

-(void)displayEditorForImahe:(UIImage *)imageToEdit{
    NSLog(@"displayEditorForImahe");
    
    //    @try {
    //        AdobeUXImageEditorViewController *editorController = [[AdobeUXImageEditorViewController alloc] initWithImage:imageToEdit];
    //        [editorController setDelegate:self];
    //        [self presentViewController:editorController animated:YES completion:nil];
    //    } @catch (NSException *exception) {
    //        // Print exception information
    //        NSLog( @"NSException caught" );
    //        NSLog( @"Name: %@", exception.name);
    //        NSLog( @"Reason: %@", exception.reason);
    //        return;
    //    }
}

//- (void)photoEditor:(AdobeUXImageEditorViewController *)editor
//  finishedWithImage:(UIImage *)image
//{
//    // Handle the result image here
//    //[ImageDataArr replaceObjectAtIndex:selectItem withObject:image];
//    //    [self myshowimage];
//    //    [mycollection reloadData];
//
//    NSLog(@"finishedWithImage");
//    [self dismissViewControllerAnimated:YES completion:nil];
//
//    [self callUpdatePhotoOfDiyWithPhoto: image];
//}
//
//- (void)photoEditorCanceled:(AdobeUXImageEditorViewController *)editor
//{
//    NSLog(@"photoEditorCanceled");
//    // Handle cancellation here
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

- (void)callUpdatePhotoOfDiyWithPhoto: (UIImage *)image
{
    //更新照片
    NSString *pid = [ImageDataArr[selectItem][@"photo_id"] stringValue];
    
    //上傳照片
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    __block typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        __strong typeof (weakself) stSelf = weakself;
        NSString *response = @"";
        
        response = [boxAPI updatephotoofdiy: [wTools getUserID]
                                      token: [wTools getUserToken]
                                   album_id: stSelf.albumid
                                   photo_id: pid
                                      image: image
                                    setting: stSelf->textForDescription];
        
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
                NSLog(@"Adobe PhotoEditor Response");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"AlbumCollectionViewController");
                    NSLog(@"callUpdatePhotoOfDiyWithPhoto");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"callUpdatePhotoOfDiyWithPhoto"
                                         textStr: @""
                                            data: nil
                                           image: image
                                         jsonStr: @""
                                       audioMode: @""
                                          option: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        stSelf->ImageDataArr=[NSMutableArray arrayWithArray:dic[@"data"][@"photo"]];
                        [stSelf myshowimage];
                        //[self.dataCollectionView reloadData];
                    } else if ([dic[@"result"] intValue] == 0) {
                        [stSelf showPermission];
                    } else {
                        [stSelf showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}

//共用
- (IBAction)coppertation:(id)sender {
    if ([self.userIdentity isEqualToString: @"admin"] || [self.userIdentity isEqualToString: @"approver"]) {
        NewCooperationViewController *newCooperationVC = [[UIStoryboard storyboardWithName: @"NewCooperationVC" bundle: nil] instantiateViewControllerWithIdentifier: @"NewCooperationViewController"];
        newCooperationVC.albumId = self.albumid;
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.myNav pushViewController: newCooperationVC animated: YES];
    } else {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor thirdPink];
        
        [self.view makeToast: @"權限不足"
                    duration: 1.0
                    position: CSToastPositionBottom
                       style: style];
        return;
    }
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
        [self showPermissionAlert: NSLocalizedString(@"CreateAlbumText-canNotEditOthers", @"")];
    }
}

#pragma mark - Reorder Function
- (void)showReorderVC
{
    NSLog(@"showReorderVC");
    
    reorderVC = [[UIStoryboard storyboardWithName: @"ReorderVC" bundle: nil] instantiateViewControllerWithIdentifier: @"ReorderViewController"];
    reorderVC.imageArray = ImageDataArr;
    reorderVC.albumId = self.albumid;
    reorderVC.delegate = self;
    
    [self presentViewController: reorderVC animated: YES completion: nil];
}

#pragma mark - PreviewPage Setup Function
- (void)showPreviewPageSetupVC
{
    NSLog(@"showPreviewPageSetupVC");
    
    previewPageVC = [[UIStoryboard storyboardWithName: @"PreviewPageSetupVC" bundle: nil] instantiateViewControllerWithIdentifier: @"PreviewPageSetupViewController"];
    previewPageVC.imageArray = ImageDataArr;
    previewPageVC.albumId = self.albumid;
    previewPageVC.delegate = self;
    
    NSLog(@"ImageDataArr.count: %lu", (unsigned long)ImageDataArr.count);
    NSLog(@"ImageDataArr.count / 4: %u", (unsigned int)ImageDataArr.count / 4);
    NSLog(@"ImageDataArr.count remainder divided by 4 : %u", (unsigned int)ImageDataArr.count % 4);
    
    [self presentViewController: previewPageVC animated: YES completion: nil];
}

#pragma mark - ReorderViewControllerDelegate Method
- (void)reorderViewControllerDisappear:(ReorderViewController *)controller imageArray:(NSMutableArray *)ImageArray
{
    ImageDataArr = ImageArray;
    //[self.dimVC.view removeFromSuperview];
}

- (void)reorderViewControllerDisappearAfterCalling:(ReorderViewController *)controller
{
    NSLog(@"reorderViewControllerDisappear");
    
    //NSLog(@"ImageArray: %@", ImageArray);
    
    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
    style.messageColor = [UIColor whiteColor];
    style.backgroundColor = [UIColor secondMain];
    [self.view makeToast: @"修改成功"
                duration: 2.0
                position: CSToastPositionBottom
                   style: style];
    
    [self myshowimage];
    //[self.dataCollectionView reloadData];
}

#pragma mark - PreviewPageSetupViewControllerDelegate Method
- (void)previewPageSetupViewControllerDisappear:(PreviewPageSetupViewController *)controller
{
    //[self.dimVC.view removeFromSuperview];
}

- (void)previewPageSetupViewControllerDisappearAfterCalling:(PreviewPageSetupViewController *)controller modifySuccess:(BOOL)modifySuccess imageArray:(NSMutableArray *)ImageArray
{
    ImageDataArr = ImageArray;
    
    if (modifySuccess) {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor secondMain];
        [self.view makeToast: @"修改成功"
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
    }
}

#pragma mark - SetupMusicViewController Delegate Method
- (void)dismissFromSetupMusicVC:(SetupMusicViewController *)controller audioModeChanged:(BOOL)audioModeChanged
{
    NSLog(@"dismissFromSetupMusicVC");
    
    [self reload: nil];
    
    if (audioModeChanged) {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor secondMain];
        
        [self.view makeToast: @"音 效 播 放 模 式 已 切 換"
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
    }
}

- (void)changeAudioMode: (NSString *)audioMode
{
    NSLog(@"changeAudioMode");
    
    NSMutableDictionary *settingsDic = [NSMutableDictionary new];
    NSLog(@"audioMode: %@", audioMode);
    [settingsDic setObject: audioMode forKey: @"audio_mode"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: settingsDic
                                                       options: 0
                                                         error: nil];
    NSString *jsonStr = [[NSString alloc] initWithData: jsonData
                                              encoding: NSUTF8StringEncoding];
    NSLog(@"jsonStr: %@", jsonStr);
    
    [self callAlbumSettings: jsonStr audioMode: audioMode];
}

- (void)callAlbumSettings: (NSString *)jsonStr
                audioMode: (NSString *)audioMode {
    NSLog(@"callAlbumSettings");
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSString *response = [boxAPI albumsettings: [wTools getUserID]
                                             token: [wTools getUserToken]
                                          album_id: self.albumid
                                          settings: jsonStr];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response != nil) {
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"AlbumCollectionViewController");
                    NSLog(@"callAlbumSettings");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"albumsettings"
                                         textStr: @""
                                            data: nil
                                           image: nil
                                         jsonStr: jsonStr
                                       audioMode: audioMode
                                          option: @""];
                } else {
                    NSLog(@"Get Real Response");
                    [self stopRipple];
                    
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    //if ([dic[@"result"]boolValue]) {
                    if ([dic[@"result"] isEqualToString: @"SYSTEM_OK"]) {
                        NSLog(@"dic: %@", dic);
                        
                        self.audioMode = audioMode;
                        
                        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                        style.messageColor = [UIColor whiteColor];
                        style.backgroundColor = [UIColor secondMain];
                        
                        [self.view makeToast: @"音 效 播 放 模 式 已 切 換"
                                    duration: 2.0
                                    position: CSToastPositionBottom
                                       style: style];
                    } else if ([dic[@"result"] isEqualToString: @"SYSTEM_ERROR"]) {
                        NSLog(@"失敗： %@", dic[@"message"]);
                        NSString *msg = dic[@"message"];
                        
                        if (msg == nil) {
                            msg = NSLocalizedString(@"Host-NotAvailable", @"");
                        }
                        [self showCustomErrorAlert: msg];
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

- (void)setupWhenViewWillDisappear {
    if (self.avPlayer != nil) {
        NSLog(@"self.avPlayer != nil");
        [self.avPlayer pause];
        [self.avPlayer seekToTime: kCMTimeZero];
        isPlayingAudio = NO;
    }
    
    [self removeObserAndNotificationAndRipple];
}


- (void)callAlbumSettings {
    NSLog(@"callAlbumSettings");
    NSMutableDictionary *settingsDic = [NSMutableDictionary new];
    [settingsDic setValue: @"close" forKey: @"act"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: settingsDic
                                                       options: 0
                                                         error: nil];
    NSString *jsonString = [[NSString alloc] initWithData: jsonData
                                                 encoding: NSUTF8StringEncoding];
    
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
        NSString *response = [boxAPI albumsettings: [wTools getUserID]
                                             token: [wTools getUserToken]
                                          album_id: self.albumid
                                          settings: jsonString];
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
                NSLog(@"response from albumsettings: %@", response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"AlbumCreationViewController");
                    NSLog(@"callAlbumSettings");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"albumsettings"
                                         textStr: @""
                                            data: nil
                                           image: nil
                                         jsonStr: @""
                                       audioMode: @""
                                          option: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    NSLog(@"dic: %@", dic);
                    
                    if ([dic[@"result"] isEqualToString: @"SYSTEM_OK"]) {
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setObject: [NSNumber numberWithBool: YES] forKey: @"privacyStatusChange"];
                        [defaults synchronize];
                        
                        [self updateAlbumOfDiy: @"back"];
                    } else if ([dic[@"result"] isEqualToString: @"SYSTEM_ERROR"]) {
                        NSLog(@"失敗： %@", dic[@"message"]);
                        NSString *msg = dic[@"message"];
                        
                        if (msg == nil) {
                            msg = NSLocalizedString(@"Host-NotAvailable", @"");
                        }
                        [self showCustomErrorAlert: msg];
                    } else if ([dic[@"result"] isEqualToString: @"TOKEN_ERROR"]) {
                        NSLog(@"resultStr isEqualToString TOKEN_ERROR");
                        
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

#pragma mark - Custom AlertView for Yes and No
- (void)showCustomAlert: (NSString *)msg {
    NSLog(@"showCustomAlert: Msg: %@", msg);
    
    CustomIOSAlertView *alertBackView = [[CustomIOSAlertView alloc] init];
    //[alertBackView setContainerView: [self createContainerView: msg]];
    [alertBackView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertBackView.arrangeStyle = @"Horizontal";
    
    [alertBackView setButtonTitles: [NSMutableArray arrayWithObjects: @"取消", @"確定", nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertBackView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor whiteColor],nil]];
    [alertBackView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
    [alertBackView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    
    __weak CustomIOSAlertView *weakAlertBackView = alertBackView;
    __weak typeof(self) weakSelf = self;
    [alertBackView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertBackView, int buttonIndex) {
        __strong typeof(weakSelf) stSelf = weakSelf;
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertBackView tag]);
        [weakAlertBackView close];
        
        if (buttonIndex == 0) {
            
        } else {
            // When pressing back button, the audio should be stopped
            [stSelf setupWhenViewWillDisappear];
            
            CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
            style.messageColor = [UIColor whiteColor];
            style.backgroundColor = [UIColor firstGrey];
            
            [stSelf.view makeToast: @"作品保存中...請稍候"
                          duration: 2.0
                          position: CSToastPositionBottom
                             style: style];
            
            if (stSelf->ImageDataArr.count == 0) {
                // if there is no image then should set to close
                [stSelf callAlbumSettings];
            } else {
                [stSelf updateAlbumOfDiy: @"back"];
            }
        }
    }];
    [alertBackView setUseMotionEffects: YES];
    [alertBackView show];
}

- (UIView *)createContainerView: (NSString *)msg
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

#pragma mark - CustomAlertForPermission
- (void)showPermissionAlert: (NSString *)msg
{
    CustomIOSAlertView *alertPermissionView = [[CustomIOSAlertView alloc] init];
    //[alertPermissionView setContainerView: [self createContainerViewForPermission: msg]];
    [alertPermissionView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertPermissionView.arrangeStyle = @"Horizontal";
    
    [alertPermissionView setButtonTitles: [NSMutableArray arrayWithObjects: @"取消", @"確定", nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertPermissionView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor whiteColor],nil]];
    [alertPermissionView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
    [alertPermissionView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    
    __weak CustomIOSAlertView *weakAlertPermissionView = alertPermissionView;
    [alertPermissionView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertPermissionView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertPermissionView tag]);
        
        [weakAlertPermissionView close];
        
        if (buttonIndex == 0) {
            
        } else {
            [self deleteAudioOfDiy];
        }
    }];
    [alertPermissionView setUseMotionEffects: YES];
    [alertPermissionView show];
}

- (UIView *)createContainerViewForPermission: (NSString *)msg
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

#pragma mark - CustomAlertForDeletingImageOrVideo
- (void)showCustomAlertForDeletingImageOrVideo: (NSString *)msg
                                          type: (NSString *)type
{
    CustomIOSAlertView *alertDeletingImageView = [[CustomIOSAlertView alloc] init];
    //[alertDeletingImageView setContainerView: [self createContainerViewForDeletingImageOrVideo: msg]];
    [alertDeletingImageView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertDeletingImageView.arrangeStyle = @"Horizontal";
    
    [alertDeletingImageView setButtonTitles: [NSMutableArray arrayWithObjects: @"取消", @"確定", nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertDeletingImageView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor whiteColor],nil]];
    [alertDeletingImageView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
    [alertDeletingImageView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    
    __weak CustomIOSAlertView *weakAlertDeletingImageView = alertDeletingImageView;
    [alertDeletingImageView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertDeletingImageView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertDeletingImageView tag]);
        
        [weakAlertDeletingImageView close];
        
        if (buttonIndex == 0) {
            
        } else {
            if ([type isEqualToString: @"Image"]) {
                [self deletePhotoOfDiy];
            } else if ([type isEqualToString: @"Video"]) {
                [self deleteVideoOfDiy];
            }
        }
    }];
    [alertDeletingImageView setUseMotionEffects: YES];
    [alertDeletingImageView show];
}

- (UIView *)createContainerViewForDeletingImageOrVideo: (NSString *)msg
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

#pragma mark - Custom AlertView For Text
- (void)showTextEditing {
    NSLog(@"showTextEditing");
    
    UIImage *imgForText1 = [UIImage imageNamed: @"icon_cancel_pink500_120x120"];
    UIImage *imgForText2 = [UIImage imageNamed: @"icon_comfirm_teal500_120x120"];
    
    OldCustomAlertView *alertViewForText = [[OldCustomAlertView alloc] init];
    [alertViewForText setContainerView: [self createViewForText]];
    alertViewForText.useImages = YES;
    [alertViewForText setButtonImages: [NSMutableArray arrayWithObjects: imgForText1, imgForText2, nil]];
    
    __weak typeof(self) weakSelf = self;
    __weak OldCustomAlertView *weakAlertViewForText = alertViewForText;
    [alertViewForText setOnButtonTouchUpInside:^(OldCustomAlertView *alertViewForText, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertViewForText tag]);
        [weakAlertViewForText close];
        
        if (buttonIndex == 0) {
            NSLog(@"0");
        } else if (buttonIndex == 1) {
            NSLog(@"1");
            [weakSelf setUpTextAdding];
        } else {
            NSLog(@"buttonIndex: %d", buttonIndex);
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
    textV.textColor = [UIColor blackColor];
    textV.backgroundColor = btnVColor;
    textV.frame = CGRectMake(5, 10, buttonView.bounds.size.width - 10, buttonView.bounds.size.height - 40);
    textV.editable = YES;
    textV.returnKeyType = UIReturnKeyNext;
    
    UILabel *placeHolderLabel = [[UILabel alloc] init];
    placeHolderLabel.text = @"給這頁作品加點介紹吧！";
    placeHolderLabel.numberOfLines = 0;
    placeHolderLabel.textColor = [UIColor lightGrayColor];
    [placeHolderLabel sizeToFit];
    [textV addSubview: placeHolderLabel];
    
    placeHolderLabel.font = [UIFont fontWithName: @"TrebuchetMS" size: 15.0f];
    
    [textV setValue: placeHolderLabel forKey: @"_placeholderLabel"];
    
    NSLog(@"textForDescription: %@", textForDescription);
    
    textV.text = textForDescription;
    textV.delegate = self;
    
    [buttonView addSubview: textV];
    
    /*
     // Through running, we found there is a _placeHolderLabel iVar
     unsigned int count = 0;
     Ivar *ivars = class_copyIvarList([UITextView class], &count);
     
     for (int i = 0; i < count; i++) {
     Ivar ivar = ivars[i];
     const char *name = ivar_getName(ivar);
     NSString *objcName = [NSString stringWithUTF8String: name];
     NSLog(@"%d : %@", i, objcName);
     }
     */
    
    return buttonView;
}

#pragma mark - CustomAlertForText
- (void)showCustomAlertForText: (NSString *)msg
{
    CustomIOSAlertView *alertTextView = [[CustomIOSAlertView alloc] init];
    //[alertTextView setContainerView: [self createContainerViewForText: msg]];
    [alertTextView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertTextView.arrangeStyle = @"Horizontal";
    
    [alertTextView setButtonTitles: [NSMutableArray arrayWithObjects: @"取消", @"確定", nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertTextView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor whiteColor],nil]];
    [alertTextView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
    [alertTextView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    
    __weak CustomIOSAlertView *weakAlertTextView = alertTextView;
    [alertTextView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertTextView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertTextView tag]);
        
        [weakAlertTextView close];
        
        if (buttonIndex == 0) {
            
        } else {
            [self callUpdatePhotoOfDiyWithoutPhoto: @""];
        }
    }];
    [alertTextView setUseMotionEffects: YES];
    [alertTextView show];
}

- (UIView *)createContainerViewForText: (NSString *)msg
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

#pragma mark - CustomAlertForAudio
- (void)showCustomAlertForAudio: (NSString *)msg
{
    CustomIOSAlertView *alertAudioView = [[CustomIOSAlertView alloc] init];
    //[alertAudioView setContainerView: [self createContainerViewForAudio: msg]];
    [alertAudioView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertAudioView.arrangeStyle = @"Horizontal";
    
    [alertAudioView setButtonTitles: [NSMutableArray arrayWithObjects: @"取消", @"確定", nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertAudioView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor whiteColor],nil]];
    [alertAudioView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
    [alertAudioView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    
    __weak CustomIOSAlertView *weakAlertAudioView = alertAudioView;
    [alertAudioView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertAudioView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertAudioView tag]);
        
        [weakAlertAudioView close];
        
        if (buttonIndex == 0) {
            
        } else {
            [self deleteAudioOfDiy];
        }
    }];
    [alertAudioView setUseMotionEffects: YES];
    [alertAudioView show];
}

- (UIView *)createContainerViewForAudio: (NSString *)msg
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

#pragma mark - showCustomAudioModeCheckAlert
- (void)showCustomAudioModeCheckAlert: (NSString *)msg
{
    CustomIOSAlertView *alertAudioModeView = [[CustomIOSAlertView alloc] init];
    //[alertAudioModeView setContainerView: [self createAudioModeCheckContainerView: msg]];
    [alertAudioModeView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertAudioModeView.arrangeStyle = @"Horizontal";
    
    [alertAudioModeView setButtonTitles: [NSMutableArray arrayWithObjects: @"取消", @"確定", nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertAudioModeView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor whiteColor],nil]];
    [alertAudioModeView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
    [alertAudioModeView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    
    __weak CustomIOSAlertView *weakAlertAudioModeView = alertAudioModeView;
    [alertAudioModeView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertAudioModeView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertAudioModeView tag]);
        
        [weakAlertAudioModeView close];
        
        if (buttonIndex == 0) {
            [self enableRecordAndPlayBtn];
        } else {
            [self changeAudioMode: @"plural"];
        }
    }];
    [alertAudioModeView setUseMotionEffects: YES];
    [alertAudioModeView show];
}

- (UIView *)createAudioModeCheckContainerView: (NSString *)msg
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

#pragma mark - Custom Error Alert Method
- (void)showCustomErrorAlert: (NSString *)msg
{
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
#pragma mark - Custom Method for TimeOut
- (void)processUpdate{
    [recordPausePlayBtn setImage: [UIImage imageNamed: @"ic200_micro_white"] forState: UIControlStateNormal];
    audioBgView.hidden = YES;
    deleteAudioBtn.hidden = YES;
    
    isRecorded = NO;
}
- (void)showCustomTimeOutAlert: (NSString *)msg
                  protocolName: (NSString *)protocolName
                       textStr: (NSString *)textStr
                          data: (NSData *)data
                         image: (UIImage *)image
                       jsonStr: (NSString *)jsonStr
                     audioMode: (NSString *)audioMode
                        option: (NSString *)option
{
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
    [alertTimeOutView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey],nil]];
    [alertTimeOutView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor whiteColor], nil]];
    [alertTimeOutView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    
    __weak typeof(self) weakSelf = self;
    __weak CustomIOSAlertView *weakAlertTimeOutView = alertTimeOutView;
    [alertTimeOutView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertTimeOutView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertTimeOutView tag]);
        
        [weakAlertTimeOutView close];
        
        if (buttonIndex == 0) {
            if ([protocolName isEqualToString: @"updateAudioOfDiy"]) {
                [weakSelf processUpdate];
            }
        } else {
            if ([protocolName isEqualToString: @"callUpdatePhotoOfDiyWithoutPhoto"]) {
                [weakSelf callUpdatePhotoOfDiyWithoutPhoto: textStr];
            } else if ([protocolName isEqualToString: @"callUpdatePhotoOfDiyWithPhoto"]) {
                [weakSelf callUpdatePhotoOfDiyWithPhoto: image];
            } else if ([protocolName isEqualToString: @"deleteAudioOfDiy"]) {
                [weakSelf deleteAudioOfDiy];
            } else if ([protocolName isEqualToString: @"getalbumofdiy"]) {
                [weakSelf reload: nil];
            } else if ([protocolName isEqualToString: @"getcooperation"]) {
                [weakSelf getCooperation];
            } else if ([protocolName isEqualToString: @"updatealbumofdiy"]) {
                [weakSelf updateAlbumOfDiy: option];
            } else if ([protocolName isEqualToString: @"deletephotoofdiy"]) {
                [weakSelf deletePhotoOfDiy];
            } else if ([protocolName isEqualToString: @"deleteVideoOfDiy"]) {
                [weakSelf deleteVideoOfDiy];
            } else if ([protocolName isEqualToString: @"insertVideoOfDiy"]) {
                [weakSelf callInsertVideoOfDiy: data];
            } else if ([protocolName isEqualToString: @"updateAudioOfDiy"]) {
                [weakSelf updateAudio];
            } else if ([protocolName isEqualToString: @"albumsettings"]) {
                [weakSelf callAlbumSettings];
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

#pragma mark - TemplateViewControllerDelegate Method
- (void)uploadPhotoDidComplete:(TemplateViewController *)controller
{
    NSLog(@"uploadPhotoDidComplete");
    [self reload: nil];
}

@end
