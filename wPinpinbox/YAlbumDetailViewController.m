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

#import "UIViewController+ErrorAlert.h"
#import "AppDelegate.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <FBSDKShareKit/FBSDKShareLinkContent.h>
#import <FBSDKShareKit/FBSDKShareDialog.h>


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

static NSString *autoPlayStr = @"&autoplay=1";

@interface YAlbumDetailViewController ()<UITableViewDataSource, UITableViewDelegate,
ContentCheckingViewControllerDelegate,MessageboardViewControllerDelegate,DDAUIActionSheetViewControllerDelegate,
AlbumCreationViewControllerDelegate,AlbumSettingViewControllerDelegate,FBSDKSharingDelegate>
@property(nonatomic) NSMutableDictionary *albumInfo;
@property(nonatomic) NSString *album_id;
@property(nonatomic) BOOL isViewed;
@property(nonatomic) BOOL isPosting;
@property(nonatomic) NSString *albumType;
@property(nonatomic) NSString *task_for;
@property(nonatomic) BOOL isCollected;
@property(nonatomic) NSInteger albumPoint;


@property(nonatomic) IBOutlet UITableView *detailView;

@property(nonatomic) IBOutlet UIButton *messageBtn;
@property(nonatomic) IBOutlet UIButton *likeBtn;
@property(nonatomic) IBOutlet UIButton *moreBtn;
@property(nonatomic) IBOutlet UITableView *infoView;
@property(nonatomic) IBOutlet UIImageView *headerView;
@property(nonatomic) IBOutlet UIButton *contentButton;
@property(nonatomic) IBOutlet NSLayoutConstraint *headerHeight;
@property(nonatomic) IBOutlet NSLayoutConstraint *infoHeight;

@property (nonatomic) DDAUIActionSheetViewController *customMoreActionSheet;
@property (nonatomic) DDAUIActionSheetViewController *customShareActionSheet;
@property (nonatomic) MessageboardViewController *customMessageActionSheet;
@property (nonatomic) UIVisualEffectView *effectView;



- (IBAction)dismissVC:(id)sender;
- (void)showCustomAlert:(NSString *)msg btnName:(NSString *)btnName;
@end

@implementation YAlbumDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.albumInfo = [NSMutableDictionary dictionary];

}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [wTools setStatusBarBackgroundColor:[UIColor clearColor]];
}
- (void)setupAlbumWithInfo:(NSDictionary *)info {
    [self.albumInfo setDictionary:info];
    [self prepareCoverView];
    [self pointsUpdate];
    [self.detailView reloadData];
}
- (void)setAlubumId:(NSString *)aid {
    self.album_id = aid;
    [self checkAlbumId:self.album_id];
    [self retrieveAlbum:self.album_id];
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
- (void)pointsUpdate {
    
}
- (void)checkPoint {
    
}
- (void)buyAlbum {
    
}
- (void)getPoint {
    
}
- (BOOL)isPanValid {
    
    return self.customMessageActionSheet.view.superview != self.view;
}
#pragma mark -
- (BOOL)isPointInHeader:(CGPoint)point {
    CGRect r = [self.view convertRect:self.headerView.frame fromView:self.headerView];
    return CGRectContainsPoint(r, point);
}
- (UIImageView *)albumCoverView{
    return self.headerView;
}
- (void)setContentBtnVisible {
    self.contentButton.hidden = NO;
}
- (void)setHeaderPlaceholder:(UIImage *)placeholder {
    CGSize s = placeholder.size;
    CGFloat dh = (s.height/s.width)* [UIScreen mainScreen].bounds.size.width;
    self.headerView.image = placeholder;
    self.headerHeight.constant = dh;
}
- (void)prepareCoverView {
    NSArray *a = self.albumInfo[@"photo"];
    NSDictionary *p = a[0];
    if ([wTools objectExists:p[@"image_url"]]) {
        NSURL *u = [NSURL URLWithString:p[@"image_url"]];
        __block typeof(self) wself = self;
        [self.headerView sd_setImageWithURL:u completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (error || image == nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *image = [UIImage imageNamed:@"bg_2_0_0_no_image.jpg"];
                    CGSize s = image.size;
                    CGFloat dh = (s.height/s.width)* [UIScreen mainScreen].bounds.size.width;
                    wself.headerView.image = image;
                    wself.headerHeight.constant = dh;
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    CGSize s = image.size;
                    CGFloat dh = (s.height/s.width)* [UIScreen mainScreen].bounds.size.width;
                    wself.headerView.image = image;
                    wself.headerHeight.constant = dh;
                });
            }
        }];
        //[header.albumHeader sd_setImageWithURL:u placeholderImage:];
    }
    
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
- (NSInteger)getLikesCount {
    NSInteger c = 0;
    NSDictionary *data = self.albumInfo[@"albumstatistics"];
    if ([wTools objectExists: data[@"likes"]])
        c = (int)[data[@"likes"] integerValue];
    return c;
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
            return [YAlbumPointCell estimatedHeight:self.albumInfo[@"album"]];
        }
        case 4:
        case 6: {
            return [YAlbumFollowerCell estimatedHeight:self.albumInfo[@"album"]];
        } break;
        case 7: {
            return [YAlbumCreatorCell estimatedHeight:self.albumInfo[@"user"]];
            
        } break;
        case 8: {
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
            [cell loadData:self.albumInfo];
            if (![cell.creatorWorks.allTargets containsObject:self]) {
                [cell.creatorWorks addTarget:self action:@selector(moreAlbumList:) forControlEvents:UIControlEventTouchUpInside];
            }
            return cell;
        } break;
        case 8: {
            YAlbumEventCell *cell = (YAlbumEventCell *)[tableView dequeueReusableCellWithIdentifier:@"YAlbumEventCell"];
            [cell loadData:self.albumInfo];
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
- (IBAction)dismissVC:(id)sender {
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [appDelegate.myNav popViewControllerAnimated:YES];
//    appDelegate.myNav.delegate = nil;
//    
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
- (IBAction)eventVote:(id)sender {
    
}
- (IBAction)moreAlbumList:(id)sender {
    if ([wTools objectExists:self.albumInfo[@"user"][@"user_id"]]) {
        CreaterViewController *cVC = [[UIStoryboard storyboardWithName: @"CreaterVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CreaterViewController"];
        cVC.userId = self.albumInfo[@"user"][@"user_id"];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.myNav pushViewController: cVC animated: YES];
    }
}

#pragma mark - API
- (void)retrieveAlbum:(NSString *)aid {
    
    [wTools ShowMBProgressHUD];
    __block NSString *viewedString = [NSString stringWithFormat: @"%d", self.isViewed];
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSString *response = [boxAPI retrievealbump: aid
                                                uid: [wTools getUserID]
                                              token: [wTools getUserToken]
                                             viewed: viewedString];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [wTools HideMBProgressHUD];
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
                        [wself setupAlbumWithInfo:dic[@"data"]];
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
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
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
        [wTools ShowMBProgressHUD];
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
                [wTools HideMBProgressHUD];
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
    
    [alertTimeOutView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
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
//            if ([protocolName isEqualToString: @"checkTaskCompleted"]) {
//                [weakSelf checkTaskComplete];
//            } else if ([protocolName isEqualToString: @"geturpoints"]) {
//                [weakSelf getPoint];
//            } else if ([protocolName isEqualToString: @"buyalbum"]) {
//                [weakSelf buyAlbum];
//            } else if ([protocolName isEqualToString: @"doTask2"]) {
//                [weakSelf checkPoint];
//            } else if ([protocolName isEqualToString: @"getreportintentlist"]) {
//                [weakSelf insertReport];
//            } else if ([protocolName isEqualToString: @"retrievealbump"]) {
//                [weakSelf retrieveAlbum];
//            } else if ([protocolName isEqualToString: @"insertreport"]) {
//                [weakSelf SaveDataRow: row];
//            } else if ([protocolName isEqualToString: @"insertAlbum2Likes"]) {
//                [weakSelf insertAlbumToLikes];
//            } else if ([protocolName isEqualToString: @"deleteAlbum2Likes"]) {
//                [weakSelf deleteAlbumToLikes];
//            } else if ([protocolName isEqualToString: @"getUrPoints"]) {
//                [weakSelf pointsUPdate];
//            }
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
        
    [self retrieveAlbum:self.album_id];
}
#pragma mark -
- (void)gotMessageData {
    //self.effectView.tag = 100;
    [self.view addSubview: self.effectView];
    [self.view addSubview: self.customMessageActionSheet.view];
}
#pragma mark -
- (void)showCustomShareActionSheet {
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
    //isMessageShowing = YES;
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
    
    NSString *collectStr;
    NSString *btnStr;
    
    if (albumUserId != userId) {
        if (!_isCollected) {
            if (_albumPoint == 0) {
                collectStr = @"收藏";
            } else if (_albumPoint > 0) {
                collectStr = [NSString stringWithFormat: @"收藏(需要贊助%ldP)", (long)_albumPoint];
                btnStr = @"贊助更多";
            }
        } else {
            collectStr = @"已收藏";
            btnStr = @"";
        }
        [self.customMoreActionSheet addSelectItem: @"ic200_collect_dark.png" title: collectStr btnStr: btnStr tagInt: 1 identifierStr: @"collectItem" isCollected: _isCollected];
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
    __block NSInteger weakAlbumPoint = _albumPoint;
    
    self.customMoreActionSheet.customButtonBlock = ^(BOOL selected) {
        NSString *alertMsg = @"點選「觀看內容」並前往最後一頁可進行贊助額度設定";
        NSString *btnName = @"我知道了";
        [weakSelf showCustomAlert: alertMsg btnName: btnName];
        [weakSelf.customMoreActionSheet slideOut];
    };
    self.customMoreActionSheet.customViewBlock = ^(NSInteger tagId, BOOL isTouchDown, NSString *identifierStr) {
        if ([identifierStr isEqualToString: @"collectItem"]) {
        
            
            if (weakAlbumPoint == 0) {
                [weakSelf buyAlbum];
            } else {
                NSString *msgStr = [NSString stringWithFormat: @"確定贊助%ldP?", (long)weakAlbumPoint];
                [weakSelf showCustomAlert: msgStr option: @"buyAlbum"];
            }
        } else if ([identifierStr isEqualToString: @"albumEdit"]) {
            [weakSelf toAlbumCreationViewController: weakSelf.album_id
                                         templateId: @"0"
                                    shareCollection: NO];
        } else if ([identifierStr isEqualToString: @"modifyInfo"]) {
            [weakSelf toAlbumSettingViewController: weakSelf.album_id
                                        templateId: @"0"
                                   shareCollection: NO];
        } else if ([identifierStr isEqualToString: @"shareItem"]) {
            //[weakSelf checkTaskComplete];
            //[weakSelf showCustomShareActionSheet];
        } else if ([identifierStr isEqualToString: @"reportItem"]) {
            //[weakSelf insertReport];
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
- (void)showCustomAlert: (NSString *)msg option:(NSString *)option {
    
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
#pragma mark - Likes
- (void)insertAlbumToLikes {
    
    @try {
        [wTools ShowMBProgressHUD];
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
                [wTools HideMBProgressHUD];
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
        
        [self retrieveAlbum:self.album_id];
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
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        
        return;
    }
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI deleteAlbum2Likes: [wTools getUserID] token: [wTools getUserToken] albumId: wself.album_id];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [wTools HideMBProgressHUD];
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
