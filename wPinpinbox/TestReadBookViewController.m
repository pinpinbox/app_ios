//
//  TestReadBookViewController.m
//  wPinpinbox
//
//  Created by David on 6/13/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "TestReadBookViewController.h"

#import "UICustomLineLabel.h"
#import "MyScrollView.h"
#import "wTools.h"
#import "YoutubeViewController.h"
#import "VideoViewController.h"
//#import "PagetextViewController.h"
#import "PageNavigationController.h"
#import "CalbumlistViewController.h"
#import "RetrievealbumpViewController.h"
#import "AppDelegate.h"
#import "OfflineViewController.h"
#import "boxAPI.h"
#import "OpenUDID.h"

#import "Remind.h"

#import "CustomIOSAlertView.h"
#import "OldCustomAlertView.h"

#import <SafariServices/SafariServices.h>
#import "MZUtility.h"
#import "EventPostViewController.h"

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

#import "PreviewbookViewController.h"
#import "CurrencyViewController.h"

#import "NSString+MD5.h"
#import "FTWCache.h"
#import "UIView+Toast.h"

#import "MBProgressHUD.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import <FBSDKShareKit/FBSDKShareLinkContent.h>
#import <FBSDKShareKit/FBSDKShareDialog.h>

#import "YTVimeoExtractor.h"
#import <CoreData/CoreData.h>
#import "MyLayout.h"
#import "NewMessageBoardViewController.h"
#import "UIColor+Extensions.h"
#import "BuyPPointViewController.h"
#import "AlbumInfoViewController.h"
#import "AsyncImageView.h"

#import "MyAVPlayerViewController.h"
#import "DDAUIActionSheetViewController.h"
#import "MapShowingViewController.h"
//#import "NewEventPostViewController.h"
#import "AlbumCollectionViewController.h"
#import "GlobalVars.h"

#import <SDWebImage/UIImageView+WebCache.h>

#import "LabelAttributeStyle.h"

#import "ZOZolaZoomTransition.h"
#import "ExchangeInfoEditViewController.h"

typedef void (^FBBlock)(void);typedef void (^FBBlock)(void);

//static NSString *sharingLink = @"http://www.pinpinbox.com/index/album/content/?album_id=%@%@";
//static NSString *sharingLinkWithoutAutoPlay = @"http://www.pinpinbox.com/index/album/content/?album_id=%@";
static NSString *autoPlayStr = @"&autoplay=1";


static void *AVPlayerDemoPlaybackViewControllerRateObservationContext = &AVPlayerDemoPlaybackViewControllerRateObservationContext;
static void *AVPlayerDemoPlaybackViewControllerStatusObservationContext = &AVPlayerDemoPlaybackViewControllerStatusObservationContext;
static void *AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext = &AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext;

@interface TestReadBookViewController () <MyScrollViewDataSource1, UIScrollViewDelegate, SFSafariViewControllerDelegate, UITextViewDelegate, FBSDKSharingDelegate, NewMessageBoardViewControllerDelegate, AlbumInfoViewControllerDelegate, BuyPPointViewControllerDelegate, UITextFieldDelegate, DDAUIActionSheetViewControllerDelegate, MapShowingViewControllerDelegate, ZOZolaZoomTransitionDelegate, UINavigationControllerDelegate, ExchangeInfoEditViewControllerDelegate, UIGestureRecognizerDelegate>
{
    UITapGestureRecognizer *tapGR;
    BOOL isNavBarHidden;
    BOOL isLikes;
    
    NSInteger albumPoint;
    
    BOOL isOwn;
    
    __weak IBOutlet UICustomLineLabel *mytitle;
    __weak IBOutlet UIView *showview;
    
    //MyScrollView *mySV;
    NSMutableArray *datalist;
    NSString *file;
    
    //BOOL readyToPlay;
    
    NSDictionary *bookdata;
    BOOL isfile;
    
    NSMutableArray *audiobool;
    
    BOOL isplayaudio;
    BOOL playWholeAlbum;
    NSString *audioMode;
    
    UIButton *tmpbtn;
    UIView *tmpview;
    
    NSDictionary *locdata;
    
    // For Slot
    //NSString *giftImage;
    //NSString *giftName;
    //NSString *photoUseForUserId;
    
    UIView *giftView;
    UIButton *exchangeButton;
    UILabel *exchangeLabel;
    UIImageView *exchangeGiftImageView;
    UILabel *giftLabel;
    UILabel *noticeLabel;
    UIButton *yesButton;
    UIButton *noButton;
    UIButton *exchangeCheckButton;
    
    NSTimer *timer;
    int timeTick;
    UILabel *timeLabel;
    
    // For Exchange
    NSString *giftImage1;
    NSString *giftName1;
    NSString *photoUseForUserId1;
    
    UIView *giftView1;
    UIButton *exchangeButton1;
    UILabel *exchangeLabel1;
    UIImageView *exchangeGiftImageView1;
    UILabel *giftLabel1;
    UILabel *noticeLabel1;
    UIButton *yesButton1;
    UIButton *noButton1;
    UIButton *exchangeCheckButton1;
    
    NSTimer *timer1;
    int timeTick1;
    UILabel *timeLabel1;
    
    
    // For Showing Message of Getting Point
    NSString *missionTopicStr;
    NSString *rewardType;
    NSString *rewardValue;
    NSString *eventUrl;
    NSString *restriction;
    NSString *restrictionValue;
    NSUInteger numberOfCompleted;
    
    OldCustomAlertView *alertView;
    CustomIOSAlertView *alertViewForExchange;
    CustomIOSAlertView *alertViewForGift;
    
    OldCustomAlertView *alertViewForCollect;
    
    NSString *task_for;
    
    // For Photo Caption
    UITextView *myText;
    
    NSString *fileNameForDeletion;
    
    // For checking scrolling right or left
    CGPoint lastContentOffset;
    
    NSInteger selectItem;
    
    NSMutableArray *selectItemArray;
    NSArray *photoArray;
    
    NSInteger userPoint;
    
    
    int _firstVisiblePageIndexBeforeRotation;  // for autorotation
    CGFloat _percentScrolledIntoFirstVisiblePage;
    
    NSUInteger currentPageOffset;
    
    CGFloat oldCVWidth;
    
    BOOL isLandscape;
    BOOL shouldFixPageNumber;
    
    CGRect rectForAVPlayer;
    
    //AVPlayerViewController *videoPlayerVC;
    AVPlayerViewController *playerViewController;
    YoutubeViewController *yv;
    NewMessageBoardViewController *nMBC;
    AlbumInfoViewController *albumInfoVC;
    BuyPPointViewController *bPPVC;
    SFSafariViewController *safariVC;
    
    UITextField *inputField;
    UITextField *selectText;
    MyLinearLayout *vertLayout;
    
    NSUInteger pPoint;
    
    BOOL sponsorTextFieldEditing;
    
    CGRect portraitVertLayoutRect;
    CGRect landscapeVertLayoutRect;
    
    float mRestoreAfterScrubbingRate;
    BOOL seekToZeroBeforePlay;
    id mTimeObserver;
    BOOL isSeeking;
    
    NSString *audioStr;
    
    NSUInteger messageInt;
    NSUInteger likesInt;
    
    BOOL shouldTurnOffAudio;
    
    BOOL isGiftScrollViewScrolling;
}

@property (strong) NSMutableArray *browseArray;
@property (strong, nonatomic) AVPlayer *avPlayer;
@property (strong, nonatomic) AVPlayerItem *avPlayerItem;
@property (assign, nonatomic) BOOL isReadyToPlay;
@property (assign, nonatomic) BOOL isVideoReadyToPlay;

@property (weak, nonatomic) IBOutlet UILabel *pageOrderLabel;

@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet MyLinearLayout *navBarHorzLayout;
@property (weak, nonatomic) IBOutlet UIButton *locationBtn;
@property (weak, nonatomic) IBOutlet UIButton *soundBtn;
@property (weak, nonatomic) IBOutlet UIButton *messageBtn;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;

@property (weak, nonatomic) IBOutlet MyLinearLayout *textAndImageVertLayout;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet MyScrollView *mySV;

@property (nonatomic) DDAUIActionSheetViewController *customMoreActionSheet;
@property (nonatomic) DDAUIActionSheetViewController *customShareActionSheet;

@property (nonatomic) MapShowingViewController *mapShowingActionSheet;

@property (nonatomic) UIVisualEffectView *effectView;

@property (weak, nonatomic) IBOutlet UISlider *mScrubber;

//@property (nonatomic) MyLinearLayout *giftBgV;
@property (nonatomic) NSMutableDictionary *slotDicData;
@property (nonatomic) UIImageView *giftImageView;

@property (strong, nonatomic) NSMutableArray *slotArray;

@end

@implementation TestReadBookViewController

#pragma mark - CoreData Section
- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    
    if ([delegate performSelector: @selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

#pragma mark - Browsing Data
- (void)checkBrowsingDataInDatabaseOrNot {
    // Fetch the data from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName: @"Browse"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey: @"browseDate" ascending: NO];
    [fetchRequest setSortDescriptors: @[sortDescriptor]];
    
    self.browseArray = [[managedObjectContext executeFetchRequest: fetchRequest error: nil] mutableCopy];
    //NSLog(@"self.browseArray: %@", self.browseArray);
    
    for (int i = 0; i < self.browseArray.count; i++) {
        NSManagedObject *browseData = [self.browseArray objectAtIndex: i];
        
        if ([[browseData valueForKey: @"albumId"] isEqualToString: self.albumid]) {
            //NSLog(@"browseData valueForKey albumId is: %@", [browseData valueForKey: @"albumId"]);
            [managedObjectContext deleteObject: [self.browseArray objectAtIndex: i]];
        } else {
            //NSLog(@"browseData valueForKey albumId is not equalToString self.albumId");
        }
    }
}

#pragma mark - Browsing Data

- (void)checkBrowsingDataReachMax {
    //NSLog(@"checkBrowseDataReachMax");
    
    // Fetch the data from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName: @"Browse"];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey: @"browseDate" ascending: NO];
    [fetchRequest setSortDescriptors: @[sortDescriptor]];
    
    self.browseArray = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if (self.browseArray.count >= 20) {
        NSLog(@"browseArray.count is more than 20, so need to be removed the last object");
        [managedObjectContext deleteObject: [self.browseArray lastObject]];
    }
}

- (void)saveBrowsingData: (NSDictionary *)bookData {
    NSLog(@"saveBrowseData");
    NSArray *photoArr = bookData[@"photo"];
    NSString *imageUrlThumbnail = photoArr[0][@"image_url_thumbnail"];
    //NSLog(@"imageUrlThumbnail: %@", photoArr[0][@"image_url_thumbnail"]);
    
    //NSString *imageFolderName = [NSString stringWithFormat: @"%@%@", [wTools getUserID], self.albumid];
    //NSLog(@"imageFolderName: %@", imageFolderName);
    
    // Save data to Core Data
    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *newData = [NSEntityDescription insertNewObjectForEntityForName: @"Browse" inManagedObjectContext: context];
    
    NSLog(@"album name: %@", bookData[@"album"][@"name"]);
    
    if (![self.albumid isKindOfClass: [NSNull class]]) {
        [newData setValue: self.albumid forKey: @"albumId"];
    }
    if (![bookData[@"user"][@"name"] isKindOfClass: [NSNull class]]) {
        [newData setValue: bookData[@"user"][@"name"] forKey: @"author"];
    }
    if (![bookData[@"album"][@"description"] isKindOfClass: [NSNull class]]) {
        [newData setValue: bookData[@"album"][@"description"] forKey: @"descriptionInfo"];
    }
    if (![bookData[@"album"][@"name"] isKindOfClass: [NSNull class]]) {
        [newData setValue: bookData[@"album"][@"name"] forKey: @"title"];
    }
    if (![imageUrlThumbnail isKindOfClass: [NSNull class]]) {
        [newData setValue: imageUrlThumbnail forKey: @"imageUrlThumbnail"];
    }
    if (![[NSDate date] isKindOfClass: [NSNull class]]) {
        [newData setValue: [NSDate date] forKey: @"browseDate"];
    }
    
    NSError *error = nil;
    
    // Save the object to persistent store
    if (![context save: &error]) {
        //NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}

#pragma mark - Slot Data
- (void)checkSlotDataInDatabaseOrNot {
    NSLog(@"checkSlotDataInDatabaseOrNot");
    // Fetch the data from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName: @"Slot"];
    
    self.slotArray = [[managedObjectContext executeFetchRequest: fetchRequest error: nil] mutableCopy];
    NSLog(@"self.slotArray: %@", self.slotArray);
    
    for (int i = 0; i < self.slotArray.count; i++) {
        NSManagedObject *slotData = [self.slotArray objectAtIndex: i];
        NSLog(@"photoId: %ld", [[slotData valueForKey: @"photoId"] integerValue]);
    }
}

- (void)saveSlotData:(NSInteger)photoId {
    NSLog(@"saveSlotData");
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName: @"Slot"];
    self.slotArray = [[context executeFetchRequest: fetchRequest error: nil] mutableCopy];
    NSLog(@"self.slotArray: %@", self.slotArray);
    
    BOOL photoIdExist = NO;
    
    for (int i = 0; i < self.slotArray.count; i++) {
        NSManagedObject *slotData = [self.slotArray objectAtIndex: i];
        NSLog(@"photoId: %ld", [[slotData valueForKey: @"photoId"] integerValue]);
        
        if (photoId == [[slotData valueForKey: @"photoId"] integerValue]) {
            photoIdExist = YES;
        }
    }
    
    if (!photoIdExist) {
        NSManagedObject *newData = [NSEntityDescription insertNewObjectForEntityForName: @"Slot" inManagedObjectContext: context];
        [newData setValue: [NSNumber numberWithInteger: photoId] forKey: @"photoId"];
        
        NSError *error = nil;
        
        // Save the object to persistent store
        if (![context save: &error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    }
}

#pragma mark - View Related Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"TestReadBookViewController viewDidLoad");
    NSLog(@"self.eventId: %@", self.eventId);
    
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    appDelegate.myNav.interactivePopGestureRecognizer.delegate = self;
    
    self.collectionView.pagingEnabled = NO;
    isGiftScrollViewScrolling = NO;
    
    self.navigationController.delegate = self;
    
    // CustomActionSheet
    self.customMoreActionSheet = [[DDAUIActionSheetViewController alloc] init];
    self.customMoreActionSheet.delegate = self;
    self.customMoreActionSheet.topicStr = @"你 想 做 什 麼?";
    
    self.customShareActionSheet = [[DDAUIActionSheetViewController alloc] init];
    self.customShareActionSheet.delegate = self;
    self.customShareActionSheet.topicStr = @"選 擇 分 享 方 式";
    
    self.mapShowingActionSheet = [[MapShowingViewController alloc] init];
    self.mapShowingActionSheet.delegate = self;
    
    albumInfoVC = [[UIStoryboard storyboardWithName: @"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumInfoViewController"];
    
    // To Avoid Crash, because when viewWillDisappear,
    // the rotation function will not be called
    shouldFixPageNumber = NO;
    sponsorTextFieldEditing = NO;
    
    self.isPresented = YES;
    self.isAddingBuyPointVC = NO;
    
    tapGR = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleTap)];
    tapGR.numberOfTapsRequired = 1;
    [showview addGestureRecognizer: tapGR];
    
    self.navBarHorzLayout.gravity = MyMarginGravity_Horz_Right;
    
    self.navBarView.backgroundColor = [UIColor clearColor];
    
    self.textAndImageVertLayout.backgroundColor = [UIColor blackColor];
    self.textAndImageVertLayout.alpha = 0.8;
    self.textAndImageVertLayout.myLeftMargin = self.textAndImageVertLayout.myRightMargin = 0;
    
    self.textView.myBottomMargin = 0;
    self.textView.myWidth = self.view.bounds.size.width - 96;
//    self.textView.myLeftMargin = self.textView.myRightMargin = 48;
//    self.textView.wrapContentWidth = YES;
    
    self.lineView.backgroundColor = [UIColor thirdGrey];
    self.lineView.myLeftMargin = self.lineView.myRightMargin = 0;
    self.lineView.myBottomMargin = self.lineView.myTopMargin = 0;
    
    albumPoint = [self.dic[@"album"][@"point"] integerValue];
    
    isNavBarHidden = NO;
    locdata = nil;
    
    // Default Setting
    // Audio Switch should be set to Off
    // Main Audio Switch
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.audioSwitch = [[defaults objectForKey: @"isAudioPlayedAutomatically"] boolValue];
    NSLog(@"self.audioSwitch: %d", self.audioSwitch);
    //_audioSwitch = YES;
    
    // Check whether video is played or not
    isplayaudio = YES;
    //_fromPageText = NO;
    
    // Check avPlayer is ready or not
    self.isReadyToPlay = NO;
    
    // Turn off audio when going to other view controllers
    shouldTurnOffAudio = NO;
    
    selectItem = 0;
    
    // Reset the data for not releasing the avPlayer instance
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL fromCollectAndDownload = NO;
    [defaults setObject: [NSNumber numberWithBool: fromCollectAndDownload] forKey: @"fromCollectAndDownload"];
    [defaults synchronize];
    
    [self setupForDicFile: self.dic];
    
    messageInt = [self.dic[@"albumstatistics"][@"messageboard"] integerValue];
    isLikes = self.isLikes;
    likesInt = self.likeNumber;
    
//    [self setupFrameForDifferentDevice];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"");
    NSLog(@"TestReadBookViewController viewWillAppear");
    [super viewWillAppear:animated];
    
//    [self setupFrameForDifferentDevice];
    
    [self addKeyboardNotification];
    
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    userPoint = [[userPrefs objectForKey: @"pPoint"] integerValue];
    
    for (UIView *v1 in self.mySV.subviews) {
        for (UIView *v2 in v1.subviews) {
            if (v2.tag == 2) {
                for (UIView *v3 in v2.subviews) {
                    if ([v3 isKindOfClass: [UILabel class]]) {
                        if (v3.tag == 4) {
                            UILabel *currentPointLabel = (UILabel *)v3;
                            currentPointLabel.text = [NSString stringWithFormat: @"現有P點：%ld", (long)userPoint];
                            [currentPointLabel sizeToFit];
                        }
                    }
                }
            }
        }
    }
    [self preparationForViewWillAppear];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    appDelegate.myNav.interactivePopGestureRecognizer.enabled = YES;
    
    [wTools setStatusBarBackgroundColor: [UIColor colorWithRed: 255.0 green: 255.0 blue: 255.0 alpha: 0.0]];
    
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    appDelegate.myNav.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear");
    NSLog(@"TestReadBookViewController");
    
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
    
    [self removeKeyboardNotification];
    
    if (isLandscape) {
        shouldFixPageNumber = YES;
    }
    NSLog(@"shouldFixPageNumber: %d", shouldFixPageNumber);
    
    if (self.isMovingFromParentViewController) {
        NSLog(@"self.isMovingFromParentViewController");
        self.isPresented = NO;
        
        // forces a return to portrait orientation
        NSNumber *value = [NSNumber numberWithInt: UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue: value forKey: @"orientation"];
    }
    
    // NavigationBar Setup
    //self.navigationController.navigationBar.hidden = NO;
    
    [[UIApplication sharedApplication] setStatusBarHidden: NO];
    
    [timer invalidate];
    
    NSLog(@"");
    NSLog(@"msgNumber: %lu", (unsigned long)messageInt);
    NSLog(@"likesNumber: %lu", (unsigned long)likesInt);
    
    if ([self.delegate respondsToSelector: @selector(testReadBookViewControllerViewWillDisappear:likeNumber:isLike:)]) {
        NSLog(@"self.delegate respondsToSelector");
        
        [self.delegate testReadBookViewControllerViewWillDisappear: self likeNumber: likesInt isLike: isLikes];
    }
}

- (void)preparationForViewWillAppear
{
    NSLog(@"preparationForViewWillAppear");
    [self initialValueSetup];
    
    // NavigationBar Setup
    //self.navigationController.navigationBar.hidden = YES;
    
    // comment the line below will cause crash in 4" device
    [[UIApplication sharedApplication] setStatusBarHidden: YES];
    
    // Back to BookViewController, so that means videoPlay is finished
    if (_videoPlay) {
        _videoPlay = NO;
    }
    
    //[[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
    //[[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
    
    // Check audio button is clicked or not
    [self changeAudioButtonImage];
    [self checkAudioData];
}

- (void)setupForDicFile: (NSDictionary *)dic {
    NSLog(@"setupForDicFile");
    NSLog(@"dic: %@", dic);
    
    bookdata = [dic mutableCopy];
    
    // Core Data Setting
    [self checkBrowsingDataInDatabaseOrNot];
    [self checkBrowsingDataReachMax];
    [self saveBrowsingData: bookdata];
    
    datalist = [NSMutableArray new];
    
    datalist = [dic[@"photo"] mutableCopy];
    NSLog(@"");
    //NSLog(@"datalist.count: %lu", (unsigned long)datalist.count);
    
    //NSLog(@"datalist: %@", datalist);
    
    isOwn = [bookdata[@"album"][@"own"] boolValue];
    //NSLog(@"isOwn: %d", isOwn);
    
    if (!isOwn) {
        NSMutableDictionary *collectDic = [NSMutableDictionary new];
        [collectDic setValue: [NSNumber numberWithBool: NO] forKey: @"audio_loop"];
        [collectDic setValue: @"none" forKey: @"audio_refer"];
        [collectDic setValue: [NSNull null] forKey: @"audio_target"];
        [collectDic setValue: @"" forKey: @"description"];
        [collectDic setValue: [NSNumber numberWithInteger: 0] forKey: @"duration"];
        [collectDic setValue: [NSNull null] forKey: @"hyperlink"];
        [collectDic setValue: @"bg200_preview_normal.jpg" forKey: @"image"];
        [collectDic setValue: @"bg200_preview_small.jpg" forKey: @"imageThumbnail"];
        [collectDic setValue: @"" forKey: @"location"];
        [collectDic setValue: @"" forKey: @"name"];
        [collectDic setValue: [NSNumber numberWithInteger: 0] forKey: @"photo_id"];
        [collectDic setValue: @"FinalPage" forKey: @"usefor"];
        [collectDic setValue: @"none" forKey: @"video_refer"];
        [collectDic setValue: [NSNull null] forKey: @"video_target"];
        
        [collectDic setValue: [NSNumber numberWithBool: YES] forKey: @"collect"];
        
        [datalist addObject: collectDic];
    }
    
    selectItemArray = [NSMutableArray new];
    
    for (int i = 0; i < datalist.count; i++) {
        [selectItemArray addObject: @"notSelected"];
    }
    selectItemArray[0] = @"selected";
    audioMode = dic[@"album"][@"audio_mode"];
    mytitle.text = dic[@"album"][@"name"];
    
    CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
    
    //判斷3.5吋或4吋螢幕以載入不同storyboard
    if (iOSDeviceScreenSize.height == 480) {
        showview.frame=CGRectMake(showview.frame.origin.x, showview.frame.origin.y, showview.frame.size.width, 392);
    }
    
//    self.textView.font = [UIFont fontWithName: @"TrebuchetMS-Bold" size: 12.0f];
    self.textView.font = [UIFont systemFontOfSize: 12.0f];
    self.textView.textColor = [UIColor whiteColor];
    //self.textView.backgroundColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.5];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.editable = NO;
//    self.textView.textAlignment = NSTextAlignmentLeft;
    self.textView.heightDime.max(113.6).min(48);
    
    // MyScrollView Setting
    //self.mySV = [[MyScrollView alloc] initWithFrame: CGRectMake(0, 0, showview.bounds.size.width, showview.bounds.size.height)];
    self.mySV.pagingEnabled = YES;
    self.mySV.alwaysBounceHorizontal = YES;
    self.mySV.dataSourceDelegate = self;
    self.mySV.accessibilityIdentifier = @"mySV";
    [self.mySV initWithDelegate: self atPage: 0];
    
    int page = 0;
    page = self.mySV.contentOffset.x / self.mySV.frame.size.width;
    page += 1;
    photoArray = bookdata[@"photo"];
    
    self.pageOrderLabel.text = [NSString stringWithFormat: @"%d / %lu", page, (unsigned long)photoArray.count];
    [self.pageOrderLabel sizeToFit];
    
    //設定音樂開關
    for (int i=0; i<bookdata.count; i++) {
        [audiobool addObject:@"1"];
    }
    
    [self getGoogleAPI];
}

- (void)getGoogleAPI {
    // Location
    NSString *location = bookdata[@"album"][@"location"];
    //NSLog(@"location: %@", location);
    
    if (![location isEqualToString:@""]) {
        @try {
            [MBProgressHUD showHUDAddedTo: self.view animated: YES];
        } @catch (NSException *exception) {
            // Print exception information
            NSLog( @"NSException caught" );
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
            return;
        }
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            NSString *response = [boxAPI api_GET:[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=false",location ] ];
            
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
                    NSLog(@"response from api_GET: %@",response);
                    
                    if ([response isEqualToString: timeOutErrorCode]) {
                        NSLog(@"Time Out Message Return");
                        NSLog(@"TestReadBookViewController");
                        NSLog(@"getGoogleAPI");
                        
                        [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                        protocolName: @"api_GET"
                                            pointStr: @""
                                                 btn: nil
                                                 bgV: nil];
                    } else {
                        NSLog(@"Get Real Response");
                        NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                        
                        locdata = [dic mutableCopy];
                        NSLog(@"locdata: %@", locdata);
                    }
                }
            });
        });
    }
}

- (void)initialValueSetup {
    NSLog(@"initialValueSetup");
    [self btnSetup];
}

- (void)btnSetup {
    NSLog(@"btnSetup");
    
    self.locationBtn.layer.cornerRadius = 8;
    [self.locationBtn addTarget: self action: @selector(locationBtnHighlight:) forControlEvents: UIControlEventTouchDown];
    [self.locationBtn addTarget: self action: @selector(locationBtnNormal:) forControlEvents: UIControlEventTouchUpInside];
    [self.locationBtn addTarget: self action: @selector(locationBtnNormal:) forControlEvents: UIControlEventTouchUpOutside];
    
    //self.locationBtn.hidden = YES;
    
    self.soundBtn.layer.cornerRadius = 8;
    [self.soundBtn addTarget: self action: @selector(soundBtnHighlight:) forControlEvents: UIControlEventTouchDown];
    [self.soundBtn addTarget: self action: @selector(soundBtnNormal:) forControlEvents: UIControlEventTouchUpInside];
    [self.soundBtn addTarget: self action: @selector(soundBtnNormal:) forControlEvents: UIControlEventTouchUpOutside];
    
    [self.mScrubber setThumbImage: [UIImage imageNamed: @"slider-metal-handle"] forState: UIControlStateNormal];
    [self.mScrubber setThumbImage: [UIImage imageNamed: @"slider-metal-handle-highlighted"] forState: UIControlStateHighlighted];
    
    // Default set hidden is YES
    self.soundBtn.hidden = YES;
    self.mScrubber.hidden = YES;
    
    //NSLog(@"self.dic: %@", self.dic);
    
    NSString *location = self.dic[@"photo"][0][@"location"];
    NSLog(@"location: %@", location);
    
    if (![location isKindOfClass: [NSNull class]]) {
        if (![location isEqualToString: @""]) {
            self.locationBtn.hidden = NO;
        } else {
            self.locationBtn.hidden = YES;
        }
    } else {
        self.locationBtn.hidden = NO;
    }
    
    if ([audioMode isEqualToString: @"none"]) {
        self.soundBtn.hidden = YES;
        self.mScrubber.hidden = YES;
    } else if ([audioMode isEqualToString: @"singular"]) {
        self.soundBtn.hidden = NO;
        self.mScrubber.hidden = NO;
    } else if ([audioMode isEqualToString: @"plural"]) {
        NSString *audioTarget = datalist[0][@"audio_target"];
        NSLog(@"audioTarget of First Page Content: %@", audioTarget);
        
        if ([audioTarget isKindOfClass: [NSNull class]]) {
            //NSLog(@"audioTarget is Null");
            self.soundBtn.hidden = YES;
            self.mScrubber.hidden = YES;
        } else {
            //NSLog(@"audioTarget is not Null");
            self.soundBtn.hidden = NO;
            self.mScrubber.hidden = NO;
        }
    }
    
    self.messageBtn.layer.cornerRadius = 8;
    [self.messageBtn addTarget: self action: @selector(messageBtnHighlight:) forControlEvents: UIControlEventTouchDown];
    [self.messageBtn addTarget: self action: @selector(messageBtnNormal:) forControlEvents: UIControlEventTouchUpInside];
    [self.messageBtn addTarget: self action: @selector(messageBtnNormal:) forControlEvents: UIControlEventTouchUpOutside];
    
    if (isLikes) {
        [self.likeBtn setImage: [UIImage imageNamed: @"ic200_ding_pink"] forState: UIControlStateNormal];
    } else {
        [self.likeBtn setImage: [UIImage imageNamed: @"ic200_ding_white"] forState: UIControlStateNormal];
    }
    
    self.likeBtn.layer.cornerRadius = 8;
    [self.likeBtn addTarget: self action: @selector(likeBtnHighlight:) forControlEvents: UIControlEventTouchDown];
    [self.likeBtn addTarget: self action: @selector(likeBtnNormal:) forControlEvents: UIControlEventTouchUpInside];
    [self.likeBtn addTarget: self action: @selector(likeBtnNormal:) forControlEvents: UIControlEventTouchUpOutside];
    
    self.moreBtn.layer.cornerRadius = 8;
    [self.moreBtn addTarget: self action: @selector(moreBtnHighlight:) forControlEvents: UIControlEventTouchDown];
    [self.moreBtn addTarget: self action: @selector(moreBtnNormal:) forControlEvents: UIControlEventTouchUpInside];
    [self.moreBtn addTarget: self action: @selector(moreBtnNormal:) forControlEvents: UIControlEventTouchUpOutside];
}

- (void)checkAudioData {
    NSLog(@"");
    NSLog(@"checkAudioData");
    // Check audioMode first
    NSLog(@"");
    NSLog(@"audioMode: %@", audioMode);
    
    if (![audioMode isEqualToString: @"none"]) {
        if ([audioMode isEqualToString: @"singular"]) {
            audioStr = bookdata[@"album"][@"audio_target"];
            playWholeAlbum = YES;
        } else if ([audioMode isEqualToString: @"plural"]) {
            // Get the page value for playing the audio accordingly
            int page = self.mySV.contentOffset.x / self.mySV.frame.size.width;
            //NSLog(@"page: %d", page);
            
            audioStr = datalist[page][@"audio_target"];
            
            playWholeAlbum = NO;
        }
    } else {
        audioStr = nil;
    }
    
    NSLog(@"audioStr: %@", audioStr);
    NSLog(@"self.audioSwitch: %d", self.audioSwitch);
    
    if (audioStr == nil) {
        NSLog(@"audioStr == nil");
        audioStr = @"";
    } else if ([audioStr isEqual: [NSNull null]]) {
        NSLog(@"audioStr is equal to NSNull null");
        audioStr = @"";
    }
    
    if (![audioStr isEqualToString: @""]) {
        if (self.audioSwitch) {
            if (self.avPlayer == nil) {
                NSLog(@"avPlayer is nil, needs to be initialized");
                [self avPlayerSetUp: audioStr];
            } else {
                NSLog(@"avPlayer is initialized");
                
                if (self.isReadyToPlay) {
                    if (isplayaudio) {
                        [self.avPlayer play];
                    }
                }
            }
        }
    }
    
    /*
     if (audioStr != nil || ![audioStr isEqual: [NSNull null]]) {
     NSLog(@"audioStr is not nil or NSNull null");
     if (![audioStr isEqualToString: @""]) {
     if (self.audioSwitch) {
     if (self.avPlayer == nil) {
     NSLog(@"avPlayer is nil, needs to be initialized");
     [self avPlayerSetUp: audioStr];
     } else {
     NSLog(@"avPlayer is initialized");
     
     if (self.isReadyToPlay) {
     if (isplayaudio) {
     [self.avPlayer play];
     }
     }
     }
     }
     }
     } else {
     NSLog(@"audioStr is nil");
     }
     */
}

#pragma mark - Button Selector Methods
- (void)locationBtnHighlight: (UIButton *)sender {
    [self showMapViewActionSheet];
}

- (void)locationBtnNormal: (UIButton *)sender {
}

- (void)soundBtnHighlight: (UIButton *)sender {
    [self playbool: nil];
}

- (void)soundBtnNormal: (UIButton *)sender {
}

- (void)messageBtnHighlight: (UIButton *)sender {
    NSLog(@"messageBtnHighlight");
    
    if (sponsorTextFieldEditing) {
        [self hideKeyboard];
    }
    nMBC = [[UIStoryboard storyboardWithName: @"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"NewMessageBoardViewController"];
    nMBC.type = @"album";
    nMBC.typeId = self.albumid;
    nMBC.delegate = self;
    nMBC.view.frame = self.view.frame;
    [self.view addSubview: nMBC.view];
}

// Hide keyboard when sponsor textField is editing
- (void)hideKeyboard {
    NSLog(@"hideKeyboard");
    
    sponsorTextFieldEditing = NO;
    [inputField resignFirstResponder];
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    NSLog(@"deviceOrientation: %ld", (long)deviceOrientation);
    
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    NSLog(@"interfaceOrientation: %ld", (long)interfaceOrientation);
    NSLog(@"");
    
    if (interfaceOrientation == 1) {
        NSLog(@"interfaceOrientation: %ld", (long)interfaceOrientation);
        vertLayout.frame = portraitVertLayoutRect;
    }
    
    if (interfaceOrientation == 3 || interfaceOrientation == 4) {
        NSLog(@"interfaceOrientation: %ld", (long)interfaceOrientation);
        vertLayout.frame = landscapeVertLayoutRect;
    }
}

- (void)messageBtnNormal: (UIButton *)sender {
}

- (void)newMessageBoardViewControllerDisappear:(NewMessageBoardViewController *)controller
                                     msgNumber:(NSUInteger)msgNumber {
    NSLog(@"msgNumber: %lu", (unsigned long)msgNumber);
    messageInt = msgNumber;
    [nMBC.view removeFromSuperview];
}

- (void)likeBtnHighlight: (UIButton *)sender {
    if (isLikes) {
        [self deleteAlbumToLikes];
    } else {
        [self insertAlbumToLikes];
    }
}

- (void)likeBtnNormal: (UIButton *)sender {
}

- (void)moreBtnHighlight: (UIButton *)sender {
    [self showCustomMoreActionSheet];
}

- (void)moreBtnNormal: (UIButton *)sender {
}

#pragma mark - Likes Method
- (void)insertAlbumToLikes
{
    NSLog(@"insertAlbumToLikes");
    
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
        NSString *response = [boxAPI insertAlbum2Likes: [wTools getUserID]
                                                 token: [wTools getUserToken]
                                               albumId: self.albumid];
        
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
                //NSLog(@"response: %@", response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"TestReadBookViewController");
                    NSLog(@"insertAlbumToLikes");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"insertAlbum2Likes"
                                        pointStr: @""
                                             btn: nil
                                             bgV: nil];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] boolValue]) {
                        likesInt++;
                        
                        [self.likeBtn setImage: [UIImage imageNamed: @"ic200_ding_pink"] forState: UIControlStateNormal];
                        //self.likeNumberLabel.text = [NSString stringWithFormat: @"%ld", (long)likesInt];
                        
                        isLikes = !isLikes;
                        NSLog(@"isLikes: %d", isLikes);
                    } else {
                        NSLog(@"失敗：%@", dic[@"message"]);
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

- (void)deleteAlbumToLikes
{
    NSLog(@"deleteAlbumToLikes");
    
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
        NSString *response = [boxAPI deleteAlbum2Likes: [wTools getUserID]
                                                 token: [wTools getUserToken]
                                               albumId: self.albumid];
        
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
                //NSLog(@"response: %@", response);
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"TestReadBookViewController");
                    NSLog(@"deleteAlbumToLikes");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"deleteAlbum2Likes"
                                        pointStr: @""
                                             btn: nil
                                             bgV: nil];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] boolValue]) {
                        likesInt--;
                        
                        [self.likeBtn setImage: [UIImage imageNamed: @"ic200_ding_white"] forState: UIControlStateNormal];
                        //self.likeNumberLabel.text = [NSString stringWithFormat: @"%ld", (long)likesInt];
                        
                        isLikes = !isLikes;
                    } else {
                        NSLog(@"失敗：%@", dic[@"message"]);
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

#pragma mark -

- (void)handleTap
{
    NSLog(@"handleTap");
    
    isNavBarHidden = !isNavBarHidden;
    
    self.navBarView.hidden = isNavBarHidden;
    self.textAndImageVertLayout.hidden = isNavBarHidden;
    //self.collectionView.hidden = isNavBarHidden;
    //self.lineView.hidden = isNavBarHidden;
}

#pragma mark - CustomActionSheet
- (void)showCustomMoreActionSheet {
    NSLog(@"");
    NSLog(@"showCustomMoreActionSheet");
    
    // Blur View Setting
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
    
    // Custom ActionSheet Setting
    [self.view addSubview: self.customMoreActionSheet.view];
    [self.customMoreActionSheet viewWillAppear: NO];
    
    albumPoint = [self.dic[@"album"][@"point"] integerValue];
    
    // Check if albumUserId is same as userId, then don't add collectBtn
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"id: %@", [userDefaults objectForKey: @"id"]);
    NSLog(@"self.dic user user_id: %d", [self.dic[@"user"][@"user_id"] intValue]);
    
    NSInteger userId = [[userDefaults objectForKey: @"id"] intValue];
    NSInteger albumUserId = [self.dic[@"user"][@"user_id"] intValue];
    
    NSString *collectStr;
    NSString *btnStr;
    
    if (albumUserId != userId) {
        if (!isOwn) {
            if (albumPoint == 0) {
                collectStr = @"收藏";
            } else if (albumPoint > 0) {
                collectStr = [NSString stringWithFormat: @"收藏(需要贊助%ldP)", (long)albumPoint];
                btnStr = @"贊助更多";
            }
        } else {
            collectStr = @"已收藏";
            btnStr = @"";
        }
        
        [self.customMoreActionSheet addSelectItem: @"ic200_collect_dark.png" title: collectStr btnStr: btnStr tagInt: 1 identifierStr: @"collectItem" isCollected: isOwn];
    }
    
    [self.customMoreActionSheet addSelectItem: @"ic200_share_dark.png" title: @"分享" btnStr: @"" tagInt: 2 identifierStr: @"shareItem"];
    [self.customMoreActionSheet addSelectItem: @"ic200_info_dark.png" title: @"作品資訊" btnStr: @"" tagInt: 3 identifierStr: @"albumInfoItem"];
    
    __weak typeof(self) weakSelf = self;
    __block NSInteger weakAlbumPoint = albumPoint;
    __weak NSDictionary *weakLocData = locdata;
    __weak AlbumInfoViewController *weakAlbumInfoVC = albumInfoVC;
    
    self.customMoreActionSheet.customButtonBlock = ^(BOOL selected) {
        NSLog(@"customButtonBlock press");
        
        [weakSelf.mySV moveToPage: datalist.count - 1];
        [weakSelf.customMoreActionSheet slideOut];
    };
    
    self.customMoreActionSheet.customViewBlock = ^(NSInteger tagId, BOOL isTouchDown, NSString *identifierStr) {
        NSLog(@"");
        NSLog(@"self.customMoreActionSheet.customViewBlock");
        NSLog(@"tagId: %ld", (long)tagId);
        NSLog(@"isTouchDown: %d", isTouchDown);
        NSLog(@"identifierStr: %@", identifierStr);
        
        if ([identifierStr isEqualToString: @"collectItem"]) {
            NSLog(@"collectItem is pressed");
            
            if (weakAlbumPoint == 0) {
                [weakSelf buyAlbum];
            } else {
                NSString *msgStr = [NSString stringWithFormat: @"確定贊助%ldP?", (long)weakAlbumPoint];
                [weakSelf showBuyAlbumCustomAlert: msgStr option: @"buyAlbum" pointStr: [NSString stringWithFormat: @"%ld", (long)weakAlbumPoint]];
            }
            
        } else if ([identifierStr isEqualToString: @"shareItem"]) {
            NSLog(@"shareItem is pressed");
            
            [weakSelf checkTaskComplete];
            //[weakSelf showCustomShareActionSheet];
        } else if ([identifierStr isEqualToString: @"albumInfoItem"]) {
            NSLog(@"reportItem is pressed");
            
            if (weakLocData) {
                NSLog(@"locdata exists");
                NSLog(@"locdata: %@", weakLocData);
                weakAlbumInfoVC.localData = weakLocData;
            }
            
            weakAlbumInfoVC.data = weakSelf.dic;
            //NSLog(@"self.dic: %@", weakSelf.dic);
            weakAlbumInfoVC.delegate = weakSelf;
            weakAlbumInfoVC.view.frame = weakSelf.view.frame;
            
            NSLog(@"check locdata whether exist or not");
            
            [weakSelf.view addSubview: weakAlbumInfoVC.view];
        }
    };
}

- (void)showCustomShareActionSheet {
    // Blur View Setting
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
    
    // Custom ActionSheet Setting
    [self.view addSubview: self.customShareActionSheet.view];
    [self.customShareActionSheet viewWillAppear: NO];
    
    [self.customShareActionSheet addSelectItem: @"" title: @"獎勵分享(facebook)" btnStr: @"" tagInt: 1 identifierStr: @"fbSharing"];
    [self.customShareActionSheet addSelectItem: @"" title: @"一般分享" btnStr: @"" tagInt: 2 identifierStr: @"normalSharing"];
    
    __weak typeof(self) weakSelf = self;
    
    self.customShareActionSheet.customViewBlock = ^(NSInteger tagId, BOOL isTouchDown, NSString *identifierStr) {
        NSLog(@"");
        NSLog(@"customShareActionSheet.customViewBlock executes");
        NSLog(@"tagId: %ld", (long)tagId);
        NSLog(@"isTouchDown: %d", isTouchDown);
        NSLog(@"identifierStr: %@", identifierStr);
        
        if ([identifierStr isEqualToString: @"fbSharing"]) {
            NSLog(@"fbSharing is pressed");
            
            FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
            
            if ([weakSelf.eventJoin isEqual: [NSNull null]]) {
                content.contentURL = [NSURL URLWithString: [NSString stringWithFormat: sharingLinkWithAutoPlay, weakSelf.albumid, autoPlayStr]];
            } else {
                content.contentURL = [NSURL URLWithString: [NSString stringWithFormat: sharingLinkWithoutAutoPlay, weakSelf.albumid]];
            }
            [FBSDKShareDialog showFromViewController: weakSelf
                                         withContent: content
                                            delegate: weakSelf];
        } else if ([identifierStr isEqualToString: @"normalSharing"]) {
            NSLog(@"normalSharing is pressed");
            NSString *message;
            
            if ([weakSelf.eventJoin isEqual: [NSNull null]]) {
                message = [NSString stringWithFormat: sharingLinkWithAutoPlay, weakSelf.albumid, autoPlayStr];
            } else {
                message = [NSString stringWithFormat: sharingLinkWithoutAutoPlay, weakSelf.albumid];
            }
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems: [NSArray arrayWithObjects: message, nil] applicationActivities: nil];
            [weakSelf presentViewController: activityVC animated: YES completion: nil];
        }
    };
}

- (void)showMapViewActionSheet
{
    NSLog(@"");
    NSLog(@"showMapViewActionSheet");
    
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
    
    // Custom ActionSheet Setting
    int page = self.mySV.contentOffset.x / self.mySV.frame.size.width;
    NSLog(@"page: %d", page);
    NSLog(@"location Str: %@", self.dic[@"photo"][page][@"location"]);
    self.mapShowingActionSheet.locationStr = self.dic[@"photo"][page][@"location"];
    
    [self.view addSubview: self.mapShowingActionSheet.view];
    [self.mapShowingActionSheet viewWillAppear: NO];
}

#pragma mark - DDAUIActionSheetViewControllerDelegate Method
- (void)actionSheetViewDidSlideOut:(DDAUIActionSheetViewController *)controller
{
    NSLog(@"actionSheetViewDidSlideOut");
    //[self.fxBlurView removeFromSuperview];
    [self.effectView removeFromSuperview];
    self.effectView = nil;
}

#pragma mark - MapShowingViewControllerDelegate Method
- (void)mapShowingActionSheetDidSlideOut:(MapShowingViewController *)controller
{
    NSLog(@"mapShowingActionSheetDidSlideOut");
    
    [self.effectView removeFromSuperview];
    self.effectView = nil;
}

#pragma mark - ActionSheet
- (void)showMoreActionSheet
{
    NSLog(@"showMoreActionSheet");
    
    self.moreBtn.backgroundColor = [UIColor clearColor];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    NSString *customTitle = @"你想做什麼?";
    NSMutableAttributedString *hogan = [[NSMutableAttributedString alloc] initWithString: customTitle];
    [hogan addAttribute:NSFontAttributeName
                  value:[UIFont systemFontOfSize:25.0]
                  range:NSMakeRange(0, customTitle.length)];
    [alert setValue:hogan forKey:@"attributedMessage"];
    /*
     UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"你想做什麼?"
     message: nil
     preferredStyle: UIAlertControllerStyleActionSheet];
     */
    //NSMutableAttributedString *titleStr = [[NSMutableAttributedString alloc] initWithString: @""]
    
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle: @"取消"
                                                        style: UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          
                                                      }];
    
    albumPoint = [self.dic[@"album"][@"point"] integerValue];
    NSLog(@"albumPoint: %ld", (long)albumPoint);
    
    NSString *collectStr;
    
    if (!isOwn) {
        if (albumPoint == 0) {
            collectStr = @"收藏";
        } else {
            collectStr = [NSString stringWithFormat: @"收藏(需要贊助%ldP)", (long)albumPoint];
        }
    } else {
        collectStr = @"已收藏";
    }
    
    UIAlertAction *collectBtn = [UIAlertAction
                                 actionWithTitle: collectStr
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     if (albumPoint == 0) {
                                         [self buyAlbum];
                                     } else {
                                         NSLog(@"albumPoint is not equal to 0");
                                         NSString *msgStr = [NSString stringWithFormat: @"確定贊助%ldP?", (long)albumPoint];
                                         //[self showBuyAlbumCustomAlert: msgStr option: @"buyAlbum"];
                                         [self showBuyAlbumCustomAlert: msgStr option: @"buyAlbum" pointStr: [NSString stringWithFormat: @"%ld", (long)albumPoint]];
                                     }
                                 }];
    
    if (isOwn) {
        collectBtn.enabled = NO;
    } else {
        collectBtn.enabled = YES;
    }
    
    UIAlertAction *shareBtn = [UIAlertAction
                               actionWithTitle:@"分享"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   [self checkTaskComplete];
                               }];
    
    UIAlertAction *infoBtn = [UIAlertAction
                              actionWithTitle:@"作品資訊"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  //[self insertReport];
                                  albumInfoVC = [[UIStoryboard storyboardWithName: @"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumInfoViewController"];
                                  
                                  if (locdata) {
                                      NSLog(@"locdata exists");
                                      NSLog(@"locdata: %@", locdata);
                                      albumInfoVC.localData = locdata;
                                  }
                                  
                                  albumInfoVC.data = self.dic;
                                  //NSLog(@"self.dic: %@", self.dic);
                                  albumInfoVC.delegate = self;
                                  albumInfoVC.view.frame = self.view.frame;
                                  
                                  NSLog(@"check locdata whether exist or not");
                                  
                                  [self.view addSubview: albumInfoVC.view];
                                  
                                  //[self presentViewController: albumInfoVC animated: YES completion: nil];
                              }];
    
    // Check if albumUserId is same as userId, then don't add collectBtn
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"id: %@", [userDefaults objectForKey: @"id"]);
    NSLog(@"self.dic user user_id: %d", [self.dic[@"user"][@"user_id"] intValue]);
    
    NSInteger userId = [[userDefaults objectForKey: @"id"] intValue];
    NSInteger albumUserId = [self.dic[@"user"][@"user_id"] intValue];
    
    if (albumUserId != userId) {
        [alert addAction: collectBtn];
    }
    
    [alert addAction: shareBtn];
    [alert addAction: infoBtn];
    [alert addAction: cancelBtn];
    
    //[alert addAction: testBtn];
    
    [self presentViewController: alert animated: YES completion: nil];
}

- (void)albumInfoViewControllerDisappear:(AlbumInfoViewController *)controller
{
    NSLog(@"albumInfoViewControllerDisappear");
    [albumInfoVC.view removeFromSuperview];
}

#pragma mark - Check Point Task

- (void)checkTaskComplete
{
    NSLog(@"checkTask");
    
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI checkTaskCompleted: [wTools getUserID]
                                                  token: [wTools getUserToken]
                                               task_for: @"share_to_fb"
                                               platform: @"apple"];
        
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
                //NSLog(@"%@", response);
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"TestReadBookViewController");
                    NSLog(@"checkTaskComplete");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"checkTaskCompleted"
                                        pointStr: @""
                                             btn: nil
                                             bgV: nil];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([data[@"result"] intValue] == 1) {
                        
                        // Task is completed, so calling the original sharing function
                        //[wTools Activitymessage:[NSString stringWithFormat: sharingLink , _album_id, autoPlayStr]];
                        
                        NSString *message;
                        
                        if ([self.eventJoin isEqual: [NSNull null]]) {
                            message = [NSString stringWithFormat: sharingLinkWithAutoPlay, self.albumid, autoPlayStr];
                        } else {
                            message = [NSString stringWithFormat: sharingLinkWithoutAutoPlay, self.albumid];
                        }
                        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems: [NSArray arrayWithObjects: message, nil] applicationActivities: nil];
                        [self presentViewController: activityVC animated: YES completion: nil];
                        
                    } else if ([data[@"result"] intValue] == 2) {
                        
                        // Task is not completed, so pop ups alert view
                        //[self showSharingAlertView];
                        //[self showShareActionSheet];
                        [self showCustomShareActionSheet];
                        
                    } else if ([data[@"result"] intValue] == 0) {
                        NSString *errorMessage = data[@"message"];
                        NSLog(@"errorMessage: %@", errorMessage);
                        
                        NSString *message;
                        
                        if ([self.eventJoin isEqual: [NSNull null]]) {
                            message = [NSString stringWithFormat: sharingLinkWithAutoPlay, self.albumid, autoPlayStr];
                        } else {
                            message = [NSString stringWithFormat: sharingLinkWithoutAutoPlay, self.albumid];
                        }
                        
                        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems: [NSArray arrayWithObjects: message, nil] applicationActivities: nil];
                        [self presentViewController: activityVC animated: YES completion: nil];
                    }
                }
            }
        });
    });
}

#pragma mark - Share ActionSheet

- (void)showShareActionSheet
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"選擇分享方式"
                                                                   message: nil
                                                            preferredStyle: UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle: @"取消"
                                                        style: UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          
                                                      }];
    UIAlertAction *facebookShareBtn = [UIAlertAction
                                       actionWithTitle:@"獎勵分享(facebook)"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action)
                                       {
                                           FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
                                           
                                           if ([self.eventJoin isEqual: [NSNull null]]) {
                                               content.contentURL = [NSURL URLWithString: [NSString stringWithFormat: sharingLinkWithAutoPlay, self.albumid, autoPlayStr]];
                                           } else {
                                               content.contentURL = [NSURL URLWithString: [NSString stringWithFormat: sharingLinkWithoutAutoPlay, self.albumid]];
                                           }
                                           [FBSDKShareDialog showFromViewController: self
                                                                        withContent: content
                                                                           delegate: self];
                                       }];
    
    UIAlertAction *normalShareBtn = [UIAlertAction
                                     actionWithTitle:@"一般分享"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         NSString *message;
                                         
                                         if ([self.eventJoin isEqual: [NSNull null]]) {
                                             message = [NSString stringWithFormat: sharingLinkWithAutoPlay, self.albumid, autoPlayStr];
                                         } else {
                                             message = [NSString stringWithFormat: sharingLinkWithoutAutoPlay, self.albumid];
                                         }
                                         UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems: [NSArray arrayWithObjects: message, nil] applicationActivities: nil];
                                         [self presentViewController: activityVC animated: YES completion: nil];
                                     }];
    
    [alert addAction: cancelBtn];
    [alert addAction: facebookShareBtn];
    [alert addAction: normalShareBtn];
    [self presentViewController: alert animated: YES completion: nil];
}

#pragma mark - FBSDKSharing Delegate Methods

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    NSLog(@"Sharing Complete");
    
    // Check whether getting Sharing Point or not
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL share_to_fb = [defaults objectForKey: @"share_to_fb"];
    NSLog(@"Check whether getting sharing point or not");
    NSLog(@"share_to_fb: %d", (int)share_to_fb);
    
    if (share_to_fb) {
        NSLog(@"Getting Sharing Point Already");
    } else {
        NSLog(@"Haven't got the point of sharing yet");
        task_for = @"share_to_fb";
        [self checkPoint];
    }
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    NSLog(@"Sharing didFailWithError");
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    NSLog(@"Sharing Did Cancel");
}

- (void)buyPPointViewController:(BuyPPointViewController *)controller {
    NSLog(@"buyPPointViewController");
    [bPPVC.view removeFromSuperview];
    shouldTurnOffAudio = NO;
    
    [self checkAudioWhenViewConrtrollerShowsUp];
    
    self.isAddingBuyPointVC = NO;
    
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    userPoint = [[userPrefs objectForKey: @"pPoint"] integerValue];
    NSLog(@"userPoint: %ld", (long)userPoint);
    
    NSLog(@"");
    //NSLog(@"self.mySV.subviews: %@", self.mySV.subviews);
    NSLog(@"");
    
    for (UIView *v1 in self.mySV.subviews) {
        NSLog(@"");
        //NSLog(@"v1: %@", v1);
        
        for (UIView *v2 in v1.subviews) {
            NSLog(@"");
            //NSLog(@"v2: %@", v2);
            
            if (v2.tag == 2) {
                for (UIView *v3 in v2.subviews) {
                    NSLog(@"");
                    //NSLog(@"v3: %@", v3);
                    
                    if ([v3 isKindOfClass: [UILabel class]]) {
                        NSLog(@"");
                        //NSLog(@"v3: %@", v3);
                        
                        if (v3.tag == 4) {
                            UILabel *currentPointLabel = (UILabel *)v3;
                            
                            //NSLog(@"old point: %@", currentPointLabel.text);
                            //NSLog(@"current point: %@", [NSString stringWithFormat: @"現有P點：%ld", (long)userPoint]);
                            currentPointLabel.text = [NSString stringWithFormat: @"現有P點：%ld", (long)userPoint];
                            [currentPointLabel sizeToFit];
                        }
                    }
                }
            }
        }
    }
}

#pragma mark - Buy Album
- (void)getPoint: (NSString *)pointStr
{
    NSLog(@"getPoint");
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
        NSString *response = [boxAPI geturpoints: [wTools getUserID] token: [wTools getUserToken]];
        
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
                    NSLog(@"TestReadBookViewController");
                    NSLog(@"getPoint pointStr");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getPoint"
                                        pointStr: pointStr
                                             btn: nil
                                             bgV: nil];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    //NSLog(@"dic from getUrPoints: %@", dic);
                    
                    if ([dic[@"result"] boolValue]) {
                        NSInteger point = [dic[@"data"] integerValue];
                        NSLog(@"point: %ld", (long)point);
                        NSLog(@"albumPoint: %ld", (long)albumPoint);
                        
                        if (point >= albumPoint) {
                            NSLog(@"point is bigger than albumPoint");
                            //[self buyAlbum];
                            [self newBuyAlbum: pointStr];
                        } else {
                            NSLog(@"point is not enough");
                            //[self showBuyAlbumCustomAlert: @"你的P點不足，前往購點?" option: @"buyPoint"];
                            [self showBuyAlbumCustomAlert: @"你的P點不足，前往購點?" option: @"buyPoint" pointStr: @""];
                        }
                    } else {
                        NSLog(@"失敗： %@", dic[@"message"]);
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

- (void)newBuyAlbum: (NSString *)pointStr
{
    NSLog(@"newBuyAlbum");
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
        NSString *response = [boxAPI newBuyAlbum: [wTools getUserID]
                                           token: [wTools getUserToken]
                                         albumId: self.albumid
                                        platform: @"apple"
                                           point: pointStr];
        
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
                    NSLog(@"TestReadBookViewController");
                    NSLog(@"newBuyAlbum pointStr");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"newBuyAlbum"
                                        pointStr: pointStr
                                             btn: nil
                                             bgV: nil];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    //NSLog(@"dic: %@", dic);
                    
                    
                    NSString *resultStr = dic[@"result"];
                    //NSLog(@"resultStr: %@", resultStr);
                    
                    if ([resultStr isEqualToString: @"SYSTEM_ERROR"]) {
                        NSLog(@"resultStr isEqualToString SYSTEM_ERROR");
                        [self showCustomErrorAlert: @"不明錯誤"];
                    } else if ([resultStr isEqualToString: @"SYSTEM_OK"]) {
                        NSLog(@"resultStr isEqualToString SYSTEM_OK");
                        
                        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                        style.messageColor = [UIColor whiteColor];
                        style.backgroundColor = [UIColor firstMain];
                        
                        [self.view makeToast: @"成功加入收藏"
                                    duration: 2.0
                                    position: CSToastPositionBottom
                                       style: style];
                        
                        [self own];
                        [self retrieveAlbum];
                        
                        //                        [self.mySV moveToPage: 0];
                        //[self.mySV setContentOffset: CGPointMake(0.0f, 0.0f) animated: YES];
                        
                        //[self getUrPoints];
                        //[self getPointStore];
                        
                    } else if ([resultStr isEqualToString: @"USER_ERROR"]) {
                        NSLog(@"resultStr isEqualToString USER_ERROR");
                        [self showCustomErrorAlert: dic[@"message"]];
                    } else if ([resultStr isEqualToString: @"USER_OWNS_THE_ALBUM"]) {
                        NSLog(@"resultStr isEqualToString USER_OWNS_THE_ALBUM");
                        [self showCustomErrorAlert: dic[@"message"]];
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

- (void)logOut {
    [wTools logOut];
}

- (void)buyAlbum {
    NSLog(@"buyAlbum");
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
        NSString *response = [boxAPI buyalbum: [wTools getUserID]
                                        token: [wTools getUserToken]
                                      albumid: self.albumid];
        
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
                //NSLog(@"response: %@", response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"TestReadBookViewController");
                    NSLog(@"buyAlbum");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"buyalbum"
                                        pointStr: @""
                                             btn: nil
                                             bgV: nil];
                } else {
                    NSLog(@"Get Real Response");
                    NSLog(@"response from buyalbum");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] boolValue]) {
                        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                        style.messageColor = [UIColor whiteColor];
                        style.backgroundColor = [UIColor firstMain];
                        
                        [self.view makeToast: @"成功加入收藏"
                                    duration: 2.0
                                    position: CSToastPositionBottom
                                       style: style];
                        
                        [self own];
                        [self retrieveAlbum];
                        
                        //                        [self.mySV moveToPage: 0];
                        //[self.mySV setContentOffset: CGPointMake(0.0f, 0.0f) animated: YES];
                        
                        //[self getPointStore];
                        //[self getUrPoints];
                        
                        // For Temporate Solution about last page
                        //[self.navigationController popViewControllerAnimated: YES];
                        //[self.navigationController pushViewController: self animated: YES];
                    }
                }
            }
        });
    });
}

- (void)retrieveAlbum {
    NSLog(@"");
    NSLog(@"retrieveAlbum");
    
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
        NSString *response = [boxAPI retrievealbump: self.albumid
                                                uid: [wTools getUserID]
                                              token: [wTools getUserToken]];
        
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
                //NSLog(@"response from retrievealbump: %@", response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"TestReadBookViewController");
                    NSLog(@"retrieveAlbum");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"retrievealbump"
                                        pointStr: @""
                                             btn: nil
                                             bgV: nil];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] boolValue]) {
                        NSLog(@"result bool value is YES");
                        //NSLog(@"dic: %@", dic);
                        
                        NSLog(@"dic data photo: %@", dic[@"data"][@"photo"]);
                        NSLog(@"dic data user name: %@", dic[@"data"][@"user"][@"name"]);
                        
                        //self.data = [dic[@"data"] mutableCopy];
                        self.dic = [dic[@"data"] mutableCopy];
                        
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        self.audioSwitch = [[defaults objectForKey: @"isAudioPlayedAutomatically"] boolValue];
                        NSLog(@"self.audioSwitch: %d", self.audioSwitch);
                        //_audioSwitch = YES;
                        isplayaudio = YES;
                        //_fromPageText = NO;
                        
                        self.isReadyToPlay = NO;
                        
                        [self setupForDicFile: self.dic];
                        
                        messageInt = [self.dic[@"albumstatistics"][@"messageboard"] integerValue];
                        isLikes = [self.dic[@"album"][@"is_likes"] boolValue];
                        likesInt = [self.dic[@"albumstatistics"][@"likes"] integerValue];
                        
                        [self preparationForViewWillAppear];
                        
                        [self.collectionView reloadData];
                        
                        [self resetScreenDisplay];
                        
                        [self.mySV moveToPage: 0];
                        
                        [self getUrPoints];
                    } else {
                        NSLog(@"失敗： %@", dic[@"message"]);
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

- (void)resetScreenDisplay {
    NSLog(@"resetScreenDisplay");
    
    selectItem = 0;
    
    for (int i = 0; i < selectItemArray.count; i++) {
        selectItemArray[i] = @"notSelected";
    }
    selectItemArray[0] = @"selected";
    
    // CollectionViewCell Section
    // Move CollectionViewCell When mySV Scroll
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem: selectItem inSection: 0];
    [self.collectionView scrollToItemAtIndexPath: indexPath atScrollPosition: UICollectionViewScrollPositionCenteredHorizontally animated: YES];
    
    // Check Selected Cell or Not
    [self checkCell];
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
                    NSLog(@"TestReadBookViewController");
                    NSLog(@"getUrPoints");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"geturpoints"
                                        pointStr: @""
                                             btn: nil
                                             bgV: nil];
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
                        
                        // For Point Activity
                        [self checkAlbumCollectTask];
                    } else {
                        NSLog(@"失敗： %@", dic[@"message"]);
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

- (void)checkAlbumCollectTask
{
    NSLog(@"checkAlbumCollectTask");
    
    if (albumPoint == 0) {
        task_for = @"collect_free_album";
    } else if (albumPoint > 0) {
        task_for = @"collect_pay_album";
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([task_for isEqualToString: @"collect_free_album"]) {
        // Check whether getting Free Album point or not
        BOOL collect_free_album = [[defaults objectForKey: @"collect_free_album"] boolValue];
        NSLog(@"Check whether getting Album Saving point or not");
        NSLog(@"collect_free_album: %d", (int)collect_free_album);
        
        if (collect_free_album) {
            NSLog(@"Get the First Time Album Saving Point Already");
        } else {
            NSLog(@"Haven't got the point of saving album for first time");
            [self checkPoint];
        }
    } else if ([task_for isEqualToString: @"collect_pay_album"]) {
        // Check whether getting Pay Album Point or not
        BOOL collect_pay_album = [[defaults objectForKey: @"collect_pay_album"] boolValue];
        NSLog(@"Check whether getting paid album point or not");
        NSLog(@"collect_pay_album: %d", (int)collect_pay_album);
        
        if (collect_pay_album) {
            NSLog(@"Getting Paid Album Point Already");
        } else {
            NSLog(@"Haven't got the point of saving paid album for first time");
            [self checkPoint];
        }
    }
}

- (void)checkPoint {
    NSLog(@"checkPoint");
    
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *response = [boxAPI doTask2: [wTools getUserID]
                                       token: [wTools getUserToken]
                                    task_for: task_for
                                    platform: @"apple"
                                        type: @"album"
                                     type_id: self.albumid];
        
        NSLog(@"User ID: %@", [wTools getUserID]);
        NSLog(@"Token: %@", [wTools getUserToken]);
        NSLog(@"Task_For: %@", task_for);
        NSLog(@"Album ID: %@", self.albumid);
        
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
                    NSLog(@"TestReadBookViewController");
                    NSLog(@"checkPoint");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"doTask2"
                                        pointStr: @""
                                             btn: nil
                                             bgV: nil];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    NSLog(@"data: %@", data);
                    
                    if ([data[@"result"] intValue] == 1) {
                        missionTopicStr = data[@"data"][@"task"][@"name"];
                        NSLog(@"name: %@", missionTopicStr);
                        
                        rewardType = data[@"data"][@"task"][@"reward"];
                        NSLog(@"reward type: %@", rewardType);
                        
                        rewardValue = data[@"data"][@"task"][@"reward_value"];
                        NSLog(@"reward value: %@", rewardValue);
                        
                        eventUrl = data[@"data"][@"event"][@"url"];
                        NSLog(@"eventUrl: %@", eventUrl);
                        
                        restriction = data[@"data"][@"task"][@"restriction"];
                        NSLog(@"restriction: %@", restriction);
                        
                        restrictionValue = data[@"data"][@"task"][@"restriction_value"];
                        NSLog(@"restrictionValue: %@", restrictionValue);
                        
                        numberOfCompleted = [data[@"data"][@"task"][@"numberofcompleted"] unsignedIntegerValue];
                        NSLog(@"numberOfCompleted: %lu", (unsigned long)numberOfCompleted);
                        
                        [self showAlertView];
                        
                        [self saveCollectInfoToDevice: NO];
                        
                        //[self getPointStore];
                        
                    } else if ([data[@"result"] intValue] == 2) {
                        NSLog(@"message: %@", data[@"message"]);
                        
                        [self saveCollectInfoToDevice: YES];
                        
                    } else if ([data[@"result"] intValue] == 0) {
                        NSLog(@"失敗： %@", data[@"message"]);
                        [self saveCollectInfoToDevice: YES];
                        
                    } else if ([data[@"result"] intValue] == 3) {
                        NSLog(@"data result intValue: %d", [data[@"result"] intValue]);
                    }
                }
            }
        });
    });
}

- (void)saveCollectInfoToDevice: (BOOL)isCollect
{
    if ([task_for isEqualToString: @"collect_free_album"]) {
        
        // Save data for first collect album
        BOOL collect_free_album = isCollect;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject: [NSNumber numberWithBool: collect_free_album]
                     forKey: @"collect_free_album"];
        [defaults synchronize];
        
        //[self getPointStore];
        
    } else if ([task_for isEqualToString: @"collect_pay_album"]) {
        
        // Save data for first collect paid album
        BOOL collect_pay_album = isCollect;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject: [NSNumber numberWithBool: collect_pay_album]
                     forKey: @"collect_pay_album"];
        [defaults synchronize];
        
        //[self getPointStore];
    }
}

#pragma mark -
#pragma mark Error Handling - Preparing Assets for Playback Failed

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
    
    [self removePlayerTimeObserver];
    [self syncScrubber];
    [self disableScrubber];
    //[self disablePlayerButtons];
    /*
     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
     message:[error localizedFailureReason]
     delegate:nil
     cancelButtonTitle:@"OK"
     otherButtonTitles:nil];
     [alertView show];
     */
}


#pragma mark - AVPlayer Section
- (void)avPlayerSetUp: (NSString *)audioData
{
    NSLog(@"avPlayerSetUp");
    
    //註冊audioInterrupted
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver: self selector: @selector(audioInterrupted:) name: AVAudioSessionInterruptionNotification object: nil];
    
    //self.avPlayer = [[AVPlayer alloc] initWithURL: audioUrl];
    //avPlayer = player;
    
    // 1. Set Up URL Audio Source
    NSURL *audioUrl = [NSURL URLWithString: audioData];
    
    // 2. PlayItem Setup
    //self.playerItem = [AVPlayerItem playerItemWithURL: audioUrl];
    // Setting AVAsset & AVPlayerItem this way can avoid crash
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL: audioUrl options: nil];
    //AVAsset *asset = [AVURLAsset URLAssetWithURL: audioUrl options: nil];
    //AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset: asset];
    
    NSArray *requestedKeys = @[@"playable"];
    
    // Tells the asset to load the values of any of the specified keys that are not already loaded.
    [asset loadValuesAsynchronouslyForKeys: requestedKeys completionHandler:^{
        NSLog(@"Before dispatch_async( dispatch_get_main_queue()");
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"After dispatch_async( dispatch_get_main_queue()");
            // IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem.
            NSLog(@"self prepareToPlayAsset:asset withKeys:requestedKeys");
            [self prepareToPlayAsset:asset withKeys:requestedKeys];
        });
    }];
}

#pragma mark Prepare to play asset, URL

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
        NSLog(@"");
        NSLog(@"thisKey: %@", thisKey);
        
        NSError *error = nil;
        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
        NSLog(@"keyStatus: %ld", (long)keyStatus);
        
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
    
    isSeeking = NO;
    
    NSLog(@"self.avPlayerItem = [AVPlayerItem playerItemWithAsset: asset]");
    self.avPlayerItem = [AVPlayerItem playerItemWithAsset: asset];
    
    NSLog(@"self.avPlayerItem addObserver: self forKeyPath: status");
    [self.avPlayerItem addObserver: self
                        forKeyPath: @"status"
                           options: NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                           context: AVPlayerDemoPlaybackViewControllerStatusObservationContext];
    
    if (self.avPlayer != nil) {
        //[self.avPlayer removeObserver: self forKeyPath: @"status"];
        NSLog(@"self.avPlayer != nil");
        NSLog(@"self.avPlayer removeObserver: self forKeyPath: rate");
        @try {
            [self.avPlayer removeObserver: self forKeyPath: @"rate"];
        } @catch (NSException *exception) {
            // Print exception information
            NSLog( @"NSException caught" );
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
            return;
        }
        
    }
    
    // To avoid the syncScrubbing keep calling, so pause avPlayer
    NSLog(@"self.avPlayer pause");
    [self.avPlayer pause];
    
    NSLog(@"self.avPlayer = [AVPlayer playerWithPlayerItem: self.avPlayerItem]");
    self.avPlayer = [AVPlayer playerWithPlayerItem: self.avPlayerItem];
    
    NSLog(@"self.avPlayer addObserver: self forKeyPath: rate");
    [self.avPlayer addObserver: self
                    forKeyPath: @"rate"
                       options: NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                       context: AVPlayerDemoPlaybackViewControllerRateObservationContext];
    
    //self.avPlayer.automaticallyWaitsToMinimizeStalling = false
    
    NSLog(@"self.mScrubber setValue: 0.0");
    [self.mScrubber setValue: 0.0];
    
    // 3. AVPlayer Setup
    
    // Loading data faster but only support iOS 10 and above
    //self.avPlayer = [AVPlayer playerWithPlayerItem: playerItem];
    
    BOOL isLoop;
    //NSLog(@"audioMode: %@", audioMode);
    
    if ([audioMode isEqualToString: @"singular"]) {
        NSLog(@"audioMode isEqualToString: singular");
        isLoop = [bookdata[@"album"][@"audio_loop"] boolValue];
        NSLog(@"audioLoop: %d", isLoop);
        
        if (isLoop) {
            NSLog(@"Loop Audio");
            
            // The setting below is to loop audio
            self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            [self addNotification];
        } else {
            NSLog(@"Don't Loop Audio");
            self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        }
    } else if ([audioMode isEqualToString: @"plural"]) {
        NSLog(@"audioMode isEqualToString: plural");
        int page = self.mySV.contentOffset.x / self.mySV.frame.size.width;
        NSLog(@"page: %d", page);
        
        isLoop = [datalist[page][@"audio_loop"] boolValue];
        NSLog(@"audioLoop: %d", isLoop);
        
        if (isLoop) {
            NSLog(@"Loop Audio");
            // The setting below is to loop audio
            self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            [self addNotification];
        } else {
            NSLog(@"Don't Loop Audio");
            self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        }
    }
}

#pragma mark - Audio Interrupted
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
            
            if (self.audioSwitch) {
                if (self.isReadyToPlay) {
                    if (isplayaudio) {
                        [NSThread sleepForTimeInterval: 0.1];
                        [self.avPlayer play];
                    }
                }
            }
        }
    }
}

#pragma mark - NSNotification
- (void)addNotification
{
    NSLog(@"");
    NSLog(@"addNotification");
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(playerItemDidReachEnd:)
                                                 name: AVPlayerItemDidPlayToEndTimeNotification
                                               object: self.avPlayerItem];
    
    /*
     [[NSNotificationCenter defaultCenter] addObserver: self
     selector: @selector(playerItemDidReachEnd:)
     name: AVPlayerItemDidPlayToEndTimeNotification
     object: [self.avPlayer currentItem]];
     */
}

- (void)removeNotification
{
    NSLog(@"");
    NSLog(@"removeNotification");
    @try {
        //[[NSNotificationCenter defaultCenter] removeObserver: self];
        
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
}

#pragma mark -

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    
    //  code here to play next audio file
    NSLog(@"");
    NSLog(@"playerItemDidReachEnd");
    
    seekToZeroBeforePlay = YES;
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        NSLog(@"Seek To Time kCMTimeZero");
        AVPlayerItem *p = [notification object];
        [p seekToTime: kCMTimeZero];
    });
}

// From Apple API Reference
// Informs the observing object when the value at the specified key path
// relative to the observed object has changed
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    NSLog(@"");
    NSLog(@"observeValueForKeyPath");
    
    NSLog(@"object: %@", object);
    
    if (context == AVPlayerDemoPlaybackViewControllerStatusObservationContext) {
        NSLog(@"context == AVPlayerDemoPlaybackViewControllerStatusObservationContext");
        
        switch (self.avPlayer.status) {
            case AVPlayerStatusUnknown:
            {
                NSLog(@"AVPlayerStatusUnknown");
                self.isReadyToPlay = NO;
                
                [self syncScrubber];
                [self disableScrubber];
            }
                break;
                
            case AVPlayerStatusReadyToPlay:
            {
                NSLog(@"AVPlayerStatusReadyToPlay");
                self.isReadyToPlay = YES;
                [self initScrubberTimer];
                
                [self enableScrubber];
                
                if (self.audioSwitch) {
                    if (self.avPlayer != nil) {
                        NSLog(@"avPlayer is initialized");
                        
                        if (self.isReadyToPlay) {
                            NSLog(@"self.isReadyToPlay is set to YES");
                            
                            if (isplayaudio) {
                                NSLog(@"isplayaudio is set to YES");
                                
                                [self.avPlayer play];
                                //[self.avPlayer playImmediatelyAtRate: 1.0];
                                NSLog(@"self.avPlayer play");
                            } else {
                                NSLog(@"isplayaudio is set to NO");
                                [self.avPlayer pause];
                                NSLog(@"self.avPlayer pause");
                            }
                        } else {
                            NSLog(@"self.isReadyToPlay is set to NO");
                        }
                    }
                }
            }
                break;
                
            case AVPlayerStatusFailed:
            {
                NSLog(@"AVPlayerStatusFailed");
                self.isReadyToPlay = NO;
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback: playerItem.error];
            }
                break;
            default:
                break;
        }
    } else if (context == AVPlayerDemoPlaybackViewControllerRateObservationContext) {
        NSLog(@"context == AVPlayerDemoPlaybackViewControllerRateObservationContext");
    } else {
        NSLog(@"else");
        [super observeValueForKeyPath: keyPath ofObject: object change: change context: context];
    }
}

#pragma mark - Movie scrubber control

/* ---------------------------------------------------------
 **  Methods to handle manipulation of the movie scrubber control
 ** ------------------------------------------------------- */

/* Requests invocation of a given block during media playback to update the movie scrubber control. */
- (void)initScrubberTimer
{
    NSLog(@"");
    NSLog(@"initScrubberTimer");
    
    double interval = .1f;
    
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        return;
    }
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        CGFloat width = CGRectGetWidth([self.mScrubber bounds]);
        interval = 0.5f * duration / width;
    }
    
    /* Update the scrubber during normal playback. */
    __weak TestReadBookViewController *weakSelf = self;
    mTimeObserver = [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                                queue:NULL /* If you pass NULL, the main queue is used. */
                                                           usingBlock:^(CMTime time)
                     {
                         NSLog(@"call syncScrubber in Block of initScrubberTimer");
                         [weakSelf syncScrubber];
                     }];
}

/* Set the scrubber based on the player current time. */
- (void)syncScrubber
{
    NSLog(@"");
    NSLog(@"syncScrubber");
    
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        NSLog(@"CMTIME_IS_INVALID(playerDuration)");
        self.mScrubber.minimumValue = 0.0;
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        NSLog(@"isfinite(duration)");
        
        float minValue = [self.mScrubber minimumValue];
        float maxValue = [self.mScrubber maximumValue];
        double time = CMTimeGetSeconds([self.avPlayer currentTime]);
        
        [self.mScrubber setValue:(maxValue - minValue) * time / duration + minValue];
    }
}

/* The user is dragging the movie controller thumb to scrub through the movie. */
- (IBAction)beginScrubbing:(id)sender
{
    NSLog(@"");
    NSLog(@"beginScrubbing");
    
    mRestoreAfterScrubbingRate = [self.avPlayer rate];
    [self.avPlayer setRate: 0.f];
    
    // Remove previous timer
    [self removePlayerTimeObserver];
}

/* Set the player current time to match the scrubber position. */
- (IBAction)scrub:(id)sender
{
    NSLog(@"");
    NSLog(@"scrub");
    
    if ([sender isKindOfClass: [UISlider class]] && !isSeeking) {
        isSeeking = YES;
        UISlider *slider = sender;
        
        CMTime playerDuration = [self playerItemDuration];
        
        if (CMTIME_IS_INVALID(playerDuration)) {
            return;
        }
        
        double duration = CMTimeGetSeconds(playerDuration);
        
        if (isfinite(duration)) {
            float minValue = [slider minimumValue];
            float maxValue = [slider maximumValue];
            float value = [slider value];
            
            double time = duration * (value - minValue) / (maxValue - minValue);
            
            [self.avPlayer seekToTime: CMTimeMakeWithSeconds(time, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"isSeeking = NO");
                    isSeeking = NO;
                });
            }];
        }
    }
}

/* The user has released the movie thumb control to stop scrubbing through the movie. */
- (IBAction)endScrubbing:(id)sender
{
    NSLog(@"");
    NSLog(@"endScrubbing");
    
    if (!mTimeObserver) {
        CMTime playerDuration = [self playerItemDuration];
        
        if (CMTIME_IS_INVALID(playerDuration)) {
            return;
        }
        
        double duration = CMTimeGetSeconds(playerDuration);
        
        if (isfinite(duration)) {
            CGFloat width = CGRectGetWidth([self.mScrubber bounds]);
            double tolerance = 0.5 * duration / width;
            
            __weak TestReadBookViewController *weakSelf = self;
            mTimeObserver = [self.avPlayer addPeriodicTimeObserverForInterval: CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) queue: NULL usingBlock:^(CMTime time) {
                NSLog(@"call syncScrubber in Block of endScrubbing method");
                [weakSelf syncScrubber];
            }];
        }
    }
    
    if (mRestoreAfterScrubbingRate) {
        [self.avPlayer setRate: mRestoreAfterScrubbingRate];
        mRestoreAfterScrubbingRate = 0.f;
    }
}

- (void)enableScrubber
{
    NSLog(@"");
    NSLog(@"enableScrubber");
    self.mScrubber.enabled = YES;
}

- (void)disableScrubber
{
    NSLog(@"");
    NSLog(@"disableScrubber");
    self.mScrubber.enabled = NO;
}

/* ---------------------------------------------------------
 **  Get the duration for a AVPlayerItem.
 ** ------------------------------------------------------- */

- (CMTime)playerItemDuration
{
    NSLog(@"");
    NSLog(@"playerItemDuration");
    
    AVPlayerItem *playerItem = [self.avPlayer currentItem];
    
    if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
        return ([playerItem duration]);
    }
    return (kCMTimeInvalid);
}

/* Cancels the previously registered time observer. */
/* Cancels the previously registered time observer. */
-(void)removePlayerTimeObserver
{
    NSLog(@"");
    NSLog(@"removePlayerTimeObserver");
    
    if (mTimeObserver) {
        [self.avPlayer removeTimeObserver: mTimeObserver];
        mTimeObserver = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"dealloc");
    
    @try {
        [self removeObserverForPlayerAndItem];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
}

- (void)removeObserverForPlayerAndItem
{
    if (self.avPlayer != nil) {
        NSLog(@"self.avPlayer != nil");
        NSLog(@"remove observer");
        
        //[self.avPlayer removeObserver: self forKeyPath: @"status"];
        @try {
            [self.avPlayer removeObserver: self forKeyPath: @"rate"];
        } @catch (NSException *exception) {
            // Print exception information
            NSLog( @"NSException caught" );
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
            return;
        }
        
        //[self.avPlayer.currentItem removeObserver: self forKeyPath: @"status"];
        
        [self.avPlayer pause];
        
        @try {
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
        
        
        self.avPlayer = nil;
    }
    if (self.avPlayerItem) {
        NSLog(@"self.avPlayerItem Existed");
        NSLog(@"self.avPlayerItem removeObserver: self forKeyPath: status");
        
        @try {
            [self.avPlayerItem removeObserver: self
                                   forKeyPath: @"status"];
        } @catch (NSException *exception) {
            // Print exception information
            NSLog( @"NSException caught" );
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
            return;
        }
        
        
        self.avPlayerItem = nil;
    }
}

- (void)playCheck: (NSString *)audioData
{
    NSLog(@"");
    NSLog(@"playCheck");
    NSLog(@"audioData: %@", audioData);
    
    // audioSwitch is ON, after pressed button will be set to NO
    // That means audioSwitch is ON at the beginning
    
    NSLog(@"_audioSwitch: %d", _audioSwitch);
    NSLog(@"isplayaudio: %d", isplayaudio);
    NSLog(@"self.isReadyToPlay: %d", self.isReadyToPlay);
    
    if (_audioSwitch) {
        NSLog(@"audioSwitch is ON");
        
        if (!_videoPlay) {
            NSLog(@"videoPlay is finished");
            
            if (![audioData isKindOfClass: [NSNull class]]) {
                if (![audioData isEqualToString: @""]) {
                    if (self.avPlayer != nil) {
                        NSLog(@"avPlayer is not nil");
                        
                        if (self.isReadyToPlay) {
                            NSLog(@"self.isReadyToPlay is set to: %d", self.isReadyToPlay);
                            
                            if (isplayaudio) {
                                NSLog(@"isplayaudio is set to: %d", isplayaudio);
                                [self.avPlayer play];
                            }
                        }
                    }
                }
            }
        } else if (_videoPlay) {
            NSLog(@"Video is playing");
            [self.avPlayer pause];
            NSLog(@"avPlayer pause");
        }
    } else {
        NSLog(@"audioSwitch is OFF");
    }
}

#pragma mark - Audio Related Methods
// Audio Switching Function
- (void)playbool: (id)sender {
    NSLog(@"playbool");
    
    NSLog(@"self.audioSwitch: %d", self.audioSwitch);
    
    if (_audioSwitch) {
        // If audioSwitch is ON then set to OFF
        NSLog(@"audioSwitch is set to YES");
        NSLog(@"_audioSwitch: %d", _audioSwitch);
        isplayaudio = NO;
        _audioSwitch = NO;
    } else {
        // If audioSwitch is OFF then set to ON
        NSLog(@"audioSwitch is set to NO");
        NSLog(@"_audioSwitch: %d", _audioSwitch);
        isplayaudio = YES;
        
        if (_videoPlay) {
            NSLog(@"videoPlay is set to YES");
            isplayaudio = NO;
        } else {
            NSLog(@"videoPlay is set to NO");
            isplayaudio = YES;
        }
        _audioSwitch = YES;
    }
    
    //isplayaudio = !isplayaudio;
    
    NSLog(@"isplayaudio: %d", isplayaudio);
    
    if (self.avPlayer != nil) {
        NSLog(@"avPlayer is not nil");
        NSLog(@"avPlayer: %@", self.avPlayer);
        
        if (isplayaudio) {
            [self.avPlayer play];
            NSLog(@"avPlayer play");
            
            //[self changeAudioButtonImage];
            
        } else {
            [self.avPlayer pause];
            NSLog(@"avPlayer pause");
            
            //[self changeAudioButtonImage];
        }
    } else if (self.avPlayer == nil) {
        NSLog(@"avPlayer is nil");
        NSLog(@"avPlayer: %@", self.avPlayer);
        NSLog(@"avPlayer is nil, needs to be initialized");
        NSLog(@"audioStr: %@", audioStr);
        [self avPlayerSetUp: audioStr];
    }
    
    [self changeAudioButtonImage];
}

- (void)changeAudioButtonImage {
    if (self.audioSwitch) {
        //NSLog(@"isplayaudio is On");
        [self.soundBtn setImage: [UIImage imageNamed: @"ic200_audio_play_light.png"] forState: UIControlStateNormal];
    } else {
        //NSLog(@"isplayaudio is Off");
        [self.soundBtn setImage: [UIImage imageNamed: @"ic200_audio_stop_light.png"] forState: UIControlStateNormal];
    }
}

- (void)addingAudioButton: (UIView *)v
                   target: (NSString *)audioTarget
                     page: (int)pageId
{
    NSLog(@"addingAudioButton");
    
    NSLog(@"pageId: %d", pageId);
    NSLog(@"audioTarget: %@", audioTarget);
    
    NSLog(@"isplayaudio: %d", isplayaudio);
    NSLog(@"audioMode: %@", audioMode);
    
    if ([audioMode isEqualToString: @"singular"]) {
        NSLog(@"audioMode is signular");
        //UIButton *btn;
        
        NSLog(@"audioTarget: %@", audioTarget);
        
        if (isplayaudio) {
            [self.soundBtn setImage: [UIImage imageNamed: @"ic200_audio_play_light.png"] forState: UIControlStateNormal];
            //btn = [wTools W_Button: self frame: CGRectMake(0, 0, 50, 50) imgname: @"icon_audioswitch_open_white_75x75" SELL: @selector(playbool:) tag: pageId];
        } else {
            [self.soundBtn setImage: [UIImage imageNamed: @"ic200_audio_stop_light.png"] forState: UIControlStateNormal];
            //btn = [wTools W_Button: self frame: CGRectMake(0, 0, 50, 50) imgname: @"icon_audioswitch_close_white_75x75" SELL: @selector(playbool:) tag: pageId];
        }
    }
    
    if ([audioMode isEqualToString: @"plural"]) {
        NSLog(@"audioMode is plural");
        
        NSLog(@"audioTarget: %@", audioTarget);
        
        if (![audioTarget isKindOfClass: [NSNull class]]) {
            
            NSLog(@"audioTarget is not null class");
            NSLog(@"audioTarget: %@", audioTarget);
            
            UIButton *btn;
            
            if (isplayaudio) {
                [self.soundBtn setImage: [UIImage imageNamed: @"ic200_audio_play_light"] forState: UIControlStateNormal];
                //btn = [wTools W_Button: self frame: CGRectMake(0, 0, 50, 50) imgname: @"icon_audioswitch_open_white_75x75" SELL: @selector(playbool:) tag: pageId];
            } else {
                [self.soundBtn setImage: [UIImage imageNamed: @"ic200_audio_stop_light"] forState: UIControlStateNormal];
                //btn = [wTools W_Button: self frame: CGRectMake(0, 0, 50, 50) imgname: @"icon_audioswitch_close_white_75x75" SELL: @selector(playbool:) tag: pageId];
            }
        }
    }
}

#pragma mark -
#pragma mark Text Description Related Methods

- (void)viewSignleTapped: (UIGestureRecognizer *)recognizer
{
    if (myText.hidden == YES) {
        myText.hidden = NO;
    } else if (myText.hidden == NO) {
        myText.hidden = YES;
    }
}


#pragma mark - Custom AlertView for Getting Point
- (void)showAlertView
{
    NSLog(@"Show Alert View");
    
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
    missionTopicLabel.text = missionTopicStr;
    
    NSLog(@"Topic Label Text: %@", missionTopicStr);
    [pointView addSubview: missionTopicLabel];
    
    if ([restriction isEqualToString: @"personal"]) {
        UILabel *restrictionLabel = [[UILabel alloc] initWithFrame: CGRectMake(10, 45, 200, 10)];
        restrictionLabel.textColor = [UIColor firstGrey];
        restrictionLabel.text = [NSString stringWithFormat: @"次數：%lu / %@", (unsigned long)numberOfCompleted, restrictionValue];
        NSLog(@"restrictionLabel.text: %@", restrictionLabel.text);
        
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
    
    NSLog(@"Reward Value: %@", rewardValue);
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

- (void)showTheActivityPage {
    NSLog(@"showTheActivityPage");
    
    //NSString *activityLink = @"http://www.apple.com";
    NSLog(@"eventUrl: %@", eventUrl);
    NSString *activityLink = eventUrl;
    
    NSURL *url = [NSURL URLWithString: activityLink];
    
    // Close for present safari view controller, otherwise alertView will hide the background
    [alertView close];
    
    SFSafariViewController *safariVC1 = [[SFSafariViewController alloc] initWithURL: url entersReaderIfAvailable: NO];
    safariVC1.delegate = self;
    safariVC1.preferredBarTintColor = [UIColor whiteColor];
    [self presentViewController: safariVC1 animated: YES completion: nil];
}

#pragma mark - SFSafariViewController delegate methods
- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller
{
    // Done button pressed
    
    NSLog(@"show");
    [alertView show];
}

#pragma mark - IBAction Methods

- (IBAction)back:(id)sender {
    NSLog(@"TestReadBookViewController");
    NSLog(@"back");
    
    NSLog(@"isLandscape: %d", isLandscape);
    
    self.navigationController.delegate = nil;
    
    self.isPresented = NO;
    
    [FTWCache resetCache];
    
    @try {
        [self removeObserverForPlayerAndItem];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver: self];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    if (self.postMode) {
        //NSString *alertMessage = @"確定投稿此作品? (點 取消 則退出作品瀏覽，如需再投稿此作品請至活動頁面 - 點擊投稿 - 選擇現有作品)";
        NSString *msg = @"要取消此次投稿，請至活動頁面";
        [self showCustomCheckPostAlertView: msg];
    } else {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.myNav popViewControllerAnimated: YES];
    }
}

- (void)postAlbum
{
    NSLog(@"postAlbum");
    //[wTools ShowMBProgressHUD];
    @try {
        [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI switchstatusofcontribution: [wTools getUserID]
                                                          token: [wTools getUserToken]
                                                       event_id: _eventId
                                                       album_id: _albumid];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[wTools HideMBProgressHUD];
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
                //NSLog(@"%@", response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"TestReadBookViewController");
                    NSLog(@"postAlbum");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"switchstatusofcontribution"
                                        pointStr: @""
                                             btn: nil
                                             bgV: nil];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] boolValue]) {
                        NSLog(@"post album success");
                        
                        int contributionCheck = [dic[@"data"][@"event"][@"contributionstatus"] boolValue];
                        NSLog(@"contributionCheck: %d", contributionCheck);
                        
                        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                        style.messageColor = [UIColor whiteColor];
                        style.backgroundColor = [UIColor thirdMain];
                        
                        [self.view makeToast: @"投稿成功"
                                    duration: 2.0
                                    position: CSToastPositionBottom
                                       style: style];
                    } else {
                        NSLog(@"失敗： %@", dic[@"message"]);
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

#pragma mark - MyScrollViewDataScource
-(UIView *)ScrollView:(MyScrollView *)scrollView
               atPage:(int)pageId {
    // Activate when flip page
    // Preloading Content Methods
    // So, pageId is ahead of current page in order to prepare the content for display
    NSLog(@"");
    NSLog(@"MyScrollView DataSource");
    NSLog(@"pageId: %d", pageId);
    int page = self.mySV.contentOffset.x / self.mySV.frame.size.width;
    NSLog(@"page: %d", page);
    
    UIView *v = [[UIView alloc] initWithFrame: CGRectMake(scrollView.bounds.size.width * pageId, 0, scrollView.bounds.size.width, scrollView.bounds.size.height)];
    v.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    v.accessibilityIdentifier = @"ScrollViewSubViews";
    
    //相片用途
    NSString *usefor = datalist[pageId][@"usefor"];
    NSLog(@"usefor: %@", usefor);
    
    NSString *pid = [datalist[pageId][@"photo_id"] stringValue];
    //NSLog(@"pid: %@", pid);
    
    [self textViewSetup: page];
    
    //NSLog(@"datalist: %@", datalist);
    
    // Audio Section
    //NSString *audioTarget = datalist[pageId][@"audio_target"];
    NSString *audioTarget = datalist[page][@"audio_target"];
    NSLog(@"audioTarget: %@", audioTarget);
    NSLog(@"audioMode: %@", audioMode);
    
    NSString *location = datalist[page][@"location"];
    NSLog(@"location: %@", location);
    
    if (![location isKindOfClass: [NSNull class]]) {
        if (![location isEqualToString: @""]) {
            self.locationBtn.hidden = NO;
        } else {
            self.locationBtn.hidden = YES;
        }
    } else {
        self.locationBtn.hidden = NO;
    }
    
    if ([audioMode isEqualToString: @"none"]) {
        self.soundBtn.hidden = YES;
        self.mScrubber.hidden = YES;
    } else if ([audioMode isEqualToString: @"singular"]) {
        self.soundBtn.hidden = NO;
        self.mScrubber.hidden = NO;
    } else if ([audioMode isEqualToString: @"plural"]) {
        if ([audioTarget isKindOfClass: [NSNull class]]) {
            //NSLog(@"audioTarget is Null");
            self.soundBtn.hidden = YES;
            self.mScrubber.hidden = YES;
        } else {
            //NSLog(@"audioTarget is not Null");
            self.soundBtn.hidden = NO;
            self.mScrubber.hidden = NO;
        }
    }
    
    //[wTools HideMBProgressHUD];
    [MBProgressHUD hideHUDForView: self.view animated: YES];
    
    //相片
    if ([usefor isEqualToString:@"image"]) {
        //NSLog(@"usefor is image");
        
        UIScrollView *sc = [[UIScrollView alloc] initWithFrame: v.bounds];
        sc.maximumZoomScale = 2.0;
        sc.minimumZoomScale = 1;
//        sc.delegate = self;
        sc.tag = 1002;
        sc.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        sc.accessibilityIdentifier = @"sc";
        
        NSString *filename = [NSString stringWithFormat: @"%d.jpg", pageId];
        
        //NSLog(@"file: %@", file);
        NSString *imagePath = [file stringByAppendingPathComponent: filename];
        //NSLog(@"imagePath: %@", imagePath);
        
        UIImageView *imagev = [[UIImageView alloc] initWithFrame: v.bounds];
        imagev.tag = 1003;
        imagev.contentMode = UIViewContentModeScaleAspectFit;
        imagev.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        if (_dic) {
            NSLog(@"dic is not null");
            //NSLog(@"pageId: %d", pageId);
            NSLog(@"datalist.count: %lu", (unsigned long)datalist.count);
            
            if (pageId == (datalist.count -1)) {
                //NSLog(@"collect: %d", [datalist[pageId][@"collect"] boolValue]);
            }
            
            if ([datalist[pageId][@"collect"] boolValue]) {
                //NSLog(@"imageThumbnail: %@", datalist[pageId][@"imageThumbnail"]);
            }
            
            NSString *URL = datalist[pageId][@"image_url"];
            NSLog(@"");
            NSLog(@"URL: %@", URL);
            NSLog(@"");
            NSURL *imageURL = [NSURL URLWithString: URL];
            NSString *key = [URL MD5Hash];
            NSData *data = [FTWCache objectForKey: key];
            
            if (data) {
                NSLog(@"");
                NSLog(@"data exists");
                //UIImage *image = [UIImage imageWithData: data];
                [imagev sd_setImageWithURL: imageURL];
            } else {
                NSLog(@"data does not exist");
                
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                
                dispatch_async(queue, ^{
                    NSData *data = [NSData dataWithContentsOfURL: imageURL];
                    [FTWCache setObject: data forKey: key];
                    //UIImage *image = [UIImage imageWithData: data];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView: self.view animated: YES];
                        [imagev sd_setImageWithURL: imageURL];
                    });
                });
            }
        } else {
            NSLog(@"dic is null");
            imagev.image = [UIImage imageWithContentsOfFile: imagePath];
        }
        imagev.contentMode = UIViewContentModeScaleAspectFit;
        [sc addSubview: imagev];
        [v addSubview: sc];
    } else {
        NSString *filename = [NSString stringWithFormat: @"%d.jpg", pageId];
        NSString *imagePath = [file stringByAppendingPathComponent: filename];
        
        UIImageView *imagev = [[UIImageView alloc]initWithFrame: v.bounds];
        imagev.contentMode = UIViewContentModeScaleAspectFit;
        imagev.tag = 1004;
        imagev.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imagev.accessibilityIdentifier = @"imagev";
        
        if (![_dic isKindOfClass: [NSNull class]]) {
            NSLog(@"dic is not kind of NSNull class");
            
            if (datalist[pageId][@"image_url"] == nil) {
                NSLog(@"datalist image_url is nil");
                NSLog(@"image_url: %@", datalist[pageId][@"image_url"]);
                
                NSString *imgStr = datalist[pageId][@"image"];
                imagev.image = [UIImage imageNamed: imgStr];
            } else {
                NSLog(@"datalist image_url is not nil");
                NSLog(@"image_url: %@", datalist[pageId][@"image_url"]);
                NSURL *url = [NSURL URLWithString: datalist[pageId][@"image_url"]];
                [imagev sd_setImageWithURL: url];
            }
        } else {
            NSLog(@"dic is kind of NSNull class");
            imagev.image = [UIImage imageWithContentsOfFile: imagePath];
        }
        
        imagev.contentMode = UIViewContentModeScaleAspectFit;
        [v addSubview: imagev];
        
        int page = self.mySV.contentOffset.x / self.mySV.frame.size.width;
        NSLog(@"page: %d", page);
    }
    
    // Final Page Setting
    if ([usefor isEqualToString: @"FinalPage"]) {
        NSLog(@"");
        NSLog(@"");
        
        NSLog(@"usefor is FinalPage");
        //NSLog(@"self.dic: %@", self.dic);
        
        pPoint = [self.dic[@"album"][@"point"] intValue];
        NSLog(@"pPoint: %lu", (unsigned long)pPoint);
        
        NSUInteger countPhoto = [self.dic[@"album"][@"count_photo"] intValue];
        NSLog(@"countPhoto: %lu", (unsigned long)countPhoto);
        
        photoArray = self.dic[@"photo"];
        //NSLog(@"photoArray: %@", photoArray);
        NSLog(@"photoArray.count: %lu", (unsigned long)photoArray.count);
        NSUInteger totalPhoto = photoArray.count;
        NSLog(@"totalPhoto: %lu", (unsigned long)totalPhoto);
        
        vertLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Vert];
        vertLayout.backgroundColor = [UIColor whiteColor];
        vertLayout.myCenterXOffset = 0;
        vertLayout.myCenterYOffset = 0;
        vertLayout.wrapContentWidth = YES;
        vertLayout.layer.cornerRadius = 16;
        vertLayout.tag = 2;
        vertLayout.accessibilityIdentifier = @"vertLayout";
        //vertLayout.padding = UIEdgeInsetsMake(32, 32, 32, 32);
        //vertLayout.myWidth = 200;
        
        UILabel *msgLabel = [UILabel new];
        msgLabel.textColor = [UIColor firstGrey];
        msgLabel.font = [UIFont boldSystemFontOfSize: 18];
        msgLabel.myCenterXOffset = 0;
        msgLabel.myTopMargin = 0;
        msgLabel.myBottomMargin = 16;
        msgLabel.wrapContentWidth = YES;
        msgLabel.tag = 3;
        //[vertLayout addSubview: msgLabel];
        
        NSString *topicStr;
        
        if (pPoint == 0) {
            if (totalPhoto == countPhoto) {
                NSLog(@"1st Case");
                
                topicStr = @"已完整閱讀";
                NSString *btnStr = @"離開";
                
                vertLayout.padding = UIEdgeInsetsMake(32, 32, 32, 32);
                [vertLayout addSubview: msgLabel];
                
                // Button Setup
                UIButton *btn = [wTools W_Button: self frame: CGRectMake(0, 0, 112, 48) imgname: nil SELL: @selector(readingComplete:) tag: pageId];
                [btn setTitle: btnStr forState: UIControlStateNormal];
                btn.backgroundColor = [UIColor secondGrey];
                btn.myTopMargin = 16;
                btn.myCenterXOffset = 0;
                btn.layer.cornerRadius = 8;
                [vertLayout addSubview: btn];
                
            } else if (totalPhoto != countPhoto) {
                NSLog(@"2nd Case");
                
                topicStr = @"馬上收藏看全部內容";
                NSString *btnStr = @"收藏";
                
                vertLayout.padding = UIEdgeInsetsMake(0, 32, 32, 32);
                
                UIImageView *imgV = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 144, 144)];
                imgV.image = [UIImage imageNamed: @"bg200_preview_collect"];
                imgV.myBottomMargin = 16;
                imgV.myTopMargin = -54;
                imgV.myCenterXOffset = 0;
                [vertLayout addSubview: imgV];
                
                msgLabel.myTopMargin = 16;
                [vertLayout addSubview: msgLabel];
                
                // Button Setup
                UIButton *btn = [wTools W_Button: self frame: CGRectMake(0, 0, 112, 48) imgname: nil SELL: @selector(freeCollect:) tag: pageId];
                [btn setTitle: btnStr forState: UIControlStateNormal];
                btn.backgroundColor = [UIColor firstMain];
                btn.myTopMargin = 16;
                btn.myCenterXOffset = 0;
                btn.layer.cornerRadius = 8;
                [vertLayout addSubview: btn];
            }
        } else if (pPoint > 0) {
            if (totalPhoto == countPhoto) {
                NSLog(@"3rd Case");
                
                topicStr = @"喜歡作品就給個鼓勵吧！";
                
                vertLayout.padding = UIEdgeInsetsMake(32, 32, 32, 32);
                
                [vertLayout addSubview: msgLabel];
                
                // Current Point Label Setup
                UILabel *currentPointLabel = [UILabel new];
                currentPointLabel.textColor = [UIColor secondGrey];
                currentPointLabel.font = [UIFont boldSystemFontOfSize: 16];
                currentPointLabel.myCenterXOffset = 0;
                currentPointLabel.myTopMargin = 16;
                currentPointLabel.myBottomMargin = 16;
                currentPointLabel.wrapContentWidth = YES;
                currentPointLabel.tag = 4;
                currentPointLabel.accessibilityIdentifier = @"currentPointLabel";
                
                NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
                userPoint = [[userPrefs objectForKey: @"pPoint"] integerValue];
                NSLog(@"userPoint: %ld", (long)userPoint);
                currentPointLabel.text = [NSString stringWithFormat: @"現有P點：%ld", (long)userPoint];
                [currentPointLabel sizeToFit];
                [vertLayout addSubview: currentPointLabel];
                
                // Sponsor Section
                MyLinearLayout *sponsorHorzLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Horz];
                sponsorHorzLayout.myTopMargin = 16;
                sponsorHorzLayout.myBottomMargin = 16;
                sponsorHorzLayout.myCenterYOffset = 0;
                
                // Set specific height for let the top and bottom margin works
                sponsorHorzLayout.myHeight = 48;
                //sponsorHorzLayout.backgroundColor = [UIColor redColor];
                sponsorHorzLayout.wrapContentWidth = YES;
                sponsorHorzLayout.wrapContentHeight = NO;
                
                [vertLayout addSubview: sponsorHorzLayout];
                
                UILabel *sponsorLabel = [UILabel new];
                sponsorLabel.textColor = [UIColor firstGrey];
                sponsorLabel.font = [UIFont systemFontOfSize: 16];
                sponsorLabel.text = @"我要贊助";
                sponsorLabel.myLeftMargin = 0;
                sponsorLabel.myRightMargin = 8;
                sponsorLabel.myCenterYOffset = 0;
                [sponsorLabel sizeToFit];
                [sponsorHorzLayout addSubview: sponsorLabel];
                
                inputField = [UITextField new];
                inputField.myLeftMargin = 5;
                inputField.myRightMargin = 5;
                inputField.myCenterYOffset = 0;
                inputField.delegate = self;
                inputField.font = [UIFont systemFontOfSize: 16];
                inputField.placeholder = [NSString stringWithFormat: @"最低額度：%lu", (unsigned long)pPoint];
                inputField.keyboardType = UIKeyboardTypeNumberPad;
                
                UIToolbar *numberToolBar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 0, 320, 40)];
                numberToolBar.barStyle = UIBarStyleDefault;
                numberToolBar.items = [NSArray arrayWithObjects:
                                       //[[UIBarButtonItem alloc] initWithTitle: @"取消" style: UIBarButtonItemStylePlain target: self action: @selector(cancelNumberPad)],
                                       [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil],
                                       [[UIBarButtonItem alloc] initWithTitle: @"完成" style: UIBarButtonItemStyleDone target: self action: @selector(doneNumberPad)] ,nil];
                
                [inputField sizeToFit];
                inputField.inputAccessoryView = numberToolBar;
                
                MyLinearLayout *textFieldBgView = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Horz];
                //UIView *textFieldBgView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 40, 48)];
                textFieldBgView.myLeftMargin = 8;
                textFieldBgView.myRightMargin = 8;
                textFieldBgView.myCenterYOffset = 0;
                textFieldBgView.wrapContentWidth = YES;
                textFieldBgView.myHeight = 48;
                textFieldBgView.layer.cornerRadius = 8;
                textFieldBgView.backgroundColor = [UIColor thirdGrey];
                [textFieldBgView addSubview: inputField];
                
                [textFieldBgView sizeToFit];
                [sponsorHorzLayout addSubview: textFieldBgView];
                
                UILabel *pLabel = [UILabel new];
                pLabel.myLeftMargin = 8;
                pLabel.myRightMargin = 0;
                pLabel.myCenterYOffset = 0;
                pLabel.text = @"P";
                [pLabel sizeToFit];
                [sponsorHorzLayout addSubview: pLabel];
                
                // Button Setup
                //NSString *btnStr = [NSString stringWithFormat: @"贊助 %luP", (unsigned long)pPoint];
                NSString *btnStr = [NSString stringWithFormat: @"贊助"];
                //btn.backgroundColor = [UIColor firstMain];
                
                UIButton *btn = [wTools W_Button: self frame: CGRectMake(0, 0, 112, 48) imgname: nil SELL: @selector(chargeCollect:) tag: pageId];
                [btn setTitle: btnStr forState: UIControlStateNormal];
                btn.backgroundColor = [UIColor firstMain];
                btn.myTopMargin = 16;
                btn.myCenterXOffset = 0;
                btn.layer.cornerRadius = 8;
                [vertLayout addSubview: btn];
                
            } else if (totalPhoto != countPhoto) {
                NSLog(@"4th Case");
                
                topicStr = @"贊助P點 看全部內容";
                
                vertLayout.padding = UIEdgeInsetsMake(0, 32, 32, 32);
                
                UIImageView *imgV = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 144, 144)];
                imgV.image = [UIImage imageNamed: @"bg200_preview_sponsor"];
                
                imgV.myBottomMargin = 16;
                imgV.myTopMargin = -65;
                imgV.myCenterXOffset = 0;
                [vertLayout addSubview: imgV];
                
                msgLabel.myTopMargin = 16;
                [vertLayout addSubview: msgLabel];
                
                // Current Point Label Setup
                UILabel *currentPointLabel = [UILabel new];
                currentPointLabel.textColor = [UIColor secondGrey];
                currentPointLabel.font = [UIFont boldSystemFontOfSize: 16];
                currentPointLabel.myCenterXOffset = 0;
                currentPointLabel.myTopMargin = 16;
                currentPointLabel.myBottomMargin = 16;
                currentPointLabel.wrapContentWidth = YES;
                currentPointLabel.tag = 4;
                currentPointLabel.accessibilityIdentifier = @"currentPointLabel";
                
                NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
                userPoint = [[userPrefs objectForKey: @"pPoint"] integerValue];
                
                NSLog(@"userPoint: %ld", (long)userPoint);
                
                currentPointLabel.text = [NSString stringWithFormat: @"現有P點：%ld", (long)userPoint];
                [currentPointLabel sizeToFit];
                [vertLayout addSubview: currentPointLabel];
                
                // Sponsor Section
                MyLinearLayout *sponsorHorzLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Horz];
                sponsorHorzLayout.myTopMargin = 16;
                sponsorHorzLayout.myBottomMargin = 16;
                sponsorHorzLayout.myCenterYOffset = 0;
                
                // Set specific height for let the top and bottom margin works
                sponsorHorzLayout.myHeight = 48;
                //sponsorHorzLayout.backgroundColor = [UIColor redColor];
                sponsorHorzLayout.wrapContentWidth = YES;
                sponsorHorzLayout.wrapContentHeight = NO;
                
                [vertLayout addSubview: sponsorHorzLayout];
                
                UILabel *sponsorLabel = [UILabel new];
                sponsorLabel.textColor = [UIColor firstGrey];
                sponsorLabel.font = [UIFont systemFontOfSize: 16];
                sponsorLabel.text = @"我要贊助";
                sponsorLabel.myLeftMargin = 0;
                sponsorLabel.myRightMargin = 8;
                sponsorLabel.myCenterYOffset = 0;
                [sponsorLabel sizeToFit];
                [sponsorHorzLayout addSubview: sponsorLabel];
                
                inputField = [UITextField new];
                inputField.myLeftMargin = 5;
                inputField.myRightMargin = 5;
                inputField.myCenterYOffset = 0;
                inputField.delegate = self;
                inputField.font = [UIFont systemFontOfSize: 16];
                inputField.placeholder = [NSString stringWithFormat: @"最低額度：%lu", (unsigned long)pPoint];
                inputField.keyboardType = UIKeyboardTypeNumberPad;
                
                UIToolbar *numberToolBar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 0, 320, 40)];
                numberToolBar.barStyle = UIBarStyleDefault;
                numberToolBar.items = [NSArray arrayWithObjects:
                                       //[[UIBarButtonItem alloc] initWithTitle: @"取消" style: UIBarButtonItemStylePlain target: self action: @selector(cancelNumberPad)],
                                       [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil],
                                       [[UIBarButtonItem alloc] initWithTitle: @"完成" style: UIBarButtonItemStyleDone target: self action: @selector(doneNumberPad)] ,nil];
                
                [inputField sizeToFit];
                inputField.inputAccessoryView = numberToolBar;
                
                MyLinearLayout *textFieldBgView = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Horz];
                //UIView *textFieldBgView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 40, 48)];
                textFieldBgView.myLeftMargin = 8;
                textFieldBgView.myRightMargin = 8;
                textFieldBgView.myCenterYOffset = 0;
                textFieldBgView.wrapContentWidth = YES;
                textFieldBgView.myHeight = 48;
                textFieldBgView.layer.cornerRadius = 8;
                textFieldBgView.backgroundColor = [UIColor thirdGrey];
                [textFieldBgView addSubview: inputField];
                
                [textFieldBgView sizeToFit];
                [sponsorHorzLayout addSubview: textFieldBgView];
                
                UILabel *pLabel = [UILabel new];
                pLabel.myLeftMargin = 8;
                pLabel.myRightMargin = 0;
                pLabel.myCenterYOffset = 0;
                pLabel.text = @"P";
                [pLabel sizeToFit];
                [sponsorHorzLayout addSubview: pLabel];
                
                
                // Button Setup
                //NSString *btnStr = [NSString stringWithFormat: @"贊助 %luP", (unsigned long)pPoint];
                NSString *btnStr = [NSString stringWithFormat: @"贊助"];
                
                UIButton *btn = [wTools W_Button: self frame: CGRectMake(0, 0, 112, 48) imgname: nil SELL: @selector(chargeCollectToSeeAll:) tag: pageId];
                [btn setTitle: btnStr forState: UIControlStateNormal];
                btn.backgroundColor = [UIColor firstMain];
                btn.myTopMargin = 16;
                btn.myCenterXOffset = 0;
                btn.layer.cornerRadius = 8;
                [vertLayout addSubview: btn];
            }
        }
        
        msgLabel.text = topicStr;
        [msgLabel sizeToFit];
        
        [v addSubview: vertLayout];
    }
    
    //影片
    if([usefor isEqualToString: @"video"]) {
        NSLog(@"usefor is video");
        
        UIView *bv = [[UIView alloc] initWithFrame: v.bounds];
        bv.backgroundColor = [UIColor blackColor];
        bv.alpha = 0.5;
        bv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        bv.accessibilityIdentifier = @"VideoBgV";
        [v addSubview: bv];
        
        NSString *refer = datalist[pageId][@"video_refer"];
        
        //NSLog(@"datalist: %@", datalist);
        
        if ([refer isEqualToString: @"embed"]) {
            UIButton *btn = [wTools W_Button: self frame: CGRectMake(0, 0, 100, 100) imgname: @"wbutton_play.png" SELL: @selector(videoembed:) tag: pageId];
            btn.center = CGPointMake(v.frame.size.width / 2, v.frame.size.height / 2);
            btn.accessibilityIdentifier = @"VideoBtn";
            [v addSubview: btn];
        }
        if ([refer isEqualToString: @"file"]) {
            UIButton *btn = [wTools W_Button: self frame: CGRectMake(0, 0, 100, 100) imgname: @"wbutton_play.png" SELL: @selector(videofile:) tag: pageId];
            btn.center = CGPointMake(v.frame.size.width / 2, v.frame.size.height / 2);
            btn.accessibilityIdentifier = @"VideoBtn";
            [v addSubview: btn];
        }
        if ([refer isEqualToString: @"system"]) {
            UIButton *btn = [wTools W_Button: self frame: CGRectMake(0, 0, 100, 100) imgname: @"wbutton_play.png" SELL: @selector(videofile:) tag: pageId];
            btn.center = CGPointMake(v.frame.size.width / 2, v.frame.size.height / 2);
            btn.accessibilityIdentifier = @"VideoBtn";
            [v addSubview: btn];
        }
        
        //[self addingAudioButton: v target: audioTarget page: pageId];
    }
    
    //拉霸
    if ([usefor isEqualToString: @"slot"]) {
        //[self addingAudioButton: v target: audioTarget page: pageId];
        
        NSLog(@"usefor is slot");
        NSLog(@"isOwn: %d", isOwn);
        
        UIView *bv = [[UIView alloc] initWithFrame: v.bounds];
        bv.backgroundColor = [UIColor blackColor];
        bv.alpha = 0.8;
        [v addSubview: bv];
        
        if (isOwn) {
            [self checkSlotDataInDatabaseOrNot];
            
            BOOL slotted = NO;
            
            for (int i = 0; i < self.slotArray.count; i++) {
                NSManagedObject *slotData = [self.slotArray objectAtIndex: i];
                NSLog(@"photoId: %ld", (long)[[slotData valueForKey: @"photoId"] integerValue]);
                
                if ([[slotData valueForKey: @"photoId"] integerValue] == [datalist[page][@"photo_id"] integerValue]) {
                    slotted = YES;
                }
            }
            
            NSLog(@"slotted: %d", slotted);
            NSLog(@"Before Adding slot btn");
            
            UIButton *btn = [wTools W_Button: self frame: CGRectMake(v.bounds.size.width - 100, v.bounds.size.height - 100, 180, 200) imgname: @"GiftImages1.png" SELL: @selector(showSlot:) tag: pageId];
            btn.center = CGPointMake(v.frame.size.width / 2, v.frame.size.height / 2);
            btn.accessibilityIdentifier = @"SlotBtn";
            [v addSubview: btn];
            
            NSLog(@"page: %d", page);
            
            if (slotted) {
                if (page == 0) {
                    NSLog(@"v.frame.origin.x: %f", v.frame.origin.x);
                    NSLog(@"scrollView.bounds.size.width * page: %f", scrollView.bounds.size.width * page);
                    
                    if (v.frame.origin.x == scrollView.bounds.size.width * page) {
                        NSLog(@"self slotPhotoUseFor: v");
                        [self slotPhotoUseFor: v];
                    }
                }
            }
        } else {
            [self createViewForCollectionCheck: v];
        }
    }
    
    //兌換
    if ([usefor isEqualToString: @"exchange"]) {
        NSLog(@"usefor is exchange");
        NSLog(@"isOwn: %d", isOwn);
        
        UIView *bv = [[UIView alloc] initWithFrame: v.bounds];
        bv.backgroundColor = [UIColor blackColor];
        bv.alpha = 0.8;
        [v addSubview: bv];
        
        if (isOwn) {
            [self checkSlotDataInDatabaseOrNot];
            
            if (page == 0) {
                NSLog(@"v.frame.origin.x: %f", v.frame.origin.x);
                NSLog(@"scrollView.bounds.size.width * page: %f", scrollView.bounds.size.width * page);
                
                if (v.frame.origin.x == scrollView.bounds.size.width * page) {
                    NSLog(@"self getPhotoUseFor: v");
                    [self getPhotoUseFor: v];
                }
            }
        } else {
            [self createViewForCollectionCheck: v];
        }
    }
    
    return v;
}

#pragma mark - Create View for Checking Collect or not
- (void)createViewForCollectionCheck:(UIView *)v {
    MyLinearLayout *checkCollectLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Vert];
    checkCollectLayout.wrapContentHeight = YES;
    checkCollectLayout.myCenterXOffset = 0;
    checkCollectLayout.myCenterYOffset = 0;
    checkCollectLayout.backgroundColor = [UIColor whiteColor];
    checkCollectLayout.padding = UIEdgeInsetsMake(16, 16, 16, 16);
    checkCollectLayout.myWidth = [UIScreen mainScreen].bounds.size.width - 100;
    checkCollectLayout.myHeight = 150.0;
    checkCollectLayout.layer.cornerRadius = 16;
    [v addSubview: checkCollectLayout];
    
    UILabel *topicLabel = [UILabel new];
    topicLabel.wrapContentHeight = YES;
    topicLabel.myTopMargin = 0;
    topicLabel.myLeftMargin = topicLabel.myRightMargin = 0;
    topicLabel.myBottomMargin = 8;
    topicLabel.text = @"本頁功能要先收藏或贊助才能使用";
    [LabelAttributeStyle changeGapString: topicLabel content: topicLabel.text];
    topicLabel.textColor = [UIColor firstGrey];
    topicLabel.font = [UIFont systemFontOfSize: 20.0];
    topicLabel.numberOfLines = 0;
    [topicLabel sizeToFit];
    [checkCollectLayout addSubview: topicLabel];
    
    UIButton *collectBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    [collectBtn addTarget: self action: @selector(collectAlbum) forControlEvents: UIControlEventTouchUpInside];
    collectBtn.frame = CGRectMake(0.0, 0.0, 112.0, 48.0);
    collectBtn.myTopMargin = 8;
    collectBtn.myCenterXOffset = 0;
    collectBtn.backgroundColor = [UIColor firstMain];
    collectBtn.layer.cornerRadius = 6;
    
    NSString *btnStrForExchange;
    
    pPoint = [self.dic[@"album"][@"point"] intValue];
    NSLog(@"pPoint: %lu", (unsigned long)pPoint);
    
    if (pPoint == 0) {
        btnStrForExchange = @"收藏";
    } else {
        btnStrForExchange = @"贊助";
    }
    
    [collectBtn setTitle: btnStrForExchange forState: UIControlStateNormal];
    [checkCollectLayout addSubview: collectBtn];
}

#pragma mark - To Final Page
- (void)collectAlbum {
    NSLog(@"collectAlbum");
    
    if (pPoint == 0) {
        NSLog(@"pPoint == 0");
        [self buyAlbum];
    } else {
        NSLog(@"pPoint != 0");
        [self.mySV moveToPage: (int)(datalist.count - 1)];
    }
}

#pragma mark - NumberPad ToolBar Button Selector Methods
- (void)cancelNumberPad
{
    NSLog(@"cancelNumberPad");
    [inputField resignFirstResponder];
}

- (void)doneNumberPad
{
    NSLog(@"doneNumberPad");
    [inputField resignFirstResponder];
}

#pragma mark - UITextField Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    selectText = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    selectText = nil;
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    NSString *resultString = [textField.text stringByReplacingCharactersInRange: range
                                                                     withString: string];
    NSLog(@"newLength: %lu", (unsigned long)newLength);
    NSLog(@"resultString: %@", resultString);
    
    if (textField == inputField) {
        NSLog(@"textField.text: %@", textField.text);
        NSLog(@"textField.text intValue: %d", [textField.text intValue]);
        
        if (newLength > 4) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Keyboard Notification
- (void)addKeyboardNotification {
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
    NSLog(@"");
    
    sponsorTextFieldEditing = YES;
    NSLog(@"sponsorTextFieldEditing: %d", sponsorTextFieldEditing);
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    NSLog(@"deviceOrientation: %ld", (long)deviceOrientation);
    
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    NSLog(@"interfaceOrientation: %ld", (long)interfaceOrientation);
    NSLog(@"");
    
    if (interfaceOrientation == 1) {
        NSLog(@"interfaceOrientation: %ld", (long)interfaceOrientation);
        
        // If you want to move vertLayout.frame up, you should use "-="
        // If you want to move vertLayout.bounds up, you should use "+="
        
        portraitVertLayoutRect = vertLayout.frame;
        NSLog(@"portraitVertLayoutRect: %@", NSStringFromCGRect(portraitVertLayoutRect));
        
        [UIView animateWithDuration: 0.3 animations:^{
            CGRect rect = vertLayout.frame;
            rect.origin.y -= 40;
            vertLayout.frame = rect;
            
            NSLog(@"rect.origin: %@", NSStringFromCGPoint(rect.origin));
        }];
    }
    
    if (interfaceOrientation == 3 || interfaceOrientation == 4) {
        NSLog(@"interfaceOrientation: %ld", (long)interfaceOrientation);
        
        landscapeVertLayoutRect = vertLayout.frame;
        NSLog(@"landscapeVertLayoutRect: %@", NSStringFromCGRect(landscapeVertLayoutRect));
        
        [UIView animateWithDuration: 0.3 animations:^{
            CGRect rect = vertLayout.frame;
            rect.origin.y -= 110;
            vertLayout.frame = rect;
            
            NSLog(@"rect.origin: %@", NSStringFromCGPoint(rect.origin));
        }];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSLog(@"keyboardWillBeHidden");
    NSLog(@"");
    
    sponsorTextFieldEditing = NO;
    NSLog(@"sponsorTextViewEditing: %d", sponsorTextFieldEditing);
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    NSLog(@"deviceOrientation: %ld", (long)deviceOrientation);
    
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    NSLog(@"interfaceOrientation: %ld", (long)interfaceOrientation);
    NSLog(@"");
    
    if (interfaceOrientation == 1) {
        NSLog(@"interfaceOrientation: %ld", (long)interfaceOrientation);
        
        [UIView animateWithDuration: 0.3 animations:^{
            CGRect rect = vertLayout.frame;
            rect.origin.y += 40;
            vertLayout.frame = rect;
            
            NSLog(@"rect.origin: %@", NSStringFromCGPoint(rect.origin));
        }];
    }
    
    if (interfaceOrientation == 3 || interfaceOrientation == 4) {
        NSLog(@"interfaceOrientation: %ld", (long)interfaceOrientation);
        
        [UIView animateWithDuration: 0.3 animations:^{
            CGRect rect = vertLayout.frame;
            rect.origin.y += 90;
            vertLayout.frame = rect;
            
            NSLog(@"rect.origin: %@", NSStringFromCGPoint(rect.origin));
        }];
    }
}

#pragma mark - Final Page Button Selector Methods
- (void)readingComplete:(UIButton *)btn
{
    NSLog(@"readingComplete");
    [self back: nil];
}

- (void)freeCollect:(UIButton *)btn
{
    NSLog(@"freeCollect");
    [self buyAlbum];
}

- (void)chargeCollect:(UIButton *)btn
{
    NSLog(@"chargeCollect");
    
    NSLog(@"userPoint: %ld", (long)userPoint);
    NSLog(@"albumPoint: %ld", (long)albumPoint);
    
    NSString *inputText = inputField.text;
    
    if ([inputText isEqualToString: @""]) {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor thirdPink];
        
        [self.view makeToast: @"請輸入贊助數量"
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
        
        [inputField resignFirstResponder];
        
    } else if ([inputText intValue] < pPoint) {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor thirdPink];
        
        [self.view makeToast: [NSString stringWithFormat: @"最低額度：%lu", (unsigned long)pPoint]
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
        
        [inputField resignFirstResponder];
    } else {
        [self checkBuyingAlbum];
    }
}

- (void)chargeCollectToSeeAll:(UIButton *)btn
{
    NSLog(@"chargeCollectToSeeAll");
    
    NSLog(@"userPoint: %ld", (long)userPoint);
    NSLog(@"albumPoint: %ld", (long)albumPoint);
    
    NSString *inputText = inputField.text;
    
    if ([inputText isEqualToString: @""]) {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor thirdPink];
        
        [self.view makeToast: @"請輸入贊助數量"
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
        
        [inputField resignFirstResponder];
        
    } else if ([inputText intValue] < pPoint) {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor thirdPink];
        
        [self.view makeToast: [NSString stringWithFormat: @"最低額度：%lu", (unsigned long)pPoint]
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
        
        [inputField resignFirstResponder];
    } else {
        [self checkBuyingAlbum];
    }
}

- (void)checkBuyingAlbum
{
    NSLog(@"checkBuyingAlbum");
    
    NSInteger inputPoint = [inputField.text intValue];
    NSLog(@"inputPoint: %ld", (long)inputPoint);
    
    if (userPoint >= albumPoint) {
        if (userPoint >= inputPoint) {
            //NSString *msgStr = [NSString stringWithFormat: @"確定贊助%ldP?", (long)albumPoint];
            
            // Show inputPoint for displaying the correct point
            NSString *msgStr = [NSString stringWithFormat: @"確定贊助%ldP?", (long)inputPoint];
            
            //[self showBuyAlbumCustomAlert: msgStr option: @"buyAlbum"];
            [self showBuyAlbumCustomAlert: msgStr option: @"buyAlbum" pointStr: [NSString stringWithFormat: @"%ld", (long)inputPoint]];
        } else {
            //[self showBuyAlbumCustomAlert: @"你的P點不足，前往購點?" option: @"buyPoint"];
            [self showBuyAlbumCustomAlert: @"你的P點不足，前往購點?" option: @"buyPoint" pointStr: @""];
        }
    } else if (userPoint < albumPoint) {
        //[self showBuyAlbumCustomAlert: @"你的P點不足，前往購點?" option: @"buyPoint"];
        [self showBuyAlbumCustomAlert: @"你的P點不足，前往購點?" option: @"buyPoint" pointStr: @""];
    }
}

#pragma mark - View Controller Rotation

- (void)viewDidLayoutSubviews {
    NSLog(@"viewDidLayoutSubviews");
    
    NSLog(@"Screen Bounds: %@", NSStringFromCGRect([UIScreen mainScreen].bounds));
    NSLog(@"showview: %@", showview);
    NSLog(@"self.mySV: %@", self.mySV);
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                self.textAndImageVertLayout.myBottomMargin = 0;
                break;
            case 1334:
                printf("iPhone 6/6S/7/8");
                self.textAndImageVertLayout.myBottomMargin = 0;
                break;
            case 1920:
                printf("iPhone 6+/6S+/7+/8+");
                self.textAndImageVertLayout.myBottomMargin = 0;
                break;
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                self.textAndImageVertLayout.myBottomMargin = 0;
                break;
            case 2436:
            {
                printf("iPhone X");
                
                showview.frame = CGRectMake(0, 20, 375, 758);
                self.mySV.frame = CGRectMake(0, 0, 375, 758);
                
                CGSize oldSize = self.mySV.contentSize;
                oldSize.height = 647;
                self.mySV.contentSize = oldSize;
                
                self.textAndImageVertLayout.myBottomMargin = 40;
            }
                break;
            default:
                printf("unknown");
                self.textAndImageVertLayout.myBottomMargin = 0;
                break;
        }
    }
}

- (void)viewWillLayoutSubviews
{
    /*
     NSLog(@"----------------------");
     NSLog(@"viewWillLayoutSubviews");
     */
    [self checkDeviceOrientation];
}

- (void)checkDeviceOrientation
{
    /*
     NSLog(@"----------------------");
     NSLog(@"checkDeviceOrientation");
     */
    
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
        //NSLog(@"UIDeviceOrientationIsPortrait");
        
        //NSLog(@"Before");
        //NSLog(@"self.collectionView.frame: %@", NSStringFromCGRect(self.collectionView.frame));
        self.collectionView.myWidth = 320;
        
        /*
         CGRect rect = self.collectionView.frame;
         rect.size.width = 320;
         self.collectionView.frame = rect;
         */
        //NSLog(@"self.collectionView.frame: %@", NSStringFromCGRect(self.collectionView.frame));
        
        self.textView.myLeftMargin = self.textView.myRightMargin = 48;
        
        /*
         NSLog(@"");
         NSLog(@"self.mySV.contentOffset.x: %f", self.mySV.contentOffset.x);
         NSLog(@"self.mySV.frame.size.width: %f", self.mySV.frame.size.width);
         */
        int page = self.mySV.contentOffset.x / self.mySV.frame.size.width;
        
        /*
         NSLog(@"page: %d", page);
         NSLog(@"");
         */
        
        isLandscape = NO;
        //NSLog(@"isLandscape: %d", isLandscape);
        
        self.lineView.hidden = NO;
        self.collectionView.hidden = NO;
    }
    
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        //NSLog(@"UIDeviceOrientationIsLandscape");
        
        //NSLog(@"After");
        //NSLog(@"self.collectionView.frame: %@", NSStringFromCGRect(self.collectionView.frame));
        
        self.collectionView.myWidth = 568;
        /*
         CGRect rect = self.collectionView.frame;
         rect.size.width = 568;
         self.collectionView.frame = rect;
         */
        //NSLog(@"self.collectionView.frame: %@", NSStringFromCGRect(self.collectionView.frame));
        
        //NSLog(@"self.view.myWidth: %f", self.view.myWidth);
        self.textView.myLeftMargin = self.textView.myRightMargin = 85.2;
        
        isLandscape = YES;
        //NSLog(@"isLandscape: %d", isLandscape);
        
        self.lineView.hidden = YES;
        self.collectionView.hidden = YES;
    }
    
    //To show complete cell when rotating
    CGPoint offset = self.collectionView.contentOffset;
    CGPoint newOffset = CGPointMake(0, offset.y);
    [self.collectionView setContentOffset: newOffset animated: NO];
    
    /*
     NSLog(@"End CheckDeviceOrientation");
     NSLog(@"--------------------------");
     */
}

/*
 - (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
 {
 NSLog(@"viewWillTransitionToSize");
 }
 */

/*
 - (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame;   // in screen coordinates
 {
 NSLog(@"willChangeStatusBarFrame");
 NSLog(@"TestReadBookViewController");
 }
 */

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"");
    NSLog(@"willRotateToInterfaceOrientation");
    
    [self beforeRotation];
    
    NSLog(@"");
    NSLog(@"---------------------");
    NSLog(@"Calling mySV Function");
    NSLog(@"---------------------");
    NSLog(@"");
    
    // Release pages for getting right image size
    //[self.mySV resetPage: _firstVisiblePageIndexBeforeRotation];
    //[self.mySV unLoadNestPage: _firstVisiblePageIndexBeforeRotation];
    NSLog(@"-----------------------------");
    NSLog(@"Start self.mySV relaseAllPage");
    //[self.mySV relaseAllPage];
    NSLog(@"End self.mySV relaseAllPage");
    NSLog(@"-----------------------------");
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"");
    NSLog(@"willAnimateRotationToInterfaceOrientation");
    
    [self checkDeviceOrientation];
    
    [self afterRotation];
    
    NSLog(@"");
    NSLog(@"---------------------");
    NSLog(@"Calling loadNestPage");
    NSLog(@"---------------------");
    NSLog(@"");
    
    NSLog(@"-----------------------------");
    NSLog(@"Start self.mySV loadNestPage");
    // Loading pages for getting right image size
    //[self.mySV loadNestPage: _firstVisiblePageIndexBeforeRotation];
    NSLog(@"End self.mySV loadNestPage");
    NSLog(@"-----------------------------");
}

- (void)beforeRotation
{
    NSLog(@"");
    NSLog(@"--------------");
    NSLog(@"beforeRotation");
    NSLog(@"--------------");
    NSLog(@"");
    
    //NSLog(@"self.mySV.contentSize: %@", NSStringFromCGSize(self.mySV.contentSize));
    //NSLog(@"self.mySV.bounds: %@", NSStringFromCGRect(self.mySV.bounds));
    
    CGFloat offset = self.mySV.contentOffset.x;
    NSLog(@"");
    NSLog(@"old Offset Data");
    //NSLog(@"self.mySV.contentOffset: %@", NSStringFromCGPoint(self.mySV.contentOffset));
    NSLog(@"offset: %f", offset);
    
    NSLog(@"");
    CGFloat pageWidth = self.mySV.bounds.size.width;
    NSLog(@"pageWidth: %f", pageWidth);
    
    if (offset >= 0)
        _firstVisiblePageIndexBeforeRotation = floorf(offset / pageWidth);
    else
        _firstVisiblePageIndexBeforeRotation = 0;
    
    NSLog(@"_firstVisiblePageIndexBeforeRotation: %lu", (unsigned long)_firstVisiblePageIndexBeforeRotation);
    
    _percentScrolledIntoFirstVisiblePage = offset / pageWidth - _firstVisiblePageIndexBeforeRotation;
    
    NSLog(@"_percentScrolledIntoFirstVisiblePage: %f", _percentScrolledIntoFirstVisiblePage);
    
    NSLog(@"End beforeRotation");
    NSLog(@"------------------");
}

- (void)afterRotation
{
    NSLog(@"");
    NSLog(@"-------------");
    NSLog(@"afterRotation");
    NSLog(@"-------------");
    NSLog(@"");
    
    //NSLog(@"self.mySV.bounds: %@", NSStringFromCGRect(self.mySV.bounds));
    
    self.mySV.contentSize = [self ContentSizeInScrollView: self.mySV];
    //NSLog(@"self.mySV.contentSize: %@", NSStringFromCGSize(self.mySV.contentSize));
    //NSLog(@"self.mySV.bounds: %@", NSStringFromCGRect(self.mySV.bounds));
    
    NSLog(@"");
    CGFloat pageWidth = self.mySV.bounds.size.width;
    NSLog(@"pageWidth: %f", pageWidth);
    
    CGFloat newOffsetX = (_firstVisiblePageIndexBeforeRotation + _percentScrolledIntoFirstVisiblePage) * pageWidth;
    NSLog(@"New Offset Data");
    NSLog(@"newOffsetX: %f", newOffsetX);
    
    NSLog(@"");
    self.mySV.contentOffset = CGPointMake(newOffsetX, 0);
    //NSLog(@"self.mySV.contentOffset: %@", NSStringFromCGPoint(self.mySV.contentOffset));
    NSLog(@"");
    //NSLog(@"self.mySV: %@", self.mySV);
    NSLog(@"");
    NSLog(@"self.collectionView.contentOffset.x: %f", self.collectionView.contentOffset.x);
    
    NSLog(@"");
    NSLog(@"_firstVisiblePageIndexBeforeRotation: %d", _firstVisiblePageIndexBeforeRotation);
    [self.mySV moveToPage: _firstVisiblePageIndexBeforeRotation];
    
    NSLog(@"End afterRotation");
    NSLog(@"-----------------");
}

#pragma mark - Check Audio
- (void)checkAudioWhenMovingPage
{
    //目前頁數
    int wNowPage = [self.mySV getNowPage: 2];
    NSLog(@"current page: %i", wNowPage);
    NSLog(@"dic album count_photo: %d", [_dic[@"album"][@"count_photo"] intValue]);
    
    NSInteger page = self.mySV.contentOffset.x / self.mySV.frame.size.width;
    
    NSString *usefor = datalist[page][@"usefor"];
    typelabel.text = usefor;
    
    
    //判斷播放音樂
    NSString *audiorefer = datalist[page][@"audio_refer"];
    NSLog(@"audiorefer: %@", audiorefer);
    
    NSString *photoAudioTarget = datalist[page][@"audio_target"];
    NSLog(@"photoAudioTarget: %@", photoAudioTarget);
    
    BOOL isplay = NO;
    
    if (playWholeAlbum) {
        NSLog(@"playWholeAlbum is set to YES");
        
        if (self.avPlayer != nil) {
            NSLog(@"avPlayer is not nil");
            
            if (isplay) {
                NSLog(@"isPlay set to YES");
                [self.avPlayer pause];
                NSLog(@"avPlayer is paused");
            } else {
                if (isplayaudio) {
                    NSLog(@"isPlayAudio is set to Yes");
                    
                    if (self.audioSwitch) {
                        [self.avPlayer play];
                        NSLog(@"avPlayer is played");
                    }
                }
            }
        }
    } else {
        NSLog(@"playWholeAlbum is set to NO");
        
        if (![photoAudioTarget isKindOfClass: [NSNull class]]) {
            NSLog(@"photoAudioTarget is not null");
            isplay = YES;
            
            if (![photoAudioTarget isEqualToString: @""]) {
                [self avPlayerSetUp: photoAudioTarget];
            }
        } else {
            NSLog(@"photoAudioTarget is null");
            isplay = NO;
            
            [self.avPlayer pause];
        }
    }
}

- (void)checkAudioWhenViewConrtrollerShowsUp {
    NSLog(@"checkAudioWhenViewConrtrollerShowsUp");
    
    if (self.avPlayer != nil) {
        NSLog(@"avPlayer is not nil");
        
        if (isplayaudio) {
            NSLog(@"isPlayAudio is set to Yes");
            
            if (shouldTurnOffAudio) {
                [self.avPlayer pause];
            } else {
                [self.avPlayer play];
            }
            
            NSLog(@"avPlayer is played");
        } else {
            [self.avPlayer pause];
        }
    }
}

#pragma mark - ScrollView Delegate Methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView  {
    return [[scrollView subviews]objectAtIndex:0];
}

-(CGSize)ContentSizeInScrollView:(MyScrollView *)scrollView
{
    //NSLog(@"ContentSizeInScrollView");
    //NSLog(@"contentSize: %@", NSStringFromCGSize(CGSizeMake(scrollView.bounds.size.width * datalist.count, scrollView.bounds.size.height)));
    return CGSizeMake(scrollView.bounds.size.width * datalist.count, scrollView.bounds.size.height);
}

-(int)TotalPageInScrollView:(MyScrollView *)scrollView
{
    //NSLog(@"TotalPageInScrollView");
    NSLog(@"datalist.count: %lu", (unsigned long)datalist.count);
    return datalist.count;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"");
    NSLog(@"TestReadBookViewController.");
    NSLog(@"scrollViewDidScroll");
    
    //[self scrollToNextCell];
    
    [inputField resignFirstResponder];
    
    if (scrollView == self.mySV) {
        NSLog(@"scrollView == self.mySV");
        
//        int wNowPage = [self.mySV getNowPage: 2];
//        NSLog(@"");
//        NSLog(@"current page: %i", wNowPage);
//        selectItem = wNowPage;
        
        NSInteger page = self.mySV.contentOffset.x / self.mySV.frame.size.width;
        selectItem = page;
        NSLog(@"selectItem: %ld", (long)selectItem);
        NSLog(@"selectItemArray.count: %lu", (unsigned long)selectItemArray.count);
        
        for (int i = 0; i < selectItemArray.count; i++) {
            NSLog(@"i: %d", i);
            if (i == selectItem) {
                selectItemArray[i] = @"selected";
            } else {
                selectItemArray[i] = @"notSelected";
            }
        }
        
        /*
        NSLog(@"isLandscape: %d", isLandscape);
        NSLog(@"_firstVisiblePageIndexBeforeRotation: %d", _firstVisiblePageIndexBeforeRotation);
        NSLog(@"shouldFixPageNumber: %d", shouldFixPageNumber);
        */
         
        // To Avoid crash when TestReadBookViewController is disappeared
        if (shouldFixPageNumber) {
            page = _firstVisiblePageIndexBeforeRotation;
            selectItem = _firstVisiblePageIndexBeforeRotation;
        }
        
        //NSLog(@"datalist: %@", datalist);
//        [self textViewSetup:wNowPage];
        
        // CollectionViewCell Section
        // Move CollectionViewCell When self.mySV Scroll
        NSLog(@"selectItem: %ld", (long)selectItem);
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem: selectItem inSection: 0];
        [self.collectionView scrollToItemAtIndexPath: indexPath atScrollPosition: UICollectionViewScrollPositionCenteredHorizontally animated: YES];
        
        // Check Selected Cell or Not
        [self checkCell];
        
        NSLog(@"After checkCell");
//        NSLog(@"wNowPage: %d", wNowPage);
        
        if (datalist[page][@"image_url"] == nil) {
            NSLog(@"datalist wNowPage image_url == nil");
            self.pageOrderLabel.text = [NSString stringWithFormat: @"%ld / %lu", (long)page, (unsigned long)photoArray.count];
        } else {
            NSLog(@"datalist wNowPage image_url != nil");
            self.pageOrderLabel.text = [NSString stringWithFormat: @"%ld / %lu", (long)page + 1, (unsigned long)photoArray.count];
        }
        
        NSLog(@"Before setting self.pageOrderLabel.text");
        
        
        [self.pageOrderLabel sizeToFit];
        
        NSLog(@"After setting self.pageOrderLabel.text");
        
        NSString *photoAudioTarget = datalist[page][@"audio_target"];
        NSLog(@"photoAudioTarget: %@", photoAudioTarget);
        
        //NSLog(@"datalist: %@", datalist);
        
        //NSString *location = self.dic[@"photo"][wNowPage][@"location"];
        NSString *location = datalist[page][@"location"];
        NSLog(@"location: %@", location);
        
        if (![location isKindOfClass: [NSNull class]]) {
            if (![location isEqualToString: @""]) {
                self.locationBtn.hidden = NO;
            } else {
                self.locationBtn.hidden = YES;
            }
        } else {
            self.locationBtn.hidden = NO;
        }
        
        if ([audioMode isEqualToString: @"none"]) {
            self.soundBtn.hidden = YES;
            self.mScrubber.hidden = YES;
        } else if ([audioMode isEqualToString: @"singular"]) {
            self.soundBtn.hidden = NO;
            self.mScrubber.hidden = NO;
        } else if ([audioMode isEqualToString: @"plural"]) {
            if ([photoAudioTarget isKindOfClass: [NSNull class]]) {
                NSLog(@"photoAudioTarget is Null");
                self.soundBtn.hidden = YES;
                self.mScrubber.hidden = YES;
            } else {
                NSLog(@"photoAudioTarget is not Null");
                self.soundBtn.hidden = NO;
                self.mScrubber.hidden = NO;
            }
        }
    }
    
    if (scrollView == self.collectionView) {
        NSLog(@"scrollView == self.collectionView");
        [self.collectionView reloadData];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"");
    NSLog(@"scrollViewDidEndDecelerating");
    
    NSInteger page = self.mySV.contentOffset.x / self.mySV.frame.size.width;
    NSLog(@"page: %ld", (long)page);
    NSLog(@"scrollView.accessibilityIdentifier: %@", scrollView.accessibilityIdentifier);
    
    [self textViewSetup: page];
    
    if (lastContentOffset.x < (int)scrollView.contentOffset.x) {
        NSLog(@"Scrolled Right");
    }
    else if (lastContentOffset.x > (int)scrollView.contentOffset.x) {
        NSLog(@"Scrolled Left");
    }
    
    else if (lastContentOffset.y < scrollView.contentOffset.y) {
        NSLog(@"Scrolled Down");
    }
    
    else if (lastContentOffset.y > scrollView.contentOffset.y) {
        NSLog(@"Scrolled Up");
    }
    
    if (isGiftScrollViewScrolling) {
        NSLog(@"GiftScrollView is Scrolling");
        NSLog(@"isGiftScrollViewScrolling: %d", isGiftScrollViewScrolling);
    } else {
        NSLog(@"GiftScrollView is not Scrolling");
        NSLog(@"isGiftScrollViewScrolling: %d", isGiftScrollViewScrolling);
        if (scrollView == self.collectionView) {
            NSLog(@"scrollView == self.collectionView");
            [self.collectionView reloadData];
        } else {
            if (isOwn) {
                NSLog(@"is owned");
                if ([datalist[page][@"usefor"] isEqualToString: @"slot"]) {
                    [self loadSlotDataForEachPage: page];
                } else if ([datalist[page][@"usefor"] isEqualToString: @"exchange"]) {
                    [self loadExchangeDataForEachPage: page];
                }
            } else {
                NSLog(@"is not owned");
            }
        }
    }
    
    
    // From Calling MovePage Function
    if (scrollView == nil) {
        NSLog(@"scrollView: %@", scrollView);
        [self checkAudioWhenMovingPage];
    }
    
    if (scrollView == self.mySV) {
        NSLog(@"scrollView == self.mySV");
        [self checkAudioWhenMovingPage];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewWillBeginDragging");
    NSLog(@"");
    
    NSLog(@"scrollView.accessibilityIdentifier: %@", scrollView.accessibilityIdentifier);
    
    if ([scrollView.accessibilityIdentifier isEqualToString: @"GiftScrollView"]) {
        isGiftScrollViewScrolling = YES;
    } else {
        isGiftScrollViewScrolling = NO;
    }
    
    if (scrollView == self.collectionView) {
        NSLog(@"scrollView == self.collectionView");
    }
    if (scrollView == self.mySV) {
        lastContentOffset.x = scrollView.contentOffset.x;
        
        int wNowPage = [self.mySV getNowPage: 2];
        NSLog(@"current page: %i", wNowPage);
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    NSLog(@"");
    NSLog(@"scrollViewDidEndDragging");
    
    if (scrollView == self.mySV) {
        int wNowPage = [self.mySV getNowPage: 2];
        NSLog(@"current page: %i", wNowPage);
        
        //NSLog(@"dic: %@", _dic);
        NSLog(@"dic album count_photo: %d", [_dic[@"album"][@"count_photo"] intValue]);
        
        //int totalPage = [_dic[@"album"][@"count_photo"] intValue];
        //NSLog(@"totalPage: %d", totalPage);
        
        // datalist.count => 預覽照片數目
        //NSLog(@"datalist: %@", datalist);
        NSLog(@"datalist.count: %lu", (unsigned long)datalist.count);
        
        if (lastContentOffset.x < scrollView.contentOffset.x) {
            NSLog(@"moved right");
            
            if (!_isDownloaded) {
                NSLog(@"isDownloaded: %d", _isDownloaded);
                
                if (wNowPage == datalist.count - 1) {
                    NSLog(@"Last Page");
                    
                    if (datalist.count == [_dic[@"album"][@"count_photo"] intValue]) {
                        NSLog(@"Total amount of photo is equal to Preview photo");
                        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                        style.messageColor = [UIColor blackColor];
                        style.backgroundColor = [UIColor whiteColor];
                        //[self.view makeToast: @"當前已經是最後一頁" duration: 1.0 position: CSToastPositionBottom style: style];
                        
                    } else if (datalist.count <= [_dic[@"album"][@"count_photo"] intValue]) {
                        
                        NSLog(@"The amount of photo is smaller than the Total amount of photo");
                        
                        if ([_dic[@"album"][@"point"] intValue] == 0) {
                            NSLog(@"album point is equal to 0");
                            
                            NSString *msg = @"收藏並完整閱讀";
                            //[self showAlertViewForCollect: msg];
                            //[self showCustomCollectionAlert: msg];
                        } else if ([_dic[@"album"][@"point"] intValue] > 0) {
                            NSLog(@"album point is bigger than 0");
                            NSString *msg = [NSString stringWithFormat: @"贊助收藏 %d P", [_dic[@"album"][@"point"] intValue]];
                            //[self showAlertViewForCollect: msg];
                            //[self showCustomCollectionAlert: msg];
                        }
                    }
                }
            }
        } else if (lastContentOffset.x > scrollView.contentOffset.x) {
            NSLog(@"moved left");
        } else {
            NSLog(@"didn't move");
        }
    }
}

- (void)textViewSetup:(NSInteger)page {
    NSLog(@"textViewSetup");
    NSLog(@"page: %ld", (long)page);
    NSLog(@"datalist.count: %lu", (unsigned long)datalist.count);
    
    // Description TextView
    NSString *description = datalist[page][@"description"];
    NSLog(@"description: %@", description);
    
    self.textView.hidden = YES;
    
    if (![description isEqualToString: @""]) {
        self.textView.text = description;
        
        // Set delay for adjust textView text display
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            NSLog(@"self.textView scrollRangeToVisible");
            [self.textView setContentOffset: CGPointZero animated: NO];
            //[self.textView scrollRangeToVisible: NSMakeRange(0, 1)];
        });                
    } else {
        self.textView.text = @"";
    }
    
    [self.textView sizeToFit];
    
    float rows = (self.textView.contentSize.height - self.textView.textContainerInset.top - self.textView.textContainerInset.bottom) / self.textView.font.lineHeight;
    int numberOfLines = (int)rows;
    
    if (numberOfLines < 2) {
        self.textView.textAlignment = NSTextAlignmentCenter;
    } else if (numberOfLines > 1) {
        self.textView.textAlignment = NSTextAlignmentLeft;
    }
    
    self.textView.hidden = NO;
}

- (void)unlockTheFullAlbum
{
    if (albumPoint == 0) {
        [self buyAlbum];
    } else {
        NSString *msgStr = [NSString stringWithFormat: @"確定贊助%ldP?", (long)albumPoint];
        //[self showCustomCollectAlertView: msgStr option: @"buyAlbum"];
        [self showCustomCollectAlertView: msgStr option: @"buyAlbum" pointStr: [NSString stringWithFormat: @"%ld", (long)albumPoint]];
    }
}

#pragma mark - Collect & Download Book
//改變成擁有
-(void)own{
    /*
     [_openbtn setTitle:NSLocalizedString(@"Works-viewAlbum", @"") forState:UIControlStateNormal];
     [_openbtn setImage:[UIImage imageNamed:@"button_open.png"] forState:UIControlStateNormal];
     [_openbtn setImage:[UIImage imageNamed:@"button_open_click.png"] forState:UIControlStateHighlighted];
     [_openbtn setImage:[UIImage imageNamed:@"button_open_click.png"] forState:UIControlStateSelected];
     */
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary: _dic];
    NSMutableDictionary *album = [[NSMutableDictionary alloc] initWithDictionary: _dic[@"album"]];
    
    [album setObject: [NSNumber numberWithBool: YES] forKey: @"own"];
    [dictionary setObject: album forKey: @"album"];
    
    _dic = dictionary;
}

/*
- (void)collectAndDowloadBook {
    NSLog(@"collectAndDowloadBook");
    
    [alertViewForCollect close];
    
    //[wTools ShowMBProgressHUD];
    @try {
        [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString * Pointstr=[boxAPI geturpoints:[wTools getUserID] token:[wTools getUserToken]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //[wTools HideMBProgressHUD];
            @try {
                [MBProgressHUD hideHUDForView: self.view animated: YES];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                return;
            }
            
            
            NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[Pointstr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            
            if ([_dic[@"album"][@"point"] intValue]==0) {
                NSLog(@"收藏相本");
                
                //[self buyAlbum];
                
                // Avoid instance of avPlayer will be created again when viewWillAppear
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                BOOL fromCollectAndDownload = YES;
                [defaults setObject: [NSNumber numberWithBool: fromCollectAndDownload] forKey: @"fromCollectAndDownload"];
                [defaults synchronize];
                
                PreviewbookViewController *rv=[[PreviewbookViewController alloc]initWithNibName:@"PreviewbookViewController" bundle:nil];
                //PreviewbookViewController *rv = [[UIStoryboard storyboardWithName: @"Home" bundle:nil] instantiateViewControllerWithIdentifier: @"PreviewbookViewController"];
                rv.albumid=_albumid;
                rv.userbook=@"N";
                
                [self own];
                AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                [app.myNav pushViewController: rv animated: YES];
                //[self.navigationController pushViewController:rv animated:YES];
                
                // Check whether taskType is createAlbum or collectAlbum
                // Because, these two type will go to the same view controller - BookViewController
                //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                task_for = @"collect_free_album";
                [defaults setObject: task_for forKey: @"task_for"];
                [defaults synchronize];
                
            } else {
                //是否足夠
                if ([_dic[@"album"][@"point"] intValue]>[dic[@"data"] intValue]) {
                    //[self showCustomCollectAlertView: @"你的P點不足，前往購點?" option: @"buyPoint"];
                    [self showCustomCollectAlertView: @"你的P點不足，前往購點?" option: @"buyPoint" pointStr: @""];
                } else {
                    
                    NSString *msgStr = [NSString stringWithFormat: @"確定贊助%ldP?", (long)albumPoint];
                    //[self showCustomCollectAlertView: msgStr option: @"buyAlbum"];
                    [self showCustomCollectAlertView: msgStr option: @"buyAlbum" pointStr: [NSString stringWithFormat: @"%ld", (long)albumPoint]];
                    
                    [self retrieveAlbum];
                    [self own];
                }
            }
        });
    });
}
 */

#pragma mark -
- (void)checkFBSDK:(NSURL *)url
{
    NSLog(@"checkFBSDK");
    NSLog(@"url: %@", url);
    
    // Section Below is to check FBSDK
    
    //NSDictionary *parametersDic = [[NSDictionary alloc] initWithObjectsAndKeys: @"id,source", @"fields", nil];
    NSString *videoStr;
    
    NSCharacterSet *notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    
    for (NSString *str in [url pathComponents]) {
        //NSLog(@"str: %@", str);
        
        // Check which string section is all decimal
        if ([str rangeOfCharacterFromSet: notDigits].location == NSNotFound) {
            //NSLog(@"str: %@", str);
            
            videoStr = str;
        }
    }
    
    __block NSString *fbVideoLink;
    
    NSLog(@"fbVideoLink: %@", fbVideoLink);
    NSLog(@"Before getting token");
    
    if ([FBSDKAccessToken currentAccessToken]) {
        NSLog(@"");
        NSLog(@"FBSDKAccessToken currentAccessToken is TRUE");
        
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath: videoStr parameters: @{@"fields" : @"id,source"} HTTPMethod: @"GET"];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
         {
             if (connection) {
                 NSLog(@"");
                 NSLog(@"connection is TRUE");
                 //NSLog(@"result: %@", result);
                 
                 if (result != nil) {
                     NSLog(@"result is not nil");
                     
                     fbVideoLink = [result objectForKey: @"source"];
                     NSLog(@"fbVideoLink: %@", fbVideoLink);
                     
                     NSURL *videoURL = [NSURL URLWithString: fbVideoLink];
                     
                     AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL: videoURL];
                     AVPlayer *player = [AVPlayer playerWithPlayerItem: playerItem];
                     //AVPlayerViewController *playerViewController = [AVPlayerViewController new];
                     playerViewController = [AVPlayerViewController new];
                     playerViewController.player = player;
                     
                     // Adding Button on AVPlayerViewController
                     UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
                     [doneButton addTarget:self
                                    action:@selector(doneButtonPress:)
                          forControlEvents:UIControlEventTouchUpInside];
                     [doneButton setImage: [UIImage imageNamed: @"icon_close.png"] forState: UIControlStateNormal];
                     doneButton.frame = CGRectMake(5.0, 55.0, 30.0, 30.0);
                     
                     // Button will not show in iOS 11
                     //[playerViewController.view addSubview:button];
                     
                     [self addChildViewController: playerViewController];
                     
                     // Adding playerViewController.view to self.view
                     [self.view addSubview: playerViewController.view];
                     playerViewController.view.frame = self.view.frame;
                     
                     [self.view addSubview: doneButton];
                     [self.view bringSubviewToFront: doneButton];
                     
                     // Play video automatically when presenting AVPlayerViewController
                     [player play];
                     
                     //[self presentViewController: playerViewController animated: YES completion: nil];
                 } else if (result == nil) {
                     NSLog(@"result is nil");
                     NSLog(@"url: %@", url);
                     [self openSafari: url];
                     
                     //[[UIApplication sharedApplication] openURL: url];
                 }
             } else if (!connection) {
                 NSLog(@"Get Video Error");
             }
         }];
    } else {
        NSLog(@"");
        NSLog(@"FBSDKAccessToken currentAccessToken is not TRUE");
        NSLog(@"login with permissions");
        
        // Try to login with permissions
        [self loginAndRequestPermissionsWithSuccessHandler:^{
            NSLog(@"loginAndRequestPermissionsWithSuccessHandler");
            
            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath: videoStr parameters: @{@"fields" : @"id,source"} HTTPMethod: @"GET"];
            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if (connection) {
                    //NSLog(@"result: %@", result);
                    
                    if (result != nil) {
                        NSLog(@"result is not nil");
                        
                        fbVideoLink = [result objectForKey: @"source"];
                        NSLog(@"fbVideoLink: %@", fbVideoLink);
                        
                        NSURL *videoURL = [NSURL URLWithString: fbVideoLink];
                        
                        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL: videoURL];
                        AVPlayer *player = [AVPlayer playerWithPlayerItem: playerItem];
                        //AVPlayerViewController *playerViewController = [AVPlayerViewController new];
                        playerViewController = [AVPlayerViewController new];
                        playerViewController.player = player;
                        
                        // Adding Button on AVPlayerViewController
                        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
                        [doneButton addTarget:self
                                       action:@selector(doneButtonPress:)
                             forControlEvents:UIControlEventTouchUpInside];
                        [doneButton setImage: [UIImage imageNamed: @"icon_close.png"] forState: UIControlStateNormal];
                        doneButton.frame = CGRectMake(5.0, 25.0, 20.0, 20.0);
                        
                        // Button will not show in iOS 11
                        //[playerViewController.view addSubview:button];
                        
                        [self addChildViewController: playerViewController];
                        
                        // Adding playerViewController.view to self.view
                        [self.view addSubview: playerViewController.view];
                        playerViewController.view.frame = self.view.frame;
                        
                        [self.view addSubview: doneButton];
                        [self.view bringSubviewToFront: doneButton];
                        
                        // Adding playerViewController.view to self.view
                        [self.view addSubview: playerViewController.view];
                        playerViewController.view.frame = self.view.frame;
                        
                        // Play video automatically when presenting AVPlayerViewController
                        [player play];
                        
                        //[self presentViewController: playerViewController animated: YES completion: nil];
                    } else if (result == nil) {
                        NSLog(@"result is nil");
                        NSLog(@"url: %@", url);
                        [self openSafari: url];
                        
                        //[[UIApplication sharedApplication] openURL: url];
                    }
                } else if (!connection) {
                    NSLog(@"Get Video Error");
                }
            }];
        } declinedOrCanceledHandler:^{
            NSLog(@"declinedOrCanceledHandler");
            
            // If the user declined permissions tell them why we need permissions
            // and ask for permissions again if they want to grant permissions.
            [self alertDeclinedPublishActionsWithCompletion:^{
                [self loginAndRequestPermissionsWithSuccessHandler: nil
                                         declinedOrCanceledHandler: nil
                                                      errorHandler:^(NSError * error) {
                                                          NSLog(@"Error: %@", error.description);
                                                      }];
            }];
        } errorHandler:^(NSError * error) {
            NSLog(@"Error: %@", error.description);
        }];
    }
}

#pragma mark - FaceBook Handler Methods
- (void)loginAndRequestPermissionsWithSuccessHandler:(FBBlock) successHandler
                           declinedOrCanceledHandler:(FBBlock) declinedOrCanceledHandler
                                        errorHandler:(void (^)(NSError *)) errorHandler
{
    NSLog(@"loginAndRequestPermissionsWithSuccessHandler Method");
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions: @[@"user_videos"] fromViewController: self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        
        //NSLog(@"result: %@", result);
        
        if (result == nil) {
            NSLog(@"result is null");
        }
        
        if (error) {
            if (errorHandler) {
                errorHandler(error);
            }
            return;
        }
        
        if ([FBSDKAccessToken currentAccessToken]) {
            
            NSLog(@"FBSDKAccessToken currentAccessToken");
            
            if (successHandler) {
                NSLog(@"successHandler");
                successHandler();
            }
            return;
        }
        if (declinedOrCanceledHandler) {
            NSLog(@"declinedOrCanceledHandler");
            declinedOrCanceledHandler();
        }
    }];
}

- (void)alertDeclinedPublishActionsWithCompletion:(FBBlock)completion
{
    NSLog(@"alertDeclinedPublishActionsWithCompletion");
    /*
     UIAlertView *alertViewForFB = [[UIAlertView alloc] initWithTitle:@"Publish Permissions"
     message:@"Publish permissions are needed to share game content automatically. Do you want to enable publish permissions?"
     delegate:self
     cancelButtonTitle:@"No"
     otherButtonTitles:@"Ok", nil];
     [alertViewForFB show];
     */
}

#pragma mark - Open Safari
- (void)openSafari: (NSURL *)url
{
    NSLog(@"openSafari");
    NSLog(@"url: %@", url);
    safariVC = [[SFSafariViewController alloc] initWithURL: url entersReaderIfAvailable: NO];
    safariVC.preferredBarTintColor = [UIColor whiteColor];
    
    // Adding Button on AVPlayerViewController
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self
               action:@selector(doneButtonPress:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setImage: [UIImage imageNamed: @"icon_close.png"] forState: UIControlStateNormal];
    button.frame = CGRectMake(5.0, 25.0, 20.0, 20.0);
    [safariVC.view addSubview:button];
    
    // Adding playerViewController.view to self.view
    [self.view addSubview: safariVC.view];
    safariVC.view.frame = self.view.frame;
    
    //[self presentViewController: safariVC animated: YES completion: nil];
}

#pragma mark - Video Section

-(void)videoembed:(UIButton *)btn{
    NSLog(@"videoEmbed");
    
    //NSLog(@"datalist: %@", datalist);
    NSLog(@"btn.tag: %ld", (long)btn.tag);
    NSLog(@"datalist[btn.tag]: %@", datalist[btn.tag]);
    
    NSURL *url = [NSURL URLWithString: datalist[btn.tag][@"video_target"]];
    NSLog(@"url: %@", url);
    
    NSLog(@"scheme: %@", [url scheme]);
    NSLog(@"host: %@", [url host]);
    NSLog(@"port: %@", [url port]);
    NSLog(@"path: %@", [url path]);
    NSLog(@"path components: %@", [url pathComponents]);
    NSLog(@"parameterString: %@", [url parameterString]);
    NSLog(@"query: %@", [url query]);
    NSLog(@"fragment: %@", [url fragment]);
    
    if (!([[url host] rangeOfString: @"vimeo"].location == NSNotFound)) {
        NSLog(@"url contains vimeo");
        
        [[YTVimeoExtractor sharedExtractor] fetchVideoWithVimeoURL: datalist[btn.tag][@"video_target"] withReferer: nil completionHandler:^(YTVimeoVideo * _Nullable video, NSError * _Nullable error) {
            if (video) {
                // Get URL
                NSURL *highQualityURL = [video highestQualityStreamURL];
                
                // Setup playerItem
                AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL: highQualityURL];
                AVPlayer *player = [AVPlayer playerWithPlayerItem: playerItem];
                //AVPlayerViewController *playerViewController = [AVPlayerViewController new];
                playerViewController = [AVPlayerViewController new];
                playerViewController.player = player;
                
                // Adding Button on AVPlayerViewController
                UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [doneButton addTarget:self
                               action:@selector(doneButtonPress:)
                     forControlEvents:UIControlEventTouchUpInside];
                [doneButton setImage: [UIImage imageNamed: @"icon_close.png"] forState: UIControlStateNormal];
                doneButton.frame = CGRectMake(5.0, 55.0, 30.0, 30.0);
                [playerViewController.view addSubview: doneButton];
                
                [self addChildViewController: playerViewController];
                
                // Adding playerViewController.view to self.view
                [self.view addSubview: playerViewController.view];
                //playerViewController.view.frame = self.view.frame;
                
                [self.view addSubview: doneButton];
                [self.view bringSubviewToFront: doneButton];
                
                // Play video automatically when presenting AVPlayerViewController
                [player play];
                
                //[self presentViewController: playerViewController animated: YES completion: nil];
            }
        }];
    }
    
    if (!([[url host] rangeOfString: @"facebook"].location == NSNotFound)) {
        NSLog(@"url host contains facebook");
        [self checkFBSDK: url];
    }
    if (!([[url host] rangeOfString: @"youtube"].location == NSNotFound)) {
        NSLog(@"url host contains youtube");
        [self youtubeVideoSetup: datalist[btn.tag][@"video_target"]];
    }
    if (!([[url host] rangeOfString: @"youtu.be"].location == NSNotFound)) {
        [self youtubeVideoSetup: datalist[btn.tag][@"video_target"]];
    }
    
    shouldTurnOffAudio = YES;
    [self checkAudioWhenViewConrtrollerShowsUp];
}

- (void)youtubeVideoSetup: (NSString *)urlString
{
    NSLog(@"youtubeVideoSetup");
    NSLog(@"urlString: %@", urlString);
    
    //YoutubeViewController *yv = [[YoutubeViewController alloc] initWithNibName: @"YoutubeViewController" bundle: nil];
    yv = [[YoutubeViewController alloc] init];
    
    yv.url = urlString;
    //yv.url = urlString;
    yv.bookVC = self;
    
    NSLog(@"yv.url: %@", yv.url);
    
    // Adding Button on AVPlayerViewController
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton addTarget:self
                   action:@selector(doneButtonPress:)
         forControlEvents:UIControlEventTouchUpInside];
    [doneButton setImage: [UIImage imageNamed: @"icon_close.png"] forState: UIControlStateNormal];
    doneButton.frame = CGRectMake(5.0, 30.0, 30.0, 30.0); // set your own position
    [yv.view addSubview: doneButton];
    
    [self.view addSubview: yv.view];
    yv.view.frame = self.view.frame;
    
    NSLog(@"");
    NSLog(@"yv: %@", yv);
    NSLog(@"");
    
    //[self.view addSubview: doneButton];
    //[self.view bringSubviewToFront: doneButton];
    
    //[self presentViewController:yv animated:YES completion:nil];
}

-(void)videofile:(UIButton *)btn{
    NSLog(@"videoFile");
    
    NSURL *videoURL;
    
    // Get URL
    if (![_dic isKindOfClass: [NSNull class]]) {
        NSLog(@"dic is not kind of NSNull class");
        
        NSString *urlString = datalist[btn.tag][@"video_target"];
        NSLog(@"urlString: %@", urlString);
        videoURL = [NSURL URLWithString: urlString];
    } else {
        NSLog(@"dic is kind of NSNull class");
        NSString *urlString = [file stringByAppendingPathComponent:datalist[btn.tag][@"video_target"]];
        NSLog(@"urlString: %@", urlString);
        videoURL = [NSURL fileURLWithPath: urlString];
    }
    
    // Setup playerItem
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL: videoURL];
    AVPlayer *player = [AVPlayer playerWithPlayerItem: playerItem];
    playerViewController = [AVPlayerViewController new];
    playerViewController.player = player;
    
    // Adding Button on AVPlayerViewController
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton addTarget:self
                   action:@selector(doneButtonPress:)
         forControlEvents:UIControlEventTouchUpInside];
    [doneButton setImage: [UIImage imageNamed: @"icon_close.png"] forState: UIControlStateNormal];
    doneButton.frame = CGRectMake(5.0, 55.0, 30.0, 30.0);
    
    // Button will not show in iOS 11
    //[playerViewController.view addSubview:button];
    //[playerViewController.view addSubview: doneButton];
    //[playerViewController.view bringSubviewToFront: doneButton];
    
    [self addChildViewController: playerViewController];
    
    // Adding playerViewController.view to self.view
    [self.view addSubview: playerViewController.view];
    playerViewController.view.frame = self.view.frame;
    //[playerViewController didMoveToParentViewController: self];
    
    [self.view addSubview: doneButton];
    [self.view bringSubviewToFront: doneButton];
    
    // Play video automatically when presenting AVPlayerViewController
    [player play];
    
    /*
     //[self presentViewController: playerViewController animated: YES completion: nil];
     [self presentViewController: playerViewController animated: YES completion:^{
     NSLog(@"AVPlayerViewController is presented");
     }];
     */
    
    // The music is playing
    // At the beginning, audioSwitch is On, after pressing will be set to NO;
    if (_audioSwitch) {
        NSLog(@"_audioSwitch is ON");
        _videoPlay = YES;
        
        [self playCheck: nil];
    }
    
    shouldTurnOffAudio = YES;
    [self checkAudioWhenViewConrtrollerShowsUp];
}

- (void)doneButtonPress:(UIButton *)button {
    NSLog(@"\n\ndoneButtonPress\n\n");
    NSLog(@"Remove Video Player");
    
    // Back to TestReadBookVC, so that means videoPlay is finished
    if (_videoPlay) {
        _videoPlay = NO;
    }
    
    // The music is playing
    // At the beginning, audioSwitch is On, after pressing will be set to NO;
    if (_audioSwitch) {
        NSLog(@"_audioSwitch is ON");
        //_videoPlay = YES;
        
        [self playCheck: audioStr];
    }
    
    NSLog(@"\n\nCheck which view need to be removed");
    NSLog(@"\n\n\n");
    NSLog(@"playerViewController: %@", playerViewController);
    NSLog(@"yv: %@", yv);
    NSLog(@"safariVC: %@", safariVC);
    NSLog(@"\n\n\n");
    
    // Remove playerViewController.view
    if (playerViewController) {
        NSLog(@"playerViewController exits");
        
        playerViewController.player = nil;
        [playerViewController.view removeFromSuperview];
        playerViewController = nil;
        [button removeFromSuperview];
    } else if (yv) {
        NSLog(@"yv exists");
        [yv.view removeFromSuperview];
        yv = nil;
        [button removeFromSuperview];
    } else if (safariVC) {
        NSLog(@"safariVC exists");
        [safariVC.view removeFromSuperview];
        [button removeFromSuperview];
    }
    
    shouldTurnOffAudio = NO;
    [self checkAudioWhenViewConrtrollerShowsUp];
}

#pragma mark - Gift Related Methods

//拉霸
-(void)showSlot:(UIButton *)slotBtn {
    NSLog(@"show slot");
    slotBtn.hidden = YES;
    
    NSMutableArray *array = [NSMutableArray new];
    
    for (int i = 1; i < 13; i++) {
        UIImage *image = [UIImage imageNamed: [NSString stringWithFormat: @"GiftImages%i.png", i]];
        [array addObject: image];
    }
    
    UIImageView *animateImageView;
    animateImageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 180, 200)];
    animateImageView.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
    animateImageView.contentMode = UIViewContentModeScaleAspectFill;
    animateImageView.animationImages = array;
    animateImageView.animationDuration = 1.5;
    animateImageView.animationRepeatCount = 1;
    
    [slotBtn.superview addSubview: animateImageView];
    [animateImageView startAnimating];
    
    while ([animateImageView isAnimating]) {
        [[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
    }
    [animateImageView removeFromSuperview];
    
    [self slotPhotoUseFor: slotBtn.superview];
}

- (void)slotPhotoUseFor:(UIView *)bgV {
    NSLog(@"self.mySV.subviews: %@", self.mySV.subviews);
    NSLog(@"slotPhotoUseFor");
    int page = self.mySV.contentOffset.x / self.mySV.frame.size.width;
    NSLog(@"page: %d", page);
    
    NSInteger photoId = [datalist[page][@"photo_id"] integerValue];
    NSLog(@"photoId: %ld", (long)photoId);
    NSString *photoIdStr = [datalist[page][@"photo_id"] stringValue];
    
    UIDevice *device = [UIDevice currentDevice];
    NSString *currentDeviceId = [[device identifierForVendor] UUIDString];
    
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI slotPhotoUseFor: currentDeviceId
                                             photoId: photoIdStr
                                               token: [wTools getUserToken]
                                              userId: [wTools getUserID]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"response from slotPhotoUseFor");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"TestReadBookViewController");
                    NSLog(@"slotPhotoUseFor");
                    
                    //                    [self createTimeOutView: slotBtn];
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"slotPhotoUseFor"
                                        pointStr: @""
                                             btn: nil
                                             bgV: nil];
                } else {
                    NSLog(@"Get Real Response");
                    NSLog(@"Get response from slotPhotoUseFor");
                    
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    NSLog(@"dic: %@", dic);
                    NSLog(@"dic message: %@", dic[@"message"]);
                    
                    if ([dic[@"result"] isEqualToString: @"SYSTEM_OK"]) {
                        [self saveSlotData: photoId];
                        [self checkSlotDataInDatabaseOrNot];
                        
                        self.slotDicData = dic[@"data"];
                        [self createGiftView: bgV
                                     dicData: self.slotDicData
                                  returnType: @"SYSTEM_OK"];
                        
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
                        
                    } else if ([dic[@"result"] isEqualToString: @"PHOTOUSEFOR_HAS_EXPIRED"]) {
                        [self saveSlotData: photoId];
                        [self checkSlotDataInDatabaseOrNot];
                        
                        [self createViewForStatus: bgV msg: @"兌換已結束"];
                    } else if ([dic[@"result"] isEqualToString: @"PHOTOUSEFOR_HAS_SENT_FINISHED"]) {
                        [self saveSlotData: photoId];
                        [self checkSlotDataInDatabaseOrNot];
                        
                        [self createViewForStatus: bgV msg: @"兌換已結束"];
                    } else if ([dic[@"result"] isEqualToString: @"PHOTOUSEFOR_USER_HAS_EXCHANGED"]) {
                        [self saveSlotData: photoId];
                        [self checkSlotDataInDatabaseOrNot];
                        
                        self.slotDicData = dic[@"data"];
                        [self createGiftView: bgV
                                     dicData: self.slotDicData
                                  returnType: @"PHOTOUSEFOR_USER_HAS_EXCHANGED"];
                        
                    } else if ([dic[@"result"] isEqualToString: @"PHOTOUSEFOR_USER_HAS_GAINED"]) {
                        [self saveSlotData: photoId];
                        [self checkSlotDataInDatabaseOrNot];
                        
                        self.slotDicData = dic[@"data"];
                        [self createGiftView: bgV
                                     dicData: self.slotDicData
                                  returnType: @"PHOTOUSEFOR_USER_HAS_GAINED"];
                    } else if ([dic[@"result"] isEqualToString: @"PHOTOUSEFOR_USER_HAS_SLOTTED"]) {
                        [self saveSlotData: photoId];
                        [self checkSlotDataInDatabaseOrNot];
                        
                        self.slotDicData = dic[@"data"];
                        [self createGiftView: bgV
                                     dicData: self.slotDicData
                                  returnType: @"PHOTOUSEFOR_USER_HAS_SLOTTED"];
                    } else if ([dic[@"result"] isEqualToString: @"PHOTOUSEFOR_NOT_YET_STARTED"]) {
                        for (UIView *view in bgV.subviews) {
                            NSLog(@"view.accessibilityIdentifier: %@", view.accessibilityIdentifier);
                            
                            if ([view.accessibilityIdentifier isEqualToString: @"SlotBtn"]) {
                                if ([view isKindOfClass: [UIButton class]]) {
                                    UIButton *btn = (UIButton *)view;
                                    btn.hidden = NO;
                                }
                            }
                        }
                        
                        // The Toast method below will call scrollViewScroll delegate method 
                        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                        style.messageColor = [UIColor whiteColor];
                        style.backgroundColor = [UIColor hintGrey];
                        
                        NSLog(@"self.view.subviews: %@", self.view.subviews);
                        
                        // Use self.view.superview to present toast will not call scrollViewDidScroll
                        [self.view.superview makeToast: @"活動尚未開始"
                                              duration: 2.0
                                              position: CSToastPositionBottom
                                                 style: style];
                    }
                }
            }
        });
    });
}

- (void)getPhotoUseFor:(UIView *)bgV {
    //    NSLog(@"self.mySV.subviews: %@", self.mySV.subviews);
    NSLog(@"getPhotoUseFor");
    int page = self.mySV.contentOffset.x / self.mySV.frame.size.width;
    NSLog(@"page: %d", page);
    
    NSInteger photoId = [datalist[page][@"photo_id"] integerValue];
    NSLog(@"photoId: %ld", (long)photoId);
    NSString *photoIdStr = [datalist[page][@"photo_id"] stringValue];
    
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI getPhotoUseFor: photoIdStr
                                              token: [wTools getUserToken]
                                             userId: [wTools getUserID]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"response from slotPhotoUseFor");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"TestReadBookViewController");
                    NSLog(@"slotPhotoUseFor");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getPhotoUseFor"
                                        pointStr: @""
                                             btn: nil
                                             bgV: nil];
                } else {
                    NSLog(@"Get Real Response");
                    NSLog(@"Get response from getPhotoUseFor");
                    
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    NSLog(@"dic: %@", dic);
                    NSLog(@"dic message: %@", dic[@"message"]);
                    
                    if ([dic[@"result"] isEqualToString: @"SYSTEM_OK"]) {
                        self.slotDicData = dic[@"data"];
                        [self createGiftView: bgV
                                     dicData: self.slotDicData
                                  returnType: @"SYSTEM_OK"];
                        
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
                        
                    } else if ([dic[@"result"] isEqualToString: @"PHOTOUSEFOR_HAS_EXPIRED"]) {
                        [self createViewForStatus: bgV msg: @"兌換已結束"];
                    } else if ([dic[@"result"] isEqualToString: @"PHOTOUSEFOR_HAS_SENT_FINISHED"]) {
                        [self createViewForStatus: bgV msg: @"兌換已結束"];
                    } else if ([dic[@"result"] isEqualToString: @"PHOTOUSEFOR_USER_HAS_EXCHANGED"]) {
                        self.slotDicData = dic[@"data"];
                        [self createGiftView: bgV
                                     dicData: self.slotDicData
                                  returnType: @"PHOTOUSEFOR_USER_HAS_EXCHANGED"];
                        
                    } else if ([dic[@"result"] isEqualToString: @"PHOTOUSEFOR_USER_HAS_GAINED"]) {
                        [self checkSlotDataInDatabaseOrNot];
                        
                        self.slotDicData = dic[@"data"];
                        [self createGiftView: bgV
                                     dicData: self.slotDicData
                                  returnType: @"PHOTOUSEFOR_USER_HAS_GAINED"];
                    } else if ([dic[@"result"] isEqualToString: @"PHOTOUSEFOR_USER_HAS_SLOTTED"]) {
                        self.slotDicData = dic[@"data"];
                        [self createGiftView: bgV
                                     dicData: self.slotDicData
                                  returnType: @"PHOTOUSEFOR_USER_HAS_SLOTTED"];
                    } else if ([dic[@"result"] isEqualToString: @"PHOTOUSEFOR_NOT_YET_STARTED"]) {
                        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                        style.messageColor = [UIColor whiteColor];
                        style.backgroundColor = [UIColor hintGrey];
                        
                        // Use self.view.superview to present toast will not call scrollViewDidScroll
                        [self.view.superview makeToast: @"活動尚未開始"
                                              duration: 2.0
                                              position: CSToastPositionBottom
                                                 style: style];
                    }
                }
            }
        });
    });
}

- (void)createViewForStatus:(UIView *)v
                        msg:(NSString *)msg {
    NSLog(@"createViewForOtherStatus");
    NSLog(@"v.subviews: %@", v.subviews);
    
    for (UIView *view in v.subviews) {
        NSLog(@"view: %@", view);
        NSLog(@"view.accessibilityIdentifier: %@", view.accessibilityIdentifier);
        
        if ([view.accessibilityIdentifier isEqualToString: @"statusLayout"]) {
            [view removeFromSuperview];
        }
        
        if ([view.accessibilityIdentifier isEqualToString: @"SlotBtn"]) {
            if ([view isKindOfClass: [UIButton class]]) {
                UIButton *btn = (UIButton *)view;
                btn.hidden = YES;
            }
        }
    }
    
    MyFrameLayout *statusLayout = [MyFrameLayout new];
    statusLayout.mySize = CGSizeMake(v.frame.size.width - 100, 70);
    statusLayout.myCenterOffset = CGPointZero;
    statusLayout.accessibilityIdentifier = @"statusLayout";
    statusLayout.backgroundColor = [UIColor whiteColor];
    statusLayout.layer.cornerRadius = kCornerRadius;
    [v addSubview: statusLayout];
    
    // Name Label
    UILabel *infoLabel = [UILabel new];
    infoLabel.wrapContentHeight = YES;
    infoLabel.myCenterOffset = CGPointZero;
    infoLabel.numberOfLines = 0;
    infoLabel.font = [UIFont boldSystemFontOfSize: 18.0];
    infoLabel.text = msg;
    [LabelAttributeStyle changeGapString: infoLabel content: infoLabel.text];
    infoLabel.textColor = [UIColor firstGrey];
    [infoLabel sizeToFit];
    
    [statusLayout addSubview: infoLabel];
}

- (void)createGiftView:(UIView *)v
               dicData:(NSDictionary *)dicData
            returnType:(NSString *)returnType
{
    NSLog(@"createGiftView");
    NSLog(@"dicData: %@", dicData);
    NSLog(@"returnType: %@", returnType);
    
    for (UIView *view in v.subviews) {
        NSLog(@"view.accessibilityIdentifier: %@", view.accessibilityIdentifier);
        
        if ([view.accessibilityIdentifier isEqualToString: @"giftBgV"]) {
            [view removeFromSuperview];
        }
        
        if ([view.accessibilityIdentifier isEqualToString: @"SlotBtn"]) {
            if ([view isKindOfClass: [UIButton class]]) {
                UIButton *btn = (UIButton *)view;
                btn.hidden = YES;
            }
        }
    }
    
    CGFloat height = [self checkDeviceForGiftViewHeight: v.frame.size.height];
    NSLog(@"height: %f", height);
    
    // giftBgV
    MyLinearLayout *giftBgV = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Vert];
//    giftBgV.mySize = CGSizeMake(v.frame.size.width - 64, 380);
    giftBgV.mySize = CGSizeMake(v.frame.size.width - 64, height);
    giftBgV.myCenterXOffset = 0;
//    giftBgV.myCenterYOffset = -64;
    giftBgV.myCenterYOffset = -32;
    giftBgV.accessibilityIdentifier = @"giftBgV";
    [v addSubview: giftBgV];
    
    giftBgV.hidden = YES;
    
    // giftView
    MyFrameLayout *giftView = [MyFrameLayout new];
    giftView.backgroundColor = [UIColor whiteColor];
//    giftView.mySize = CGSizeMake(giftBgV.myWidth, giftBgV.myHeight);
    giftView.mySize = CGSizeMake(giftBgV.myWidth, giftBgV.myHeight - 54);
    NSLog(@"giftView.myHeight: %f", giftView.myHeight);
    giftView.myTopMargin = 0;
    giftView.myLeftMargin = giftView.myRightMargin = 0;
    giftView.myBottomMargin = 8;
    giftView.layer.cornerRadius = kCornerRadius;
    giftView.accessibilityIdentifier = @"giftView";
    [giftBgV addSubview: giftView];
    
    // ScrollView
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame: giftView.bounds];
    scrollView.myTopMargin = scrollView.myBottomMargin = 0;
    scrollView.myLeftMargin = scrollView.myRightMargin = 0;
    scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 51.0, 0.0);
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.delegate = self;
    scrollView.accessibilityIdentifier = @"GiftScrollView";
    [giftView addSubview: scrollView];
    
    // ContentLayout
    MyLinearLayout *contentLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Vert];
    contentLayout.wrapContentHeight = YES;
    contentLayout.myTopMargin = 0;
    contentLayout.myLeftMargin = contentLayout.myRightMargin = 0;
    [scrollView addSubview: contentLayout];
    
    // Name Label
    if (![dicData[@"photousefor"][@"name"] isEqual: [NSNull null]]) {
        UILabel *nameLabel = [UILabel new];
        nameLabel.wrapContentHeight = YES;
        nameLabel.myTopMargin = 16;
        nameLabel.myLeftMargin = nameLabel.myRightMargin = 16;
        nameLabel.myBottomMargin = 8;
        nameLabel.numberOfLines = 0;
        nameLabel.font = [UIFont boldSystemFontOfSize: 18.0];
        nameLabel.text = dicData[@"photousefor"][@"name"];
        [LabelAttributeStyle changeGapString: nameLabel content: nameLabel.text];
        nameLabel.textColor = [UIColor firstGrey];
        [nameLabel sizeToFit];
        [contentLayout addSubview: nameLabel];
    }
    
    // ImageView
    if (![dicData[@"photousefor"][@"image"] isEqual: [NSNull null]]) {
        __block UIImageView *imageView = [[UIImageView alloc] init];
        //        [imageView sd_setImageWithURL: [NSURL URLWithString: dicData[@"photousefor"][@"image"]]
        //                     placeholderImage: [UIImage imageNamed: @"bg200_no_image.jpg"]];
        
        [imageView sd_setImageWithURL: [NSURL URLWithString: dicData[@"photousefor"][@"image"]] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            imageView = [self calculateImageViewSize: giftBgV imgV: imageView];
            //            imageView.mySize = CGSizeMake(100.0, 100.0);
            imageView.myTopMargin = imageView.myBottomMargin = 8;
            imageView.myLeftMargin = imageView.myRightMargin = 16;
            imageView.layer.cornerRadius = kCornerRadius;
            imageView.layer.masksToBounds = YES;
            NSLog(@"imageView.mySize: %@", NSStringFromCGSize(imageView.mySize));
            
            self.giftImageView = imageView;
            
            NSLog(@"imageView.mySize: %@", NSStringFromCGSize(imageView.mySize));
            [contentLayout addSubview: imageView];
            
            giftBgV.hidden = NO;
            
            // Description Label
            if (![dicData[@"photousefor"][@"description"] isEqual: [NSNull null]]) {
                UILabel *descriptionLabel = [UILabel new];
                descriptionLabel.wrapContentHeight = YES;
                descriptionLabel.myTopMargin = descriptionLabel.myBottomMargin = 8;
                descriptionLabel.myLeftMargin = descriptionLabel.myRightMargin = 16;
                descriptionLabel.numberOfLines = 0;
                descriptionLabel.font = [UIFont systemFontOfSize: 14.0];
                descriptionLabel.text = dicData[@"photousefor"][@"description"];
                [LabelAttributeStyle changeGapString: descriptionLabel content: descriptionLabel.text];
                descriptionLabel.textColor = [UIColor firstGrey];
                [descriptionLabel sizeToFit];
                [contentLayout addSubview: descriptionLabel];
            }
        }];
    } else {
        // Description Label
        if (![dicData[@"photousefor"][@"description"] isEqual: [NSNull null]]) {
            UILabel *descriptionLabel = [UILabel new];
            descriptionLabel.wrapContentHeight = YES;
            descriptionLabel.myTopMargin = descriptionLabel.myBottomMargin = 8;
            descriptionLabel.myLeftMargin = descriptionLabel.myRightMargin = 16;
            descriptionLabel.numberOfLines = 0;
            descriptionLabel.font = [UIFont systemFontOfSize: 14.0];
            descriptionLabel.text = dicData[@"photousefor"][@"description"];
            [LabelAttributeStyle changeGapString: descriptionLabel content: descriptionLabel.text];
            descriptionLabel.textColor = [UIColor firstGrey];
            [descriptionLabel sizeToFit];
            [contentLayout addSubview: descriptionLabel];
        }
    }
    
    // Add to Exchange List
    UIButton *addToExchangeListBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    [addToExchangeListBtn addTarget: self
                             action: @selector(addToExchangeListBtnTouchDown:)
                   forControlEvents: UIControlEventTouchDown];
    [addToExchangeListBtn addTarget: self
                             action: @selector(addToExchangeListBtnTouchUpInside:)
                   forControlEvents: UIControlEventTouchUpInside];
    [addToExchangeListBtn addTarget: self
                             action: @selector(addToExchangeListBtnTouchDragExit:)
                   forControlEvents: UIControlEventTouchDragExit];
    addToExchangeListBtn.mySize = CGSizeMake(32.0, 46.0);
    addToExchangeListBtn.myLeftMargin = addToExchangeListBtn.myRightMargin = 0;
    addToExchangeListBtn.myBottomMargin = 0;
    
    if ([dicData[@"bookmark"][@"is_existing"] boolValue]) {
        [addToExchangeListBtn setTitle: @"已加入兌換清單" forState: UIControlStateNormal];
        [addToExchangeListBtn setTitleColor: [UIColor secondGrey] forState: UIControlStateNormal];
        addToExchangeListBtn.userInteractionEnabled = NO;
        addToExchangeListBtn.adjustsImageWhenHighlighted = NO;
    } else {
        [addToExchangeListBtn setTitle: @"加入兌換清單" forState: UIControlStateNormal];
        [addToExchangeListBtn setTitleColor: [UIColor firstGrey] forState: UIControlStateNormal];
        addToExchangeListBtn.userInteractionEnabled = YES;
        addToExchangeListBtn.userInteractionEnabled = YES;
        addToExchangeListBtn.adjustsImageWhenHighlighted = YES;
    }
    addToExchangeListBtn.titleLabel.font = [UIFont boldSystemFontOfSize: 16.0];
    addToExchangeListBtn.backgroundColor = [UIColor whiteColor];
    addToExchangeListBtn.layer.cornerRadius = kCornerRadius;
    addToExchangeListBtn.accessibilityIdentifier = @"addToExchangeListBtn";
    [giftView addSubview: addToExchangeListBtn];
    
    if ([returnType isEqualToString: @"PHOTOUSEFOR_USER_HAS_GAINED"] || [dicData[@"photousefor"][@"useless_award"] boolValue]) {
        addToExchangeListBtn.hidden = YES;
    }
    
    // exchangeBtn
    UIButton *exchangeBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    [exchangeBtn addTarget: self
                    action: @selector(exchangeBtnTouchDown:)
          forControlEvents: UIControlEventTouchDown];
    [exchangeBtn addTarget: self
                    action: @selector(exchangeBtnTouchUpInside:)
          forControlEvents: UIControlEventTouchUpInside];
    [exchangeBtn addTarget: self
                    action: @selector(exchangeBtnTouchUpDragExit:)
          forControlEvents: UIControlEventTouchDragExit];
    exchangeBtn.frame = CGRectMake(0.0, 0.0, 32.0, 46.0);
    exchangeBtn.myTopMargin = 8;
    exchangeBtn.myLeftMargin = exchangeBtn.myRightMargin = 0;
    exchangeBtn.myBottomMargin = 0;
    exchangeBtn.layer.cornerRadius = kCornerRadius;
    exchangeBtn.titleLabel.font = [UIFont systemFontOfSize: 18.0];
    exchangeBtn.accessibilityIdentifier = @"exchangeBtn";
    
    if ([returnType isEqualToString: @"PHOTOUSEFOR_USER_HAS_GAINED"]) {
        [exchangeBtn setTitle: @"已完成" forState: UIControlStateNormal];
        [exchangeBtn setTitleColor: [UIColor secondGrey] forState: UIControlStateNormal];
        exchangeBtn.backgroundColor = [UIColor whiteColor];
        exchangeBtn.userInteractionEnabled = NO;
        exchangeBtn.adjustsImageWhenHighlighted = NO;
    } else {
        [exchangeBtn setTitle: @"立即兌換" forState: UIControlStateNormal];
        [exchangeBtn setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
        exchangeBtn.backgroundColor = [UIColor firstMain];
    }
    
    if ([dicData[@"photousefor"][@"useless_award"] boolValue]) {
        exchangeBtn.hidden = YES;
    }
    
    [giftBgV addSubview: exchangeBtn];
}

- (UIImageView *)calculateImageViewSize:(UIView *)bV
                                   imgV:(UIImageView *)imgV {
    NSLog(@"calculateImageViewSize");
    CGFloat bgVWidth = bV.bounds.size.width;
    NSLog(@"bgVWidth: %f", bgVWidth);
    
    CGFloat imgVWidth = bgVWidth - 16 * 2;
    NSLog(@"imgVWidth: %f", imgVWidth);
    
    CGFloat imgVHeight = (imgVWidth * imgV.image.size.height) / imgV.image.size.width;
    NSLog(@"imgVHeight: %f", imgVHeight);
    
    imgV.myWidth = imgVWidth;
    imgV.myHeight = imgVHeight;
    
    return imgV;
}

- (CGFloat)checkDeviceForGiftViewHeight:(CGFloat)screenViewHeight
{
    CGFloat x = 230;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                screenViewHeight -= x;
                break;
            case 1334:
                printf("iPhone 6/6S/7/8");
                screenViewHeight -= x;
                break;
            case 1920:
                printf("iPhone 6+/6S+/7+/8+");
                screenViewHeight -= x;
                break;
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                screenViewHeight -= x;
                break;
            case 2436:
                printf("iPhone X");
                screenViewHeight -= x + 40;
                break;
            default:
                printf("unknown");
                screenViewHeight -= x;
                break;
        }
    }
    return screenViewHeight;
}

//#pragma mark - createTimeOutView
//- (void)createTimeOutView:(UIButton *)slotBtn {
//    NSLog(@"createTimeOutView");
//    UIView *v = slotBtn.superview;
//    NSLog(@"v.subviews: %@", v.subviews);
//
//    for (UIView *view in v.subviews) {
//        NSLog(@"view: %@",view);
//        NSLog(@"view.accessibilityIdentifier: %@", view.accessibilityIdentifier);
//
//        if ([view.accessibilityIdentifier isEqualToString: @"timeOutLayout"]) {
//            NSLog(@"timeout view already exists");
//        } else {
//
//        }
//    }
//
//    MyLinearLayout *timeOutLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Vert];
//    timeOutLayout.wrapContentHeight = YES;
//    timeOutLayout.myCenterXOffset = 0;
//    timeOutLayout.myCenterYOffset = 0;
//    timeOutLayout.backgroundColor = [UIColor whiteColor];
//    timeOutLayout.padding = UIEdgeInsetsMake(16, 16, 16, 16);
//    timeOutLayout.myWidth = [UIScreen mainScreen].bounds.size.width - 100;
//    timeOutLayout.myHeight = 150.0;
//    timeOutLayout.layer.cornerRadius = 16;
//    timeOutLayout.accessibilityIdentifier = @"timeOutLayout";
//    [v addSubview: timeOutLayout];
//
//    UILabel *topicLabel = [UILabel new];
//    topicLabel.wrapContentHeight = YES;
//    topicLabel.myTopMargin = 0;
//    topicLabel.myLeftMargin = topicLabel.myRightMargin = 0;
//    topicLabel.myBottomMargin = 8;
//    topicLabel.text = @"目前網路不穩定，請確認品質再繼續使用pinpinbox!";
//    [LabelAttributeStyle changeGapString: topicLabel content: topicLabel.text];
//    topicLabel.textColor = [UIColor firstGrey];
//    topicLabel.font = [UIFont systemFontOfSize: 20.0];
//    topicLabel.numberOfLines = 0;
//    [topicLabel sizeToFit];
//    [timeOutLayout addSubview: topicLabel];
//
//    UIButton *reconnectBtn = [UIButton buttonWithType: UIButtonTypeCustom];
//    [reconnectBtn addTarget: self action: @selector(reConnect:) forControlEvents: UIControlEventTouchUpInside];
//    reconnectBtn.frame = CGRectMake(0.0, 0.0, 112.0, 48.0);
//    reconnectBtn.myTopMargin = 8;
//    reconnectBtn.myCenterXOffset = 0;
//    reconnectBtn.backgroundColor = [UIColor firstMain];
//    reconnectBtn.layer.cornerRadius = 6;
//
//    [reconnectBtn setTitle: @"再試一次" forState: UIControlStateNormal];
//    [timeOutLayout addSubview: reconnectBtn];
//
//    for (UIView *view in v.subviews) {
//        NSLog(@"view: %@",view);
//        NSLog(@"view.accessibilityIdentifier: %@", view.accessibilityIdentifier);
//
//        if ([view.accessibilityIdentifier isEqualToString: @"timeOutLayout"]) {
//            NSLog(@"timeout view already exists");
//        } else {
//
//        }
//    }
//
//    NSLog(@"reconnectBtn.superview: %@", reconnectBtn.superview);
//
//    for (UIView *view in reconnectBtn.superview.subviews) {
//        NSLog(@"view: %@", view);
//        NSLog(@"view.accessibilityIdentifier: %@", view.accessibilityIdentifier);
//    }
//}
//
//- (void)reConnect:(UIButton *)reConnectBtn {
//    NSLog(@"reConnect");
//    NSLog(@"reConnectBtn.superview.accessibilityIdentifier: %@", reConnectBtn.superview.accessibilityIdentifier);
//
//    if ([reConnectBtn.superview.accessibilityIdentifier isEqualToString: @"timeOutLayout"]) {
//        [reConnectBtn.superview removeFromSuperview];
//    }
//
//    [self slotPhotoUseFor: reConnectBtn];
//}

#pragma mark - AddToExchangeListBtn Action Methods
- (void)addToExchangeListBtnTouchDown:(UIButton *)btn {
    NSLog(@"addToExchangeListBtnTouchDown");
    btn.backgroundColor = [UIColor thirdMain];
}

- (void)addToExchangeListBtnTouchUpInside:(UIButton *)btn {
    NSLog(@"addToExchangeListBtnTouchUpInside");
    btn.backgroundColor = [UIColor whiteColor];
    
    [self insertBookmark: btn];
}

- (void)addToExchangeListBtnTouchDragExit:(UIButton *)btn {
    NSLog(@"addToExchangeListBtnTouchDragExit");
    btn.backgroundColor = [UIColor whiteColor];
}

#pragma mark - ExchangeBtn Action Methods
- (void)exchangeBtnTouchDown:(UIButton *)btn {
    NSLog(@"exchangeBtnTouchDown");
    btn.backgroundColor = [UIColor darkMain];
}

- (void)exchangeBtnTouchUpInside:(UIButton *)btn {
    NSLog(@"exchangeBtnTouchUpInside");
    btn.backgroundColor = [UIColor firstMain];
    
    int page = self.mySV.contentOffset.x / self.mySV.frame.size.width;
    NSLog(@"page: %d", page);
    
    NSInteger photoId = [datalist[page][@"photo_id"] integerValue];
    NSLog(@"photoId: %ld", (long)photoId);
    
    ExchangeInfoEditViewController *exchangeInfoEditVC = [[ExchangeInfoEditViewController alloc] init];
    exchangeInfoEditVC.exchangeDic = [self.slotDicData mutableCopy];
    exchangeInfoEditVC.hasExchanged = NO;
    exchangeInfoEditVC.isExisting = [self.slotDicData[@"bookmark"][@"is_existing"] boolValue];
    exchangeInfoEditVC.backgroundView = btn.superview;
    exchangeInfoEditVC.photoId = photoId;
    exchangeInfoEditVC.delegate = self;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.myNav pushViewController: exchangeInfoEditVC animated: YES];
}

- (void)exchangeBtnTouchUpDragExit:(UIButton *)btn {
    NSLog(@"exchangeBtnTouchUpDragExit");
    btn.backgroundColor = [UIColor firstMain];
}

#pragma mark - ExchangeInfoEditViewControllerDelegate Methods
- (void)finishExchange:(NSMutableDictionary *)exchangeDic
                   bgV:(UIView *)bgV {
    NSLog(@"");
    NSLog(@"finishExchange");
    NSLog(@"bgV.subviews: %@", bgV.subviews);
    NSLog(@"bgV.accessibilityIdentifier: %@", bgV.accessibilityIdentifier);
    
    for (UIView *view1 in bgV.subviews) {
        NSLog(@"view1.accessibilityIdentifier: %@", view1.accessibilityIdentifier);
        
        if ([view1.accessibilityIdentifier isEqualToString: @"giftView"]) {
            for (UIView *view2 in view1.subviews) {
                NSLog(@"view2.accessibilityIdentifier: %@", view2.accessibilityIdentifier);
                
                if ([view2.accessibilityIdentifier isEqualToString: @"addToExchangeListBtn"]) {
                    if ([view2 isKindOfClass: [UIButton class]]) {
                        UIButton *btn = (UIButton *)view2;
                        btn.hidden = YES;
                    }
                }
            }
        }
        
        if ([view1.accessibilityIdentifier isEqualToString: @"exchangeBtn"]) {
            NSLog(@"view1.accessibilityIdentifier isEqualToString exchangeBtn");
            if ([view1 isKindOfClass: [UIButton class]]) {
                NSLog(@"view1 isKindOfClass UIButton class");
                UIButton *btn = (UIButton *)view1;
                NSLog(@"Before change");
                NSLog(@"btn.titleLabel.text: %@", btn.titleLabel.text);
                
                [btn setTitle: @"已完成" forState: UIControlStateNormal];                
                
                NSLog(@"After change");
                NSLog(@"btn.titleLabel.text: %@", btn.titleLabel.text);
                [btn setTitleColor: [UIColor secondGrey] forState: UIControlStateNormal];
                btn.backgroundColor = [UIColor whiteColor];
                btn.userInteractionEnabled = NO;
                btn.adjustsImageWhenHighlighted = NO;
            }
        }
    }
}

- (void)insertBookmark:(UIButton *)btn {
    NSLog(@"insertBookmark");
    
    //    [wTools ShowMBProgressHUD];
    
    int page = self.mySV.contentOffset.x / self.mySV.frame.size.width;
    NSLog(@"page: %d", page);
    
    NSString *photoIdStr = [datalist[page][@"photo_id"] stringValue];
    NSLog(@"photoIdStr: %@", photoIdStr);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [boxAPI insertBookmark: photoIdStr
                                              token: [wTools getUserToken]
                                             userId: [wTools getUserID]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"response from insertBookmark");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ExchangeInfoEditViewController");
                    NSLog(@"insertBookmark");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"insertBookmark"
                                        pointStr: @""
                                             btn: btn
                                             bgV: nil];
                } else {
                    NSLog(@"Get Real Response");
                    NSLog(@"Get response from insertBookmark");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] isEqualToString: @"SYSTEM_OK"]) {
                        NSLog(@"SYSTEM_OK");
                        NSLog(@"dic: %@", dic);
                        
                        [self.slotDicData[@"bookmark"] setObject: [NSNumber numberWithBool: YES] forKey: @"is_existing"];
                        NSLog(@"self.slotDicData: %@", self.slotDicData);
                        
                        [btn setTitle: @"已加入兌換清單" forState: UIControlStateNormal];
                        [btn setTitleColor: [UIColor secondGrey] forState: UIControlStateNormal];
                        btn.userInteractionEnabled = NO;
                        btn.adjustsImageWhenHighlighted = NO;
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

#pragma mark - UINavigationControllerDelegate Methods
- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC {
    // Sanity
    if (fromVC != self && toVC != self) return nil;
    
    // Determine if we're presenting or dismissing
    ZOTransitionType type = (fromVC == self) ? ZOTransitionTypePresenting : ZOTransitionTypeDismissing;
    
    // Create a transition instance with the selected cell's imageView as the target view
    ZOZolaZoomTransition *zoomTransition = [ZOZolaZoomTransition transitionFromView:self.giftImageView
                                                                               type:type
                                                                           duration:0.5
                                                                           delegate:self];
    zoomTransition.fadeColor = self.collectionView.backgroundColor;
    
    return zoomTransition;
}

#pragma mark - ZOZolaZoomTransitionDelegate Methods
- (CGRect)zolaZoomTransition:(ZOZolaZoomTransition *)zoomTransition
        startingFrameForView:(UIView *)targetView
              relativeToView:(UIView *)relativeView
          fromViewController:(UIViewController *)fromViewController
            toViewController:(UIViewController *)toViewController {
    
    if (fromViewController == self) {
        // We're pushing to the detail controller. The starting frame is taken from the selected cell's imageView.
        return [self.giftImageView convertRect:self.giftImageView.bounds toView:relativeView];
    } else if ([fromViewController isKindOfClass:[ExchangeInfoEditViewController class]]) {
        // We're popping back to this master controller. The starting frame is taken from the detailController's imageView.
        ExchangeInfoEditViewController *detailController = (ExchangeInfoEditViewController *)fromViewController;
        return [detailController.imageView convertRect:detailController.imageView.bounds toView:relativeView];
    }
    
    return CGRectZero;
}

- (CGRect)zolaZoomTransition:(ZOZolaZoomTransition *)zoomTransition
       finishingFrameForView:(UIView *)targetView
              relativeToView:(UIView *)relativeView
          fromViewController:(UIViewController *)fromViewController
            toViewController:(UIViewController *)toViewController {
    
    if (fromViewController == self) {
        // We're pushing to the detail controller. The finishing frame is taken from the detailController's imageView.
        ExchangeInfoEditViewController *detailController = (ExchangeInfoEditViewController *)toViewController;
        return [detailController.imageView convertRect:detailController.imageView.bounds toView:relativeView];
    } else if ([fromViewController isKindOfClass:[ExchangeInfoEditViewController class]]) {
        // We're popping back to this master controller. The finishing frame is taken from the selected cell's imageView.
        return [self.giftImageView convertRect:self.giftImageView.bounds toView:relativeView];
    }
    
    return CGRectZero;
}

- (NSArray *)supplementaryViewsForZolaZoomTransition:(ZOZolaZoomTransition *)zoomTransition {
    // Here we're returning all UICollectionViewCells that are clipped by the edge
    // of the screen. These will be used as "supplementary views" so that the clipped
    // cells will be drawn in their entirety rather than appearing cut off during the
    // transition animation.
    
    NSMutableArray *clippedCells = [NSMutableArray arrayWithCapacity:[[self.collectionView visibleCells] count]];
    for (UICollectionViewCell *visibleCell in self.collectionView.visibleCells) {
        CGRect convertedRect = [visibleCell convertRect:visibleCell.bounds toView:self.view];
        if (!CGRectContainsRect(self.view.frame, convertedRect)) {
            [clippedCells addObject:visibleCell];
        }
    }
    return clippedCells;
}

- (CGRect)zolaZoomTransition:(ZOZolaZoomTransition *)zoomTransition
   frameForSupplementaryView:(UIView *)supplementaryView
              relativeToView:(UIView *)relativeView {
    
    return [supplementaryView convertRect:supplementaryView.bounds toView:relativeView];
}


- (void)checkSubViews
{
    NSLog(@"check subViews");
    
    int page = self.mySV.contentOffset.x / self.mySV.frame.size.width;
    NSLog(@"page: %d", page);
    
    for (UIView *addedView in self.mySV.subviews) {
        for (UIView *sub in [addedView subviews]) {
            if ([sub isKindOfClass: [UIButton class]]) {
                UIButton *btn = (UIButton *)sub;
                
                NSLog(@"List all the buttons");
                NSLog(@"btn: %@", btn);
                
                if (btn.tag == page) {
                    NSLog(@"List button matches page");
                    NSLog(@"page: %d", page);
                    NSLog(@"btn.tag == page");
                    NSLog(@"btn.tag: %ld", (long)btn.tag);
                    NSLog(@"btn: %@", btn);
                }
                
                if (btn.tag == 55) {
                    if (isplayaudio) {
                        [btn setImage: [UIImage imageNamed: @"icon_audioswitch_open_white_75x75"] forState: UIControlStateNormal];
                    } else {
                        [btn setImage: [UIImage imageNamed: @"icon_audioswitch_close_white_75x75"] forState: UIControlStateNormal];
                    }
                }
            }
            if ([sub isKindOfClass: [UILabel class]]) {
                UILabel *label = (UILabel *)sub;
                
                NSLog(@"List all the labels");
                NSLog(@"label: %@", label);
                
                if (label.tag == page) {
                    NSLog(@"List label matches page");
                    NSLog(@"page: %d", page);
                    NSLog(@"label.tag == page");
                    NSLog(@"label.tag: %ld", (long)label.tag);
                    NSLog(@"label: %@", label);
                }
            }
        }
    }
}

#pragma mark - Image from HTTP Processing

- (UIImage *)getImageFromURL: (NSString *)fileURL {
    UIImage *resultImage;
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString: fileURL]];
    resultImage = [UIImage imageWithData: data];
    
    return resultImage;
}

- (void)saveImage: (UIImage *)image withFileName: (NSString *)imageName ofType: (NSString *)extension inDirectory: (NSString *)directoryPath {
    if ([[extension lowercaseString] isEqualToString: @"png"]) {
        [UIImagePNGRepresentation(image) writeToFile: [directoryPath stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.%@", imageName, @"png"]] options: NSAtomicWrite error: nil];
        
        NSLog(@"directoryPath with fileName: %@", [directoryPath stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.%@", imageName, @"png"]]);
        
    } else if ([[extension lowercaseString] isEqualToString: @"jpg"] || [[extension lowercaseString] isEqualToString: @"jpeg"]) {
        [UIImageJPEGRepresentation(image, 1.0) writeToFile: [directoryPath stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.%@", imageName, @"jpg"]] options: NSAtomicWrite error: nil];
        
        NSLog(@"directoryPath with fileName: %@", [directoryPath stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.%@", imageName, @"jpg"]]);
        
    } else {
        NSLog(@"Image Save Failed\nExtension: (%@) is not recognized, use (PNG/JPG)", extension);
    }
}

- (UIImage *)loadImage: (NSString *)fileName ofType: (NSString *)extension inDirectory: (NSString *)directoryPath {
    
    NSLog(@"directoryPath with fileName: %@", [directoryPath stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.%@", fileName, extension]]);
    UIImage *result = [UIImage imageWithContentsOfFile: [directoryPath stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.%@", fileName, extension]]];
    
    return result;
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //NSLog(@"");
    //NSLog(@"numberOfSectionsInCollectionView");
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    //NSLog(@"");
    //NSLog(@"numberOfItemsInSection");
    //NSLog(@"pictures.count: %lu", (unsigned long)datalist.count);
    
    return datalist.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"");
    //NSLog(@"cellForItemAtIndexPath");
    //NSLog(@"datalist: %@", datalist);
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"ThumbNailCV" forIndexPath: indexPath];
    
    AsyncImageView *imageV = (AsyncImageView *)[cell viewWithTag: 2222];
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: imageV];
    imageV.layer.masksToBounds = YES;
    imageV.alpha = 0.8;
    
    //NSLog(@"indexPath.item: %ld", (long)indexPath.item);
    
    if (datalist[indexPath.item][@"image_url_thumbnail"] == nil) {
        //NSLog(@"image_url_thumbnail: %@", datalist[indexPath.item][@"image_url_thumbnail"]);
        //NSLog(@"image_url_thumbnail is nil");
        
        NSString *imgStr = datalist[indexPath.row][@"imageThumbnail"];
        
        imageV.image = [UIImage imageNamed: imgStr];
    } else {
        //NSLog(@"image_url_thumbnail: %@", datalist[indexPath.item][@"image_url_thumbnail"]);
        //NSLog(@"image_url_thumbnail is not nil");
        imageV.imageURL = [NSURL URLWithString: datalist[indexPath.item][@"image_url_thumbnail"]];
    }
    
    /*
     if (indexPath.item == (datalist.count - 1)) {
     NSLog(@"");
     
     if (!isOwn) {
     imageV.image = [UIImage imageNamed: datalist[indexPath.item][@"imageThumbnail"]];
     } else if (isOwn) {
     imageV.imageURL = [NSURL URLWithString: datalist[indexPath.item][@"image_url_thumbnail"]];
     }
     }
     */
    
    UIImageView *infoImageView = (UIImageView *)[cell viewWithTag: 3333];
    infoImageView.layer.cornerRadius = infoImageView.bounds.size.width / 2;
    
    //    if (![datalist[indexPath.row][@"video_target"] isKindOfClass: [NSNull class]]) {
    if ([datalist[indexPath.row][@"usefor"] isEqualToString: @"video"]) {
        infoImageView.image = [UIImage imageNamed: @"ic200_video_white"];
        infoImageView.backgroundColor = [UIColor firstMain];
    } else if ([datalist[indexPath.row][@"usefor"] isEqualToString: @"slot"] || [datalist[indexPath.row][@"usefor"] isEqualToString: @"exchange"]) {
        infoImageView.image = [UIImage imageNamed: @"ic200_gift_white"];
        infoImageView.backgroundColor = [UIColor firstMain];
    } else {
        infoImageView.image = nil;
        infoImageView.backgroundColor = [UIColor clearColor];
    }
    
    if (indexPath.item == selectItem) {
        cell.layer.borderWidth = 2;
        cell.layer.borderColor = [UIColor firstMain].CGColor;
        cell.alpha = 1;
    } else {
        cell.layer.borderWidth = 0;
        cell.layer.borderColor = [UIColor clearColor].CGColor;
        cell.alpha = 0.4;
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate Methods
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectItemAtIndexPath");
    
    //UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath: indexPath];
    //NSLog(@"cell.contentView.subviews: %@", cell.contentView.subviews);
    
    //cell.contentView.subviews[0].backgroundColor = [UIColor thirdMain];
    
    selectItem = indexPath.item;
    NSLog(@"selectItem: %ld", (long)selectItem);
    
    for (int i = 0; i < selectItemArray.count; i++) {
        if (i == selectItem) {
            selectItemArray[i] = @"selected";
        } else {
            selectItemArray[i] = @"notSelected";
        }
    }
    
    [self checkCell];
    
    if ([datalist[selectItem][@"usefor"] isEqualToString: @"slot"]) {
        [self loadSlotDataForEachPage: selectItem];
    }
    
    [self.mySV moveToPage: selectItem];
    
    [collectionView reloadData];
    
    //[self.mySV setContentOffset: CGPointMake(self.mySV.frame.size.width * selectItem, 0.0f) animated: YES];
    
    //NSLog(@"self.collectionView.subviews: %@", self.collectionView.subviews);
}

/*
 - (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
 {
 UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath: indexPath];
 //cell.contentView.backgroundColor = nil;
 //cell.contentView.subviews[0].backgroundColor = nil;
 }
 */

- (void)loadExchangeDataForEachPage:(NSInteger)page {
    for (UIView *view in self.mySV.subviews) {
        NSLog(@"view: %@", view);
        NSLog(@"view.accessibilityIdentifier: %@", view.accessibilityIdentifier);
        
        if ([view.accessibilityIdentifier isEqualToString: @"ScrollViewSubViews"]) {
            NSLog(@"view: %@", view);
            
            if (view.frame.origin.x == self.mySV.bounds.size.width * page) {
                NSLog(@"page: %ld", (long)page);
                NSLog(@"view: %@", view);
                
                [self getPhotoUseFor: view];
            }
        }
    }
}

- (void)loadSlotDataForEachPage:(NSInteger)page {
    [self checkSlotDataInDatabaseOrNot];
    NSLog(@"self.slotArray: %@", self.slotArray);
    
    BOOL slotted = NO;
    
    for (int i = 0; i < self.slotArray.count; i++) {
        NSManagedObject *slotData = [self.slotArray objectAtIndex: i];
        NSLog(@"photoId: %ld", [[slotData valueForKey: @"photoId"] integerValue]);
        
        if ([[slotData valueForKey: @"photoId"] integerValue] == [datalist[page][@"photo_id"] integerValue]) {
            slotted = YES;
        }
    }
    NSLog(@"slotted: %d", slotted);
    
    if (slotted) {
        for (UIView *view in self.mySV.subviews) {
            NSLog(@"view: %@", view);
            NSLog(@"view.accessibilityIdentifier: %@", view.accessibilityIdentifier);
            
            if ([view.accessibilityIdentifier isEqualToString: @"ScrollViewSubViews"]) {
                NSLog(@"view: %@", view);
                
                if (view.frame.origin.x == self.mySV.bounds.size.width * page) {
                    NSLog(@"page: %ld", (long)page);
                    NSLog(@"view: %@", view);
                    
                    [self slotPhotoUseFor: view];
                }
            }
        }
    }
}

- (void)scrollToNextCell
{
    CGSize cellSize = CGSizeMake(35, 52);
    CGPoint contentOffset = self.collectionView.contentOffset;
    
    if (self.collectionView.contentSize.width <= self.collectionView.contentOffset.x + cellSize.width) {
        [self.collectionView scrollRectToVisible: CGRectMake(0, contentOffset.y, cellSize.width, cellSize.height) animated: YES];
    } else {
        [self.collectionView scrollRectToVisible: CGRectMake(contentOffset.x + cellSize.width, contentOffset.y, cellSize.width, cellSize.height) animated: YES];
    }
}

- (void)checkCell {
    NSLog(@"checkCell");
    
    NSIndexPath *indexPath;
    UICollectionViewCell *cell;
    
    for (int i = 0; i < selectItemArray.count; i++) {
        indexPath = [NSIndexPath indexPathForItem: i inSection: 0];
        cell = [self.collectionView cellForItemAtIndexPath: indexPath];
        cell.layer.borderWidth = 0;
        cell.layer.borderColor = [UIColor clearColor].CGColor;
        cell.alpha = 0.4;
    }
    
    for (int i = 0; i < selectItemArray.count; i++) {
        indexPath = [NSIndexPath indexPathForItem: i inSection: 0];
        cell = [self.collectionView cellForItemAtIndexPath: indexPath];
        
        if ([selectItemArray[i] isEqualToString: @"selected"]) {
            cell.layer.borderWidth = 2;
            cell.layer.borderColor = [UIColor firstMain].CGColor;
            cell.alpha = 1;
        }
    }
}

#pragma mark - Custom Alert Method
#pragma mark - showCustomCheckPostAlertView
- (void)showCustomCheckPostAlertView: (NSString *)msg
{
    NSLog(@"showCustomCheckPostAlertView msg: %@", msg);
    
    CustomIOSAlertView *alertPostView = [[CustomIOSAlertView alloc] init];
    [alertPostView setContainerView: [self createCheckPostContainerView: msg]];
    
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertPostView.arrangeStyle = @"Horizontal";
    
    if (![self.specialUrl isEqual: [NSNull null]]) {
        [alertPostView setButtonTitles: [NSMutableArray arrayWithObjects: @"離開", @"我要兌換", nil]];
        [alertPostView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor firstMain], nil]];
        [alertPostView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor whiteColor], nil]];
        [alertPostView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    } else {
        [alertPostView setButtonTitles: [NSMutableArray arrayWithObjects: @"離開", nil]];
        [alertPostView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], nil]];
        [alertPostView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], nil]];
        [alertPostView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], nil]];
    }
    
    __weak CustomIOSAlertView *weakAlertPostView = alertPostView;
    [alertPostView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertAlbumView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertAlbumView tag]);
        
        [weakAlertPostView close];
        
        if (buttonIndex == 0) {
            AlbumCollectionViewController *albumCollectionVC = [[UIStoryboard storyboardWithName: @"AlbumCollectionVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumCollectionViewController"];
            albumCollectionVC.postMode = self.postMode;
            
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate.myNav pushViewController: albumCollectionVC animated: YES];
        } else {
            if (![self.specialUrl isEqual: [NSNull null]]) {
                NSLog(@"self.specialUrl: %@", self.specialUrl);
                SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: [NSURL URLWithString: self.specialUrl] entersReaderIfAvailable: NO];
                safariVC.preferredBarTintColor = [UIColor whiteColor];
                [self presentViewController: safariVC animated: YES completion: nil];
            }
        }
        
    }];
    [alertPostView setUseMotionEffects: YES];
    [alertPostView show];
}

- (UIView *)createCheckPostContainerView: (NSString *)msg
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
    imageView.alpha = 0.4;
    
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

#pragma mark -
- (void)toBuyPointVC {
    bPPVC = [[UIStoryboard storyboardWithName: @"BuyPointVC" bundle: nil] instantiateViewControllerWithIdentifier: @"BuyPPointViewController"];
    bPPVC.delegate = self;
    bPPVC.fromVC = @"TestReadBookViewController";
    bPPVC.view.frame = self.view.frame;
    [self.view addSubview: bPPVC.view];
    
    shouldTurnOffAudio = YES;
    self.isAddingBuyPointVC = YES;
    
    [self checkAudioWhenViewConrtrollerShowsUp];
}

#pragma mark - showBuyAlbumCustomAlert
- (void)showBuyAlbumCustomAlert:(NSString *)msg
                         option:(NSString *)option
                       pointStr:(NSString *)pointStr
{
    NSLog(@"showBuyAlbumCustomAlert msg: %@ option: %@", msg, option);
    
    CustomIOSAlertView *alertAlbumView = [[CustomIOSAlertView alloc] init];
    [alertAlbumView setContainerView: [self createBuyAlbumContainerView: msg]];
    
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertAlbumView.arrangeStyle = @"Horizontal";
    
    if ([option isEqualToString: @"buyAlbum"]) {
        [alertAlbumView setButtonTitles: [NSMutableArray arrayWithObjects: @"取消", @"確定", nil]];
    }
    if ([option isEqualToString: @"buyPoint"]) {
        [alertAlbumView setButtonTitles: [NSMutableArray arrayWithObjects: @"稍後再說", @"前往購點", nil]];
    }
    
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertAlbumView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor firstMain],nil]];
    [alertAlbumView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor whiteColor], nil]];
    [alertAlbumView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    
    __weak CustomIOSAlertView *weakAlertAlbumView = alertAlbumView;
    [alertAlbumView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertAlbumView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertAlbumView tag]);
        
        [weakAlertAlbumView close];
        
        if (buttonIndex == 0) {
            
        } else {
            if ([option isEqualToString: @"buyAlbum"]) {
                [self getPoint: pointStr];
            }
            if ([option isEqualToString: @"buyPoint"]) {
                [self toBuyPointVC];
                
                //                bPPVC = [[UIStoryboard storyboardWithName: @"BuyPointVC" bundle: nil] instantiateViewControllerWithIdentifier: @"BuyPPointViewController"];
                //                bPPVC.delegate = self;
                //                bPPVC.fromVC = @"TestReadBookViewController";
                //                bPPVC.view.frame = self.view.frame;
                //                [self.view addSubview: bPPVC.view];
                //
                //                shouldTurnOffAudio = YES;
                //
                //                self.isAddingBuyPointVC = YES;
                //[self.navigationController pushViewController: bPPVC animated: YES];
            }
        }
    }];
    [alertAlbumView setUseMotionEffects: YES];
    [alertAlbumView show];
}

- (UIView *)createBuyAlbumContainerView: (NSString *)msg
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

#pragma mark - showCustomCollectAlertView
- (void)showCustomCollectAlertView: (NSString *)msg
                            option:(NSString *)option
                          pointStr:(NSString *)pointStr
{
    CustomIOSAlertView *collectAlertView = [[CustomIOSAlertView alloc] init];
    [collectAlertView setContainerView: [self createCollectContainerView: msg]];
    
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    collectAlertView.arrangeStyle = @"Horizontal";
    
    if ([option isEqualToString: @"buyAlbum"]) {
        [collectAlertView setButtonTitles: [NSMutableArray arrayWithObjects: @"取消", @"確定", nil]];
    }
    if ([option isEqualToString: @"buyPoint"]) {
        [collectAlertView setButtonTitles: [NSMutableArray arrayWithObjects: @"稍後再說", @"前往購點", nil]];
    }
    
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [collectAlertView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor firstMain],nil]];
    [collectAlertView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor whiteColor], nil]];
    [collectAlertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    
    __weak typeof(self) weakSelf = self;
    [collectAlertView setOnButtonTouchUpInside:^(CustomIOSAlertView *collectAlertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[collectAlertView tag]);
        
        [collectAlertView close];
        
        if (buttonIndex == 0) {
            
        } else {
            if ([option isEqualToString: @"buyAlbum"]) {
                //[self getPoint];
                //[weakSelf getPoint];
                [weakSelf getPoint: pointStr];
            }
            if ([option isEqualToString: @"buyPoint"]) {
                [self toBuyPointVC];
            }
        }
    }];
    [alertView setUseMotionEffects: YES];
    [alertView show];
}

- (UIView *)createCollectContainerView: (NSString *)msg
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
    CustomIOSAlertView *errorAlertView = [[CustomIOSAlertView alloc] init];
    [errorAlertView setContainerView: [self createErrorContainerView: msg]];
    
    [errorAlertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    [errorAlertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    [errorAlertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    errorAlertView.arrangeStyle = @"Horizontal";
    
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

#pragma mark - Custom Method for TimeOut
- (void)showCustomTimeOutAlert: (NSString *)msg
                  protocolName: (NSString *)protocolName
                      pointStr: (NSString *)pointStr
                           btn: (UIButton *)btn
                           bgV: (UIView *)bgV
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
            if ([protocolName isEqualToString: @"api_GET"]) {
                [weakSelf getGoogleAPI];
            } else if ([protocolName isEqualToString: @"insertAlbum2Likes"]) {
                [weakSelf insertAlbumToLikes];
            } else if ([protocolName isEqualToString: @"deleteAlbum2Likes"]) {
                [weakSelf deleteAlbumToLikes];
            } else if ([protocolName isEqualToString: @"checkTaskCompleted"]) {
                [weakSelf checkTaskComplete];
            } else if ([protocolName isEqualToString: @"getPoint"]) {
                [weakSelf getPoint: pointStr];
            } else if ([protocolName isEqualToString: @"buyalbum"]) {
                [weakSelf buyAlbum];
            } else if ([protocolName isEqualToString: @"newBuyAlbum"]) {
                [weakSelf newBuyAlbum: pointStr];
            } else if ([protocolName isEqualToString: @"retrievealbump"]) {
                [weakSelf retrieveAlbum];
            } else if ([protocolName isEqualToString: @"geturpoints"]) {
                [weakSelf getUrPoints];
            } else if ([protocolName isEqualToString: @"doTask2"]) {
                [weakSelf checkPoint];
            } else if ([protocolName isEqualToString: @"switchstatusofcontribution"]) {
                [weakSelf postAlbum];
            } else if ([protocolName isEqualToString: @"slotPhotoUseFor"]) {
                [weakSelf slotPhotoUseFor: bgV];
            } else if ([protocolName isEqualToString: @"getPhotoUseFor"]) {
                [weakSelf getPhotoUseFor: bgV];
            } else if ([protocolName isEqualToString: @"insertBookmark"]) {
                [weakSelf insertBookmark: btn];
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

@end
