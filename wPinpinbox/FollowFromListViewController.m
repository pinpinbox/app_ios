//
//  FollowFromListViewController.m
//  wPinpinbox
//
//  Created by David on 07/05/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "FollowFromListViewController.h"
#import "FollowFromListTableViewCell.h"
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

@interface FollowFromListViewController () <UITableViewDataSource, UITableViewDelegate, MessageboardViewControllerDelegate,UIGestureRecognizerDelegate> {
    BOOL isLoading;
    BOOL isReloading;
    NSInteger nextId;
    NSMutableArray *followFromListArray;
    
    UIView *noInfoView;
    BOOL isNoInfoViewCreate;
}
@property (nonatomic) DGActivityIndicatorView *activityIndicatorView;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarHeight;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) MessageboardViewController *customMessageActionSheet;
@property (nonatomic) UIVisualEffectView *effectView;

@end

@implementation FollowFromListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.delegate = self;
    [self initActivityIndicatorView];
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

- (void)initActivityIndicatorView {
    self.activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType: DGActivityIndicatorAnimationTypeDoubleBounce tintColor: [UIColor secondMain] size: kActivityIndicatorViewSize];
    self.activityIndicatorView.frame = CGRectMake(0.0f, 0.0f, 50.0f, 50.0f);
    self.activityIndicatorView.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
    [self.view addSubview: self.activityIndicatorView];
}

- (void)initialValueSetup {
    NSLog(@"initialValueSetup");
    nextId = 0;
    isLoading = NO;
    isReloading = NO;
    
    followFromListArray = [[NSMutableArray alloc] init];
    self.titleLabel.text = @"關注我的人";
    [LabelAttributeStyle changeGapStringAndLineSpacingCenterAlignment: self.titleLabel content: self.titleLabel.text];
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
    
    noInfoView.hidden = YES;
    isNoInfoViewCreate = NO;
    self.tableView.hidden = YES;
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
        [self getFollowFromList];
    }
}

- (void)getFollowFromList {
    NSLog(@"getFollowFromList");
    [self.activityIndicatorView startAnimating];
    
    NSString *limit = [NSString stringWithFormat: @"%ld,%d", (long)nextId, 16];
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI getFollowFromList: [wTools getUserToken]
                                                userId: [wTools getUserID]
                                                 limit: limit];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicatorView stopAnimating];
            
            if (response != nil) {
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"FollowFromListViewController");
                    NSLog(@"getFollowFromList");
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getFollowFromList"
                                          userId: 0
                                            cell: nil];
                    [wself.refreshControl endRefreshing];
                    wself->isReloading = NO;
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    [wself processFollowFromList:dic];
                }
            }
        });
    });
}

- (void)processFollowFromList:(NSDictionary *)dic {
    if ([dic[@"result"] isEqualToString: @"SYSTEM_OK"]) {
        NSLog(@"SYSTEM_OK");
        NSLog(@"dic data: %@", dic[@"data"]);
        NSLog(@"Before");
        NSLog(@"nextId: %ld", (long)nextId);
        
        if (nextId == 0) {
            followFromListArray = [[NSMutableArray alloc] init];
        }
        // s for counting how much data is loaded
        int s = 0;
        
        for (NSMutableDictionary *followFromDic in [dic objectForKey: @"data"]) {
            NSLog(@"followFromDic: %@", followFromDic);
            s++;
            [followFromListArray addObject: followFromDic];
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
        
        if (followFromListArray.count == 0) {
            if (!isNoInfoViewCreate) {
                [self addNoInfoViewOnCollectionView: @"還沒有人關注"];
            }
            noInfoView.hidden = NO;
            self.tableView.hidden = YES;
        } else if (followFromListArray.count > 0) {
            noInfoView.hidden = YES;
            self.tableView.hidden = NO;
        }
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

- (void)addNoInfoViewOnCollectionView:(NSString *)msg {
    NSLog(@"addNoInfoViewOnCollectionView");
    if (!isNoInfoViewCreate) {
        noInfoView = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Vert];
        noInfoView.myTopMargin = 300;
        noInfoView.myLeftMargin = noInfoView.myRightMargin = 64;        
        noInfoView.backgroundColor = [UIColor thirdGrey];
        noInfoView.layer.cornerRadius = 16;
        noInfoView.clipsToBounds = YES;
        [self.view addSubview: noInfoView];
        
        MyFrameLayout *frameLayout = [self createFrameLayout];
        [noInfoView addSubview: frameLayout];
        
        UILabel *label = [self createLabel: msg];
        [frameLayout addSubview: label];
    }
    isNoInfoViewCreate = YES;
}

- (MyFrameLayout *)createFrameLayout {
    MyFrameLayout *frameLayout = [MyFrameLayout new];
    frameLayout.wrapContentHeight = YES;
    frameLayout.wrapContentWidth = YES;
    frameLayout.myMargin = 0;
    frameLayout.myCenterXOffset = 0;
    frameLayout.myCenterYOffset = 0;
    frameLayout.padding = UIEdgeInsetsMake(32, 32, 32, 32);
    return frameLayout;
}

- (UILabel *)createLabel: (NSString *)title {
    UILabel *label = [UILabel new];
    label.wrapContentHeight = YES;
    label.wrapContentWidth = YES;
    label.myLeftMargin = label.myRightMargin = 8;
    label.numberOfLines = 0;
    label.text = title;
    [LabelAttributeStyle changeGapString: label content: label.text];
    label.font = [UIFont systemFontOfSize: 17];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor firstGrey];
    [label sizeToFit];
    //    label.myCenterXOffset = 0;
    //    label.myCenterYOffset = 0;
    
    return label;
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return followFromListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForRowAtIndexPath");
    NSLog(@"followFromListArray: %@", followFromListArray);
    __weak FollowFromListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Cell" forIndexPath: indexPath];
    NSDictionary *dic = [followFromListArray[indexPath.row] copy];
    NSString *imageUrl = dic[@"user"][@"picture"];
    NSString *name = dic[@"user"][@"name"];
    NSInteger userId = [dic[@"user"][@"user_id"] integerValue];
    
//    cell.headshotImageView.layer.cornerRadius = cell.headshotImageView.frame.size.height / 2;
    
    if ([imageUrl isEqual: [NSNull null]] || [imageUrl isEqualToString: @""]) {
        cell.headshotImageView.image = [UIImage imageNamed: @"member_back_head.png"];
    } else {
        //        [cell.headshotImageView sd_setImageWithURL: [NSURL URLWithString: imageUrl]];
        [cell.headshotImageView sd_setImageWithURL: [NSURL URLWithString: imageUrl] placeholderImage: [UIImage imageNamed: @"member_back_head.png"]];
    }
    if (![name isEqual: [NSNull null]]) {
        cell.userNameLabel.text = name;
        [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: cell.userNameLabel content: cell.userNameLabel.text];
    }
    NSLog(@"user is_follow: %d", [dic[@"user"][@"is_follow"] boolValue]);
    //    cell.isFollow = [dic[@"user"][@"is_follow"] boolValue];
    
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
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath");
    NSDictionary *dic = [followFromListArray[indexPath.row] copy];
    NSInteger userId = [dic[@"user"][@"user_id"] integerValue];
    CreaterViewController *cVC = [[UIStoryboard storyboardWithName: @"CreaterVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CreaterViewController"];
    cVC.userId = [NSString stringWithFormat: @"%ld", (long)userId];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: cVC animated: YES];
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
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
                  cell:(FollowFromListTableViewCell *)cell {
    [self.activityIndicatorView startAnimating];
    NSString *userIdStr = [NSString stringWithFormat: @"%ld", (long)userId];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSString *respnose = [boxAPI changefollowstatus: [wTools getUserID]
                                                  token: [wTools getUserToken]
                                               authorid: userIdStr];
        
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
                        if ([wTools objectExists: dic[@"data"]]) {
                            NSDictionary *d = dic[@"data"];
                            [self updateFollowBtnStatus: cell.followBtn
                                               isFollow: [d[@"followstatus"] boolValue]];
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
- (void)showCustomErrorAlert:(NSString *)msg {
    [UIViewController showCustomErrorAlertWithMessage:msg onButtonTouchUpBlock:^(CustomIOSAlertView *customAlertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[customAlertView tag]);
        [customAlertView close];
    }];
}

#pragma mark - Custom Method for TimeOut
- (void)showCustomTimeOutAlert:(NSString *)msg
                  protocolName:(NSString *)protocolName
                        userId:(NSInteger)userId
                          cell:(FollowFromListTableViewCell *)cell {
    CustomIOSAlertView *alertTimeOutView = [[CustomIOSAlertView alloc] init];
    alertTimeOutView.parentView = self.view;
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
            if ([protocolName isEqualToString: @"getFollowFromList"]) {
                [weakSelf getFollowFromList];
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
