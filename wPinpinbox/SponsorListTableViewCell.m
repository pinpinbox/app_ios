//
//  SponsorListTableViewCell.m
//  wPinpinbox
//
//  Created by David on 23/04/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "SponsorListTableViewCell.h"
#import "UIColor+Extensions.h"
#import "GlobalVars.h"
#import "LabelAttributeStyle.h"

@implementation SponsorListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.headshotImageView.layer.cornerRadius = self.headshotImageView.bounds.size.width / 2;
    self.headshotImageView.clipsToBounds = YES;
    self.headshotImageView.layer.borderColor = [UIColor thirdGrey].CGColor;
    self.headshotImageView.layer.borderWidth = 0.5;
    
    self.userNameLabel.textColor = [UIColor firstGrey];
    self.userNameLabel.font = [UIFont systemFontOfSize: 16.0];    
    
    self.pPointLabel.textColor = [UIColor firstGrey];
    self.pPointLabel.font = [UIFont boldSystemFontOfSize: 16.0];
    
    self.messageBtn.layer.cornerRadius = kCornerRadius;
    self.messageBtn.backgroundColor = [UIColor thirdGrey];
    [self.messageBtn setTitleColor: [UIColor firstGrey] forState: UIControlStateNormal];
    self.messageBtn.titleLabel.font = [UIFont systemFontOfSize: 16.0];
    [LabelAttributeStyle changeGapStringAndLineSpacingCenterAlignment: self.messageBtn.titleLabel content: self.messageBtn.titleLabel.text];
    [self.messageBtn addTarget: self action: @selector(showMessageBoard:) forControlEvents: UIControlEventTouchUpInside];
        
    self.followBtn.layer.cornerRadius = kCornerRadius;
    self.followBtn.titleLabel.font = [UIFont systemFontOfSize: 16.0];
    [LabelAttributeStyle changeGapStringAndLineSpacingCenterAlignment: self.followBtn.titleLabel content: self.followBtn.titleLabel.text];
    [self.followBtn addTarget: self action: @selector(callFollowAPI:) forControlEvents: UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)showMessageBoard:(UIButton *)sender {
    NSLog(@"showMessageBoard");
    if (self.customBlock) {
        self.customBlock(sender.selected, sender.tag);
    }
}

- (void)callFollowAPI:(UIButton *)sender {
    NSLog(@"callFollowAPI");
    if (self.customBlock) {
        self.customBlock(sender.selected, sender.tag);
    }
}

@end
