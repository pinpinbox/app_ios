//
//  AlbumDetailViewController.m
//  wPinpinbox
//
//  Created by David on 10/01/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "AlbumDetailViewController.h"
#import "boxAPI.h"
#import "wTools.h"
#import "MyLinearLayout.h"
#import "UIColor+Extensions.h"

#import <FBSDKShareKit/FBSDKShareLinkContent.h>
#import <FBSDKShareKit/FBSDKShareDialog.h>

#import "SelectBarViewController.h"
#import "UIViewController+CWPopup.h"

#import "CustomIOSAlertView.h"
#import "OldCustomAlertView.h"
#import "ReadBookViewController.h"
#import "RecentBrowsingViewController.h"
#import "UIView+Toast.h"
#import "BuyPPointViewController.h"
#import "NewMessageBoardViewController.h"
#import "MessageboardViewController.h"
#import "AppDelegate.h"
#import "NewReadBookViewController.h"
#import "TestReadBookViewController.h"
#import "CreaterViewController.h"
#import <SafariServices/SafariServices.h>
#import "DDAUIActionSheetViewController.h"
#import "AsyncImageView.h"
#import "FRHyperLabel.h"
#import "RegexKitLite.h"
#import "GlobalVars.h"

#import "AlbumCreationViewController.h"
#import "AlbumSettingViewController.h"
#import "NewEventPostViewController.h"
#import "LabelAttributeStyle.h"

#import <SDWebImage/UIImageView+WebCache.h>

//#import "FXBlurView.h"

//static NSString *sharingLink = @"http://www.pinpinbox.com/index/album/content/?album_id=%@%@";
//static NSString *sharingLinkWithoutAutoPlay = @"http://www.pinpinbox.com/index/album/content/?album_id=%@";
static NSString *autoPlayStr = @"&autoplay=1";


#define animateConstant 0.1

@interface AlbumDetailViewController () <FBSDKSharingDelegate, SelectBarDelegate, UIGestureRecognizerDelegate, SFSafariViewControllerDelegate, DDAUIActionSheetViewControllerDelegate, UIScrollViewDelegate, TestReadBookViewControllerDelegate, UITextViewDelegate, NewMessageBoardViewControllerDelegate, MessageboardViewControllerDelegate, SFSafariViewControllerDelegate, AlbumCreationViewControllerDelegate, AlbumSettingViewControllerDelegate>
{
    // For Showing Message of Getting Point
    NSString *missionTopicStr;
    NSString *rewardType;
    NSString *rewardValue;
    NSString *eventUrl;
    
    NSString *restriction;
    NSString *restrictionValue;
    NSUInteger numberOfCompleted;
    
    NSArray *reportIntentList;
    CGFloat height;
    
    BOOL isLikes;
    NSUInteger likesInt;
    
    NSUInteger messageInt;
    
    NSInteger albumPoint;
    BOOL isCollected;
    
    //NewMessageBoardViewController *newMessageBoardVC;
    
    UITapGestureRecognizer *tapGR;
    
    OldCustomAlertView *alertGetPointView;
    
    NSString *albumType;
    
    NSString *task_for;
    
    BOOL isViewed;
    BOOL isPosting;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBarViewHeight;
@property (weak, nonatomic) IBOutlet UIView *toolBarView;
@property (weak, nonatomic) IBOutlet UIButton *downArrowBtn;
@property (weak, nonatomic) IBOutlet UIButton *messageBtn;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;
@property (weak, nonatomic) IBOutlet UIButton *checkContentBtn;

@property (weak, nonatomic) IBOutlet UILabel *likeNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageNumberLabel;

@property (nonatomic) DDAUIActionSheetViewController *customMoreActionSheet;
@property (nonatomic) DDAUIActionSheetViewController *customShareActionSheet;
@property (nonatomic) MessageboardViewController *customMessageActionSheet;

@property (nonatomic) UIVisualEffectView *effectView;
//@property (nonatomic) FXBlurView *fxBlurView;

//@property (strong, nonatomic) UIViewController *dimVC;
//@property (strong, nonatomic) UIViewController *modal;
@property (weak, nonatomic) IBOutlet UIButton *headerImageBtn;

@end

@implementation AlbumDetailViewController

- (void)checkAlbumId:(NSString *)albumId {
    NSLog(@"checkAlbumId: albumId: %@", albumId);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *array = [defaults objectForKey: @"albumIdArray"];
    NSLog(@"array: %@", array);
    
    // Get the albumIdArray from Device
    if (array != nil) {
        NSLog(@"albumIdArray exists");
        
        NSMutableArray *albumIdArray  = [NSMutableArray arrayWithArray: array];
        NSLog(@"albumIdArray: %@", albumIdArray);
        
        if ([albumIdArray containsObject: albumId]) {
            NSLog(@"albumIdArray containsObject: albumId");
            isViewed = NO;
        } else {
            NSLog(@"albumIdArray does not containsObject: albumId");
            [albumIdArray addObject: albumId];
            NSLog(@"After adding object albumId: %@", albumId);
            NSLog(@"albumIdArray: %@", albumIdArray);
            
            isViewed = YES;
            
            [defaults setObject: albumIdArray forKey: @"albumIdArray"];
            [defaults synchronize];
        }
    } else {
        NSLog(@"albumIdArray does not exist");
        NSMutableArray *albumIdArray = [NSMutableArray new];
        [albumIdArray addObject: albumId];
        NSLog(@"albumIdArray: %@", albumIdArray);
        
        [defaults setObject: albumIdArray forKey: @"albumIdArray"];
        [defaults synchronize];
        
        isViewed = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"AlbumDetailViewController");
    NSLog(@"viewDidLoad");
    
    NSLog(@"");
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSLog(@"app.myNav: %@", app.myNav);
    NSLog(@"");
    
    for (id controller in app.myNav.viewControllers) {
        NSLog(@"controller: %@", controller);
    }
    NSLog(@"");
    NSLog(@"self.navigationController.viewControllers: %@", self.navigationController.viewControllers);
    NSLog(@"");
    for (id controller in self.navigationController.viewControllers) {
        NSLog(@"controller: %@", controller);
    }
    NSLog(@"");        
    
    self.checkContentBtn.layer.cornerRadius = kCornerRadius;
    
    // CustomActionSheet
    self.customMoreActionSheet = [[DDAUIActionSheetViewController alloc] init];
    self.customMoreActionSheet.delegate = self;
    self.customMoreActionSheet.topicStr = @"你 想 做 什 麼?";
    
    self.customShareActionSheet = [[DDAUIActionSheetViewController alloc] init];
    self.customShareActionSheet.delegate = self;
    self.customShareActionSheet.topicStr = @"選 擇 分 享 方 式";
    
    self.customMessageActionSheet = [[MessageboardViewController alloc] init];
    self.customMessageActionSheet.delegate = self;
    self.customMessageActionSheet.topicStr = @"留言板";
    self.customMessageActionSheet.userName = @"";
    self.customMessageActionSheet.type = @"album";
    self.customMessageActionSheet.typeId = self.albumId;
    
    // Set default value
    isViewed = NO;
    
    [self checkAlbumId: self.albumId];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"AlbumDetailViewController viewWillAppear");
    
    for (UIView *view in self.tabBarController.view.subviews) {
        UIButton *btn = (UIButton *)[view viewWithTag: 104];
        btn.hidden = YES;
    }
    
    [self retrieveAlbum];
    
    @try {
        [self setBtnBackgroundColorToClear];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [wTools setStatusBarBackgroundColor: [UIColor whiteColor]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                self.toolBarViewHeight.constant = 56;
                break;
            case 1334:
                printf("iPhone 6/6S/7/8");
                self.toolBarViewHeight.constant = 56;
                break;
            case 1920:
                printf("iPhone 6+/6S+/7+/8+");
                self.toolBarViewHeight.constant = 56;
                break;
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                self.toolBarViewHeight.constant = 56;
                break;
            case 2436:
                printf("iPhone X");
                self.toolBarViewHeight.constant = 90;
                break;
            default:
                printf("unknown");
                self.toolBarViewHeight.constant = 56;
                break;
        }
    }
}

- (void)setBtnBackgroundColorToClear {
    NSLog(@"setBtnBackgroundColorToClear");
    self.downArrowBtn.backgroundColor = [UIColor clearColor];
    self.messageBtn.backgroundColor = [UIColor clearColor];
    self.likeBtn.backgroundColor = [UIColor clearColor];
    self.moreBtn.backgroundColor = [UIColor clearColor];
}

- (void)initialValueSetup {
    NSLog(@"initialValueSetup");
    
    [self parallaxViewSetup];
    
    isLikes = [self.data[@"album"][@"is_likes"] boolValue];
    
    // ToolBarView Setup
    self.toolBarView.backgroundColor = [UIColor barColor];
    [self btnSetup];
}

- (void)btnSetup {
    self.downArrowBtn.backgroundColor = [UIColor clearColor];
    self.downArrowBtn.layer.cornerRadius = kCornerRadius;
    [self.downArrowBtn addTarget: self action: @selector(arrowBtnHighLight:) forControlEvents: UIControlEventTouchDown];
    [self.downArrowBtn addTarget: self action: @selector(arrowBtnNormal:) forControlEvents: UIControlEventTouchUpInside];
    [self.downArrowBtn addTarget: self action: @selector(arrowBtnNormal:) forControlEvents: UIControlEventTouchUpOutside];
    
    self.messageBtn.backgroundColor = [UIColor clearColor];
    self.messageBtn.layer.cornerRadius = kCornerRadius;
    [self.messageBtn addTarget: self action: @selector(messageBtnHighLight:) forControlEvents: UIControlEventTouchDown];
    [self.messageBtn addTarget: self action: @selector(messageBtnNormal:) forControlEvents: UIControlEventTouchUpInside];
    [self.messageBtn addTarget: self action: @selector(messageBtnNormal:) forControlEvents: UIControlEventTouchUpOutside];
    
    
    if (isLikes) {
        [self.likeBtn setImage: [UIImage imageNamed: @"ic200_like_main.png"] forState: UIControlStateNormal];
    } else {
        [self.likeBtn setImage: [UIImage imageNamed: @"ic200_like_dark.png"] forState: UIControlStateNormal];
    }
    self.likeBtn.backgroundColor = [UIColor clearColor];
    self.likeBtn.layer.cornerRadius = kCornerRadius;
    [self.likeBtn addTarget: self action: @selector(likeBtnHighLight:) forControlEvents: UIControlEventTouchDown];
    [self.likeBtn addTarget: self action: @selector(likeBtnNormal:) forControlEvents: UIControlEventTouchUpInside];
    [self.likeBtn addTarget: self action: @selector(likeBtnNormal:) forControlEvents: UIControlEventTouchUpOutside];
    
    self.moreBtn.backgroundColor = [UIColor clearColor];
    self.moreBtn.layer.cornerRadius = kCornerRadius;
    [self.moreBtn addTarget: self action: @selector(moreBtnHighlight:) forControlEvents: UIControlEventTouchDown];
    [self.moreBtn addTarget: self action: @selector(moreBtnNormal:) forControlEvents: UIControlEventTouchUpInside];
    [self.moreBtn addTarget: self action: @selector(moreBtnNormal:) forControlEvents: UIControlEventTouchUpOutside];
    
    self.checkContentBtn.layer.cornerRadius = kCornerRadius;
    //[self.checkContentBtn addTarget: self action: @selector(checkContent) forControlEvents: UIControlEventTouchUpInside];
    //[self.checkContentBtn addTarget: self action: @selector(checkContent) forControlEvents: UIControlEventTouchUpOutside];
    
    NSLog(@"self.getMessagePush: %d", self.getMessagePush);
    
    // Check whether messagePush exist or not
    if (self.getMessagePush) {
        [self messageBtnPress: nil];
        self.getMessagePush = NO;
    }
}

#pragma mark - Add Views on Parallax View
- (void)parallaxViewSetup {
    NSLog(@"parallaxViewSetup");
    
    tapGR = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(imageViewTap)];
    tapGR.numberOfTapsRequired = 1;
    tapGR.delegate = self;
    
    //[self.view addGestureRecognizer: tapGR];
    //[self.headerImageView addGestureRecognizer: tapGR];
    
    self.useBlurForPopup = YES;
    
    isCollected = [self.data[@"album"][@"own"] boolValue];
    
    // Setup Bottom ImageView
    NSString *imageUrl;
    //NSLog(@"_data: %@", _data);
    
    if ([self.data[@"photo"] isEqual: [NSNull null]]) {
        self.headerImageView.image = [UIImage imageNamed: @"bg200_no_image.jpg"];
    } else {
        if ([_data[@"photo"][0][@"image_url"] isEqual: [NSNull null]]) {
            self.headerImageView.image = [UIImage imageNamed: @"bg200_no_image.jpg"];
        } else {
            imageUrl = _data[@"photo"][0][@"image_url"];
            self.headerImageView.image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: imageUrl]]];
        }
    }
    
    // Message Section
    messageInt = [self.data[@"albumstatistics"][@"messageboard"] integerValue];
    
    self.messageNumberLabel.textColor = [UIColor secondGrey];
    
    if (messageInt >= 100000) {
        messageInt = messageInt / 10000;
        self.messageNumberLabel.text = [NSString stringWithFormat: @"%ldM", (long)messageInt];
        [LabelAttributeStyle changeGapString: self.messageNumberLabel content: [NSString stringWithFormat: @"%ldM", (long)messageInt]];
    } else if (messageInt >= 10000) {
        messageInt = messageInt / 1000;
        self.messageNumberLabel.text = [NSString stringWithFormat: @"%ldK", (long)messageInt];
        [LabelAttributeStyle changeGapString: self.messageNumberLabel content: [NSString stringWithFormat: @"%ldK", (long)messageInt]];
    } else {
        self.messageNumberLabel.text = [NSString stringWithFormat: @"%ld", (long)messageInt];
        [LabelAttributeStyle changeGapString: self.messageNumberLabel content: [NSString stringWithFormat: @"%ld", (long)messageInt]];
    }
    
    // Likes Section
    isLikes = [self.data[@"album"][@"is_likes"] boolValue];
    likesInt = [self.data[@"albumstatistics"][@"likes"] integerValue];
    
    if ([self.data[@"album"][@"is_likes"] boolValue]) {
        [self.likeBtn setImage: [UIImage imageNamed: @"ic200_like_main"] forState: UIControlStateNormal];
    } else {
        [self.likeBtn setImage: [UIImage imageNamed: @"ic200_like_dark"] forState: UIControlStateNormal];
    }
    
    self.likeNumberLabel.textColor = [UIColor secondGrey];
    
    if (likesInt >= 100000) {
        likesInt = likesInt / 10000;
        //self.likeNumberLabel.text = [NSString stringWithFormat: @"%ldM", (long)likesInt];
        self.headerLikedNumberLabel.text = [NSString stringWithFormat: @"%ldM", (long)likesInt];
        [LabelAttributeStyle changeGapString: self.headerLikedNumberLabel content: [NSString stringWithFormat: @"%ldM", (long)likesInt]];
    } else if (messageInt >= 10000) {
        likesInt = likesInt / 1000;
        //self.likeNumberLabel.text = [NSString stringWithFormat: @"%ldK", (long)likesInt];
        self.headerLikedNumberLabel.text = [NSString stringWithFormat: @"%ldK", (long)likesInt];
        [LabelAttributeStyle changeGapString: self.headerLikedNumberLabel content: [NSString stringWithFormat: @"%ldK", (long)likesInt]];
    } else {
        //self.likeNumberLabel.text = [NSString stringWithFormat: @"%ld", (long)likesInt];
        self.headerLikedNumberLabel.text = [NSString stringWithFormat: @"%ld", (long)likesInt];
        [LabelAttributeStyle changeGapString: self.headerLikedNumberLabel content: [NSString stringWithFormat: @"%ld", (long)likesInt]];
    }
    //self.likeNumberLabel.text = [NSString stringWithFormat: @"%ld", (long)likesInt];
    
    // Check whether there is any subViews of self.contentView
    // If so, then remove it from superView
    // If not, then do nothing
    if (self.contentView.subviews.count == 0) {
        NSLog(@"self.contentView.subviews.count == 0");
    } else {
        NSLog(@"self.contentView.subviews.count != 0");
        
        for (UIView *subView in self.contentView.subviews) {
            NSLog(@"subView: %@", subView);
            [subView removeFromSuperview];
        }
    }
    
    // Layout Setup
    MyLinearLayout *rootLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Vert];
    rootLayout.myTopMargin = 16;
    rootLayout.myLeftMargin = rootLayout.myRightMargin = 0;
    [self.contentView addSubview: rootLayout];
    
    //UITapGestureRecognizer *contentTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleContentTap)];
    //[rootLayout addGestureRecognizer: contentTap];
    
    // Info Layout
    MyLinearLayout *horzInfoLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Horz];
    horzInfoLayout.myRightMargin = 16;
    
    [rootLayout addSubview: horzInfoLayout];
    
    //UILabel *viewedNumberLabel = [UILabel new];
    
    NSInteger viewedNumber = [self.data[@"albumstatistics"][@"viewed"] integerValue];
    
    if (viewedNumber >= 100000) {
        viewedNumber = viewedNumber / 10000;
        //viewedNumberLabel.text = [NSString stringWithFormat: @"%ldM次觀看", (long)viewedNumber];
        self.headerViewedNumberLabel.text = [NSString stringWithFormat: @"%ldM次瀏覽", (long)viewedNumber];
        [LabelAttributeStyle changeGapString: self.headerViewedNumberLabel content: [NSString stringWithFormat: @"%ldM次瀏覽", (long)viewedNumber]];
    } else if (viewedNumber >= 10000) {
        viewedNumber = viewedNumber / 1000;
        //viewedNumberLabel.text = [NSString stringWithFormat: @"%ldK次觀看", (long)viewedNumber];
        self.headerViewedNumberLabel.text = [NSString stringWithFormat: @"%ldK次瀏覽", (long)viewedNumber];
        [LabelAttributeStyle changeGapString: self.headerViewedNumberLabel content: [NSString stringWithFormat: @"%ldK次瀏覽", (long)viewedNumber]];
    } else {
        //viewedNumberLabel.text = [NSString stringWithFormat: @"%ld次觀看", (long)viewedNumber];
        self.headerViewedNumberLabel.text = [NSString stringWithFormat: @"%ld次瀏覽", (long)viewedNumber];
        [LabelAttributeStyle changeGapString: self.headerViewedNumberLabel content: [NSString stringWithFormat: @"%ld次瀏覽", (long)viewedNumber]];
    }
    
//    viewedNumberLabel.textColor = [UIColor secondGrey];
//    viewedNumberLabel.font = [UIFont systemFontOfSize: 16];
//    [viewedNumberLabel sizeToFit];
//    viewedNumberLabel.myRightMargin = 2;
    //[horzInfoLayout addSubview: viewedNumberLabel];
    
    NSLog(@"self.data: %@", self.data);
    
    BOOL gotAudio;
    BOOL gotVideo;
    BOOL gotExchange;
    BOOL gotSlot;
    
    @try {
        gotAudio = [self.data[@"album"][@"usefor"][@"audio"] boolValue];
        gotVideo = [self.data[@"album"][@"usefor"][@"video"] boolValue];
        gotExchange = [self.data[@"album"][@"usefor"][@"exchange"] boolValue];
        gotSlot = [self.data[@"album"][@"usefor"][@"slot"] boolValue];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
    }
    
    if (gotAudio) {
        NSLog(@"gotAudio");
        //[self addInfoTextToLayout: horzInfoLayout];
        [self addAudioImageToLayout: horzInfoLayout];
        
        if (gotVideo) {
            NSLog(@"gotAudio");
            NSLog(@"gotVideo");
            
            [self addVideoImageToLayout: horzInfoLayout];
            
            if (gotExchange || gotSlot) {
                NSLog(@"gotAudio");
                NSLog(@"gotVideo");
                NSLog(@"gotExchange or gotSlot");
                
                [self addGiftImageToLayout: horzInfoLayout];
            }
        }
    } else if (gotVideo) {
        NSLog(@"gotVideo");
        
        //[self addInfoTextToLayout: horzInfoLayout];
        [self addVideoImageToLayout: horzInfoLayout];
        
        if (gotExchange || gotSlot) {
            NSLog(@"gotVideo");
            NSLog(@"gotExchange or gotSlot");
            
            [self addGiftImageToLayout: horzInfoLayout];
        }
    } else if (gotExchange || gotSlot) {
        NSLog(@"gotExchange || gotSlot");
        
        //[self addInfoTextToLayout: horzInfoLayout];
        [self addGiftImageToLayout: horzInfoLayout];
    }
    
    height = 20;
    NSLog(@"After adding InfoLayout Height");
    NSLog(@"height: %f", height);
    
    // Content Layout
    MyLinearLayout *vertLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Vert];
    vertLayout.myTopMargin = 16;
    vertLayout.myLeftMargin = vertLayout.myRightMargin = 0;
    
    UILabel *topicLabel = [UILabel new];
    topicLabel.text = self.data[@"album"][@"name"];
    topicLabel.textColor = [UIColor firstGrey];
    //topicLabel.font = [UIFont systemFontOfSize: 28];
    topicLabel.font = [UIFont boldSystemFontOfSize: 28];
    topicLabel.numberOfLines = 0;
    [topicLabel sizeToFit];
    topicLabel.myTopMargin = 16;
    topicLabel.myLeftMargin = 16;
    topicLabel.myRightMargin = 16;
    topicLabel.wrapContentHeight = YES;
    [vertLayout addSubview: topicLabel];
    
    CGSize topicSize = [topicLabel.text boundingRectWithSize: CGSizeMake(288, MAXFLOAT) options: NSStringDrawingUsesLineFragmentOrigin attributes: @{NSFontAttributeName: [UIFont systemFontOfSize: 28]}context: nil].size;
    NSLog(@"topicSize.height: %f", topicSize.height);
    
    height += topicSize.height;
    NSLog(@"After adding topicLabel Height");
    NSLog(@"height: %f", height);
    
    
    //UILabel *descriptionLabel = [UILabel new];
    //descriptionLabel.text = self.data[@"album"][@"description"];
    
    FRHyperLabel *descriptionLabel = [FRHyperLabel new];
    
    // Step 1: Define a normal attributed string for non-link texts
    NSString *string = self.data[@"album"][@"description"];
    NSDictionary *attributes = @{NSForegroundColorAttributeName :[UIColor blackColor], NSFontAttributeName: [UIFont preferredFontForTextStyle: UIFontTextStyleHeadline]};
    //descriptionLabel.attributedText = [[NSAttributedString alloc] initWithString: string attributes: attributes];
    [LabelAttributeStyle changeGapString: descriptionLabel content: string];
    descriptionLabel.textColor = [UIColor firstGrey];
    descriptionLabel.font = [UIFont systemFontOfSize: 16];
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.myTopMargin = 16;
    descriptionLabel.myLeftMargin = 16;
    descriptionLabel.myRightMargin = 16;
    descriptionLabel.wrapContentHeight = YES;
    [vertLayout addSubview: descriptionLabel];
    
    // Step 2: Define a selection handler block
    void(^handler)(FRHyperLabel *label, NSString *substring) = ^(FRHyperLabel *label, NSString *substring){
        NSURL *url = [NSURL URLWithString: substring];
        SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: url entersReaderIfAvailable: NO];
        safariVC.preferredBarTintColor = [UIColor whiteColor];
        [self presentViewController: safariVC animated: YES completion: nil];
    };
    
    // Step 3: Add link descriptionStr
    NSArray *urls1 = [string componentsMatchedByRegex: @"http://[^\\s]*"];
    NSArray *urls2 = [string componentsMatchedByRegex: @"https://[^\\s]*"];
    NSMutableArray *array = [NSMutableArray new];
    [array addObjectsFromArray: urls1];
    [array addObjectsFromArray: urls2];
    
    NSLog(@"array: %@", array);
    
    [descriptionLabel setLinksForSubstrings: array withLinkHandler: handler];
    
    [rootLayout addSubview: vertLayout];
    
    CGSize descriptionSize = [descriptionLabel.text boundingRectWithSize: CGSizeMake(288, MAXFLOAT) options: NSStringDrawingUsesLineFragmentOrigin attributes: @{NSFontAttributeName: [UIFont systemFontOfSize: 16]}context: nil].size;
    NSLog(@"descriptionSize.height: %f", descriptionSize.height);
    height += descriptionSize.height;
    
    NSLog(@"After adding descriptionLabel Height");
    NSLog(@"height: %f", height);
    
    UIView *horzLineView = [UIView new];
    horzLineView.myLeftMargin = horzLineView.myRightMargin = 0;
    horzLineView.myTopMargin = horzLineView.myBottomMargin = 32;
    horzLineView.myHeight = 0.5;
    horzLineView.backgroundColor = [UIColor thirdGrey];
    
    [rootLayout addSubview: horzLineView];
    
    height += horzLineView.myHeight;
    
    // Horizontal Name Layout
    MyLinearLayout *horzNameLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Horz];
    //horzNameLayout.myTopMargin = 16;
    horzNameLayout.myLeftMargin = horzNameLayout.myRightMargin = 0;
    //horzNameLayout.myBottomMargin = 13;
    horzNameLayout.wrapContentHeight = YES;
    [rootLayout addSubview: horzNameLayout];
    
    UIImageView *nameImgView = [UIImageView new];
//    AsyncImageView *nameImgView = [AsyncImageView new];
//    nameImgView.showActivityIndicator = NO;
//    nameImgView.imageURL = nil;
//    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: nameImgView];
    NSLog(@"user picture: %@", self.data[@"user"][@"picture"]);
    
    if ([self.data[@"user"][@"picture"] isEqual: [NSNull null]]) {
        NSLog(@"self.data user picture is equal to null");
        nameImgView.image = [UIImage imageNamed: @"member_back_head.png"];
    } else {
//        nameImgView.imageURL = [NSURL URLWithString: self.data[@"user"][@"picture"]];
        [nameImgView sd_setImageWithURL: [NSURL URLWithString: self.data[@"user"][@"picture"]]
                       placeholderImage: [UIImage imageNamed: @"member_back_head.png"]];
    }
    
    //nameImgView.image = [UIImage imageNamed: @"MeTab"];
    nameImgView.myLeftMargin = 16;
    nameImgView.myRightMargin = 2;
    nameImgView.myWidth = 18;
    nameImgView.myHeight = 18;
    
    nameImgView.layer.cornerRadius = 9;
    nameImgView.layer.masksToBounds = YES;
    nameImgView.layer.borderColor = [UIColor thirdGrey].CGColor;
    nameImgView.layer.borderWidth = 0.5;
    
    [horzNameLayout addSubview: nameImgView];
    
    UILabel *nameLabel = [UILabel new];
    nameLabel.text = self.data[@"user"][@"name"];
    nameLabel.textColor = [UIColor firstGrey];
    nameLabel.font = [UIFont boldSystemFontOfSize: 16];
    [nameLabel sizeToFit];
    nameLabel.numberOfLines = 0;
    nameLabel.myLeftMargin = 2;
    nameLabel.myRightMargin = 16;
    nameLabel.weight = 1.0;
    nameLabel.wrapContentHeight = YES;
    [horzNameLayout addSubview: nameLabel];
    
    UITapGestureRecognizer *nameTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleNameTap)];
    [horzNameLayout addGestureRecognizer: nameTap];
    
    CGSize nameSize = [nameLabel.text boundingRectWithSize: CGSizeMake(288, MAXFLOAT) options: NSStringDrawingUsesLineFragmentOrigin attributes: @{NSFontAttributeName: [UIFont systemFontOfSize: 16]}context: nil].size;
    height += nameSize.height;
    
    NSLog(@"After adding nameLabel Height");
    NSLog(@"height: %f", height);
    
    if ([self.data[@"album"][@"location"] isEqualToString: @""]) {
        NSLog(@"no location data");
    } else {
        NSLog(@"got location data");
        // Horizontal Localtion Layout
        MyLinearLayout *horzLocLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Horz];
        horzLocLayout.myTopMargin = 13;
        horzLocLayout.myLeftMargin = horzLocLayout.myRightMargin = 0;
        horzLocLayout.wrapContentHeight = YES;
        [rootLayout addSubview: horzLocLayout];
        
        UIImageView *locImgView = [UIImageView new];
        locImgView.image = [UIImage imageNamed: @"ic200_location_light"];
        locImgView.myLeftMargin = 16;
        locImgView.myRightMargin = 2;
        locImgView.myWidth = 18;
        locImgView.myHeight = 18;
        [horzLocLayout addSubview: locImgView];
        
        UILabel *locLabel = [UILabel new];
        locLabel.text = self.data[@"album"][@"location"];
        locLabel.textColor = [UIColor secondGrey];
        locLabel.font = [UIFont systemFontOfSize: 16];
        [locLabel sizeToFit];
        locLabel.numberOfLines = 0;
        locLabel.myLeftMargin = 2;
        locLabel.myRightMargin = 16;
        locLabel.weight = 1.0;
        locLabel.wrapContentHeight = YES;
        [horzLocLayout addSubview: locLabel];
        
        CGSize locSize = [locLabel.text boundingRectWithSize: CGSizeMake(288, MAXFLOAT) options: NSStringDrawingUsesLineFragmentOrigin attributes: @{NSFontAttributeName: [UIFont systemFontOfSize: 16]}context: nil].size;
        height += locSize.height;
        
        NSLog(@"After adding locationLabel Height");
        NSLog(@"height: %f", height);
    }
    
    NSLog(@"Check Event Layout");
    NSLog(@"self.data: %@", self.data);
    
    // Event Layout
    if ([self.data[@"eventjoin"] isEqual: [NSNull null]]) {
        
    } else {
        //isPosting = YES;
        
        if ([self.fromVC isEqualToString: @"VotingVC"]) {
            
        } else {
            MyLinearLayout *vertEventLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Vert];
            vertEventLayout.myLeftMargin = vertEventLayout.myRightMargin = 0;
            vertEventLayout.myTopMargin = 16;
            vertEventLayout.backgroundColor = [UIColor thirdMain];
            
            UITapGestureRecognizer *eventTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleEventTap)];
            [vertEventLayout addGestureRecognizer: eventTap];
            
            UILabel *eventLabel1 = [UILabel new];
            eventLabel1.text = @"作品正在參加活動";
            eventLabel1.textColor = [UIColor firstMain];
            [eventLabel1 sizeToFit];
            eventLabel1.myLeftMargin = 16;
            eventLabel1.myTopMargin = 16;
            eventLabel1.myBottomMargin = 8;
            [vertEventLayout addSubview: eventLabel1];
            
            //h += 16 * 2;
            
            CGSize eventSize1 = [eventLabel1.text boundingRectWithSize: CGSizeMake(288, MAXFLOAT) options: NSStringDrawingUsesLineFragmentOrigin attributes: @{NSFontAttributeName: [UIFont systemFontOfSize: 16]}context: nil].size;
            height += eventSize1.height;
            
            UILabel *eventLabel2 = [UILabel new];
            eventLabel2.text = self.data[@"event"][@"name"];
            eventLabel2.textColor = [UIColor firstMain];
            [eventLabel2 sizeToFit];
            eventLabel2.numberOfLines = 0;
            eventLabel2.myTopMargin = 8;
            eventLabel2.myLeftMargin = 16;
            eventLabel2.myRightMargin = 16;
            eventLabel2.myBottomMargin = 16;
            eventLabel2.wrapContentHeight = YES;
            [vertEventLayout addSubview: eventLabel2];
            
            [rootLayout addSubview: vertEventLayout];
            
            //h += 8;
            
            CGSize eventSize2 = [eventLabel2.text boundingRectWithSize: CGSizeMake(288, MAXFLOAT) options: NSStringDrawingUsesLineFragmentOrigin attributes: @{NSFontAttributeName: [UIFont systemFontOfSize: 16]}context: nil].size;
            height += eventSize2.height;
            //h += 16;
        }
    }
    
    self.headerImageViewHeight.constant = 300;
    [self adjustContentViewHeight];
    
    [rootLayout sizeToFit];
    
    //self.contentViewHeight.constant = height;
    self.contentViewHeight.constant = rootLayout.frame.size.height + 100;
}

//- (void)addInfoTextToLayout: (MyLinearLayout *)horzInfoLayout
//{
//    // If there are some other info such as audio/video/gift, will show the data below
//    UILabel *dotLabel = [UILabel new];
//    dotLabel.text = @"▪";
//    dotLabel.textColor = [UIColor secondGrey];
//    dotLabel.font = [UIFont systemFontOfSize: 3];
//    [dotLabel sizeToFit];
//    dotLabel.myLeftMargin = 2;
//    dotLabel.myRightMargin = 2;
//    dotLabel.myTopMargin = 7;
//    [horzInfoLayout addSubview: dotLabel];
//
//    UILabel *otherLabel = [UILabel new];
//    otherLabel.text = @"其他內容";
//    otherLabel.textColor = [UIColor secondGrey];
//    otherLabel.font = [UIFont systemFontOfSize: 16];
//    [otherLabel sizeToFit];
//    otherLabel.myLeftMargin = 2;
//    otherLabel.myRightMargin = 2;
//    [horzInfoLayout addSubview: otherLabel];
//}

- (void)addAudioImageToLayout: (MyLinearLayout *)horzInfoLayout
{
    UIImageView *soundImgView = [UIImageView new];
    soundImgView.image = [UIImage imageNamed: @"ic200_audio_play_light"];
    soundImgView.myLeftMargin = 2;
    soundImgView.myRightMargin = 2;
    soundImgView.myWidth = 18;
    soundImgView.myHeight = 18;
    [horzInfoLayout addSubview:soundImgView];
}

- (void)addVideoImageToLayout: (MyLinearLayout *)horzInfoLayout
{
    UIImageView *videoImgView = [UIImageView new];
    videoImgView.image = [UIImage imageNamed: @"ic200_video_light"];
    videoImgView.myLeftMargin = 2;
    videoImgView.myRightMargin = 2;
    videoImgView.myWidth = 18;
    videoImgView.myHeight = 18;
    [horzInfoLayout addSubview: videoImgView];
}

- (void)addGiftImageToLayout: (MyLinearLayout *)horzInfoLayout
{
    UIImageView *giftImgView = [UIImageView new];
    giftImgView.image = [UIImage imageNamed: @"ic200_gift_light"];
    giftImgView.myLeftMargin = 2;
    giftImgView.myRightMargin = 2;
    giftImgView.myWidth = 18;
    giftImgView.myHeight = 18;
    [horzInfoLayout addSubview: giftImgView];
}

#pragma mark - Selector Methods
- (void)handleImageViewTap: (UITapGestureRecognizer *)gestureRecognizer
{
    NSLog(@"handleImageViewTap");
    
    UIView *viewClicked = [gestureRecognizer view];
    
    if (viewClicked == self.headerImageView) {
        NSLog(@"viewClicked == self.headerImageView");
    } else {
        NSLog(@"viewClicked != self.headerImageView");
    }
}

- (void)handleNameTap
{
    NSLog(@"handleNameTap");
    
    CreaterViewController *cVC = [[UIStoryboard storyboardWithName: @"CreaterVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CreaterViewController"];
    cVC.userId = self.data[@"user"][@"user_id"];
    
    //[self.navigationController pushViewController: cVC animated: YES];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: cVC animated: YES];
}

- (void)handleEventTap {
    NSString *eventIdString = [self.data[@"event"][@"event_id"] stringValue];
    
    if (![eventIdString isEqual: [NSNull null]]) {
        if (![eventIdString isEqualToString: @""]) {
            [self getEventData: eventIdString];
        }
    }
    /*
     NSString *activityLink = self.data[@"event"][@"url"];
     NSURL *url = [NSURL URLWithString: activityLink];
     SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: url entersReaderIfAvailable: NO];
     safariVC.delegate = self;
     [self presentViewController: safariVC animated: YES completion: nil];
     */
}

- (void)handleContentTap
{
    NSLog(@"handleContentTap");
}

- (void)imageViewTap
{
    NSLog(@"imageViewTap");
    
    [self toReadBookVC];
}

#pragma mark - Button Action Methods
- (void)arrowBtnHighLight: (UIButton *)sender
{
    NSLog(@"arrowBtnTouchDown");
    sender.backgroundColor = [UIColor thirdMain];
}

- (void)arrowBtnNormal: (UIButton *)sender
{
    NSLog(@"arrowBtnTouchUpOutside");
    sender.backgroundColor = [UIColor clearColor];
}

- (void)messageBtnHighLight: (UIButton *)sender
{
    NSLog(@"messageBtnTouchDown");
    sender.backgroundColor = [UIColor thirdMain];
}

- (void)messageBtnNormal: (UIButton *)sender
{
    NSLog(@"messageBtnTouchUpOutside");
    sender.backgroundColor = [UIColor clearColor];
}

- (void)likeBtnHighLight: (UIButton *)sender
{
    NSLog(@"likeBtnTouchDown");
    sender.backgroundColor = [UIColor thirdMain];
}

- (void)likeBtnNormal: (UIButton *)sender
{
    NSLog(@"likeBtnTouchUpOutside");
    sender.backgroundColor = [UIColor clearColor];
}

- (void)moreBtnHighlight: (UIButton *)sender
{
    NSLog(@"moreBtnHighlight");
    sender.backgroundColor = [UIColor thirdMain];
}

- (void)moreBtnNormal: (UIButton *)sender
{
    NSLog(@"moreBtnNormal");
    sender.backgroundColor = [UIColor clearColor];
}

#pragma mark - Get Event Methods
- (void)getEventData: (NSString *)eventId
{
    NSLog(@"getEventData");
    
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
        NSString *response = [boxAPI getEvent: [wTools getUserID]
                                        token: [wTools getUserToken]
                                     event_id: eventId];
        
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
                NSLog(@"getEvent Response");
                //NSLog(@"response: %@", response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"AlbumDetailViewController");
                    NSLog(@"getEventData eventId");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getEvent"
                                             row: 0
                                         eventId: eventId];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableLeaves error: nil];
                    
                    NSLog(@"data: %@", data);
                    
                    if ([data[@"result"] intValue] == 1) {
                        NSLog(@"GetEvent Success");
                        
                        NewEventPostViewController *newEventPostVC = [[UIStoryboard storyboardWithName: @"NewEventPostVC" bundle: nil] instantiateViewControllerWithIdentifier: @"NewEventPostViewController"];
                        newEventPostVC.name = data[@"data"][@"event"][@"name"];
                        newEventPostVC.title = data[@"data"][@"event"][@"title"];
                        newEventPostVC.imageUrl = data[@"data"][@"event"][@"image"];
                        newEventPostVC.urlString = data[@"data"][@"event"][@"url"];
                        newEventPostVC.templateArray = data[@"data"][@"event_templatejoin"];
                        newEventPostVC.eventId = eventId;
                        newEventPostVC.contributionNumber = [data[@"data"][@"event"][@"contribution"] integerValue];
                        newEventPostVC.popularityNumber = [data[@"data"][@"event"][@"popularity"] integerValue];
                        newEventPostVC.prefixText = data[@"data"][@"event"][@"prefix_text"];
                        newEventPostVC.specialUrl = data[@"data"][@"special"][@"url"];
                        newEventPostVC.eventFinished = NO;
                        
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate.myNav pushViewController: newEventPostVC animated: YES];
                        
                    } else if ([data[@"result"] intValue] == 0) {
                        NSLog(@"失敗： %@", data[@"message"]);
                        NSString *msg = data[@"message"];
                        
                        if (msg == nil) {
                            msg = NSLocalizedString(@"Host-NotAvailable", @"");
                        }
                        [self showCustomErrorAlert: msg];
                        
                    } else if ([data[@"result"] intValue] == 2) {
                        NewEventPostViewController *newEventPostVC = [[UIStoryboard storyboardWithName: @"NewEventPostVC" bundle: nil] instantiateViewControllerWithIdentifier: @"NewEventPostViewController"];
                        newEventPostVC.name = data[@"data"][@"event"][@"name"];
                        newEventPostVC.title = data[@"data"][@"event"][@"title"];
                        newEventPostVC.imageUrl = data[@"data"][@"event"][@"image"];
                        newEventPostVC.urlString = data[@"data"][@"event"][@"url"];
                        newEventPostVC.templateArray = data[@"data"][@"event_templatejoin"];
                        newEventPostVC.eventId = eventId;
                        newEventPostVC.contributionNumber = [data[@"data"][@"event"][@"contribution"] integerValue];
                        newEventPostVC.popularityNumber = [data[@"data"][@"event"][@"popularity"] integerValue];
                        newEventPostVC.prefixText = data[@"data"][@"event"][@"prefix_text"];
                        newEventPostVC.specialUrl = data[@"data"][@"special"][@"url"];
                        newEventPostVC.eventFinished = YES;
                        
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate.myNav pushViewController: newEventPostVC animated: YES];
                    }
                }
            }
        });
    });
}

#pragma mark -

- (void)checkTaskComplete
{
    NSLog(@"checkTaskComplete");
    
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
                NSLog(@"");
                NSLog(@"");
                NSLog(@"response from checkTaskCompleted");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"AlbumDetailViewController");
                    NSLog(@"checkTaskComplete");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"checkTaskCompleted"
                                             row: 0
                                         eventId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    NSLog(@"data: %@", data);
                    
                    if ([data[@"result"] intValue] == 1) {
                        
                        // Task is completed, so calling the original sharing function
                        //[wTools Activitymessage:[NSString stringWithFormat: sharingLink , _album_id, autoPlayStr]];
                        
                        NSString *message;
                        
                        if ([self.data[@"eventjoin"] isEqual: [NSNull null]]) {
                            message = [NSString stringWithFormat: sharingLinkWithAutoPlay, self.albumId, autoPlayStr];
                        } else {
                            message = [NSString stringWithFormat: sharingLinkWithoutAutoPlay, self.albumId];
                        }
                        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems: [NSArray arrayWithObjects: message, nil] applicationActivities: nil];
                        [self presentViewController: activityVC animated: YES completion: nil];
                        
                    } else if ([data[@"result"] intValue] == 2) {
                        NSLog(@"data result intValue: %d", [data[@"result"] intValue]);
                        
                        // Task is not completed, so pop ups alert view
                        //[self showSharingAlertView];
                        //[self showShareActionSheet];
                        [self showCustomShareActionSheet];
                        
                    } else if ([data[@"result"] intValue] == 0) {
                        NSString *message;
                        
                        if ([self.data[@"eventjoin"] isEqual: [NSNull null]]) {
                            message = [NSString stringWithFormat: sharingLinkWithAutoPlay, self.albumId, autoPlayStr];
                        } else {
                            message = [NSString stringWithFormat: sharingLinkWithoutAutoPlay, self.albumId];
                        }
                        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems: [NSArray arrayWithObjects: message, nil] applicationActivities: nil];
                        [self presentViewController: activityVC animated: YES completion: nil];
                    }
                }
            }
        });
    });
}

- (void)toNewReadBookVC
{
    NewReadBookViewController *newReadBookVC = [[UIStoryboard storyboardWithName: @"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"NewReadBookViewController"];
    //[self.navigationController pushViewController: newReadBookVC animated: YES];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: newReadBookVC animated: YES];
}

- (void)toReadBookVC
{
    TestReadBookViewController *testReadBookVC = [[UIStoryboard storyboardWithName: @"TestReadBookVC" bundle: nil] instantiateViewControllerWithIdentifier: @"TestReadBookViewController"];
    testReadBookVC.dic = self.data;
    testReadBookVC.isDownloaded = NO;
    testReadBookVC.albumid = self.albumId;
    testReadBookVC.delegate = self;
    testReadBookVC.isLikes = isLikes;
    testReadBookVC.likeNumber = likesInt;
    testReadBookVC.eventJoin = self.data[@"eventjoin"];
    //[self.navigationController pushViewController: testReadBookVC animated: YES];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: testReadBookVC animated: YES];
}

#pragma mark - ActionSheet
- (void)showMoreActionSheet
{
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
    
    albumPoint = [self.data[@"album"][@"point"] integerValue];
    
    NSString *collectStr;
    
    if (!isCollected) {
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
                                         NSString *msgStr = [NSString stringWithFormat: @"確定贊助%ldP?", (long)albumPoint];
                                         [self showCustomAlert: msgStr option: @"buyAlbum"];
                                     }
                                 }];
    
    if (isCollected) {
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
                                   
                                   /*
                                    NSString *message = [NSString stringWithFormat: sharingLink, self.albumId, autoPlayStr];
                                    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems: [NSArray arrayWithObjects: message, nil] applicationActivities: nil];
                                    [self presentViewController: activityVC animated: YES completion: nil];
                                    */
                               }];
    
    UIAlertAction *reportBtn = [UIAlertAction
                                actionWithTitle:@"檢舉"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    [self insertReport];
                                }];
    
    [alert addAction: cancelBtn];
    
    // Check if albumUserId is same as userId, then don't add collectBtn
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"id: %@", [userDefaults objectForKey: @"id"]);
    NSLog(@"self.data user user_id: %d", [self.data[@"user"][@"user_id"] intValue]);
    
    NSInteger userId = [[userDefaults objectForKey: @"id"] intValue];
    NSInteger albumUserId = [self.data[@"user"][@"user_id"] intValue];
    
    if (albumUserId != userId) {
        [alert addAction: collectBtn];
    }
    
    [alert addAction: shareBtn];
    [alert addAction: reportBtn];
    [self presentViewController: alert animated: YES completion: nil];
}

#pragma mark - Buy Album
- (void)getPoint {
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [boxAPI geturpoints: [wTools getUserID]
                                           token: [wTools getUserToken]];
        
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
            
            
            NSLog(@"response: %@", response);
            
            if (response != nil) {
                NSLog(@"response from geturpoints");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"AlbumDetailViewController");
                    NSLog(@"getPoint");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"geturpoints"
                                             row: 0
                                         eventId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] boolValue]) {
                        NSInteger point = [dic[@"data"] integerValue];
                        NSLog(@"%ld", (long)point);
                        
                        if (point >= albumPoint) {
                            [self buyAlbum];
                        } else {
                            [self showCustomAlert: @"你的P點不足，前往購點?" option: @"buyPoint"];
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

- (void)buyAlbum {
    NSLog(@"buyAlbum");
    
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [boxAPI buyalbum: [wTools getUserID]
                                        token: [wTools getUserToken]
                                      albumid: self.albumId];
        
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
                NSLog(@"response: %@", response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"AlbumDetailViewController");
                    NSLog(@"buyAlbum");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"buyalbum"
                                             row: 0
                                         eventId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSLog(@"response from buyAlbum");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                        style.messageColor = [UIColor whiteColor];
                        style.backgroundColor = [UIColor firstMain];
                        
                        [self.view makeToast: @"成功加入收藏"
                                    duration: 2.0
                                    position: CSToastPositionBottom
                                       style: style];
                        
                        [self checkAlbumCollectTask];
                        
                        isCollected = YES;
                        
                        //[self retrieveAlbum];
                    } else if ([dic[@"result"] intValue] == 2) {
                        [self showCustomErrorAlert: @"已擁有該相本"];
                    } else if ([dic[@"result"] intValue] == 0) {
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
            [self retrieveAlbum];
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
            [self retrieveAlbum];
        } else {
            NSLog(@"Haven't got the point of saving paid album for first time");
            [self checkPoint];
        }
    }
}

- (void)checkPoint
{
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
                                     type_id: self.albumId];
        
        NSLog(@"User ID: %@", [wTools getUserID]);
        NSLog(@"Token: %@", [wTools getUserToken]);
        NSLog(@"Task_For: %@", task_for);
        NSLog(@"Album ID: %@", self.albumId);
        
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
                NSLog(@"response from doTask2");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"AlbumDetailViewController");
                    NSLog(@"checkPoint");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"doTask2"
                                             row: 0
                                         eventId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([data[@"result"] intValue] == 1) {
                        
                        missionTopicStr = data[@"data"][@"task"][@"name"];
                        NSLog(@"name: %@", missionTopicStr);
                        
                        rewardType = data[@"data"][@"task"][@"reward"];
                        NSLog(@"reward type: %@", rewardType);
                        
                        rewardValue = data[@"data"][@"task"][@"reward_value"];
                        NSLog(@"reward value: %@", rewardValue);
                        
                        eventUrl = data[@"data"][@"event"][@"url"];
                        NSLog(@"event: %@", eventUrl);
                        
                        restriction = data[@"data"][@"task"][@"restriction"];
                        NSLog(@"restriction: %@", restriction);
                        
                        restrictionValue = data[@"data"][@"task"][@"restriction_value"];
                        NSLog(@"restrictionValue: %@", restrictionValue);
                        
                        numberOfCompleted = [data[@"data"][@"task"][@"numberofcompleted"] unsignedIntegerValue];
                        NSLog(@"numberOfCompleted: %lu", (unsigned long)numberOfCompleted);
                        
                        [self showAlertPointView];
                        [self saveCollectInfoToDevice: NO];
                        [self retrieveAlbum];
                        
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

#pragma mark - Report Section
- (void)insertReport
{
    NSLog(@"insertReport");
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [boxAPI getreportintentlist: [wTools getUserID]
                                                   token: [wTools getUserToken]];
        
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
                    NSLog(@"AlbumDetailViewController");
                    NSLog(@"insertReport");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getreportintentlist"
                                             row: 0
                                         eventId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    NSLog(@"dic: %@", dic);
                    
                    if ([dic[@"result"] boolValue]) {
                        reportIntentList = dic[@"data"];
                        SelectBarViewController *mv = [[SelectBarViewController alloc] initWithNibName: @"SelectBarViewController" bundle: nil];
                        
                        NSMutableArray *strArr = [NSMutableArray new];
                        
                        for (int i = 0; i < reportIntentList.count; i++) {
                            [strArr addObject: reportIntentList[i][@"name"]];
                        }
                        mv.data = strArr;
                        mv.delegate = self;
                        mv.topViewController = self;
                        [self wpresentPopupViewController: mv animated: YES completion: nil];
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

- (void)SaveDataRow:(NSInteger)row {
    NSLog(@"SaveDataRow: row: %ld", (long)row);
    
    NSString *rid = [reportIntentList[row][@"reportintent_id"] stringValue];
    
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [boxAPI insertreport: [wTools getUserID]
                                            token: [wTools getUserToken]
                                              rid: rid
                                             type: @"album"
                                           typeid: self.albumId];
        
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
                    NSLog(@"AlbumDetailViewController");
                    NSLog(@"SaveDataRow");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"insertreport"
                                             row: row
                                         eventId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    NSLog(@"dic: %@", dic);
                    
                    NSString *msg = @"";
                    
                    if ([dic[@"result"] boolValue]) {
                        msg = NSLocalizedString(@"Works-tipRpSuccess", @"");
                        [self showCustomOKAlert: msg];
                    } else {
                        NSLog(@"失敗： %@", dic[@"message"]);
                        NSString *msg = dic[@"message"];
                        
                        if (msg == nil) {
                            msg = NSLocalizedString(@"Host-NotAvailable", @"");
                        }
                        [self showCustomErrorAlert: msg];
                    }
                    
                    //[self showCustomAlert: msg];
                }
            }
        });
    });
}

- (void)cancelButtonPressed {
    NSLog(@"cancelButtonPressed");
}

#pragma mark - Share ActionSheet

- (void)showShareActionSheet {
    NSLog(@"showShareActionSheet");
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
                                           
                                           if ([self.data[@"eventjoin"] isEqual: [NSNull null]]) {
                                               content.contentURL = [NSURL URLWithString: [NSString stringWithFormat: sharingLinkWithAutoPlay, self.albumId, autoPlayStr]];
                                           } else {
                                               content.contentURL = [NSURL URLWithString: [NSString stringWithFormat: sharingLinkWithoutAutoPlay, self.albumId]];
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
                                         
                                         if ([self.data[@"eventjoin"] isEqual: [NSNull null]]) {
                                             message = [NSString stringWithFormat: sharingLinkWithAutoPlay, self.albumId, autoPlayStr];
                                         } else {
                                             message = [NSString stringWithFormat: sharingLinkWithoutAutoPlay, self.albumId];
                                         }
                                         UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems: [NSArray arrayWithObjects: message, nil] applicationActivities: nil];
                                         [self presentViewController: activityVC animated: YES completion: nil];
                                     }];
    
    [alert addAction: cancelBtn];
    [alert addAction: facebookShareBtn];
    [alert addAction: normalShareBtn];
    [self presentViewController: alert animated: YES completion: nil];
}

- (void)retrieveAlbum {
    NSLog(@"retrieveAlbum");
    
    @try {
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools ShowMBProgressHUD];
        });
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        //NSString *response = [boxAPI retrievealbump: self.albumId uid: [wTools getUserID] token: [wTools getUserToken]];
        
        NSLog(@"isViewed: %d", isViewed);
        
        NSString *viewedString = [NSString stringWithFormat: @"%d", isViewed];
        NSString *response = [boxAPI retrievealbump: self.albumId
                                                uid: [wTools getUserID]
                                              token: [wTools getUserToken]
                                             viewed: viewedString];
        
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
                NSLog(@"response: %@", response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"AlbumDetailViewController");
                    NSLog(@"retrieveAlbum");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"retrievealbump"
                                             row: 0
                                         eventId: @""];
                } else {
                    NSLog(@"Get Real Response");NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] boolValue]) {
                        NSLog(@"result bool value is YES");
                        NSLog(@"dic: %@", dic);
                        
                        NSLog(@"dic data photo: %@", dic[@"data"][@"photo"]);
                        NSLog(@"dic data user name: %@", dic[@"data"][@"user"][@"name"]);
                        
                        self.data = [dic[@"data"] mutableCopy];
                        NSLog(@"self.data: %@", self.data);
                        
                        [self pointsUPdate];                                                
                        
                        [self initialValueSetup];
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

#pragma mark - PointUpdate
- (void)pointsUPdate {
    NSLog(@"pointsUPdate");
    
    // Call geturpoints for right value
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *pointStr = [boxAPI geturpoints: [userPrefs objectForKey: @"id"]
                                           token: [userPrefs objectForKey: @"token"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"pointStr: %@", pointStr);
            
            if (pointStr != nil) {
                if ([pointStr isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"AlbumDetailViewController");
                    NSLog(@"pointsUpdate");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getUrPoints"
                                             row: 0
                                         eventId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *pointDic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [pointStr dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    NSInteger point = [pointDic[@"data"] integerValue];
                    [userPrefs setObject: [NSNumber numberWithInteger: point] forKey: @"pPoint"];
                    [userPrefs synchronize];
                }
            }
        });
    });
}

#pragma mark - Custom Alert Method
- (void)showCustomAlert: (NSString *)msg btnName: (NSString *)btnName
{
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    [alertView setContainerView: [self createCustomContainerView: msg]];
    
    [alertView setButtonTitles: [NSMutableArray arrayWithObject: btnName]];
    [alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    [alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertView.arrangeStyle = @"Horizontal";
    
    /*
     [alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
     [alertView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor firstMain], [UIColor firstPink], [UIColor secondGrey], nil]];
     [alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor darkMain], [UIColor darkPink], [UIColor firstGrey], nil]];
     alertView.arrangeStyle = @"Vertical";
     */
    
    __weak CustomIOSAlertView *weakAlertView = alertView;
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        [weakAlertView close];
    }];
    [alertView setUseMotionEffects: YES];
    [alertView show];
}

- (UIView *)createCustomContainerView: (NSString *)msg
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
    [imageView setImage:[UIImage imageNamed:@"icon_2_0_0_dialog_pinpin"]];
    
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

#pragma mark - IBAction Methods
- (IBAction)checkContentBtnPress:(id)sender {
    NSLog(@"checkContentBtnPress");
    NSLog(@"self.data: %@", self.data);
    
    if (self.data == nil) {
        NSLog(@"self.data == nil");
        NSLog(@"self.data: %@", self.data);
        [self retrieveAlbum];
    } else {
        NSLog(@"self.data != nil");
        
        if ([self.data[@"photo"] isEqual:[NSNull null]]) {
            [self showCustomErrorAlert: @"作品沒有內容"];
        } else {
            [self toReadBookVC];
        }
        //[self toNewReadBookVC];
    }
}

- (IBAction)backBtnPress:(id)sender {
    NSLog(@"backBtnPress");
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromBottom;
    [self.navigationController.view.layer addAnimation: transition forKey: kCATransition];
    //[self.navigationController popViewControllerAnimated: NO];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav popViewControllerAnimated: NO];
    
    /*
     [UIView animateWithDuration: 0.75
     animations:^{
     [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
     [UIView setAnimationTransition: UIViewAnimationOptionTransitionCrossDissolve forView: self.navigationController.view cache: NO];
     }];
     [self.navigationController popViewControllerAnimated: YES];
     */
    //[self.navigationController popViewControllerAnimated:YES];
    //[self dismissViewControllerAnimated: YES completion: nil];
}

- (IBAction)messageBtnPress:(id)sender {
    NSLog(@"messageBtnPress");
    
    UIButton *btn = (UIButton *)sender;
    btn.backgroundColor = [UIColor thirdMain];
    
    [self showCustomMessageActionSheet];
    
//    NewMessageBoardViewController *nMBC = [[UIStoryboard storyboardWithName: @"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"NewMessageBoardViewController"];
//    nMBC.type = @"album";
//    nMBC.typeId = self.albumId;
//    nMBC.delegate = self;
//    [self presentViewController: nMBC animated: YES completion: nil];
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

#pragma mark - MessageBoardViewControllerDelegate Methods
- (void)gotMessageData {
    NSLog(@"gotMessageData");    
    // CustomActionSheet Setting
    // Below method will call viewDidLoad
    [self.view addSubview: self.effectView];
    [self.view addSubview: self.customMessageActionSheet.view];
}

#pragma mark -
- (IBAction)likeBtnPress:(id)sender {
    NSLog(@"isLikes: %d", isLikes);
    
    if (isLikes) {
        [self deleteAlbumToLikes];
    } else {
        [self insertAlbumToLikes];
    }
}

- (IBAction)moreBtnPress:(id)sender {
    NSLog(@"moreBtnPress");
    
    UIButton *btn = (UIButton *)sender;
    btn.backgroundColor = [UIColor thirdMain];
    
    [self showCustomMoreActionSheet];
    //[self showMoreActionSheet];
}

- (void)showCustomMoreActionSheet {
    NSLog(@"");
    NSLog(@"showCustomMoreActionSheet");
    
    // Blur View Setting
    /*
     self.fxBlurView = [[FXBlurView alloc] initWithFrame: self.view.bounds];
     self.fxBlurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
     self.fxBlurView.myLeftMargin = self.fxBlurView.myRightMargin = 0;
     self.fxBlurView.myTopMargin = self.fxBlurView.myBottomMargin = 0;
     
     self.fxBlurView.tintColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.5];
     self.fxBlurView.backgroundColor = [UIColor whiteColor];
     self.fxBlurView.blurRadius = 10;
     [self.view addSubview: self.fxBlurView];
     */
    
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
    [self.view addSubview: self.customMoreActionSheet.view];
    [self.customMoreActionSheet viewWillAppear: NO];
    
    albumPoint = [self.data[@"album"][@"point"] integerValue];
    
    // Check if albumUserId is same as userId, then don't add collectBtn
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"id: %@", [userDefaults objectForKey: @"id"]);
    NSLog(@"self.data user user_id: %d", [self.data[@"user"][@"user_id"] intValue]);
    
    NSInteger userId = [[userDefaults objectForKey: @"id"] intValue];
    NSInteger albumUserId = [self.data[@"user"][@"user_id"] intValue];
    
    NSString *collectStr;
    NSString *btnStr;
    
    if (albumUserId != userId) {
        if (!isCollected) {
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
        
        [self.customMoreActionSheet addSelectItem: @"ic200_collect_dark.png" title: collectStr btnStr: btnStr tagInt: 1 identifierStr: @"collectItem" isCollected: isCollected];
    }
    
    if (albumUserId == userId) {
        [self.customMoreActionSheet addSelectItem: @"" title: @"作品編輯" btnStr: @"" tagInt: 2 identifierStr: @"albumEdit"];
        [self.customMoreActionSheet addSelectItem: @"" title: @"修改資訊" btnStr: @"" tagInt: 3 identifierStr: @"modifyInfo"];
        [self.customMoreActionSheet addHorizontalLine];
    }
    
    [self.customMoreActionSheet addSelectItem: @"ic200_share_dark.png" title: @"分享" btnStr: @"" tagInt: 4 identifierStr: @"shareItem"];
    
    if (albumUserId != userId) {
        [self.customMoreActionSheet addSelectItem: @"ic200_report_dark.png" title: @"檢舉" btnStr: @"" tagInt: 5 identifierStr: @"reportItem"];
    }
    
    __weak typeof(self) weakSelf = self;
    __block NSInteger weakAlbumPoint = albumPoint;
    
    self.customMoreActionSheet.customButtonBlock = ^(BOOL selected) {
        NSLog(@"customButtonBlock press");
        
        NSString *alertMsg = @"點選「觀看內容」並前往最後一頁可進行贊助額度設定";
        NSString *btnName = @"我知道了";
        [weakSelf showCustomAlert: alertMsg btnName: btnName];
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
                [weakSelf showCustomAlert: msgStr option: @"buyAlbum"];
            }
        } else if ([identifierStr isEqualToString: @"albumEdit"]) {
            NSLog(@"albumEdit item is pressed");
            [weakSelf toAlbumCreationViewController: weakSelf.albumId
                                         templateId: @"0"
                                    shareCollection: NO];
        } else if ([identifierStr isEqualToString: @"modifyInfo"]) {
            NSLog(@"modifyInfo item is pressed");
            [weakSelf toAlbumSettingViewController: weakSelf.albumId
                                        templateId: @"0"
                                   shareCollection: NO];
        } else if ([identifierStr isEqualToString: @"shareItem"]) {
            NSLog(@"shareItem is pressed");
            [weakSelf checkTaskComplete];
            //[weakSelf showCustomShareActionSheet];
        } else if ([identifierStr isEqualToString: @"reportItem"]) {
            NSLog(@"reportItem is pressed");
            [weakSelf insertReport];
        }
    };
}

- (void)showCustomShareActionSheet {
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
            
            if ([weakSelf.data[@"eventjoin"] isEqual: [NSNull null]]) {
                NSLog(@"eventjoin is null");
                content.contentURL = [NSURL URLWithString: [NSString stringWithFormat: sharingLinkWithAutoPlay, weakSelf.albumId, autoPlayStr]];
            } else {
                NSLog(@"eventjoin is not null");
                content.contentURL = [NSURL URLWithString: [NSString stringWithFormat: sharingLinkWithoutAutoPlay, weakSelf.albumId]];
            }
            
            [FBSDKShareDialog showFromViewController: weakSelf
                                         withContent: content
                                            delegate: weakSelf];
        } else if ([identifierStr isEqualToString: @"normalSharing"]) {
            NSLog(@"normalSharing is pressed");
            NSString *message;
            
            if ([weakSelf.data[@"eventjoin"] isEqual: [NSNull null]]) {
                NSLog(@"eventjoin is null");
                message = [NSString stringWithFormat: sharingLinkWithAutoPlay, weakSelf.albumId, autoPlayStr];
            } else {
                NSLog(@"eventjoin is not null");
                message = [NSString stringWithFormat: sharingLinkWithoutAutoPlay, weakSelf.albumId];
            }
            
            NSLog(@"message: %@", message);
            
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems: [NSArray arrayWithObjects: message, nil] applicationActivities: nil];
            [weakSelf presentViewController: activityVC animated: YES completion: nil];
        }
    };
}

#pragma mark - DDAUIActionSheetViewController Method
- (void)actionSheetViewDidSlideOut:(DDAUIActionSheetViewController *)controller
{
    NSLog(@"self: %@", self);
    NSLog(@"DDAUIActionSheetViewController");
    NSLog(@"actionSheetViewDidSlideOut");
    //[self.fxBlurView removeFromSuperview];
    [self.effectView removeFromSuperview];
    self.effectView = nil;
    
    [self retrieveAlbum];
}

#pragma mark - Methods for choosing viewControllers
- (void)toAlbumCreationViewController: (NSString *)albumId
                           templateId: (NSString *)templateId
                      shareCollection: (BOOL)shareCollection
{
    NSLog(@"toAlbumCreationViewController");
    
    AlbumCreationViewController *acVC = [[UIStoryboard storyboardWithName: @"AlbumCreationVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumCreationViewController"];
    //acVC.selectrow = [wTools userbook];
    acVC.albumid = albumId;
    acVC.templateid = [NSString stringWithFormat:@"%@", templateId];
    acVC.shareCollection = shareCollection;
    acVC.postMode = NO;
    acVC.fromVC = @"AlbumDetailVC";
    acVC.delegate = self;
    
    if ([templateId isEqualToString:@"0"]) {
        acVC.booktype = 0;
        acVC.choice = @"Fast";
    } else {
        acVC.booktype = 1000;
        acVC.choice = @"Template";
    }
    
    //[self.navigationController pushViewController: acVC animated: YES];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: acVC animated: YES];
}

- (void)toAlbumSettingViewController: (NSString *)albumId
                          templateId: (NSString *)templateId
                     shareCollection: (BOOL)shareCollection
{
    NSLog(@"toAlbumSettingViewController");
    
    AlbumSettingViewController *aSVC = [[UIStoryboard storyboardWithName: @"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumSettingViewController"];
    aSVC.albumId = albumId;
    aSVC.postMode = NO;
    aSVC.templateId = [NSString stringWithFormat:@"%@", templateId];
    aSVC.shareCollection = shareCollection;
    aSVC.fromVC = @"AlbumDetailVC";
    aSVC.delegate = self;
    
    //[self.navigationController pushViewController: aSVC animated: YES];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: aSVC animated: YES];
}

#pragma mark - insertAlbumToLikes

- (void)insertAlbumToLikes
{
    NSLog(@"insertAlbumToLikes");
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
        NSString *response = [boxAPI insertAlbum2Likes: [wTools getUserID]
                                                 token: [wTools getUserToken]
                                               albumId: self.albumId];
        
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
                NSLog(@"response from insertAlbum2Likes");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"AlbumDetailViewController");
                    NSLog(@"insertAlbumToLikes");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"insertAlbum2Likes"
                                             row: 0
                                         eventId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] boolValue]) {
                        likesInt++;
                        
                        [self.likeBtn setImage: [UIImage imageNamed: @"ic200_like_main"] forState: UIControlStateNormal];
                        self.likeNumberLabel.text = [NSString stringWithFormat: @"%ld", (long)likesInt];
                        
                        isLikes = !isLikes;
                        NSLog(@"isLikes: %d", isLikes);
                        
                        [self retrieveAlbum];
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
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI deleteAlbum2Likes: [wTools getUserID] token: [wTools getUserToken] albumId: self.albumId];
        
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
                NSLog(@"response from deleteAlbum2Likes");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"AlbumDetailViewController");
                    NSLog(@"deleteAlbumToLikes");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"deleteAlbum2Likes"
                                             row: 0
                                         eventId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] boolValue]) {
                        likesInt--;
                        
                        [self.likeBtn setImage: [UIImage imageNamed: @"ic200_like_dark"] forState: UIControlStateNormal];
                        self.likeNumberLabel.text = [NSString stringWithFormat: @"%ld", (long)likesInt];
                        
                        isLikes = !isLikes;
                        
                        [self retrieveAlbum];
                    } else {
                        NSLog(@"失敗：%@", dic[@"message"]);
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FBSDKSharing Delegate Methods

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
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

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    NSLog(@"Sharing didFailWithError");
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    NSLog(@"Sharing Did Cancel");
}


#pragma mark - Custom AlertView for Getting Point
- (void)showAlertPointView {
    NSLog(@"Show Alert View");
    
    // Custom AlertView shows up when getting the point
    alertGetPointView = [[OldCustomAlertView alloc] init];
    [alertGetPointView setContainerView: [self createPointView]];
    [alertGetPointView setButtonTitles: [NSMutableArray arrayWithObject: @"確     認"]];
    [alertGetPointView setUseMotionEffects: true];
    
    [alertGetPointView show];
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

- (void)showTheActivityPage
{
    NSLog(@"showTheActivityPage");
    
    //NSString *activityLink = @"http://www.apple.com";
    NSString *activityLink = eventUrl;
    
    NSURL *url = [NSURL URLWithString: activityLink];
    
    // Close for present safari view controller, otherwise alertView will hide the background
    [alertGetPointView close];
    
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: url entersReaderIfAvailable: NO];
    safariVC.delegate = self;
    safariVC.preferredBarTintColor = [UIColor whiteColor];
    [self presentViewController: safariVC animated: YES completion: nil];
}

#pragma mark - SFSafariViewController delegate methods
- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller
{
    // Done button pressed
    
    NSLog(@"show");
    [alertGetPointView show];
}

#pragma mark - Custom Alert Method
- (void)showCustomAlert: (NSString *)msg option:(NSString *)option
{
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    [alertView setContainerView: [self createContainerView: msg]];
    
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertView.arrangeStyle = @"Horizontal";
    
    if ([option isEqualToString: @"buyAlbum"]) {
        [alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"取消", @"確定", nil]];
    }
    if ([option isEqualToString: @"buyPoint"]) {
        [alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"稍後再說", @"前往購點", nil]];
    }
    
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor firstMain],nil]];
    [alertView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor whiteColor], nil]];
    [alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    
    __weak CustomIOSAlertView *weakAlertView = alertView;
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        
        [weakAlertView close];
        
        if (buttonIndex == 0) {
            
        } else {
            if ([option isEqualToString: @"buyAlbum"]) {
                [self getPoint];
            }
            if ([option isEqualToString: @"buyPoint"]) {
                BuyPPointViewController *bPPVC = [[UIStoryboard storyboardWithName: @"BuyPointVC" bundle: nil] instantiateViewControllerWithIdentifier: @"BuyPPointViewController"];
                //[self.navigationController pushViewController: bPPVC animated: YES];
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [appDelegate.myNav pushViewController: bPPVC animated: YES];
            }
        }
    }];
    [alertView setUseMotionEffects: YES];
    [alertView show];
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

#pragma mark - Dismiss View
- (void)dismissPopup {
    NSLog(@"dismissPopup");
    
    for (UIView *view in self.view.subviews) {
        NSLog(@"view: %@", view);
        
        NSLog(@"y: %f", view.frame.origin.y);
    }
    
    for (UIView *view in self.view.subviews) {
        NSLog(@"view.tag: %ld", (long)view.tag);
    }
    
    NSLog(@"self.popupViewController: %@", self.popupViewController);
    
    if (self.popupViewController != nil) {
        [self dismissPopupViewControllerAnimated:YES completion:^{
            NSLog(@"popup view dismissed");
        }];
    }
}

#pragma mark - UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    NSLog(@"shouldReceiveTouch");
    NSLog(@"self.view.tag: %ld", (long)self.view.tag);
    
    //return touch.view == self.view;
    
    NSLog(@"touch.view: %@", touch.view);
    
    /*
     if ([touch.view isKindOfClass: [UIScrollView class]]) {
     NSLog(@"touch.view isKindOf UIScrollView Class");
     
     TestReadBookViewController *testReadBookVC = [[UIStoryboard storyboardWithName: @"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"TestReadBookViewController"];
     
     NSLog(@"self.data photo: %@", self.data[@"photo"]);
     
     testReadBookVC.dic = self.data;
     testReadBookVC.isDownloaded = NO;
     testReadBookVC.albumid = self.albumId;
     
     [self.navigationController pushViewController: testReadBookVC animated: YES];
     }
     */
    
    if (touch.view.tag == 200) {
        return NO;
    } else {
        return YES;
    }
    
    /*
     if ([touch.view isKindOfClass: [MyLinearLayout class]]) {
     NSLog(@"touch.view is kindOfClass MyLinearLayout");
     return YES;
     }
     */
    /*
     if ((touch.view == newMessageBoardVC.view) && (gestureRecognizer == tapGR)) {
     return YES;
     }
     */
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesBegan");
    
    CGPoint location = [[touches anyObject] locationInView: self.view];
    CGRect fingerRect = CGRectMake(location.x - 5, location.y - 5, 10, 10);
    
    for (UIView *view in self.view.subviews) {
        CGRect subviewFrame = view.frame;
        
        if (CGRectIntersectsRect(fingerRect, subviewFrame)) {
            NSLog(@"finally touched view: %@", view);
            NSLog(@"view.tag: %ld", (long)view.tag);
        }
    }
}

- (void)headerImgBtnPress:(id)sender
{
    NSLog(@"AlbumDetailVC");
    NSLog(@"headerImgBtnPress");
    
    [self checkContentBtnPress: nil];
}


#pragma mark - TestReadBookViewControllerDelegate Method
- (void)testReadBookViewControllerViewWillDisappear:(TestReadBookViewController *)controller likeNumber:(NSUInteger)likeNumber isLike:(BOOL)isLike
{
    NSLog(@"");
    NSLog(@"testReadBookViewControllerViewWillDisappear");
    
    //[self retrieveAlbum];
}

#pragma mark - UITextViewDelegate Methods
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    NSLog(@"URL: %@", URL);
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: URL entersReaderIfAvailable: NO];
    safariVC.preferredBarTintColor = [UIColor whiteColor];
    [self presentViewController: safariVC animated: YES completion: nil];
    
    return NO;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - Custom Error Alert Method
- (void)showCustomOKAlert: (NSString *)msg
{
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    [alertView setContainerView: [self createCustomOKContainerView: msg]];
    
    [alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    [alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    [alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertView.arrangeStyle = @"Horizontal";
    
    /*
     [alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
     [alertView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor firstMain], [UIColor firstPink], [UIColor secondGrey], nil]];
     [alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor darkMain], [UIColor darkPink], [UIColor firstGrey], nil]];
     alertView.arrangeStyle = @"Vertical";
     */
    
    __weak CustomIOSAlertView *weakAlertView = alertView;
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        [weakAlertView close];
    }];
    [alertView setUseMotionEffects: YES];
    [alertView show];
}

- (UIView *)createCustomOKContainerView: (NSString *)msg
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

- (void)showCustomErrorAlert: (NSString *)msg
{
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    [alertView setContainerView: [self createCustomErrorContainerView: msg]];
    
    [alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    [alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    [alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertView.arrangeStyle = @"Horizontal";
    
    /*
     [alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
     [alertView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor firstMain], [UIColor firstPink], [UIColor secondGrey], nil]];
     [alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor darkMain], [UIColor darkPink], [UIColor firstGrey], nil]];
     alertView.arrangeStyle = @"Vertical";
     */
    
    __weak CustomIOSAlertView *weakAlertView = alertView;
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        [weakAlertView close];
    }];
    [alertView setUseMotionEffects: YES];
    [alertView show];
}

- (UIView *)createCustomErrorContainerView: (NSString *)msg
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
                           row: (NSInteger)row
                       eventId: (NSString *)eventId
{
    CustomIOSAlertView *alertTimeOutView = [[CustomIOSAlertView alloc] init];
    alertTimeOutView.parentView = self.view;
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
            if ([protocolName isEqualToString: @"checkTaskCompleted"]) {
                [weakSelf checkTaskComplete];
            } else if ([protocolName isEqualToString: @"geturpoints"]) {
                [weakSelf getPoint];
            } else if ([protocolName isEqualToString: @"buyalbum"]) {
                [weakSelf buyAlbum];
            } else if ([protocolName isEqualToString: @"doTask2"]) {
                [weakSelf checkPoint];
            } else if ([protocolName isEqualToString: @"getreportintentlist"]) {
                [weakSelf insertReport];
            } else if ([protocolName isEqualToString: @"retrievealbump"]) {
                [weakSelf retrieveAlbum];
            } else if ([protocolName isEqualToString: @"insertreport"]) {
                [weakSelf SaveDataRow: row];
            } else if ([protocolName isEqualToString: @"insertAlbum2Likes"]) {
                [weakSelf insertAlbumToLikes];
            } else if ([protocolName isEqualToString: @"deleteAlbum2Likes"]) {
                [weakSelf deleteAlbumToLikes];
            } else if ([protocolName isEqualToString: @"getUrPoints"]) {
                [weakSelf pointsUPdate];
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

- (void)newMessageBoardViewControllerDisappear:(NewMessageBoardViewController *)controller msgNumber:(NSUInteger)msgNumber
{
    NSLog(@"newMessageBoardViewControllerDisappear");
    //[self retrieveAlbum];
}

- (void)albumCreationViewControllerBackBtnPressed:(AlbumCreationViewController *)controller {
    //[self retrieveAlbum];
}

- (void)albumSettingViewControllerUpdate:(AlbumSettingViewController *)controller {
    NSLog(@"albumSettingViewControllerUpdate");
    //[self retrieveAlbum];
}

- (void)dealloc {
    NSLog(@"AlbumDetailViewController");
    NSLog(@"dealloc");
}

@end
