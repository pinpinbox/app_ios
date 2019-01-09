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


@interface YAlbumDetailViewController ()<UITableViewDataSource, UITableViewDelegate>
@property(nonatomic) NSMutableDictionary *albumInfo;
@property(nonatomic) NSString *album_id;
@property(nonatomic) BOOL isViewed;
@property(nonatomic) BOOL isPosting;
@property(nonatomic) NSString *albumType;
@property(nonatomic) NSString *task_for;

@property(nonatomic) IBOutlet UITableView *detailView;

@property(nonatomic) IBOutlet UIButton *messageBtn;
@property(nonatomic) IBOutlet UIButton *likeBtn;
@property(nonatomic) IBOutlet UIButton *moreBtn;
@property(nonatomic) IBOutlet UITableView *infoView;
@property(nonatomic) IBOutlet UIImageView *headerView;
@property(nonatomic) IBOutlet UIButton *contentButton;
@property(nonatomic) IBOutlet NSLayoutConstraint *headerHeight;

- (IBAction)dismissVC:(id)sender;
@end

@implementation YAlbumDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.albumInfo = [NSMutableDictionary dictionary];
    
    
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
//        case 0: {
//            return 300;
//        } break;
//
        case 1: {
            NSDictionary *al = self.albumInfo[@"album"];
            if ([al[@"location"] isKindOfClass:[NSNull class]]) {
                return 0;
            }
            NSString *location = al[@"location"];
            
            return (location.length > 0)? 36 : 0;
        } break;
        case 2:{
            return 36;
        } break;
        case 3: {
            return 275;
        } break;
        case 4:
        case 5:
        case 6: {
            return 52;
        } break;
        case 7: {
            return 148;
        } break;
        case 8: {
            if ([wTools objectExists:self.albumInfo[@"eventjoin"]])
                return 180;
            return 0;
        } break;
        default: {
            return 64;
        }
            
    }
    
    return 0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    //if (self.albumInfo.allKeys.count < 1) return 0;
    
    return 9;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
//        case 0: {
//            YAlbumDetailHeaderCell *header = (YAlbumDetailHeaderCell *)[tableView dequeueReusableCellWithIdentifier:@"YAlbumDetailHeaderCell"];
//            NSArray *a = self.albumInfo[@"photo"];
//            NSDictionary *p = a[0];
//
//            if ([wTools objectExists:p[@"image_url"]]) {
//                NSURL *u = [NSURL URLWithString:p[@"image_url"]];
//                [header.albumHeader sd_setImageWithURL:u placeholderImage:[UIImage imageNamed:@"bg_2_0_0_no_image.jpg"]];
//            }
//            if (!self.interactiveTransitioning) {
//                self.interactiveTransitioning = [[AlbumInteractiveTransitioning alloc] init];
//                [self.interactiveTransitioning attachVC:self headerImage:header.imageView];
//            }
//            return header;
//        } break;

        case 1: {
            YAlbumLocationCell *cell = (YAlbumLocationCell *)[tableView dequeueReusableCellWithIdentifier:@"YAlbumLocationCell"];
            NSDictionary *a = self.albumInfo[@"album"];
            if ([wTools objectExists:a[@"location"]])
                cell.locationLabel.text = a[@"location"];
            return cell;
        } break;
        case 2: {
            YAlbumContentTypeCell *cell = (YAlbumContentTypeCell *)[tableView dequeueReusableCellWithIdentifier:@"YAlbumContentTypeCell"];
            return cell;
        } break;
        case 3: {
            YAlbumDescCell *cell = (YAlbumDescCell *)[tableView dequeueReusableCellWithIdentifier:@"YAlbumDescCell"];
            return cell;
        } break;
        case 4: {
            YAlbumFollowerCell *cell = (YAlbumFollowerCell *)[tableView dequeueReusableCellWithIdentifier:@"YAlbumFollowerCell"];
            
            return cell;
        } break;
        case 5: {
            YAlbumPointCell *cell = (YAlbumPointCell *)[tableView dequeueReusableCellWithIdentifier:@"YAlbumPointCell"];
            
            return cell;

        } break;
        case 6: {
            YAlbumMessageCell *cell = (YAlbumMessageCell *)[tableView dequeueReusableCellWithIdentifier:@"YAlbumMessageCell"];
            
            return cell;
        } break;
        case 7: {
            YAlbumCreatorCell *cell = (YAlbumCreatorCell *)[tableView dequeueReusableCellWithIdentifier:@"YAlbumCreatorCell"];
            NSDictionary *u = self.albumInfo[@"user"];
            if ([wTools objectExists:u[@"name"]])
                cell.creatorName.text = u[@"name"];
            if ([wTools objectExists:u[@"picture"]])
                [cell.creatorAvatar sd_setImageWithURL:[NSURL URLWithString:u[@"picture"]] placeholderImage:[UIImage imageNamed:@"member_back_head"]];
            return cell;
        } break;
        case 8: {
            YAlbumEventCell *cell = (YAlbumEventCell *)[tableView dequeueReusableCellWithIdentifier:@"YAlbumEventCell"];
            
            return cell;
        } break;
        default: {
            YAlbumTitleCell *title = (YAlbumTitleCell *)[tableView dequeueReusableCellWithIdentifier:@"YAlbumTitleCell"];
            NSDictionary *a = self.albumInfo[@"album"];
            if ([wTools objectExists:a[@"name"]])
                title.titleLabel.text = a[@"name"];
            return title;
        }
            
    }
    
    YAlbumTitleCell *title = (YAlbumTitleCell *)[tableView dequeueReusableCellWithIdentifier:@"YAlbumTitleCell"];

    return title;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

#pragma mark -
- (IBAction)dismissVC:(id)sender {
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [appDelegate.myNav popViewControllerAnimated:YES];
//    appDelegate.myNav.delegate = nil;
//    
}
- (IBAction)messageBtnTouched:(id)sender {
    
}
- (IBAction)likeBtnTouched:(id)sender {
    
}
- (IBAction)moreBtnTouched:(id)sender {
    
}
- (IBAction)viewContentTouched:(id)sender {
    
}
- (IBAction)eventVote:(id)sender {
    
}
- (IBAction)moreAlbumList:(id)sender {
    
}

#pragma mark -
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

@end
