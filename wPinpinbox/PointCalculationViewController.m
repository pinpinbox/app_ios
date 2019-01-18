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
#import "LabelAttributeStyle.h"

@interface PointCalculationViewController () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarHeight;
@property (weak, nonatomic) IBOutlet TouchDetectedScrollView *scrollView;
@property (weak, nonatomic) IBOutlet MyLinearLayout *vertLayout;

@property (weak, nonatomic) IBOutlet UILabel *pointCalculationTitleLabel;

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
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.delegate = self;
    
    [self initialValueSetup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    for (UIView *view in self.tabBarController.view.subviews) {
        UIButton *btn = (UIButton *)[view viewWithTag: 104];
        btn.hidden = YES;
    }
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
            case 1920:
                printf("iPhone 6+/6S+/7+/8+");
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
    
    self.pointCalculationTitleLabel.font = [UIFont boldSystemFontOfSize: 48.0];
    self.pointCalculationTitleLabel.textColor = [UIColor firstGrey];
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: self.pointCalculationTitleLabel content: self.pointCalculationTitleLabel.text];
    
    self.totalPointTitleLabel.font = [UIFont boldSystemFontOfSize: 18.0];
    self.totalPointTitleLabel.textColor = [UIColor firstGrey];
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: self.totalPointTitleLabel content: self.totalPointTitleLabel.text];
    
    self.monthPointTitleLabel.font = [UIFont boldSystemFontOfSize: 18.0];
    self.monthPointTitleLabel.textColor = [UIColor firstGrey];
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: self.monthPointTitleLabel content: self.monthPointTitleLabel.text];
    
    self.exchangeTitleLabel.font = [UIFont boldSystemFontOfSize: 18.0];
    self.exchangeTitleLabel.textColor = [UIColor firstGrey];
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: self.exchangeTitleLabel content: self.exchangeTitleLabel.text];
    
    // Total Point
    [self.totalPointTitleLabel sizeToFit];
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: self.totalPointTitleLabel content: self.totalPointTitleLabel.text];
    
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
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: self.totalPointNumberLabel content: self.totalPointNumberLabel.text];
    
    // Month Point
    [self.monthPointTitleLabel sizeToFit];
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: self.monthPointTitleLabel content: self.monthPointTitleLabel.text];
    
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
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: self.monthPointNumberLabel content: self.monthPointNumberLabel.text];
    [self.monthSubTitleLabel sizeToFit];
    
    // Exchange
    [self.exchangeTitleLabel sizeToFit];
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: self.exchangeTitleLabel content: self.exchangeTitleLabel.text];
    
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
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: self.exchangeNumberLabel content: self.exchangeNumberLabel.text];
    
    NSLog(@"self.identity: %@", self.identity);
    
    if ([wTools objectExists: self.identity]) {
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
