//
//  AlbumSponsorListViewController.m
//  wPinpinbox
//
//  Created by David on 2018/6/21.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "AlbumSponsorListViewController.h"
#import "AlbumSponsorListTableViewCell.h"
#import "MyLayout.h"
#import "GlobalVars.h"
#import "boxAPI.h"
#import "wTools.h"
#import "UIColor+HexString.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "LabelAttributeStyle.h"
#import "CustomIOSAlertView.h"
#import "UIColor+Extensions.h"
#import "UIView+Toast.h"
#import "AppDelegate.h"
#import "MessageboardViewController.h"
#import "CreaterViewController.h"
#import "UIViewController+ErrorAlert.h"
#import "SwitchButtonView.h"

@interface AlbumSponsorListViewController () <UITableViewDataSource, UITableViewDelegate, MessageboardViewControllerDelegate, UIGestureRecognizerDelegate> {
    BOOL isLoading;
    BOOL isReloading;
    NSInteger nextId;
    NSMutableArray *albumSponsorArray;
}
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIKernedLabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarHeight;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) MessageboardViewController *customMessageActionSheet;
@property (nonatomic) UIVisualEffectView *effectView;
@end

@implementation AlbumSponsorListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.delegate = self;
    [self initialValueSetup];
    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.enabled = NO;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backBtnPress:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav popViewControllerAnimated: YES];
}

- (void)initialValueSetup {
    NSLog(@"initialValueSetup");
    nextId = 0;
    isLoading = NO;
    isReloading = NO;
    
    albumSponsorArray = [[NSMutableArray alloc] init];
    self.titleLabel.text = @"贊助我的人";
    
    self.navBarView.backgroundColor = [UIColor barColor];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget: self
                            action: @selector(refresh)
                  forControlEvents: UIControlEventValueChanged];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(72, 0, 0, 0);
    [self.tableView addSubview: self.refreshControl];
    
    self.customMessageActionSheet = [[MessageboardViewController alloc] init];
    self.customMessageActionSheet.delegate = self;
}

#pragma mark -
- (void)refresh {
    NSLog(@"refresh");
    
    if (!isReloading) {
        isReloading = YES;
        nextId = 0;
        isLoading = NO;
        [self loadData];
    }
}

#pragma mark -
- (void)loadData {
    NSLog(@"loadData");
    
    if (!isLoading) {
        if (nextId == 0) {
            NSLog(@"nextId: %ld", (long)nextId);
        }
        isLoading = YES;
        [self getSponsorList];
    }
}

- (void)getSponsorList {
    NSLog(@"getSponsorList");
    [DGHUDView start];
    
    NSString *limit = [NSString stringWithFormat: @"%ld,%d", (long)nextId, 16];
    __block typeof(self) wself = self;
    __block typeof(self.albumId) aid = self.albumId;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI getAlbumSponsorList: aid
                                                   limit: limit
                                                   token: [wTools getUserToken]
                                                  userId: [wTools getUserID]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [DGHUDView stop];
            
            if (response != nil) {
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"SponsorListViewController");
                    NSLog(@"getSponsorList");
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getSponsorList"
                                          userId: 0
                                            cell: nil];
                    [wself.refreshControl endRefreshing];
                    wself->isReloading = NO;
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    [wself processSponsorListResult:dic];
                }
            }
        });
    });
}

- (void)processSponsorListResult:(NSDictionary *)dic {
    if ([dic[@"result"] isEqualToString: @"SYSTEM_OK"]) {
        NSLog(@"SYSTEM_OK");
        NSLog(@"dic data: %@", dic[@"data"]);
        NSLog(@"Before");
        NSLog(@"nextId: %ld", (long)nextId);
        
        if (nextId == 0) {
            albumSponsorArray = [[NSMutableArray alloc] init];
        }
        
        if (![wTools objectExists: dic[@"data"]]) {
            return;
        }
        
        // s for counting how much data is loaded
        int s = 0;
        
        for (NSMutableDictionary *sponsorDic in [dic objectForKey: @"data"]) {
            NSLog(@"sponsorDic: %@", sponsorDic);
            s++;
            [albumSponsorArray addObject: sponsorDic];
        }
        
        NSLog(@"After");
        NSLog(@"nextId: %ld", (long)nextId);
        
        // If data keeps loading then the nextId is accumulating
        nextId = nextId + s;
        
        // If nextId is bigger than 0, that means there are some data loaded already.
        if (nextId >= 0) {
            isLoading = NO;
        }
        
        // If s is 0, that means dic data is empty.
        if (s == 0) {
            isLoading = YES;
        }
        NSLog(@"self.tableView reloadData");
        
        [self.refreshControl endRefreshing];
        isReloading = NO;
        
        [self.tableView reloadData];
        self.notice.hidden = albumSponsorArray.count > 0;
    } else if ([dic[@"result"] isEqualToString: @"SYSTEM_ERROR"]) {
        NSLog(@"SYSTEM_ERROR");
        NSLog(@"失敗：%@",dic[@"message"]);
        if ([wTools objectExists: dic[@"message"]]) {
            [self showCustomErrorAlert: dic[@"message"]];
        } else {
            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
        }
        
        [self.refreshControl endRefreshing];
        isReloading = NO;
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
        
        [self.refreshControl endRefreshing];
        isReloading = NO;
    } else if ([dic[@"result"] isEqualToString: @"USER_ERROR"]) {
        NSLog(@"錯誤：%@",dic[@"message"]);
        if ([wTools objectExists: dic[@"message"]]) {
            [self showCustomErrorAlert: dic[@"message"]];
        } else {
            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
        }
        
        [self.refreshControl endRefreshing];
        isReloading = NO;
    }
}

- (void)logOut {
    [wTools logOut];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return albumSponsorArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForRowAtIndexPath");
    NSLog(@"albumSponsorArray: %@", albumSponsorArray);
    
    __weak AlbumSponsorListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Cell" forIndexPath: indexPath];
    NSDictionary *dic = [albumSponsorArray[indexPath.row] copy];
    NSString *imageUrl = dic[@"user"][@"picture"];
    NSString *name = dic[@"user"][@"name"];
    NSInteger point = [dic[@"user"][@"point"] integerValue];
    NSInteger userId = [dic[@"user"][@"user_id"] integerValue];
    
    if ([imageUrl isEqual: [NSNull null]] || [imageUrl isEqualToString: @""]) {
        cell.headshotImageView.image = [UIImage imageNamed: @"member_back_head.png"];
    } else {
        [cell.headshotImageView sd_setImageWithURL: [NSURL URLWithString: imageUrl] placeholderImage: [UIImage imageNamed: @"member_back_head.png"]];
    }
    
    if (![name isEqual: [NSNull null]]) {
        cell.userNameLabel.text = name;
        [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: cell.userNameLabel content: cell.userNameLabel.text];
    }
    cell.pPointLabel.text = [NSString stringWithFormat: @"%ldP", (long)point];
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: cell.pPointLabel content: cell.pPointLabel.text];
    
    NSLog(@"user is_follow: %d", [dic[@"user"][@"is_follow"] boolValue]);
    [self updateFollowBtnStatus: cell.followBtn isFollow: [dic[@"user"][@"is_follow"] boolValue]];
    
    __weak typeof(self) weakSelf = self;
    
    cell.customBlock = ^(BOOL selected, NSInteger tag) {
        NSLog(@"cell.customBlock");
        NSLog(@"tag: %ld", (long)tag);
        
        if (tag == 10) {
            NSLog(@"message btn pressed");
            [weakSelf showMessageBoard: userId userName: name];
        } else if (tag == 20) {
            NSLog(@"follow btn pressed");
            [weakSelf followBtnPress: userId cell: cell];
        }
    };
    return cell;
}

#pragma mark - UITableViewDelegate Methods
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    CreaterViewController *cVC = [[UIStoryboard storyboardWithName: @"CreaterVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CreaterViewController"];
    cVC.userId = albumSponsorArray[indexPath.row][@"user"][@"user_id"];
    
    if (![wTools objectExists: cVC.userId]) {
        return;
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: cVC animated: YES];
}

#pragma mark - Messageboard
- (void)showMessageBoard:(NSInteger)userId
                userName:(NSString *)userName {
    [wTools setStatusBarBackgroundColor: [UIColor clearColor]];
    
    self.customMessageActionSheet.topicStr = @"留言板";
    self.customMessageActionSheet.type = @"user";
    self.customMessageActionSheet.typeId = [NSString stringWithFormat: @"%ld", (long)userId];
    self.customMessageActionSheet.userName = userName;
    
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

#pragma mark - DDAUIActionSheetViewController Method
- (void)actionSheetViewDidSlideOut:(MessageboardViewController *)controller {
    NSLog(@"actionSheetViewDidSlideOut");
    //[self.fxBlurView removeFromSuperview];
    [wTools setStatusBarBackgroundColor: [UIColor whiteColor]];
    [self.effectView removeFromSuperview];
    self.effectView = nil;
}

#pragma mark - Call Server For Follow Function
- (void)followBtnPress:(NSInteger)userId
                  cell:(AlbumSponsorListTableViewCell *)cell {
    [DGHUDView start];
    NSString *userIdStr = [NSString stringWithFormat: @"%ld", (long)userId];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSString *respnose = [boxAPI changefollowstatus: [wTools getUserID]
                                                  token: [wTools getUserToken]
                                               authorid: userIdStr];
        
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
            if (respnose != nil) {
                NSLog(@"response from changefollowstatus");
                
                if ([respnose isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"CreaterViewController");
                    NSLog(@"followBtnPress");
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"followBtnPress"
                                          userId: userId
                                            cell: cell];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respnose dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        if (![wTools objectExists: dic[@"data"]]) {
                            return;
                        }
                        NSDictionary *d = dic[@"data"];
                        [self updateFollowBtnStatus: cell.followBtn
                                           isFollow: [d[@"followstatus" ]boolValue]];
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

- (void)updateFollowBtnStatus:(UIButton *)followBtn
                     isFollow:(BOOL)isFollow {
    if (isFollow) {
        followBtn.backgroundColor = [UIColor clearColor];
        [followBtn setTitle: @"關注中" forState:UIControlStateNormal];
        [followBtn setTitleColor: [UIColor thirdGrey] forState: UIControlStateNormal];
        followBtn.layer.borderColor = [UIColor thirdGrey].CGColor;
        followBtn.layer.borderWidth = 0.5;
    } else {
        followBtn.backgroundColor = [UIColor firstPink];
        [followBtn setTitle: @"關注" forState:UIControlStateNormal];
        [followBtn setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
        followBtn.layer.borderColor = [UIColor clearColor].CGColor;
        followBtn.layer.borderWidth = 0;
    }
}

#pragma mark - Custom Alert Method
- (void)showCustomErrorAlert: (NSString *)msg {
    [UIViewController showCustomErrorAlertWithMessage:msg onButtonTouchUpBlock:^(CustomIOSAlertView *customAlertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[customAlertView tag]);
        [customAlertView close];
    }];
}

#pragma mark - Custom Method for TimeOut
- (void)showCustomTimeOutAlert: (NSString *)msg
                  protocolName: (NSString *)protocolName
                        userId: (NSInteger)userId
                          cell: (AlbumSponsorListTableViewCell *)cell
{
    CustomIOSAlertView *alertTimeOutView = [[CustomIOSAlertView alloc] init];
    alertTimeOutView.parentView = self.view;
    //[alertTimeOutView setContainerView: [self createTimeOutContainerView: msg]];
    [alertTimeOutView setContentViewWithMsg:msg contentBackgroundColor:[UIColor darkMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
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
            if ([protocolName isEqualToString: @"getSponsorList"]) {
                [weakSelf getSponsorList];
            } else if ([protocolName isEqualToString: @"followBtnPress"]) {
                [weakSelf followBtnPress: userId cell: cell];
            }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
