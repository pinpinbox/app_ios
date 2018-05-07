//
//  ChooseHobbyCollectionViewCell.m
//  wPinpinbox
//
//  Created by David on 5/15/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "ChooseHobbyCollectionViewCell.h"
#import "UIColor+Extensions.h"
#import "GlobalVars.h"

@implementation ChooseHobbyCollectionViewCell
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.hobbyBgView.layer.cornerRadius = kCornerRadius;
    self.hobbyBgView.clipsToBounds = YES;
    
    self.hobbyImageView.layer.cornerRadius = kCornerRadius;
    self.hobbyImageView.clipsToBounds = YES;
    
    self.hobbyLabel.font = [UIFont systemFontOfSize: 16.0];
    self.hobbyLabel.textColor = [UIColor firstGrey];
}
@end
