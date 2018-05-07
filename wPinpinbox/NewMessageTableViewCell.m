//
//  NewMessageTableViewCell.m
//  wPinpinbox
//
//  Created by David on 6/10/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "NewMessageTableViewCell.h"
#import "UIColor+Extensions.h"

@implementation NewMessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    self.bgContentLayout.backgroundColor = [UIColor greenColor];
//    self.subContentLayout.backgroundColor = [UIColor blueColor];
    self.subContentLayout.myRightMargin = 0;
    
    self.pictureImageView.layer.cornerRadius = self.pictureImageView.bounds.size.width / 2;
    self.nameLabel.textColor = [UIColor firstMain];
    self.nameLabel.font = [UIFont systemFontOfSize: 14];
    
    self.contentLabel.textColor = [UIColor firstGrey];
    self.contentLabel.font = [UIFont systemFontOfSize: 14];
    
    self.insertTimeLabel.textColor = [UIColor secondGrey];
    self.insertTimeLabel.font = [UIFont systemFontOfSize: 14];
    
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    //self.contentView.wrapContentHeight = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
