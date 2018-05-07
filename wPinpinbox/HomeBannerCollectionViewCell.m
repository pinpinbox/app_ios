//
//  HomeBannerCollectionViewCell.m
//  wPinpinbox
//
//  Created by David on 12/01/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "HomeBannerCollectionViewCell.h"
#import "GlobalVars.h"

@implementation HomeBannerCollectionViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    NSLog(@"awakeFromNib");
    
    self.bannerImageView.layer.cornerRadius = kCornerRadius;
    self.bannerImageView.layer.masksToBounds = YES;
}
@end
