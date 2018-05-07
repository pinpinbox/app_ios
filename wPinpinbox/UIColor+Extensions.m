//
//  UIColor+Extensions.m
//  pinpinbox
//
//  Created by David on 3/31/17.
//  Copyright © 2017 vmage. All rights reserved.
//

#import "UIColor+Extensions.h"

@implementation UIColor (Extensions)

#pragma mark - Main Color
+ (UIColor *)darkMain
{
    return [UIColor colorWithRed: 15.0/255.0
                           green: 131.0/255.0
                            blue: 153.0/255.0
                           alpha: 0.95];
}

+ (UIColor *)firstMain
{
    return [UIColor colorWithRed: 0/255.0
                           green: 172.0/255.0
                            blue: 193.0/255.0
                           alpha: 0.95];
}

+ (UIColor *)secondMain
{
    return [UIColor colorWithRed: 105.0/255.0
                           green: 206.0/255.0
                            blue: 219.0/255.0
                           alpha: 0.95];
}

+ (UIColor *)thirdMain
{
    return [UIColor colorWithRed: 204.0/255.0
                           green: 225.0/255.0
                            blue: 228.0/255.0
                           alpha: 0.95];
}

#pragma mark - Pink Color
+ (UIColor *)darkPink
{
    return [UIColor colorWithRed: 173.0/255.0
                           green: 20.0/255.0
                            blue: 87.0/255.0
                           alpha: 0.95];
}

+ (UIColor *)firstPink
{
    return [UIColor colorWithRed: 233.0/255.0
                           green: 30.0/255.0
                            blue: 99.0/255.0
                           alpha: 0.95];
}

+ (UIColor *)secondPink
{
    return [UIColor colorWithRed: 242.0/255.0
                           green: 123.0/255.0
                            blue: 163.0/255.0
                           alpha: 0.95];
}

+ (UIColor *)thirdPink
{
    return [UIColor colorWithRed: 244.0/255.0
                           green: 173.0/255.0
                            blue: 197.0/255.0
                           alpha: 0.95];
}

#pragma mark - Grey Color
// Mainly use for text
+ (UIColor *)firstGrey
{
    return [UIColor colorWithRed: 77.0/255.0
                           green: 77.0/255.0
                            blue: 77.0/255.0
                           alpha: 1];
}

+ (UIColor *)secondGrey
{
    return [UIColor colorWithRed: 212.0/255.0
                           green: 212.0/255.0
                            blue: 212.0/255.0
                           alpha: 1];
}

+ (UIColor *)thirdGrey
{
    return [UIColor colorWithRed: 232.0/255.0
                           green: 232.0/255.0
                            blue: 232.0/255.0
                           alpha: 1];
}

+ (UIColor *)hintGrey
{
    return [UIColor colorWithRed: 158.0/255.0
                           green: 158.0/255.0
                            blue: 158.0/255.0
                           alpha: 1];
}

#pragma mark - Other Color
+ (UIColor *)barColor
{
    return [UIColor colorWithRed: 255.0/255.0
                           green: 255.0/255.0
                            blue: 255.0/255.0
                           alpha: 0.96];
}

+ (UIColor *)albumTypeBackground
{
    return [UIColor colorWithRed: 255.0/255.0
                           green: 255.0/255.0
                            blue: 255.0/255.0
                           alpha: 0.82];
}

+ (UIColor *)notifyAlbumBackground
{
    return [UIColor colorWithRed: 173.0/255.0
                           green: 20.0/255.0
                            blue: 87.0/255.0
                           alpha: 0.47];
}

+ (UIColor *)notifyCooperationBackground
{
    return [UIColor colorWithRed: 83.0/255.0
                           green: 79.0/255.0
                            blue: 14.0/255.0
                           alpha: 0.82];
}

+ (UIColor *)notifyUserInteractiveBackground
{
    return [UIColor colorWithRed: 63.0/255.0
                           green: 81.0/255.0
                            blue: 181.0/255.0
                           alpha: 0.82];
}

+ (UIColor *)FBGradientViewColor
{
    return [UIColor colorWithRed: 59.0/255.0
                           green: 89.0/255.0
                            blue: 152.0/255.0
                           alpha: 1.0];
}

@end
