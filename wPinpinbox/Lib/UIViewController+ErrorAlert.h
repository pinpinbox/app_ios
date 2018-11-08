//
//  UIViewController+ErrorAlert.h
//  wPinpinbox
//
//  Created by appbuilder on 2018/9/7.
//  Copyright © 2018年 Angus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CustomIOSAlertView;

@interface UIViewController (ErrorAlert)
//  return a simple error alert with one close button (firstPink)
//  msg can not be null
+ (CustomIOSAlertView * _Nullable)getCustomErrorAlert: (NSString * _Nonnull)msg;
//  show a simple error alert with one close button (firstPink) and button-touchup block
//  msg and  onButtonTouchUpBlock can not be null
+ (void)showCustomErrorAlertWithMessage:(NSString * _Nonnull)msg onButtonTouchUpBlock:(void(^ _Nonnull)(CustomIOSAlertView * _Nonnull customAlertView , int buttonIndex))onButtonTouchUpBlock;
@end
