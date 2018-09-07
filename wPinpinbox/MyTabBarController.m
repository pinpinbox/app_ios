//
//  MyTabBarController.m
//  wPinpinbox
//
//  Created by David on 12/14/16.
//  Copyright © 2016 Angus. All rights reserved.
//

#import "MyTabBarController.h"
#import "AppDelegate.h"
#import "AlbumCreationViewController.h"

#import "boxAPI.h"
#import "wTools.h"
#import "CustomIOSAlertView.h"

#import "UIColor+Extensions.h"
#import "GlobalVars.h"

#import "MyLinearLayout.h"

#import <SafariServices/SafariServices.h>
#import "UIViewController+ErrorAlert.h"

@interface MyTabBarController ()
{
    UIButton *centerButton;
    BOOL isiPhoneX;
}
@property (strong, nonatomic) NSString *tempAlbumId;

@end

const CGFloat kBarHeight = 56;

@implementation MyTabBarController

- (void)toHomeTab {
    NSLog(@"toHomeTab");
    self.selectedIndex = kHomeTabIndex;
}

- (void)toMeTab {
    NSLog(@"toMeTab");
    self.selectedIndex = kMeTabIndex;
}

- (void)checkBadge {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"badgeCount: %d", [[defaults objectForKey: @"badgeCount"] intValue]);
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([[defaults objectForKey: @"badgeCount"] intValue] > 0) {
        for (UIViewController *vc in appDelegate.myNav.viewControllers) {
            NSLog(@"vc: %@", vc);
            if ([vc isKindOfClass: [MyTabBarController class]]) {
                MyTabBarController *myTabBarC = (MyTabBarController *)vc;
                [[myTabBarC.viewControllers objectAtIndex: kNotifTabIndex] tabBarItem].badgeValue = @"N";
            }
        }
    }
}

- (void)presentSafariVC:(NSString *)urlStr {
    NSLog(@"");
    NSLog(@"MyTabBarController");
    NSLog(@"presentSafariVC");
    NSLog(@"urlStr: %@", urlStr);
    
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: [NSURL URLWithString: urlStr]  entersReaderIfAvailable: NO];
    safariVC.preferredBarTintColor = [UIColor whiteColor];
    [self presentViewController: safariVC animated: YES completion: nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"");
    NSLog(@"MyTabBarController viewDidLoad");
    
    isiPhoneX = NO;
    
    self.delegate = self;
    
    // Do any additional setup after loading the view.
    self.tabBar.barTintColor = [UIColor whiteColor];
    self.tabBar.clipsToBounds = YES;
    
    //[[self.viewControllers objectAtIndex: 3] tabBarItem].badgeValue = @"N";
    /*
    UIViewController *vc = [self.viewControllers objectAtIndex: 2];
    vc.tabBarItem = [[UITabBarItem alloc] initWithTitle: @""
                                                  image: [UIImage imageNamed: @"CreateTab"]
                                                    tag: 3];
     */
    
    /*
    CGRect tabFrame = self.tabBar.frame;
    NSLog(@"Before Change");
    NSLog(@"tabFrame: %@", NSStringFromCGRect(tabFrame));
    
    tabFrame.size.height = kBarHeight;
    tabFrame.origin.y = self.view.frame.size.height - kBarHeight;
    NSLog(@"After Change");
    NSLog(@"tabFrame: %@", NSStringFromCGRect(tabFrame));
    self.tabBar.frame = tabFrame;
    
    NSLog(@"self.tabBar.frame.size.height: %f", self.tabBar.frame.size.height);
    */
    
    [self createCenterButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"MyTabBarController viewWillAppear");
    [self checkBadge];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"MyTabBarController viewWillDisappear");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {    
    NSLog(@"MyTabBarController viewWillLayoutSubviews");
    
    [self.view bringSubviewToFront: centerButton];
}

- (void)createCenterButton
{
    UIImage *buttonImage = [UIImage imageNamed: @"CreateTab"];
    UIImage *hightlightImage = [UIImage imageNamed: @"CreateSelectedTab"];
    
    centerButton = [UIButton buttonWithType: UIButtonTypeCustom];
    //centerButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    centerButton.frame = CGRectMake(0.0, 0.0, 56.0f, 56.0f);
    NSLog(@"centerButton.frame: %@", NSStringFromCGRect(centerButton.frame));
    [centerButton setBackgroundImage: buttonImage forState: UIControlStateNormal];
    [centerButton setBackgroundImage: hightlightImage forState: UIControlStateHighlighted];
    centerButton.tag = 104;
    
    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;
//    NSLog(@"");
//    NSLog(@"self.tabBar.frame.size.height: %f", self.tabBar.frame.size.height);
//    NSLog(@"buttonImage.size.height: %f", buttonImage.size.height);
//    NSLog(@"heightDifference: %f", heightDifference);
//    NSLog(@"");
    
    NSLog(@"heightDifference: %f", heightDifference);
    
    [self checkDevice];
    
    if (heightDifference < 0) {
        if (isiPhoneX) {
            centerButton.center = CGPointMake(self.tabBar.center.x, self.tabBar.center.y - 35);
        } else {
            centerButton.center = CGPointMake(self.tabBar.center.x, self.tabBar.center.y - 5);
        }
        NSLog(@"centerButton.center.y: %f", centerButton.center.y);
    } else {
        CGPoint center = self.tabBar.center;
        center.y = center.y - heightDifference / 2.0;
        NSLog(@"center.y: %f", center.y);
        centerButton.center = center;
    }
    
    [centerButton addTarget: self action: @selector(centerBtnPress) forControlEvents: UIControlEventTouchUpInside];
    
    [self.view addSubview: centerButton];
}

- (void)checkDevice {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                isiPhoneX = NO;
                break;
            case 1334:
                printf("iPhone 6/6S/7/8");
                isiPhoneX = NO;
                break;
            case 1920:
                printf("iPhone 6+/6S+/7+/8+");
                isiPhoneX = NO;
                break;
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                isiPhoneX = NO;
                break;
            case 2436:
                printf("iPhone X");
                isiPhoneX = YES;
                break;
            default:
                printf("unknown");
                isiPhoneX = NO;
                break;
        }
    }
}

- (void)centerBtnPress
{
    NSLog(@"centerButtonPress");
    
    [self toAlbumCreationVC];
}

- (void)hideCenterButton
{
    NSLog(@"hideCenterButton");
    //centerButton.hidden = true;
    //[centerButton removeFromSuperview];
}

- (void)showCenterButton
{
    NSLog(@"showCenterButton");
    //centerButton.hidden = false;
    //[self createCenterButton];
}

- (void)bringCenterButtonToFront
{
    //[self.view bringSubviewToFront: centerButton];
}

- (void)toAlbumCreationVC {
    // Data Storing for FastViewController popToHomeViewController Directly
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL fromHomeVC = YES;
    [defaults setObject: [NSNumber numberWithBool: fromHomeVC]
                 forKey: @"fromHomeVC"];
    [defaults synchronize];
    NSLog(@"FastBtn");
    [self addNewFastMod];
}

- (void)checkAlbumOfDiy {
    NSLog(@"");
    NSLog(@"checkAlbumOfDiy");
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI checkalbumofdiy: [wTools getUserID]
                                               token: [wTools getUserToken]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"response from checkalbumofdiy");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"MyTabBarController");
                    NSLog(@"checkAlbumOfDiy");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"checkalbumofdiy"
                                         albumId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSLog(@"response: %@", response);
                    
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    NSLog(@"dic: %@", dic);
                    
                    if (dic != nil) {
                        NSLog(@"dic != nil");
                        
                        if ([dic[@"result"] intValue] == 1) {
                            NSLog(@"dic result boolValue is 1");
                            
                            [self updateAlbumOfDiy: [dic[@"data"][@"album"][@"album_id"] stringValue]];
                        } else if ([dic[@"result"] intValue] == 0) {
                            NSLog(@"失敗：%@",dic[@"message"]);
                            [self showCustomErrorAlert: dic[@"message"]];
                        } else {
                            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                        }
                    } else {
                        NSLog(@"dic == nil");
                        [self addNewFastMod];
                    }
                }
            }
        });
    });
}

- (void)updateAlbumOfDiy: (NSString *)albumId
{
    NSLog(@"");
    NSLog(@"updateAlbumOfDiy: albumId: %@", albumId);
    
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI updatealbumofdiy: [wTools getUserID]
                                                token: [wTools getUserToken]
                                             album_id: albumId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"response from checkalbumofdiy");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"MyTabBarController");
                    NSLog(@"updateAlbumOfDiy albumId");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"updatealbumofdiy"
                                         albumId: albumId];
                } else {
                    NSLog(@"Get Real Response");
                    
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"dic result boolValue is 1");
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗：%@",dic[@"message"]);
                        [self showCustomErrorAlert: dic[@"message"]];
                    } else {
                        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}

//快速套版
- (void)addNewFastMod {
    NSLog(@"addNewFastMod");
    
    //新增相本id
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        
        NSString *response = [boxAPI insertalbumofdiy: [wTools getUserID]
                                                token: [wTools getUserToken]
                                          template_id: @"0"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"response from insertalbumofdiy");
                NSLog(@"response: %@",response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"MyTabBarController");
                    NSLog(@"addNewFastMod");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"insertalbumofdiy"
                                         albumId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"] boolValue]) {
                        NSLog(@"get result value from insertalbumofdiy");
                        self.tempAlbumId = [dic[@"data"] stringValue];
                        
                        AlbumCreationViewController *albumCreationVC = [[UIStoryboard storyboardWithName: @"AlbumCreationVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumCreationViewController"];
                        NSLog(@"");
                        
                        // Data from wTools userbook is not right
                        //albumCreationVC.selectrow = [wTools userbook];
                        
                        albumCreationVC.albumid = self.tempAlbumId;
                        albumCreationVC.templateid = @"0";
                        albumCreationVC.choice = @"Fast";
                        albumCreationVC.isNew = YES;
                        
                        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        [appDelegate.myNav pushViewController: albumCreationVC animated: YES];
                        
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setObject: [NSNumber numberWithBool: YES] forKey: @"createAlbum"];
                        [defaults synchronize];
                        
                        //NSLog(@"appDelegate.myNav: %@", appDelegate.myNav);
                    } else {
                        NSLog(@"失敗：%@", dic[@"message"]);
                        [self showCustomErrorAlert: dic[@"messager"]];
                    }
                }
            }
        });
    });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UIInterfaceOrientationMask)tabBarControllerSupportedInterfaceOrientations:(UITabBarController *)tabBarController
{
    NSLog(@"tabBarControllerSupportedInterfaceOrientations");
    
    if (tabBarController.selectedIndex == 0) {
        return UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskAllButUpsideDown;
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
- (void)showCustomTimeOutAlert: (NSString *)msg
                  protocolName: (NSString *)protocolName
                       albumId: (NSString *)albumId
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
            if ([protocolName isEqualToString: @"checkalbumofdiy"]) {
                [weakSelf checkAlbumOfDiy];
            } else if ([protocolName isEqualToString: @"updateAlbumOfDiy"]) {
                [weakSelf updateAlbumOfDiy: albumId];
            } else if ([protocolName isEqualToString: @"insertalbumofdiy"]) {
                [weakSelf addNewFastMod];
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
