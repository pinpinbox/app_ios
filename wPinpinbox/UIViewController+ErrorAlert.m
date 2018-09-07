//
//  UIViewController+ErrorAlert.m
//  wPinpinbox
//
//  Created by appbuilder on 2018/9/7.
//  Copyright © 2018年 Angus. All rights reserved.
//

#import "UIViewController+ErrorAlert.h"
#import "CustomIOSAlertView.h"
#import "UIColor+Extensions.h"

@implementation UIViewController(ErrorAlert)
//  return a simple error alert with one close button (firstPink)
+ (CustomIOSAlertView * _Nullable)getCustomErrorAlert: (NSString * _Nonnull)msg {
    CustomIOSAlertView *errorAlertView = [[CustomIOSAlertView alloc] init];
    //[errorAlertView setContainerView: [self createErrorContainerView: msg]];
    [errorAlertView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstPink] badgeName:nil];
    [errorAlertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    [errorAlertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    [errorAlertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondPink]]];
    errorAlertView.arrangeStyle = @"Horizontal";
    
    [errorAlertView setUseMotionEffects:YES];
    
    return errorAlertView;
}
//  show a simple error alert with one close button (firstPink) and button-touchup block
+ (void)showCustomErrorAlertWithMessage:(NSString * _Nonnull)msg onButtonTouchUpBlock:(void(^ _Nonnull)(CustomIOSAlertView * _Nonnull customAlertView , int buttonIndex))onButtonTouchUpBlock {
    
    CustomIOSAlertView *errorAlertView = [UIViewController getCustomErrorAlert:msg];
    
    [errorAlertView setOnButtonTouchUpInside:onButtonTouchUpBlock];
    
    [errorAlertView show];
}
@end
