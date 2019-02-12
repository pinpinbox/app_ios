//
//  DGHUDView.m
//  wPinpinbox
//
//  Created by David on 2019/2/1.
//  Copyright © 2019 Angus. All rights reserved.
//

#import "DGHUDView.h"
#import "UIColor+Extensions.h"
#import "AppDelegate.h"

@implementation DGHUDView

+ (DGHUDView *)sharedView {
    static DGHUDView *sharedView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedView = [[self alloc] initWithType: DGActivityIndicatorAnimationTypeDoubleBounce tintColor: [UIColor secondMain] size: 56.0f];
        sharedView.frame = CGRectMake(0.0f, 0.0f, 50.0f, 50.0f);
        sharedView.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 2);
        [[UIApplication sharedApplication].delegate.window addSubview: sharedView];
    });
    return sharedView;
}

+ (void)start {
    [[self sharedView] startAnimating];
    [UIView animateWithDuration: 0.1 delay: 1.0 options: UIViewAnimationOptionCurveLinear animations:^{
        [self sharedView].alpha = 0;
        [self sharedView].alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    
    UIView *view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    view.accessibilityIdentifier = @"HUDTransparentView";
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window addSubview: view];
}

+ (void)stop {
    if ([self sharedView]) {
        [[self sharedView] stopAnimating];
        [[self sharedView].layer removeAllAnimations];
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    for (UIView *view in appDelegate.window.subviews) {
        if ([view.accessibilityIdentifier isEqualToString: @"HUDTransparentView"]) {
            [view removeFromSuperview];
        }
    }
}

+ (BOOL)isAnimating {
    return [self sharedView].animating;
}

@end
