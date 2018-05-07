//
//  PointCalculationViewController.m
//  wPinpinbox
//
//  Created by David on 2017/11/6.
//  Copyright © 2017年 Angus. All rights reserved.
//

#import "PointCalculationViewController.h"
#import "boxAPI.h"
#import "wTools.h"
#import "GlobalVars.h"
#import "UIColor+Extensions.h"
#import "TouchDetectedScrollView.h"
#import "MyLinearLayout.h"
#import "AppDelegate.h"

@interface PointCalculationViewController ()
@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarHeight;
@property (weak, nonatomic) IBOutlet TouchDetectedScrollView *scrollView;
@property (weak, nonatomic) IBOutlet MyLinearLayout *vertLayout;

@property (weak, nonatomic) IBOutlet UILabel *totalPointTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalPointNumberLabel;

@property (weak, nonatomic) IBOutlet UILabel *monthPointTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthPointNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthSubTitleLabel;

@property (weak, nonatomic) IBOutlet UIView *exchangeHorizontalView;
@property (weak, nonatomic) IBOutlet UILabel *exchangeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *exchangeNumberLabel;

@end

@implementation PointCalculationViewController
- (IBAction)backBtnPress:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.myNav popViewControllerAnimated: YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"PointCalculationViewController viewDidLoad");
    [self initialValueSetup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    for (UIView *view in self.tabBarController.view.subviews) {
        UIButton *btn = (UIButton *)[view viewWithTag: 104];
        btn.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialValueSetup {
    NSLog(@"initialValueSetup");
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                self.navBarHeight.constant = 48;
                break;
            case 1334:
                printf("iPhone 6/6S/7/8");
                self.navBarHeight.constant = 48;
                break;
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                self.navBarHeight.constant = 48;
                break;
            case 2436:
                printf("iPhone X");
                self.navBarHeight.constant = navBarHeightConstant;
                break;
            default:
                printf("unknown");
                self.navBarHeight.constant = 48;                
                break;
        }
    }
    
    self.navBarView.backgroundColor = [UIColor barColor];
    
    // Total Point
    [self.totalPointTitleLabel sizeToFit];
    
    if (self.sum >= 10000000) {
        NSLog(@"self.sum >= 10000000");
        self.sum = self.sum / 1000000;
        self.totalPointNumberLabel.text = [NSString stringWithFormat: @"%ldM", (long)self.sum];
    } else if (self.sum >= 10000) {
        NSLog(@"self.sum >= 10000");
        self.sum = self.sum/ 1000;
        self.totalPointNumberLabel.text = [NSString stringWithFormat: @"%ldK", (long)self.sum];
    } else {
        NSLog(@"else");
        self.totalPointNumberLabel.text = [NSString stringWithFormat: @"%ld", (long)self.sum];
        NSLog(@"self.totalPointNumberLabel.text: %@", self.totalPointNumberLabel.text);
    }
    [self.totalPointNumberLabel sizeToFit];
    
    // Month Point
    [self.monthPointTitleLabel sizeToFit];
    
    if (self.sumOfUnsettlement >= 10000000) {
        NSLog(@"self.sum >= 10000000");
        self.sumOfUnsettlement = self.sumOfUnsettlement / 1000000;
        self.monthPointNumberLabel.text = [NSString stringWithFormat: @"%ldM", (long)self.sumOfUnsettlement];
    } else if (self.sumOfUnsettlement >= 10000) {
        NSLog(@"self.sum >= 10000");
        self.sumOfUnsettlement = self.sumOfUnsettlement/ 1000;
        self.monthPointNumberLabel.text = [NSString stringWithFormat: @"%ldK", (long)self.sumOfUnsettlement];
    } else {
        NSLog(@"else");
        self.monthPointNumberLabel.text = [NSString stringWithFormat: @"%ld", (long)self.sumOfUnsettlement];
        NSLog(@"self.monthPointNumberLabel.text: %@", self.monthPointNumberLabel.text);
    }
    [self.monthPointNumberLabel sizeToFit];
    [self.monthSubTitleLabel sizeToFit];
    
    // Exchange
    [self.exchangeTitleLabel sizeToFit];
    
    if (self.sumOfSettlement >= 10000000) {
        NSLog(@"self.sum >= 10000000");
        self.sumOfSettlement = self.sumOfSettlement / 1000000;
        self.exchangeNumberLabel.text = [NSString stringWithFormat: @"%ldM", (long)self.sumOfSettlement];
    } else if (self.sumOfSettlement >= 10000) {
        NSLog(@"self.sum >= 10000");
        self.sumOfSettlement = self.sumOfSettlement/ 1000;
        self.monthPointNumberLabel.text = [NSString stringWithFormat: @"%ldK", (long)self.sumOfSettlement];
    } else {
        NSLog(@"else");
        self.exchangeNumberLabel.text = [NSString stringWithFormat: @"%ld", (long)self.sumOfSettlement];
        NSLog(@"self.exchangeNumberLabel.text: %@", self.exchangeNumberLabel.text);
    }
    [self.exchangeNumberLabel sizeToFit];
    
    NSLog(@"self.identity: %@", self.identity);
    
    if ([self.identity isEqualToString: @"company_downline"]) {
        self.exchangeHorizontalView.hidden = YES;
        self.exchangeTitleLabel.hidden = YES;
        self.exchangeNumberLabel.hidden = YES;
    } else {
        self.exchangeHorizontalView.hidden = NO;
        self.exchangeTitleLabel.hidden = NO;
        self.exchangeNumberLabel.hidden = NO;
    }
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
