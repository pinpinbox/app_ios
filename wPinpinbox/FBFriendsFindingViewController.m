//
//  FBFriendsFindingViewController.m
//  wPinpinbox
//
//  Created by David on 4/17/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "FBFriendsFindingViewController.h"
#import "UIColor+Extensions.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "MBProgressHUD.h"
#import "boxAPI.h"
#import "wTools.h"
#import "FBFriendsListViewController.h"
#import "FBFriendNotFoundViewController.h"

#import "ChooseHobbyViewController.h"

#import "CustomIOSAlertView.h"

#import "GlobalVars.h"

#import "AppDelegate.h"
#import "UIViewController+ErrorAlert.h"

typedef void (^FBBlock)(void);typedef void (^FBBlock)(void);

@interface FBFriendsFindingViewController ()
{
    BOOL isLoading;
    NSString *dataRank;
    NSInteger nextId;
    NSMutableArray *pictures;
}
@end

@implementation FBFriendsFindingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self gradientViewSetup];
    [self initSetup];
    [self buttonSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup Methods
- (void)gradientViewSetup
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.gradientView.bounds;
    gradient.colors = @[(id)[UIColor FBGradientViewColor].CGColor, (id)[UIColor whiteColor].CGColor];
    
    [self.gradientView.layer insertSublayer: gradient atIndex: 0];
    self.gradientView.alpha = 0.6;
}

- (void)initSetup
{
    nextId = 0;
    isLoading = NO;
    pictures = [NSMutableArray new];
}

- (void)buttonSetup {
    self.okBtn.layer.cornerRadius = 16;    
    self.skipBtn.layer.cornerRadius = 16;
}

#pragma mark - IBAction Methods
- (IBAction)skipBtnPress:(id)sender {
    ChooseHobbyViewController *chooseHobbyVC = [[UIStoryboard storyboardWithName: @"ChooseHobbyVC" bundle: nil] instantiateViewControllerWithIdentifier: @"ChooseHobbyViewController"];
    //[self.navigationController pushViewController: chooseHobbyVC animated: YES];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: chooseHobbyVC animated: YES];
}

- (IBAction)findFBFriends:(id)sender {
    NSLog(@"findFBFriends");
    
    if ([FBSDKAccessToken currentAccessToken]) {
        [self facebookFriends];
    } else {
        __block typeof(self) wself = self;
        // Try to login with permissions
        [self loginAndRequestPermissionsWithSuccessHandler:^{
            [wself facebookFriends];
        } declinedOrCanceledHandler:^{
            // If the user declined permissions tell them why we need permissions
            // and ask for permissions again if they want to grant permissions.
            [wself alertDeclinedPublishActionsWithCompletion:^{
                [wself loginAndRequestPermissionsWithSuccessHandler: nil declinedOrCanceledHandler: nil errorHandler:^(NSError * error) {
                    __strong typeof(wself) sself = wself;
                    sself->isLoading = YES;
                    NSLog(@"Error: %@", error.description);
                }];
            }];
        } errorHandler:^(NSError * error) {
            __strong typeof(wself) sself = wself;
            NSLog(@"Error: %@", error.description);
            sself->isLoading = YES;
        }];
    }
}

#pragma mark -

- (void)facebookFriends {
    NSLog(@"facebookFriends");
    
    if ([[FBSDKAccessToken currentAccessToken].permissions containsObject: @"user_friends"]) {
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath: @"/me/friends"
                                                                       parameters: [NSDictionary new]
                                                                       HTTPMethod: @"GET"];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (connection) {
                NSLog(@"Friends = %@", result);
                NSArray *data = result[@"data"];
                NSString *rank = @"facebook=";
                
                if ([wTools objectExists: data]) {
                    for (int i = 0; i < data.count; i++) {
                        NSDictionary *d = data[i];
                        
                        if (i == 0) {
                            rank = [NSString stringWithFormat: @"%@%@", rank, d[@"id"]];
                        } else {
                            rank = [NSString stringWithFormat: @"%@,%@", rank, d[@"id"]];
                        }
                    }
                    [self reloadAPI: rank];
                }
            } else if (!connection) {
                NSLog(@"Get Friends Error");
                [self showCustomErrorAlert: @"連線失敗"];
            }
        }];
        return;
    }
    
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logInWithReadPermissions: @[@"user_friends"]
                        fromViewController: self
                                   handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                       if (error) {
                                           NSLog(@"error");
                                           return;
                                       }
                                       
                                       if ([FBSDKAccessToken currentAccessToken] && [[FBSDKAccessToken currentAccessToken].permissions containsObject: @"user_friends"]) {
                                           FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath: @"/me/friends" parameters: [NSDictionary new] HTTPMethod: @"GET"];
                                           
                                           [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                                               if (connection) {
                                                   NSLog(@"Friends = %@", result);
                                                   NSArray *data = result[@"data"];
                                                   NSString *rank = @"facebook=";
                                                   
                                                   if ([wTools objectExists: data]) {
                                                       for (int i = 0; i < data.count; i++) {
                                                           NSDictionary *d = data[i];
                                                           
                                                           if (i == 0) {
                                                               rank = [NSString stringWithFormat: @"%@%@", rank, d[@"id"]];
                                                           } else {
                                                               rank = [NSString stringWithFormat: @"%@,%@", rank, d[@"id"]];
                                                           }
                                                       }
                                                       [self reloadAPI: rank];
                                                   }
                                               } else if (!connection) {
                                                   NSLog(@"Get Friends Error");
                                                   [self showCustomErrorAlert: @"連線失敗"];
                                               }
                                           }];
                                           return;
                                       }
                                       NSLog(@"100");
                                   }];
}

- (void)loginAndRequestPermissionsWithSuccessHandler:(FBBlock) successHandler
                           declinedOrCanceledHandler:(FBBlock) declinedOrCanceledHandler
                                        errorHandler:(void (^)(NSError *)) errorHandler {
    NSLog(@"loginAndRequestPermissionsWithSuccessHandler");
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    //public_profile
    //publish_actions
    [login
     logInWithReadPermissions: @[@"public_profile"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         
         if (error) {
             if (errorHandler) {
                 errorHandler(error);
             }
             return;
         }
         if ([FBSDKAccessToken currentAccessToken] &&
             [[FBSDKAccessToken currentAccessToken].permissions containsObject:@"public_profile"]) {
             
             if (successHandler) {
                 successHandler();
             }
             return;
         }
         if (declinedOrCanceledHandler) {
             declinedOrCanceledHandler();
         }
     }];
}

- (void)alertDeclinedPublishActionsWithCompletion:(FBBlock)completion {
    /*
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Publish Permissions" message: @"Publish permissions are needed to share game content automatically. Do you want to enable publish permissions?" preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction *okBtn = [UIAlertAction actionWithTitle: @"確 定" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"確 定 Pressed");
    }];
    [alert addAction: okBtn];
    [self presentViewController: alert animated: YES completion: nil];
    */
    
    /*
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Publish Permissions"
                                                        message:@"Publish permissions are needed to share game content automatically. Do you want to enable publish permissions?"
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Ok", nil];
    _alertOkHandler = [completion copy];
    [alertView show];
     */
}

- (void)reloadAPI:(NSString *)rank
{
    NSLog(@"reloadAPI: rank: %@", rank);
    
    dataRank = [NSString stringWithFormat: @"%@", rank];
    nextId = 0;
    isLoading = NO;
    [pictures removeAllObjects];
    [self loadData: rank];
}

- (void)processFBResult:(NSDictionary *)dic {
    if ([dic[@"result"] intValue] == 1) {
        int s = 0;
        
        if ([wTools objectExists: dic[@"data"]]) {
            for (NSMutableDictionary *picture in [dic objectForKey: @"data"]) {
                s++;
                [pictures addObject: picture];
            }
            nextId = nextId + s;
            
            if (nextId >= 0) {
                isLoading = NO;
            }
            NSLog(@"pictures: %@", pictures);
            
            if (pictures.count == 0) {
                FBFriendNotFoundViewController *fbFriendNotFoundVC = [[UIStoryboard storyboardWithName: @"FBFriendNotFoundVC" bundle: nil] instantiateViewControllerWithIdentifier: @"FBFriendNotFoundViewController"];
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [appDelegate.myNav pushViewController: fbFriendNotFoundVC animated: YES];
            } else if (pictures.count > 0) {
                FBFriendsListViewController *fbFriendsVC = [[UIStoryboard storyboardWithName: @"FBFriendsListVC" bundle: nil] instantiateViewControllerWithIdentifier: @"FBFriendsListViewController"];
                fbFriendsVC.fbArray = [pictures mutableCopy];
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [appDelegate.myNav pushViewController: fbFriendsVC animated: YES];
            }
        }
    } else if ([dic[@"result"] intValue] == 0) {
        NSLog(@"失敗： %@", dic[@"message"]);
        if ([wTools objectExists: dic[@"message"]]) {
            [self showCustomErrorAlert: dic[@"message"]];
        } else {
            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
        }
    } else {
        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
    }
}

- (void)loadData: (NSString *)rank {
    NSLog(@"loadData: rank: %@", rank);
    
    if (!isLoading) {
        if (pictures.count == 0) {
            @try {
                [MBProgressHUD showHUDAddedTo: self.view animated:YES];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason);
                return;
            }
        }
        isLoading = YES;
        NSMutableDictionary *data = [NSMutableDictionary new];
        NSString *limit = [NSString stringWithFormat: @"%ld,%d", (long)nextId, 10];
        [data setValue: limit forKey: @"limit"];
        
        if (rank == nil) {
            [data setObject: @"official=" forKey: @"rank"];
        } else {
            [data setObject: rank forKey: @"rank"];
        }
        __block typeof(self) wself = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
            NSString *response = [boxAPI getrecommended: [wTools getUserID]
                                                  token: [wTools getUserToken]
                                                   data: data];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                @try {
                    [MBProgressHUD hideHUDForView: self.view  animated:YES];
                } @catch (NSException *exception) {
                    // Print exception information
                    NSLog( @"NSException caught" );
                    NSLog( @"Name: %@", exception.name);
                    NSLog( @"Reason: %@", exception.reason);
                    return;
                }
                if (response != nil) {
                    NSLog(@"response: %@", response);
                    
                    if ([response isEqualToString: timeOutErrorCode]) {
                        NSLog(@"Time Out Message Return");
                        NSLog(@"FBFriendsFindingViewController");
                        NSLog(@"loadData rank");
                        
                        [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                        protocolName: @"getrecommended"
                                                rank: rank];
                    } else {
                        NSLog(@"Get Real Response");                        
                        NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                        [wself processFBResult:dic];
                    }                                        
                }
            });
        });
    }
}

#pragma mark - Custom Alert Method
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
                          rank: (NSString *)rank
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
            if ([protocolName isEqualToString: @"getrecommended"]) {
                [weakSelf loadData: rank];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
