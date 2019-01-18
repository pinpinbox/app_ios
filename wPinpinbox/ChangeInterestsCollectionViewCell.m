//
//  ChangeInterestsCollectionViewCell.m
//  wPinpinbox
//
//  Created by David on 05/02/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "ChangeInterestsCollectionViewCell.h"
#import "UIColor+Extensions.h"
#import "GlobalVars.h"

@implementation ChangeInterestsCollectionViewCell
- (void)awakeFromNib {
    [super awakeFromNib];    
    self.hobbyBgView.layer.cornerRadius = kCornerRadius;
    self.hobbyBgView.clipsToBounds = YES;
    
    self.hobbyImageView.layer.cornerRadius = kCornerRadius;
    self.hobbyImageView.clipsToBounds = YES;
    
    self.hobbyLabel.font = [UIFont systemFontOfSize: 16.0];
    self.hobbyLabel.textColor = [UIColor firstGrey];
}

@end
