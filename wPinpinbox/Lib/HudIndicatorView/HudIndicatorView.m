//
//  HudIndicatorView.m
//  wPinpinbox
//
//  Created by Antelis on 2018/11/23.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "HudIndicatorView.h"

@interface HudIndicatorView()
@property(nonatomic) NSMutableDictionary *iconList;
@end
@implementation HudIndicatorView
- (void)addIconWithIdentifier:(UIImage *)icon identifier:(NSString *)identifier {
    if (!_iconList){
        _iconList = [[NSMutableDictionary alloc] init];
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = CGRectMake(0, 0, 126, 84);
        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor],
                           (id)[[UIColor clearColor] CGColor], nil];
        gradient.locations = @[[NSNumber numberWithFloat:0.8],[NSNumber numberWithFloat:1.0],] ;
        //gradient.opacity = 0.75;
        //[self.layer insertSublayer:gradient atIndex:0];
        self.layer.mask = gradient;
        
    }
    //self.backgroundColor = UIColor.yellowColor;
    UIImageView *ic = [[UIImageView alloc] initWithImage:icon];
    ic.frame = CGRectMake(28, 28, 28, 28);
    //ic.center = self.center;
    ic.layer.cornerRadius = 14;
    ic.clipsToBounds = YES;
    ic.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
    ic.layer.borderWidth = 0.5;
    
    [self addSubview:ic];
    [_iconList setObject:ic forKey:identifier];
    //[self refreshCircleLayout];
    [self refreshGridLayout];
    self.clipsToBounds = true;
}
- (void)removeIconWithIdentifier:(NSString *)identifier {
    UIView *icon = (UIView *)[_iconList objectForKey:identifier];
    [icon removeFromSuperview];
    [_iconList removeObjectForKey:identifier];
    //[self refreshCircleLayout];
    [self refreshGridLayout];
}
- (void)refreshGridLayout {
//    int i = 0;
//    for (UIView *icon in self.iconList.allValues) {
//        icon.frame = CGRectMake(0, 0, 28, 28);
//        i++;
//    }
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1.0
          initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
              int t = 0;
              for (UIView *icon in self.iconList.allValues) {
                  icon.center = CGPointMake((t%4)*29+14,(t/4)*29+14);
                  t++;
              }
          } completion:nil];
    
}
- (void)refreshCircleLayout {
    
    if (_iconList.count > 1) {
        double step = 2*(M_PI/(double)_iconList.count);
        
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1.0
              initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                  int t = 0;
                  for (UIView *icon in self.iconList.allValues) {
                      double dx = cos(step*t);
                      double dy = sin(step*t);
                      icon.transform = CGAffineTransformMakeTranslation(28*dx, 28*dy);
                      t++;
                  }
              } completion:nil];
        
    } else {
        for (UIView *icon in self.iconList.allValues) {
            icon.transform = CGAffineTransformIdentity;
        }
    }
}
- (CGSize) intrinsicContentSize {
    
    return CGSizeMake(116,84);
}

@end
