//
//  FollowFromListTableViewCell.m
//  wPinpinbox
//
//  Created by David on 07/05/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "FollowFromListTableViewCell.h"
#import "UIColor+Extensions.h"
#import "GlobalVars.h"

@implementation FollowFromListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.userNameLabel.textColor = [UIColor firstGrey];
    self.userNameLabel.font = [UIFont systemFontOfSize: 16.0];        
    
    self.messageBtn.layer.cornerRadius = kCornerRadius;
    self.messageBtn.backgroundColor = [UIColor thirdGrey];
    [self.messageBtn setTitleColor: [UIColor firstGrey] forState: UIControlStateNormal];
    self.messageBtn.titleLabel.font = [UIFont boldSystemFontOfSize: 16.0];
    [self.messageBtn addTarget: self action: @selector(showMessageBoard:) forControlEvents: UIControlEventTouchUpInside];
    
    self.followBtn.layer.cornerRadius = kCornerRadius;
    self.followBtn.titleLabel.font = [UIFont boldSystemFontOfSize: 16.0];
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
