//
//  HomeCategoryCollectionViewCell.m
//  wPinpinbox
//
//  Created by David on 12/01/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "HomeCategoryCollectionViewCell.h"
#import "GlobalVars.h"
#import "UIColor+HexString.h"

@implementation HomeCategoryCollectionViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    NSLog(@"awakeFromNib");
    
    self.categoryBgView.backgroundColor = [UIColor clearColor];
    self.categoryBgView.layer.shadowRadius = 12;
    self.categoryBgView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.categoryBgView.layer.shadowOpacity = 0.2;
    //self.categoryBgView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) cornerRadius:5].CGPath;
    self.categoryBgView.layer.shadowOffset = CGSizeMake(2, 2);
    
//    self.categoryBgView.layer.cornerRadius = kCornerRadius;
//    self.categoryBgView.layer.masksToBounds = YES;
    
//    self.categoryImageView.layer.cornerRadius = kCornerRadius;
    
//    self.categoryGradientView.layer.cornerRadius = kCornerRadius;
    
//    CAGradientLayer *gradientLayer;
//    gradientLayer = [CAGradientLayer layer];
//    gradientLayer.frame = CGRectMake(0, 0, self.categoryGradientView.bounds.size.width, self.categoryGradientView.frame.size.height);
//    gradientLayer.colors = @[(id)[UIColor colorFromHexString: @"#E6000000"].CGColor, (id)[UIColor colorFromHexString: @"#000000"].CGColor];
//    [self.categoryGradientView.layer insertSublayer: gradientLayer atIndex: 0];
//    self.categoryGradientView.alpha = 0.4;
}
@end
