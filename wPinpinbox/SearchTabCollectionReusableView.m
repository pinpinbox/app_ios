//
//  SearchTabCollectionReusableView.m
//  wPinpinbox
//
//  Created by David on 5/11/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "SearchTabCollectionReusableView.h"
#import "UIColor+Extensions.h"

@implementation SearchTabCollectionReusableView
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.userRecommendationLabel.textColor = [UIColor firstGrey];
    self.albumRecommendationLabel.textColor = [UIColor firstGrey];
    self.horzLineView.backgroundColor = [UIColor secondGrey];
}
@end
