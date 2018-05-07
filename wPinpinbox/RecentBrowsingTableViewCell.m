//
//  RecentBrowsingTableViewCell.m
//  wPinpinbox
//
//  Created by David on 5/23/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "RecentBrowsingTableViewCell.h"
#import "UIColor+Extensions.h"
#import "GlobalVars.h"

@implementation RecentBrowsingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.albumImageView.layer.cornerRadius = kCornerRadius;
    self.albumNameLabel.textColor = [UIColor firstGrey];
    self.albumNameLabel.font = [UIFont boldSystemFontOfSize: 18];
    self.creatorNameLabel.textColor = [UIColor secondGrey];
    self.creatorNameLabel.font = [UIFont systemFontOfSize: 12];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
