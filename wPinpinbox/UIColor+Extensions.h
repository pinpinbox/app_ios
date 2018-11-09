//
//  UIColor+Extensions.h
//  pinpinbox
//
//  Created by David on 3/31/17.
//  Copyright © 2017 vmage. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Extensions)
#pragma mark - Main Color
+ (UIColor *)darkMain;
+ (UIColor *)firstMain;
+ (UIColor *)secondMain;
+ (UIColor *)thirdMain;

#pragma mark - Pink Color
+ (UIColor *)darkPink;
+ (UIColor *)firstPink;
+ (UIColor *)secondPink;
+ (UIColor *)thirdPink;

#pragma mark - Grey Color
// Mainly use for text
+ (UIColor *)firstGrey;
+ (UIColor *)secondGrey;
+ (UIColor *)thirdGrey;
+ (UIColor *)hintGrey;

#pragma mark - Other Color
+ (UIColor *)barColor;
+ (UIColor *)albumTypeBackground;
+ (UIColor *)notifyAlbumBackground;
+ (UIColor *)notifyCooperationBackground;
+ (UIColor *)notifyUserInteractiveBackground;
+ (UIColor *)FBGradientViewColor;

@end
