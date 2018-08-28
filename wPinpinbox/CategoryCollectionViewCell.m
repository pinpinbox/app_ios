//
//  CategoryCollectionViewCell.m
//  wPinpinbox
//
//  Created by David on 17/01/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "CategoryCollectionViewCell.h"
#import "GlobalVars.h"

@implementation CategoryCollectionViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    self.albumImageView.layer.cornerRadius = kCornerRadius;
    self.albumImageView.layer.masksToBounds = YES;    
    self.albumNameLabel.font = [UIFont boldSystemFontOfSize: 12];
    
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
}
@end
