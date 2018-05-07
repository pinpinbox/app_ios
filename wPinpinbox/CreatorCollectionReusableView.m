//
//  CreatorCollectionReusableView.m
//  wPinpinbox
//
//  Created by David on 5/3/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "CreatorCollectionReusableView.h"
#import "UIColor+Extensions.h"

@implementation CreatorCollectionReusableView
- (void)awakeFromNib
{
    [super awakeFromNib];
    NSLog(@"CreatorCollectionReusableView");
    NSLog(@"awakeFromNib");
    
    self.userPictureImageView.layer.cornerRadius = self.userPictureImageView.bounds.size.height / 2;
    self.userPictureImageView.layer.masksToBounds = YES;
    
    self.userNameLabel.textColor = [UIColor firstGrey];
    self.userNameLabel.font = [UIFont boldSystemFontOfSize: 18];
    
    self.creativeNameLabel.textColor = [UIColor firstGrey];
    self.creativeNameLabel.font = [UIFont boldSystemFontOfSize: 28];
    self.creativeNameLabel.numberOfLines = 0;
    
    self.viewedNumberLabel.textColor = [UIColor firstGrey];
    self.likeNumberLabel.textColor = [UIColor firstGrey];
    self.sponsoredNumberLabel.textColor = [UIColor firstGrey];
    
    self.viewedLabel.textColor = [UIColor firstGrey];
    self.likeLabel.textColor = [UIColor firstGrey];
    self.sponsoredLabel.textColor = [UIColor firstGrey];
    
    self.linkLabel.font = [UIFont systemFontOfSize: 18];
    self.linkLabel.textColor = [UIColor secondGrey];
    
    self.horzLineView.backgroundColor = [UIColor thirdGrey];
    self.albumCollectionLabel.textColor = [UIColor firstGrey];        
}
@end
