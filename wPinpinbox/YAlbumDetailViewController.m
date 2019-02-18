//
//  YAlbumDetailViewController.m
//  wPinpinbox
//
//  Created by Antelis on 2019/1/7.
//  Copyright © 2019 Angus. All rights reserved.
//

#import "YAlbumDetailViewController.h"
#import "YAlbumDetailHeaderCell.h"

#import "wTools.h"
#import "boxAPI.h"
#import "GlobalVars.h"

#import "CustomIOSAlertView.h"
#import "UIColor+Extensions.h"
#import "UIColor+HexString.h"
#import "UIView+Toast.h"

#import "UIViewController+ErrorAlert.h"
#import "AppDelegate.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <FBSDKShareKit/FBSDKShareLinkContent.h>
#import <FBSDKShareKit/FBSDKShareDialog.h>
#import <SafariServices/SafariServices.h>

#import "ContentCheckingViewController.h"
#import "CreaterViewController.h"
#import "LikeListViewController.h"
#import "AlbumSponsorListViewController.h"
#import "DDAUIActionSheetViewController.h"
#import "MessageboardViewController.h"
#import "AlbumCreationViewController.h"
#import "AlbumSettingViewController.h"
#import "BuyPPointViewController.h"
#import "NewEventPostViewController.h"

#import "OldCustomAlertView.h"
#import "SelectBarViewController.h"
#import "UIViewController+CWPopup.h"
#import "LabelAttributeStyle.h"

static NSString *autoPlayStr = @"&autoplay=1";

@interface YAlbumDetailViewController ()<UITableViewDataSource, UITableViewDelegate,
ContentCheckingViewControllerDelegate,MessageboardViewControllerDelegate,DDAUIActionSheetViewControllerDelegate,
AlbumCreationViewControllerDelegate,AlbumSettingViewControllerDelegate,FBSDKSharingDelegate,SFSafariViewControllerDelegate,SelectBarDelegate>
@property(nonatomic) NSMutableDictionary *albumInfo;
@property(nonatomic) NSString *album_id;
@property(nonatomic) BOOL isViewed;
@property(nonatomic) BOOL isPosting;
@property(nonatomic) NSString *albumType;
@property(nonatomic) NSString *task_for;
@property(nonatomic) BOOL isCollected;
@property(nonatomic) NSInteger albumPoint;
@property(nonatomic) NSString *eventUrl;
@property(nonatomic) NSArray *reportIntentList;

@property(nonatomic) OldCustomAlertView *alertGetPointView;
@property(nonatomic) IBOutlet UITableView *detailView;

@property(nonatomic) IBOutlet UIButton *messageBtn;
@property(nonatomic) IBOutlet UIButton *likeBtn;
@property(nonatomic) IBOutlet UIButton *moreBtn;
@property(nonatomic) IBOutlet UITableView *infoView;
@property(nonatomic) IBOutlet UIKernedButton *contentButton;
@property(nonatomic) IBOutlet NSLayoutConstraint *headerHeight;
@property(nonatomic) IBOutlet NSLayoutConstraint *coverHeight;
@property(nonatomic) IBOutlet NSLayoutConstraint *infoHeight;
@property(nonatomic) IBOutlet UIKernedButton *collectBtn;

@property (nonatomic) DDAUIActionSheetViewController *customMoreActionSheet;
@property (nonatomic) DDAUIActionSheetViewController *customShareActionSheet;
@property (nonatomic) MessageboardViewController *customMessageActionSheet;
@property (nonatomic) UIVisualEffectView *effectView;

- (void)showCustomAlert:(NSString *)msg btnName:(NSString *)btnName;
@end

@implementation YAlbumDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.albumInfo = [NSMutableDictionary dictionary];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //  album detail is changed outward //
    [self checkCollectedOutward];
    [wTools setStatusBarBackgroundColor:[UIColor clearColor]];
}

- (void)setupAlbumWithInfo:(NSDictionary *)info albumId:(NSString *)albumId {
    self.album_id = albumId;
    [self checkAlbumId:self.album_id];
    [self.albumInfo setDictionary:info];
    [self prepareCoverView];
    [self pointsUpdate];
    [self.detailView reloadData];
    
    if (_isMessageShowing) {
        [self messageBtnTouched:self.messageBtn];
    }
    self.albumPoint = [self.albumInfo[@"album"][@"point"] integerValue];
    self.isCollected = [self.albumInfo[@"album"][@"own"] boolValue];
}
- (void)setAlubumId:(NSString *)aid {
    self.album_id = aid;
    [self checkAlbumId:self.album_id];
    if (self.albumInfo.allKeys.count < 1)
        [self retrieveAlbum:self.album_id silence:NO];
}
- (void)checkAlbumId:(NSString *)albumId {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *array = [defaults objectForKey: @"albumIdArray"];
    
    
    // Get the albumIdArray from Device
    if (array != nil) {
    
        NSMutableArray *albumIdArray  = [NSMutableArray arrayWithArray: array];

        if ([albumIdArray containsObject: albumId]) {
            self.isViewed = NO;
        } else {
            
            [albumIdArray addObject: albumId];
            
            self.isViewed = YES;
            
            [defaults setObject: albumIdArray forKey: @"albumIdArray"];
            [defaults synchronize];
        }
    } else {
        
        NSMutableArray *albumIdArray = [NSMutableArray new];
        [albumIdArray addObject: albumId];
        
        
        [defaults setObject: albumIdArray forKey: @"albumIdArray"];
        [defaults synchronize];
        
        self.isViewed = YES;
    }
}
- (BOOL)isPanValid {
    
    return self.effectView == nil;
}
- (void)setIsCollected:(BOOL)isCollected {
    _isCollected = isCollected;
    [self layoutCollectButton];
}
#pragma mark -
- (BOOL)isPointInHeader:(CGPoint)point {
    //CGRect r = [self.view convertRect:self.headerView.frame fromView:self.headerView];
    //return CGRectContainsPoint(r, point);
    return self.baseView.contentOffset.y < 1;
}
- (UIImageView *)albumCoverView{
    return self.headerView;
}
- (void)setContentBtnVisible {
    [self.contentButton setTitle:@"進入觀看" forState:UIControlStateNormal];
    self.contentButton.hidden = NO;
}
- (void)setHeaderPlaceholder:(UIImage *)placeholder {
    if (placeholder) {
        CGSize s = placeholder.size;
        CGFloat dh = (s.height/s.width)* [UIScreen mainScreen].bounds.size.width;
        CGFloat sh =  [UIScreen mainScreen].bounds.size.height;
        self.coverHeight.constant = dh;
        dh = (dh > sh*0.67)? sh*0.67:dh;
        self.headerView.image = placeholder;
        self.headerHeight.constant = dh;
    }
}
- (void)prepareCoverView {
    CGFloat sh =  [UIScreen mainScreen].bounds.size.height;
    if (![wTools objectExists:self.albumInfo[@"photo"]]) {
        UIImage *image = [UIImage imageNamed:@"bg_2_0_0_no_image.jpg"];
        CGSize s = image.size;
        CGFloat dh = (s.height/s.width)* [UIScreen mainScreen].bounds.size.width;
        self.coverHeight.constant = dh;
        dh = (dh > sh*0.67)? sh*0.67:dh;
        self.headerView.image = image;
        self.headerHeight.constant = dh;
        return;
    } else {
        NSArray *a = self.albumInfo[@"photo"];
        NSDictionary *p = a[0];
        if ([wTools objectExists:p[@"image_url"]]) {
            NSURL *u = [NSURL URLWithString:p[@"image_url"]];
            __block typeof(self) wself = self;
            UIImage *placholder = [UIImage imageWithCGImage:self.headerView.image.CGImage];
            
            [self.headerView sd_setImageWithURL:u placeholderImage:placholder  completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                if (error || image == nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIImage *image = [UIImage imageNamed:@"bg_2_0_0_no_image.jpg"];
                        CGSize s = image.size;
                        CGFloat dh = (s.height/s.width)* [UIScreen mainScreen].bounds.size.width;
                        self.coverHeight.constant = dh;
                        dh = (dh > sh*0.67)? sh*0.67:dh;
                        wself.headerView.image = image;
                        wself.headerHeight.constant = dh;
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        CGSize s = image.size;
                        CGFloat dh = (s.height/s.width)* [UIScreen mainScreen].bounds.size.width;
                        self.coverHeight.constant = dh;
                        dh = (dh > sh*0.67)? sh*0.67:dh;
                        wself.headerView.image = image;
                        wself.headerHeight.constant = dh;
                    });
                }
            }];
            //[header.albumHeader sd_setImageWithURL:u placeholderImage:];
        }
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToContent:)];
    [self.headerView addGestureRecognizer:tap];
    
    self.detailView.scrollEnabled = NO;
    self.infoHeight.constant = [self estimateInfoHeight];
    
    
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
    self.customMessageActionSheet.typeId = self.album_id;
    
    
    NSDictionary *album = self.albumInfo[@"album"];
    BOOL like = NO;
    if ([wTools objectExists:album[@"is_likes"]])
        like = [album[@"is_likes"] boolValue];
    if (like) {
        [self.likeBtn setImage: [UIImage imageNamed: @"ic200_ding_pink"] forState: UIControlStateNormal];
        self.likeBtn.tag = 111;
    }
    else {
        [self.likeBtn setImage: [UIImage imageNamed: @"ic200_ding_dark"] forState: UIControlStateNormal];
        self.likeBtn.tag = 0;
    }
}
- (CGFloat) estimateInfoHeight {
    CGFloat height = 0;
    height = [YAlbumLocationCell estimatedHeight:self.albumInfo[@"album"]]+
             [YAlbumContentTypeCell estimatedHeight:self.albumInfo[@"album"]]+
             [YAlbumDescCell estimatedHeight:self.albumInfo[@"album"]]+
             [YAlbumFollowerCell estimatedHeight:self.albumInfo[@"album"]]*3+
             [YAlbumCreatorCell estimatedHeight:self.albumInfo[@"user"]]+
             [YAlbumEventCell estimatedHeight:self.albumInfo[@"eventjoin"]]+
             [YAlbumTitleCell estimatedHeight:self.albumInfo[@"album"]];
    return height+32;
}
- (void)layoutCollectButton {
    
    NSString * u = [NSString stringWithFormat:@"%lu", [self.albumInfo[@"user"][@"user_id"] longValue] ];
    BOOL selfWork = [u isEqualToString: [wTools getUserID]];
    self.collectBtn.hidden = selfWork;
    
    if (!selfWork) {
        NSString *str = @"";
        if (!self.isCollected) {
            
            self.collectBtn.enabled = YES;
            [self.collectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            if (_albumPoint == 0) {
                str = @"收藏";
            } else if (_albumPoint > 0) {
                //if (_albumPoint > 1000)
                str = [NSString stringWithFormat: @"%ldP", (long)_albumPoint];
                //else
                //    str = [NSString stringWithFormat: @"收藏%ldP", (long)_albumPoint];
            }
            NSMutableDictionary *attDic = [NSMutableDictionary dictionary];
            [attDic setValue:@1 forKey:NSKernAttributeName];
            [attDic setValue:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
            NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:str attributes:attDic];
            [self.collectBtn setAttributedTitle:attStr forState:UIControlStateNormal];
        } else {
            str = @"已收藏";
            [self.collectBtn setBackgroundColor:[UIColor whiteColor]];
            self.collectBtn.layer.borderColor = [UIColor colorFromHexString:@"d4d4d4"].CGColor;
            self.collectBtn.layer.borderWidth = 0.8;
            UIImage *image = [UIImage imageNamed:@"ic200_albumdetail_collect"];
            UIImage *aimage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.collectBtn.imageView setTintColor:[UIColor colorFromHexString:@"d4d4d4"]];
            [self.collectBtn setImage:aimage forState:UIControlStateDisabled];
            self.collectBtn.enabled = NO;
            
            //[self.collectBtn setTitle:str forState:UIControlStateDisabled];
            NSMutableDictionary *attDic = [NSMutableDictionary dictionary];
            [attDic setValue:@1 forKey:NSKernAttributeName];
            [attDic setValue:[UIColor colorFromHexString:@"d4d4d4"] forKey:NSForegroundColorAttributeName];
            NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:str attributes:attDic];
            [self.collectBtn setAttributedTitle:attStr forState:UIControlStateDisabled];
        }
        
        
    }
}
- (NSInteger)getLikesCount {
    NSInteger c = 0;
    NSDictionary *data = self.albumInfo[@"albumstatistics"];
    if ([wTools objectExists: data[@"likes"]])
        c = (int)[data[@"likes"] integerValue];
    return c;
}
- (NSInteger)getAuthor {
    NSInteger aid = 0;
    
    if ([wTools objectExists:self.albumInfo[@"user"]]) {
        NSDictionary *u = self.albumInfo[@"user"];
        aid = [u[@"user_id"] integerValue];
    }
    return aid;
}
#pragma mark -
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (@available(iOS 11.0, *)) {
        [self.baseView setContentInset:UIEdgeInsetsMake(-(self.view.safeAreaLayoutGuide.layoutFrame.origin.y), 0, 0, 0)];
    } else {
        // Fallback on earlier versions
        [self.baseView setContentInset:UIEdgeInsetsMake(-20, 0, 0, 0)];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 1: {
            return [YAlbumLocationCell estimatedHeight:self.albumInfo[@"album"]];
        } break;
        case 2:{
            return [YAlbumContentTypeCell estimatedHeight:self.albumInfo[@"album"]];
        } break;
        case 3: {
            return [YAlbumDescCell estimatedHeight:self.albumInfo[@"album"]];
        } break;
        case 5: {
            return [YAlbumPointCell estimatedHeight:self.albumInfo[@"user"]];
        }
        case 4:
        case 6: {
            return [YAlbumFollowerCell estimatedHeight:self.albumInfo[@"album"]];
        } break;
        case 7: {
            return [YAlbumCreatorCell estimatedHeight:self.albumInfo[@"user"]];
            
        } break;
        case 8: {
            if ([self.fromVC isEqualToString:@"VotingVC"]) {
                return 0;
            }
            return [YAlbumEventCell estimatedHeight:self.albumInfo[@"eventjoin"]];
            
        } break;
        default: {
            return [YAlbumTitleCell estimatedHeight:self.albumInfo[@"album"]];
            
        }
            
    }
    
    return 0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.albumInfo.allKeys.count < 1) return 0;
    
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    switch (indexPath.section) {

        case 1: {
            YAlbumLocationCell *cell = (YAlbumLocationCell *)[tableView dequeueReusableCellWithIdentifier:@"YAlbumLocationCell"];
            [cell loadData:self.albumInfo];
            return cell;
        } break;
        case 2: {
            YAlbumContentTypeCell *cell = (YAlbumContentTypeCell *)[tableView dequeueReusableCellWithIdentifier:@"YAlbumContentTypeCell"];
            NSDictionary *a = self.albumInfo[@"album"];
            NSDictionary *use = a[@"usefor"];
            [cell loadData:use];
            return cell;
        } break;
        case 3: {
            YAlbumDescCell *cell = (YAlbumDescCell *)[tableView dequeueReusableCellWithIdentifier:@"YAlbumDescCell"];
            [cell loadData:self.albumInfo[@"album"]];
            return cell;
        } break;
        case 4: {
            YAlbumFollowerCell *cell = (YAlbumFollowerCell *)[tableView dequeueReusableCellWithIdentifier:@"YAlbumFollowerCell"];
            
            [cell loadData:self.albumInfo[@"albumstatistics"]];
            return cell;
        } break;
        case 5: {
            YAlbumPointCell *cell = (YAlbumPointCell *)[tableView dequeueReusableCellWithIdentifier:@"YAlbumPointCell"];
            [cell loadData:self.albumInfo[@"albumstatistics"]];
            return cell;

        } break;
        case 6: {
            YAlbumMessageCell *cell = (YAlbumMessageCell *)[tableView dequeueReusableCellWithIdentifier:@"YAlbumMessageCell"];
            [cell loadData:self.albumInfo[@"albumstatistics"]];
            return cell;
        } break;
        case 7: {
            YAlbumCreatorCell *cell = (YAlbumCreatorCell *)[tableView dequeueReusableCellWithIdentifier:@"YAlbumCreatorCell"];
            //cell.creatorWorks.hidden = [self.fromVC isEqualToString:@"creatorVC"];
            [cell loadData:self.albumInfo];
            
            
            if (![cell.creatorWorks.allTargets containsObject:self]) {
                [cell.creatorWorks addTarget:self action:@selector(moreAlbumList:) forControlEvents:UIControlEventTouchUpInside];
            }
            return cell;
        } break;
        case 8: {
            YAlbumEventCell *cell = (YAlbumEventCell *)[tableView dequeueReusableCellWithIdentifier:@"YAlbumEventCell"];
            [cell loadData:self.albumInfo];
            if (![cell.voteBtn.allTargets containsObject:self]) {
                [cell.voteBtn addTarget:self action:@selector(handleVotePressed:) forControlEvents:UIControlEventTouchUpInside];
            }
            return cell;
            
        } break;
        default: {
            YAlbumTitleCell *title = (YAlbumTitleCell *)[tableView dequeueReusableCellWithIdentifier:@"YAlbumTitleCell"];
            NSDictionary *a = self.albumInfo[@"album"];
            [title loadData:a];
            return title;
        }
            
    }
    
    YAlbumTitleCell *title = (YAlbumTitleCell *)[tableView dequeueReusableCellWithIdentifier:@"YAlbumTitleCell"];

    return title;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 4: {
            LikeListViewController *likesListVC = [[UIStoryboard storyboardWithName: @"LikeListVC" bundle: nil] instantiateViewControllerWithIdentifier: @"LikeListViewController"];
            likesListVC.albumId = self.album_id;
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [app.myNav pushViewController: likesListVC animated: YES];
            break;
        }
        case 5: {
            AlbumSponsorListViewController *albumSponsorListVC = [[UIStoryboard storyboardWithName: @"AlbumSponsorVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumSponsorListViewController"];
            albumSponsorListVC.albumId = self.album_id;
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate.myNav pushViewController: albumSponsorListVC animated: YES];
            break;
        }
        case 6: {
            [self showCustomMessageActionSheet];
            break;
        }
        default:
            break;
    }
}
#pragma mark -
- (void)tapToContent:(UITapGestureRecognizer *)gesture {
    [self viewContentTouched:self.contentButton];
}
- (IBAction)collectBtnTouched:(id)sender {
    if (_albumPoint > 0) {
        BOOL rewardAfterCollect = [self.albumInfo[@"album"][@"reward_after_collect"] boolValue];
        NSLog(@"rewardAfterCollect: %d", rewardAfterCollect);
        NSString *msgStr;
        
        if (rewardAfterCollect) {
            msgStr = [NSString stringWithFormat: @"點選「進入觀看」並前往最後一頁可填寫回饋表單"];
            [self showCustomAlert: msgStr btnName: @"我知道了"];
        } else {
            NSString *msgStr = [NSString stringWithFormat: @"確定贊助%ldP(NTD%ld)?\n點選「觀看內容」並前往最後一頁可進行贊助額度設定", (long)_albumPoint, (long)_albumPoint / 2];
            [self showCustomAlert: msgStr option: @"buyAlbum"];
        }
    } else {
        [self buyAlbum];
    }
}
- (IBAction)messageBtnTouched:(id)sender {
    [self showCustomMessageActionSheet];
}
- (IBAction)likeBtnTouched:(id)sender {
    if (self.likeBtn.tag == 0) {
        [self insertAlbumToLikes];
    } else
        [self deleteAlbumToLikes];
}
- (IBAction)moreBtnTouched:(id)sender {
    [self showCustomMoreActionSheet];
}
- (IBAction)viewContentTouched:(id)sender {
    
    if (![wTools objectExists: self.album_id]) {
        return;
    }
    ContentCheckingViewController *contentCheckingVC = [[UIStoryboard storyboardWithName: @"ContentCheckingVC" bundle: nil] instantiateViewControllerWithIdentifier: @"ContentCheckingViewController"];
    contentCheckingVC.albumId = self.album_id;
    contentCheckingVC.isLikes = [self getLikesCount];
    contentCheckingVC.eventJoin = self.albumInfo[@"eventjoin"];
    contentCheckingVC.delegate = self;
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: contentCheckingVC animated: YES];
}
- (IBAction)moreAlbumList:(id)sender {
    if ([self.fromVC isEqualToString:@"creatorVC"]) {
        [self.dismissBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    } else {
        if ([wTools objectExists:self.albumInfo[@"user"][@"user_id"]]) {
            CreaterViewController *cVC = [[UIStoryboard storyboardWithName: @"CreaterVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CreaterViewController"];
            cVC.userId = self.albumInfo[@"user"][@"user_id"];
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate.myNav pushViewController: cVC animated: YES];
        }
        
    }
}

#pragma mark - API
- (void)pointsUpdate {
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

- (void)retrieveAlbum:(NSString *)aid silence:(BOOL)silence {
    
    if (!silence)
        [DGHUDView start];
    __block NSString *viewedString = [NSString stringWithFormat: @"%d", self.isViewed];
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = nil;
        if (wself.noparam)
            response = [boxAPI retrievealbump: aid
                                          uid: [wTools getUserID]
                                        token: [wTools getUserToken]];                                       
        else
            response = [boxAPI retrievealbump: aid
                                      uid: [wTools getUserID]
                                    token: [wTools getUserToken]
                                   viewed: viewedString];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [DGHUDView stop];
            } @catch (NSException *exception) {
                return;
            }
            
            if (response != nil) {
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"retrievealbump"
                                             row: 0
                                         eventId: @""];
                } else {
                    
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        [wself setupAlbumWithInfo:dic[@"data"] albumId:wself.album_id];
                    } else if ([dic[@"result"] intValue] == 0) {
                        
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
- (void)getEventData: (NSString *)eventId {
    
    @try {
        [DGHUDView start];
    } @catch (NSException *exception) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI getEvent: [wTools getUserID]
                                        token: [wTools getUserToken]
                                     event_id: eventId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [DGHUDView stop];
            } @catch (NSException *exception) {
                // Print exception information
                return;
            }
            if (response != nil) {
                
                if ([response isEqualToString: timeOutErrorCode]) {
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
                        [newEventPostVC prepareData:data[@"data"] eventId:eventId finished:NO];
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate.myNav pushViewController: newEventPostVC animated: YES];
                        
                    } else if ([data[@"result"] intValue] == 0) {
                        NSLog(@"失敗： %@", data[@"message"]);
                        if ([wTools objectExists: data[@"message"]]) {
                            [self showCustomErrorAlert: data[@"message"]];
                        } else {
                            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                        }
                    } else if ([data[@"result"] intValue] == 2) {
                        NewEventPostViewController *newEventPostVC = [[UIStoryboard storyboardWithName: @"NewEventPostVC" bundle: nil] instantiateViewControllerWithIdentifier: @"NewEventPostViewController"];
                        [newEventPostVC prepareData:data[@"data"] eventId:eventId finished:YES];
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate.myNav pushViewController: newEventPostVC animated: YES];
                    } else {
                        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}
- (void)checkTaskComplete {

    @try {
        [DGHUDView start];
    } @catch (NSException *exception) {
        // Print exception information
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI checkTaskCompleted: [wTools getUserID]
                                                  token: [wTools getUserToken]
                                               task_for: @"share_to_fb"
                                               platform: @"apple"
                                                   type: @"album"
                                                 typeId: self.album_id];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [DGHUDView stop];
            } @catch (NSException *exception) {
                // Print exception information
                return;
            }
            if (response != nil) {
                if ([response isEqualToString: timeOutErrorCode]) {
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"checkTaskCompleted"
                                             row: 0
                                         eventId: @""];
                } else {
                
                    NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    NSLog(@"data: %@", data);
                    NSLog(@"data message: %@", data[@"message"]);
                    
                    if ([data[@"result"] intValue] == 1) {
                        // Task is completed, so calling the original sharing function
                        //[wTools Activitymessage:[NSString stringWithFormat: sharingLink , _album_id, autoPlayStr]];
                        NSString *message;
                        
                        if ([self.albumInfo[@"eventjoin"] isEqual: [NSNull null]]) {
                            message = [NSString stringWithFormat: sharingLinkWithAutoPlay, self.album_id, autoPlayStr];
                        } else {
                            message = [NSString stringWithFormat: sharingLinkWithoutAutoPlay, self.album_id];
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
                        
                        if ([self.albumInfo[@"eventjoin"] isEqual: [NSNull null]]) {
                            message = [NSString stringWithFormat: sharingLinkWithAutoPlay, self.album_id, autoPlayStr];
                        } else {
                            message = [NSString stringWithFormat: sharingLinkWithoutAutoPlay, self.album_id];
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

- (void)getPoint {
    @try {
        [DGHUDView start];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [boxAPI geturpoints: [wTools getUserID]
                                           token: [wTools getUserToken]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [DGHUDView stop];
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
                    NSLog(@"Time Out Message Return -- getPoint");
                   
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                     protocolName: @"geturpoints"
                                              row: 0
                                          eventId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        if (![wTools objectExists: dic[@"data"]]) {
                            return;
                        }
                        NSInteger point = [dic[@"data"] integerValue];
                        NSLog(@"%ld", (long)point);
                        
                        if (point >= wself.albumPoint) {
                            [wself buyAlbum];
                        } else {
                            [wself showCustomAlert: @"你的P點不足，前往購點?" option: @"buyPoint"];
                        }
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

- (void)buyAlbum {
    NSLog(@"buyAlbum");
    @try {
        [DGHUDView start];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [boxAPI buyalbum: [wTools getUserID]
                                        token: [wTools getUserToken]
                                      albumid: self.album_id];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [DGHUDView stop];
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
                    NSLog(@"Time Out Message Return -- buyAlbum");
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

                        [wself.view makeToast: @"成功加入收藏"
                                     duration: 2.0
                                     position: CSToastPositionBottom
                                        style: style];

                        [wself checkAlbumCollectTask];
                        wself.isCollected = YES;
                        
                    } else if ([dic[@"result"] intValue] == 2) {
                        [wself showCustomErrorAlert: @"已擁有該相本"];
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗： %@", dic[@"message"]);
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

- (void)insertReport {
    NSLog(@"insertReport");
    @try {
        [DGHUDView start];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [boxAPI getreportintentlist: [wTools getUserID]
                                                   token: [wTools getUserToken]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [DGHUDView stop];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                return;
            }
            if (response != nil) {
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return -- insertReport");
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                     protocolName: @"getreportintentlist"
                                              row: 0
                                          eventId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    [wself processReportResult:dic];
                }
            }
        });
    });
}
#pragma mark - SelectBarDelegate
- (void)SaveDataRow:(NSInteger)row {
    NSLog(@"SaveDataRow: row: %ld", (long)row);
    NSString *rid = [self.reportIntentList[row][@"reportintent_id"] stringValue];
    @try {
        [DGHUDView start];
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
                                           typeid: self.album_id];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [DGHUDView stop];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                return;
            }
            if (response != nil) {
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return -- SaveDataRow");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"insertreport"
                                             row: row
                                         eventId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    NSString *msg = @"";
                    
                    if ([dic[@"result"] intValue] == 1) {
                        msg = NSLocalizedString(@"Works-tipRpSuccess", @"");
                        [self showCustomAlert:msg btnName:@"關 閉"];
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
#pragma mark - Event
- (IBAction)handleVotePressed:(id)sender {

    NSString *eventIdString = [self.albumInfo[@"event"][@"event_id"] stringValue];
    
    if (![eventIdString isEqual: [NSNull null]]) {
        if (![eventIdString isEqualToString: @""]) {
            [self getEventData: eventIdString];
        }
    }


}
#pragma mark - Buy Album
- (void)checkAlbumCollectTask {
    NSLog(@"checkAlbumCollectTask");
    if (_albumPoint == 0) {
        _task_for = @"collect_free_album";
    } else if (_albumPoint > 0) {
        _task_for = @"collect_pay_album";
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([_task_for isEqualToString: @"collect_free_album"]) {
        // Check whether getting Free Album point or not
        BOOL collect_free_album = [[defaults objectForKey: @"collect_free_album"] boolValue];
        NSLog(@"Check whether getting Album Saving point or not");
        NSLog(@"collect_free_album: %d", (int)collect_free_album);
        
        if (collect_free_album) {
            NSLog(@"Get the First Time Album Saving Point Already");
            [self retrieveAlbum:self.album_id silence:NO];
        } else {
            NSLog(@"Haven't got the point of saving album for first time");
            [self checkPoint];
        }
    } else if ([_task_for isEqualToString: @"collect_pay_album"]) {
        // Check whether getting Pay Album Point or not
        BOOL collect_pay_album = [[defaults objectForKey: @"collect_pay_album"] boolValue];
        NSLog(@"Check whether getting paid album point or not");
        NSLog(@"collect_pay_album: %d", (int)collect_pay_album);
        
        if (collect_pay_album) {
            NSLog(@"Getting Paid Album Point Already");
            [self retrieveAlbum:self.album_id silence:NO];
        } else {
            NSLog(@"Haven't got the point of saving paid album for first time");
            [self checkPoint];
        }
    }
}

- (void)checkPoint {
    NSLog(@"checkPoint");
    @try {
        [DGHUDView start];
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
                                    task_for: wself.task_for
                                    platform: @"apple"
                                        type: @"album"
                                     type_id: wself.album_id];
        
        NSLog(@"User ID: %@", [wTools getUserID]);
        NSLog(@"Token: %@", [wTools getUserToken]);
        NSLog(@"Task_For: %@", wself.task_for);
        NSLog(@"Album ID: %@", wself.album_id);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [DGHUDView stop];
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
                    NSLog(@"Time Out Message Return -- checkPoint");
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                     protocolName: @"doTask2"
                                              row: 0
                                          eventId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    [wself processCheckPointResult:data];
                }
            }
        });
    });
}
#pragma mark -
- (void)showTheActivityPage {
    NSLog(@"showTheActivityPage");
    //NSString *activityLink = @"http://www.apple.com";
    
    if (![wTools objectExists: _eventUrl]) {
        return;
    }
    
    NSString *activityLink = _eventUrl;
    NSURL *url = [NSURL URLWithString: activityLink];
    // Close for present safari view controller, otherwise alertView will hide the background
    [self.alertGetPointView close];
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: url entersReaderIfAvailable: NO];
    safariVC.delegate = self;
    safariVC.preferredBarTintColor = [UIColor whiteColor];
    [self presentViewController: safariVC animated: YES completion: nil];
}

- (void)processCheckPointResult:(NSDictionary *)data {
    if ([data[@"result"] intValue] == 1) {
        
        self.eventUrl = data[@"data"][@"event"][@"url"];
        
        [self showAlertViewForGettingPoint:data[@"data"][@"task"] eventURL:self.eventUrl];
        [self saveCollectInfoToDevice: NO];
        [self retrieveAlbum:self.album_id silence:NO];
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
- (void)showAlertViewForGettingPoint:(NSDictionary *)task eventURL:(NSString *)eventURL {
    NSString *missionTopicStr = task[@"name"];
    //NSString *rewardType = task[@"reward"];
    NSString *rewardValue = task[@"reward_value"];
    NSString *restriction = task[@"restriction"];
    NSString *restrictionValue = task[@"restriction_value"];
    NSInteger numberOfCompleted = [task[@"numberofcompleted"] unsignedIntegerValue];
    
    UIView *pointView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 250, 250)];
    // Mission Topic Label
    UILabel *missionTopicLabel = [[UILabel alloc] initWithFrame: CGRectMake(10, 15, 200, 10)];
    //missionTopicLabel.text = @"收藏相本得點";
    
    if ([wTools objectExists: missionTopicStr]) {
        missionTopicLabel.text = missionTopicStr;
    }
    
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
    imageView.center = CGPointMake(pointView.frame.size.width / 2, pointView.frame.size.height / 2);
    [pointView addSubview: imageView];
    
    NSLog(@"imageView.center: %@", NSStringFromCGPoint(imageView.center));
    
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
    
    if ([_eventUrl isEqual: [NSNull null]] || _eventUrl == nil) {
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
    
    
    self.alertGetPointView = [[OldCustomAlertView alloc] init];
    [self.alertGetPointView setContainerView: pointView];//[self createPointView]];
    [self.alertGetPointView setButtonTitles: [NSMutableArray arrayWithObject: @"確     認"]];
    [self.alertGetPointView setUseMotionEffects: true];
    [self.alertGetPointView show];
    
}
- (void)saveCollectInfoToDevice: (BOOL)isCollect {
    if ([_task_for isEqualToString: @"collect_free_album"]) {
        // Save data for first collect album
        BOOL collect_free_album = isCollect;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject: [NSNumber numberWithBool: collect_free_album]
                     forKey: @"collect_free_album"];
        [defaults synchronize];
    } else if ([_task_for isEqualToString: @"collect_pay_album"]) {
        // Save data for first collect paid album
        BOOL collect_pay_album = isCollect;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject: [NSNumber numberWithBool: collect_pay_album]
                     forKey: @"collect_pay_album"];
        [defaults synchronize];
    }
}
#pragma mark - Report Section
- (void)processReportResult:(NSDictionary *)dic {
    if ([dic[@"result"] intValue] == 1) {
        self.reportIntentList = dic[@"data"];
        SelectBarViewController *mv = [[SelectBarViewController alloc] initWithNibName: @"SelectBarViewController" bundle: nil];
        NSMutableArray *strArr = [NSMutableArray new];
        
        for (int i = 0; i < self.reportIntentList.count; i++) {
            [strArr addObject: self.reportIntentList[i][@"name"]];
        }
        mv.data = strArr;
        mv.delegate = self;
        mv.topViewController = self;
        [self wpresentPopupViewController: mv animated: YES completion: nil];
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



- (void)cancelButtonPressed {
    NSLog(@"cancelButtonPressed");
}

#pragma mark - Custom Method for TimeOut
- (void)showCustomErrorAlert: (NSString *)msg {
    [UIViewController showCustomErrorAlertWithMessage:msg onButtonTouchUpBlock:^(CustomIOSAlertView *customAlertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[customAlertView tag]);
        [customAlertView close];
    }];
}

- (void)showCustomTimeOutAlert: (NSString *)msg
                  protocolName: (NSString *)protocolName
                           row: (NSInteger)row
                       eventId: (NSString *)eventId {
    CustomIOSAlertView *alertTimeOutView = [[CustomIOSAlertView alloc] init];
    alertTimeOutView.parentView = self.view;
    
    [alertTimeOutView setContentViewWithMsg:msg contentBackgroundColor:[UIColor darkMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    alertTimeOutView.arrangeStyle = @"Horizontal";
    
    alertTimeOutView.parentView = self.view;
    [alertTimeOutView setButtonTitles: [NSMutableArray arrayWithObjects: NSLocalizedString(@"TimeOut-CancelBtnTitle", @""), NSLocalizedString(@"TimeOut-OKBtnTitle", @""), nil]];
    
    [alertTimeOutView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor clearColor], [UIColor clearColor],nil]];
    [alertTimeOutView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
    [alertTimeOutView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
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
                //[weakSelf insertReport];
            } else if ([protocolName isEqualToString: @"retrievealbump"]) {
                [weakSelf retrieveAlbum:self.album_id silence:NO];
            } else if ([protocolName isEqualToString: @"insertreport"]) {
                //[weakSelf SaveDataRow: row];
            } else if ([protocolName isEqualToString: @"insertAlbum2Likes"]) {
                [weakSelf insertAlbumToLikes];
            } else if ([protocolName isEqualToString: @"deleteAlbum2Likes"]) {
                [weakSelf deleteAlbumToLikes];
            } else if ([protocolName isEqualToString: @"getUrPoints"]) {
                [weakSelf pointsUpdate];
            }
        }
    }];
    [alertTimeOutView setUseMotionEffects: YES];
    [alertTimeOutView show];
}
#pragma mark -
- (void)contentCheckingViewControllerViewWillDisappear:(ContentCheckingViewController *)controller isLikeBtnPressed:(BOOL)isLikeBtnPressed {
    
}
#pragma mark -
- (void)actionSheetViewDidSlideOut:(UIViewController *)controller {
    [self.effectView removeFromSuperview];
    self.effectView = nil;
        
    [self retrieveAlbum:self.album_id silence:YES];
    if (_isMessageShowing)
        _isMessageShowing = NO;
}
#pragma mark -
- (void)gotMessageData {
    //self.effectView.tag = 100;
    [self.view addSubview: self.effectView];
    [self.view addSubview: self.customMessageActionSheet.view];
}
#pragma mark -
- (void)showCustomShareActionSheet {
    if (self.albumInfo.allKeys.count < 1) return;
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleDark];
    
    [UIView animateWithDuration: kAnimateActionSheet animations:^{
        self.effectView = [[UIVisualEffectView alloc] initWithEffect: blurEffect];
    }];
    
    self.effectView.frame = self.view.frame;
    self.effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.effectView.alpha = 0.8;
    [self.view addSubview: self.effectView];
    
    [self.view addSubview: self.customShareActionSheet.view];
    [self.customShareActionSheet viewWillAppear: NO];
    [self.customShareActionSheet addSelectItem: @"" title: @"獎勵分享(facebook)" btnStr: @"" tagInt: 1 identifierStr: @"fbSharing"];
    [self.customShareActionSheet addSelectItem: @"" title: @"一般分享" btnStr: @"" tagInt: 2 identifierStr: @"normalSharing"];
    
    __weak typeof(self) weakSelf = self;
    [self.customShareActionSheet addSafeArea];
    self.customShareActionSheet.customViewBlock = ^(NSInteger tagId, BOOL isTouchDown, NSString *identifierStr) {
        NSLog(@"");
        NSLog(@"customShareActionSheet.customViewBlock executes");
        NSLog(@"tagId: %ld", (long)tagId);
        NSLog(@"isTouchDown: %d", isTouchDown);
        NSLog(@"identifierStr: %@", identifierStr);
        
        if ([identifierStr isEqualToString: @"fbSharing"]) {
            NSLog(@"fbSharing is pressed");
            FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
            
            if ([weakSelf.albumInfo[@"eventjoin"] isEqual: [NSNull null]]) {
                NSLog(@"eventjoin is null");
                content.contentURL = [NSURL URLWithString: [NSString stringWithFormat: sharingLinkWithAutoPlay, weakSelf.album_id, autoPlayStr]];
            } else {
                NSLog(@"eventjoin is not null");
                content.contentURL = [NSURL URLWithString: [NSString stringWithFormat: sharingLinkWithoutAutoPlay, weakSelf.album_id]];
            }
            [FBSDKShareDialog showFromViewController: weakSelf
                                         withContent: content
                                            delegate: weakSelf];
        } else if ([identifierStr isEqualToString: @"normalSharing"]) {
            NSLog(@"normalSharing is pressed");
            NSString *message;
            
            if ([weakSelf.albumInfo[@"eventjoin"] isEqual: [NSNull null]]) {
                NSLog(@"eventjoin is null");
                message = [NSString stringWithFormat: sharingLinkWithAutoPlay, weakSelf.album_id, autoPlayStr];
            } else {
                NSLog(@"eventjoin is not null");
                message = [NSString stringWithFormat: sharingLinkWithoutAutoPlay, weakSelf.album_id];
            }
            NSLog(@"message: %@", message);
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems: [NSArray arrayWithObjects: message, nil] applicationActivities: nil];
            [weakSelf presentViewController: activityVC animated: YES completion: nil];
        }
    };
}
- (void)showCustomMessageActionSheet {
    NSLog(@"showCustomMessageActionSheet");
    _isMessageShowing = YES;
    self.messageBtn.backgroundColor = [UIColor clearColor];
    
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleDark];
    
    [UIView animateWithDuration: kAnimateActionSheet animations:^{
        self.effectView = [[UIVisualEffectView alloc] initWithEffect: blurEffect];
    }];
    self.effectView.frame = self.view.frame;
    self.effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //self.effectView.myLeftMargin = self.effectView.myRightMargin = 0;
    //self.effectView.myTopMargin = self.effectView.myBottomMargin = 0;
    self.effectView.alpha = 0.9;
    
    // Call customMessageActionSheet methods first
    [self.customMessageActionSheet initialValueSetup];
    [self.customMessageActionSheet getMessage];
}

- (void)showCustomMoreActionSheet {
    if (self.albumInfo.allKeys.count < 1) return;
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleDark];
    
    [UIView animateWithDuration: kAnimateActionSheet animations:^{
        self.effectView = [[UIVisualEffectView alloc] initWithEffect: blurEffect];
    }];
    self.effectView.frame = self.view.frame;
    self.effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.effectView.alpha = 0.8;
    [self.view addSubview: self.effectView];
    
    // CustomActionSheet Setting
    [self.view addSubview: self.customMoreActionSheet.view];
    [self.customMoreActionSheet viewWillAppear: NO];
    
    _albumPoint = [self.albumInfo[@"album"][@"point"] integerValue];
    
    // Check if albumUserId is same as userId, then don't add collectBtn
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"id: %@", [userDefaults objectForKey: @"id"]);
    NSLog(@"self.data user user_id: %d", [self.albumInfo[@"user"][@"user_id"] intValue]);
    
    NSInteger userId = [[userDefaults objectForKey: @"id"] intValue];
    NSInteger albumUserId = [self.albumInfo[@"user"][@"user_id"] intValue];
//
//    NSString *collectStr;
//    NSString *btnStr;
//    _isCollected = [self.albumInfo[@"album"][@"own"] boolValue];
//
//    if (albumUserId != userId) {
//        if (!_isCollected) {
//            if (_albumPoint == 0) {
//                collectStr = @"收藏";
//            } else if (_albumPoint > 0) {
//                collectStr = [NSString stringWithFormat: @"收藏(需要贊助%ldP)", (long)_albumPoint];
//                btnStr = @"贊助更多";
//            }
//        } else {
//            collectStr = @"已收藏";
//            btnStr = @"";
//        }
//        [self.customMoreActionSheet addSelectItem: @"ic200_collect_dark.png" title: collectStr btnStr: btnStr tagInt: 1 identifierStr: @"collectItem" isCollected: _isCollected];
//    }
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
    [self.customMoreActionSheet addSafeArea];
    self.customMoreActionSheet.customViewBlock = ^(NSInteger tagId, BOOL isTouchDown, NSString *identifierStr) {
        if ([identifierStr isEqualToString: @"albumEdit"]) {
            [weakSelf toAlbumCreationViewController: weakSelf.album_id
                                         templateId: @"0"
                                    shareCollection: NO];
        } else if ([identifierStr isEqualToString: @"modifyInfo"]) {
            [weakSelf toAlbumSettingViewController: weakSelf.album_id
                                        templateId: @"0"
                                   shareCollection: NO];
        } else if ([identifierStr isEqualToString: @"shareItem"]) {
            [weakSelf checkTaskComplete];
            
        } else if ([identifierStr isEqualToString: @"reportItem"]) {
            [weakSelf insertReport];
        }
    };
}
- (void)showCustomAlert:(NSString *)msg
                btnName:(NSString *)btnName {
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    
    [alertView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    [alertView setButtonTitles: [NSMutableArray arrayWithObject: btnName]];
    [alertView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor whiteColor],nil]];
    [alertView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
    [alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
alertView.arrangeStyle = @"Horizontal";
    
    __weak CustomIOSAlertView *weakAlertView = alertView;
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        [weakAlertView close];
    }];
    [alertView setUseMotionEffects: YES];
    [alertView show];
}
- (void)showCustomAlert:(NSString *)msg
                 option:(NSString *)option {
    
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    
    [alertView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    if ([option isEqualToString: @"buyAlbum"]) {
        [alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"取消", @"確定", nil]];
    }
    if ([option isEqualToString: @"buyPoint"]) {
        [alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"稍後再說", @"前往購點", nil]];
    }
    [alertView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor whiteColor],nil]];
    [alertView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
    [alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    alertView.arrangeStyle = @"Horizontal";
    
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
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [appDelegate.myNav pushViewController: bPPVC animated: YES];
            }
        }
    }];
    [alertView setUseMotionEffects: YES];
    [alertView show];
}



#pragma mark - Methods for choosing viewControllers
- (void)toAlbumCreationViewController: (NSString *)albumId
                           templateId: (NSString *)templateId
                      shareCollection: (BOOL)shareCollection {
    NSLog(@"toAlbumCreationViewController");
    AlbumCreationViewController *acVC = [[UIStoryboard storyboardWithName: @"AlbumCreationVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumCreationViewController"];
    //acVC.selectrow = [wTools userbook];
    acVC.albumid = albumId;
    acVC.templateid = [NSString stringWithFormat:@"%@", templateId];
    acVC.shareCollection = shareCollection;
    acVC.postMode = NO;
    acVC.fromVC = @"YAlbumDetailVC";
    acVC.delegate = self;
    acVC.isNew = NO;
    
    NSString * u = [NSString stringWithFormat:@"%lu", [self.albumInfo[@"user"][@"user_id"] longValue] ];
    if ([u isEqualToString: [wTools getUserID]])
        acVC.userIdentity = @"admin";
    
    if ([templateId isEqualToString:@"0"]) {
        acVC.booktype = 0;
        acVC.choice = @"Fast";
    } else {
        acVC.booktype = 1000;
        acVC.choice = @"Template";
    }
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: acVC animated: YES];
}

- (void)toAlbumSettingViewController: (NSString *)albumId
                          templateId: (NSString *)templateId
                     shareCollection: (BOOL)shareCollection {
    NSLog(@"toAlbumSettingViewController");
    AlbumSettingViewController *aSVC = [[UIStoryboard storyboardWithName: @"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumSettingViewController"];
    aSVC.albumId = albumId;
    aSVC.postMode = NO;
    aSVC.templateId = [NSString stringWithFormat:@"%@", templateId];
    aSVC.shareCollection = shareCollection;
    aSVC.fromVC = @"YAlbumDetailVC";
    aSVC.delegate = self;
    NSArray *photos = self.albumInfo[@"photo"];
    if ([wTools objectExists:photos])
        aSVC.hasImage = photos.count > 0;
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: aSVC animated: YES];
}
#pragma mark -
- (void)albumCreationViewControllerBackBtnPressed: (AlbumCreationViewController *)controller {
    
}
- (void)albumSettingViewControllerUpdate:(AlbumSettingViewController *)controller {
    
}
#pragma mark -
- (void)checkCollectedOutward {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *aid = (NSString *) [defaults objectForKey:@"keepOwnedAlbumLocal"];
    if (aid) {
        if ([aid isEqualToString:self.album_id] && self.albumInfo.allKeys.count) {
            [self retrieveAlbum:self.album_id silence:YES];
        }
        [defaults removeObjectForKey:@"keepOwnedAlbumLocal"];
    } else {
        aid = (NSString *)[defaults objectForKey:@"albumliked"];
        if (aid && [aid isEqualToString:self.album_id] && self.albumInfo.allKeys.count) {
            [self retrieveAlbum:self.album_id silence:YES];
        }
        [defaults removeObjectForKey:@"albumliked"];
    }
    [defaults synchronize];
}
#pragma mark - Likes
- (void)insertAlbumToLikes {
    @try {
        [DGHUDView start];
    } @catch (NSException *exception) {
        return;
    }
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI insertAlbum2Likes: [wTools getUserID]
                                                 token: [wTools getUserToken]
                                               albumId: self.album_id];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [DGHUDView stop];
            } @catch (NSException *exception) {
                return;
            }
            if (response != nil) {
                
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"insertAlbum2Likes"
                                             row: 0
                                         eventId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    [wself processInsertAlbumLikesResult:dic];
                }
            }
        });
    });
}
- (void)processInsertAlbumLikesResult:(NSDictionary *)dic {
    if ([dic[@"result"] intValue] == 1) {
        
        [self retrieveAlbum:self.album_id silence:NO];
    } else if ([dic[@"result"] intValue] == 0) {
        NSLog(@"失敗：%@", dic[@"message"]);
        NSString *msg = dic[@"message"];
        [self showCustomErrorAlert: msg];
    } else {
        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
    }
}
- (void)deleteAlbumToLikes {
    @try {
        [DGHUDView start];
    } @catch (NSException *exception) {
        // Print exception information
        
        return;
    }
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI deleteAlbum2Likes: [wTools getUserID] token: [wTools getUserToken] albumId: wself.album_id];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [DGHUDView stop];
            } @catch (NSException *exception) {
                // Print exception information
                return;
            }
            if (response != nil) {
                if ([response isEqualToString: timeOutErrorCode]) {
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                     protocolName: @"deleteAlbum2Likes"
                                              row: 0
                                          eventId: @""];
                } else {
                    
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    [wself processInsertAlbumLikesResult:dic];
                }
            }
        });
    });
}
#pragma mark - FB Delegate
- (void)sharer:(id<FBSDKSharing>)sharer
didCompleteWithResults:(NSDictionary *)results {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL share_to_fb = [[defaults objectForKey: @"share_to_fb"] boolValue];
    
    if (share_to_fb) {
        NSLog(@"Getting Sharing Point Already");
    } else {
        
        _task_for = @"share_to_fb";
        [self checkPoint];
    }
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {

}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    
}

@end
