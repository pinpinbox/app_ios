//
//  CategoryDetailCollectionViewCell.m
//  wPinpinbox
//
//  Created by David on 5/30/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "CategoryDetailCollectionViewCell.h"
#import "UIColor+Extensions.h"
#import "GlobalVars.h"

@implementation CategoryDetailCollectionViewCell
- (void)awakeFromNib
{
    NSLog(@"awakeFromNib");
    [super awakeFromNib];
    
    // Background View For Image
    self.imgBgView.backgroundColor = [UIColor firstGrey];        
    
    // CoverImage
    self.coverImageView.alpha = 0.95;
    self.coverImageView.layer.cornerRadius = kCornerRadius;
    self.coverImageView.layer.masksToBounds = YES;
    
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
    
    // Album
    self.albumNameLabel.textColor = [UIColor firstGrey];
    self.albumNameLabel.numberOfLines = 3;
}

@end

