//
//  BuyPPointViewController.m
//  wPinpinbox
//
//  Created by David on 5/25/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "BuyPPointViewController.h"
#import "boxAPI.h"
#import "wTools.h"
#import "UIColor+Extensions.h"
#import "InAppPurchaseManager.h"
#import "CustomIOSAlertView.h"
#import "OldCustomAlertView.h"
#import <SafariServices/SafariServices.h>
#import "GlobalVars.h"

#import "AppDelegate.h"

@interface BuyPPointViewController () <SFSafariViewControllerDelegate, UIGestureRecognizerDelegate>
{
    NSString *pointstr;
    NSDictionary *pointlist;
    NSArray *listdata;
    NSArray *totalArray;
    NSString *selectproductid;
    
    NSArray *datakey;
    
    //價格表
    NSDictionary *pointdata;
    
    NSString *orderid;
    
    // For Showing Message of Getting Point
    NSString *missionTopicStr;
    NSString *rewardType;
    NSString *rewardValue;
    NSString *eventUrl;
    
    NSString *restriction;
    NSString *restrictionValue;
    NSUInteger numberOfCompleted;
    
    OldCustomAlertView *alertTaskView;
}
@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarHeight;
@property (weak, nonatomic) IBOutlet UILabel *userPointLabel;

@property (weak, nonatomic) IBOutlet UIButton *firstBtn;
@property (weak, nonatomic) IBOutlet UIButton *secondBtn;
@property (weak, nonatomic) IBOutlet UIButton *thirdBtn;
@property (weak, nonatomic) IBOutlet UIButton *fourthBtn;
@property (weak, nonatomic) IBOutlet UIButton *fifthBtn;
@property (weak, nonatomic) IBOutlet UIButton *sixthBtn;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) NSString *priceTitle;
@property (weak, nonatomic) IBOutlet UIButton *buyBtn;

@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@end

@implementation BuyPPointViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.delegate = self;
    
    [self initialValueSetup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    for (UIView *v in self.tabBarController.view.subviews) {
        UIButton *btn = (UIButton *)[v viewWithTag: 104];
        btn.hidden = YES;
    }
    
    [self getPointStore];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Force view to dislay portrait mode
    [[UIDevice currentDevice] setValue: [NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey: @"orientation"];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.enabled = NO;
}

#pragma mark -
- (void)initialValueSetup
{
    self.navBarView.backgroundColor = [UIColor barColor];

    self.firstBtn.layer.borderColor = [UIColor blackColor].CGColor;
    self.firstBtn.layer.borderWidth = 0;
    self.firstBtn.layer.cornerRadius = kCornerRadius;
    self.firstBtn.backgroundColor = [UIColor thirdMain];
    
    self.secondBtn.layer.borderColor = [UIColor blackColor].CGColor;
    self.secondBtn.layer.borderWidth = 0.5;
    self.secondBtn.layer.cornerRadius = kCornerRadius;

    self.thirdBtn.layer.borderColor = [UIColor blackColor].CGColor;
    self.thirdBtn.layer.borderWidth = 0.5;
    self.thirdBtn.layer.cornerRadius = kCornerRadius;
    
    self.fourthBtn.layer.borderColor = [UIColor blackColor].CGColor;
    self.fourthBtn.layer.borderWidth = 0.5;
    self.fourthBtn.layer.cornerRadius = kCornerRadius;
    
    self.fifthBtn.layer.borderColor = [UIColor blackColor].CGColor;
    self.fifthBtn.layer.borderWidth = 0.5;
    self.fifthBtn.layer.cornerRadius = kCornerRadius;
    
    self.sixthBtn.layer.borderColor = [UIColor blackColor].CGColor;
    self.sixthBtn.layer.borderWidth = 0.5;
    self.sixthBtn.layer.cornerRadius = kCornerRadius;
    
    self.buyBtn.layer.cornerRadius = kCornerRadius;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)getPointStore
{
    NSLog(@"getPointStore");
    
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI getpointstore: [userPrefs objectForKey: @"id"]
                                            token: [userPrefs objectForKey: @"token"]];
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
            
            NSLog(@"response from getPointStore: %@", response);
            
            if (response != nil) {
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"BuyPPointViewController");
                    NSLog(@"getPointStore");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getpointstore"
                                 selectProductId: @""
                                   dataSignature: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    NSLog(@"dic: %@", dic);
                    
                    if ([dic[@"result"] intValue] == 1) {
                        pointlist = [dic[@"data"] mutableCopy];
                        
                        NSMutableArray *testarr=[NSMutableArray new];
                        NSMutableArray *testarr2=[NSMutableArray new];
                        NSMutableArray *testarr3 = [NSMutableArray new];
                        
                        for (NSDictionary *pointdic in pointlist) {
                            NSString *platform_flag = pointdic[@"platform_flag"];
                            NSString *obtain = [pointdic[@"obtain"] stringValue];
                            NSString *total = pointdic[@"total"];
                            
                            NSArray *strArray = [total componentsSeparatedByString: @"."];
                            NSString *newTotal = [strArray objectAtIndex: 0];
                            
                            [testarr addObject: platform_flag];
                            [testarr2 addObject: obtain];
                            [testarr3 addObject: newTotal];
                        }
                        datakey = [NSArray arrayWithArray:testarr];
                        NSLog(@"datakey: %@", datakey);
                        
                        listdata = [NSArray arrayWithArray:testarr2];
                        NSLog(@"listdata: %@", listdata);
                        
                        totalArray = [NSArray arrayWithArray: testarr3];
                        NSLog(@"totalArray: %@", totalArray);
                        
                        //NSString *str = [NSString stringWithFormat: @"還有%ldP點可使用", (long)point];
                        //self.userPointLabel.text = str;
                        
                        // Setup Btn Title for P Point
                        [self.firstBtn setTitle: [NSString stringWithFormat: @"%@ P", listdata[0]]
                                       forState: UIControlStateNormal];
                        [self.secondBtn setTitle: [NSString stringWithFormat: @"%@ P", listdata[1]]
                                        forState: UIControlStateNormal];
                        [self.thirdBtn setTitle: [NSString stringWithFormat: @"%@ P", listdata[2]]
                                       forState: UIControlStateNormal];
                        [self.fourthBtn setTitle: [NSString stringWithFormat: @"%@ P", listdata[3]]
                                        forState: UIControlStateNormal];
                        [self.fifthBtn setTitle: [NSString stringWithFormat: @"%@ P", listdata[4]]
                                       forState: UIControlStateNormal];
                        
                        if (pointlist.count <= 5) {
                            self.sixthBtn.hidden = YES;
                        } else {
                            self.sixthBtn.hidden = NO;
                            [self.sixthBtn setTitle: [NSString stringWithFormat: @"%@ P", listdata[5]]
                                           forState: UIControlStateNormal];
                        }
                        self.priceLabel.text = [NSString stringWithFormat: @"NT$%@", totalArray[0]];
                        
                        selectproductid = datakey[0];
                        
                        [self getUrPoints];
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

- (void)getUrPoints {
    NSLog(@"getUrPoints");
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        pointstr = [boxAPI geturpoints: [userPrefs objectForKey: @"id"]
                                 token: [userPrefs objectForKey: @"token"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (pointstr != nil) {
                if ([pointstr isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"BuyPPointViewController");
                    NSLog(@"getUrPoints");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"geturpoints"
                                 selectProductId: @""
                                   dataSignature: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *pointdic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[pointstr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    NSLog(@"pointdic: %@", pointdic);
                    NSInteger point = [pointdic[@"data"] integerValue];
                    
                    [userPrefs setObject: [NSNumber numberWithInteger: point] forKey: @"pPoint"];
                    [userPrefs synchronize];
                    
                    pointstr = [NSString stringWithFormat:@"%ld",(long)point];
                    
                    NSString *str = [NSString stringWithFormat: @"還有%ldP點可使用", (long)point];
                    NSLog(@"str: %@", str);
                    self.userPointLabel.text = str;
                    
                    [InAppPurchaseManager getInstance].delegate = self;
                    [InAppPurchaseManager getInstance].priceid = datakey;
                    [[InAppPurchaseManager getInstance] loadStore]; //讀取商店資訊
                }
            }
        });
    });
}

- (IBAction)pBtnPress:(id)sender {
    UIButton *btn = (UIButton *)sender;
    
    //_selectpriceText.text=[NSString stringWithFormat:@"%@",pointdata[datakey[row]]];
    //NSLog(@"%@",listdata[row]);
    //selectproductid=datakey[row];
    
    switch (btn.tag) {
        case 1:
        {
//            NSString *priceStr = [NSString stringWithFormat: @"%@", pointdata[datakey[0]]];
//            NSArray *strArray = [priceStr componentsSeparatedByString: @"."];
//            NSString *str = [strArray objectAtIndex: 0];
            
            //self.priceLabel.text = str;
            self.priceLabel.text = [NSString stringWithFormat: @"NT$%@", totalArray[0]];
            
            selectproductid = datakey[0];
            
            self.firstBtn.layer.borderWidth = 0;
            self.firstBtn.backgroundColor = [UIColor thirdMain];
            
            self.secondBtn.layer.borderColor = [UIColor blackColor].CGColor;
            self.secondBtn.layer.borderWidth = 0.5;
            self.secondBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
            
            self.thirdBtn.layer.borderColor = [UIColor blackColor].CGColor;
            self.thirdBtn.layer.borderWidth = 0.5;
            self.thirdBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
            
            self.fourthBtn.layer.borderColor = [UIColor blackColor].CGColor;
            self.fourthBtn.layer.borderWidth = 0.5;
            self.fourthBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
            
            self.fifthBtn.layer.borderColor = [UIColor blackColor].CGColor;
            self.fifthBtn.layer.borderWidth = 0.5;
            self.fifthBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
            
            self.sixthBtn.layer.borderColor = [UIColor blackColor].CGColor;
            self.sixthBtn.layer.borderWidth = 0.5;
            self.sixthBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
            
            break;
        }
            
        case 2:
        {
//            NSString *priceStr = [NSString stringWithFormat: @"%@", pointdata[datakey[1]]];
//            NSArray *strArray = [priceStr componentsSeparatedByString: @"."];
//            NSString *str = [strArray objectAtIndex: 0];
            
            //self.priceLabel.text = str;
            self.priceLabel.text = [NSString stringWithFormat: @"NT$%@", totalArray[1]];
            
            selectproductid = datakey[1];
            
            self.firstBtn.layer.borderColor = [UIColor blackColor].CGColor;
            self.firstBtn.layer.borderWidth = 0.5;
            self.firstBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
            
            self.secondBtn.layer.borderWidth = 0;
            self.secondBtn.backgroundColor = [UIColor thirdMain];
            
            self.thirdBtn.layer.borderColor = [UIColor blackColor].CGColor;
            self.thirdBtn.layer.borderWidth = 0.5;
            self.thirdBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
            
            self.fourthBtn.layer.borderColor = [UIColor blackColor].CGColor;
            self.fourthBtn.layer.borderWidth = 0.5;
            self.fourthBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
            
            self.fifthBtn.layer.borderColor = [UIColor blackColor].CGColor;
            self.fifthBtn.layer.borderWidth = 0.5;
            self.fifthBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
            
            self.sixthBtn.layer.borderColor = [UIColor blackColor].CGColor;
            self.sixthBtn.layer.borderWidth = 0.5;
            self.sixthBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
            
            break;
        }
            
        case 3:
        {
//            NSString *priceStr = [NSString stringWithFormat: @"%@", pointdata[datakey[2]]];
//            NSArray *strArray = [priceStr componentsSeparatedByString: @"."];
//            NSString *str = [strArray objectAtIndex: 0];
            
            //self.priceLabel.text = str;
            self.priceLabel.text = [NSString stringWithFormat: @"NT$%@", totalArray[2]];
            
            selectproductid = datakey[2];
            
            self.firstBtn.layer.borderColor = [UIColor blackColor].CGColor;
            self.firstBtn.layer.borderWidth = 0.5;
            self.firstBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
            
            self.secondBtn.layer.borderColor = [UIColor blackColor].CGColor;
            self.secondBtn.layer.borderWidth = 0.5;
            self.secondBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
            
            self.thirdBtn.layer.borderWidth = 0;
            self.thirdBtn.backgroundColor = [UIColor thirdMain];
            
            self.fourthBtn.layer.borderColor = [UIColor blackColor].CGColor;
            self.fourthBtn.layer.borderWidth = 0.5;
            self.fourthBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
            
            self.fifthBtn.layer.borderColor = [UIColor blackColor].CGColor;
            self.fifthBtn.layer.borderWidth = 0.5;
            self.fifthBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
            
            self.sixthBtn.layer.borderColor = [UIColor blackColor].CGColor;
            self.sixthBtn.layer.borderWidth = 0.5;
            self.sixthBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
            
            break;
        }
            
        case 4:
        {
//            NSString *priceStr = [NSString stringWithFormat: @"%@", pointdata[datakey[3]]];
//            NSArray *strArray = [priceStr componentsSeparatedByString: @"."];
//            NSString *str = [strArray objectAtIndex: 0];
            
            //self.priceLabel.text = str;
            self.priceLabel.text = [NSString stringWithFormat: @"NT$%@", totalArray[3]];
            
            selectproductid = datakey[3];
            
            self.firstBtn.layer.borderColor = [UIColor blackColor].CGColor;
            self.firstBtn.layer.borderWidth = 0.5;
            self.firstBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
            
            self.secondBtn.layer.borderColor = [UIColor blackColor].CGColor;
            self.secondBtn.layer.borderWidth = 0.5;
            self.secondBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
            
            self.thirdBtn.layer.borderColor = [UIColor blackColor].CGColor;
            self.thirdBtn.layer.borderWidth = 0.5;
            self.thirdBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
            
            self.fourthBtn.layer.borderWidth = 0;
            self.fourthBtn.backgroundColor = [UIColor thirdMain];
            
            self.fifthBtn.layer.borderColor = [UIColor blackColor].CGColor;
            self.fifthBtn.layer.borderWidth = 0.5;
            self.fifthBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
            
            self.sixthBtn.layer.borderColor = [UIColor blackColor].CGColor;
            self.sixthBtn.layer.borderWidth = 0.5;
            self.sixthBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
            
            break;
        }
            
        case 5:
        {
//            NSString *priceStr = [NSString stringWithFormat: @"%@", pointdata[datakey[4]]];
//            NSArray *strArray = [priceStr componentsSeparatedByString: @"."];
//            NSString *str = [strArray objectAtIndex: 0];
            
            //self.priceLabel.text = str;
            self.priceLabel.text = [NSString stringWithFormat: @"NT$%@", totalArray[4]];
            
            selectproductid = datakey[4];
            
            self.firstBtn.layer.borderColor = [UIColor blackColor].CGColor;
            self.firstBtn.layer.borderWidth = 0.5;
            self.firstBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
            
            self.secondBtn.layer.borderColor = [UIColor blackColor].CGColor;
            self.secondBtn.layer.borderWidth = 0.5;
            self.secondBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
            
            self.thirdBtn.layer.borderColor = [UIColor blackColor].CGColor;
            self.thirdBtn.layer.borderWidth = 0.5;
            self.thirdBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
            
            self.fourthBtn.layer.borderColor = [UIColor blackColor].CGColor;
            self.fourthBtn.layer.borderWidth = 0.5;
            self.fourthBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
            
            self.fifthBtn.layer.borderWidth = 0;
            self.fifthBtn.backgroundColor = [UIColor thirdMain];
            
            self.sixthBtn.layer.borderColor = [UIColor blackColor].CGColor;
            self.sixthBtn.layer.borderWidth = 0.5;
            self.sixthBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
            
            break;
        }
            
        case 6:
        {
//            NSString *priceStr = [NSString stringWithFormat: @"%@", pointdata[datakey[5]]];
//            NSArray *strArray = [priceStr componentsSeparatedByString: @"."];
//            NSString *str = [strArray objectAtIndex: 0];
            
            //self.priceLabel.text = str;
            self.priceLabel.text = [NSString stringWithFormat: @"NT$%@", totalArray[5]];
            
            selectproductid = datakey[5];
            
            self.firstBtn.layer.borderColor = [UIColor blackColor].CGColor;
            self.firstBtn.layer.borderWidth = 0.5;
            self.firstBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
            
            self.secondBtn.layer.borderColor = [UIColor blackColor].CGColor;
            self.secondBtn.layer.borderWidth = 0.5;
            self.secondBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
            
            self.thirdBtn.layer.borderColor = [UIColor blackColor].CGColor;
            self.thirdBtn.layer.borderWidth = 0.5;
            self.thirdBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
            
            self.fourthBtn.layer.borderColor = [UIColor blackColor].CGColor;
            self.fourthBtn.layer.borderWidth = 0.5;
            self.fourthBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
            
            self.fifthBtn.layer.borderColor = [UIColor blackColor].CGColor;
            self.fifthBtn.layer.borderWidth = 0.5;
            self.fifthBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
            
            self.sixthBtn.layer.borderWidth = 0;
            self.sixthBtn.backgroundColor = [UIColor thirdMain];
            
            break;
        }
            
        default:
            break;
    }
}

- (IBAction)backBtnPress:(id)sender {
    NSLog(@"backBtnPress");
    NSLog(@"self.fromVC: %@", self.fromVC);
    
    if ([self.delegate respondsToSelector: @selector(buyPPointViewController:)]) {
        [self.delegate buyPPointViewController: self];
        NSLog(@"self.delegate buyPPointViewController: self");
    }
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav popViewControllerAnimated: YES];
    
    /*
    if ([self.fromVC isEqualToString: @"ContentCheckingViewController"]) {
        if ([self.delegate respondsToSelector: @selector(buyPPointViewController:)]) {
            [self.delegate buyPPointViewController: self];
            NSLog(@"self.delegate buyPPointViewController: self");
        }
    } else {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.myNav popViewControllerAnimated: YES];
    }
     */
}

- (IBAction)buyBtnPress:(id)sender {
    
    NSLog(@"%@", selectproductid);
    
    NSString *originalStr;
    NSString *priceStr;
    
    if ([selectproductid isEqualToString: datakey[0]]) {
        originalStr = [NSString stringWithFormat: @"%@", datakey[0]];
        priceStr = [NSString stringWithFormat: @"%@", totalArray[0]];
        //priceStr = [NSString stringWithFormat: @"%@", pointdata[datakey[0]]];
    }
    if ([selectproductid isEqualToString: datakey[1]]) {
        originalStr = [NSString stringWithFormat: @"%@", datakey[1]];
        priceStr = [NSString stringWithFormat: @"%@", totalArray[1]];
        //priceStr = [NSString stringWithFormat: @"%@", pointdata[datakey[1]]];
    }
    if ([selectproductid isEqualToString: datakey[2]]) {
        originalStr = [NSString stringWithFormat: @"%@", datakey[2]];
        priceStr = [NSString stringWithFormat: @"%@", totalArray[2]];
        //priceStr = [NSString stringWithFormat: @"%@", pointdata[datakey[2]]];
    }
    if ([selectproductid isEqualToString: datakey[3]]) {
        originalStr = [NSString stringWithFormat: @"%@", datakey[3]];
        priceStr = [NSString stringWithFormat: @"%@", totalArray[3]];
        //priceStr = [NSString stringWithFormat: @"%@", pointdata[datakey[3]]];
    }
    if ([selectproductid isEqualToString: datakey[4]]) {
        originalStr = [NSString stringWithFormat: @"%@", datakey[4]];
        priceStr = [NSString stringWithFormat: @"%@", totalArray[4]];
        //priceStr = [NSString stringWithFormat: @"%@", pointdata[datakey[4]]];
    }
    
    if (pointlist.count <= 5) {
        NSLog(@"pointlist.count <= 5");
    } else {
        NSLog(@"pointlist.count > 5");
        
        if ([selectproductid isEqualToString: datakey[5]]) {
            originalStr = [NSString stringWithFormat: @"%@", datakey[5]];
            priceStr = [NSString stringWithFormat: @"%@", totalArray[5]];
            //priceStr = [NSString stringWithFormat: @"%@", pointdata[datakey[5]]];
        }
    }
    
    NSLog(@"originalStr: %@", originalStr);
    NSArray *strArray1 = [originalStr componentsSeparatedByString: @"_"];
    NSString *pointStr = [strArray1 objectAtIndex: 1];
    NSLog(@"pointStr: %@", pointStr);
    
    NSArray *strArray2 = [priceStr componentsSeparatedByString: @"."];
    NSString *newPriceStr = [strArray2 objectAtIndex: 0];
    NSLog(@"newPriceStr: %@", newPriceStr);
    
    NSString *msgStr = [NSString stringWithFormat: @"確定購買%@P:NT %@", pointStr, newPriceStr];
    NSLog(@"msgStr: %@", msgStr);
    
    if ([priceStr isKindOfClass: [NSNull class]]) {
        NSLog(@"priceStr is kind of null");
    } else {
        NSLog(@"priceStr is not null");
        [self showCustomAlert: msgStr productId: selectproductid];
    }
}

- (void)buyPoint: (NSString *)selectProductId {
    NSLog(@"buyPoint: selectProductId: %@", selectProductId);
    
    if(![[InAppPurchaseManager getInstance] canMakePurchases]) {
        NSLog(@"無法使用購買服務。");
        return;
    }
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){        
        NSString *response = [boxAPI getpayload: [wTools getUserID]
                                          token: [wTools getUserToken]
                                      productid: selectproductid];
        
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
            NSLog(@"response from getPayLoad");
            
            if (response != nil) {
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"BuyPPointViewController");
                    NSLog(@"buyPoint selectProductId");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getpayload"
                                 selectProductId: selectProductId
                                   dataSignature: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    NSLog(@"dic: %@", dic);
                    
                    if ([dic[@"result"] intValue] == 1) {
                        orderid = dic[@"data"];
                        NSLog(@"orderid: %@", orderid);
                        
                        [[InAppPurchaseManager getInstance] purchaseProUpgrade2:selectproductid];
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

#pragma mark -
#pragma mark In-App Purchase

//內購相關
-(void)purchaseComplete: (NSString*)PID
                withDic: (NSDictionary*)dict
           appendString: (NSString*)str
                   flag: (int)status
{
    NSLog(@"purchaseComplete");
    NSLog(@"購買行為");
    //NSError *error;
    
    //    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
    //                                                       options:NSJSONWritingPrettyPrinted
    //                                                         error:&error];
    //     NSString *jsonString=@"";
    //    if (! jsonData) {
    //        NSLog(@"Got an error: %@", error);
    //        [wTools HideMBProgressHUD];
    //        return;
    //    } else {
    //        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //    }
    
    [self finishPurchase: str];
    
    //[wTools HideMBProgressHUD];
}

-(void)purchaseFailed:(NSString*)info{
    NSLog(@"Failed:%@",info);
    [self showCustomErrorAlert: @"交易失敗"];
}

-(void)StoreInfoError:(NSString*)info{
    NSLog(@"Error:%@",info);
    [self showCustomErrorAlert: @"交易失敗"];
}

//-(void)giveMeStoreList:(NSArray*)products; //商品列表 from apple
//商品資訊
-(void)giveMeItemInfo:(NSMutableDictionary*)products{
    NSLog(@"giveMeItemInfo");
    
    NSLog(@"商品詳細Info:%@", products);
    pointdata = [NSDictionary dictionaryWithDictionary:products];
    NSLog(@"pointdata: %@", pointdata);
    
    //_selectpointText.text = [NSString stringWithFormat:@"%@ P",listdata[0]];
    self.priceTitle = [NSString stringWithFormat:@"%@ P",listdata[0]];
    
    NSLog(@"datakey: %@", datakey);
    
    //_selectpriceText.text = [NSString stringWithFormat:@"%@",pointdata[datakey[0]]];
    //self.priceLabel.text = [NSString stringWithFormat:@"%@",pointdata[datakey[0]]];
    
    selectproductid = datakey[0];
    
    @try {
        [wTools HideMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
}

#pragma mark -
- (void)finishPurchase: (NSString *)str {
    NSLog(@"finishPurchase");
    //[wTools ShowMBProgressHUD];
    NSLog(@"after wTools ShowMBProgressHUD");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSString *response = [boxAPI finishpurchased: [wTools getUserID]
                                               token: [wTools getUserToken]
                                             orderid: orderid
                                       dataSignature: str];
        
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
                NSLog(@"response from finishpurchased");
                NSLog(@"response: %@", response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"BuyPPointViewController");
                    NSLog(@"finishPurchase");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"finishpurchased"
                                 selectProductId: @""
                                   dataSignature: str];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        pointstr = [dic[@"data"] stringValue];
                        NSLog(@"old pointstr: %@", pointstr);
                        
                        NSString *str = [NSString stringWithFormat: @"還有%@P點可使用", pointstr];
                        NSLog(@"str: %@", str);
                        self.userPointLabel.text = str;
                        
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setObject: [NSNumber numberWithInteger: [pointstr integerValue]] forKey: @"pPoint"];
                        
                        //_mypoint.text=pointstr;
                        
                        NSLog(@"Purchase is Successful");
                        // Check whether getting P-Point-Buying point or not
                        
                        BOOL firsttime_buy_point = [[defaults objectForKey: @"firsttime_buy_point"] boolValue];
                        NSLog(@"firsttime_buy_point: %d", (int)firsttime_buy_point);
                        
                        if (firsttime_buy_point) {
                            NSLog(@"Get the First Time Buying P Point Task Already");
                            [self pointsUPdate];
                        } else {
                            [self checkPoint];
                        }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Check Point Method

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
        
        NSString *response = [boxAPI doTask1: [wTools getUserID]
                                       token: [wTools getUserToken]
                                    task_for: @"firsttime_buy_point"
                                    platform: @"apple"];
        
        NSLog(@"User ID: %@", [wTools getUserID]);
        NSLog(@"Token: %@", [wTools getUserToken]);
        
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
                NSLog(@"response from doTask1");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"BuyPPointViewController");
                    NSLog(@"checkPoint");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"doTask1"
                                 selectProductId: @""
                                   dataSignature: @""];
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
                        [self showAlertView];
                        [self pointsUPdate];
                    } else if ([data[@"result"] intValue] == 2) {
                        NSLog(@"message: %@", data[@"message"]);
                        
                        // Save data for first collect album
                        BOOL firsttime_buy_point = YES;
                        
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setObject: [NSNumber numberWithBool: firsttime_buy_point]
                                     forKey: @"firsttime_buy_point"];
                        [defaults synchronize];
                    } else if ([data[@"result"] intValue] == 0) {
                        NSString *errorMessage = data[@"message"];
                        NSLog(@"error messsage: %@", errorMessage);
                    } else {
                        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}

#pragma mark - Custom AlertView for Getting Point
- (void)showAlertView
{
    NSLog(@"Show Alert View");
    
    // Custom AlertView shows up when getting the point
    alertTaskView = [[OldCustomAlertView alloc] init];
    [alertTaskView setContainerView: [self createPointView]];
    [alertTaskView setButtonTitles: [NSMutableArray arrayWithObject: @"確     認"]];
    [alertTaskView setUseMotionEffects: true];
    
    [alertTaskView show];
}

- (UIView *)createPointView
{
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
    [alertTaskView close];
    
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
    [alertTaskView show];
}

#pragma mark - Points Update
- (void)pointsUPdate {
    NSLog(@"pointsUPdate");
    
    // Call geturpoints for right value
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        pointstr = [boxAPI geturpoints: [userPrefs objectForKey: @"id"]
                                 token: [userPrefs objectForKey: @"token"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"pointstr: %@", pointstr);
            
            if (pointstr != nil) {
                if ([pointstr isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"BuyPPointViewController");
                    NSLog(@"pointsUpdate");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"pointsUPdate"
                                 selectProductId: @""
                                   dataSignature: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *pointDic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [pointstr dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    NSInteger point = [pointDic[@"data"] integerValue];
                    
                    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
                    [userPrefs setObject: [NSNumber numberWithInteger: point] forKey: @"pPoint"];
                    [userPrefs synchronize];
                    
                    pointstr = [NSString stringWithFormat: @"%ld", (long)point];
                    NSLog(@"new pointstr: %@", pointstr);
                    
                    //_mypoint.text=pointstr;
                    
                    NSString *str = [NSString stringWithFormat: @"還有%ldP點可使用", (long)point];
                    NSLog(@"str: %@", str);
                    self.userPointLabel.text = str;
                }
            }
        });
    });
}


#pragma mark - Custom Alert Method
- (void)showCustomAlert: (NSString *)msg productId: (NSString *)productId {
    NSLog(@"showCustomAlert productId: %@", productId);
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    //[alertView setContainerView: [self createContainerView: msg]];
    [alertView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertView.arrangeStyle = @"Horizontal";
    
    [alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"取消", @"確定", nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor clearColor], [UIColor clearColor],nil]];
    [alertView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
    [alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    
    __weak CustomIOSAlertView *weakAlertView = alertView;
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        
        [weakAlertView close];
        
        if (buttonIndex == 0) {
            
        } else {
            //[self changeFollowStatus: userId name: name];
            [self buyPoint: productId];
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

#pragma mark - Custom Error Alert Method
- (void)showCustomErrorAlert: (NSString *)msg
{
    CustomIOSAlertView *errorAlertView = [[CustomIOSAlertView alloc] init];
    //[errorAlertView setContainerView: [self createErrorContainerView: msg]];
    [errorAlertView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstPink] badgeName:nil];
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
               selectProductId: (NSString *)selectProductId
                 dataSignature: (NSString *)dataSignature
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
            if ([protocolName isEqualToString: @"getpointstore"]) {
                [weakSelf getPointStore];
            } else if ([protocolName isEqualToString: @"geturpoints"]) {
                [weakSelf getUrPoints];
            } else if ([protocolName isEqualToString: @"getpayload"]) {
                [weakSelf buyPoint: selectProductId];
            } else if ([protocolName isEqualToString: @"finishpurchased"]) {
                [wTools ShowMBProgressHUD];
                [weakSelf finishPurchase: dataSignature];
            } else if ([protocolName isEqualToString: @"doTask1"]) {
                [weakSelf checkPoint];
            } else if ([protocolName isEqualToString: @"pointsUPdate"]) {
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

- (BOOL)shouldAutorotate
{
    NSLog(@"shouldAutorotate");
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    NSLog(@"shouldAutorotateToInterfaceOrientation");
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    NSLog(@"supportedInterfaceOrientations");
    
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    NSLog(@"preferredInterfaceOrientationForPresentation");
    return UIInterfaceOrientationPortrait;
}

@end
