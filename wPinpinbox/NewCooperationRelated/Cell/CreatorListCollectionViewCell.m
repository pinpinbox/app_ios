//
//  CreatorListCollectionViewCell.m
//  wPinpinbox
//
//  Created by David on 2018/9/26.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "CreatorListCollectionViewCell.h"
#import "UIColor+Extensions.h"
#import "GlobalVars.h"

@implementation CreatorListCollectionViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.userPictureImageView.layer.cornerRadius = self.userPictureImageView.bounds.size.width / 2;
    self.userPictureImageView.clipsToBounds = YES;
    self.userPictureImageView.layer.borderColor = [UIColor thirdGrey].CGColor;
    self.userPictureImageView.layer.borderWidth = 0.5;
    
    self.userNameLabel.font = [UIFont systemFontOfSize: 12.0];
    self.userNameLabel.textColor = [UIColor firstGrey];
    
    self.inviteBtn.backgroundColor = [UIColor firstMain];
    self.inviteBtn.layer.cornerRadius = kCornerRadius;
    [self.inviteBtn setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    self.inviteBtn.titleLabel.font = [UIFont boldSystemFontOfSize: 12.0];
}

- (void)setInviteBtnEnabled:(BOOL)e {
    if (e) {
        self.inviteBtn.enabled = YES;
        self.inviteBtn.layer.borderWidth = 0;
        self.inviteBtn.backgroundColor = [UIColor firstMain];
        [self.inviteBtn setTitle: @"邀請" forState: UIControlStateNormal];
        [self.inviteBtn setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    } else {
        self.inviteBtn.enabled = NO;
        self.inviteBtn.layer.borderWidth = 1;
        self.inviteBtn.layer.borderColor = [UIColor thirdGrey].CGColor;
        self.inviteBtn.backgroundColor = [UIColor whiteColor];
        [self.inviteBtn setTitle: @"已邀請" forState: UIControlStateNormal];
        [self.inviteBtn setTitleColor: [UIColor thirdGrey] forState: UIControlStateNormal];
    }
}

@end
