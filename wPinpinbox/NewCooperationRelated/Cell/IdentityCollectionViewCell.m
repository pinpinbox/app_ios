//
//  IdentityCollectionViewCell.m
//  wPinpinbox
//
//  Created by David on 2018/9/26.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "IdentityCollectionViewCell.h"
#import "UIColor+Extensions.h"
#import "UIColor+HexString.h"
#import "GlobalVars.h"

@implementation IdentityCollectionViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.userPictureImageView.layer.cornerRadius = self.userPictureImageView.bounds.size.width / 2;
    self.userPictureImageView.clipsToBounds = YES;
    self.userPictureImageView.layer.borderColor = [UIColor thirdGrey].CGColor;
    self.userPictureImageView.layer.borderWidth = 0.5;
    
    self.userNameLabel.font = [UIFont systemFontOfSize: 12.0];
    self.userNameLabel.textColor = [UIColor firstGrey];
    
    self.userIdentityChangeBtn.layer.cornerRadius = kCornerRadius;
    self.userIdentityChangeBtn.titleLabel.font = [UIFont systemFontOfSize: 12.0];
    
    self.deleteIdentityBtn.backgroundColor = [UIColor colorFromHexString: @"F4ADC5"];
    self.deleteIdentityBtn.layer.cornerRadius = self.deleteIdentityBtn.bounds.size.width / 2;
    self.deleteIdentityBtn.alpha = 0.8;
}

@end
