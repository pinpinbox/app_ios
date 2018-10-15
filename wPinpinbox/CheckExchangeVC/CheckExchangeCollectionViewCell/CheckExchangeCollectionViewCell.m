//
//  CheckExchangeCollectionViewCell.m
//  wPinpinbox
//
//  Created by David on 08/03/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "CheckExchangeCollectionViewCell.h"
#import "UIColor+Extensions.h"
#import "GlobalVars.h"

@implementation CheckExchangeCollectionViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    self.imageView.alpha = 0.95;
    self.imageView.layer.cornerRadius = kCornerRadius;
    self.imageView.layer.masksToBounds = YES;
    
    self.nameLabel.textColor = [UIColor firstGrey];
    self.nameLabel.font = [UIFont boldSystemFontOfSize: 14.0];
    
    self.timeLabel.font = [UIFont boldSystemFontOfSize: 14.0];
    self.timeLabel.textColor = [UIColor firstPink];
}
@end
