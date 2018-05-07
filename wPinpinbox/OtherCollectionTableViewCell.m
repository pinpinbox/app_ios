//
//  OtherCollectionTableViewCell.m
//  wPinpinbox
//
//  Created by David on 6/18/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "OtherCollectionTableViewCell.h"
#import "UIColor+Extensions.h"
#import "GlobalVars.h"

@implementation OtherCollectionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.albumImageView.layer.cornerRadius = kCornerRadius;
    self.albumNameLabel.textColor = [UIColor firstGrey];
    self.albumNameLabel.font = [UIFont boldSystemFontOfSize: 16];
    self.timeLabel.textColor = [UIColor secondGrey];
    
    self.userImageView.layer.cornerRadius = self.userImageView.bounds.size.width / 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
