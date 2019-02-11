//
//  ContentCheckingViewController.m
//  wPinpinbox
//
//  Created by David on 2018/7/23.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "ContentCheckingViewController.h"
#import "ImageCollectionViewCell.h"
#import "ThumbnailImageCollectionViewCell.h"
#import "AppDelegate.h"
#import "wTools.h"
#import "boxAPI.h"
#import "GlobalVars.h"
#import "MyLayout.h"
#import "UIColor+Extensions.h"
#import "UIColor+HexString.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "LabelAttributeStyle.h"
#import <SafariServices/SafariServices.h>
#import "UIView+Toast.h"
#import "FRHyperLabel.h"
//#import "RegexKitLite.h"
#import <TTTAttributedLabel.h>
#import "CustomIOSAlertView.h"
#import "OldCustomAlertView.h"
#import "BuyPPointViewController.h"
#import "MessageboardViewController.h"
#import "NewMessageBoardViewController.h"
#import "DDAUIActionSheetViewController.h"
#import "MapShowingViewController.h"
#import "AlbumInfoViewController.h"
#import "AlbumCollectionViewController.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareLinkContent.h>
#import <FBSDKShareKit/FBSDKShareDialog.h>

#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

#import "YTVimeoExtractor.h"
#import "ExchangeInfoEditViewController.h"

#import "ZOZolaZoomTransition.h"
#import <SSFadingScrollView.h>

//#import "YoutubePlayerViewController.h"

#import "DMViewController.h"
#import "UIViewController+ErrorAlert.h"



#import "WKVideoPlayerView.h"
#import "3rdPartyVideoPlayerViewController.h"
#import "MapHelper.h"

//#import "MBProgressHUD.h"


#define kTextContentHeight 155

typedef void (^FBBlock)(void);typedef void (^FBBlock)(void);

static NSString *autoPlayStr = @"&autoplay=1";

static void *AVPlayerDemoPlaybackViewControllerRateObservationContext = &AVPlayerDemoPlaybackViewControllerRateObservationContext;
static void *AVPlayerDemoPlaybackViewControllerStatusObservationContext = &AVPlayerDemoPlaybackViewControllerStatusObservationContext;
static void *AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext = &AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext;

@interface ContentCheckingViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, TTTAttributedLabelDelegate, BuyPPointViewControllerDelegate, MessageboardViewControllerDelegate, DDAUIActionSheetViewControllerDelegate, MapShowingViewControllerDelegate, FBSDKSharingDelegate, SFSafariViewControllerDelegate, ExchangeInfoEditViewControllerDelegate, ZOZolaZoomTransitionDelegate, UINavigationControllerDelegate, NewMessageBoardViewControllerDelegate, /*YoutubePlayerViewControllerDelegate, */AlbumInfoViewControllerDelegate, UITextViewDelegate, UITextFieldDelegate> {
    BOOL isDataLoaded;
    BOOL isRotating;
    BOOL kbShowUp;
    CGFloat textViewContentHeight;
    
    NSString *btnUrl1;
    NSString *btnUrl2;
    
    NSUserDefaults *userPrefs;
    
    UIScrollView *bgSV;
    UITextView *nameTextView;
    UITextView *phoneTextView;
    UITextView *addressTextView;
    UITextField *inputTextField;
    
//    UITextField *inputField;
    
    NSUInteger albumPoint;
    NSUInteger userPoint;
    NSUInteger exchangeNumber;
    NSUInteger oldCurrentPage;
    
    NSDictionary *locdata;
    
    BOOL isLikeBtnPressed;
    NSString *task_for;
    
    // For Showing Message of Getting Point
    NSString *missionTopicStr;
    NSString *rewardType;
    NSString *rewardValue;
    NSString *eventUrl;
    NSString *restriction;
    NSString *restrictionValue;
    NSUInteger numberOfCompleted;
    
    OldCustomAlertView *alertView;
    
    // Audio Section
    NSString *audioMode;
    NSString *audioTarget;
    BOOL isReadyToPlay;
    
    float mRestoreAfterScrubbingRate;
    BOOL seekToZeroBeforePlay;
    id mTimeObserver;
    BOOL isSeeking;
    NSString *useFor;
    BOOL videoIsPlaying;
    
    
    CGFloat giftViewWidth;
    CGFloat giftViewHeight;
    
    BOOL isGiftImageLoaded;
    
    BOOL isRotated;
    CGSize sizeAfterRotating;
    float offsetAfterRotating;
    UIInterfaceOrientation orientation;
    
    BOOL rewardAfterCollect;
    BOOL displayNumOfCollect;
}
@property (nonatomic) DGActivityIndicatorView *activityIndicatorView;

@property (weak, nonatomic) IBOutlet UIView *navBarBgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarBgViewHeight;
@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarViewTopConstraint;

@property (weak, nonatomic) IBOutlet UILabel *pageOrderLabel;
@property (weak, nonatomic) IBOutlet MyLinearLayout *navBarHorzLayout1;
@property (weak, nonatomic) IBOutlet MyLinearLayout *navBarHorzLayout2;
@property (weak, nonatomic) IBOutlet UIButton *locationBtn;
@property (weak, nonatomic) IBOutlet UIButton *soundBtn;
@property (weak, nonatomic) IBOutlet UIButton *messageBtn;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;
@property (weak, nonatomic) IBOutlet UISlider *mScrubber;

@property (strong, nonatomic) UITapGestureRecognizer *singleTap;

@property (nonatomic, strong) NSMutableArray *photoArray;
@property (nonatomic) BOOL isOwned;
@property (strong, nonatomic) NSDictionary *bookdata;

@property (weak, nonatomic) IBOutlet UICollectionView *imageScrollCV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageScrollCVBottomConstraint;
@property (nonatomic) int pageBeforePresentingOrPushing;
@property (nonatomic) UIInterfaceOrientation previousOrientation;
@property (nonatomic) BOOL isPresentingOrPushingVC;

@property (weak, nonatomic) IBOutlet MyLinearLayout *textAndImageVertLayout;

@property (weak, nonatomic) IBOutlet UIView *textViewBgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBgViewHeightConstraint;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBgViewBottomConstraint;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottomConstraint;

//@property (weak, nonatomic) IBOutlet UIScrollView *descriptionScrollView;
@property (weak, nonatomic) IBOutlet SSFadingScrollView *descriptionScrollView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionScrollViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionScrollViewBottomConstraint;
//@property (weak, nonatomic) IBOutlet FRHyperLabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIStackView *linkStackView;
@property (weak, nonatomic) IBOutlet UIButton *linkBtn1;
@property (weak, nonatomic) IBOutlet UIButton *linkBtn2;

@property (weak, nonatomic) IBOutlet UIView *horzLineView;
@property (weak, nonatomic) IBOutlet UICollectionView *thumbnailImageScrollCV;

@property (nonatomic) DDAUIActionSheetViewController *customMoreActionSheet;
@property (nonatomic) DDAUIActionSheetViewController *customShareActionSheet;
@property (nonatomic) MessageboardViewController *customMessageActionSheet;
@property (nonatomic) MapShowingViewController *mapShowingActionSheet;
@property (nonatomic) UIVisualEffectView *effectView;

@property (strong, nonatomic) AVPlayer *avPlayer;
@property (strong, nonatomic) AVPlayerItem *avPlayerItem;

@property (strong, nonatomic) AVPlayer *videoPlayer;
@property (strong, nonatomic) AVPlayerItem *videoPlayerItem;
@property (strong, nonatomic) AVPlayerViewController *videoPlayerViewController;

@property (nonatomic) NSMutableDictionary *slotDicData;
@property (strong, nonatomic) NSMutableArray *slotArray;
@property (nonatomic) UIImageView *giftImageView;

@property (strong) NSMutableArray *browseArray;
@property (nonatomic) NSURL *fbVideoUrl;

@property (nonatomic) UITextField *activeTextField;
@property (nonatomic) UITextView *activeTextView;

@property (nonatomic) CGPoint lastOffset;

@property (nonatomic) WKWebViewConfiguration *wkvideoplayerConf;
@property (nonatomic) BOOL is3rdPartyVideoPlaying;

@property (nonatomic) IBOutlet UIView *autoplayView;
@property (nonatomic) IBOutlet NSLayoutConstraint *autoplayViewConstraint;
@property (nonatomic) IBOutlet UIButton *autoplay;
@property (nonatomic) dispatch_source_t autoplayTimer;
@property (nonatomic) dispatch_queue_t autoplayQueue;
@property (nonatomic) NSTimeInterval playStart;
@property (nonatomic) NSTimeInterval playThrough;
@end

@implementation ContentCheckingViewController

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
    
    if (![wTools objectExists: self.browseArray]) {
        return;
    }
    
    for (int i = 0; i < self.browseArray.count; i++) {
        NSManagedObject *browseData = [self.browseArray objectAtIndex: i];
        
        if ([[browseData valueForKey: @"albumId"] isEqualToString: self.albumId]) {
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
    
    if (![wTools objectExists: self.browseArray]) {
        return;
    }
    
    if (self.browseArray.count >= 20) {
        NSLog(@"browseArray.count is more than 20, so need to be removed the last object");
        [managedObjectContext deleteObject: [self.browseArray lastObject]];
    }
}

- (void)saveBrowsingData: (NSDictionary *)bookData {
    NSLog(@"saveBrowseData");
    NSLog(@"bookData: %@", bookData);
    NSArray *photoArr = bookData[@"photo"];
    NSLog(@"photoArr: %@", photoArr);
    
    NSString *imageUrlThumbnail;
    
    if ([wTools objectExists: photoArr[0][@"image_url_thumbnail"]]) {
        imageUrlThumbnail = photoArr[0][@"image_url_thumbnail"];
    }
    // Save data to Core Data
    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *newData = [NSEntityDescription insertNewObjectForEntityForName: @"Browse" inManagedObjectContext: context];
    
    NSLog(@"album name: %@", bookData[@"album"][@"name"]);
    
    if ([wTools objectExists: self.albumId]) {
        [newData setValue: self.albumId forKey: @"albumId"];
    }
    if ([wTools objectExists: bookData[@"user"][@"name"]]) {
        [newData setValue: bookData[@"user"][@"name"] forKey: @"author"];
    }
    if ([wTools objectExists: bookData[@"album"][@"description"]]) {
        [newData setValue: bookData[@"album"][@"description"] forKey: @"descriptionInfo"];
    }
    if ([wTools objectExists: bookData[@"album"][@"name"]]) {
        [newData setValue: bookData[@"album"][@"name"] forKey: @"title"];
    }
    if ([wTools objectExists: imageUrlThumbnail]) {
        [newData setValue: imageUrlThumbnail forKey: @"imageUrlThumbnail"];
    }
    if ([wTools objectExists: [NSDate date]]) {
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
    
    if (![wTools objectExists: self.slotArray]) {
        return;
    }
    
    for (int i = 0; i < self.slotArray.count; i++) {
        NSManagedObject *slotData = [self.slotArray objectAtIndex: i];
        NSLog(@"photoId: %d", (int)[[slotData valueForKey: @"photoId"] integerValue]);
    }
}

- (void)saveSlotData:(NSInteger)photoId {
    NSLog(@"saveSlotData");
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName: @"Slot"];
    self.slotArray = [[context executeFetchRequest: fetchRequest error: nil] mutableCopy];
    NSLog(@"self.slotArray: %@", self.slotArray);
    
    BOOL photoIdExist = NO;
    
    if (![wTools objectExists: self.slotArray]) {
        return;
    }
    
    for (int i = 0; i < self.slotArray.count; i++) {
        NSManagedObject *slotData = [self.slotArray objectAtIndex: i];
        NSLog(@"photoId: %d", (int)[[slotData valueForKey: @"photoId"] integerValue]);
        
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initActivityIndicatorView];
    [self initialValueSetup];
    [self retrieveAlbum];
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
//    [[NSNotificationCenter defaultCenter] addObserverForName:UIWindowDidBecomeKeyNotification
//                                                      object:nil
//                                                       queue:nil
//                                                  usingBlock:^(NSNotification* notification) {
//                                                      if ([UIApplication sharedApplication].keyWindow.tag == 10001) {
//                                                          [self pageCalculation:[self getCurrentPage]];
//                                                      }
//                                                  }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"ContentCheckingViewController viewWillAppear");
    [wTools setStatusBarBackgroundColor:[UIColor clearColor]];
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"ContentCheckingViewController viewDidAppear");
    [super viewDidAppear:animated];
    [wTools sendScreenTrackingWithScreenName: @"閱讀器"];
    [self addKeyboardNotification];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeKeyboardNotification];
    
    if ([self.delegate respondsToSelector: @selector(contentCheckingViewControllerViewWillDisappear:isLikeBtnPressed:)]) {
        [self.delegate contentCheckingViewControllerViewWillDisappear: self
                                                     isLikeBtnPressed: isLikeBtnPressed];
    }
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    //NSLog(@"isRotated: %d", isRotated);
    
    if (self.isPresentingOrPushingVC) {
        if (isRotated) {
            self.isPresentingOrPushingVC = NO;
            isRotated = NO;
            NSLog(@"offsetAfterRotating: %f", offsetAfterRotating);
            [self.imageScrollCV setContentOffset: CGPointMake(offsetAfterRotating, 0)];
        }
    }
    NSLog(@"self.imageScrollCV contentOffset.x  %f",self.imageScrollCV.contentOffset.x);
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.navBarBgViewHeight.constant = 48;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - changeOrientationToPortrait
- (void)changeOrientationToPortrait {
    // Force to return to portrait orientation
    NSNumber *value = [NSNumber numberWithInt: UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue: value forKey: @"orientation"];
}

#pragma mark - initActivityIndicatorView
- (void)initActivityIndicatorView {
    self.activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType: DGActivityIndicatorAnimationTypeDoubleBounce tintColor: [UIColor secondMain] size: kActivityIndicatorViewSize];
    self.activityIndicatorView.frame = CGRectMake(0.0f, 0.0f, 50.0f, 50.0f);
    self.activityIndicatorView.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
    [self.view addSubview: self.activityIndicatorView];
}

#pragma mark - initialValueSetup
- (void)initialValueSetup {
    NSLog(@"viewDidAppear");
    self.navigationController.delegate = self;
    
    self.isPresented = YES;
    isDataLoaded = NO;
    isRotating = NO;
    kbShowUp = NO;
    isLikeBtnPressed = NO;
    oldCurrentPage = 0;
    videoIsPlaying = NO;
    
    giftViewWidth = self.view.frame.size.width - 32 * 2;
    giftViewHeight = self.view.frame.size.width;
    
    isGiftImageLoaded = NO;
    
    self.isPresentingOrPushingVC = NO;
    
    isRotated = NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.audioSwitch = [[defaults objectForKey: @"isAudioPlayedAutomatically"] boolValue];
    NSLog(@"self.audioSwitch: %d", self.audioSwitch);
    
    userPrefs = [NSUserDefaults standardUserDefaults];
    
    self.descriptionScrollView.fadeSize = 10;
    
    [self setupCustomMapActionSheet];
    [self setupCustomMoreActionSheet];
    [self setupCustomShareActionSheet];
    [self setupCustomMessageActionSheet];
    
    [self setupTapGesture];
    [self setupNavBarRelated];
    [self setupPageOrderLabel];
    [self setupImageScrollCV];
    [self setupTextAndImageVertLayout];
    [self settingSizeBasedOnDevice];
    [self btnSetup];
}

- (void)setupCustomMapActionSheet {
    self.mapShowingActionSheet = [[MapShowingViewController alloc] init];
    self.mapShowingActionSheet.delegate = self;
}

- (void)setupCustomMoreActionSheet {
    self.customMoreActionSheet = [[DDAUIActionSheetViewController alloc] init];
    self.customMoreActionSheet.delegate = self;
    self.customMoreActionSheet.topicStr = @"你 想 做 什 麼?";
}

- (void)setupCustomShareActionSheet {
    self.customShareActionSheet = [[DDAUIActionSheetViewController alloc] init];
    self.customShareActionSheet.delegate = self;
    self.customShareActionSheet.topicStr = @"選 擇 分 享 方 式";
}

- (void)setupCustomMessageActionSheet {
    self.customMessageActionSheet = [[MessageboardViewController alloc] init];
    self.customMessageActionSheet.delegate = self;
    self.customMessageActionSheet.topicStr = @"留言板";
    self.customMessageActionSheet.userName = @"";
    self.customMessageActionSheet.type = @"album";
    self.customMessageActionSheet.typeId = self.albumId;
}

- (void)setupTapGesture {
    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleSingleTap)];
    // setCancelsTouchesInView to NO will cause no tap response when AVPlayerViewController in Full Screen, so that the playBackControls won't show up when tapping
//    [self.singleTap setCancelsTouchesInView: NO];
    
    [self.imageScrollCV addGestureRecognizer: self.singleTap];
//    [self.view addGestureRecognizer: self.singleTap];
}

#pragma mark - UI Setup
- (void)setupNavBarRelated {
    // Grident Effect for NavBarView
    self.navBarBgView.backgroundColor = [UIColor blackColor];
    self.navBarBgView.alpha = 0.5;
    self.navBarView.backgroundColor = [UIColor clearColor];
    self.navBarHorzLayout1.gravity = MyMarginGravity_Horz_Left;
    self.navBarHorzLayout2.gravity = MyMarginGravity_Horz_Right;
}

- (void)setupPageOrderLabel {
    self.pageOrderLabel.font = [UIFont systemFontOfSize: 14.0];
    self.pageOrderLabel.text = [NSString stringWithFormat: @"%d / %@", 0, @"讀取中"];
    [self.pageOrderLabel sizeToFit];
}

- (void)setupImageScrollCV {
    NSLog(@"setupImageScrollCV");
    self.imageScrollCV.alpha = 0;
    self.imageScrollCV.pagingEnabled = YES;
    self.imageScrollCV.showsVerticalScrollIndicator = NO;
    self.imageScrollCV.showsHorizontalScrollIndicator = NO;
}

- (void)setupTextAndImageVertLayout {
    NSLog(@"setupTextAndImageVertLayout");
    self.textAndImageVertLayout.backgroundColor = [UIColor blackColor];
    self.textAndImageVertLayout.alpha = 0.8;
    
    self.textViewBgView.backgroundColor = [UIColor blackColor];
    self.textViewBgView.alpha = 0;
    
    self.descriptionLabel.font = [UIFont boldSystemFontOfSize: 16.0];
    self.descriptionLabel.numberOfLines = 0;
    self.descriptionLabel.textColor = [UIColor whiteColor];
    self.descriptionLabel.text = @"";
    self.descriptionLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    self.descriptionLabel.delegate = self;
    self.descriptionLabel.linkAttributes = @{NSForegroundColorAttributeName: [UIColor firstMain], NSFontAttributeName: [UIFont boldSystemFontOfSize: 18.0]};
    
    [self.linkBtn1 setTitle: @"" forState: UIControlStateNormal];
    [self.linkBtn2 setTitle: @"" forState: UIControlStateNormal];
    
    [self.linkBtn1 setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [self.linkBtn2 setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    
    self.linkBtn1.backgroundColor = [UIColor firstMain];
    self.linkBtn2.backgroundColor = [UIColor firstMain];
    
    self.linkBtn1.layer.cornerRadius = 15;
    self.linkBtn2.layer.cornerRadius = 15;
    
    self.descriptionScrollView.showsVerticalScrollIndicator = NO;
    self.descriptionScrollView.alpha = 0;
    
    self.horzLineView.alpha = 0;
    self.horzLineView.backgroundColor = [UIColor thirdGrey];
    
    self.thumbnailImageScrollCV.pagingEnabled = NO;
    self.thumbnailImageScrollCV.alpha = 0;
    self.thumbnailImageScrollCV.showsVerticalScrollIndicator = NO;
    self.thumbnailImageScrollCV.showsHorizontalScrollIndicator = NO;
}

- (void)settingSizeBasedOnDevice {

    CGRect rect;
    bgSV.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                self.navBarViewTopConstraint.constant = 0;
                if (orientation == 1) {
                    rect = self.imageScrollCV.frame;
                    rect.size.width = 320;
                    rect.size.height = 548;
                    self.imageScrollCV.frame = rect;
                } else {
                    rect = self.imageScrollCV.frame;
                    rect.size.width = 568;
                    rect.size.height = 320;
                    self.imageScrollCV.frame = rect;
                }
                break;
            case 1334:
                printf("iPhone 6/6S/7/8");
                self.navBarViewTopConstraint.constant = 0;
                if (orientation == 1) {
                    rect = self.imageScrollCV.frame;
                    rect.size.width = 375;
                    rect.size.height = 647;
                    self.imageScrollCV.frame = rect;
                } else {
                    rect = self.imageScrollCV.frame;
                    rect.size.width = 667;
                    rect.size.height = 375;
                    self.imageScrollCV.frame = rect;
                }
                break;
            case 1920:
                printf("iPhone 6+/6S+/7+/8+");
                self.navBarViewTopConstraint.constant = 0;
                if (orientation == 1) {
                    rect = self.imageScrollCV.frame;
                    rect.size.width = 414;
                    rect.size.height = 716;
                    self.imageScrollCV.frame = rect;
                } else {
                    rect = self.imageScrollCV.frame;
                    rect.size.width = 736;
                    rect.size.height = 414;
                    self.imageScrollCV.frame = rect;
                }
                break;
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                self.navBarViewTopConstraint.constant = 0;
                
                break;
            //case 2436:
            default:
                printf("iPhone X");
                self.navBarViewTopConstraint.constant = 20;
                
                if (orientation == 1) {
                    rect = self.imageScrollCV.frame;
                    rect.size.width = UIScreen.mainScreen.bounds.size.width;//375;
                    if (@available(iOS 11.0, *)) {
                        rect.size.height = self.view.safeAreaLayoutGuide.layoutFrame.size.height;
                    } else {
                        // Fallback on earlier versions
                        rect.size.height = self.view.frame.size.height-48;
                    }
                    self.imageScrollCV.frame = rect;
                } else {
                    rect = self.imageScrollCV.frame;
                    rect.size.width = 724;
                    rect.size.height = 394;
                    self.imageScrollCV.frame = rect;
                }
                break;
//            default:
//                printf("unknown");
//                self.navBarViewTopConstraint.constant = 0;
//                break;
        }
    }
}

- (void)handleSingleTap {
    NSLog(@"handleSingleTap");
    [inputTextField resignFirstResponder];
    [self.activeTextField resignFirstResponder];
    self.activeTextField = nil;
    [self.activeTextView resignFirstResponder];
    self.activeTextView = nil;
    
    [UIView animateWithDuration: 0.2 animations:^{
        self.navBarBgView.hidden = !self.navBarBgView.hidden;
        self.navBarView.hidden = !self.navBarView.hidden;
        self.textAndImageVertLayout.hidden = !self.textAndImageVertLayout.hidden;
        self.textViewBgView.hidden = !self.textViewBgView.hidden;
        self.textView.hidden = !self.textView.hidden;
        self.descriptionScrollView.hidden = !self.descriptionScrollView.hidden;                
    }];
    
    if (![wTools objectExists: useFor]) {
        return;
    }
    
    if ([useFor isEqualToString: @"video"]) {
        if ((self.videoPlayer.rate != 0) && (self.videoPlayer.error == nil)) {
            NSLog(@"self.videoPlayer.rate: %f", self.videoPlayer.rate);
        }        
        if (self.navBarView.hidden) {
            self.videoPlayerViewController.showsPlaybackControls = YES;
        } else {
            self.videoPlayerViewController.showsPlaybackControls = NO;
        }
    }
}

- (void)btnSetup {
    if (self.isLikes) {
        [self.likeBtn setImage: [UIImage imageNamed: @"ic200_ding_pink"] forState: UIControlStateNormal];
    } else {
        [self.likeBtn setImage: [UIImage imageNamed: @"ic200_ding_light"] forState: UIControlStateNormal];
    }
    
    self.soundBtn.hidden = YES;
    self.mScrubber.hidden = YES;
//    [self.mScrubber setThumbImage: [UIImage imageNamed: @"slider-metal-handle"] forState: UIControlStateNormal];
//    [self.mScrubber setThumbImage: [UIImage imageNamed: @"slider-metal-handle-highlighted"] forState: UIControlStateHighlighted];
//
//    self.mScrubber.thumbTintColor = [UIColor secondMain];
//    self.mScrubber.tintColor = [UIColor secondMain];
//    self.mScrubber.maximumTrackTintColor = [UIColor firstGrey];
    
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(18, 18)];
    UIImage *thumbImage = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull context) {
        [[UIColor firstMain] setFill];
        UIBezierPath *p = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(1, 1, 16, 16)];
        [p fill];
    }];
    
    [self.mScrubber setThumbImage: thumbImage/*[UIImage imageNamed: @"slider-metal-handle"]*/ forState: UIControlStateNormal];
    //[self.mScrubber setThumbImage: [UIImage imageNamed: @"slider-metal-handle-highlighted"] forState: UIControlStateHighlighted];
    UIGraphicsImageRenderer *renderer2 = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(10, 18)];
    UIImage *slider0 = [renderer2 imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull context) {
        [[UIColor firstGrey] setFill];
        UIBezierPath *p0 = [UIBezierPath bezierPathWithRect:CGRectMake(0, 8, 8, 2)];
        [p0 fill];
    }];
    UIImage *slider1 = [renderer2 imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull context) {
        [[UIColor firstMain] setFill];
        UIBezierPath *p = [UIBezierPath bezierPathWithRect:CGRectMake(0, 8, 8, 2)];
        [p fill];
    }];
    UIImage *slider = [slider0 stretchableImageWithLeftCapWidth:4 topCapHeight:0];
    UIImage *slider11 = [slider1 stretchableImageWithLeftCapWidth:4 topCapHeight:0];
    [self.mScrubber setMinimumTrackImage:slider11 forState:UIControlStateNormal];
    [self.mScrubber setMaximumTrackImage:slider forState:UIControlStateNormal];        
}

- (void)pageCalculation:(NSInteger)page {
    NSLog(@"pageCalculation");
    page += 1;
    
    if (self.photoArray.count == 0) {
        self.pageOrderLabel.text = [NSString stringWithFormat: @"%ld / %@", (long)page, @"讀取中"];
    } else {
        if (self.isOwned) {
            self.pageOrderLabel.text = [NSString stringWithFormat: @"%ld / %lu", (long)page, (unsigned long)self.photoArray.count];
        } else {
            self.pageOrderLabel.text = [NSString stringWithFormat: @"%ld / %lu", (long)page, (unsigned long)self.photoArray.count - 1];
        }
    }
    [LabelAttributeStyle changeGapString: self.pageOrderLabel content: self.pageOrderLabel.text];
    [self.pageOrderLabel sizeToFit];
}

- (void)processVCTransition {
    orientation = [[UIApplication sharedApplication] statusBarOrientation];
    NSLog(@"");
    NSLog(@"");
    NSLog(@"orientation: %ld", (long)orientation);
    
    self.previousOrientation = orientation;
    
    
    if (orientation == 1) {
        NSLog(@"Portrait Mode");
        NSLog(@"self.view.frame: %@", NSStringFromCGRect(self.view.frame));
        NSLog(@"");
        NSLog(@"self.imageScrollCV.frame.size: %@", NSStringFromCGSize(self.imageScrollCV.frame.size));
        
        [self settingSizeBasedOnDevice];
        self.horzLineView.hidden = NO;
        self.thumbnailImageScrollCV.hidden = NO;
        self.descriptionScrollViewBottomConstraint.constant = 0;
        
        //            self.descriptionScrollViewHeightConstraint.constant = 140;
        //            self.textViewBottomConstraint.constant = 0;
        //            self.textViewBgViewBottomConstraint.constant = 0;
    } else {
        NSLog(@"Landscape Mode");
        NSLog(@"self.view.frame: %@", NSStringFromCGRect(self.view.frame));
        NSLog(@"");
        NSLog(@"self.imageScrollCV.frame.size: %@", NSStringFromCGSize(self.imageScrollCV.frame.size));
        
        self.navBarViewTopConstraint.constant = 0;
        self.horzLineView.hidden = YES;
        self.thumbnailImageScrollCV.hidden = YES;
        //            self.descriptionScrollViewHeightConstraint.constant = 120;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
                case 2436:
                    printf("iPhone X");
                    self.imageScrollCVBottomConstraint.constant = 40;
                    //                        self.textViewBottomConstraint.constant = -20;
                    self.descriptionScrollViewBottomConstraint.constant = -20;
                    //                        self.textViewBgViewBottomConstraint.constant = -20;
                    break;
            }
        }
    }
}
- (void)processTransitionCompletion {
    
    CGSize currentSize = self.imageScrollCV.frame.size;
    offsetAfterRotating = self.pageBeforePresentingOrPushing * currentSize.width;
    NSLog(@"offsetAfterRotating: %f", offsetAfterRotating);
    // Offset for iPhoneX
    [self.imageScrollCV setContentOffset: CGPointMake(offsetAfterRotating, 0)];
    NSLog(@"");
    NSLog(@"self.imageScrollCV.contentOffset: %@", NSStringFromCGPoint(self.imageScrollCV.contentOffset));
    
    [UIView animateWithDuration: 0.1f animations:^{
        self.imageScrollCV.alpha = 1.0f;
    }];
    
    
    //        NSIndexPath *indexPath = [NSIndexPath indexPathForItem: self.pageBeforePresentingOrPushing inSection: 0];
    [self.thumbnailImageScrollCV reloadData];
    //        [self.thumbnailImageScrollCV scrollToItemAtIndexPath: indexPath atScrollPosition: UICollectionViewScrollPositionCenteredHorizontally animated: NO];
    
    NSLog(@"");
    NSLog(@"self.videoPlayerViewController.view.hidden: %d", self.videoPlayerViewController.view.hidden);
    
    //        [self.imageScrollCV scrollToItemAtIndexPath: indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated: NO];
    isRotating = NO;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"");
    NSLog(@"viewWillTransitionToSize");
    [super viewWillTransitionToSize: size withTransitionCoordinator: coordinator];
    
    // Need to dismiss keyboard, otherwise UICollectionViewCell will be scrolled
    [self dismissKeyboard];
    
    isRotating = YES;
    isRotated = YES;
    
    self.imageScrollCV.alpha = 0.0f;
    [self.imageScrollCV.collectionViewLayout invalidateLayout];
    NSLog(@"");
    NSLog(@"self.imageScrollCV.frame.size: %@", NSStringFromCGSize(self.imageScrollCV.frame.size));
    
    [self updatePageBeforePresentingOrPushing];
    NSLog(@"self.pageBeforePresentingOrPushing: %d", self.pageBeforePresentingOrPushing);
    __block typeof(self) wself = self;
    
    
    //NSIndexPath *indexPath = [NSIndexPath indexPathForItem: [self getCurrentPage] inSection: 0];
    //ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[self.imageScrollCV cellForItemAtIndexPath: indexPath];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [wself processVCTransition];
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        NSLog(@"");
        NSLog(@"coordinator completion");
        [wself settingSizeBasedOnDevice];
        
        [wself processTransitionCompletion];
        
    }];
}
- (void)updatePageBeforePresentingOrPushing {
    CGPoint currentOffset = [self.imageScrollCV contentOffset];
    NSLog(@"currentOffset: %@", NSStringFromCGPoint(currentOffset));
    self.pageBeforePresentingOrPushing = currentOffset.x / self.imageScrollCV.frame.size.width;
}

#pragma mark - Calling API
- (void)retrieveAlbum {
    NSLog(@"retrieveAlbum");
    [self.activityIndicatorView startAnimating];
    __block typeof(self.albumId) aid = self.albumId;
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI retrievealbump: aid//self.albumId
                                                uid: [wTools getUserID]
                                              token: [wTools getUserToken]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicatorView stopAnimating];
            
            if (response != nil) {
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ContentCheckingViewController");
                    NSLog(@"retrieveAlbum");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"retrievealbump"
                                        pointStr: @""
                                             btn: nil
                                             bgV: nil];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"result bool value is YES");
                        wself->isDataLoaded = YES;
                        NSLog(@"dic data: %@", dic[@"data"]);
                        self.bookdata = [dic[@"data"] copy];
                        
                        if ([self.bookdata[@"photo"] isEqual: [NSNull null]]) {
                            CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                            style.messageColor = [UIColor whiteColor];
                            style.backgroundColor = [UIColor thirdPink];
                            
                            [wself.view makeToast: @"作品內沒有內容 "
                                         duration: 2.0
                                         position: CSToastPositionBottom
                                            style: style];
                            return;
                        }
                        if ([wTools objectExists: self.bookdata[@"album"][@"reward_after_collect"]]) {
                            self->rewardAfterCollect = [self.bookdata[@"album"][@"reward_after_collect"] boolValue];
                            NSLog(@"reward_after_collect: %@", self.bookdata[@"album"][@"reward_after_collect"]);
                        }
                        if ([wTools objectExists: self.bookdata[@"album"][@"display_num_of_collect"]]) {
                            self->displayNumOfCollect = [self.bookdata[@"album"][@"display_num_of_collect"] boolValue];
                        }
                        
                        NSLog(@"display_num_of_collect: %@", self.bookdata[@"album"][@"display_num_of_collect"]);
                        NSLog(@"preview_page_num: %@", self.bookdata[@"album"][@"preview_page_num"]);
                        NSLog(@"reward_description: %@", self.bookdata[@"album"][@"reward_description"]);
                        // Core Data Setting for RecentBrowsingViewController
                        [self checkBrowsingDataInDatabaseOrNot];
                        [self checkBrowsingDataReachMax];
                        [self saveBrowsingData: self.bookdata];
                        
                        self.photoArray = [NSMutableArray arrayWithArray: dic[@"data"][@"photo"]];
                        [self checkIsOwnedOrNot: dic[@"data"]];
                        
                        [self getMapAPI];
                        [self checkLocationBtn: wself->oldCurrentPage];
                        [self checkAudio: wself->oldCurrentPage];
                        [self.imageScrollCV reloadData];
                        [self.thumbnailImageScrollCV reloadData];
                        [self checkAutoPlay];
                        
                        double delayInSeconds = 0.5;
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            NSLog(@"Do some work");
                            
                            if (self.isOwned) {
                                NSLog(@"Owned this album");
                                NSLog(@"To 1st page");
                                // To 1st Page
                                NSIndexPath *indexPath = [NSIndexPath indexPathForItem: 0 inSection: 0];
                                [self.imageScrollCV scrollToItemAtIndexPath: indexPath atScrollPosition: UICollectionViewScrollPositionCenteredHorizontally animated: NO];
                                
                                // To old current page
                                NSLog(@"To old current page");
                                indexPath = [NSIndexPath indexPathForItem: wself->oldCurrentPage inSection: 0];
                                [self.imageScrollCV scrollToItemAtIndexPath: indexPath atScrollPosition: UICollectionViewScrollPositionCenteredHorizontally animated: NO];
                                [self.thumbnailImageScrollCV reloadData];
                            }
                            
                            [UIView animateWithDuration: 0.1 animations:^{
                                self.imageScrollCV.alpha = 0;
                                self.imageScrollCV.alpha = 1;
                                self.thumbnailImageScrollCV.alpha = 0;
                                self.thumbnailImageScrollCV.alpha = 1;
                                
                                self.textViewBgView.alpha = 0;
                                self.textViewBgView.alpha = 0.5;
                                
                                self.horzLineView.alpha = 0;
                                self.horzLineView.alpha = 1;
                                
                                self.descriptionScrollView.alpha = 0;
                                self.descriptionScrollView.alpha = 1;
                                
                                // Cell need to be successfully initialized then can play
                                NSLog(@"oldCurrentPage: %lu", (unsigned long)wself->oldCurrentPage);
                                [self checkVideo: wself->oldCurrentPage];
                                
                                // cell.giftViewBgV need to be successfully initialized then can play
                                NSIndexPath *indexPath = [NSIndexPath indexPathForItem: wself->oldCurrentPage inSection: 0];
                                ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[self.imageScrollCV cellForItemAtIndexPath: indexPath];
                                NSLog(@"cell: %@", cell);
                                NSLog(@"cell.giftViewBgV: %@", cell.giftViewBgV);
                                [self checkSlotAndExchangeInfo: wself->oldCurrentPage];
                            }];
                            [self textViewContentSetup: [self getCurrentPage]];
                            [self pageCalculation: [self getCurrentPage]];
                        });
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗：%@",dic[@"message"]);
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

- (void)checkAudio:(NSInteger)page {
    NSLog(@"checkAudio");
    // Get audioMode first
    self.mScrubber.hidden = NO;

    audioMode = self.bookdata[@"album"][@"audio_mode"];
    NSLog(@"audioMode: %@", audioMode);
    
    if ([audioMode isEqualToString: @"none"]) {
        [self.avPlayer pause];
        self.soundBtn.hidden = YES;
        self.mScrubber.hidden = YES;
    } else if ([audioMode isEqualToString: @"singular"]) {
        NSLog(@"audioMode is singular");
        audioTarget = self.bookdata[@"album"][@"audio_target"];
        NSLog(@"audioTarget: %@", audioTarget);
        if (![audioTarget isKindOfClass:[NSNull class]]) {
            self.soundBtn.hidden = NO;
            self.mScrubber.hidden = NO;
        } else {
            self.mScrubber.hidden = YES;
        }
    } else if ([audioMode isEqualToString: @"plural"]) {
        [self.avPlayer pause];
        NSLog(@"audioMode is plural");
        audioTarget = self.photoArray[page][@"audio_target"];
        NSLog(@"audioTarget: %@", audioTarget);
        
        if ([audioTarget isKindOfClass: [NSNull class]]) {
            self.soundBtn.hidden = YES;
            self.mScrubber.hidden = YES;
        } else {
            self.soundBtn.hidden = NO;
            self.mScrubber.hidden = NO;
        }
    }
    
    [self changeAudioButtonImage];
    
    // Check audioTarget
    if (audioTarget == nil) {
        NSLog(@"audioTarget == nil");
        audioTarget = @"";
    } else if ([audioTarget isEqual: [NSNull null]]) {
        audioTarget = @"";
    }
    
    [self playAudio];
}

- (void)playAudio {
    if (![audioTarget isEqualToString: @""]) {
        if ([audioMode isEqualToString: @"singular"]) {
            if (self.audioSwitch) {
                if (self.avPlayer == nil) {
                    NSLog(@"avPlayer is nil, needs to be initialized");
                    [self avPlayerSetUp: audioTarget];
                } else {
                    NSLog(@"avPlayer is initialized");
                    if (isReadyToPlay) {
                        [self.avPlayer play];
                    }
                }
            }
        } else if ([audioMode isEqualToString: @"plural"]) {
            [self avPlayerSetUp: audioTarget];
        }
    } else {
        [self.avPlayer pause];
    }
}

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

-(void)assetFailedToPrepareForPlayback:(NSError *)error {
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
- (void)avPlayerSetUp: (NSString *)audioData {
    NSLog(@"avPlayerSetUp");
    
    // setup audioInterrupted
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver: self
               selector: @selector(audioInterrupted:)
                   name: AVAudioSessionInterruptionNotification
                 object: nil];
    
    // 1. Set Up URL Audio Source
    NSURL *audioUrl = [NSURL URLWithString: audioData];
    
    // 2. PlayItem Setup
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL: audioUrl
                                            options: nil];
    
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
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys {
    NSLog(@"");
    NSLog(@"prepareToPlayAsset");
    
    /* Make sure that the value of each key has loaded successfully. */
    for (NSString *thisKey in requestedKeys) {
        NSLog(@"");
        NSLog(@"thisKey: %@", thisKey);
        
        NSError *error = nil;
        AVKeyValueStatus keyStatus = [asset statusOfValueForKey: thisKey
                                                          error: &error];
        NSLog(@"keyStatus: %ld", (long)keyStatus);
        
        if (keyStatus == AVKeyValueStatusFailed) {
            NSLog(@"keyStatus == AVKeyValueStatusFailed");
            [self assetFailedToPrepareForPlayback:error];
            return;
        }
        /* If you are also implementing -[AVAsset cancelLoading], add your code here to bail out properly in the case of cancellation. */
    }
    // Use the AVAsset playable property to detect whether the asset can be played.
    if (!asset.playable) {
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
    
    // This loading audio faster feature is available iOS 10.0 not lower version
    self.avPlayer.automaticallyWaitsToMinimizeStalling = NO;
    
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
    BOOL isLooping;
    
    if ([audioMode isEqualToString: @"singular"]) {
        isLooping = [self.bookdata[@"album"][@"audio_loop"] boolValue];
        
        if (isLooping) {
            NSLog(@"Audio is looping");
            
            // The setting below is to loop audio
            self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            [self addNotification];
        } else {
            NSLog(@"Don't Loop Audio");
            self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        }
    } else if ([audioMode isEqualToString: @"plural"]) {
        isLooping = [self.photoArray[[self getCurrentPage]][@"audio_loop"] boolValue];
        
        if (isLooping) {
            NSLog(@"Audio is looping");
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
- (void)audioInterrupted:(NSNotification *)notification {
    NSLog(@"");
    NSLog(@"audioInterrupted");
    NSUInteger type = [notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
    NSUInteger option = [notification.userInfo[AVAudioSessionInterruptionOptionKey] intValue];
    
    if (type == AVAudioSessionInterruptionTypeBegan) {
        NSLog(@"Audio Interruption");
    } else if (type == AVAudioSessionInterruptionTypeBegan) {
        if (option == AVAudioSessionInterruptionTypeEnded) {
            NSLog(@"Interruption Ended");
            
            if (self.audioSwitch) {
                if (isReadyToPlay) {
                    [NSThread sleepForTimeInterval: 0.1];
                    if (videoIsPlaying) {
                        [self.avPlayer pause];
                    } else {
                        [self.avPlayer play];
                    }
                }
            }
        }
    }
}

#pragma mark - AVPlayer Notification
- (void)addNotification {
    NSLog(@"");
    NSLog(@"addNotification");
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(playerItemDidReachEnd:)
                                                 name: AVPlayerItemDidPlayToEndTimeNotification
                                               object: self.avPlayerItem];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    seekToZeroBeforePlay = YES;
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        //        NSLog(@"Seek To Time kCMTimeZero");
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
        switch (self.avPlayer.status) {
            case AVPlayerStatusUnknown:
            {
                NSLog(@"AVPlayerStatusUnknown");
                isReadyToPlay = NO;
                [self syncScrubber];
                [self disableScrubber];
            }
                break;
            case AVPlayerStatusReadyToPlay:
            {
                isReadyToPlay = YES;
                [self initScrubberTimer];
                [self enableScrubber];
                
                if (self.audioSwitch) {
                    if (self.avPlayer != nil) {
                        NSLog(@"avPlayer is initialized");
                        if (isReadyToPlay) {
                            NSLog(@"self.isReadyToPlay is set to YES");
                            
                            if (videoIsPlaying) {
                                [self.avPlayer pause];
                            } else {
                                [self.avPlayer play];
                                NSLog(@"self.avPlayer play");
                            }
                        } else {
                            NSLog(@"self.isReadyToPlay is set to NO");
                        }
                    }
                } else {
                    [self.avPlayer pause];
                    NSLog(@"self.avPlayer pause");
                }
            }
                break;
            case AVPlayerStatusFailed:
            {
                NSLog(@"AVPlayerStatusFailed");
                isReadyToPlay = NO;
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback: playerItem.error];
            }
            default:
                break;
        }
    } else if (context == AVPlayerDemoPlaybackViewControllerRateObservationContext) {
        NSLog(@"context == AVPlayerDemoPlaybackViewControllerRateObservationContext");
    } else {
        NSLog(@"else");
        [super observeValueForKeyPath: keyPath
                             ofObject: object
                               change: change
                              context: context];
    }
}

#pragma mark - Movie scrubber control
/* ---------------------------------------------------------
 **  Methods to handle manipulation of the movie scrubber control
 ** ------------------------------------------------------- */

/* Requests invocation of a given block during media playback to update the movie scrubber control. */
- (void)initScrubberTimer {
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
    __weak ContentCheckingViewController *weakSelf = self;
    mTimeObserver = [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                                queue:NULL /* If you pass NULL, the main queue is used. */
                                                           usingBlock:^(CMTime time)
                     {
                         //                         NSLog(@"call syncScrubber in Block of initScrubberTimer");
                         [weakSelf syncScrubber];
                     }];
}

/* Set the scrubber based on the player current time. */
- (void)syncScrubber {
    //    NSLog(@"");
    //    NSLog(@"syncScrubber");
    
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration)) {
        //        NSLog(@"CMTIME_IS_INVALID(playerDuration)");
        self.mScrubber.minimumValue = 0.0;
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration)) {
        float minValue = [self.mScrubber minimumValue];
        float maxValue = [self.mScrubber maximumValue];
        double time = CMTimeGetSeconds([self.avPlayer currentTime]);
        
        [self.mScrubber setValue:(maxValue - minValue) * time / duration + minValue];
    }
}

/* The user is dragging the movie controller thumb to scrub through the movie. */
- (IBAction)beginScrubbing:(id)sender {
    NSLog(@"");
    NSLog(@"beginScrubbing");
    
    mRestoreAfterScrubbingRate = [self.avPlayer rate];
    [self.avPlayer setRate: 0.f];
    
    // Remove previous timer
    [self removePlayerTimeObserver];
}

/* Set the player current time to match the scrubber position. */
- (IBAction)scrub:(id)sender {
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
            __block typeof(self) wself = self;
            [self.avPlayer seekToTime: CMTimeMakeWithSeconds(time, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"isSeeking = NO");
                    wself->isSeeking = NO;
                });
            }];
        }
    }
}

/* The user has released the movie thumb control to stop scrubbing through the movie. */
- (IBAction)endScrubbing:(id)sender {
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
            
            __weak ContentCheckingViewController *weakSelf = self;
            mTimeObserver = [self.avPlayer addPeriodicTimeObserverForInterval: CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC) queue: NULL usingBlock:^(CMTime time) {
                //NSLog(@"call syncScrubber in Block of endScrubbing method");
                [weakSelf syncScrubber];
            }];
        }
    }
    
    if (mRestoreAfterScrubbingRate) {
        [self.avPlayer setRate: mRestoreAfterScrubbingRate];
        mRestoreAfterScrubbingRate = 0.f;
    }
}

- (void)enableScrubber {
    NSLog(@"");
    NSLog(@"enableScrubber");
    self.mScrubber.enabled = YES;
}

- (void)disableScrubber {
    NSLog(@"");
    NSLog(@"disableScrubber");
    self.mScrubber.enabled = NO;
}

/* ---------------------------------------------------------
 **  Get the duration for a AVPlayerItem.
 ** ------------------------------------------------------- */

- (CMTime)playerItemDuration {
    //    NSLog(@"");
    //    NSLog(@"playerItemDuration");
    
    AVPlayerItem *playerItem = [self.avPlayer currentItem];
    
    if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
        return ([playerItem duration]);
    }
    return (kCMTimeInvalid);
}

/* Cancels the previously registered time observer. */
/* Cancels the previously registered time observer. */
-(void)removePlayerTimeObserver {
    NSLog(@"");
    NSLog(@"removePlayerTimeObserver");
    
    if (mTimeObserver) {
        [self.avPlayer removeTimeObserver: mTimeObserver];
        mTimeObserver = nil;
    }
}

#pragma mark - Location Btn
- (void)checkLocationBtn:(NSInteger)page {
    NSLog(@"checkLocationBtn");
    //    NSInteger page = [self getCurrentPage];
    NSString *location = self.photoArray[page][@"location"];
    NSLog(@"location: %@", location);
    
    if ([wTools objectExists:self.photoArray[page][@"location"]]){
        
        if (![location isEqualToString: @""]) {
            self.locationBtn.hidden = NO;
            return;
            
        }
    }
    
    self.locationBtn.hidden = YES;
    
}
#pragma mark - Autoplay
- (void)checkAutoPlay {
    self.autoplayViewConstraint.constant = 0;
    self.autoplayView.hidden = YES;
    self.playThrough = 0;
    for (NSDictionary *p in self.photoArray) {
        if (p[@"duration"] && ![p[@"duration"] isKindOfClass:[NSNull class]]) {
            NSInteger t = [p[@"duration"] integerValue];
            if ( t != 0) {
                self.autoplayViewConstraint.constant = 56;
                self.autoplayView.hidden = NO;
                if (p == [self.photoArray firstObject]) {
                    [self switchAutoPlay:self.autoplay];
                }
                break;
            }
            
        }
    }
}
- (void)postProcessAutoplay:(NSNumber *)p{
    //xNSInteger p0 = [p integerValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self scrollViewDidEndDecelerating:self.imageScrollCV];
    });
}
- (void)processAutoplayTime:(NSTimeInterval )tick {
    self.playThrough += (tick - self.playStart);
    self.playStart = tick;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger p = [self getCurrentPage];
        NSDictionary *photo = self.photoArray[p];
        NSInteger duration = [photo[@"duration"] integerValue];
        if (self.playThrough >= duration && (p+1) < self.photoArray.count) {
            
            [self.imageScrollCV scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:p+1 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
            
            photo = self.photoArray[p+1];
            
            
            [self performSelector:@selector(postProcessAutoplay:) withObject:[NSNumber numberWithInteger:p+1] afterDelay:0.5];
            self.playThrough = 0;
            
            
            duration = [photo[@"duration"] integerValue];
            if (duration == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self switchAutoPlay:self.autoplay];
                });
                self.playThrough = 0;
                self.playStart = 0;
                return;
            }
        } else if (p+1 >= self.photoArray.count) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self switchAutoPlay:self.autoplay];
            });
            self.playThrough = 0;
            self.playStart = 0;
        }
    });
}
- (void) setupAutoplayProcess {
    if (self.autoplayTimer) {
        dispatch_cancel(self.autoplayTimer);
        self.autoplayTimer = nil;
    } else {
        self.autoplayQueue = dispatch_queue_create("com.pinpinbox.autoplay" , 0);
    }
    self.playStart = [[NSDate date] timeIntervalSinceReferenceDate];
    self.autoplayTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,self.autoplayQueue);
    dispatch_source_set_timer(self.autoplayTimer, dispatch_walltime(NULL, 0), 0.5 * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
    __block typeof(self) wself = self;
    dispatch_source_set_event_handler(self.autoplayTimer, ^{
        //NSLog(@"dispatch_source_set_event_handler %lf", [[NSDate date] timeIntervalSinceReferenceDate]);
        [wself processAutoplayTime:[[NSDate date] timeIntervalSinceReferenceDate] ];
    });
    dispatch_resume(self.autoplayTimer);
}

- (void)stopTimer {
    if (self.autoplayTimer)
        dispatch_cancel(self.autoplayTimer);
    self.autoplayTimer = nil;
}
#pragma mark - Help Method for DailyMotion
- (NSDictionary *)queryDictionaryFromString:(NSString *)queryString {
    if ([queryString hasPrefix:@"&"] || [queryString hasPrefix:@"?"]) {
        queryString = [queryString substringFromIndex:1];
    }
    NSString *urlString = [NSString stringWithFormat:@"http://www.dailymotion.com?%@", queryString];
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:urlString];
    
    NSMutableDictionary *queryDictionary = [NSMutableDictionary dictionary];
    for (NSURLQueryItem *queryItem in urlComponents.queryItems) {
        [queryDictionary setObject:queryItem.value forKey:queryItem.name];
    }
    
    return queryDictionary;
}

#pragma mark -
- (void)checkVideo:(NSInteger)page {
    NSLog(@"checkVideo");
    NSString *refer = self.photoArray[page][@"video_refer"];
    useFor = self.photoArray[page][@"usefor"];
    NSLog(@"useFor: %@", useFor);
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem: page inSection: 0];
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[self.imageScrollCV cellForItemAtIndexPath: indexPath];
    
    
    // Reset
    [self.videoPlayer pause];
    
    if (![wTools objectExists: useFor]) {
        return;
    }
    if ([useFor isEqualToString: @"video"]) {
        cell.videoBtn.hidden = NO;
        if ([refer isEqualToString: @"file"] || [refer isEqualToString: @"system"]) {
            [self performSelector:@selector(deferedPlayVideo:) withObject:@[cell, [NSNumber numberWithInteger:page]] afterDelay:0.3];
            //[self playUploadedVideo: cell page: page];
        }
    }
    
    
}
- (void)deferedPlayVideo:(NSArray *)params {
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *) params[0];
    NSNumber *n = params[1];
    NSInteger page = [n integerValue];
    
    [self playUploadedVideo: cell page: page];
}
#pragma mark - Embedded videos
- (void)playEmbeddedVideo:(ImageCollectionViewCell *)cell
                     page:(NSInteger)page {
    NSURL *url = [NSURL URLWithString: self.photoArray[page][@"video_target"]];
    NSLog(@"url: %@", url);
    NSLog(@"scheme: %@", [url scheme]);
    NSLog(@"host: %@", [url host]);
    NSLog(@"port: %@", [url port]);
    NSLog(@"path: %@", [url path]);
    NSLog(@"path components: %@", [url pathComponents]);
    NSLog(@"parameterString: %@", [url parameterString]);
    NSLog(@"query: %@", [url query]);
    NSLog(@"fragment: %@", [url fragment]);
    
    if (!([[url host] rangeOfString: @"dailymotion"].location == NSNotFound)) {
        NSLog(@"url host is dailymotion");
        //        NSString *urlString = self.photoArray[page][@"video_target"];
        DMViewController *dmVC = [[UIStoryboard storyboardWithName: @"DMVC" bundle: nil] instantiateViewControllerWithIdentifier: @"DMViewController"];
        dmVC.baseURL = @"http://www.dailymotion.com";
        dmVC.videoID = [url.pathComponents lastObject];
        dmVC.additionalParameters = [self queryDictionaryFromString: @"fullscreen-action=trigger_event&autoplay=1"];
        self.navigationController.delegate = nil;
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.myNav pushViewController: dmVC animated: YES];
    } else if (!([[url host] rangeOfString: @"vimeo"].location == NSNotFound)) {
        NSString *path = self.photoArray[page][@"video_target"];
        ThirdPartyVideoPlayerViewController *v =  [[UIStoryboard storyboardWithName: @"3rdPartyVideoPlayerVC" bundle: nil] instantiateViewControllerWithIdentifier: @"ThirdPartyVideoPlayer"];
        
        //self.isPresentingOrPushingVC = YES;
        
        [self updatePageBeforePresentingOrPushing];
        [self presentViewController:v animated:YES completion:^{
            [v setVideoPath:path];
        }];
    } else if (!([[url host] rangeOfString: @"facebook"].location == NSNotFound)) {

        NSString *path = self.photoArray[page][@"video_target"];
        ThirdPartyVideoPlayerViewController *v =  [[UIStoryboard storyboardWithName: @"3rdPartyVideoPlayerVC" bundle: nil] instantiateViewControllerWithIdentifier: @"ThirdPartyVideoPlayer"];
        
        //self.isPresentingOrPushingVC = YES;
        
        [self updatePageBeforePresentingOrPushing];
        [self presentViewController:v animated:YES completion:^{
            [v setVideoPath:path];
        }];
        
    } else if (!([[url host] rangeOfString: @"youtube"].location == NSNotFound) || !([[url host] rangeOfString: @"youtu.be"].location == NSNotFound)) {
        NSString *path = self.photoArray[page][@"video_target"];
        [self updatePageBeforePresentingOrPushing];
        ThirdPartyVideoPlayerViewController *v =  [[UIStoryboard storyboardWithName: @"3rdPartyVideoPlayerVC" bundle: nil] instantiateViewControllerWithIdentifier: @"ThirdPartyVideoPlayer"];
        
        [self presentViewController:v animated:YES completion:^{
            [v setVideoPath:path];
        }];
    }
    videoIsPlaying = YES;
    [self.avPlayer pause];
    self.mScrubber.hidden = YES;
}

- (void)checkFBSDK:(ImageCollectionViewCell *)cell
               url:(NSURL *)url {
    NSLog(@"checkFBSDK");
    NSLog(@"url: %@", url);
    
    // Section Below is to check FBSDK
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
        self.isPresentingOrPushingVC = YES;
        __block typeof(self) wself = self;
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath: videoStr parameters: @{@"fields" : @"id,source"} HTTPMethod: @"GET"];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            NSLog(@"FBSDKGraphRequest startWithCompletionHandler");
            
            if (connection) {
                //fbVideoUrl = url;
                [wself setFBVidURL:url];
                NSLog(@"url: %@", url);
                
                if ([url isEqual: [NSNull null]]) {
                    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                    style.messageColor = [UIColor whiteColor];
                    style.backgroundColor = [UIColor thirdPink];
                    
                    [wself.view makeToast: @"FB影片連結有錯誤"
                                 duration: 2.0
                                 position: CSToastPositionBottom
                                    style: style];
                } else {
                    [wself openSafari: url];
                }
            } else if (!connection) {
                NSLog(@"Get Video Error");
                CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                style.messageColor = [UIColor whiteColor];
                style.backgroundColor = [UIColor thirdPink];
                
                [wself.view makeToast: @"FB影片連結有錯誤"
                             duration: 2.0
                             position: CSToastPositionBottom
                                style: style];
            }
        }];
    } else {
        NSLog(@"");
        NSLog(@"FBSDKAccessToken currentAccessToken is not TRUE");
        NSLog(@"login with permissions");
        self.isPresentingOrPushingVC = YES;
        __block typeof(self) wself = self;
        
        // Try to login with permissions
        [self loginAndRequestPermissionsWithSuccessHandler:^{
            NSLog(@"loginAndRequestPermissionsWithSuccessHandler");
            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath: videoStr parameters: @{@"fields" : @"id,source"} HTTPMethod: @"GET"];
            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                NSLog(@"FBSDKGraphRequest startWithCompletionHandler");
                
                if (connection) {
                    //fbVideoUrl = url;
                    [wself setFBVidURL:url];
                    NSLog(@"url: %@", url);
                    
                    if ([url isEqual: [NSNull null]]) {
                        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                        style.messageColor = [UIColor whiteColor];
                        style.backgroundColor = [UIColor thirdPink];
                        
                        [wself.view makeToast: @"FB影片連結有錯誤"
                                     duration: 2.0
                                     position: CSToastPositionBottom
                                        style: style];
                    } else {
                        [wself openSafari: url];
                    }
                } else if (!connection) {
                    NSLog(@"Get Video Error");
                    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                    style.messageColor = [UIColor whiteColor];
                    style.backgroundColor = [UIColor thirdPink];
                    
                    [wself.view makeToast: @"FB影片連結有錯誤"
                                 duration: 2.0
                                 position: CSToastPositionBottom
                                    style: style];
                }
            }];
        } declinedOrCanceledHandler:^{
            NSLog(@"declinedOrCanceledHandler");
            // If the user declined permissions tell them why we need permissions
            // and ask for permissions again if they want to grant permissions.
            [wself alertDeclinedPublishActionsWithCompletion:^{
                [wself loginAndRequestPermissionsWithSuccessHandler: nil
                                          declinedOrCanceledHandler: nil
                                                       errorHandler:^(NSError * error) {
                                                           NSLog(@"Error: %@", error.description);
                                                       }];
            }];
        } errorHandler:^(NSError *error) {
            NSLog(@"Error: %@", error.description);
        }];
    }
}

- (void)setFBVidURL:(NSURL *)url {
    self.fbVideoUrl = url;//[url mutableCopy];
}

#pragma mark - FaceBook Handler Methods
- (void)loginAndRequestPermissionsWithSuccessHandler:(FBBlock) successHandler
                           declinedOrCanceledHandler:(FBBlock) declinedOrCanceledHandler
                                        errorHandler:(void (^)(NSError *)) errorHandler {
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

- (void)alertDeclinedPublishActionsWithCompletion:(FBBlock)completion {
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

- (IBAction)videoBtnPressed:(id)sender {
    NSLog(@"videoBtnPressed");
    NSInteger page = [self getCurrentPage];
    NSString *refer = self.photoArray[page][@"video_refer"];
    useFor = self.photoArray[page][@"usefor"];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem: page inSection: 0];
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[self.imageScrollCV cellForItemAtIndexPath: indexPath];
    
    if (![wTools objectExists: useFor]) {
        return;
    }
    
    if ([useFor isEqualToString: @"video"]) {
        if ([refer isEqualToString: @"embed"]) {
            [self playEmbeddedVideo: cell page: page];
        }
    }
}

//- (IBAction)fbVideoBtnPressed:(id)sender {
//    NSLog(@"fbVideoBtnPressed");
//    NSLog(@"fbVideoUrl: %@", fbVideoUrl);
//
//    if (fbVideoUrl == nil) {
//        NSLog(@"fbVideoUrl == nil");
//        NSURL *url = [NSURL URLWithString: self.photoArray[[self getCurrentPage]][@"video_target"]];
//        NSIndexPath *indexPath = [NSIndexPath indexPathForItem: [self getCurrentPage] inSection: 0];
//        ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[self.imageScrollCV cellForItemAtIndexPath: indexPath];
//        [self checkFBSDK:cell url: url];
//    } else {
//        [self openSafari: fbVideoUrl];
//    }
//}

- (void)openSafari: (NSURL *)url {
    NSLog(@"openSafari");
    NSLog(@"url: %@", url);

    if (![wTools objectExists: url]) {
        return;
    }

    self.isPresentingOrPushingVC = YES;

    [self updatePageBeforePresentingOrPushing];

    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: url entersReaderIfAvailable: NO];
    safariVC.preferredBarTintColor = [UIColor whiteColor];
    [self presentViewController: safariVC animated: YES completion: nil];
}

#pragma mark - Play Uploaded Video
- (void)playUploadedVideo:(ImageCollectionViewCell *)cell
                     page:(NSInteger)page {
    NSLog(@"playUploadedVideo");
    NSURL *videoUrl = [NSURL URLWithString: self.photoArray[page][@"video_target"]];
    
    if (![wTools objectExists: videoUrl]) {
        return;
    }
    
    [self setupVideoPlayer: cell
                  videoUrl: videoUrl
                  platform: @"general"];
}

#pragma mark - Setup Video Player
- (void)listenAVPlayerError:(NSNotification *)n {
    NSLog(@"AVPlayerItemNewErrorLogEntryNotification \n %@ \n", n.userInfo);
}

- (void)setupVideoPlayer:(ImageCollectionViewCell *)cell
                videoUrl:(NSURL *)videoUrl
                platform:(NSString *)platform {
    NSLog(@"setupVideoPlayer");
    NSLog(@"platform: %@", platform);
    //    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL: videoUrl];
    //    NSLog(@"playerItem: %@", playerItem);
    
    videoIsPlaying = YES;
    cell.videoBtn.hidden = YES;
    [self.avPlayer pause];
    self.mScrubber.hidden = YES;
    
    self.videoPlayerItem = [AVPlayerItem playerItemWithURL: videoUrl];
    
    if (!self.videoPlayer) {
        NSLog(@"self.videoPlayer is not initialized");
        self.videoPlayer = [AVPlayer playerWithPlayerItem: self.videoPlayerItem];
        self.videoPlayer.automaticallyWaitsToMinimizeStalling = NO;
    } else {
        NSLog(@"self.videoPlayer is initialized");
        self.videoPlayer.automaticallyWaitsToMinimizeStalling = NO;
        [self.videoPlayer replaceCurrentItemWithPlayerItem: self.videoPlayerItem];
    }
    if (!self.videoPlayerViewController) {
        NSLog(@"self.videoPlayerViewController is initialized");
        self.videoPlayerViewController = [AVPlayerViewController new];
        self.videoPlayerViewController.player = self.videoPlayer;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenAVPlayerError:) name:AVPlayerItemNewErrorLogEntryNotification object:nil];
    
    self.videoPlayerViewController.view.frame = CGRectMake(0, 40, cell.videoView.bounds.size.width, cell.videoView.bounds.size.height - 40);
    self.videoPlayerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.videoPlayerViewController.view.center = cell.videoView.center;
    self.videoPlayerViewController.videoGravity = AVLayerVideoGravityResizeAspect;
    //    [self.videoPlayerViewController.view sizeToFit];
    
    for (UIView *view in cell.videoView.subviews) {
        [view removeFromSuperview];
    }
    
    
    [self addChildViewController:self.videoPlayerViewController];
    [cell.videoView addSubview: self.videoPlayerViewController.view];
    [self.videoPlayerViewController didMoveToParentViewController:self];
    [self.videoPlayer play];
    
    // Delay below is to avoid the previous video shows up
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        cell.videoView.hidden = NO;
        self.videoPlayerViewController.view.hidden = NO;
    });
    
    if (![platform isEqualToString: @"general"]) {
        NSLog(@"platform is not equal to general");
        NSLog(@"self.videoPlayer pause");
        [self.videoPlayer pause];
    }
}

#pragma mark -
- (void)buyAlbum {
    NSLog(@"buyAlbum");
    [self.activityIndicatorView startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI buyalbum: [wTools getUserID]
                                        token: [wTools getUserToken]
                                      albumid: self.albumId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicatorView stopAnimating];
            
            if (response != nil) {
                NSLog(@"response: %@", response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ContentCheckingViewController");
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
                    
                    if ([dic[@"result"] intValue] == 1) {
                        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                        style.messageColor = [UIColor whiteColor];
                        style.backgroundColor = [UIColor firstMain];
                        
                        [self.view makeToast: @"成功加入收藏"
                                    duration: 2.0
                                    position: CSToastPositionBottom
                                       style: style];
                        
                        [self own];
                        [self retrieveAlbum];
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗：%@",dic[@"message"]);
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

- (void)getPoint: (NSString *)pointStr {
    NSLog(@"getPoint");
    [self.activityIndicatorView startAnimating];
    
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI geturpoints: [wTools getUserID] token: [wTools getUserToken]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicatorView stopAnimating];
            
            if (response != nil) {
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ContentCheckingViewController");
                    NSLog(@"getPoint pointStr");
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                     protocolName: @"getPoint"
                                         pointStr: pointStr
                                              btn: nil
                                              bgV: nil];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        if (![wTools objectExists: dic[@"data"]]) {
                            return;
                        }
                        NSInteger point = [dic[@"data"] integerValue];
                        NSLog(@"point: %ld", (long)point);
                        NSLog(@"albumPoint: %ld", (long)wself->albumPoint);
                        
                        if (point >= wself->albumPoint) {
                            NSLog(@"point is bigger than albumPoint");
                            [wself newBuyAlbum: pointStr];
                        } else {
                            NSLog(@"point is not enough");
                            [wself showBuyAlbumCustomAlert: @"你的P點不足，前往購點?" option: @"buyPoint" pointStr: @""];
                        }
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗：%@",dic[@"message"]);
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

- (void)newBuyAlbum: (NSString *)pointStr {
    [self.activityIndicatorView startAnimating];
    NSMutableDictionary *rewardDic;
    NSData *jsonData;
    NSString *jsonStr;
    
    if (rewardAfterCollect) {
        rewardDic = [NSMutableDictionary new];
        [rewardDic setObject: nameTextView.text forKey: @"recipient"];
        [rewardDic setObject: phoneTextView.text forKey: @"recipient_tel"];
        [rewardDic setObject: addressTextView.text forKey: @"recipient_address"];
        jsonData = [NSJSONSerialization dataWithJSONObject: rewardDic options: 0 error: nil];
        jsonStr = [[NSString alloc] initWithData: jsonData encoding: NSUTF8StringEncoding];
    } else {
        jsonStr = nil;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI newBuyAlbum: [wTools getUserID]
                                           token: [wTools getUserToken]
                                         albumId: self.albumId
                                        platform: @"apple"
                                           point: pointStr
                                          reward: jsonStr];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicatorView stopAnimating];
            
            if (response != nil) {
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ContentCheckingViewController");
                    NSLog(@"newBuyAlbum pointStr");
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"newBuyAlbum"
                                        pointStr: pointStr
                                             btn: nil
                                             bgV: nil];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    NSString *resultStr = dic[@"result"];
                    NSLog(@"resultStr: %@", resultStr);
                    
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
                    } else if ([resultStr isEqualToString: @"USER_ERROR"]) {
                        NSLog(@"resultStr isEqualToString USER_ERROR");
                        if ([wTools objectExists: dic[@"message"]]) {
                            [self showCustomErrorAlert: dic[@"message"]];
                        } else {
                            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                        }
                    } else if ([resultStr isEqualToString: @"USER_OWNS_THE_ALBUM"]) {
                        NSLog(@"resultStr isEqualToString USER_OWNS_THE_ALBUM");
                        if ([wTools objectExists: dic[@"message"]]) {
                            [self showCustomErrorAlert: dic[@"message"]];
                        } else {
                            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                        }
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

- (void)getMapAPI {
    // Location
    NSString *location = self.bookdata[@"album"][@"location"];
    //NSLog(@"location: %@", location);
    
    if (![wTools objectExists: location]) {
        return;
    }
    
    if (![location isEqualToString:@""]) {
//        [wTools ShowMBProgressHUD];
        __block typeof(self) wself = self;
        NSLog(@"Model Name %@",[UIDevice deviceModelName]);
        [MapHelper searchLocation:location CompletionBlock:^(MKMapItem * _Nullable item, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
//                [wTools HideMBProgressHUD];
            });
            if (!error && item) {
                NSDictionary *result = @{@"mapitem" : item};
                [wself setLocdata:result];
            }
        }];
    }
}

- (void)setLocdata:(NSDictionary *)dic {
    locdata = [dic mutableCopy];
    NSLog(@"locdata: %@", locdata);
}

#pragma mark - Check Point Task
- (void)checkTaskComplete {
    NSLog(@"checkTask");
    [self.activityIndicatorView startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSString *response = [boxAPI checkTaskCompleted: [wTools getUserID]
                                                  token: [wTools getUserToken]
                                               task_for: @"share_to_fb"
                                               platform: @"apple"
                                                   type: @"album"
                                                 typeId: self.albumId];
        
//        NSString *response = [boxAPI checkTaskCompleted: [wTools getUserID]
//                                                  token: [wTools getUserToken]
//                                               task_for: @"share_to_fb"
//                                               platform: @"apple"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicatorView stopAnimating];
            
            if (response != nil) {
                //NSLog(@"%@", response);
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ContentCheckingViewController");
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
                            message = [NSString stringWithFormat: sharingLinkWithAutoPlay, self.albumId, autoPlayStr];
                        } else {
                            message = [NSString stringWithFormat: sharingLinkWithoutAutoPlay, self.albumId];
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
                            message = [NSString stringWithFormat: sharingLinkWithAutoPlay, self.albumId, autoPlayStr];
                        } else {
                            message = [NSString stringWithFormat: sharingLinkWithoutAutoPlay, self.albumId];
                        }
                        
                        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems: [NSArray arrayWithObjects: message, nil] applicationActivities: nil];
                        [self presentViewController: activityVC animated: YES completion: nil];
                    } else {
                        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}

- (void)insertAlbumToLikes {
    NSLog(@"insertAlbumToLikes");
    [self.activityIndicatorView startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI insertAlbum2Likes: [wTools getUserID]
                                                 token: [wTools getUserToken]
                                               albumId: self.albumId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicatorView stopAnimating];
            
            if (response != nil) {
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ContentCheckingViewController");
                    NSLog(@"insertAlbumToLikes");
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"insertAlbum2Likes"
                                        pointStr: @""
                                             btn: nil
                                             bgV: nil];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        [self.likeBtn setImage: [UIImage imageNamed: @"ic200_ding_pink"] forState: UIControlStateNormal];
                        self.isLikes = !self.isLikes;
                        NSLog(@"self.isLikes: %d", self.isLikes);
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗：%@", dic[@"message"]);
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

- (void)deleteAlbumToLikes {
    NSLog(@"deleteAlbumToLikes");
    [self.activityIndicatorView startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI deleteAlbum2Likes: [wTools getUserID]
                                                 token: [wTools getUserToken]
                                               albumId: self.albumId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicatorView stopAnimating];
            
            if (response != nil) {
                //NSLog(@"response: %@", response);
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ContentCheckingViewController");
                    NSLog(@"deleteAlbumToLikes");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"deleteAlbum2Likes"
                                        pointStr: @""
                                             btn: nil
                                             bgV: nil];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        [self.likeBtn setImage: [UIImage imageNamed: @"ic200_ding_white"] forState: UIControlStateNormal];
                        self.isLikes = !self.isLikes;
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗：%@", dic[@"message"]);
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
    [self.activityIndicatorView startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI geturpoints: [userPrefs objectForKey:@"id"]
                                           token: [userPrefs objectForKey:@"token"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicatorView stopAnimating];
            
            if (response != nil) {
                NSLog(@"response from geturpoints");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ContentCheckingViewController");
                    NSLog(@"getUrPoints");
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"geturpoints"
                                        pointStr: @""
                                             btn: nil
                                             bgV: nil];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"dic result boolValue is 1");
                        if (![wTools objectExists: dic[@"data"]]) {
                            return;
                        }
                        NSInteger point = [dic[@"data"] integerValue];
                        [userPrefs setObject: [NSNumber numberWithInteger: point] forKey: @"pPoint"];
                        [userPrefs synchronize];
                        
                        // For Point Activity
                        [self checkAlbumCollectTask];
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗：%@",dic[@"message"]);
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

- (void)checkAlbumCollectTask {
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
        [self.activityIndicatorView startAnimating];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI doTask2: [wTools getUserID]
                                       token: [wTools getUserToken]
                                    task_for: wself->task_for
                                    platform: @"apple"
                                        type: @"album"
                                     type_id: wself.albumId];
        
        NSLog(@"User ID: %@", [wTools getUserID]);
        NSLog(@"Token: %@", [wTools getUserToken]);
        NSLog(@"Task_For: %@", wself->task_for);
        NSLog(@"Album ID: %@", wself.albumId);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [self.activityIndicatorView stopAnimating];
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
                    NSLog(@"ContentCheckingViewController");
                    NSLog(@"checkPoint");
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                     protocolName: @"doTask2"
                                         pointStr: @""
                                              btn: nil
                                              bgV: nil];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    //NSLog(@"data: %@", data);
                    [wself processCheckPoint:data];
                }
            }
        });
    });
}

- (void)processCheckPoint:(NSDictionary *)data {
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
        
        [self showAlertViewForGettingPoint];
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
    } else {
        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
    }
}

- (void)saveCollectInfoToDevice: (BOOL)isCollect {
    if ([task_for isEqualToString: @"collect_free_album"]) {
        // Save data for first collect album
        BOOL collect_free_album = isCollect;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject: [NSNumber numberWithBool: collect_free_album]
                     forKey: @"collect_free_album"];
        [defaults synchronize];
    } else if ([task_for isEqualToString: @"collect_pay_album"]) {
        // Save data for first collect paid album
        BOOL collect_pay_album = isCollect;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject: [NSNumber numberWithBool: collect_pay_album]
                     forKey: @"collect_pay_album"];
        [defaults synchronize];
    }
}

- (void)own {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary: self.bookdata];
    NSMutableDictionary *album = [[NSMutableDictionary alloc] initWithDictionary: self.bookdata[@"album"]];
    [album setObject: [NSNumber numberWithBool: YES] forKey: @"own"];
    [dictionary setObject: album forKey: @"album"];
    self.bookdata = dictionary;
    [self keepOwnedAlbumLocal:self.albumId];
}
- (void)keepOwnedAlbumLocal:(NSString *)aid {
    if (aid) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:aid forKey:@"keepOwnedAlbumLocal"];
        [defaults synchronize];
    }
}
- (void)checkIsOwnedOrNot:(NSDictionary *)dic {
    NSLog(@"checkIsOwnedOrNot");
    self.bookdata = [dic mutableCopy];
    
    if ([wTools objectExists: self.bookdata[@"album"][@"own"]]) {
        self.isOwned = [self.bookdata[@"album"][@"own"] boolValue];
        NSLog(@"self.isOwned: %d", self.isOwned);
        
        if (!self.isOwned) {
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
            
            [self.photoArray addObject: collectDic];
        }
    }
}

- (void)updateOldCurrentPage:(NSUInteger)currentPage {
    NSLog(@"updateOldCurrentPage");
    NSLog(@"currentPage: %lu", (unsigned long)currentPage);
    NSLog(@"self.photoArray.count: %lu", (unsigned long)self.photoArray.count);
    oldCurrentPage = currentPage;
    NSLog(@"currentPage: %lu", (unsigned long)currentPage);
    
    if (!self.isOwned) {
        if (oldCurrentPage == self.photoArray.count - 1) {
            // if the oldCurrentPage didn't minus 1, then it will be crashed when collect function called
            oldCurrentPage -= 1;
            NSLog(@"oldCurrentPage: %lu", (unsigned long)oldCurrentPage);
        }
    }
    if (currentPage < self.photoArray.count) {
        NSDictionary *photo = self.photoArray[currentPage];
        if (photo && ![photo[@"duration"] isKindOfClass:[NSNull class]]) {
            NSInteger t = [photo[@"duration"] integerValue];
            self.playThrough = 0;
            self.playStart = 0;
            if (t){
                if (self.autoplayTimer == nil)
                    [self switchAutoPlay:self.autoplay];
                else
                    self.playStart = [[NSDate date] timeIntervalSinceReferenceDate];
            } else if (self.autoplayTimer ){
                [self switchAutoPlay:self.autoplay];
            }
        }
    }
}

- (NSInteger)getCurrentPage {
    
    NSInteger page = self.imageScrollCV.contentOffset.x / self.imageScrollCV.frame.size.width;
    return page;
}

#pragma mark - Check Slot Info
- (void)checkSlotAndExchangeInfo:(NSInteger)page {
    NSLog(@"");
    NSLog(@"checkSlotAndExchangeInfo");
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem: page inSection: 0];
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[self.imageScrollCV cellForItemAtIndexPath: indexPath];
    useFor = self.photoArray[page][@"usefor"];
    NSLog(@"useFor: %@", useFor);
    NSLog(@"cell.giftViewBgV: %@", cell.giftViewBgV);
    cell.alphaBgV.hidden = YES;
        
//    cell.giftImageBtn.hidden = YES;
//    cell.giftViewBgV.hidden = YES;
//    cell.giftViewBgV.alpha = 0;
    cell.checkCollectionLayout.hidden = YES;
    
    if (![wTools objectExists: useFor]) {
        return;
    }
    
    if ([useFor isEqualToString: @"slot"]) {
        NSLog(@"");
        NSLog(@"useFor is equal to slot");
        cell.alphaBgV.hidden = NO;
        
        if (self.isOwned) {
            NSLog(@"Owned this album");
            cell.checkCollectionLayout.hidden = YES;
            [self checkSlotDataInDatabaseOrNot];
            
            BOOL slotted = NO;
            
            if (![wTools objectExists: self.slotArray]) {
                return;
            }
            for (int i = 0; i < self.slotArray.count; i++) {
                NSManagedObject *slotData = [self.slotArray objectAtIndex: i];
                NSLog(@"photoId: %ld", (long)[[slotData valueForKey: @"photoId"] integerValue]);
                
                NSLog(@"slotData photoId: %d", [[slotData valueForKey: @"photoId"] intValue]);
                NSLog(@"self.photoArray page photo_id: %d", [self.photoArray[page][@"photo_id"] intValue]);
                
                if ([[slotData valueForKey: @"photoId"] integerValue] == [self.photoArray[page][@"photo_id"] integerValue]) {
                    slotted = YES;
                }
            }
            NSLog(@"slotted: %d", slotted);
            if (slotted) {
//                [self slotPhotoUseFor: cell.giftViewBgV indexPathRow: page];
                [self slotPhotoUseFor: cell.giftViewBgV
                                 cell: cell
                         indexPathRow: page];
            } else {
                cell.giftImageBtn.hidden = NO;
            }
        } else {
            NSLog(@"Does not own this album");
//            cell.giftImageBtn.hidden = YES;
            cell.checkCollectionLayout.hidden = NO;
            [self createViewForCollectionCheck: page];
        }
    }
    
    if ([useFor isEqualToString: @"exchange"]) {
        NSLog(@"");
        NSLog(@"useFor is equal to exchange");
        cell.alphaBgV.hidden = NO;
        
        if (self.isOwned) {
            NSLog(@"Owned this album");
//            cell.giftViewBgV.hidden = NO;
            cell.checkCollectionLayout.hidden = YES;
            [self checkSlotDataInDatabaseOrNot];
//            [self getPhotoUseFor: cell.giftViewBgV indexPathRow: page];
            [self getPhotoUseFor: cell.giftViewBgV
                            cell: cell
                    indexPathRow: page];
        } else {
            NSLog(@"Does not own this album");
//            cell.giftViewBgV.hidden = YES;
            cell.checkCollectionLayout.hidden = NO;
            [self createViewForCollectionCheck: page];
        }
    }
}

- (void)createViewForCollectionCheck:(NSInteger)page {
    NSLog(@"");
    NSLog(@"createViewForCollectionCheck");
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem: [self getCurrentPage] inSection: 0];
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[self.imageScrollCV cellForItemAtIndexPath: indexPath];
    cell.checkCollectionLayout.hidden = NO;
    cell.giftImageBtn.hidden = YES;
    
    for (UIView *view in cell.checkCollectionLayout.subviews) {
        [view removeFromSuperview];
    }
    
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
    [cell.checkCollectionLayout addSubview: topicLabel];
    
    UIButton *collectBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    [collectBtn addTarget: self action: @selector(collectAlbum) forControlEvents: UIControlEventTouchUpInside];
    collectBtn.frame = CGRectMake(0.0, 0.0, 112.0, 48.0);
    collectBtn.myTopMargin = 8;
    collectBtn.myCenterXOffset = 0;
    collectBtn.backgroundColor = [UIColor firstMain];
    collectBtn.layer.cornerRadius = 6;
    
    NSString *btnStrForExchange;
    
    albumPoint = [self.bookdata[@"album"][@"point"] intValue];
    NSLog(@"albumPoint: %lu", (unsigned long)albumPoint);
    
    if (albumPoint == 0) {
        btnStrForExchange = @"收藏";
    } else {
        btnStrForExchange = @"贊助";
    }
    
    [collectBtn setTitle: btnStrForExchange forState: UIControlStateNormal];
    [cell.checkCollectionLayout addSubview: collectBtn];
    
    NSLog(@"cell.checkCollectionLayout: %@", cell.checkCollectionLayout);
    NSLog(@"cell.checkCollectionLayout.frame: %@", NSStringFromCGRect(cell.checkCollectionLayout.frame));
    NSLog(@"cell.checkCollectionLayout.subViews: %@", cell.checkCollectionLayout.subviews);
}

#pragma mark - To Final Page
- (void)collectAlbum {
    NSLog(@"");
    NSLog(@"collectAlbum");
    
    if (albumPoint == 0) {
        NSLog(@"pPoint == 0");
        [self buyAlbum];
    } else {
        NSLog(@"pPoint != 0");
        NSLog(@"self.photoArray.count: %lu", (unsigned long)self.photoArray.count);
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem: self.photoArray.count - 1 inSection: 0];
        NSLog(@"self.imageScrollCV: %@", self.imageScrollCV);
        [self.imageScrollCV scrollToItemAtIndexPath: indexPath atScrollPosition: UICollectionViewScrollPositionCenteredHorizontally animated: YES];
        
        NSLog(@"self.thumbnailImageScrollCV: %@", self.thumbnailImageScrollCV);
        [self.thumbnailImageScrollCV scrollToItemAtIndexPath: indexPath atScrollPosition: UICollectionViewScrollPositionCenteredHorizontally animated: YES];
    }
}

#pragma mark - Gift Image Button Action
- (void)showSlot:(UIButton *)slotBtn
     giftViewBgV:(MyLinearLayout *)giftViewBgV
            cell:(ImageCollectionViewCell *)cell
    indexPathRow:(NSInteger)indexPathRow {
    slotBtn.hidden = YES;
    
    NSMutableArray *array = [NSMutableArray new];
    
    for (int i = 1; i < 13; i++) {
        UIImage *image = [UIImage imageNamed: [NSString stringWithFormat: @"GiftImages%i.png", i]];
        [array addObject: image];
    }
    
    UIImageView *animateImageView;
    animateImageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 180, 200)];
    //    animateImageView.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
    animateImageView.center = giftViewBgV.center;
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
    
//    [self slotPhotoUseFor: giftViewBgV indexPathRow: indexPathRow];
    [self slotPhotoUseFor: giftViewBgV
                     cell: cell
             indexPathRow: indexPathRow];
}

- (void)slotPhotoUseFor:(MyLinearLayout *)bgV
                   cell:(ImageCollectionViewCell *)cell
           indexPathRow:(NSInteger)indexPathRow {
    NSLog(@"slotPhotoUseFor");
    
    NSInteger photoId = [self.photoArray[[self getCurrentPage]][@"photo_id"] integerValue];
    NSLog(@"photoId: %ld", (long)photoId);
    NSString *photoIdStr = [self.photoArray[[self getCurrentPage]][@"photo_id"] stringValue];
    
    UIDevice *device = [UIDevice currentDevice];
    NSString *currentDeviceId = [[device identifierForVendor] UUIDString];
    
    [self.activityIndicatorView startAnimating];
    
//    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView: app.window];
//    hud.graceTime = kHUDGraceTime;
//    [app.window addSubview: hud];
//    [hud showAnimated: YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI slotPhotoUseFor: currentDeviceId
                                             photoId: photoIdStr
                                               token: [wTools getUserToken]
                                              userId: [wTools getUserID]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicatorView stopAnimating];
//            [hud hideAnimated: YES];
//            [hud removeFromSuperview];
            
            if (response != nil) {
                NSLog(@"response from slotPhotoUseFor");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ContentCheckingViewController");
                    NSLog(@"slotPhotoUseFor");
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
                        
                        if (![wTools objectExists: dic[@"data"]]) {
                            return;
                        }
                        self.slotDicData = dic[@"data"];
                        [self createGiftView: bgV
                                     dicData: self.slotDicData
                                  returnType: @"SYSTEM_OK"];
                        cell.giftImageBtn.hidden = NO;
                    } else if ([dic[@"result"] isEqualToString: @"SYSTEM_ERROR"]) {
                        NSLog(@"SYSTEM_ERROR");
                        NSLog(@"失敗：%@",dic[@"message"]);
                        if ([wTools objectExists: dic[@"message"]]) {
                            [self showCustomErrorAlert: dic[@"message"]];
                        } else {
                            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                        }
                        cell.giftImageBtn.hidden = YES;
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
                        cell.giftImageBtn.hidden = YES;
                    } else if ([dic[@"result"] isEqualToString: @"PHOTOUSEFOR_HAS_EXPIRED"]) {
                        [self saveSlotData: photoId];
                        [self checkSlotDataInDatabaseOrNot];
                        
                        [self createViewForStatus: @"兌換已結束" indexPathRow: indexPathRow];
                        cell.giftImageBtn.hidden = YES;
                        cell.giftViewBgV.alpha = 0;
                    } else if ([dic[@"result"] isEqualToString: @"PHOTOUSEFOR_HAS_SENT_FINISHED"]) {
                        [self saveSlotData: photoId];
                        [self checkSlotDataInDatabaseOrNot];
                        
                        [self createViewForStatus: @"兌換已結束" indexPathRow: indexPathRow];
                        cell.giftImageBtn.hidden = YES;
                        cell.giftViewBgV.alpha = 0;
                    } else if ([dic[@"result"] isEqualToString: @"PHOTOUSEFOR_USER_HAS_EXCHANGED"]) {
                        [self saveSlotData: photoId];
                        [self checkSlotDataInDatabaseOrNot];
                        
                        if (![wTools objectExists: dic[@"data"]]) {
                            return;
                        }
                        self.slotDicData = dic[@"data"];
                        [self createGiftView: bgV
                                     dicData: self.slotDicData
                                  returnType: @"PHOTOUSEFOR_USER_HAS_EXCHANGED"];
                        cell.giftImageBtn.hidden = YES;
                    } else if ([dic[@"result"] isEqualToString: @"PHOTOUSEFOR_USER_HAS_GAINED"]) {
                        [self saveSlotData: photoId];
                        [self checkSlotDataInDatabaseOrNot];
                        
                        if (![wTools objectExists: dic[@"data"]]) {
                            return;
                        }
                        
                        self.slotDicData = dic[@"data"];
                        [self createGiftView: bgV
                                     dicData: self.slotDicData
                                  returnType: @"PHOTOUSEFOR_USER_HAS_GAINED"];
                        cell.giftImageBtn.hidden = YES;
                    } else if ([dic[@"result"] isEqualToString: @"PHOTOUSEFOR_USER_HAS_SLOTTED"]) {
                        [self saveSlotData: photoId];
                        [self checkSlotDataInDatabaseOrNot];
                        
                        if (![wTools objectExists: dic[@"data"]]) {
                            return;
                        }
                        
                        self.slotDicData = dic[@"data"];
                        [self createGiftView: bgV
                                     dicData: self.slotDicData
                                  returnType: @"PHOTOUSEFOR_USER_HAS_SLOTTED"];
                        cell.giftImageBtn.hidden = YES;
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
                        cell.giftImageBtn.hidden = YES;
                    }
                }
            }
        });
    });
}

- (void)getPhotoUseFor:(MyLinearLayout *)bgV
                  cell:(ImageCollectionViewCell *)cell
          indexPathRow:(NSInteger)indexPathRow {
    NSLog(@"");
    NSLog(@"getPhotoUseFor bgV indexPathRow");
    NSLog(@"bgV: %@", bgV);
    
    NSInteger photoId = [self.photoArray[indexPathRow][@"photo_id"] integerValue];
    NSLog(@"photoId: %ld", (long)photoId);
    NSString *photoIdStr = [self.photoArray[indexPathRow][@"photo_id"] stringValue];
    
    [self.activityIndicatorView startAnimating];
//    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView: app.window];
//    hud.graceTime = kHUDGraceTime;
//    [app.window addSubview: hud];
//    [hud showAnimated: YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI getPhotoUseFor: photoIdStr
                                              token: [wTools getUserToken]
                                             userId: [wTools getUserID]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicatorView stopAnimating];
//            [hud hideAnimated: YES];
//            [hud removeFromSuperview];
            
            if (response != nil) {
                NSLog(@"response from getPhotoUseFor");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ContentCheckingViewController");
                    NSLog(@"getPhotoUseFor");
                    
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
                        if (![wTools objectExists: dic[@"data"]]) {
                            return;
                        }
                        self.slotDicData = dic[@"data"];
                        [self createGiftView: bgV
                                     dicData: self.slotDicData
                                  returnType: @"SYSTEM_OK"];
                        
                        cell.giftViewBgV.alpha = 1;
//                        [self animateGiftViewBgV: cell];
                    } else if ([dic[@"result"] isEqualToString: @"SYSTEM_ERROR"]) {
                        NSLog(@"SYSTEM_ERROR");
                        NSLog(@"失敗：%@",dic[@"message"]);
                        if ([wTools objectExists: dic[@"message"]]) {
                            [self showCustomErrorAlert: dic[@"message"]];
                        } else {
                            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                        }
                        
                        cell.giftViewBgV.alpha = 0;
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
                        
//                        cell.giftViewBgV.hidden = YES;
                        cell.giftViewBgV.alpha = 0;
                    } else if ([dic[@"result"] isEqualToString: @"PHOTOUSEFOR_HAS_EXPIRED"]) {
                        [self createViewForStatus: @"兌換已結束" indexPathRow: indexPathRow];
//                        cell.giftViewBgV.hidden = YES;
                        cell.giftViewBgV.alpha = 0;
                    } else if ([dic[@"result"] isEqualToString: @"PHOTOUSEFOR_HAS_SENT_FINISHED"]) {
                        [self createViewForStatus: @"兌換已結束" indexPathRow: indexPathRow];
//                        cell.giftViewBgV.hidden = YES;
                        cell.giftViewBgV.alpha = 0;
                    } else if ([dic[@"result"] isEqualToString: @"PHOTOUSEFOR_USER_HAS_EXCHANGED"]) {
                        if (![wTools objectExists: dic[@"data"]]) {
                            return;
                        }
                        self.slotDicData = dic[@"data"];
                        [self createGiftView: bgV
                                     dicData: self.slotDicData
                                  returnType: @"PHOTOUSEFOR_USER_HAS_EXCHANGED"];
//                        cell.giftViewBgV.hidden = NO;
//                        [self animateGiftViewBgV: cell];
                        
                        cell.giftViewBgV.alpha = 1;
                    } else if ([dic[@"result"] isEqualToString: @"PHOTOUSEFOR_USER_HAS_GAINED"]) {
                        [self checkSlotDataInDatabaseOrNot];
                        if (![wTools objectExists: dic[@"data"]]) {
                            return;
                        }
                        self.slotDicData = dic[@"data"];
                        [self createGiftView: bgV
                                     dicData: self.slotDicData
                                  returnType: @"PHOTOUSEFOR_USER_HAS_GAINED"];
//                        cell.giftViewBgV.hidden = NO;
//                        [self animateGiftViewBgV: cell];
                        
                        cell.giftViewBgV.alpha = 1;
                    } else if ([dic[@"result"] isEqualToString: @"PHOTOUSEFOR_USER_HAS_SLOTTED"]) {
                        if (![wTools objectExists: dic[@"data"]]) {
                            return;
                        }
                        self.slotDicData = dic[@"data"];
                        [self createGiftView: bgV
                                     dicData: self.slotDicData
                                  returnType: @"PHOTOUSEFOR_USER_HAS_SLOTTED"];
//                        cell.giftViewBgV.hidden = NO;
//                        [self animateGiftViewBgV: cell];
                        cell.giftViewBgV.alpha = 1;
                    } else if ([dic[@"result"] isEqualToString: @"PHOTOUSEFOR_NOT_YET_STARTED"]) {
                        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                        style.messageColor = [UIColor whiteColor];
                        style.backgroundColor = [UIColor hintGrey];
                        
                        // Use self.view.superview to present toast will not call scrollViewDidScroll
                        [self.view.superview makeToast: @"活動尚未開始"
                                              duration: 2.0
                                              position: CSToastPositionBottom
                                                 style: style];
                        
//                        cell.giftViewBgV.hidden = NO;
//                        [self animateGiftViewBgV: cell];
                        cell.giftViewBgV.alpha = 1;
                    }
                }
            }
        });
    });
}

- (void)animateGiftViewBgV:(ImageCollectionViewCell *)cell {
    [UIView animateWithDuration: 0.3 animations:^{
        cell.giftViewBgV.alpha = 0;
        cell.giftViewBgV.alpha = 1;
    }];
}

- (void)createGiftView:(MyLinearLayout *)giftViewBgV
               dicData:(NSDictionary *)dicData
            returnType:(NSString *)returnType {
    NSLog(@"");
    NSLog(@"createGiftViewContent");
    NSLog(@"giftViewBgV: %@", giftViewBgV);
    NSLog(@"self getCurrentPage: %ld", (long)[self getCurrentPage]);
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem: [self getCurrentPage] inSection: 0];
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[self.imageScrollCV cellForItemAtIndexPath: indexPath];
    
    for (UIView *view in cell.giftViewBgV.subviews) {
        [view removeFromSuperview];
    }
//    cell.giftViewBgV.hidden = NO;
    
    // GiftView
    MyFrameLayout *giftView = [MyFrameLayout new];
    giftView.backgroundColor = [UIColor whiteColor];
    giftView.mySize = CGSizeMake(cell.giftViewBgV.frame.size.width, cell.giftViewBgV.frame.size.height - 54);
    NSLog(@"giftView: %@", NSStringFromCGRect(giftView.frame));
    giftView.myTopMargin = 0;
    giftView.myLeftMargin = giftView.myRightMargin = 0;
    giftView.myBottomMargin = 8;
    giftView.layer.cornerRadius = kCornerRadius;
    [cell.giftViewBgV addSubview: giftView];
    
    // ScrollView
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame: giftView.bounds];
    scrollView.myTopMargin = scrollView.myBottomMargin = 0;
    scrollView.myLeftMargin = scrollView.myRightMargin = 0;
    scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 51.0, 0.0);
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.delegate = self;
    [giftView addSubview: scrollView];
    
    // ContentLayout
    MyLinearLayout *contentLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Vert];
    contentLayout.wrapContentHeight = YES;
    contentLayout.myTopMargin = 0;
    contentLayout.myLeftMargin = contentLayout.myRightMargin = 0;
    [scrollView addSubview: contentLayout];
    
    NSLog(@"dicData: %@", dicData);
    
    // Name Label
    if (![dicData[@"photousefor"][@"name"] isEqual: [NSNull null]]) {
        UILabel *nameLabel = [UILabel new];
        nameLabel.wrapContentHeight = YES;
        nameLabel.myTopMargin = 16;
        nameLabel.myLeftMargin = nameLabel.myRightMargin = 16;
        nameLabel.myBottomMargin = 8;
        nameLabel.numberOfLines = 0;
        nameLabel.font = [UIFont boldSystemFontOfSize: 18.0];
        if ([wTools objectExists: dicData[@"photousefor"][@"name"]]) {
            nameLabel.text = dicData[@"photousefor"][@"name"];
            [LabelAttributeStyle changeGapString: nameLabel content: nameLabel.text];
        }
        nameLabel.textColor = [UIColor firstGrey];
        [nameLabel sizeToFit];
        [contentLayout addSubview: nameLabel];
    }
    
    isGiftImageLoaded = NO;
    
    // ImageView
    if (![dicData[@"photousefor"][@"image"] isEqual: [NSNull null]]) {
        __block UIImageView *imageView = [[UIImageView alloc] init];
        __block typeof(self) wself = self;
        [imageView sd_setImageWithURL: [NSURL URLWithString: dicData[@"photousefor"][@"image"]] placeholderImage: [UIImage imageNamed: @"bg_2_0_0_no_image"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            wself->isGiftImageLoaded = YES;
            
            imageView = [wself calculateImageViewSize: cell.giftViewBgV imgV: imageView];
            imageView.myTopMargin = imageView.myBottomMargin = 8;
            imageView.myLeftMargin = imageView.myRightMargin = 16;
            imageView.layer.cornerRadius = kCornerRadius;
            imageView.layer.masksToBounds = YES;
            
            wself.giftImageView = imageView;
            
            [contentLayout addSubview: imageView];
            
            UILabel *descriptionLabel = [UILabel new];
            descriptionLabel.wrapContentHeight = YES;
            descriptionLabel.myTopMargin = descriptionLabel.myBottomMargin = 8;
            descriptionLabel.myLeftMargin = descriptionLabel.myRightMargin = 16;
            descriptionLabel.numberOfLines = 0;
            descriptionLabel.font = [UIFont systemFontOfSize: 14.0];
            if ([wTools objectExists: dicData[@"photousefor"][@"description"]]) {
                descriptionLabel.text = dicData[@"photousefor"][@"description"];
                [LabelAttributeStyle changeGapString: descriptionLabel content: descriptionLabel.text];
            }
            descriptionLabel.textColor = [UIColor firstGrey];
            [descriptionLabel sizeToFit];
            [contentLayout addSubview: descriptionLabel];
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
            if ([wTools objectExists: dicData[@"photousefor"][@"description"]]) {
                descriptionLabel.text = dicData[@"photousefor"][@"description"];
                [LabelAttributeStyle changeGapString: descriptionLabel content: descriptionLabel.text];
            }
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
    [cell.giftViewBgV addSubview: exchangeBtn];
    NSLog(@"giftViewBgV.hidden: %d", cell.giftViewBgV.hidden);
    NSLog(@"giftViewBgV: %@", cell.giftViewBgV);
    NSLog(@"giftViewBgV.subviews: %@", cell.giftViewBgV.subviews);
    
//    [self animateGiftViewBgV: cell];
    cell.giftViewBgV.alpha = 1;
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

- (void)createViewForStatus:(NSString *)msg
               indexPathRow:(NSInteger)indexPathRow {
    NSLog(@"createViewForStatus msg: %@", msg);
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem: indexPathRow inSection: 0];
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[self.imageScrollCV cellForItemAtIndexPath: indexPath];
    cell.statusView.hidden = NO;
    
    if (![wTools objectExists: msg]) {
        return;
    }
    
    cell.statusLabel.text = msg;
    [LabelAttributeStyle changeGapString: cell.statusLabel content: msg];
}

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
    if (isGiftImageLoaded) {
        [self changeOrientationToPortrait];
        btn.backgroundColor = [UIColor firstMain];
        NSInteger photoId = [self.photoArray[[self getCurrentPage]][@"photo_id"] integerValue];
        NSLog(@"photoId: %ld", (long)photoId);
        
        self.isPresentingOrPushingVC = YES;
        
        ExchangeInfoEditViewController *exchangeInfoEditVC = [[ExchangeInfoEditViewController alloc] init];
        exchangeInfoEditVC.exchangeDic = [self.slotDicData mutableCopy];
        exchangeInfoEditVC.hasExchanged = NO;
        exchangeInfoEditVC.isExisting = [self.slotDicData[@"bookmark"][@"is_existing"] boolValue];
        exchangeInfoEditVC.backgroundView = btn.superview;
        exchangeInfoEditVC.photoId = photoId;
        exchangeInfoEditVC.delegate = self;
        self.navigationController.delegate = self;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.myNav pushViewController: exchangeInfoEditVC animated: YES];
    } else {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor thirdPink];
        
        [self.view makeToast: @"請等待圖片載入完成"
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
    }
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
    NSString *photoIdStr = [self.photoArray[[self getCurrentPage]][@"photo_id"] stringValue];
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
                        [self.slotDicData[@"bookmark"] setObject: [NSNumber numberWithBool: YES] forKey: @"is_existing"];
                        NSLog(@"self.slotDicData: %@", self.slotDicData);
                        
                        [btn setTitle: @"已加入兌換清單" forState: UIControlStateNormal];
                        [btn setTitleColor: [UIColor secondGrey] forState: UIControlStateNormal];
                        btn.userInteractionEnabled = NO;
                        btn.adjustsImageWhenHighlighted = NO;
                    } else if ([dic[@"result"] isEqualToString: @"SYSTEM_ERROR"]) {
                        NSLog(@"SYSTEM_ERROR");
                        NSLog(@"失敗：%@",dic[@"message"]);
                        if ([wTools objectExists: dic[@"message"]]) {
                            [self showCustomErrorAlert: dic[@"message"]];
                        } else {
                            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                        }
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

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    NSLog(@"numberOfItemsInSection");
    NSLog(@"self.photoArray.count: %lu", (unsigned long)self.photoArray.count);
//    NSLog(@"self.photoArray: %@", self.photoArray);
    return self.photoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForItemAtIndexPath");
    NSDictionary *data = self.photoArray[indexPath.row];
    useFor = self.photoArray[indexPath.row][@"usefor"];
    
    if (collectionView.tag == 100) {
        NSLog(@"collectionView.tag == 100");
        ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"ImageCell" forIndexPath: indexPath];
        NSLog(@"cell: %@", cell);
        NSLog(@"cell.giftViewBgV: %@", cell.giftViewBgV);
        
        if (![wTools objectExists: data[@"image_url"]]) {
            if (![wTools objectExists: data[@"image"]]) {
                cell.imageView.image = [UIImage imageNamed: @"bg_2_0_0_no_image"];
            } else {
                cell.imageView.image = [UIImage imageNamed: data[@"image"]];
            }
        } else {
            [cell.imageView sd_setImageWithURL: [NSURL URLWithString: data[@"image_url"]]];
        }
        albumPoint = [self.bookdata[@"album"][@"point"] intValue];
        userPoint = [[userPrefs objectForKey: @"pPoint"] integerValue];
        exchangeNumber = [self.bookdata[@"albumstatistics"][@"exchange"] integerValue];
        
        NSString *rewardDescription = self.bookdata[@"album"][@"reward_description"];
        
        NSUInteger countPhoto = [self.bookdata[@"album"][@"count_photo"] intValue];
        NSArray *photoArray = self.bookdata[@"photo"];
        NSUInteger totalPhoto = photoArray.count;
        
        // Setup GiftView Width & Height
        cell.giftViewWidthConstraint.constant = giftViewWidth;
        cell.giftViewHeightConstraint.constant = giftViewHeight - 10;
        
        // Hide view for default
        cell.videoView.hidden = YES;
        cell.videoBtn.hidden = YES;
        cell.finalPageView.hidden = YES;
        cell.alphaBgV.hidden = YES;
        cell.giftImageBtn.hidden = YES;
        cell.giftViewBgV.alpha = 0;
        cell.statusView.hidden = YES;
        cell.checkCollectionLayout.hidden = YES;
        
        NSString *refer = self.photoArray[indexPath.row][@"video_refer"];
        NSLog(@"refer: %@", refer);
        NSLog(@"useFor: %@", useFor);
        
        UIView *w = [cell.videoView viewWithTag:20002];
        if (w)
            [w removeFromSuperview];
        
        if ([useFor isEqualToString: @"video"]) {
            NSLog(@"useFor is equal to video");
            //            NSURL *url = [NSURL URLWithString: self.photoArray[indexPath.row][@"video_target"]];
            
            if ([refer isEqualToString: @"file"] || [refer isEqualToString: @"system"]) {
                NSLog(@"refer is equal to file or system");
                cell.alphaBgV.hidden = YES;
                cell.videoBtn.hidden = YES;
                cell.videoView.hidden = NO;
                
                for (UIView *view in cell.videoView.subviews) {
                    NSLog(@"view: %@", view);
                    view.hidden = NO;
                }
            } else if ([refer isEqualToString: @"embed"]) {
                NSLog(@"refer is equal to embed");
                cell.alphaBgV.hidden = NO;
                cell.videoBtn.hidden = NO;
                cell.videoView.hidden = YES;
                for (UIView *view in cell.videoView.subviews) {
                    view.hidden = YES;
                }
            }
        }
        if ([useFor isEqualToString: @"slot"]) {
            cell.alphaBgV.hidden = NO;
            
            if (self.isOwned) {
//                cell.giftImageBtn.hidden = NO;
                cell.checkCollectionLayout.hidden = YES;
            } else {
//                cell.giftImageBtn.hidden = YES;
                cell.checkCollectionLayout.hidden = NO;
            }
        }
        if ([useFor isEqualToString: @"exchange"]) {
            cell.alphaBgV.hidden = NO;
            
            if (self.isOwned) {
//                cell.giftViewBgV.hidden = NO;
                cell.checkCollectionLayout.hidden = YES;
            } else {
//                cell.giftViewBgV.hidden = YES;
                cell.checkCollectionLayout.hidden = NO;
            }
        }
        if ([useFor isEqualToString: @"FinalPage"]) {
            NSLog(@"useFor is equal to Final Page");
            cell.albumPoint = albumPoint;
            NSLog(@"cell.albumPoint: %ld", (long)cell.albumPoint);
            cell.userPoint = userPoint;
            NSLog(@"cell.userPoint: %ld", (long)cell.userPoint);
            cell.exchangeNumber = exchangeNumber;
            NSLog(@"cell.exchangeNumber: %ld", (long)cell.exchangeNumber);
            cell.finalPageView.hidden = NO;
            
            if (albumPoint == 0) {
                if (totalPhoto == countPhoto) {
                    cell.conditionCheckStr = @"Exit";
                } else if (totalPhoto != countPhoto) {
                    cell.conditionCheckStr = @"FreeCollect";
                }
            } else if (albumPoint > 0) {
                NSLog(@"rewardAfterCollect: %d", rewardAfterCollect);
                
                if (displayNumOfCollect && exchangeNumber > 0) {
                    cell.sponsoredNumberLabel.hidden = NO;
                } else {
                    cell.sponsoredNumberLabel.hidden = YES;
                }
                if (totalPhoto == countPhoto) {
                    if (rewardAfterCollect) {
                        cell.conditionCheckStr = @"DisplayAllWithReward";
                        bgSV = cell.bgSV;
                        inputTextField = cell.sponsorTextFieldForBgV3;
                        nameTextView = cell.nameTextView;
                        phoneTextView = cell.phoneTextView;
                        addressTextView = cell.addressTextView;
                        
                        inputTextField.delegate = self;
                        nameTextView.delegate = self;
                        phoneTextView.delegate = self;
                        addressTextView.delegate = self;
                        
                        if ([wTools objectExists: rewardDescription]) {
                            cell.rewardDescriptionLabel.text = rewardDescription;
                        }
                    } else {
                        cell.conditionCheckStr = @"DisplayAllWithoutReward";
                        inputTextField = cell.sponsorTextFieldForBgV2;
                        inputTextField.delegate = self;
                    }
                } else if (totalPhoto != countPhoto) {
                    if (rewardAfterCollect) {
                        cell.conditionCheckStr = @"DisplayPreviewWithReward";
                        bgSV = cell.bgSV;
                        inputTextField = cell.sponsorTextFieldForBgV3;
                        nameTextView = cell.nameTextView;
                        phoneTextView = cell.phoneTextView;
                        addressTextView = cell.addressTextView;
                        
                        inputTextField.delegate = self;
                        nameTextView.delegate = self;
                        phoneTextView.delegate = self;
                        addressTextView.delegate = self;
                        
                        if ([wTools objectExists: rewardDescription]) {
                            cell.rewardDescriptionLabel.text = rewardDescription;
                        }
                    } else {
                        cell.conditionCheckStr = @"DisplayPreviewWithoutReward";
                        inputTextField = cell.sponsorTextFieldForBgV2;
                        inputTextField.delegate = self;
                    }
                }
            }
        } else {
            cell.finalPageView.hidden = YES;
        }
        cell.exitBlock = ^(BOOL selected, NSInteger tag, UIButton *btn) {
            [self backBtnPressed: nil];
        };
        cell.collectBlock = ^(BOOL selected, NSInteger tag, UIButton *btn) {
            [self buyAlbum];
        };
        //__block NSString *inputText = inputTextField.text;
        __block typeof(inputTextField) input = inputTextField;
        __block typeof(nameTextView) nameInput = nameTextView;
        __block typeof(phoneTextView) phoneInput = phoneTextView;
        __block typeof(addressTextView) addressInput = addressTextView;
        __block typeof(self) wself = self;
        __block typeof(cell) wcell = cell;
        
        cell.sponsorBlock = ^(BOOL selected, NSInteger tag, UIButton *btn) {
            if ([nameInput.text isEqualToString: @""]) {
                [wself warnToastWithMessage: @"請輸入收件人姓名"];
                [nameInput resignFirstResponder];
                return;
            }
            if ([phoneInput.text isEqualToString: @""]) {
                [wself warnToastWithMessage: @"請輸入電話號碼"];
                [phoneInput resignFirstResponder];
                return;
            }
            if ([addressInput.text isEqualToString: @""]) {
                [wself warnToastWithMessage: @"請輸入收件人地址"];
                [addressInput resignFirstResponder];
                return;
            }
            if ([input.text isEqualToString: @""]) {
                [wself warnToastWithMessage: @"請輸入贊助數量"];
                [input resignFirstResponder];
                return;
            } else if ([input.text intValue] < wself->albumPoint) {
                [wself warnToastWithMessage: [NSString stringWithFormat: @"最低額度：%lu", (unsigned long)wself->albumPoint]];
                [input resignFirstResponder];
                return;
            } else if ([input.text intValue] > 50000) {
                [input resignFirstResponder];
                return;
            } else {
                [wself checkBuyingAlbum: wself->albumPoint
                              userPoint: wself->userPoint];
            }
        };
        __weak MyLinearLayout *weakGiftViewBgV = cell.giftViewBgV;
        
        cell.giftImageBlock = ^(BOOL selected, NSInteger tag, UIButton *btn) {
//            [wself showSlot: btn giftViewBgV: weakGiftViewBgV indexPathRow: indexPath.row];
            [wself showSlot: btn
                giftViewBgV: weakGiftViewBgV
                       cell: wcell
               indexPathRow: indexPath.row];
        };
        return cell;
    } else {
        NSLog(@"collectionView.tag == 200");
        ThumbnailImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"ThumbnailImageCell" forIndexPath: indexPath];
        if (![wTools objectExists: data[@"image_url_thumbnail"]]) {
            if (![wTools objectExists: data[@"imageThumbnail"]]) {
                cell.thumbnailImageView.image = [UIImage imageNamed: @"bg200_no_image.jpg"];
            } else {
                cell.thumbnailImageView.image = [UIImage imageNamed: data[@"imageThumbnail"]];
            }
        } else {
            [cell.thumbnailImageView sd_setImageWithURL: data[@"image_url_thumbnail"]];
        }
        
        NSString *audioTargetStr = self.photoArray[indexPath.row][@"audio_target"];
        // Check audioTarget
        if (audioTargetStr == nil) {
            NSLog(@"audioTarget == nil");
            audioTargetStr = @"";
        } else if ([audioTargetStr isEqual: [NSNull null]]) {
            audioTargetStr = @"";
        }
        NSLog(@"audioTargetStr: %@", audioTargetStr);
        NSLog(@"Before checking audioTargetStr isEqualToString empty");
        
        if (![wTools objectExists: useFor]) {
            useFor = @"";
        }
        
        if ([useFor isEqualToString: @"video"]) {
            cell.infoButton.hidden = NO;
            [cell.infoButton setImage: [UIImage imageNamed: @"ic200_video_white_1"] forState: UIControlStateNormal];
        } else if ([useFor isEqualToString: @"slot"] || [useFor isEqualToString: @"exchange"]) {
            cell.infoButton.hidden = NO;
            [cell.infoButton setImage: [UIImage imageNamed: @"ic200_gift_white"] forState: UIControlStateNormal];
        } else {
            cell.infoButton.hidden = YES;
        }
        if (![audioTargetStr isEqualToString: @""]) {
            cell.infoButton.hidden = NO;
            [cell.infoButton setImage: [UIImage imageNamed: @"ic200_audio_play_white"] forState: UIControlStateNormal];
        }
        if (indexPath.item == [self getCurrentPage]) {
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
}

#pragma mark - UICollectionViewDelegate Methods
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectItemAtIndexPath");
    NSLog(@"currentPage: %ld", (long)[self getCurrentPage]);
    NSLog(@"indexPath.row: %ld", (long)indexPath.row);
    
    if (collectionView.tag == 100) {
        NSLog(@"collectionView.tag == 100");
        // Video View will be called from didSelectItemAtIndexPath
        useFor = self.photoArray[indexPath.row][@"usefor"];
        [self handleSingleTap];
    } else {
        NSLog(@"collectionView.tag == 200");
        if ([self getCurrentPage] != indexPath.row) {
            [self checkLocationBtn: indexPath.row];
            [self checkAudio: indexPath.row];
            
            // Set delay for playing video, otherwise, there is only sound no video
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^{
                NSLog(@"Do some work");
                [self checkVideo: indexPath.row];
                [self checkSlotAndExchangeInfo: indexPath.row];
            });
            
            [self updateOldCurrentPage: indexPath.row];
            [self pageCalculation:indexPath.row];
            [self textViewContentSetup: indexPath.row];
            [self.imageScrollCV scrollToItemAtIndexPath: indexPath atScrollPosition: UICollectionViewScrollPositionCenteredHorizontally animated: NO];
            [self.thumbnailImageScrollCV reloadData];
        }
    }
}

- (CGPoint)collectionView:(UICollectionView *)collectionView targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset {
    // Method below is to avoid AVPlayerViewController disappear when rotate especially the last view in UICollectionViewCell
    if (collectionView == self.imageScrollCV) {
        return CGPointMake(self.view.bounds.size.width * self.pageBeforePresentingOrPushing, 0);
    } else {
        return proposedContentOffset;
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"sizeForItemAtIndexPath");
    if (collectionView.tag == 100) {
        return self.imageScrollCV.frame.size;
    } else {
        return CGSizeMake(35.0, 52.0);
    }
}

// Horizontal Cell Spacing
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    NSLog(@"");
    NSLog(@"minimumInteritemSpacingForSectionAtIndex");
    return 0.0f;
}

// Vertical Cell Spacing
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    NSLog(@"");
    NSLog(@"minimumLineSpacingForSectionAtIndex");
    if (collectionView.tag == 100) {
        return 0.0f;
    } else {
        return 8.0f;
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    //NSLog(@"");
    //NSLog(@"insetForSectionAtIndex");
    UIEdgeInsets itemInset = UIEdgeInsetsMake(0, 0, 0, 0);
    return itemInset;
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    //NSLog(@" [UIApplication sharedApplication].keyWindow.tag %d",[UIApplication sharedApplication].keyWindow.tag);
    
    if ([UIApplication sharedApplication].keyWindow.tag != 10001 ) return;

    NSLog(@"");
    NSLog(@"scrollViewDidScroll");
    [self dismissKeyboard];
    [self.thumbnailImageScrollCV reloadData];
    
    //  halt video and autoplay when scrolling
    if (scrollView == self.imageScrollCV) {
        if (self.videoPlayer)
            [self.videoPlayer pause];
        
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    self.videoPlayerViewController.view.hidden = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([UIApplication sharedApplication].keyWindow.tag != 10001 ) return;
    
    NSLog(@"scrollViewDidEndDecelerating");
    NSLog(@"self.imageScrollCV.contentOffset.x: %f", self.imageScrollCV.contentOffset.x);
    NSLog(@"self.imageScrollCV.frame.size.width: %f", self.imageScrollCV.frame.size.width);
    NSInteger page = [self getCurrentPage];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem: page inSection: 0];

    if (self.autoplay.selected)
        [self switchAutoPlay:self.autoplay];

    [self updateOldCurrentPage: page];
    //    self.videoPlayerViewController.view.hidden = NO;
    
    if (isDataLoaded) {
        NSLog(@"Data is loaded");
        if (!isRotating) {
            NSLog(@"is not rotating");
            
            if (self.isOwned) {
                NSLog(@"Owned this album");
                [self pageCalculation: page];
            } else {
                NSLog(@"Does not own this album");
                if (page != self.photoArray.count - 1) {
                    [self pageCalculation: page];
                }
            }
            if (scrollView == self.imageScrollCV) {
                NSLog(@"scrollView == self.imageScrollCV");
                [self checkSlotAndExchangeInfo: [self getCurrentPage]];
                [self checkLocationBtn: [self getCurrentPage]];
                [self checkAudio: [self getCurrentPage]];
                [self checkVideo: [self getCurrentPage]];
                [self textViewContentSetup: [self getCurrentPage]];
                [self.thumbnailImageScrollCV reloadData];
                [self.thumbnailImageScrollCV scrollToItemAtIndexPath: indexPath atScrollPosition: UICollectionViewScrollPositionCenteredHorizontally animated: YES];
            }
        }
    }
}

#pragma mark - Helper Methods
- (void)checkBuyingAlbum:(NSUInteger)albumPoint
               userPoint:(NSUInteger)userPoint {
    NSLog(@"checkBuyingAlbum");
    
    NSInteger inputPoint = [inputTextField.text intValue];
    NSLog(@"inputPoint: %ld", (long)inputPoint);
    
    if (userPoint >= albumPoint) {
        if (userPoint >= inputPoint) {
            NSString *msgStr = [NSString stringWithFormat: @"確定贊助%ldP?", (long)inputPoint];
            [self showBuyAlbumCustomAlert: msgStr option: @"buyAlbum" pointStr: [NSString stringWithFormat: @"%ld", (long)inputPoint]];
        } else {
            [self showBuyAlbumCustomAlert: @"你的P點不足，前往購點?" option: @"buyPoint" pointStr: @""];
        }
    } else if (userPoint < albumPoint) {
        [self showBuyAlbumCustomAlert: @"你的P點不足，前往購點?" option: @"buyPoint" pointStr: @""];
    }
}

- (void)dismissKeyboard {
    NSLog(@"dismissKeyboard");
    [inputTextField resignFirstResponder];
    [self.activeTextField resignFirstResponder];
    self.activeTextField = nil;
    [self.activeTextView resignFirstResponder];
    self.activeTextView = nil;
}

- (void)textViewContentSetup:(NSInteger)page {
    NSLog(@"textViewContentSetup");
    NSLog(@"page: %ld", (long)page);
    NSString *description = self.photoArray[page][@"description"];
    
    self.descriptionLabel.text = @"";
    
    if ([wTools objectExists: description]) {
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString: description attributes: @{NSFontAttributeName: [UIFont preferredFontForTextStyle: UIFontTextStyleBody], NSKernAttributeName: @1, NSForegroundColorAttributeName: [UIColor whiteColor]}];
        if ([wTools objectExists: attString]) {
            self.descriptionLabel.text = attString;
        }
    }    
    
    CGFloat btnHeight = 0;
    NSInteger urlCount = 0;
    
    if ([self.photoArray[page][@"hyperlink"] isEqual: [NSNull null]]) {
        NSLog(@"hyperlink is null");
        self.linkStackView.hidden = YES;
        btnHeight = 0;
    } else {
        NSLog(@"hyperlink is not null");
        self.linkStackView.hidden = NO;
        
        NSArray *hyperLinkArray = self.photoArray[page][@"hyperlink"];
        NSLog(@"hyperlink section");
        NSLog(@"hyperLinkArray: %@", hyperLinkArray);
        
        self.linkBtn1.hidden = YES;
        self.linkBtn2.hidden = YES;
        
        for (NSInteger i = 0; i < hyperLinkArray.count; i++) {
            NSDictionary *dic = hyperLinkArray[i];
            if ([dic[@"url"] isEqualToString: @""]) {
                NSLog(@"url is equal to empty");
                btnHeight = 0;
                
                if (i == 0) {
                    self.linkBtn1.hidden = YES;
                } else if (i == 1) {
                    self.linkBtn2.hidden = YES;
                }
            } else {
                NSLog(@"url is not equal to empty");
                urlCount++;
                
                if (i == 0) {
                    btnUrl1 = dic[@"url"];
                    self.linkBtn1.hidden = NO;
                    
                    if ([dic[@"text"] isKindOfClass:[NSNull class]] || [dic[@"text"] isEqualToString: @""]) {

                        [self.linkBtn1 setTitle: @"連結1" forState: UIControlStateNormal];
                    } else {
                        [self.linkBtn1 setTitle: dic[@"text"] forState: UIControlStateNormal];
                    }
                    [self.linkBtn1 addTarget: self action: @selector(linkBt1Pressed) forControlEvents: UIControlEventTouchUpInside];
                } else if (i == 1) {
                    btnUrl2 = dic[@"url"];
                    self.linkBtn2.hidden = NO;
                    
                    if ([dic[@"text"] isKindOfClass:[NSNull class]] || [dic[@"text"] isEqualToString: @""]) {
                    
                        [self.linkBtn2 setTitle: @"連結2" forState: UIControlStateNormal];
                    } else {
                        [self.linkBtn2 setTitle: dic[@"text"] forState: UIControlStateNormal];
                    }
                    [self.linkBtn2 addTarget: self action: @selector(linkBt2Pressed) forControlEvents: UIControlEventTouchUpInside];
                }
            }
        }
    }
    if (urlCount > 0) {
        btnHeight = 30;
    }
    NSLog(@"btnHeight: %f", btnHeight);
//    [self setupContentSizeHeight: description btnHeight: btnHeight];
    [self.descriptionScrollView setContentOffset: CGPointZero];
}

- (void)setupContentSizeHeight:(NSString *)description
                     btnHeight:(CGFloat)btnHeight {
    NSLog(@"setupContentSizeHeight");
    
    if (![wTools objectExists: description]) {
        return;
    }
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.alignment = NSTextAlignmentLeft;
    NSAttributedString *string = [[NSAttributedString alloc] initWithString: description attributes: @{NSFontAttributeName:[UIFont systemFontOfSize:16], NSParagraphStyleAttributeName:style}];
    CGSize textSize = [string boundingRectWithSize: CGSizeMake([UIScreen mainScreen].bounds.size.width - 32 * 2, MAXFLOAT) options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context: nil].size;
    NSLog(@"description: %@", description);
    NSLog(@"self getCurrentPage: %ld", (long)[self getCurrentPage]);
    NSLog(@"textSize.height: %f", textSize.height);
    NSLog(@"btnHeight: %f", btnHeight);
    
    if (textSize.height + btnHeight + 30 < kTextContentHeight) {
        self.descriptionScrollViewHeightConstraint.constant = textSize.height + btnHeight + 30;
        NSLog(@"self.descriptionScrollViewHeightConstraint.constant: %f", self.descriptionScrollViewHeightConstraint.constant);
        
        if ([description isEqualToString: @""]) {
            self.descriptionScrollViewHeightConstraint.constant = (btnHeight>0)?btnHeight+15:btnHeight;
        }
    } else if (textSize.height + btnHeight + 30 > kTextContentHeight) {
        self.descriptionScrollViewHeightConstraint.constant = kTextContentHeight;
    }
}

- (void)linkBt1Pressed {
    [self checkUrlAndPresent: btnUrl1];
}

- (void)linkBt2Pressed {
    [self checkUrlAndPresent: btnUrl2];
}

- (void)checkUrlAndPresent:(NSString *)urlString {
    if (![urlString isEqual: [NSNull null]]) {
        if (![urlString isEqualToString: @""]) {
            if ([urlString containsString: @"http://"] || [urlString containsString: @"https://"]) {
                NSURL *url = [NSURL URLWithString: urlString];
                [self openSafari: url];
            } else {
                CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                style.messageColor = [UIColor whiteColor];
                style.backgroundColor = [UIColor thirdPink];
                
                [self.view makeToast: NSLocalizedString(@"ProfileText-validateSocialLink", @"")
                            duration: 2.0
                            position: CSToastPositionBottom
                               style: style];
            }
        } else {
            NSLog(@"socialLink is equalTostring empty");
        }
    } else {
        NSLog(@"socialLink is null");
    }
}

- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url {
    if ([wTools objectExists: url]) {
        [self openSafari: url];
    }
}
#pragma mark - IBAction Methods
- (IBAction)backBtnPressed:(id)sender {
    NSLog(@"backBtnPressed");
    self.navigationController.delegate = nil;
    
    [self stopTimer];
    
    [self.videoPlayer pause];
    self.videoPlay = NO;
    self.videoPlayerItem = nil;
    [self.videoPlayerViewController removeFromParentViewController];
    self.videoPlayerViewController.player = nil;
    self.videoPlayerViewController = nil;
    
    [self removeObserverForPlayerAndItem];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    self.isPresented = NO;
    [self changeOrientationToPortrait];
    [wTools setStatusBarBackgroundColor:[UIColor clearColor]];
    if (self.postMode) {
        //NSString *alertMessage = @"確定投稿此作品? (點 取消 則退出作品瀏覽，如需再投稿此作品請至活動頁面 - 點擊投稿 - 選擇現有作品)";
        NSString *msg = @"要取消此次投稿，請至活動頁面";
        [self showCustomCheckPostAlertView: msg];
    } else {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.myNav popViewControllerAnimated: YES];
    }
}

- (IBAction)locationBtnPressed:(id)sender {
    [self showMapViewActionSheet];
}

- (void)showMapViewActionSheet {
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
    NSInteger page = [self getCurrentPage];
    if ([wTools objectExists:self.bookdata[@"photo"][page][@"location"]]) {
    //NSLog(@"location Str: %@", self.bookdata[@"photo"][page][@"location"]);
        self.mapShowingActionSheet.locationStr = self.bookdata[@"photo"][page][@"location"];
    
        [self.view addSubview: self.mapShowingActionSheet.view];
        [self.mapShowingActionSheet viewWillAppear: NO];
    }
}

- (IBAction)soundBtnPressed:(id)sender {
    if (self.audioSwitch) {
        // If audioSwitch is ON then set to OFF
        NSLog(@"audioSwitch is set to YES");
        self.audioSwitch = NO;
        [self.avPlayer pause];
    } else {
        // If audioSwitch is OFF then set to ON
        NSLog(@"audioSwitch is set to NO");
        self.audioSwitch = YES;
        
        if (self.avPlayer != nil) {
            NSLog(@"avPlayer is not nil");
            NSLog(@"avPlayer: %@", self.avPlayer);
            
            if (videoIsPlaying) {
                [self.avPlayer pause];
            } else {
                [self.avPlayer play];
            }
        } else if (self.avPlayer == nil) {
            NSLog(@"avPlayer is nil");
            NSLog(@"avPlayer: %@", self.avPlayer);
            NSLog(@"avPlayer is nil, needs to be initialized");
            [self avPlayerSetUp: audioTarget];
        }
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

- (IBAction)messageBtnPressed:(id)sender {
    NSLog(@"messageBtnPressed");
    if (kbShowUp) {
        [self dismissKeyboard];
    }
    [self showNewMessageBoardVC];
}

- (void)showNewMessageBoardVC {
    if (![wTools objectExists: self.albumId]) {
        return;
    }
    NewMessageBoardViewController *nMBVC = [[UIStoryboard storyboardWithName: @"NewMessageBoardVC" bundle: nil] instantiateViewControllerWithIdentifier: @"NewMessageBoardViewController"];
    nMBVC.type = @"album";
    nMBVC.typeId = self.albumId;
    [self presentViewController: nMBVC animated: YES completion: nil];
}

- (void)showCustomMessageActionSheet {
    NSLog(@"showCustomMessageActionSheet");
    self.messageBtn.backgroundColor = [UIColor clearColor];
    
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleDark];
    [UIView animateWithDuration: kAnimateActionSheet animations:^{
        self.effectView = [[UIVisualEffectView alloc] initWithEffect: blurEffect];
    }];
    
    self.effectView.frame = self.view.frame;
    self.effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.effectView.myLeftMargin = self.effectView.myRightMargin = 0;
    self.effectView.myTopMargin = self.effectView.myBottomMargin = 0;
    self.effectView.alpha = 0.9;
    
    // Call customMessageActionSheet methods first
    [self.customMessageActionSheet initialValueSetup];
    [self.customMessageActionSheet getMessage];
}

- (IBAction)likeBtnPressed:(id)sender {
    isLikeBtnPressed = YES;
    
    if (self.isLikes) {
        [self deleteAlbumToLikes];
    } else {
        [self insertAlbumToLikes];
    }
}

- (IBAction)moreBtnPressed:(id)sender {
    NSLog(@"moreBtnPressed");
    if (kbShowUp) {
        [self dismissKeyboard];
    }
    [self showCustomMoreActionSheet];
}
- (IBAction)switchAutoPlay:(id)sender {
    if (sender) {
        UIButton *p = (UIButton *)sender;
        p.selected = !(p.selected);
        if (p.selected) {
            [self setupAutoplayProcess];
            
        } else {
            [self stopTimer];
        }
    }
    
}
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
    
    albumPoint = [self.bookdata[@"album"][@"point"] integerValue];
    
    // Check if albumUserId is same as userId, then don't add collectBtn
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"id: %@", [userDefaults objectForKey: @"id"]);
    NSLog(@"self.dic user user_id: %d", [self.bookdata[@"user"][@"user_id"] intValue]);
    
    NSInteger userId = [[userDefaults objectForKey: @"id"] intValue];
    NSInteger albumUserId = [self.bookdata[@"user"][@"user_id"] intValue];
    
    NSString *collectStr;
    NSString *btnStr;
    
    if (albumUserId != userId) {
        if (!self.isOwned) {
            if (albumPoint == 0) {
                collectStr = @"收藏";
            } else if (albumPoint > 0) {
                collectStr = [NSString stringWithFormat: @"收藏(需要贊助%ldP)", (long)albumPoint];
//                btnStr = @"贊助更多";
            }
        } else {
            collectStr = @"已收藏";
            btnStr = @"";
        }
        [self.customMoreActionSheet addSelectItem: @"ic200_collect_dark.png" title: collectStr btnStr: btnStr tagInt: 1 identifierStr: @"collectItem" isCollected: self.isOwned];
    }
    [self.customMoreActionSheet addSelectItem: @"ic200_share_dark.png" title: @"分享" btnStr: @"" tagInt: 2 identifierStr: @"shareItem"];
    [self.customMoreActionSheet addSelectItem: @"ic200_info_dark.png" title: @"作品資訊" btnStr: @"" tagInt: 3 identifierStr: @"albumInfoItem"];
    
    __weak typeof(self) weakSelf = self;
    __block NSInteger weakAlbumPoint = albumPoint;
    __weak NSDictionary *weakLocData = locdata;
    
    self.customMoreActionSheet.customButtonBlock = ^(BOOL selected) {
        NSLog(@"customButtonBlock press");
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem: self.photoArray.count - 1 inSection: 0];
        [weakSelf.imageScrollCV scrollToItemAtIndexPath: indexPath atScrollPosition: UICollectionViewScrollPositionCenteredHorizontally animated: NO];
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
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem: self.photoArray.count - 1 inSection: 0];
                [weakSelf.imageScrollCV scrollToItemAtIndexPath: indexPath atScrollPosition: UICollectionViewScrollPositionCenteredHorizontally animated: YES];
                [weakSelf.thumbnailImageScrollCV scrollToItemAtIndexPath: indexPath atScrollPosition: UICollectionViewScrollPositionCenteredHorizontally animated: YES];
                
//                NSString *msgStr = [NSString stringWithFormat: @"確定贊助%ldP?", (long)weakAlbumPoint];
//                [weakSelf showBuyAlbumCustomAlert: msgStr option: @"buyAlbum" pointStr: [NSString stringWithFormat: @"%ld", (long)weakAlbumPoint]];
            }
            
        } else if ([identifierStr isEqualToString: @"shareItem"]) {
            NSLog(@"shareItem is pressed");
            [weakSelf checkTaskComplete];
            //[weakSelf showCustomShareActionSheet];
        } else if ([identifierStr isEqualToString: @"albumInfoItem"]) {
            NSLog(@"reportItem is pressed");
            weakSelf.isPresentingOrPushingVC = YES;
            AlbumInfoViewController *albumInfoVC = [[UIStoryboard storyboardWithName: @"AlbumInfoVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumInfoViewController"];
            
            if (weakLocData) {
                NSLog(@"locdata exists");
                NSLog(@"locdata: %@", weakLocData);
                albumInfoVC.localData = weakLocData;
            }
            albumInfoVC.data = weakSelf.bookdata;
            
            CATransition *transition = [CATransition animation];
            transition.duration = 0.5;
            transition.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionMoveIn;
            transition.subtype = kCATransitionFromTop;
            
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate.myNav.view.layer addAnimation: transition forKey: kCATransition];
            weakSelf.navigationController.delegate = nil;
            albumInfoVC.delegate = weakSelf;
            [appDelegate.myNav pushViewController: albumInfoVC animated: NO];
            
            // Can't use presentViewController, because this will cause error logs like
            // Could not inset compass from edges 9
            // Could not inset scale from edge 9
            // Could not inset legal attribution from corner 4
            // Could not inset compass from edges 9
            // Could not inset compass from edges 9
            // Only in iPhoneX
            // [weakSelf presentViewController: albumInfoVC animated: YES completion: nil];
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
                content.contentURL = [NSURL URLWithString: [NSString stringWithFormat: sharingLinkWithAutoPlay, weakSelf.albumId, autoPlayStr]];
            } else {
                content.contentURL = [NSURL URLWithString: [NSString stringWithFormat: sharingLinkWithoutAutoPlay, weakSelf.albumId]];
            }
            [FBSDKShareDialog showFromViewController: weakSelf
                                         withContent: content
                                            delegate: weakSelf];
        } else if ([identifierStr isEqualToString: @"normalSharing"]) {
            NSLog(@"normalSharing is pressed");
            NSString *message;
            
            if ([weakSelf.eventJoin isEqual: [NSNull null]]) {
                message = [NSString stringWithFormat: sharingLinkWithAutoPlay, weakSelf.albumId, autoPlayStr];
            } else {
                message = [NSString stringWithFormat: sharingLinkWithoutAutoPlay, weakSelf.albumId];
            }
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems: [NSArray arrayWithObjects: message, nil] applicationActivities: nil];
            [weakSelf presentViewController: activityVC animated: YES completion: nil];
        }
    };
}

#pragma mark - FBSDKSharing Delegate Methods
- (void)sharer:(id<FBSDKSharing>)sharer
didCompleteWithResults:(NSDictionary *)results {
    NSLog(@"Sharing Complete");
    // Check whether getting Sharing Point or not
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL share_to_fb = [[defaults objectForKey: @"share_to_fb"] boolValue];
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

- (void)sharer:(id<FBSDKSharing>)sharer
didFailWithError:(NSError *)error {
    NSLog(@"Sharing didFailWithError");
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    NSLog(@"Sharing Did Cancel");
}

#pragma mark - MessageBoardViewControllerDelegate Methods
#pragma mark - DDAUIActionSheetViewController Method
- (void)actionSheetViewDidSlideOut:(DDAUIActionSheetViewController *)controller {
    NSLog(@"DDAUIActionSheetViewController");
    NSLog(@"actionSheetViewDidSlideOut");
    [self.effectView removeFromSuperview];
    self.effectView = nil;
}

#pragma mark - MapShowingViewControllerDelegate Method
- (void)mapShowingActionSheetDidSlideOut:(MapShowingViewController *)controller {
    NSLog(@"mapShowingActionSheetDidSlideOut");
    [self.effectView removeFromSuperview];
    self.effectView = nil;
    
}

- (void)gotMessageData {
    NSLog(@"gotMessageData");
    // CustomActionSheet Setting
    // Below method will call viewDidLoad
    [self.view addSubview: self.effectView];
    [self.view addSubview: self.customMessageActionSheet.view];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    NSLog(@"shouldReceiveTouch");
    NSLog(@"self.view.tag: %ld", (long)self.view.tag);
    NSLog(@"touch.view: %@", touch.view);
    return YES;
}

// UIGestureRecognizerDelegate Method
// Delegate method allow gestureRecognizer works when there is a scrollView
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - Custom Alert Method
#pragma mark - showBuyAlbumCustomAlert
- (void)showBuyAlbumCustomAlert:(NSString *)msg
                         option:(NSString *)option
                       pointStr:(NSString *)pointStr {
    NSLog(@"showBuyAlbumCustomAlert msg: %@ option: %@", msg, option);
    CustomIOSAlertView *alertAlbumView = [[CustomIOSAlertView alloc] init];
    //[alertAlbumView setContainerView: [self createBuyAlbumContainerView: msg]];
    [alertAlbumView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    
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
    [alertAlbumView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor whiteColor],nil]];
    [alertAlbumView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
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
                self.isPresentingOrPushingVC = YES;
                
                BuyPPointViewController *bPPVC = [[UIStoryboard storyboardWithName: @"BuyPointVC" bundle: nil] instantiateViewControllerWithIdentifier: @"BuyPPointViewController"];
                bPPVC.delegate = self;
                self.navigationController.delegate = nil;
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [appDelegate.myNav pushViewController: bPPVC animated: YES];
            }
        }
    }];
    [alertAlbumView setUseMotionEffects: YES];
    [alertAlbumView show];
}

- (UIView *)createBuyAlbumContainerView: (NSString *)msg {
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
- (void)showCustomErrorAlert: (NSString *)msg {
    [UIViewController showCustomErrorAlertWithMessage:msg onButtonTouchUpBlock:^(CustomIOSAlertView *customAlertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[customAlertView tag]);
        [customAlertView close];
    }];
}

- (UIView *)createErrorContainerView: (NSString *)msg {
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
                           bgV: (MyLinearLayout *)bgV {
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
    [alertTimeOutView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor clearColor], [UIColor clearColor],nil]];
    [alertTimeOutView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
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
                [weakSelf getMapAPI];
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
            } else if ([protocolName isEqualToString: @"slotPhotoUseFor"]) {
                [weakSelf checkSlotAndExchangeInfo: [self getCurrentPage]];
            } else if ([protocolName isEqualToString: @"getPhotoUseFor"]) {
//                [weakSelf getPhotoUseFor: bgV indexPathRow: [self getCurrentPage]];
                [weakSelf checkSlotAndExchangeInfo: [self getCurrentPage]];
            } else if ([protocolName isEqualToString: @"insertBookmark"]) {
                [weakSelf insertBookmark: btn];
            }
            //            else if ([protocolName isEqualToString: @"switchstatusofcontribution"]) {
            //                [weakSelf postAlbum];
            //            }
        }
    }];
    [alertTimeOutView setUseMotionEffects: YES];
    [alertTimeOutView show];
}

- (UIView *)createTimeOutContainerView: (NSString *)msg {
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

#pragma mark - showCustomCheckPostAlertView
- (void)showCustomCheckPostAlertView: (NSString *)msg {
    NSLog(@"showCustomCheckPostAlertView msg: %@", msg);
    CustomIOSAlertView *alertPostView = [[CustomIOSAlertView alloc] init];
    //[alertPostView setContainerView: [self createCheckPostContainerView: msg]];
    [alertPostView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    
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
            self.isPresentingOrPushingVC = YES;
            
            AlbumCollectionViewController *albumCollectionVC = [[UIStoryboard storyboardWithName: @"AlbumCollectionVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumCollectionViewController"];
            albumCollectionVC.postMode = self.postMode;
            self.navigationController.delegate = nil;
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

- (UIView *)createCheckPostContainerView: (NSString *)msg {
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

#pragma mark - Custom AlertView for Getting Point
- (void)showAlertViewForGettingPoint {
    NSLog(@"showAlertViewForGettingPoint");
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
    
    if ([wTools objectExists: missionTopicStr]) {
        missionTopicLabel.text = missionTopicStr;
        NSLog(@"Topic Label Text: %@", missionTopicStr);
    }
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
    imageView.center = CGPointMake(pointView.frame.size.width / 2, pointView.frame.size.height / 2);
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
    
    if ([wTools objectExists: rewardValue]) {
        messageLabel.text = [NSString stringWithFormat: @"%@%@%@", congratulate, rewardValue, end];
    }
    
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
    
    if (![wTools objectExists: eventUrl]) {
        return;
    }
    
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
- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    // Done button pressed
    NSLog(@"show");
    [alertView show];
}

#pragma mark - BuyPPointViewController Delegate Method
- (void)buyPPointViewController:(BuyPPointViewController *)controller {
    NSLog(@"buyPPointViewController delegate method");
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    userPoint = [[userPrefs objectForKey: @"pPoint"] integerValue];
    NSLog(@"userPoint: %ld", (long)userPoint);
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem: [self getCurrentPage] inSection: 0];
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[self.imageScrollCV cellForItemAtIndexPath: indexPath];
    cell.currentPointLabelForBgV2.text = [NSString stringWithFormat: @"現有P點：%ld", (long)userPoint];
    cell.currentPointLabelForBgV3.text = [NSString stringWithFormat: @"現有P點：%ld", (long)userPoint];
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
    zoomTransition.fadeColor = self.imageScrollCV.backgroundColor;
    
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

#pragma mark -
- (void)dealloc {
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

- (void)removeObserverForPlayerAndItem {
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


#pragma mark - UITextFieldDelegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"textFieldDidBeginEditing");
    self.activeTextField = textField;
    self.lastOffset = bgSV.contentOffset;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"textFieldDidEndEditing");
    [self.activeTextField resignFirstResponder];
    self.activeTextField = nil;
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    if (textField.tag == 50000) {
        NSMutableString *test = [NSMutableString stringWithString:textField.text];
        [test replaceCharactersInRange:range withString:string];
        int i = [test intValue];
        if (i > 50000) {
            textField.text = @"50000";
            //[self warnToastWithMessage: @"超過最高贊助上限"];
            CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
            style.messageColor = [UIColor whiteColor];
            style.backgroundColor = [UIColor thirdPink];
            
            [self.view makeToast: @"超過最高贊助上限"
                        duration: 2.0
                        position: CSToastPositionCenter
                           style: style];
            return NO;
        }
    }
    if ((textField.text.length + (string.length - range.length)) > 5) {
        return false;
    }
    return true;
}

#pragma mark - UITextViewDelegate Methods
- (void)textViewDidBeginEditing:(UITextView *)textView {
    NSLog(@"textViewDidBeginEditing");
    self.activeTextView = textView;
    self.lastOffset = bgSV.contentOffset;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSLog(@"textViewDidEndEditing");
    [self.activeTextView resignFirstResponder];
    self.activeTextView = nil;
}

- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"textViewDidChange");
    //每次输入变更都让布局重新布局。
    if (textView == phoneTextView) {
        return;
    }
    UITextRange *tp = textView.selectedTextRange;
    NSLog(@"tp: %@", tp);
    CGRect caret = [textView firstRectForRange:tp];
    NSLog(@"caret: %@", NSStringFromCGRect(caret));
    
    if (caret.size.width < 1) {
        caret = [textView caretRectForPosition: [textView endOfDocument]];
    }
    CGRect r2 = [bgSV convertRect: caret fromView: textView];
    NSLog(@"r2: %@", NSStringFromCGRect(r2));
    [bgSV scrollRectToVisible:CGRectMake(0, r2.origin.y, bgSV.bounds.size.width, r2.size.height) animated:YES];
    
    MyBaseLayout *layout = (MyBaseLayout*)textView.superview;
    [layout setNeedsLayout];
    
    //这里设置在布局结束后将textView滚动到光标所在的位置了。在布局执行布局完毕后如果设置了endLayoutBlock的话可以在这个block里面读取布局里面子视图的真实布局位置和尺寸，也就是可以在block内部读取每个子视图的真实的frame的值。
    layout.endLayoutBlock = ^{
        NSRange rg = textView.selectedRange;
        [textView scrollRangeToVisible:rg];
    };
    NSLog(@"bgSV.contentOffset: %@", NSStringFromCGPoint(bgSV.contentOffset));
}

- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    if (textView == phoneTextView) {
        if ([text isEqualToString: @"\n"]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Keyboard Notification
- (void)addKeyboardNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
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

- (void)keyboardDidShow:(NSNotification*)aNotification {
    NSLog(@"keyboardDidShow");
    kbShowUp = YES;
    NSLog(@"rewardAfterCollect: %d", rewardAfterCollect);
    
    if (rewardAfterCollect) {
        NSDictionary *info = [aNotification userInfo];
        CGSize kbSize = [[info objectForKey: UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        CGFloat keyboardHeight = kbSize.height;
        NSLog(@"kbSize: %@", NSStringFromCGSize(kbSize));
        
        UIView *activeView;
        
        if (self.activeTextView != nil) {
            NSLog(@"self.activeTextView != nil");
            activeView = self.activeTextView;
        } else if (self.activeTextField != nil) {
            NSLog(@"self.activeTextField != nil");
            activeView = self.activeTextField;
        }
        NSLog(@"bgSV.frame.size.height: %f", bgSV.frame.size.height);
        NSLog(@"activeView.frame.origin.y: %f", activeView.frame.origin.y);
        NSLog(@"activeView.frame.size.height: %f", activeView.frame.size.height);
        
        CGFloat distanceToBottom = bgSV.frame.size.height - activeView.frame.origin.y - activeView.frame.size.height;
        NSLog(@"keyboardHeight: %f", keyboardHeight);
        NSLog(@"distanceToBottom: %f", distanceToBottom);
        
        CGFloat collapseSpace = keyboardHeight + 20 - distanceToBottom;
        
        if (collapseSpace < 0) {
            NSLog(@"no collapse");
            return;
        }
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
        bgSV.contentInset = contentInsets;
        
        [UIView animateWithDuration: 0.3 animations:^{
            NSLog(@"scroll to the position above keyboard 10 points");
            [self->bgSV setContentOffset: CGPointMake(self.lastOffset.x, collapseSpace + 10) animated: YES];
        }];
    } else {
        NSLog(@"rewardAfterCollect is NO");
        NSLog(@"Animate bgV2CenterYConstraint");
        UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem: [self getCurrentPage] inSection: 0];
        ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[self.imageScrollCV cellForItemAtIndexPath: indexPath];
        
        if (interfaceOrientation == 1) {
            NSLog(@"interfaceOrientation == 1");
            [UIView animateWithDuration: 0.3 animations:^{
                cell.bgV2CenterYConstraint.constant = 0;
                cell.bgV2CenterYConstraint.constant = -30;
            }];
        } else if (interfaceOrientation == 3 || interfaceOrientation == 4) {
            NSLog(@"interfaceOrientation == 3 || 4");
            [UIView animateWithDuration: 0.3 animations:^{
                cell.bgV2CenterYConstraint.constant = 0;
                cell.bgV2CenterYConstraint.constant = -100;
            }];
        }
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    NSLog(@"keyboardWillBeHidden");
    kbShowUp = NO;
    NSLog(@"rewardAfterCollect: %d", rewardAfterCollect);
    
    if (rewardAfterCollect) {
        [UIView animateWithDuration: 0.3 animations:^{
            self->bgSV.contentOffset = self.lastOffset;
            //            UIEdgeInsets contentInsets = UIEdgeInsetsZero;
            //            self->bgSV.contentInset = contentInsets;
            self->bgSV.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
            //            self->bgSV.scrollIndicatorInsets = contentInsets;
        }];
    } else {
        UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem: [self getCurrentPage] inSection: 0];
        ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[self.imageScrollCV cellForItemAtIndexPath: indexPath];
        
        if (interfaceOrientation == 1) {
            NSLog(@"interfaceOrientation == 1");
            [UIView animateWithDuration: 0.3 animations:^{
                cell.bgV2CenterYConstraint.constant = -30;
                cell.bgV2CenterYConstraint.constant = 0;
            }];
        } else if (interfaceOrientation == 3 || interfaceOrientation == 4) {
            NSLog(@"interfaceOrientation == 3 || 4");
            [UIView animateWithDuration: 0.3 animations:^{
                cell.bgV2CenterYConstraint.constant = -60;
                cell.bgV2CenterYConstraint.constant = 0;
            }];
        }
    }
}

#pragma mark - toast message
- (void)warnToastWithMessage:(NSString *)message {
    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
    style.messageColor = [UIColor whiteColor];
    style.backgroundColor = [UIColor thirdPink];
    
    [self.view makeToast: message
                duration: 2.0
                position: CSToastPositionBottom
                   style: style];
}
#pragma mark -
- (void)albumInfoViewControllerDisappear: (AlbumInfoViewController *)controller {
    
}

@end
