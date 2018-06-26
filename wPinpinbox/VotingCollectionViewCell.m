//
//  VotingCollectionViewCell.m
//  wPinpinbox
//
//  Created by David on 2017/10/31.
//  Copyright © 2017年 Angus. All rights reserved.
//

#import "VotingCollectionViewCell.h"
#import "UIColor+Extensions.h"
#import "GlobalVars.h"

@implementation VotingCollectionViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    NSLog(@"awakeFromNib");
    
    //self.bgLayout.wrapContentHeight = YES;
    self.bgLayout.layer.cornerRadius = 16;
    
    // CoverBG
    //self.coverBgView.wrapContentHeight = YES;
    //self.coverBgView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.coverBgView.heightDime.min(kMinWidthAndHeight);
    
    // CoverImage
    self.coverImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    //self.coverImageView.wrapContentHeight = YES;
    self.coverImageView.backgroundColor = [UIColor thirdGrey];
    self.coverImageView.alpha = 0.95;
    self.coverImageView.layer.cornerRadius = kCornerRadius;
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverImageView.heightDime.min(kMinWidthAndHeight);
    
    
    // UserInfoView Setting
    self.userInfoView.wrapContentWidth = YES;
    self.userInfoView.gravity = MyMarginGravity_Horz_Right;
    self.userInfoView.myRightMargin = 8;
    self.userInfoView.myBottomMargin = 8;
    self.userInfoView.layer.cornerRadius = kCornerRadius;
    
    self.btn1.tintColor = [UIColor blackColor];
    self.btn2.tintColor = [UIColor blackColor];
    self.btn3.tintColor = [UIColor blackColor];
    
    self.btn1.imageEdgeInsets = UIEdgeInsetsMake(kBtnInset, kBtnInset, kBtnInset, kBtnInset);
    self.btn2.imageEdgeInsets = UIEdgeInsetsMake(kBtnInset, kBtnInset, kBtnInset, kBtnInset);
    self.btn3.imageEdgeInsets = UIEdgeInsetsMake(kBtnInset, kBtnInset, kBtnInset, kBtnInset);
    
    self.btn1.userInteractionEnabled = NO;
    self.btn2.userInteractionEnabled = NO;
    self.btn3.userInteractionEnabled = NO;
    
    self.votedLabel.layer.cornerRadius = kCornerRadius;
    self.votedLabel.myCenterYOffset = 0;
    self.rankLabel.backgroundColor = [UIColor firstPink];
    self.rankLabel.transform = CGAffineTransformMakeRotation(-M_PI / 4);
    
    // Album Related Info
    self.albumNameLabel.textColor = [UIColor firstGrey];
    self.albumNameLabel.font = [UIFont boldSystemFontOfSize: 14];
    self.albumNameLabel.numberOfLines = 1;
    
    self.albumIdLabel.textColor = [UIColor firstGrey];
    self.albumIdLabel.font = [UIFont systemFontOfSize: 12];
    self.albumIdLabel.numberOfLines = 1;
    
    self.eventJoinLabel.textColor = [UIColor firstGrey];
    self.eventJoinLabel.font = [UIFont systemFontOfSize: 12];
    self.eventJoinLabel.numberOfLines = 1;
    
    self.voteBtn.layer.cornerRadius = kCornerRadius;
    self.voteBtn.backgroundColor = [UIColor firstMain];
    
    self.userView.layer.cornerRadius = kCornerRadius;
    self.userView.backgroundColor = [UIColor clearColor];
    
    self.userPictureImageView.layer.cornerRadius = self.userPictureImageView.bounds.size.width / 2;
    self.userNameLabel.textColor = [UIColor firstGrey];
    self.userNameLabel.font = [UIFont systemFontOfSize: 14];
    self.userNameLabel.numberOfLines = 1;
    
    [self.userBtn addTarget: self action: @selector(userTouchHighlight:) forControlEvents: UIControlEventTouchDown];
    [self.userBtn addTarget: self action: @selector(userTouchNormal:) forControlEvents: UIControlEventTouchUpInside];
    [self.userBtn addTarget: self action: @selector(userTouchNormal:) forControlEvents: UIControlEventTouchUpOutside];
}

- (IBAction)userBtnPress:(id)sender {
    NSLog(@"userBtnPress");
    
    if (self.userBtnBlock) {
        self.userBtnBlock(self.userBtn.selected, self.userId, self.albumId);
    }
    //self.userView.backgroundColor = [UIColor thirdMain];
}

- (void)userTouchHighlight:(UIButton *)sender {
    NSLog(@"beginUserTouch");
    self.userView.backgroundColor = [UIColor thirdMain];
}

- (void)userTouchNormal:(UIButton *)sender {
    NSLog(@"endUserTouch");
    self.userView.backgroundColor = [UIColor clearColor];
}

- (IBAction)voteBtnPress:(id)sender {
    NSLog(@"voteBtnPress");
    
    if (self.voteBtnBlock) {
        self.voteBtnBlock(self.voteBtn.selected, self.userId, self.albumId);
    }
}

@end
