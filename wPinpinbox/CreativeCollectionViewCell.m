//
//  CreativeCollectionViewCell.m
//  wPinpinbox
//
//  Created by Angus on 2015/10/28.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "CreativeCollectionViewCell.h"

@implementation CreativeCollectionViewCell
- (void)awakeFromNib
{
    [_bgview.layer setCornerRadius:5];
    [_bgview.layer setBorderWidth:0];
    [_bgview.layer setBorderColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:0.9].CGColor];
    [_bgview.layer setMasksToBounds:YES];
    
    [super awakeFromNib];
}

@end
