//
//  MeCollectionReusableView.m
//  wPinpinbox
//
//  Created by David on 5/8/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "MeCollectionReusableView.h"
#import "UIColor+Extensions.h"
#import "GlobalVars.h"

@implementation MeCollectionReusableView
- (void)awakeFromNib {
    [super awakeFromNib];
    NSLog(@"MeCollectionReusableView");
    NSLog(@"awakeFromNib");
    
    self.changeBannerBtn.hidden = NO;
    self.changeBannerBtn.layer.cornerRadius = kCornerRadius;
    self.changeBannerBtn.layer.masksToBounds = YES;
    [self.changeBannerBtn setTitleColor: [UIColor firstGrey] forState: UIControlStateNormal];
    self.changeBannerBtn.backgroundColor = [UIColor thirdGrey];
    
    self.userPictureImageView.layer.cornerRadius = self.userPictureImageView.bounds.size.height / 2;
    self.userPictureImageView.layer.masksToBounds = YES;
    self.userPictureImageView.layer.borderColor = [UIColor thirdGrey].CGColor;
    self.userPictureImageView.layer.borderWidth = 0.5;
    
    self.userNameLabel.textColor = [UIColor firstGrey];
    self.userNameLabel.font = [UIFont boldSystemFontOfSize: 18];
    
    self.creativeNameLabel.textColor = [UIColor whiteColor];
    self.creativeNameLabel.font = [UIFont boldSystemFontOfSize: 24.0];
    self.creativeNameLabel.numberOfLines = 2;
    
    self.viewedNumberLabel.textColor = [UIColor firstGrey];
    self.likeNumberLabel.textColor = [UIColor firstGrey];
    self.sponsoredNumberLabel.textColor = [UIColor firstGrey];
    
    self.viewedLabel.textColor = [UIColor firstGrey];
    self.likeLabel.textColor = [UIColor firstGrey];
    self.sponsoredLabel.textColor = [UIColor firstGrey];
    
    UITapGestureRecognizer *followTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleTapFromStackView:)];
    [self.followStackView addGestureRecognizer: followTap];
    
    UITapGestureRecognizer *sponsorTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleTapFromStackView:)];
    [self.sponsorStackView addGestureRecognizer: sponsorTap];
    
    self.linkLabel.font = [UIFont systemFontOfSize: 18];
    self.linkLabel.textColor = [UIColor secondGrey];
    
    self.horzLineView.backgroundColor = [UIColor thirdGrey];
    self.albumCollectionLabel.textColor = [UIColor firstGrey];
}

- (void)handleTapFromStackView:(UITapGestureRecognizer *)gestureRecognizer {
    NSLog(@"handleTapFromStackView");
    if (self.customBlock) {
//        self.customBlock(YES);
        self.customBlock(YES, gestureRecognizer.view.tag);
        NSLog(@"gestureRecognizer.view.tag: %ld", gestureRecognizer.view.tag);
    }
}

@end
