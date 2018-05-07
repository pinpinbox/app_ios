//
//  ChangeInterestsCollectionReusableView.m
//  wPinpinbox
//
//  Created by David on 05/02/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "ChangeInterestsCollectionReusableView.h"
#import "MyLayout.h"

@implementation ChangeInterestsCollectionReusableView
- (void)awakeFromNib {
    [super awakeFromNib];
    self.topicLabel.numberOfLines = 0;
    self.topicLabel.wrapContentHeight = YES;
}

@end
