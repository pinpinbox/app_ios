//
//  HomeDataCollectionReusableView.m
//  wPinpinbox
//
//  Created by David on 5/2/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "HomeDataCollectionReusableView.h"
#import "UIColor+Extensions.h"

@implementation HomeDataCollectionReusableView
- (void)awakeFromNib {
    [super awakeFromNib];
    NSLog(@"awakeFromNib");
    
    self.pageControl.currentPage = 0;
    self.pageControl.pageIndicatorTintColor = [UIColor secondGrey];
    self.pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    self.pageControl.userInteractionEnabled = NO;
}
@end
