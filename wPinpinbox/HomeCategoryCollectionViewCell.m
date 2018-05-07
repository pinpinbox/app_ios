//
//  HomeCategoryCollectionViewCell.m
//  wPinpinbox
//
//  Created by David on 12/01/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "HomeCategoryCollectionViewCell.h"
#import "GlobalVars.h"

@implementation HomeCategoryCollectionViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    NSLog(@"awakeFromNib");
    self.categoryBgView.layer.cornerRadius = kCornerRadius;
    self.categoryBgView.layer.masksToBounds = YES;
}
@end
