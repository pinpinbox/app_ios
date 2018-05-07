//
//  MessageTableViewCell.m
//  wPinpinbox
//
//  Created by David on 02/04/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "MessageTableViewCell.h"
#import "UIColor+Extensions.h"

@implementation MessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.subContentLayout.myRightMargin = 0;
    
    self.pictureImageView.layer.cornerRadius = self.pictureImageView.bounds.size.width / 2;
    
    self.nameLabel.textColor = [UIColor firstGrey];
    self.nameLabel.font = [UIFont boldSystemFontOfSize: 14];
    self.nameLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *nameLabelTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleTapFromLabel)];
    nameLabelTap.numberOfTapsRequired = 1;
    [self.nameLabel addGestureRecognizer: nameLabelTap];
    
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

- (void)handleTapFromLabel {
    NSLog(@"handleTapFromLabel");
    
    NSLog(@"self.userId: %@", self.userId);
    NSLog(@"self.userName: %@", self.userName);
    
    if (self.customBlock) {
        self.customBlock(self.userId, self.userName);
    }
}

@end
