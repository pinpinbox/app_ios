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
    self.categoryBgView.layer.cornerRadius = kCornerRadius;
    self.categoryBgView.layer.masksToBounds = YES;
    
    self.categoryImageView.layer.cornerRadius = kCornerRadius;
    
    self.categoryGradientView.layer.cornerRadius = kCornerRadius;
    
    CAGradientLayer *gradientLayer;
    gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, self.categoryGradientView.bounds.size.width, self.categoryGradientView.frame.size.height);
    gradientLayer.colors = @[(id)[UIColor colorFromHexString: @"#E6000000"].CGColor, (id)[UIColor colorFromHexString: @"#000000"].CGColor];
    [self.categoryGradientView.layer insertSublayer: gradientLayer atIndex: 0];
    self.categoryGradientView.alpha = 0.4;
}
@end
