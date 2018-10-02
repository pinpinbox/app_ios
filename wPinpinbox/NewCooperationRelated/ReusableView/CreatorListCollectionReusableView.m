//
//  CreatorListCollectionReusableView.m
//  wPinpinbox
//
//  Created by David on 2018/9/26.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "CreatorListCollectionReusableView.h"
#import "UIColor+Extensions.h"

@implementation CreatorListCollectionReusableView
- (void)awakeFromNib {
    [super awakeFromNib];
    NSLog(@"awakeFromNib");
    
    self.topicLabel.font = [UIFont boldSystemFontOfSize: 22.0];
    self.topicLabel.textColor = [UIColor firstGrey];
    self.topicLabel.numberOfLines = 1;
}
@end
